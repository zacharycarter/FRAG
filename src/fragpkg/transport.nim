import ws

type
  Transport* = object
    connection: WebSocket

when isMainModule:
  import asyncdispatch, httpclient, os, lockless

  type
    AsyncRequest = iterator

  var
    workerThread: Thread[void]

    

  proc loop(): Future[void] {.async.} =
    discard

  proc worker() {.thread.} =
    waitFor loop()

  createThread(workerThread, worker)

  
  
  joinThreads(workerThread)