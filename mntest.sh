#!/bin/bash 
as -o ntest.o ntest.s
ld -o ntest.out ntest.o -Ttext 0x7c00
objcopy -O binary -j .text ntest.out ntest.bin

