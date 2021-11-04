when defined(Windows):
  import os

  const
    sdkPath = currentSourcePath.parentDir()/"stackwalkerc"
    header = sdkPath/"stackwalkerc.h"

  when defined(vcc):
    {.passC: "/D SW_IMPL".}
    {.passC: "/I " & sdkPath.}


  type
    SwSysHandle* = pointer

  proc swLoadDbghelp*(): SwSysHandle {.importc: "sw_load_dbghelp",
      header: header.}
