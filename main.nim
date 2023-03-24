import ioutils
import drivers/gdt
import drivers/idt
import drivers/ports
# Need to import so that it compiles along with the whole project
import string_impl

type
  TMultiboot_header = object
  PMultiboot_header = ptr TMultiboot_header

var idt_arr: array[256, interruptDescriptor]
var gdt_arr: array[64, uint64]

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
  
  gdt_arr[0] = createGlobalDescriptor(0, 0, 0)
  gdt_arr[1] = createGlobalDescriptor(0, 0x000FFFFF, gdt_code_pl0)
  gdt_arr[2] = createGlobalDescriptor(0, 0x000FFFFF, gdt_data_pl0)

  idt_arr[0] = createInterruptDescriptor(0, 
                createSegmentSelector(0, 0, cpu_ring0),
                intteruptGate32bit, 
                cpu_ring0)

  loadGdt(addr gdt_arr)
  loadIdt(addr idt_arr)

  writeString(vram, "I need to make keyboard driver XD", attr, (25, 10))
  var str = "Look at me!"
  str &= " Wow, I got some more text!"

  writeString(vram, str, attr, (25, 11))

  #var x = newOrderedTable[string, string]()
  #x["Hello"] = "World"
  #x["World"] = "Hello"
  #let otherStr = $x
  #writeString(vram, otherStr, attr, (25, 12))
