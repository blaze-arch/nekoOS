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

import isrs

type
  idt_entry {.packed.} = object
    base_low*: uint16
    sel*: uint16
    always0*: uint8
    flags*: uint8
    base_high*: uint16

  idt_ptr {.packed.} = object
    limit*: uint16
    base*: uint32

var idt_arr: array[0..255, idt_entry]
var idt_pointer {.exportc.}: idt_ptr

# Declared in idt.s
proc loadIdt() {.importc: "loadIdt".}

proc idtGet*(index: uint8): idt_entry =
  result = idt_arr[index]

proc idtGetAddress*(index: uint8): uint32 =
  result = (idtGet(index).base_high).uint32
  result = result or ((idtGet(index).base_low shl 16).uint32)

proc idtSet*(index: uint8, base: uint32, sel: uint16, flags: uint8) =
  idt_arr[index].base_low = (base and 0xFFFF).uint16
  idt_arr[index].base_high = ((base shr 16) and 0xFFFF).uint16

  idt_arr[index].sel = sel
  idt_arr[index].always0 = 0
  # We must uncomment the OR below when we get to using user-mode.
  # It sets the interrupt gate's privilege level to 3.
  idt_arr[index].flags = flags # or 0x60.uint8

proc initIdt*() =

  # Set the limit and base
  idt_pointer.limit = cast[uint16](sizeof(idt_arr) * 256) - 1
  idt_pointer.base = cast[uint32](idt_arr.addr)

  #var ptr_idt: ptr uint8 = cast[ptr uint8](idt_arr.addr)
  #memset(ptr_idt, 0, cast[uint32](sizeof(idt_entry) * 256))

  # ISRs go here
  idtSet(0, cast[uint32](isr0), 0x08, 0x8e)
  idtSet(1, cast[uint32](isr1), 0x08, 0x8e)
  idtSet(2, cast[uint32](isr2), 0x08, 0x8e)
  idtSet(3, cast[uint32](isr3), 0x08, 0x8e)
  idtSet(4, cast[uint32](isr4), 0x08, 0x8e)
  idtSet(5, cast[uint32](isr5), 0x08, 0x8e)
  idtSet(6, cast[uint32](isr6), 0x08, 0x8e)
  idtSet(7, cast[uint32](isr7), 0x08, 0x8e)
  idtSet(8, cast[uint32](isr8), 0x08, 0x8e)
  idtSet(9, cast[uint32](isr9), 0x08, 0x8e)
  idtSet(10, cast[uint32](isr10), 0x08, 0x8e)
  idtSet(11, cast[uint32](isr11), 0x08, 0x8e)
  idtSet(12, cast[uint32](isr12), 0x08, 0x8e)
  idtSet(13, cast[uint32](isr13), 0x08, 0x8e)
  idtSet(14, cast[uint32](isr14), 0x08, 0x8e)
  idtSet(15, cast[uint32](isr15), 0x08, 0x8e)
  idtSet(16, cast[uint32](isr16), 0x08, 0x8e)
  idtSet(17, cast[uint32](isr17), 0x08, 0x8e)
  idtSet(18, cast[uint32](isr18), 0x08, 0x8e)
  idtSet(19, cast[uint32](isr19), 0x08, 0x8e)
  idtSet(20, cast[uint32](isr20), 0x08, 0x8e)
  idtSet(21, cast[uint32](isr21), 0x08, 0x8e)
  idtSet(22, cast[uint32](isr22), 0x08, 0x8e)
  idtSet(23, cast[uint32](isr23), 0x08, 0x8e)
  idtSet(24, cast[uint32](isr24), 0x08, 0x8e)
  idtSet(25, cast[uint32](isr25), 0x08, 0x8e)
  idtSet(26, cast[uint32](isr26), 0x08, 0x8e)
  idtSet(27, cast[uint32](isr27), 0x08, 0x8e)
  idtSet(28, cast[uint32](isr28), 0x08, 0x8e)
  idtSet(29, cast[uint32](isr29), 0x08, 0x8e)
  idtSet(30, cast[uint32](isr30), 0x08, 0x8e)
  idtSet(31, cast[uint32](isr31), 0x08, 0x8e)

  # IRQs going here

  #irqRemap()

  # Tell the cpu about our idt
  loadIdt()