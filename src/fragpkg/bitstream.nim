import ptr_math

type
  InputMemoryBitStream* = ref object
    buffer: ptr UncheckedArray[uint8]
    bitHead: uint32
    bitCapacity: uint32
    isBufferOwner: bool
  
  OutputMemoryBitStream* = object
    buffer: ptr UncheckedArray[uint8]
    bitHead: uint32
    bitCapacity: uint32

proc newInputMemoryBitStream*(buffer: ptr UncheckedArray[uint8]; bitCount: uint32): InputMemoryBitStream =
  result = InputMemoryBitStream(
    buffer: buffer,
    bitCapacity: bitCount,
    bitHead: 0'u32,
    isBufferOwner: false
  )

proc resetToCapacity*(imbs: InputMemoryBitStream; byteCapacity: uint32) =
  imbs.bitCapacity = byteCapacity shl 3
  imbs.bitHead = 0

proc readBits(imbs: InputMemoryBitStream;`out`: ptr uint8; bitCount: uint32) =
  let
    byteOffset = imbs.bitHead shr 3
    bitOffset = imbs.bitHead and 0x7
  
  `out`[] = cast[uint8](imbs.buffer[byteOffset]) shr bitOffset

  let bitsFreeThisByte = 8 - bitOffset
  if bitsFreeThisByte < bitCount:
    `out`[] = `out`[] or cast[uint8](imbs.buffer[byteOffset + 1]) shl bitsFreeThisByte

  `out`[] = `out`[] and ( not( 0x00ff'u8 shl bitCount ) )

  imbs.bitHead += bitCount

proc readBits(imbs: InputMemoryBitStream;`out`: pointer; bitCount: uint32) =
  var destByte = cast[ptr uint8](`out`)

  var bc = bitCount
  while bc > 8:
    readBits(imbs, destByte, 8)
    destByte += 1
    bc -= 8
  
  if bc > 0:
    readBits(imbs, destByte, bc)

proc read*(imbs: InputMemoryBitStream; `out`: var uint32; bitCount: uint32 = 32) =
  readBits(imbs, addr(`out`), bitCount)

proc newOutputMemoryBitStream*(buffer: ptr UncheckedArray[uint8]; bitCount: uint32): InputMemoryBitStream =
  result = InputMemoryBitStream(
    buffer: buffer,
    bitCapacity: bitCount,
    bitHead: 0'u32,
    isBufferOwner: false
  )

proc writeBits(ombs: OutputMemoryBitStream; `in`: pointer; bitCount: uint32) =
  var srcByte = cast[cstring](`in`)

  var bc = bitCount
  while bc > 8:
    

proc write*[T](ombs: OutputMemoryBitStream; `in`: T; bitCount: uint32 = sizeof(T) * 8) =
  # TODO: add check to make sure only primitive data types can be passed here
  writeBits(ombs, addr(`in`), bitCount)