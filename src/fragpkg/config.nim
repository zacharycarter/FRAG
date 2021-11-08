const
  FragMaxPlugins* = 64
  FragMaxPath* = 256
  FragPluginUpdateInterval* = 1.0'f32

type
  FragConfig* = object
    appName*: cstring
    appTitle*: cstring
    pluginPath*: cstring
    appVersion*: uint32
    
    plugins*: array[FragMaxPlugins, cstring]

    windowWidth*: int32
    windowHeight*: int32

