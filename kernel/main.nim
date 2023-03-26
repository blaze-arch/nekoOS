import drivers/tty
import cpu/gdt
import cpu/idt
import cpu/isrs
import nekoapi
import strutils

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
  setColor(LightBlue, White)
  screenClear() # Make the screen light blue.

  writeString("nekoOS\n")

  initGdt()
  writeString("loaded gdt!\n")
  initIdt()
  writeString("loaded idt!\n")

  asm """
    int $0x03
  """