import ../nekoapi
import ports
import idt

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

proc irqRemap() =
  # Prevent irqs from overlapping on PIC
  out8(0x20, 0x11)
  out8(0xA0, 0x11)
  out8(0x21, 0x20)
  out8(0xA1, 0x28)
  out8(0x21, 0x04)
  out8(0xA1, 0x02)
  out8(0x21, 0x01)
  out8(0xA1, 0x01)
  out8(0x21, 0x00)
  out8(0xA1, 0x00)

proc irqInstall*() =
  # Lazily do this instead of memset
  for i in 0..15:
    uninstallHandler(i)
  # Remove conflicts with IRQ 0 - IRQ 8
  irqRemap()
  for i in 0..15:
    idtSet(cast[uint8](32 + i), getIrq(i), cast[uint16](0x08), cast[uint8](0x8E))

proc irqHandler*(regs: registers) {.exportc: "irqHandler"} =
  # Handle various irqs
  # Subtract by 32 to take into account we remapped
  let irqIndex: uint32 = (regs.int_no) - 32
  # DO NOT DELETE NOINIT
  var handler{.noinit.}: proc(regs: registers) = irq_routines[irqIndex]
  # If we have a handler, use it
  if handler != nil:
    handler(regs)
  # If the int_no we got is above 39, send a response to the slave pic on 0xA0
  if irqIndex + 32 >= cast[uint32](40):
    out8(0xA0, 0x20)
  # Either way, send a response to the master pic
  out8(0x20, 0x20)