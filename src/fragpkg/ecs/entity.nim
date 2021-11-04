import frag

declareFragPluginMain(ecs, plugin, e):
  case e
  of fpeStep:
    discard
  of fpeLoad:
    if plugin.iteration == 1:
      echo "Initializing plugin!"
  of fpeUnload:
    discard
  of fpeClose:
    discard
  else:
    discard

  result = 0

declareFragPlugin(ecs, 1000, "Entity-component-system plugin", nil, 0)
