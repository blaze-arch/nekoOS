import drivers/tty
import cpu/gdt
import cpu/idt

# Need to import so that it compiles along with the whole project
import string_impl

type
  TMultiboot_header = object
  PMultiboot_header = ptr TMultiboot_header

proc NimMain {.importc.}

proc kmain(mb_header: PMultiboot_header, magic: int) {.exportc.} =
  NimMain() # Call Nim's main procedure so that all global code is executed properly.
  if magic != 0x2BADB002:
    discard # Something went wrong?

  var vram = cast[PVIDMem](0xB8000)

  initTTY(vram)
  screenClear(vram, LightBlue) # Make the screen light blue.

  setColor(makeColor(LightBlue, White))
  writeLn("nekoOS")

  gdt_arr[0] = createGlobalDescriptor(0, 0, 0)
  gdt_arr[1] = createGlobalDescriptor(0, 0x000FFFFF, gdt_code_pl0)
  gdt_arr[2] = createGlobalDescriptor(0, 0x000FFFFF, gdt_data_pl0)

  loadGdt(addr gdt_arr)
  loadIdt(addr idt_arr)

  writeLn("Loaded GDT and IDT!")

  var str = "Look at me!"
  str &= " Wow, I got some more text!"

  writeLn(str)
  write("uwu\nuwu\n")
  writeLn("other test")