import ../lowlevel_nekoapi
import ../nekoapi
import ../cpu/irq
import ../cpu/ports

var tick {.volatile.}: uint32 = 0

proc timerCallback(regs: registers) = 
  tick.inc
  print "Tick: ", tick

proc initTimer*(frequency: uint32) =
  print "initializating timer!"

  installHandler(0, timerCallback)
  var division: uint32 = 1193180'u32 div frequency

  # Send the command byte.
  cli()
  out8(0x43, 0x36)

  var alow: uint8 = (division and 0xff'u32).uint8
  var ahigh: uint8 = ((division shr 8) and 0xff00'u32).uint8

  out8(0x40, alow)
  out8(0x40, ahigh)

proc currentTimerFrequency*(): uint16 =
  cli()
  out8(0x43,0b0000000)

  result = in8(0x40).uint16
  result = result or (in8(0x40).uint16 shr 8)
