objects = BootLoader.bin BootLoader.out BootLoader.o \
					MBRLoader.bin MBRLoader.out MBRLoader.o

boot.bin: BootLoader.bin MBRLoader.bin
	dd if=BootLoader.bin of=BootLoader_.bin bs=512 count=1
	cat BootLoader_.bin MBRLoader.bin > boot.bin

BootLoader.bin: BootLoader.s IO.s
	as -o BootLoader.o BootLoader.s
	ld -o BootLoader.out BootLoader.o -Ttext 0x7c00
	objcopy -O binary -j .text BootLoader.out BootLoader.bin

MBRLoader.bin: MBRLoader.s IO.s SYS.s
	as -o MBRLoader.o BootLoader.s
	ld -o MBRLoader.out MBRLoader.o -Ttext 0x7e00
	objcopy -O binary -j .text MBRLoader.out MBRLoader.bin


.PHONY : clean
clean:
	-rm boot.bin $(objects)
