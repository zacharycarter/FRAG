import ../../thirdparty/sokol,
       core, exit_code, log

export exit_code

when defined(windows):
  import winim/lean

  proc messageBox(msg: cstring) =
    MessageBoxA(HWND(0), msg, "frag", MB_OK or MB_ICONERROR)
  
  proc messageBox(msg: var openArray[char]) =
    MessageBoxA(HWND(0), cast[cstring](addr msg[0]), "frag", MB_OK or MB_ICONERROR)

proc init() {.cdecl.} =
  if core.init() != ecSuccess:
    logError("failed initializing core subsystem")
    messageBox("failed initializing core subsystem, see log for details")
    quit(ecFailure)


proc update() {.cdecl.} =
  core.update()

proc shutdown() {.cdecl.} =
  sapp_quit()

proc frag*(): ExitCode =
  var appDesc = sapp_desc(
    init_cb: init,
    frame_cb: update,
    cleanup_cb: shutdown,
    width: 960,
    height: 540,
    window_title: "FRAG",
    sample_count: 4,
    swap_interval: 1,
  )

  sapp_run(addr(appDesc))
  
  result = ecSuccess