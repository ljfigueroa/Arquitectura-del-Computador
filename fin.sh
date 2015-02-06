#!/bin/bash 
as -o ntest.o ntest.s -V
ld -o ntest.out ntest.o -Ttext 0x7c00
objcopy -O binary -j .text ntest.out ntest.bin

as -o boot2.o boot2.s
ld -o boot2.out boot2.o -Ttext 0x7e00
objcopy -O binary -j .text boot2.out boot2.bin

cat ntest.bin boot2.bin > boot.bin


sudo dd if=boot.bin  of=floppy.img  bs=512 count=3
sudo qemu-system-i386 -fda floppy.img -hdd hdd.raw -boot order=a
