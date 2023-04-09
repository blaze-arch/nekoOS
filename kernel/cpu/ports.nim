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

{.push stackTrace:off.}

proc cpu_relax*(): void =
    asm "rep; nop"

proc out8*(port: uint16, data: uint8): void =
    asm """
        outb %0, %1
        :
        : "a" (`data`),
          "d" (`port`)
    """

proc in8*(port: uint16): uint8 =
    asm """
        inb %1, %0
        : "=a" (`result`)
        : "d"  (`port`)
    """

proc out16*(port: uint16, data: uint16): void =
    asm """
        outw %0, %1
        :
        : "a"  (`data`),
          "dN" (`port`)
    """

proc in16*(port: uint16): uint16 =
    asm """
        inw %1, %0
        : "=a" (`result`)
        : "dN" (`port`)
    """

proc out32*(port: uint16, data: uint32): void =
    asm """
        outl %0, %1
        :
        : "a"  (`data`),
          "dN" (`port`)
    """

proc in32*(port: uint32): uint32 =
    asm """
        inl %1, %0
        : "=a" (`result`)
        : "dN" (`port`)
    """

proc io_delay*(): void =
    const DELAY_PORT = 0x80
    asm """
        outb %%al,%0
        :
        : "dN" (`DELAY_PORT`)
    """

{.pop.}