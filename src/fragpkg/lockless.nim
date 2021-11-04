import atomics,
       ptr_math

type
  SpscNode = object
    next: ptr SpscNode

  SpscBin = object
    ptrs: ptr UncheckedArray[ptr SpscNode]
    buff: ptr UncheckedArray[uint8]
    next: ptr SpscBin
    iter: int32
    reserved: int32

  SpscQueue* = object
    ptrs: ptr UncheckedArray[ptr SpscNode]
    buff: ptr UncheckedArray[uint8]
    iter: int32
    capacity: int32
    stride: int32
    buffSize: int32

    first: ptr SpscNode
    last {.align(64).}: Atomic[ptr SpscNode]
    divider {.align(64).}: Atomic[ptr SpscNode]

    growBins: ptr SpscBin

template alignMask*(value, mask: untyped): untyped =
  (((value.uint) + (mask.uint)) and ((not 0'u) and (not(mask.uint))))

proc `=destroy`*(bin: var SpscBin) =
  assert not cast[ptr SpscBin](bin.addr).isNil

  freeShared(bin.addr)

proc `=destroy`*(queue: var SpscQueue) =
  if cast[ptr SpscQueue](queue.addr) != nil:
    if queue.growBins != nil:
      var bin = queue.growBins
      while bin != nil:
        let next = bin.next
        `=destroy`(bin)
        bin = next
    
    queue.iter = 0
    queue.capacity = queue.iter
    freeShared(queue.addr)

proc createBin(itemSize, capacity: int32): ptr SpscBin =
  assert capacity mod 16 == 0

  block:
    var buff = cast[ptr UncheckedArray[uint8]](allocShared(
      sizeof(SpscBin).int32 + (itemSize + sizeof(pointer).int32 + sizeof(SpscNode).int32) * capacity
    ))

    if buff.isNil:
      # TODO: Handle OOM
      result = nil
      break
    
    result = cast[ptr SpscBin](buff)
    buff += sizeof(SpscBin)
    result.ptrs = cast[ptr UncheckedArray[ptr SpscNode]](buff)
    buff += sizeof(ptr SpscNode) * capacity
    result.buff = buff
    result.next = nil

    result.iter = capacity
    
    for i in 0 ..< capacity:
      result.ptrs[capacity - i - 1] =
        cast[ptr SpscNode](result.buff + (sizeof(SpscNode).int32 * itemSize) * i)

proc create*(itemSize, capacity: int32): ptr SpscQueue =
  assert itemSize > 0

  let cap = alignMask(capacity, 15).int32

  block:
    var 
      buff = cast[ptr UncheckedArray[uint8]](
        allocShared(sizeof(SpscQueue).int32 + (itemSize + sizeof(pointer).int32 + sizeof(SpscNode)) * capacity)
      )
    
    if buff.isNil:
      # TODO: Handle OOM
      result = nil
      break

    result = cast[ptr SpscQueue](buff)
    buff += sizeof(SpscQueue)
    result.ptrs = cast[ptr UncheckedArray[ptr SpscNode]](buff)
    buff += sizeof(ptr SpscNode) * cap
    result.buff = buff

    result.iter = cap
    result.capacity = cap
    result.stride = itemSize
    result.buffSize = (itemSize + sizeof(SpscNode).int32) * cap

    for i in 0 ..< cap:
      result.ptrs[cap - i - 1] =
        cast[ptr SpscNode](result.buff + (sizeof(SpscNode).int32 + itemSize) * i)
    
    dec(result.iter)
    let node = result.ptrs[result.iter]
    node.next = nil
    result.first = node
    result.last.store(node)
    result.divider.store(result.last.load)
    result.growBins = nil

proc produce*(queue: ptr SpscQueue; data: pointer): bool =
  var
    node: ptr SpscNode = nil
    nodeBin: ptr SpscBin = nil
  
  if queue.iter > 0:
    dec(queue.iter)
    node = queue.ptrs[queue.iter]
  else:
    var bin = queue.growBins
    while bin != nil and node.isNil:
      if bin.iter > 0:
        dec(bin.iter)
        node = bin.ptrs[bin.iter]
        nodeBin = bin
      
      bin = bin.next
  
  if node != nil:
    copyMem(node + 1, data, queue.stride)
    node.next = nil

    let last = queue.last.load()
    last.next = node

    discard exchange(queue.last, node)

    while queue.first != queue.divider.load():
      let first = queue.first
      queue.first = first.next

      let firstPtr = cast[uint](first)
      if firstPtr >= cast[uint](queue.buff) and firstPtr < cast[uint](queue.buff + queue.buffSize):
        assert queue.iter != queue.capacity
        queue.ptrs[queue.iter] = first
        inc(queue.iter)
      else:
        var bin = queue.growBins
        while bin != nil:
          if firstPtr >= cast[uint](bin.buff) and firstPtr < cast[uint](bin.buff + queue.buffSize):
            assert bin.iter != queue.capacity
            bin.ptrs[bin.iter] = first
            inc(bin.iter)
            break
          bin = bin.next
        assert bin != nil
    
    result = true
  else:
    result = false

proc consume*(queue: ptr SpscQueue; data: pointer): bool =
  if queue.divider.load() != queue.last.load():
    let divider = queue.divider.load()
    assert(divider.next != nil)
    copyMem(data, divider.next + 1, queue.stride)

    discard exchange(queue.divider, divider.next)
    result = true
  else:
    result = false

proc grow*(queue: ptr SpscQueue): bool =
  let bin = createBin(queue.stride, queue.capacity)
  if bin != nil:
    if queue.growBins != nil:
      var last = queue.growBins
      while last.next != nil: last = last.next
      last.next = bin
    else:
      queue.growBins = bin
    result = true
  else:
    result = false

proc full*(queue: ptr SpscQueue): bool =
  block:
    if queue.iter > 0:
      result = false
      break
    else:
      var bin = queue.growBins
      while bin != nil:
        if bin.iter > 0:
          result = false
          break
        bin = bin.next
  
  result = true
