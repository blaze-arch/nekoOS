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

proc abort*(): void {.exportc.} =
    # TODO: Send SIGABRT
    return;

proc memmove*(dst: ptr, src: ptr, size: csize_t): ptr {.exportc.} =
    if dst < src:
        for i in 0..size:
            dst[i] = src[i]
    else:
        for i in size..0:
            dst[i-1] = src[i-1]
    return dst

proc strlen*(str: cstring): csize_t {.exportc.} =
    var size: csize_t = 0
    for ch in str:
        size += 1
    return size

proc memcmp*(aptr: ptr, bptr: ptr, size: csize_t): cint {.exportc.} =
    for i in 0..size:
        if aptr[i] < bptr[i]:
            return -1
        elif bptr[i] < aptr[i]:
            return 1
    return 0;

proc memset*(bufptr: ptr, value: cint, size: csize_t): ptr {.exportc.} =
    for i in 0..size:
        bufptr[i] = value
    return bufptr

proc memcpy*(dstptr: ptr, srcptr: ptr, size: csize_t): ptr {.exportc.} =
    for i in 0..size:
        dstptr[i] = srcptr[i]
    return dstptr;
