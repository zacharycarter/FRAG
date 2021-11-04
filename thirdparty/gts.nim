import os

const
  sdkPath = currentSourcePath.parentDir()/"GTS-GamesTaskScheduler"
  headerDir = sdkPath/"source/gts/include"

when defined(Windows): 
  {.passC: "/I" & headerDir.}
  {.link: sdkPath/"_build/gts/vs2019/msvc/Debug_x86_64/gts.lib".}
  {.link: sdkPath/"_build/gts_malloc/vs2019/msvc/Debug_x86_64/gts_malloc_static.lib".}
  {.link: "advapi32.lib".}
else:
  {.error: "platform not supported!".}
