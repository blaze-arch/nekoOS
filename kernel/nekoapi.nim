import drivers/tty

type
  registers* = object
    # Segment Selectors
    gs*, fs*, es*, ds*: uint32

    # Extended Registers
    edi*, esi*, ebp*, esp*, ebx*, edx*, ecx*, eax*: uint32

    # Pushed By push byte
    int_no*, err_code*: uint32

    # Pushed By iret
    eip*, cs*, eflags*, useresp*, ss*: uint32

proc debugRegs*(regs: registers) =
  write("gs: ")
  write($regs.gs)
  write(" fs: ")
  write($regs.fs)
  write(" es: ")
  write($regs.es)
  write(" ds: ")
  writeLn($regs.ds)
  write("edi: ")
  write($regs.edi)
  write(" esi: ")
  write($regs.esi)
  write(" ebp: ")
  write($regs.ebp)
  write(" esp: ")
  write($regs.esp)
  write(" ebx: ")
  write($regs.ebx)
  write(" edx: ")
  write($regs.edx)
  write(" ecx: ")
  write($regs.ecx)
  write(" eax: ")
  writeLn($regs.eax)

proc panic*(message: string, regs: registers) =
  setPosition(0, 0)
  screenClear(Red)
  setColor(makeColor(Red, White))
  writeString("Kernel panic! Sorry :(\n")
  writeString("nya! :c\nThere are problem on your computer!\nYou need to restart your PC! :(\n")
  debugRegs(regs)
  write("panic message: ")
  write(message)
  while true:
    discard

proc panic*(message: string) =
  setPosition(0, 0)
  screenClear(Red)
  setColor(Red, White)
  writeString("Kernel panic! Sorry :(\n")
  writeString("nya! :c\nThere are problem on your computer!\nYou need to restart your PC! :(\n")
  writeString("panic message: ")
  write(message)
  while true:
    discard