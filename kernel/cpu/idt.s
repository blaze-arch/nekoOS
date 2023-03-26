global loadIdt

extern idt_pointer

loadIdt:
    lidt [idt_pointer]
    ret