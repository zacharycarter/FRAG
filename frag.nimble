# Package

version       = "0.1.0"
author        = "carterza"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
backend       = "cpp"
installExt    = @["nim"]
bin           = @["frag"]


# Dependencies

requires "nim >= 1.4.8"
requires "cligen >= 1.5.19"
requires "winim >= 3.6.1"
requires "colorize >= 0.2.0"
requires "ptr_math >= 0.3.0"
requires "ws >= 0.4.4"
requires "lockfreequeues >= 2.1.0"

task ecs, "build ecs plugin":
  --verbosity:3
  --gc:arc
  --app:lib
  --outdir:"."
  --debugger:native
  --cc:vcc
  switch("out", "ecs.dll")
  setcommand "c", "./src/fragpkg/ecs/entity.nim"