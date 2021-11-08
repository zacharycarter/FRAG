import std/[algorithm, dynlib, os],
       ../../thirdparty/[cr, sw],
       api, cstringutils, internal, log, platform, smartptrs

when defined(Windows):
  import winim/lean

  type
    ImageNtHeader_t = proc(baseAddr: pointer): PIMAGE_NT_HEADERS64 {.stdcall.}

  var fImageNtHeader: ImageNtHeader_t

include ../../thirdparty/cr

type
  FragPluginDependency = object
    name: array[32, char]

  FragPluginObj = object
    dll: pointer
    eventHandler: FragPluginEventHandlerCb
    main: FragPluginMainCb

  CRPluginFragPluginObj {.union.} = object
    plug: cr_plugin
    obj: FragPluginObj

  FragPluginItem = object
    crpfp: CRPluginFragPluginObj

    info: FragPluginInfo
    order: int32
    filepath: array[FragMaxPath, char]
    updateTime: float32
    deps: seq[FragPluginDependency]

  FragPluginManager* = object
    loaded: bool
    when defined(Windows):
      dbgHelp: HMODULE
    plugins: seq[FragPluginItem]
    pluginUpdateOrder: seq[int]

var
  sFragPlugin*: UniquePtr[FragPluginManager]

proc newFragPluginItem*(): FragPluginItem =
  result.updateTime = FragPluginUpdateInterval

proc staticInit*() =
  sFragPlugin = newUniquePtr[FragPluginManager](FragPluginManager())

proc init*(mgr: FragPluginManager): bool =
  block:
    when defined(Windows):
      sFragPlugin[].dbgHelp = cast[HMODULE](swLoadDbgHelp())
      if sFragPlugin[].dbgHelp != 0:
        fImageNtHeader = cast[ImageNtHeader_t](symAddr(cast[LibHandle](
            sFragPlugin[].dbgHelp), "ImageNtHeader"))

        if fImageNtHeader.isNil:
          logError("cannot locate `ImageNtHeader` symbol in dbghelp.dll")
          break
    result = true

proc loadPluginAbs*(filepath: string; entry: bool;
    entryDeps: ptr UncheckedArray[cstring]; numEntryDeps: int32): bool =
  block:
    var item = newFragPluginItem()
    item.crpfp.plug.userData = sPluginApi.addr

    var dll: pointer = nil
    if not entry:
      dll = loadLib($filepath)
      if dll.isNil:
        logError("failed loading plugin: $1: dllerr($2)", filepath, dlerr())
        break

      let getInfo = cast[FragPluginGetInfoCb](dll.symAddr("fragPlugin"))
      if getInfo.isNil:
        logError("failed locating `fragPlugin` symbol in plugin: $1", filepath)
        break

      getInfo(item.info)
    else:
      dll = sInternalAppAPI.gameModule()
      discard strcpy(item.info.name, sizeof(item.info.name), sAppAPI.name())

    discard strcpy(item.filepath, sizeof(item.filepath), filepath)

    let
      numDeps = if entry: numEntryDeps else: item.info.numDeps
      deps = if entry: entryDeps else: item.info.deps

    if numDeps > 0 and not deps.isNil:
      item.deps = newSeq[FragPluginDependency](numDeps)

      for i in 0 ..< numDeps:
        discard strcpy(item.deps[i].name, sizeof(item.deps[i].name), deps[i])

    item.order = -1

    unloadLib(dll)

    sFragPlugin[].plugins.add(item)
    sFragPlugin[].pluginUpdateOrder.add(sFragPlugin[].plugins.len() - 1)

    result = true

proc sortDeps(): bool =
  block:
    let numPlugins = sFragPlugin[].plugins.len()

    if numPlugins == 0:
      break
  
    var
      level = 0'i32
      count = 0
    while count < numPlugins:
      let initCount = count
      for i in 0 ..< numPlugins:
        let 
          item = sFragPlugin[].plugins[i].addr
          numDeps = item.deps.len()
        if item.order == -1:
          if numDeps > 0:
            var numDepsMet = 0
            for d in 0 ..< numDeps:
              for j in 0 ..< numPlugins:
                let parentItem = sFragPlugin[].plugins[j].addr
                if i != j and parentItem.order != -1 and
                  parentItem.order <= (level - 1) and
                  parentItem.info.name == item.deps[d].name:
                    inc(numDepsMet)
                    break
            
            if numDepsMet == numDeps:
              item.order = level
              inc(count)
          else:
            item.order = 0
            inc(count)
      
      if initCount == count:
        break

      inc(level)

    if count != numPlugins:
      logError("the following plugins' dependences weren't met:")
      for i in 0 ..< numPlugins:
        let 
          item = sFragPlugin[].plugins[i].addr
          numDeps = item.deps.len()
        if item.order == -1:
          var depStr = "["
          for d in 0 ..< numDeps:
            if d != numDeps - 1:
              discard strcpy(depStr, depStr.len(), item.deps[d].name)
            else:
              depStr &= "]"
        
        logError("\t$1 - (depends) -> $2", if item.info.name[0] != char(0): $item.info.name else: "[entry]")
      
      result = false
      break

    sort(sFragPlugin[].pluginUpdateOrder)

    result = true

proc initPlugins*(): bool =
  block outer:
    if not sortDeps():
      break outer

    for idx in sFragPlugin[].pluginUpdateOrder:
      let item = sFragPlugin[].plugins[idx].addr

      when defined(Windows):
        # TODO: Do stackwalker stuff here...
        # swReloadModules()
        discard

      if not openPlugin(item[].crpfp.plug, "H:\\Projects\\FRAG\\" & $item.filepath.cstring):
        logError("failed initializing plugin: $1", item.filepath.cstring)
        break outer

      if item.info.name[0] != char(0):
        let version = item.info.version
        logInfo("initialized plugin: $1 ($2) - $3 - v$4.$5.$6", item.info.name.cstring, extractFilename($item.filepath.cstring), item.info.desc.cstring, major(version), minor(version), patch(version))

    sFragPlugin[].loaded = true
    result = true

proc update*(dt: float32) =
  for i in sFragPlugin[].pluginUpdateOrder:
    let plugin = sFragPlugin[].plugins[sFragPlugin[].pluginUpdateOrder[i]].addr

    var checkReload = false
    plugin.updateTime += dt
    if plugin.updateTime >= FragPluginUpdateInterval:
      checkReload = true
      plugin.updateTime = 0
    
    let r = updatePlugin(plugin.crpfp.plug, true)
    if r == -2:
      logError("plugin: '$1' - failed to reload", sFragPlugin[].plugins[i].info.name.cstring)
    elif r < -1:
      if plugin.crpfp.plug.failure == CR_USER:
        logError("plugin: '$1' - failed (main ret = $2)", sFragPlugin[].plugins[i].info.name.cstring, r)
      else:
        logError("plugin: '$1' crashed", sFragPlugin[].plugins[i].info.name.cstring)

proc loadPlugin(name: cstring): bool {.cdecl.} =
  assert(not sFragPlugin[].loaded, "loading of additional plugins forbidden after `initPlugins` is invoked")

  result = loadPluginAbs($name & ".dll", false, nil, 0)

sPluginAPI = FragPluginAPI(
  load: loadPlugin
)  