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


import drivers/tty
import cpu/gdt
import cpu/idt
#import cpu/isrs
import cpu/irq
import drivers/timer
import nekoapi
#import strutils

# Need to import so that it compiles along with the whole project
import string_impl

type
  TMultiboot_header = object
  PMultiboot_header = ptr TMultiboot_header

proc NimMain {.importc.}

proc kmain(mb_header: PMultiboot_header, magic: int) {.exportc.} =
  NimMain() # Call Nim's main procedure so that all global code is executed properly.
  if magic != 0x2BADB002:
    discard # Something went wrong?

  var vram = cast[PVIDMem](0xB8000)

  initTTY(vram)
  setColor(LightBlue, White)
  screenClear() # Make the screen light blue.

  print "nekoOS"

  initGdt()
  print "loaded gdt!"
  initIdt()
  print "loaded idt!"
  irqInstall()
  print "loaded irq!"
  
  initTimer(3)
  print "inited?"
  print "currentTimerFrequency() = ", currentTimerFrequency()

  initTimer(2)
  print "experimento"
  print currentTImerFrequency()

