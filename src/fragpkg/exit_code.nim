type
  FragExitCode* = distinct uint8

const
  fecSuccess* = FragExitCode(QuitSuccess)
  fecFailure* = FragExitCode(QuitFailure)

converter toInt*(fec: FragExitCode): int =
  int(fec)