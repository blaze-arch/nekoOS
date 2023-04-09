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

var
  mem {.noinit.}: array[256000, byte]
  pos: csize_t

proc malloc(size: csize_t): pointer {.exportc: "malloc".} =
  result = cast[pointer](addr mem[pos])
  inc(pos, cast[int](size))

proc free(p: pointer) {.exportc: "free".} =
  discard

proc realloc(p: pointer, size: csize_t): pointer {.exportc: "realloc".} =
  result = malloc(size)

proc calloc(nitems, size: csize_t): pointer {.exportc: "calloc".} =
  result = malloc(nitems * size)
  for i in 0 ..< nitems * size:
    mem[pos + i] = 0

# TODO: find a way to make nim not emit exit?
proc exit(status: cint) {.exportc: "exit".} =
  discard