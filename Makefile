.PHONY:build image clean

obj=mbr.bin

build:
	nasm mbr.S -o $(obj)

image:
	dd if=./mbr.bin of=./hd60M.img bs=512 count=1  conv=notrunc

clean:
	rm -rf *.img $(obj)
