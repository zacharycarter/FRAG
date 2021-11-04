import std/strutils

when defined(Windows):
  import winim/lean

proc dlErr*(): string =
  when defined(Windows):
    result = $GetLastError()
