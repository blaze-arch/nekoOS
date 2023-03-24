import ioutils
import drivers/gdt
# Need to import so that it compiles along with the whole project
import string_impl
import std/tables

type
  TMultiboot_header = object
  PMultiboot_header = ptr TMultiboot_header

var gdt_seq: array[64, uint64]

proc NimMain {.importc.}

proc kmain(mb_header: PMultiboot_header, magic: int) {.exportc.} =
  NimMain() # Call Nim's main procedure so that all global code is executed properly.
  if magic != 0x2BADB002:
    discard # Something went wrong?

  var vram = cast[PVIDMem](0xB8000)
  screenClear(vram, LightBlue) # Make the screen light blue.

  # Demonstration of error handling.
  #var x = len(vram[])
  #var outOfBounds = vram[x]

  let attr = makeColor(LightBlue, White)
  writeString(vram, "NekoOS", attr, (25, 9))
  
  gdt_seq[0] = createDescriptor(0, 0, 0)
  gdt_seq[1] = createDescriptor(0, 0x000FFFFF, gdt_code_pl0)
  gdt_seq[2] = createDescriptor(0, 0x000FFFFF, gdt_data_pl0)

  loadGdt(addr gdt_seq)

  writeString(vram, "I need to make keyboard driver XD", attr, (25, 10))
  var str = "Look at me!"
  str &= " Wow, I got some more text!"

  writeString(vram, str, attr, (25, 11))

  #var x = newOrderedTable[string, string]()
  #x["Hello"] = "World"
  #x["World"] = "Hello"
  #let otherStr = $x
  #writeString(vram, otherStr, attr, (25, 12))
