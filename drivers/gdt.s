section .text
global loadGdt
loadGdt:
    lgdt [eax]
    ret