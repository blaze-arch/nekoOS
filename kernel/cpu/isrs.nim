import ../nekoapi
import ../drivers/tty

var exceptions* = ["Division Error", "Debug", "Non-maskable Interrupt",
                      "Breakpoint", "Overflow", "Bound Range Exceeded", "Invalid Opcode",
                      "Device Not Available", "Double Fault", "Coprocessor Segment Overrun",
                      "Invalid TSS", "Segment Not Present", "Stack-Segment Fault",
                      "General Protection Fault", "Page Fault", "Reserved", 
                      "x87 Floating-Point Exception", "Alignment Check", "Machine Check",
                      "SIMD Floating-Point Exception", "Virtualization Exception",
                      "Control Protection Exception", "Reserved", "Reserved", "Reserved",
                      "Reserved", "Reserved", "Reserved", "Hypervisor Injection Exception",
                      "VMM Communication Exception", "Security Exception", "Reserved"]


proc isr0*() {.importc.}
proc isr1*() {.importc.}
proc isr2*() {.importc.}
proc isr3*() {.importc.}
proc isr4*() {.importc.}
proc isr5*() {.importc.}
proc isr6*() {.importc.}
proc isr7*() {.importc.}
proc isr8*() {.importc.}
proc isr9*() {.importc.}
proc isr10*() {.importc.}
proc isr11*() {.importc.}
proc isr12*() {.importc.}
proc isr13*() {.importc.}
proc isr14*() {.importc.}
proc isr15*() {.importc.}
proc isr16*() {.importc.}
proc isr17*() {.importc.}
proc isr18*() {.importc.}
proc isr19*() {.importc.}
proc isr20*() {.importc.}
proc isr21*() {.importc.}
proc isr22*() {.importc.}
proc isr23*() {.importc.}
proc isr24*() {.importc.}
proc isr25*() {.importc.}
proc isr26*() {.importc.}
proc isr27*() {.importc.}
proc isr28*() {.importc.}
proc isr29*() {.importc.}
proc isr30*() {.importc.}
proc isr31*() {.importc.}

proc isr_handler(regs: registers) {.exportc.} =
  if regs.int_no < 32:
    panic(exceptions[regs.int_no], regs)
  writeString("recieved interrupt: " & $regs.int_no & "\n")