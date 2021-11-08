import frag

declareFragPluginMain(ecs, plugin, e):
  case e
  of fpeStep:
    discard
  of fpeLoad:
    if plugin.iteration == 1:
      echo "Initializing the ECS plugin!"
    else:
      echo "already initialized!"
  of fpeUnload:
    discard
  of fpeClose:
    discard
  else:
    discard

declareFragPluginEventHandler(ecs, e):
  discard

declareFragPlugin(ecs, 1000, "Entity-component-system plugin", nil, 0)
