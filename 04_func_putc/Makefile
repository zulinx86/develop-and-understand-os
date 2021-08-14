default:
	make img

boot.img:
	nasm boot.s -o boot.img -l boot.lst

img:
	make -r boot.img

run:
	make img
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c -m 32M

clean:
	rm -f *.img *.lst
