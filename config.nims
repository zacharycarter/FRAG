when defined(windows):
  #################################################################################
  # A compiler must be specified - on windows vcc is used by default.             #
  # MinGW can optionally be used, but other libraries may not be able to be built #
  # successfully on Windows with MinGW without extra effort (like shaderc).       #
  #################################################################################
  --cc:vcc

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
--d:steam