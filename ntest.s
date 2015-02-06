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
  
  push %ds
  call screen
  
  lea bootmsj, %si
  call writeString
  call newLine
  pop %ds

  /*
  call newLine
  mov $'A', %dl
  call putchar_
  
  mov %ds, %dx
  mov $4, %cx
  call print_hex

  mov $'B', %dl
  call putchar_
  call newLine
  */
 

load2: 

  xor %dx, %dx
  mov $0x07e0, %ax
  mov %ax, %es
  mov $0, %bx         	 # 0x10000 (4ceros)
  mov $0x2, %ah
  mov $0x2, %al          # sectores a leer, el minimo es 1
  mov $0x2, %cx          # empezar del sector 2
  mov (bootdrive), %dl
  int $0x13


  jc disk_error_2
  jmp disk_read2

  
disk_error_2:
  
  mov $0, %ax
  mov $0x80, %dl
  int $0x13
  
  jc disk_error_2
  jmp load2
  

disk_read2:

  lea BootDrive_leido, %si
  call writeString
  call newLine

  /*  
  mov $0x0003, %ax
  mov %ax, %ds
  mov %ax, %es

  push %es
  push %cs
  push %ds

  /*
  mov $66, %dl
  call putchar_
  */
  mov $'X', %dl
  call putchar_
  call newLine

  
  mov (cPos), %al
  call putchar
  
  mov $'K', %al
  mov $0xE, %ah 
  mov $7, %bx
  int $0x10

  mov (cPos), %dx

  
  jmp 0x7e00        # No regreso mas


.include "IO.s"


/* Variables globales */
cPos:
  .int 0x0
bootdrive:
  .int 0x65
/* Mensajes */
rebootmsj:   
  .asciz "Apretar alguna tecla para reiniciar"
bootmsj:   
  .asciz "Bootloader cargado"
/* newline: 
  .byte 10, 13, 0
*/
diskerror:
  .asciz "ERROR AL LEER EL DISCO"
BootDrive_leido:
  .asciz "Cargando 2da parte en 0x7e00"

.fill (510-(.-_start)), 1, 0  # Pad with nulls up to 510 bytes (excl. boot magic)
BootMagic:  .int 0xAA55     # magic word for BIOS

