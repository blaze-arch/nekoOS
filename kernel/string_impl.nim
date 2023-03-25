var
  mem {.noinit.}: array[256000, byte]
  pos: csize_t

proc malloc(size: csize_t): pointer {.exportc: "malloc".} =
  result = cast[pointer](addr mem[pos])
  inc(pos, cast[int](size))

proc free(p: pointer) {.exportc: "free".} =
  discard

proc realloc(p: pointer, size: csize_t): pointer {.exportc: "realloc".} =
  result = malloc(size)

proc calloc(nitems, size: csize_t): pointer {.exportc: "calloc".} =
  result = malloc(nitems * size)
  for i in 0 ..< nitems * size:
    mem[pos + i] = 0

# todo: find a way to make nim not emit exit?
proc exit(status: cint) {.exportc: "exit".} =
  discard