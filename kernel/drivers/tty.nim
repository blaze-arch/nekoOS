import ../cpu/ports

type
  PVIDMem* = ptr array[0..65_000, TEntry]
  TVGAColor* = enum
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    Yellow = 14,
    White = 15
  TPos* = tuple[x: int, y: int]
  TAttribute* = distinct uint8
  TEntry* = distinct uint16

const
  VGAWidth* = 80
  VGAHeight* = 25

var
  VGABuffer: PVIDMem = nil
  CurrentPosition: TPos = (0, 0)
  CurrentColor: TAttribute
  bg_color: TVGAColor

proc makeColor*(bg: TVGAColor, fg: TVGAColor): TAttribute =
  ## Combines a foreground and background color into a ``TAttribute``.
  bg_color = bg
  return (ord(fg).uint8 or (ord(bg).uint8 shl 4)).TAttribute

proc makeEntry*(c: char, color: TAttribute): TEntry =
  ## Combines a char and a *TAttribute* into a format which can be
  ## directly written to the Video memory.
  let c16 = ord(c).uint16
  let color16 = color.uint16
  return (c16 or (color16 shl 8)).TEntry

proc setColor*(color: TAttribute) =
  CurrentColor = color

proc setPosition*(pos: TPos) =
  CurrentPosition = pos

proc initTTY*(buffer: PVIDMem) =
  VGABuffer = buffer

proc moveCursor() =
  var cursorPos = CurrentPosition.y  * 80 + CurrentPosition.x
  out8(0x3d4, 14)                      # Tell the VGA board we are setting the high cursor byte.
  out8(0x3d5, (cursorPos shr 8).uint8) # Send the high cursor byte.
  out8(0x3d4, 15)                      # Tell the VGA board we are setting the low cursor byte.
  out8(0x3D5, cursorPos.uint8)         # Send the low cursor byte.

proc scroll() =
   if CurrentPosition.y >= 25: # Row 25 is the end, this means we need to scroll up
    # Move the current text chunk that makes up the screen
    # back in the buffer by a line
    var i = 80
    while i < 24 * 80:
      VGABuffer[i] = VGABuffer[i + 80]
      inc(i)

    # The last line should now be blank. Do this by writing 80 spaces to it.
    i = 24 * 80
    while i < 25 * 80:
      VGABuffer[i] = makeEntry(' ', CurrentColor)
      inc(i)
    # The cursor should now be on the last line.
    CurrentPosition.y = 24

proc putChar*(c: char) = # Writes a single character out to the screen.
  if c == '\b' and CurrentPosition.x > 1: # Handle a backspace, by moving the cursor back one space
    dec(CurrentPosition.x)
  elif c.uint8 == 0x09: # tab
       CurrentPosition.x = (CurrentPosition.x + 8) and not 7
  elif c == '\r':
    CurrentPosition.x = 0
  elif c == '\n': # Handle newline by moving cursor back to left and increasing the row
    CurrentPosition.x = 0
    inc CurrentPosition.y

  elif (c.uint8) >= (' '.uint8): # Handle any other printable character.
    VGABuffer[CurrentPosition.y * 80 + CurrentPosition.x] = makeEntry(c, CurrentColor)
    inc CurrentPosition.x

  # Check if we need to insert a new line because we have reached the end
  # of the screen.
  if CurrentPosition.x >= 80:
    CurrentPosition.x = 0
    inc CurrentPosition.y

  scroll() # Scroll the screen if needed.
  move_cursor() # Move the hardware cursor.

proc screenClear*() =
  var i = 0
  let color = makeColor(bg_color, bg_color)
  let space = makeEntry(' ', color)
  while i <= 80 * 25:
    VGABuffer[i] = space
    inc(i)

proc screenClear*(color: TVGAColor) =
  let attr = makeColor(color, color)
  let space = makeEntry(' ', attr)
  var i = 0
  while i <= 80 * 25:
    VGABuffer[i] = space
    inc(i)

proc writeString*(s: string) =
  for c in s:
    putChar(c)

proc write*(s: string) =
  writeString(s)

proc writeLn*(s: string) =
  writeString(s & "\n")