import config, cstringutils

export config

var
  stateSegmentDefined = false

type
  FragVersion* = object
    major*: int32
    minor*: int32
    patch*: array[32, char]

  FragAppEvent = object
    frameCount: uint64

  FragAppConfigCb* = proc(conf: var FragConfig) {.cdecl.}

  FragPluginEvent* = distinct int32

  FragPluginMainCb* = proc(ctx: var FragPlugin; e: FragPluginEvent) {.cdecl.}
  FragPluginGetInfoCb* = proc(outInfo: var FragPluginInfo) {.cdecl.}
  FragPluginEventHandlerCb* = proc(ev: var FragAppEvent) {.cdecl.}

  FragPluginCrashCode* = distinct int32

  FragPluginInfo* = object
    version*: uint32
    deps*: ptr UncheckedArray[cstring]
    numDeps*: int32
    name*: array[32, char]
    desc*: array[256, char]
    mainCb*: FragPluginMainCb

  FragPlugin* = object
    p: pointer
    api*: ptr FragPluginAPI
    iteration: uint32
    crashReason: FragPluginCrashCode

  FragInternalAppAPI* = object
    gameModule*: proc(): pointer

  FragAppAPI* = object
    name*: proc(): cstring {.cdecl.}
  
  FragCoreAPI* = object
    version*: proc(): FragVersion {.cdecl.}

  FragPluginAPI* = object
    load*: proc(name: cstring): bool {.cdecl.}

const
  fpccNone* = FragPluginCrashCode(0'i32)
  fpccSegfault* = FragPluginCrashCode(1'i32)
  fpccIllegal* = FragPluginCrashCode(2'i32)
  fpccAbort* = FragPluginCrashCode(3'i32)
  fpccMisalign* = FragPluginCrashCode(4'i32)
  fpccBounds* = FragPluginCrashCode(5'i32)
  fpccStackOverflow* = FragPluginCrashCode(6'i32)
  fpccStateInvalidated* = FragPluginCrashCode(7'i32)
  fpccBadImage* = FragPluginCrashCode(8'i32)
  fpccOther* = FragPluginCrashCode(9'i32)
  fpccUser* = FragPluginCrashCode(0x100'i32)

  fpeLoad* = FragPluginEvent(0)
  fpeStep* = FragPluginEvent(1)
  fpeUnload* = FragPluginEvent(2)
  fpeClose* = FragPluginEvent(3)

template initFragPluginState*() =
  when defined Windows:
    if not stateSegmentDefined:
      {.emit: """#pragma section(".state", read, write)""".}
      stateSegmentDefined = true

    {.pragma: fragState, codegenDecl: """$# __declspec(allocate(".state")) $#""".}
  elif defined MacOSX:
    {.pragma: fragState, codegenDecl: """$# __attribute__((used, section("__DATA,__state"))) $#""".}

template declareFragApp*(confParamName, body: untyped) =
  proc fragApp*(confParamName: var FragConfig) {.cdecl, exportc, dynlib.} =
    body

template declareFragPlugin*(pluginName, pluginVersion, pluginDescription,
    pluginDependencies, numDependencies: untyped) =
  proc fragPlugin*(info: var FragPluginInfo) {.cdecl, exportc, dynlib.} =
    info.version = pluginVersion
    info.deps = pluginDependencies
    info.numDeps = numDependencies
    discard strcpy(info.name, sizeof(info.name), astToStr(pluginName))
    discard strcpy(info.desc, sizeof(info.desc), pluginDescription)

template declareFragPluginMain*(name, pluginParamName, eventParamName,
    body: untyped) =
  proc fragPluginMain*(pluginParamName: var FragPlugin;
      eventParamName: FragPluginEvent): int32 {.cdecl, exportc: "cr_main", dynlib.} =
    body

template declareFragAppMain*(name, pluginParamName, eventParamName,
    body: untyped) =
  proc fragPluginMain*(pluginParamName: var FragPlugin;
      eventParamName: FragPluginEvent): int32 {.cdecl, exportc: "cr_main", dynlib.} =
    body

template declareFragPluginEventHandler*(name, eventParamName, body: untyped) =
  proc fragPluginEventHandler(eventParamName: FragAppEvent) {.cdecl, exportc: "fragPluginEventHandler", dynlib.} =
    body

template declareFragAppEventHandler*(name, eventParamName, body: untyped) =
  proc fragPluginEventHandler(eventParamName: FragAppEvent) {.cdecl, exportc: "fragPluginEventHandler", dynlib.} =
    body

template major*(v: untyped): untyped = (v div 1000)
template minor*(v: untyped): untyped = ((v mod 1000) div 10)
template patch*(v: untyped): untyped = (v mod 10)