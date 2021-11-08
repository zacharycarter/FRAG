switch("path", "../../")
switch("path", "../../../thirdparty")

when defined(windows):
  #################################################################################
  # A compiler must be specified - on windows vcc is used by default.             #
  # MinGW can optionally be used, but other libraries may not be able to be built #
  # successfully on Windows with MinGW without extra effort (like shaderc).       #
  #################################################################################
  --cc: vcc
  switch("passC", "/std:c++17")
  switch("passC", "/MP")
  switch("passC", "/MDd")
  switch("passC", "/D_HAS_EXCEPTIONS=0")
  # switch("passC", "/IH:\\Projects\\FRAG\\thirdparty\\JoltPhysics\\Jolt\\Core")
  # switch("passC", "/IH:\\Projects\\FRAG\\thirdparty\\JoltPhysics\\Jolt")

  # GCC on windows == mingw
  # --cc:gcc
else:
  {.error: "platform not supported!".}

#########################################################################################
# In order to start the game with networked multiplayer capabilities, a gaming services #
# backend must be defined. The current available options are:                           #
#   - steam                                                                             #
#                                                                                       #
# If no option is provided, networked multiplayer will be disabled.                     #
#########################################################################################
--gc: arc
--d: useMalloc
--u: host
--threads: on
--linetrace: off
--stacktrace: off
--debugger: native
--tlsEmulation: off
