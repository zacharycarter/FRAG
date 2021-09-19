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
requires "winim >= 3.6.1"
requires "colorize >= 0.2.0"
requires "ptr_math >= 0.3.0"