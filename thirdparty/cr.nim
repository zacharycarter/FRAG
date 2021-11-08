when defined(host):
  import os

  const sdkPath = currentSourcePath.parentDir()

  when defined(windows):
    {.passL: "-ldbghelp".}
    {.passC: "/I" & sdkPath/"cr".}
  # {.compile: "./cr_impl.cpp".}
  {.emit:"""/*INCLUDESECTION*/
  #define CR_DEBUG
  #define CR_HOST CR_UNSAFE
  #include "cr.h"
  """.}


type
  cr_failure* = distinct int32

  cr_op* = distinct int32

  cr_plugin* {.importcpp.} = object
    p*: pointer
    userData* {.importcpp: "userdata".}: pointer
    version*: uint32
    failure*: cr_failure
    nextVersion*: uint32
    lastWorkingVersion*: uint32


const
  CR_NONE* = cr_failure(0)
  CR_SEGFAULT* = cr_failure(1)
  CR_ILLEGAL* = cr_failure(2)
  CR_ABORT* = cr_failure(3)
  CR_MISALIGN* = cr_failure(4)
  CR_BOUNDS* = cr_failure(5)
  CR_STACKOVERFLOW* = cr_failure(6)
  CR_STATE_INVALIDATED* = cr_failure(7)
  CR_BAD_IMAGE* = cr_failure(8)
  CR_INITIAL_FAILURE* = cr_failure(9)
  CR_OTHER* = cr_failure(10)
  CR_USER* = cr_failure(0x100)

  CR_LOAD* = cr_op(0)
  CR_STEP* = cr_op(1)
  CR_UNLOAD* = cr_op(2)
  CR_CLOSE* = cr_op(3)

when defined(host):
  const
    header = "H:\\Projects\\FRAG\\thirdparty\\cr\\cr.h"

  proc `==`*(a, b: cr_failure): bool {.borrow.}

  proc openPlugin*(ctx: cr_plugin, fullpath: cstring): bool {.importcpp: "cr_plugin_open(@)", header: header.}
  proc updatePlugin*(ctx: cr_plugin, reloadCheck: bool = true): int32 {.importcpp: "cr_plugin_update(@)", header: header.}
  proc closePlugin*(ctx: cr_plugin) {.importcpp: "cr_plugin_close(@)", header: header.}