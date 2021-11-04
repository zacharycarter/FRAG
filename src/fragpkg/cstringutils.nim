proc strcpy*(
  dst: var openArray[char];
  dstSz: int;
  src: cstring;
): cstring =
  assert src != nil

  let
    srcLen = src.len
    max = dstSz - 1
    num = if srcLen < max: srcLen else: max

  if num > 0:
    copymem(dst[0].addr, src[0].unsafeAddr, num)

  dst[num] = '\0'

  result = dst[num].addr

converter toCstring*[N: static int](a: var array[N, char]): cstring =
  cast[cstring](a[0].addr)