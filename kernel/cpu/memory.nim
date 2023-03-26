proc memset*(begin: pointer, value: uint8, size: uint32) {.exportc.} =
  var aBegin = cast[ptr uint8](begin)
  for i in 0..size:
    aBegin = cast[ptr uint8](cast[uint32](aBegin) + i)
    aBegin[] = 0