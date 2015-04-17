#!/bin/bash 

sudo dd if=boot.bin  of=floppy.img  bs=512 count=6
sudo qemu-system-i386 -fda floppy.img -hdd hdd.raw -boot order=a
