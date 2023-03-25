proc abort*(): void {.exportc.} =
    # TODO: Send SIGABRT
    return;

proc memmove*(dst: ptr, src: ptr, size: csize_t): ptr {.exportc.} =
    if dst < src:
        for i in 0..size:
            dst[i] = src[i]
    else:
        for i in size..0:
            dst[i-1] = src[i-1]
    return dst

proc strlen*(str: cstring): csize_t {.exportc.} =
    var size: csize_t = 0
    for ch in str:
        size += 1
    return size

proc memcmp*(aptr: ptr, bptr: ptr, size: csize_t): cint {.exportc.} =
    for i in 0..size:
        if aptr[i] < bptr[i]:
            return -1
        elif bptr[i] < aptr[i]:
            return 1
    return 0;

proc memset*(bufptr: ptr, value: cint, size: csize_t): ptr {.exportc.} =
    for i in 0..size:
        bufptr[i] = value
    return bufptr

proc memcpy*(dstptr: ptr, srcptr: ptr, size: csize_t): ptr {.exportc.} =
    for i in 0..size:
        dstptr[i] = srcptr[i]
    return dstptr;
