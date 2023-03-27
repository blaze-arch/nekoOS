import ports
import ../drivers/tty
import ../nekoapi

var interrupt_handlers: array[0..255, uint32]

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

proc remapIrq*() =
  out8(0x20, 0x11)
  out8(0xA0, 0x11)
  out8(0x21, 0x20)
  out8(0xA1, 0x28)
  out8(0x21, 0x04)
  out8(0xA1, 0x02)
  out8(0x21, 0x01)
  out8(0xA1, 0x01)
  out8(0x21, 0x0)
  out8(0xA1, 0x0)

proc irqHandler(regs: registers) {.exportc.} =
  # Send an EOI (end of interrupt) signal to the PICs.
  # If this interrupt involved the slave.

  var handler = cast[proc(){.cdecl.}](cast[pointer](interrupt_handlers[regs.int_no]))

  if handler != nil:
    handler()

  if regs.int_no >= 40:
    out8(0xa0, 0x20)  # Send reset signal to slave.

  # Send reset signal to master. (As well as slave, if necessary).
  out8(0x20, 0x20);

proc registerInterruptHandler*(index: uint8, handler: uint32) =
  interrupt_handlers[index] = handler

