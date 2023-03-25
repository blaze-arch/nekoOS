import ports

proc read*(index: uint8): uint8 =
    out8(0x70, index)
    return in8(0x71)

proc write*(index: uint8, data: uint8): void =
    out8(0x70, index)
    out8(0x71, data)