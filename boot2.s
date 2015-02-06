.code16
.text
.org 0x0

.globl _start

_start:
/*
  mov $0x7e00, %ax
  mov %ax, %cs
  mov %ax, %ds
*/  
  mov %dx, (cPos)
  
  cli 
  /* Creando el stack  */
  mov $0x0900, %ax
  mov %ax, %ss
  mov $0x800, %sp    # 4k de stack
  mov %sp, %bp
  sti
/*
  mov $'R', %dl
  mov $0, %di
  mov $0xb800, %ax
  mov %ax, %ds
  

  #xor %di, %di
  mov %dl, (%di)
  inc %di
  movb $0x1e, (%di)

*/
  #mov $0, (cPos)
smbr: 
  lea mbrR, %si
  call writeString
  call newLine
  
  mov $'G', %dl
  call putchar_
  
  mov $'A', %al
  call putchar

  mov (cPos), %al
  call putchar
  
  
  mov $'F', %al
  call putchar

  call get_mbr



  
  /* mov $0xE, %ah 
  mov $7, %bx
  int $0x10
  */

idle:
  hlt
  jmp idle


.include "IO.s"
.include "SYS.s"
  
cPos:
  .int 0x0
bootdrive:
  .int 0x65
/* Mensajes */
rebootmsj:   
  .asciz "Apretar alguna tecla para reiniciar"
mbrR:   
  .asciz "Cargando MBR en memoria"
/* newline: 
  .byte 10, 13, 0
*/
diskerror:
  .asciz "ERROR AL LEER EL DISCO"
diskok:
  .asciz "Cargando MBR en 0x8000"
