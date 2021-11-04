import log, plugin, smartptrs

include priv/cr

type
  FragCore* = object

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
