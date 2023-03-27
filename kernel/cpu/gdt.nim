type
  gdt_entry {.packed.} = object
    limit_low*: uint16
    base_low*: uint16
    base_middle*: uint8
    access*: uint8
    granularity*: uint8
    base_high*: uint8

  gdt_ptr {.packed.} = object
    limit*: uint16
    base*: uint32

var gdt_arr*: array[5, gdt_entry]
var gdt_pointer {.exportc.}: gdt_ptr

proc loadGdt() {.importc: "loadGdt".} # declared in gdt.s

proc gdtSet*(index: int, base: uint32, limit: uint32, access: uint8, gran: uint8) =
  gdt_arr[index].base_low = (base and 0xFFFF).uint16
  gdt_arr[index].base_middle = ((base shr 16) and 0xFF).uint8
  gdt_arr[index].base_high = ((base shr 24) and 0xFF).uint8

  gdt_arr[index].limit_low = (limit and 0xFFFF).uint16
  gdt_arr[index].granularity = ((limit shr 16) and 0x0F).uint8

  gdt_arr[index].granularity = gdt_arr[index].granularity or (gran and 0xF0)
  gdt_arr[index].access = access

proc initGdt*() =
  # Set the gdt pointer and limit
  gdt_pointer.limit = cast[uint16]((sizeof(gdt_entry) * 5) - 1)
  gdt_pointer.base = cast[uint32](addr(gdt_arr))

  # Init null descriptor
  gdtSet(0, 0, 0, 0, 0)

  # Init kernel code segment
  gdtSet(1, 0, 0xFFFFFFFF'u32, 0x9A, 0xCF)

  # Init kernel data segment
  gdtSet(2, 0, 0xFFFFFFFF'u32, 0x92, 0xCF)

  # User mode code segment
  gdtSet(3, 0, 0xFFFFFFFF'u32, 0xFA, 0xCF)

  # User mode data segment
  gdtSet(4, 0, 0xFFFFFFFF'u32, 0xF2, 0xCF)

  # Tell the cpu about our GDT
  loadGdt()