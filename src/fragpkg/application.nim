import std/dynlib, std/os, std/strformat,
       ../../thirdparty/[glfw],
       api, core, cstringutils, internal, log, smartptrs

when defined(Windows):
  import winim/lean

proc messageBox(msg: cstring) =
  when defined(Windows):
    MessageBoxA(HWND(0), msg, "frag", MB_OK or MB_ICONERROR)

proc messageBox[N: static int](msg: array[N, char]) =
  when defined(Windows):
    MessageBoxA(HWND(0), msg, "frag", MB_OK or MB_ICONERROR)

template saveConfigStr(cacheStr, str: untyped) =
  if str != nil:
    discard strcpy(cacheStr, sizeof(cacheStr), str)
    str = cacheStr
  else:
    str = cacheStr

type
  FragApp* = object
    appFilepath: string

    conf: FragConfig
    window: ptr GLFWwindow
    gameModuleHandle: pointer

proc `=destroy`*(fa: var FragApp) =
  if fa.window != nil:
    glfwDestroyWindow(fa.window)

  glfwTerminate()

const
  dt = 0.01'f64
  maxFrameTime = 0.25'f64

var
  sFragApp*: UniquePtr[FragApp]


  defaultAppName: array[64, char]
  defaultAppTitle: array[64, char]
  defaultPlugins: array[FragMaxPlugins, array[32, char]]

proc errorCb(error: int32; description: cstring) {.cdecl.} =
  logError("$1", description)

proc keyCb(window: ptr GLFWwindow; key: int32; scanCode: int32; action: int32;
    mods: int32) {.cdecl.} =
  if key == GLFW_KEY_ESCAPE and action == GLFW_PRESS:
    glfwSetWindowShouldClose(window, GLFW_TRUE)

proc staticInit*() =
  sFragApp = newUniquePtr[FragApp](FragApp())

proc init(fa: var FragApp): bool =
  block:
    glfwSetErrorCallback(errorCb)

    if glfwInit() != GLFW_TRUE:
      break

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)

    fa.window = glfwCreateWindow(960, 540, "FRAG", nil, nil)

    if fa.window.isNil:
      break

    glfwSetKeyCallback(fa.window, keyCb)

    result = true

proc frame() = 
  core.frame()

proc appName(): cstring {.cdecl.} =
  result = sFragApp[].conf.appName

proc getGameModule*(): pointer =
  result = sFragApp[].gameModuleHandle

proc run*(fa: var FragApp; appFilepath: string) =
  block outer:
    block:
      if not fileExists(appFilepath):
        messageBox(&"shared library with filepath: '{appFilepath}' - does not exist")
        break outer

      let libHandle = loadLib(appFilepath)
      if libHandle.isNil:
        messageBox(&"shared library at filepath: '{appFilepath}' - is not valid")
        break outer

      let gameConfigFn = cast[FragAppConfigCb](libHandle.symAddr("fragApp"))
      if gameConfigFn.isNil:
        messageBox(&"symbol `fragApp` not found in shared library at filepath: {appFilepath}")
        break outer

      fa.conf = FragConfig(
        appName: defaultAppName,
        appTitle: defaultAppTitle,
        appVersion: 1000
      )

      gameConfigFn(fa.conf)

      saveConfigStr(defaultAppName, fa.conf.appName)
      saveConfigStr(defaultAppTitle, fa.conf.appTitle)

      for i in 0 ..< FragMaxPlugins:
        if not fa.conf.plugins[i].isNil:
          saveConfigStr(defaultPlugins[i], fa.conf.plugins[i])

      unloadLib(libHandle)

      sFragApp[].appFilepath = appFilepath
    block:
      if not fa.init():
        messageBox("failed initializing application, see log for details")
        break outer

      core.staticInit()
      if not sFragCore.init():
        logError("failed initializing core")
        messageBox("failed initializing core, see log for details")
        break outer

      var numPlugins = 0
      for i in 0 ..< FragMaxPlugins:
        if fa.conf.plugins[i].isNil or fa.conf.plugins[i].len == 0:
          break

        if not sPluginAPI.load(fa.conf.plugins[i]):
          break outer

        inc numPlugins
      
      if not loadPluginAbs(sFragApp[].appFilepath, true, sFragApp[].conf.plugins, numPlugins.int32):
        logError("failed loading application plugin: $1", sFragApp[].appFilepath)
        messageBox("failed loading plugin, see log for details")
        break outer
    
      if not initPlugins():
        logError("failed initializing plugins")
        messageBox("failed initializing plugins, see log for details")
        break outer

    var
      frameTime: float64

      t = 0.0'f64
      accumulator = 0.0'f64
      currentTime = glfwGetTime()

    while not glfwWindowShouldClose(fa.window):
      let newTime = glfwGetTime()
      
      frameTime = newTime - currentTime
      if frameTime > 0.25'f64:
        frameTime = 0.25'f64
      currentTime = newTime
      
      accumulator += frameTime

      while accumulator >= dt:
        frame()
        t += dt
        accumulator -= dt

sInternalAppAPI = FragInternalAppAPI(
  gameModule: getGameModule
)

sAppAPI = FragAppAPI(
  name: appName
)
