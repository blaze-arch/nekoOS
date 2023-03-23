template seg_desctype*(x: int): int = x shl 0x04        ## Descriptor type (0 for system, 1 for code/data)
template seg_pres*(x: int): int = x shl 0x07            ## Present
template seg_savl*(x: int): int = x shl 0x0c            ## Available for system use
template seg_long*(x: int): int = x shl 0x0d            ## Long mode
template seg_size*(x: int): int = x shl 0x0e            ## Size (0 for 16-bit, 1 for 32-bit)
template seg_gran*(x: int): int = x shl 0x0f            ## Granularity (0 for 1B - 1MB, 1 for 4KB - 4GB)
template seg_priv*(x: int): int = (x and 0x03) shl 0x05 ## Set privilage level (0 - 3)


const seg_data_rd*        = 0x00 ## Read-Only
const seg_data_rda*       = 0x01 ## Read-Only, accessed
const seg_data_rdwr*      = 0x02 ## Read/Write
const seg_data_rdwra*     = 0x03 ## Read/Write, accessed
const seg_data_rdexpd*    = 0x04 ## Read-Only, expand-down
const seg_data_rdexpda*   = 0x05 ## Read-Only, expand-down, accessed
const seg_data_dwrexpd*   = 0x06 ## Read/Write, expand-down
const seg_data_rdwrexpda* = 0x07 ## Read/Write, expand-down, accessed
const seg_code_ex*        = 0x08 ## Execute-Only
const seg_code_exa*       = 0x09 ## Execute-Only, accessed
const seg_code_exrd*      = 0x0A ## Execute/Read
const seg_code_exrda*     = 0x0B ## Execute/Read, accessed
const seg_code_exc*       = 0x0C ## Execute-Only, conforming
const seg_code_exca*      = 0x0D ## Execute-Only, conforming, accessed
const seg_code_exrdc*     = 0x0E ## Execute/Read, conforming
const seg_code_exrdca*    = 0x0F ## Execute/Read, conforming, accessed

const gdt_code_pl0* = seg_desctype(1) or seg_pres(1) or ## Kernel Code
              seg_savl(0) or seg_long(0) or 
              seg_size(1) or seg_gran(1) or 
              seg_priv(0) or seg_code_exrd

const gdt_data_pl0* = seg_desctype(1) or seg_pres(1) or ## Kernel Data
              seg_savl(0) or seg_long(0) or 
              seg_size(1) or seg_gran(1) or 
              seg_priv(0) or seg_data_rdwr
 
const gdt_code_pl3* = seg_desctype(1) or seg_pres(1) or # Userspace Code
              seg_savl(0) or seg_long(0) or
              seg_size(1) or seg_gran(1) or
              seg_priv(3) or seg_code_exrd

const gdt_data_pl3* = seg_desctype(1) or seg_pres(1) or ## Userspace Data
              seg_savl(0) or seg_long(0) or
              seg_size(1) or seg_gran(1) or
              seg_priv(3) or seg_data_rdwr

proc createDescriptor*(base: uint32, limit: uint32, flag: uint16): uint64 =
  # Create the high 32 bit segment
  result =  limit and 0x000F0000.uint32;                   # set limit bits 19:16
  result = result or (flag shl  8) and 0x00F0FF00.uint32;  # set type, p, dpl, s, g, d/b, l and avl fields
  result = result or (base shr 16) and 0x000000FF.uint32;  # set base bits 23:16
  result = result or base      and 0xFF000000.uint32;      # set base bits 31:24
 
  # Shift by 32 to allow for low part of segment
  result = result shl 32;
 
  # Create the low 32 bit segment
  result = result or base  shl 16;                   # set base bits 15:0
  result = result or limit and 0x0000FFFF;           # set limit bits 15:0

#proc loadGdt*() {.importc: "loadGdt", varargs.}

proc loadGdt*() {.importc: "loadGdt".}

#var gdt_array* {.importc, nodecl.}: ptr seq[uint64]