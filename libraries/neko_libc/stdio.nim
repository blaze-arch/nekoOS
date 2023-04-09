#[

    nekoLibc
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

const
    EOF = '\0'
    INT_MAX = 2147483647

proc putchar(c: char): char {.exportc.} =
    # TODO: Implement STDIO and write the system call
    return c

proc print*(data: cstring, length: csize_t): bool {.exportc.} =
    for i in 0..length:
        if putchar(data[i]) == EOF:
            return false
    return true

proc printf*[T](fmt: cstring, args: varargs[T]): cint {.exportc.} =
    var format = $fmt
    var i = 0
    var written: cint = 0
    # var parsed = 0

    while i < format.len:
        var max_rem = INT_MAX - written

        if format[0] != '%' or format[1] == '%':
            if format[0] == '%':
                i += 1
            
            var amount: cint = 1
            while (amount < format.len) and (format[amount] != '%'):
                i += 1
            
            if max_rem < amount:
                # TODO: Set errno to EOVERFLOW.
                return -1
            
            if not print(format.substr(i, amount), csize_t(amount)):
                return -1
            
            i += amount
            written += amount
            continue

        if not print(format.substr(i, 1), 1):
            return -1

        i += 1
        written += 1
    return written


            
proc puts*(str: cstring): cint {.exportc.} =
    return printf("%s\n", str)