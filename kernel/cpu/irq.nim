import ../nekoapi
import ports

proc irq_handler(regs: registers) =
  # Send an EOI (end of interrupt) signal to the PICs.
  # If this interrupt involved the slave.
  if regs.int_no >= 40:
    out8(0xa0, 0x20)
  # Send reset signal to master. (As well as slave, if necessary).
  out8(0x20, 0x20)

  