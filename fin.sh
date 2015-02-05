#!/bin/bash 
as -o ntest.o ntest.s -V
ld -o ntest.out ntest.o -Ttext 0x7c00
objcopy -O binary -j .text ntest.out ntest.bin
/sbin/mkfs.msdos -C floppy.img 1440
sudo dd if=ntest.bin  of=floppy.img  bs=512 count=1
sudo qemu-system-i386 -fda floppy.img -hdd hdd.raw -boot order=a
