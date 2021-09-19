import strutils,
       colorize

type
  LogLevel* = enum
    llError
    llWarning
    llInfo
    llVerbose
    llDebug

  LogEntry* = object
    kind*: LogLevel
    channels*: uint32
    text*: string
    sourceFile*: string
    line*: int

  LogCtx = object
    logLevel: LogLevel

const
  logEntryKinds = [
    "FRAG ERROR: ",
    "FRAG WARNING: ",
    "FRAG INFO: ",
    "FRAG VERBOSE: ",
    "FRAG DEBUG: "
  ]

var ctx: LogCtx

template logInfo*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printInfo(0, iinfo.filename, iinfo.line, msg, args)

template logDebug*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printDebug(0, iinfo.filename, iinfo.line, msg, args)

template logVerbose*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printVerbose(0, iinfo.filename, iinfo.line, msg, args)

template logError*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printError(0, iinfo.filename, iinfo.line, msg, args)

template logWarn*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printWarning(0, iinfo.filename, iinfo.line, msg, args)

proc logTerminalBackend(entry: LogEntry; userData: pointer) =
  var msg: string

  case entry.kind
  of llInfo:
    msg = fgGreen(logEntryKinds[ord(entry.kind)] & entry.text)
  of llDebug:
    msg = fgCyan(logEntryKinds[ord(entry.kind)] & entry.text)
  of llVerbose:
    msg = fgLightCyan(logEntryKinds[ord(entry.kind)] & entry.text)
  of llWarning:
    msg = fgYellow(logEntryKinds[ord(entry.kind)] & entry.text)
  of llError:
    msg = fgRed(logEntryKinds[ord(entry.kind)] & entry.text)

  echo msg

proc dispatchLogEntry(entry: LogEntry) =
  logTerminalBackend(entry, nil)

proc printInfo*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llInfo:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llInfo,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printDebug*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llDebug:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llDebug,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printVerbose*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llVerbose:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llVerbose,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printError*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llError:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llError,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printWarning*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llWarning:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llWarning,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )
  
proc init*(ll: LogLevel = llDebug) =
  ctx.logLevel = ll