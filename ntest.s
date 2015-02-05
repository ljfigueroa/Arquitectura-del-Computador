.code16
.text
.org 0x0
 
.globl _start

_start:
  
  cli
  /* Guardo el disco de arranque */
  mov %dl, (bootdrive)

  /* Creando el stack  */
  mov $0x0900, %ax
  mov %ax, %ss
  mov $0x800, %sp    # 4k de stack
  mov %sp, %bp
  sti

  
  call screen

  /* Se cargo de manera exitosa */
  /*  TEST
  mov $bootmsj, %si
  call wstring 
  
  TEST 

  mov $'A', %dl
  call putchar_

  mov $'B', %dl
  call putchar_

    mov $'A', %dl
  call putchar_

  mov $'B', %dl
  call putchar_

  call newLine
  
  mov $'C', %dl
  call putchar_

  call newLine
  
  lea bootmsj, %si
  call writeString
  call newLine
  call newLine
 */
  lea bootmsj, %si
  call writeString
  call newLine
 /*
  call newLine
  call newLine

  mov $0xFFED, %dx
  mov $4, %cx
  call print_hex
  call newLine*/

  call get_mbr


idleloop:
  hlt
  jmp idleloop



.include "IO.s"
.include "SYS.s"

/* Variables globales */
cPos:
  .int 0x0
bootdrive:
  .int 0x65
/* Mensajes */
mbr_LBA_Sectors:
  .asciz "LBA Sectors "
rebootmsj:   
  .asciz "Apretar alguna tecla para reiniciar"
bootmsj:   
  .asciz "Bootloader cargado"
/* newline: 
  .byte 10, 13, 0
*/
diskerror:
  .asciz "ERROR AL LEER EL DISCO"
diskok:
  .asciz "Master Boot Record cargado"

.fill (510-(.-_start)), 1, 0  # Pad with nulls up to 510 bytes (excl. boot magic)
BootMagic:  .int 0xAA55     # magic word for BIOS
