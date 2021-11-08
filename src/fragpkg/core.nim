import ../../thirdparty/glfw,
       api, internal, log, plugin, smartptrs

include priv/cr

type
  FragCore* = object
    frameIdx: uint64
    elapsedTime: float64
    deltaTime: float64
    lastTime: float64
    fpsMean: float32
    fpsFrame: float32

    version: FragVersion

var sFragCore*: UniquePtr[FragCore]

proc staticInit*() =
  sFragCore = newUniquePtr[FragCore](FragCore())

proc loadPluginAbs*(filepath: string; entry: bool;
    entryDeps: var openArray[cstring]; numEntryDeps: int32): bool =
  plugin.loadPluginAbs(filepath, entry, cast[ptr UncheckedArray[cstring]](entryDeps[0].addr), numEntryDeps)

proc initPlugins*(): bool =
  plugin.initPlugins()

proc init*(fc: var FragCore): bool =
  block:
    plugin.staticInit()
    if not sFragPlugin.init():
      logError("failed initializing plugin subsystem")
      break

    result = true

proc frame*() =
  let currentTime = glfwGetTime()
  
  if sFragCore[].lastTime != 0.0'f64: sFragCore[].deltaTime = currentTime - sFragCore[].lastTime
  sFragCore[].lastTime = currentTime
  sFragCore[].elapsedTime += sFragCore[].deltaTime

  let dt = sFragCore[].deltaTime
  if dt > 0:
    var aFPS = sFragCore[].fpsMean
    
    let fps = 1.0'f64 / dt
    aFPS += (fps - aFPS) / sFragCore[].frameIdx.float64
    sFragCore[].fpsMean = aFPS.float32
    sFragCore[].fpsFrame = fps.float32
    
  plugin.update(dt)

  # TODO: Use gainput - https://github.com/jkuhlmann/gainput/issues/43
  glfwPollEvents()

proc version(): FragVersion {.cdecl.} =
  result = sFragCore[].version

sCoreAPI = FragCoreAPI(
  version: version
)