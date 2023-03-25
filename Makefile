all: clean build_kernel

build_world:
	@echo "Indev! :("

build_libc:
	@echo "Indeeev!!! :("

build_kernel:
	@echo "Building kernel! ^w^"
	@make -C kernel

clean:
	@echo "Cleaning! ^w^"
	@make -C kernel clean
	@rm ./nekoos.bin

run:
	@echo "Running kernel in QEMU! :3"
	qemu-system-i386 -kernel nekoos.bin