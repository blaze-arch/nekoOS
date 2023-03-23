all: build
build:
	@echo "Compiling..."
	nim c -d:release --nimcache:nimcache --gcc.exe:i686-elf-gcc main.nim
	i686-elf-as boot.s -o boot.o
	nasm ./drivers/gdt.s -f elf32 -o ./gdt.o
	@echo "Linking..."
	i686-elf-gcc -T linker.ld -o main.bin -ffreestanding -O2 -nostdlib boot.o gdt.o nimcache/*.o -lgcc
run:
	qemu-system-i386 -kernel main.bin
clean:
	rm ./*.o
	rm ./nimcache -rf
	rm ./main.bin
