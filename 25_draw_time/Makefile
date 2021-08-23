default:
	make img

boot.bin: boot.s
	nasm boot.s -o boot.bin -l boot.lst

kernel.bin: kernel.s
	nasm kernel.s -o kernel.bin -l kernel.lst

boot.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > boot.img

.PHONY: img
img:
	make boot.img

.PHONY: run
run:
	make img
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c -m 64M

.PHONY: clean
clean:
	rm -f *.img *.lst *.bin
