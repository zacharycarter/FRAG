const
  FragMaxPlugins* = 64
  FragMaxPath* = 256

type
  FragConfig* = object
    appName*: cstring
    windowTitle*: cstring
    pluginPath*: cstring
    appVersion*: uint32
    
    plugins*: array[FragMaxPlugins, cstring]

    windowWidth*: int32
    windowHeight*: int32

