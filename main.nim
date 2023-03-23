import ioutils
import drivers/gdt

type
  TMultiboot_header = object
  PMultiboot_header = ptr TMultiboot_header

var gdt_seq: array[64, uint64]

var gdt_ptr = cast[uint32](gdt_seq.addr)

proc kmain(mb_header: PMultiboot_header, magic: int) {.exportc.} =
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

  # gdt_ptr__main_6 - is gdt_ptr from this file
  asm """
  mov eax, `gdt_ptr__main_6`
  """

  loadGdt()

  writeString(vram, "I need to make keyboard driver XD", attr, (25, 10))
  