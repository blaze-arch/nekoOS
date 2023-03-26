CC = i686-elf-gcc
ASMC = i686-elf-as
OUTFILE = nekoos.bin

all: build

build:
	@echo "Cleaning nimcache"
	touch ./dummy.o
	rm ./*.o
	rm -rf nimcache
	@echo "Compiling..."
	nim c -d:release --nimcache:nimcache --gcc.exe:i686-elf-gcc main.nim
	${ASMC} boot.s -o boot.o
	nasm -f elf32 cpu/gdt.s -o ./gdt.o
	nasm -f elf32 cpu/idt.s -o ./idt.o
	nasm -f elf32 cpu/isrs.s -o ./isrs.o
	@echo "Linking..."
	${CC} -T linker.ld -o ../${OUTFILE} -ffreestanding -O2 -nostdlib *.o nimcache/*.o -lgcc
clean:
	rm ./*.o
	rm ./nimcache -rf