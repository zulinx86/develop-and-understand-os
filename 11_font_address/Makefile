default:
	make img

boot.img: boot.s
	nasm boot.s -o boot.img -l boot.lst

.PHONY: img
img:
	make boot.img

.PHONY: run
run:
	make img
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c -m 32M

.PHONY: clean
clean:
	rm -f *.img *.lst
