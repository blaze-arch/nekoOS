type
  interruptDescriptor* = object  ## Interrupt Descriptor object :)
    offset_1*: uint16            ## offset bits 0..15
    selector*: uint16            ## a code segment selector in GDT or LDT
    zero*: uint8                 ## unused, set to 0
    type_attributes*: uint8      ## gate type, dpl, and p fiels
    offset_2*: uint16            ## offset bits 16..31

var idt_arr*: array[256, interruptDescriptor]

var idt_exceptions* = ["Division Error", "Debug", "Non-maskable Interrupt",
                      "Breakpoint", "Overflow", "Bound Range Exceeded", "Invalid Opcode",
                      "Device Not Available", "Double Fault", "Coprocessor Segment Overrun",
                      "Invalid TSS", "Segment Not Present", "Stack-Segment Fault",
                      "General Protection Fault", "Page Fault", "Reserved", 
                      "x87 Floating-Point Exception", "Alignment Check", "Machine Check",
                      "SIMD Floating-Point Exception", "Virtualization Exception",
                      "Control Protection Exception", "Reserved", "Reserved", "Reserved",
                      "Reserved", "Reserved", "Reserved", "Hypervisor Injection Exception",
                      "VMM Communication Exception", "Security Exception", "Reserved"]

const taskGate* = 0b0101            ##  Task Gate, Offset value is unused and should be set to zero. 
const interruptGate16bit* = 0b0110  ##  16-bit Interrupt Gate 
const trapGate16bit* = 0b0111       ##  16-bit Trap Gate 
const intteruptGate32bit* = 0b1110  ##  32-bit Interrupt Gate 
const trapGate32bit* = 0b1111       ##  32-bit Trap Gate 

const cpu_ring0* = 0b00 ## kernel
const cpu_ring1* = 0b01 ## unused
const cpu_ring2* = 0b10 ## unused
const cpu_ring3* = 0b11 ## userspace

proc createSegmentSelector*(index: uint8 = 0, ti: uint8 = 0, ## Create Segment Selector (selector in createInterruptDescriptor())
                          cpu_ring: uint8 = 0): uint16 =
  result = cpu_ring
  result = result + (ti shl 2)
  result = result + (index.uint16 shl 4)

proc createInterruptDescriptor*(address: uint32 = 0, selector: uint16 = 0, ## Create Interrupt Descriptor object ;)
                            gate_type: uint8 = 0, cpu_ring: uint8 = 0): interruptDescriptor = 
  result.offset_1 = address.uint16
  result.offset_2 = (address shr 16).uint16
  result.selector = selector
  result.zero = 0
  result.type_attributes = 0b10000000 # p - must be 1
  result.type_attributes = result.type_attributes + (cpu_ring shl 5)
  result.type_attributes = result.type_attributes + gate_type

proc setIdt*(index: uint, descriptor: interruptDescriptor): int = ## Safe Function for Set Descriptor in IDT
  if (index < 32):
    return -1 # Error
  else:
    idt_arr[index] = descriptor
    return 0  # Success

proc loadIdt*(where: pointer) {.asmNoStackFrame.} = 
  # eax is the arg of where
  asm """
    lidt (%eax)
  """