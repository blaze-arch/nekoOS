global loadGdt     ; Allows the Nim code to call loadGdt().

extern gdt_pointer

loadGdt:
   lgdt [gdt_pointer]        ; Load GDT pointer

   mov ax, 0x10      ; 0x10 is the offset in the GDT to our data segment
   mov ds, ax        ; Load all data segment selectors
   mov es, ax
   mov fs, ax
   mov gs, ax
   mov ss, ax
   jmp 0x08:.flush   ; 0x08 is the offset to our code segment: Far jump!
.flush:
   ret