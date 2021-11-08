import fragpkg/api

export api

static:
  when defined Windows:
    {.emit: """#pragma section(".state", read, write)""".}

when isMainModule:
  import cligen,
         fragpkg/[application, smartptrs]

  proc frag(app: string) =
    application.staticInit()
    sFragApp.run(app)

  dispatch(frag, help = {"app": "shared library with application / game code to load"})
