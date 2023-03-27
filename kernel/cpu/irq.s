%macro irqSet 2
  global irq%1
  irq%1:
    cli
    push byte 0
    push byte %2
    jmp irq_common_stub
%endmacro

irqSet 0, 32
irqSet 1, 33
irqSet 2, 34
irqSet 3, 35
irqSet 4, 36
irqSet 5, 37
irqSet 6, 38
irqSet 7, 39
irqSet 8, 40
irqSet 9, 41
irqSet 10, 42
irqSet 11, 43
irqSet 12, 44
irqSet 13, 45
irqSet 14, 46
irqSet 15, 47

[extern irqHandler]

irq_common_stub:
   pusha                    ; Pushes edi,esi,ebp,esp,ebx,edx,ecx,eax

   mov ax, ds               ; Lower 16-bits of eax = ds.
   push eax                 ; save the data segment descriptor

   mov ax, 0x10             ; load the kernel data segment descriptor
   mov ds, ax
   mov es, ax
   mov fs, ax
   mov gs, ax

   call irqHandler

   pop ebx                  ; reload the original data segment descriptor
   mov ds, bx
   mov es, bx
   mov fs, bx
   mov gs, bx

   popa                     ; Pops edi,esi,ebp...
   add esp, 8               ; Cleans up the pushed error code and pushed ISR number
   sti
   iret                     ; pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP