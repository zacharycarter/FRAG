import os

const
  sdkPath = currentSourcePath.parentDir()/"entt"
  srcDir = sdkPath/"src"
  headerDir = sdkPath/"single_include"
  header = headerDir/"entt.hpp"

when defined(Windows):
  if defined(vcc):
    {.passC: "/I" & srcDir.}
    {.passC: "/DENTT_NOEXCEPTION".}

  else:
    {.error: "compiler not supported!".}

type
  Entity* {.importcpp: "entt::entity", header: header.} = object

  Registry* {.importcpp: "entt::registry", header: header.} = object
