import entt,
       frag

initFragPluginState()

var registry {.fragState.}: Registry

proc init() =
  echo "inializing ECS plugin"

declareFragPluginMain(ecs, plugin, e):
  case e
  of fpeStep:
    discard
  of fpeLoad:
    if plugin.iteration == 1:
      init()
    else:
      echo "ECS plugin reloaded"
  of fpeUnload:
    discard
  of fpeClose:
    discard
  else:
    discard

declareFragPluginEventHandler(ecs, e):
  discard

declareFragPlugin(ecs, 1000, "Entity-component-system plugin", nil, 0)
