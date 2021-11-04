import ptr_math

type
  OutputMemoryBitStream* = object
    buffer: ptr UncheckedArray[uint8]
    bitHead: uint32
    bitCapacity: uint32

proc `=destroy`*(bs: var OutputMemoryBitStream) =
  if bs.buffer != nil:
    dealloc(bs.buffer)

proc reallocBuffer(bs: var OutputMemoryBitStream; newBitLength: uint32) =
  if bs.buffer.isNil:
    bs.buffer = cast[ptr UncheckedArray[uint8]](alloc0(newBitLength shr 3))
  else:
    var tmpBuffer = cast[ptr UncheckedArray[uint8]](alloc0(newBitLength shr 3))
    copyMem(tmpBuffer.addr, bs.buffer.addr, bs.bitCapacity shr 3)
    dealloc(bs.buffer)
    bs.buffer = move(tmpBuffer)
  
  # TODO: Handle realloc failure

  bs.bitCapacity = newBitLength

proc newOutputMemoryBitStream*(): OutputMemoryBitStream =
  result.reallocBuffer(1500*8)

proc getBufferPtr*(bs: OutputMemoryBitStream): ptr UncheckedArray[uint8] =
  result = bs.buffer

proc getByteLength*(bs: OutputMemoryBitStream): uint32 =
  result = (bs.bitHead + 7) shr 3

proc writeBits(bs: var OutputMemoryBitStream; data: uint8; bitCount: uint32) =
  let nextBitHead = bs.bitHead + bitCount

  if nextBitHead > bs.bitCapacity:
    bs.reallocBuffer(max(bs.bitCapacity * 2, nextBitHead))
  
  let
    byteOffset = bs.bitHead shr 3'u32
    bitOffset = bs.bitHead and 0x7'u32
    currentMask = not(0xff'u32 shl bitOffset).uint8
    bitsFreeThisByte = 8 - bitOffset

  bs.buffer[byteOffset] = (bs.buffer[byteOffset] and currentMask) or (data shl bitOffset)

  if bitsFreeThisByte < bitCount:
    bs.buffer[byteOffset + 1] = data shr bitsFreeThisByte
  
  bs.bitHead = nextBitHead

proc writeBits(bs: var OutputMemoryBitStream; data: pointer; bitCount: uint32) =
  var
    count = bitCount 
    srcByte = cast[ptr UncheckedArray[uint8]](data)[0].addr
  
  while count > 8:
    bs.writeBits(srcByte[], 8)
    srcByte += 1
    count -= 8
  
  if count > 0:
    bs.writeBits(srcByte[], count)

proc write*[T](bs: var OutputMemoryBitStream; data: var T; bitCount = (sizeof(T) * 8).uint32) =
  bs.writeBits(cast[pointer](data.addr), bitCount)