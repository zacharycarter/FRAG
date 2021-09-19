import deques, tables,
       ../../thirdparty/sokol,
       bitstream

type
  ReceivedPacket = ref object
    receivedTime: uint64
    buffer: InputMemoryBitStream
    fromPlayer: uint64

  NetworkState* = enum
    nsUninitialized
    nsSearching
    nsLobby
    nsReady
    nsStarting
    nsPlaying
    nsDelay

  NetworkContext = object
    packetQueue: Deque[ReceivedPacket]
    playerNameMap: Table[uint64, string]
    state: NetworkState
    
    name: string

    playerCount: int32
    readyCount: int32

    playerID: uint64
    lobbyID: uint64
    masterPeerID: uint64

    isMasterPeer: bool
  
  GamerService* = enum
    gsSteam
    gsNone
    gsCount

const
  maxPacketsPerFrame = 10

  cmdTurn = "TURN"
  cmdReady = "REDY"
  cmdStart = "STRT"
  cmdDelay = "DELY"

var ctx: NetworkContext

proc newReceivedPacket(receivedTime: uint64; buffer: InputMemoryBitStream; fromPlayer: uint64): ReceivedPacket =
  result = ReceivedPacket(
    receivedTime: receivedTime,
    fromPlayer: fromPlayer,
    buffer: buffer
  )

when defined(steam):
  import ../../thirdparty/steamworks,
         log

  proc enterLobby(lobbySteamID: uint64)
  proc joinLobby()
  proc onLeaderboardFoundCb(l: ptr LeaderboardFindResult; ioFailure: bool)

  type
    Leaderboard = enum
      lbKillCount
      lbLostCount
      lbCount

    LeaderboardData = object
      name: cstring
      sortMethod: LeaderboardSortMethod
      displayType: LeaderboardDisplayType
      handle: SteamLeaderboard

    SteamworksContext = object
      leaderboardsReady: bool
      lobbyID: CSteamID
      leaderboardData: array[lbCount, LeaderboardData]
      currentLeaderFind: int
  
  const
    gameName = "FRAG"
    maxPlayers = 8'i32
  
  converter toInt(lb: Leaderboard): int =
    result = ord(lb)
  
  converter toLeaderboard(i: int32): Leaderboard =
    result = Leaderboard(i)

  var steamworksCtx: SteamworksContext

  proc newLeaderboardData(name: string; sortMethod: LeaderboardSortMethod; displayType: LeaderboardDisplayType): LeaderboardData =
    result.name = name
    result.sortMethod = sortMethod
    result.displayType = displayType
    result.handle = SteamLeaderboard(0'u64)

  proc steamAPIDebugTextCB*(severity: int32; pchDebugText: cstring) {.cdecl.} =
    logDebug($pchDebugText)
  
  proc retrieveStatsAsync() =
    RequestCurrentStats(SteamUserStats())
  
  proc findLeaderboardAsync(lb: Leaderboard) =
    steamworksCtx.currentLeaderFind = lb

    let lead = steamworksCtx.leaderboardData[lb]

    findOrCreateLeaderboard(SteamUserStats(), lead.name, lead.sortMethod, lead.displayType, onLeaderboardFoundCb)
  
  proc retrieveLeaderboardsAsync() =
    logDebug("attempting to retrieve leaderboard data...")
    findLeaderboardAsync(Leaderboard(0))

  proc initSteamworks*(): GamerService =
    block:
      logInfo("attempting to initialize steamworks...")
      if SteamAPI_Init():
        logInfo("sucessfully initialized steamworks")
        result = gsSteam
      else:
        logInfo("failed to initialize steamworks")
        result = gsCount
        break

      steamworksCtx.leaderboardData = [
        newLeaderboardData("KillCount", lbsmDescending, lbdtNumeric),
        newLeaderboardData("LostCount", lbsmAscending, lbdtNumeric),
      ]
      
      steamworksCtx.currentLeaderFind = -1
      
      SetWarningMessageHook(SteamClient(), steamAPIDebugTextCb)

      retrieveStatsAsync()

      retrieveLeaderboardsAsync()

  proc updateGamerServices*() =
    SteamAPI_RunCallbacks()
  
  proc onLeaderboardFoundCb(l: ptr LeaderboardFindResult; ioFailure: bool) =
    block:
      if ioFailure or not bool(l.leaderboardFound):
        logWarn("failed retrieving leaderboard data")
        break
      
      inc(steamworksCtx.currentLeaderFind)
      if steamworksCtx.currentLeaderFind != ord(lbCount):
        findLeaderboardAsync(Leaderboard(steamworksCtx.currentLeaderFind))
      else:
        steamworksCtx.leaderboardsReady = true
        logDebug("successfully retrieved leaderboard data")


  proc onLobbyCreateCb(l: ptr LobbyCreated; ioFailure: bool) =
    block:
      if ioFailure or (l.result != rOk):
        logError("failed creating steam lobby")
        break
      
      logDebug("successfully created steam lobby")

      steamworksCtx.lobbyID = l.lobbySteamID

      SetLobbyData(SteamMatchmaking(), steamworksCtx.lobbyID, "game", gameName)

      enterLobby(ConvertToUint64(steamworksCtx.lobbyID))

  proc onLobbyMatchListCb(l: ptr LobbyMatchList; ioFailure: bool) =
    block:
      if ioFailure:
        logError("failed retrieving list of lobbies from steam")
        break

      logDebug("number of $1 lobbies found: $2", gameName, l.numMatchingLobbies)

      if l.numMatchingLobbies > 0:
        steamworksCtx.lobbyID = GetLobbyByIndex(SteamMatchmaking(), 0)
        joinLobby()
      else:
        logDebug("creating public steam lobby for up to $1 players...", maxPlayers)
        createLobby(SteamMatchmaking(), ltPublic, maxPlayers, onLobbyCreateCb)
  
  proc onLobbyEnteredCallback(l: ptr LobbyEnter; ioFailure: bool) =
    block:
      if ioFailure:
        logError("failed joining lobby")
        break

      if l.response == crerSuccess:
        steamworksCtx.lobbyID = l.lobbySteamID
        enterLobby(ConvertToUint64(steamworksCtx.lobbyID))
      else:
        logError("failed joining lobby")

  proc getLocalPlayerID*(): uint64 =
    result = ConvertToUint64(GetSteamID(SteamUser()))
    logDebug("retrieved steam user ID: $1", result)

  proc getLocalPlayerName*(): string =
    result = $cast[cstring](GetPersonaName(SteamFriends()))
    logDebug("retrieved steam persona name: $1", result)
  
  proc getRemotePlayerName*(playerID: uint64): string =
    result = $cast[cstring](GetFriendPersonaName(SteamFriends(), playerID))
  
  proc joinLobby() =
    logDebug("joining lobby...")
    joinLobby(SteamMatchmaking(), steamworksCtx.lobbyID, onLobbyEnteredCallback)

  proc searchLobbiesAsync*() =
    AddRequestLobbyListStringFilter(SteamMatchmaking(), "game", gameName, lcEqual)

    AddRequestLobbyListResultCountFilter(SteamMatchmaking(), 1'i32)

    requestLobbyList(SteamMatchmaking(), onLobbyMatchListCb)

  proc getLobbyNumPlayers*(lobbyID: uint64): int32 =
    result = GetNumLobbyMembers(SteamMatchmaking(), lobbyID)
  
  proc getMasterPeerID*(lobbyID: uint64): uint64 =
    result = ConvertToUint64(GetLobbyOwner(SteamMatchmaking(), lobbyID))

  proc getLobbyPlayerMap(lobbyID: uint64; playerMap: var Table[uint64, string]) =
    let 
      myID = getLocalPlayerID()
      count = getLobbyNumPlayers(lobbyID)
    
    clear(playerMap)
    
    for i in 0 ..< count:
      let playerID = GetLobbyMemberByIndex(SteamMatchmaking(), lobbyID, i)
      
      if playerID == myID:
        playerMap[ConvertToUint64(playerID)] = getLocalPlayerName()
      else:
        playerMap[ConvertToUint64(playerID)] = getRemotePlayerName(ConvertToUint64(playerID))
  
  proc p2pPacketAvailable(packetSize: var uint32): bool =
    IsP2PPacketAvailable(SteamNetworking(), addr(packetSize))

  proc readP2PPacket(packet: pointer; maxLength: uint32; fromPlayer: var uint64): uint32 =
    var
      packetSize: uint32
      fromID: CSteamID
    
    ReadP2PPacket(SteamNetworking(), packet, maxLength, addr(packetSize), addr(fromID))

    fromPlayer = ConvertToUint64(fromID)

    result = packetSize

  proc init*(): GamerService =
    block:
      result = initSteamworks()

      if result != gsSteam:
        break

      ctx.playerID = getLocalPlayerID()
      ctx.name = getLocalPlayerName()

      ctx.state = nsSearching

      searchLobbiesAsync()
else:
  proc init*(): GamerService =
    logWarn("no gamer service defined, disabling multiplayer...")
    result = gsNone

proc tryStartingGame() =
  if ctx.state == nsReady and ctx.isMasterPeer and ctx.playerCount == ctx.readyCount:
    logInfo("starting game...")

proc updateLobbyPlayers() =
  if ctx.state < nsStarting:
    ctx.playerCount = getLobbyNumPlayers(ctx.lobbyID)
    ctx.masterPeerID = getMasterPeerID(ctx.lobbyID)

    if ctx.masterPeerID == ctx.playerId:
      ctx.isMasterPeer = true
    
    getLobbyPlayerMap(ctx.lobbyID, ctx.playerNameMap)

    tryStartingGame()

proc enterLobby(lobbySteamID: uint64) =
  ctx.lobbyID = lobbySteamID
  ctx.state = nsLobby
  updateLobbyPlayers()

proc getNetworkState*(): NetworkState = 
  result = ctx.state

proc readIncomingPacketsIntoQueue() =
  var
    fromPlayer: uint64
    incomingSize = 0'u32
    receivedPacketCount = 0'u32
    totalNumBytesRead = 0'u32
    packetMem {.global.}: array[1500, uint8]
  
  let packetSize = uint32(sizeof(packetMem))

  let inputStream = newInputMemoryBitStream(
    cast[ptr UncheckedArray[uint8]](addr(packetMem[0])), 
    uint32(packetSize * 8)
  )

  while p2pPacketAvailable(incomingSize) and
    receivedPacketCount < maxPacketsPerFrame:
      if incomingSize <= packetSize:
        let numBytesRead = readP2PPacket(cast[pointer](addr(packetMem[0])), packetSize, fromPlayer)
        if numBytesRead > 0:
          resetToCapacity(inputStream, numBytesRead)
          inc(receivedPacketCount)
          totalNumBytesRead += numBytesRead

          addFirst(ctx.packetQueue, newReceivedPacket(stm_now(), inputStream, fromPlayer))
  
  if totalNumBytesRead > 0:
    # TODO: Update bytes received per second
    discard

proc sendReadyPacketsToPeers() =
  var outPacket = 

proc handleReadyPacket(bitstream: var InputMemoryBitStream; fromPlayer: uint64) =
  if ctx.readyCount == 0:
    sendReadyPacketsToPeers()
    inc(ctx.readyCount)
    ctx.state = nsReady
  
  inc(ctx.readyCount)
  tryStartingGame()

proc processLobbyPackets(bitstream: var InputMemoryBitStream; fromPlayer: uint64) =
  var packetType: uint32
  read(bitstream, packetType)

  case packetType
  of cmdReady:
    handleReadyPacket(bitstream, fromPlayer)
  else:
    discard

proc processPacket(bitStream: var InputMemoryBitStream; fromPlayer: uint64) =
  case ctx.state
  of nsLobby:
    processLobbyPackets(bitStream, fromPlayer)
  else:
    discard

proc processQueuedPackets() =
  while len(ctx.packetQueue) > 0:
    var nextPacket = popFirst(ctx.packetQueue)
    if stm_now() > nextPacket.receivedTime:
      processPacket(nextPacket.buffer, nextPacket.fromPlayer)
    else:
      break

proc processIncomingPackets*() =
  readIncomingPacketsIntoQueue()

  processQueuedPackets()

proc sendOutgoingPackets*() =
  discard

proc updateDelay*() =
  discard