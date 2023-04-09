#[

    nekoOS
    Copyright (C) 2023  blaze_arch

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

]#

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

proc irqUnmask() = 
  var current_i = 0
  var port: uint16 = 0
  var value: uint8 = 0
  for i in 0..15:
    current_i.inc
    if current_i < 8:
      port = PIC1_DATA
    else:
      port = PIC2_DATA
      current_i = current_i - 8
    value = ((in8(port)).uint8 and (not(1 shl current_i)).uint8).uint8
    out8(port, value)

proc irqInstall*() =
  # Lazily do this instead of memset
  for i in 0..15:
    uninstallHandler(i)
  # Remove conflicts with IRQ 0 - IRQ 8
  irqRemap(32, 40)
  irqUnmask()
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