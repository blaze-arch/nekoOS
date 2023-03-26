import memory

type
  idt_entry {.packed.} = object
    base_low*: uint16
    sel*: uint16
    always0*: uint8
    flags*: uint8
    base_high*: uint16

  idt_ptr {.packed.} = object
    limit*: uint16
    base*: uint32

var idt_arr: array[0..255, idt_entry]
var idt_pointer {.exportc.}: idt_ptr

# Declared in idt.s
proc loadIdt() {.importc: "loadIdt".}

proc idtSet*(index: uint8, base: uint32, sel: uint16, flags: uint8) =
  idt_arr[index].base_low = (base and 0xFFFF).uint16
  idt_arr[index].base_high = ((base shr 16) and 0xFFFF).uint16

  idt_arr[index].sel = sel
  idt_arr[index].always0 = 0
  idt_arr[index].flags = flags

proc initIdt*() =
  # Set the limit and base
  idt_pointer.limit = cast[uint16](sizeof(idt_arr) * 256) - 1
  idt_pointer.base = cast[uint32](idt_arr.addr)

  var ptr_idt: ptr uint8 = cast[ptr uint8](idt_arr.addr)
  memset(ptr_idt, 0, cast[uint32](sizeof(idt_entry) * 256))

  # ISRs go here

  # Tell the cpu about our idt
  loadIdt()
