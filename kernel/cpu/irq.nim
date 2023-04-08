import ../nekoapi
import ports
import idt

const PIC1 = 0x20            # IO base address for master PIC
const PIC2 = 0xA0              # IO base address for slave PIC
const PIC1_COMMAND = PIC1
const PIC1_DATA = (PIC1+1)
const PIC2_COMMAND = PIC2
const PIC2_DATA = (PIC2+1)

const PIC_EOI  = 0x20          # End-of-interrupt command code 
 
const ICW1_ICW4  = 0x01        # Indicates that ICW4 will be present
const ICW1_SINGLE  = 0x02      # Single (cascade) mode 
const ICW1_INTERVAL4 = 0x04    # Call address interval 4 (8) 
const ICW1_LEVEL = 0x08        # Level triggered (edge) mode 
const ICW1_INIT  = 0x10        # Initialization - required! 
 
const ICW4_8086  = 0x01        # 8086/88 (MCS-80/85) mode 
const ICW4_AUTO  = 0x02        # Auto (normal) EOI 
const ICW4_BUF_SLAVE = 0x08    # Buffered mode/slave 
const ICW4_BUF_MASTER = 0x0C  # Buffered mode/master 
const ICW4_SFNM = 0x10        # Special fully nested (not) 

proc irq0*() {.importc.}
proc irq1*() {.importc.}
proc irq2*() {.importc.}
proc irq3*() {.importc.}
proc irq4*() {.importc.}
proc irq5*() {.importc.}
proc irq6*() {.importc.}
proc irq7*() {.importc.}
proc irq8*() {.importc.}
proc irq9*() {.importc.}
proc irq10*() {.importc.}
proc irq11*() {.importc.}
proc irq12*() {.importc.}
proc irq13*() {.importc.}
proc irq14*() {.importc.}
proc irq15*() {.importc.}

# Store handlers for various irqs
var irq_routines: array[0..15, proc(regs:  registers)]

proc getIrq(i: int): uint32 =
  # Get the address of an irq
  if (i == 0):
    result = cast[uint32](irq0)
  elif (i == 1):
    result = cast[uint32](irq1)
  elif (i == 2):
    result = cast[uint32](irq2)
  elif (i == 3):
    result = cast[uint32](irq3)
  elif (i == 4):
    result = cast[uint32](irq4)
  elif (i == 5):
    result = cast[uint32](irq5)
  elif (i == 6):
    result = cast[uint32](irq6)
  elif (i == 7):
    result = cast[uint32](irq7)
  elif (i == 8):
    result = cast[uint32](irq8)
  elif (i == 9):
    result = cast[uint32](irq9)
  elif (i == 10):
    result = cast[uint32](irq10)
  elif (i == 11):
    result = cast[uint32](irq11)
  elif (i == 12):
    result = cast[uint32](irq12)
  elif (i == 13):
    result = cast[uint32](irq13)
  elif (i == 14):
    result = cast[uint32](irq14)
  elif (i == 15):
    result = cast[uint32](irq15)

proc installHandler*(irq: int, handler: proc(r: registers) = nil){.exportc.} =
  irq_routines[irq] = handler

proc uninstallHandler*(irq: int) =
  # Remove handler
  irq_routines[irq] = nil

proc irqSendEoi(irq: uint8) =
  if (irq >= 8):
    out8(PIC2_COMMAND, PIC_EOI)
  out8(PIC1_COMMAND, PIC_EOI)

proc irqRemap(offset1, offset2: uint8) =
  # Prevent irqs from overlapping on PIC
  var a1, a2: uint8 = 0

  a1 = in8(PIC1_DATA)
  a2 = in8(PIC2_DATA)

  out8(PIC1_COMMAND, ICW1_INIT or ICW1_ICW4)
  io_delay()
  out8(PIC2_COMMAND, ICW1_INIT or ICW1_ICW4)
  io_delay()

  out8(PIC1_DATA.uint16, offset1)
  io_delay()
  out8(PIC2_DATA.uint16, offset2)
  io_delay()

  out8(PIC1_DATA.uint16, 4)
  io_delay()

  out8(PIC2_DATA.uint16, 2)
  io_delay()

  out8(PIC1_DATA.uint16, ICW4_8086)
  io_delay()
  out8(PIC2_DATA.uint16, ICW4_8086)
  io_delay()

  out8(PIC1_DATA.uint16, a1)
  out8(PIC2_DATA.uint16, a2)

proc irqInstall*() =
  # Lazily do this instead of memset
  for i in 0..15:
    uninstallHandler(i)
  # Remove conflicts with IRQ 0 - IRQ 8
  irqRemap(32, 40)
  for i in 0..15:
    idtSet(cast[uint8](32 + i), getIrq(i), cast[uint16](0x08), cast[uint8](0x8E))

proc irqHandler*(regs: registers) {.exportc: "irqHandler"} =
  # Handle various irqs
  # Subtract by 32 to take into account we remapped
  print "HEY I ARE A IRQ HANDLER!!!!"

  let irqIndex: uint32 = (regs.int_no) - 32
  
  # DO NOT DELETE NOINIT
  var handler {.noinit.}: proc(regs: registers) = irq_routines[irqIndex]

  # If we have a handler, use it
  if handler != nil:
    print "handler != nil!"
    handler(regs)
  irqSendEoi(regs.int_no.uint8)