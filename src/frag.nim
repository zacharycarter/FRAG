import fragpkg/[app, smartptrs]

when isMainModule:
  let game = newUniquePtr[FragApp](newFragApp())
  quit(game.run())
