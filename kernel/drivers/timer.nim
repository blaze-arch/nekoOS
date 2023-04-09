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
