import ../../thirdparty/sokol,
       exit_code, log, network

type
  CoreCtx = object
    frameIdx: int64
    elapsedTick: uint64
    deltaTick: uint64
    lastTick: uint64
    fpsMean: float32
    fpsFrame: float32

    gamerService: GamerService

var ctx: CoreCtx

proc init*(): ExitCode =
  block:
    stm_setup()
    
    log.init()

    ctx.gamerService = network.init()
    
    if ctx.gamerService == gsCount:
      result = ecFailure
      break
    
    result = ecSuccess

proc update*() =
  ctx.deltaTick = stm_laptime(addr(ctx.lastTick))
  ctx.elapsedTick += ctx.deltaTick

  let 
    deltaTick = ctx.deltaTick
    dt = float32(stm_sec(deltaTick))
  
  if deltaTick > 0:
    var afps = float64(ctx.fpsMean)
    let fps = 1.0'f64 / float64(dt)

    afps += (fps - afps) / float64(ctx.frameIdx)
    ctx.fpsMean = float32(afps)
    ctx.fpsFrame = float32(fps)
  
  updateGamerServices()
    
  if getNetworkState() != nsDelay:
    # TODO: update game state
    processIncomingPackets()
    sendOutgoingPackets()
  else:
    updateDelay()