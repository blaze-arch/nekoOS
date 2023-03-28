%macro isr_noerrcode 1
  [global isr%1]
  isr%1:
    cli
    push byte 0
    push byte %1
    jmp isr_common_stub
%endmacro

%macro isr_errcode 1
  [global isr%1]
  isr%1:
    cli
    push byte %1
    jmp isr_common_stub
%endmacro 

isr_noerrcode  0 ; Division Error
isr_noerrcode  1 ; Debug
isr_noerrcode  2 ; Non-maskable Interrupt
isr_noerrcode  3 ; Breakpoint
isr_noerrcode  4 ; Overflow
isr_noerrcode  5 ; Bound Range Exceeded
isr_noerrcode  6 ; Invalid Opcode
isr_noerrcode  7 ; Device Not Available
isr_errcode    8 ; Double Fault
isr_noerrcode  9 ; Coprocessor Segment Overrun
isr_errcode   10 ; Invalid TSS
isr_errcode   11 ; Segment Not Present
isr_errcode   12 ; Stack-Segment Fault
isr_errcode   13 ; General Protection Fault
isr_errcode   14 ; Page Fault
isr_noerrcode 15 ; Reserved
isr_noerrcode 16 ; x87 Floating-Point Exception
isr_errcode   17 ; Alignment Check
isr_noerrcode 18 ; Machine Check
isr_noerrcode 19 ; SIMD Floating-Point Exception
isr_noerrcode 20 ; Virtualization Exception
isr_errcode   21 ; Control Protection Exception
isr_noerrcode 22 ; Reserved
isr_noerrcode 23 ; Reserved
isr_noerrcode 24 ; Reserved
isr_noerrcode 25 ; Reserved
isr_noerrcode 26 ; Reserved
isr_noerrcode 27 ; Reserved
isr_noerrcode 28 ; Hypervisor Injection Exception
isr_errcode   29 ; VMM Communication Exception
isr_errcode   30 ; Security Exception
isr_noerrcode 31 ; Reserved

extern isrHandler

isr_common_stub:
    pusha
    push ds
    push es
    push fs
    push gs
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov eax, esp
    push eax
    mov eax, isrHandler
    call eax
    pop eax
    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 8
    iret