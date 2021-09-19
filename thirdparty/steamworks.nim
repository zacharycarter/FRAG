import os

const sdkPath = currentSourcePath.parentDir().parentDir()

when defined(Windows):
  const lib = sdkPath & "\\thirdparty\\steamworks\\sdk\\redistributable_bin\\win64\\steam_api64.lib"
  {.link: lib.}
  const apiHeader = sdkPath & "\\thirdparty\\steamworks\\sdk\\public\\steam\\steam_api.h"
  const clientHeader = sdkPath & "\\thirdparty\\steamworks\\sdk\\public\\steam\\isteamclient.h"
  const clientPublicHeader = sdkPath & "\\thirdparty\\steamworks\\sdk\\public\\steam\\steamclientpublic.h"
  const matchmakingHeader = sdkPath & "\\thirdparty\\steamworks\\sdk\\public\\steam\\isteammatchmaking.h"
  const userStatsHeader = sdkPath & "\\thirdparty\\steamworks\\sdk\\public\\steam\\isteamuserstats.h"
  const universeHeader = sdkPath & "\\thirdparty\\steamworks\\sdk\\public\\steam\\steamuniverse.h.h"

type
  LobbyComparison* {.importcpp: "ELobbyComparison", header: matchmakingHeader.} = enum
    lcEqualToOrLessThan = -2
    lcLessThan = -1
    lcEqual = 0
    lcGreaterThan = 1
    lcEqualToOrGreaterThan = 2
    lcNotEqual = 3
  
  LobbyType* {.importcpp: "ELobbyType", header: matchmakingHeader.} = enum
    ltPrivate = 0
    ltFriendsOnly = 1
    ltPublic = 2
    ltInvisible = 3

  LeaderboardSortMethod* {.importcpp: "ELeaderboardSortMethod", header: userStatsHeader.} = enum
    lbsmNone = 0
    lbsmAscending = 1
    lbsmDescending = 2

  LeaderboardDisplayType* {.importcpp: "ELeaderboardDisplayType", header: userStatsHeader.} = enum
    lbdtNone = 0
    lbdtNumeric = 1
    lbdtTimeSeconds = 2
    lbdtTimeMilliSeconds = 3

  ChatRoomEnterResponse* {.importcpp: "EChatRoomEnterResponse", header: apiHeader.} = enum
    crerSuccess = 1
    crerDoesntExist = 2
    crerNotAllowed = 3
    crerFull = 4
    crerError = 5
    crerBanned = 6
    crerLimited = 7
    crerClanDisabled = 8
    crerCommunityBan = 9
    crerMemberBlockedYou = 10
    crerYouBlockedMember = 11
  
  Result* {.importcpp: "EResult", header: clientPublicHeader.} = enum
    rOk = 1
    rFail = 2
    rNoConnection = 3
    rInvalidPassword = 5
    rLoggedInElsewhere = 6
  
  Universe* {.importcpp: "EUniverse", header: universeHeader.} = enum
    uInvalid = 0
    uPublic = 1
    uBeta = 2
    uInternal = 3
    uDev = 4
    uMax = 5

  SteamIDComponent {.importcpp: "SteamIDComponent_t", header: clientPublicHeader.}  = object
    when defined(bigEndian):
      discard
    else:
      unAccountID {.importcpp: "m_unAccountID", bitsize: 32.}: uint32
      unAccountInstance {.importcpp: "m_unAccountInstance", bitsize: 20.}: uint
      accountKind {.importcpp: "m_EAccountType", bitsize: 4.}: uint
      universe {.importcpp: "m_EUniverse", bitsize: 8.}: Universe

  SteamID {.union, importcpp: "SteamID_t", header: clientPublicHeader.} = object
    component {.importcpp: "m_comp".}: SteamIDComponent
    unAll64Bits {.importcpp: "m_unAll64Bits".}: uint64

  CSteamID* {.importcpp, header: clientPublicHeader.} = object
    steamID {.importcpp: "m_steamid".}: SteamID

  LobbyMatchList* {.importcpp: "LobbyMatchList_t", header: matchmakingHeader.} = object
    numMatchingLobbies* {.importcpp: "m_nLobbiesMatching".}: uint32

  LobbyCreated* {.importcpp: "LobbyCreated_t", header: matchmakingHeader.} = object
    result* {.importcpp: "m_eResult".}: Result
    lobbySteamID* {.importcpp: "m_ulSteamIDLobby".}: CSteamID
  
  LobbyEnter* {.importcpp: "LobbyEnter_t", header: matchmakingHeader.} = object
    lobbySteamID*  {.importcpp: "m_ulSteamIDLobby".}: CSteamID
    unused {.importcpp: "m_rgfChatPermissions".}: uint32
    locked* {.importcpp: "m_bLocked".}: bool
    response* {.importcpp: "m_EChatRoomEnterResponse".}: ChatRoomEnterResponse
  
  SteamLeaderboard* {.importcpp: "SteamLeaderboard_t", header: userStatsHeader.} = distinct uint64

  LeaderboardFindResult* {.importcpp: "LeaderboardFindResult_t", header: userStatsHeader.} = object
    steamLeaderboard*  {.importcpp: "m_hSteamLeaderboard".}: SteamLeaderboard
    leaderboardFound* {.importcpp: "m_bLeaderboardFound".}: uint8
  
  ISteamClient {.importcpp.} = object
  ISteamUser {.importcpp.} = object
  ISteamUserStats {.importcpp.} = object
  ISteamFriends {.importcpp.} = object
  ISteamMatchmaking {.importcpp.} = object
  ISteamNetworking {.importcpp.} = object

  SteamworksCtx = object
    requestLobbyListCb: proc(lobbyMatchList: ptr LobbyMatchList; ioFailure: bool)
    lobbyCreatedCb: proc(lobbyCreated: ptr LobbyCreated; ioFailure: bool)
    leaderboardFoundCb: proc(leaderboardFindResult: ptr LeaderboardFindResult; ioFailure: bool)
    lobbyEnteredCb: proc(lobbyEntered: ptr LobbyEnter; ioFailure: bool)

var ctx: SteamworksCtx

proc SetFromUint64(id: CSteamID; uid: uint64) {.importcpp, cdecl.}
converter toCSteamID*(id: uint64): CSteamID =
  SetFromUint64(result, id)
proc `==`*(a, b: CSteamID): bool {.importcpp: "operator==", cdecl.}

proc SteamAPI_Init*(): bool {.importcpp, cdecl, header: apiHeader.}
proc SteamAPI_RunCallbacks*() {.importcpp, cdecl, header: apiHeader.}

proc SteamClient*(): ptr ISteamClient {.importcpp, cdecl.}
proc SetWarningMessageHook*(c: ptr ISteamClient; callback: proc(severity: int32; pchDebugText: cstring) {.cdecl.}) 
  {.importcpp: "#.SetWarningMessageHook((SteamAPIWarningMessageHook_t)#)", cdecl, header: clientHeader.}

proc ConvertToUint64*(id: CSteamID): uint64 {.importcpp, cdecl.}

proc SteamUser*(): ptr ISteamUser {.importcpp, cdecl.}
proc GetSteamID*(u: ptr ISteamUser): CSteamID {.importcpp, cdecl.}

proc SteamUserStats*(): ptr ISteamUserStats {.importcpp, cdecl.}
proc RequestCurrentStats*(s: ptr ISteamUserStats): bool {.importcpp, cdecl, discardable.}


proc SteamFriends*(): ptr ISteamFriends {.importcpp, cdecl.}
proc GetPersonaName*(f: ptr ISteamFriends): cstring {.importcpp: "(char *)#->GetPersonaName()", cdecl.}
proc GetFriendPersonaName*(f: ptr ISteamFriends; friendID: CSteamID): cstring {.importcpp: "(char *)#->GetFriendPersonaName(@)", cdecl.}

proc SteamMatchmaking*(): ptr ISteamMatchmaking {.importcpp, cdecl.}
proc AddRequestLobbyListResultCountFilter*(m: ptr ISteamMatchmaking; cMaxResults: int32) {.importcpp, cdecl.}
proc AddRequestLobbyListStringFilter*(m: ptr ISteamMatchmaking; pchKeyToMatch, pchValueToMatch: cstring; eComparisonType: LobbyComparison) 
  {.importcpp, cdecl.}
proc GetLobbyByIndex*(m: ptr ISteamMatchmaking; idx: int32): CSteamID {.importcpp, cdecl.}
proc GetLobbyMemberByIndex*(m: ptr ISteamMatchmaking; lobbyID: CSteamID; idx: int32): CSteamID {.importcpp, cdecl.}
proc GetLobbyOwner*(m: ptr ISteamMatchmaking; steamIDLobby: CSteamID): CSteamID {.importcpp, cdecl.}
proc GetNumLobbyMembers*(m: ptr ISteamMatchmaking; lobbyID: CSteamID): int32 {.importcpp, cdecl.}
proc SetLobbyData*(m: ptr ISteamMatchmaking; steamIDLobby: CSteamID; pchKey: cstring; pchValue: cstring) {.importcpp, cdecl.}

proc SteamNetworking*(): ptr ISteamNetworking {.importcpp, cdecl.}
proc IsP2PPacketAvailable*(n: ptr ISteamNetworking; pcubMsgSize: ptr uint32; nChannel: int32 = 0) {.importcpp, cdecl.}
proc ReadP2PPacket*(n: ptr ISteamNetworking; pubDest: pointer; cubDest: uint32; pcubMsgSize: ptr uint32; psteamIDRemote: ptr CSteamID; nChannel: int32 = 0) {.importcpp, cdecl.}


# Callback bridge
proc requestLobbyList(lobbyMatchList: ptr LobbyMatchList, ioFailure: bool) {.cdecl.} =
  ctx.requestLobbyListCb(lobbyMatchList, ioFailure)

proc createLobby(lobbyCreated: ptr LobbyCreated; ioFailure: bool) {.cdecl.} =
  ctx.lobbyCreatedCb(lobbyCreated, ioFailure)

proc enterLobby(lobbyEnter: ptr LobbyEnter; ioFailure: bool) {.cdecl.} =
  ctx.lobbyEnteredCb(lobbyEnter, ioFailure)

proc findOrCreateLeaderboard(leaderboardFindResult: ptr LeaderboardFindResult; ioFailure: bool) {.cdecl.} =
  ctx.leaderboardFoundCb(leaderboardFindResult, ioFailure)

{.emit: """
class CallbackBridge {
public:
void OnLobbyMatchList(LobbyMatchList_t *pLobbyMatchList, bool bIOFailure);
CCallResult< CallbackBridge, LobbyMatchList_t  > m_LobbyMatchListCallResult;

void OnLobbyCreate(LobbyCreated_t *pLobbyCreated, bool bIOFailure);
CCallResult< CallbackBridge, LobbyCreated_t  > m_LobbyCreateCallResult;

void OnLobbyEnter(LobbyEnter_t *pLobbyEnter, bool bIOFailure);
CCallResult< CallbackBridge, LobbyEnter_t  > m_LobbyEnterCallResult;

void OnLeaderFindCallback(LeaderboardFindResult_t *pLeaderboardFindResult, bool bIOFailure);
CCallResult< CallbackBridge, LeaderboardFindResult_t > m_LeaderFindCallResult;
};

void CallbackBridge::OnLobbyMatchList(LobbyMatchList_t *pLobbyMatchList, bool bIOFailure){
  `requestLobbyList`(pLobbyMatchList, bIOFailure);
}

void CallbackBridge::OnLobbyCreate(LobbyCreated_t *pLobbyCreated, bool bIOFailure){
  `createLobby`(pLobbyCreated, bIOFailure);
}

void CallbackBridge::OnLobbyEnter(LobbyEnter_t *pLobbyEnter, bool bIOFailure){
  `enterLobby`(pLobbyEnter, bIOFailure);
}

void CallbackBridge::OnLeaderFindCallback(LeaderboardFindResult_t *pLeaderboardFindResult, bool bIOFailure){
  `findOrCreateLeaderboard`(pLeaderboardFindResult, bIOFailure);
}

CallbackBridge *cbb = new CallbackBridge();
""".}


proc requestLobbyList*(m: ptr ISteamMatchmaking; cb: proc(lobbyMatchList: ptr LobbyMatchList; ioFailure: bool)) =
  ctx.requestLobbyListCb = cb
  {.emit: """
  SteamAPICall_t call = `m`->RequestLobbyList();
  cbb->m_LobbyMatchListCallResult.Set(call, cbb, &CallbackBridge::OnLobbyMatchList);
  """.}

proc createLobby*(m: ptr ISteamMatchmaking; lobbyType: LobbyType; maxPlayers: int32; cb: proc(l: ptr LobbyCreated; ioFailure: bool)) =
  ctx.lobbyCreatedCb = cb
  {.emit: """
  SteamAPICall_t call = `m`->CreateLobby((ELobbyType)`lobbyType`, `maxPlayers`);
  cbb->m_LobbyCreateCallResult.Set(call, cbb, &CallbackBridge::OnLobbyCreate);
  """.}

proc joinLobby*(m: ptr ISteamMatchmaking; lobbyID: CSteamID; cb: proc(l: ptr LobbyEnter; ioFailure: bool)) =
  ctx.lobbyEnteredCb = cb
  {.emit: """
  SteamAPICall_t call = `m`->JoinLobby(`lobbyID`);
  cbb->m_LobbyEnterCallResult.Set(call, cbb, &CallbackBridge::OnLobbyEnter);
  """.}

proc findOrCreateLeaderboard*(m: ptr ISteamUserStats; name: cstring; sortMethod: LeaderboardSortMethod; displayType: LeaderboardDisplayType; cb: proc(l: ptr LeaderboardFindResult; ioFailure: bool)) =
  ctx.leaderboardFoundCb = cb
  {.emit: """
  SteamAPICall_t call = `m`->FindOrCreateLeaderboard(`name`, `sortMethod`, `displayType`);
  cbb->m_LeaderFindCallResult.Set(call, cbb, &CallbackBridge::OnLeaderFindCallback);
  """.}