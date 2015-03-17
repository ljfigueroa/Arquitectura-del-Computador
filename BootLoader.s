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
  mov $0x800, %sp       # 4k de stack
  mov %sp, %bp
  sti
  
  push %ds
  call screen           # limpio la pantalla
  
  lea BootMsj, %si
  call writeString
  call newLine
  pop %ds

load_to_memory: 

  xor %dx, %dx
  mov $0x07e0, %ax
  mov %ax, %es
  mov $0, %bx         	 # 0x10000 (4ceros)
  mov $0x2, %ah
  mov $0x2, %al          # sectores a leer, el minimo es 1
  mov $0x2, %cx          # empezar del sector 2
  mov (bootdrive), %dl
  int $0x13


  jc disk_reset
  jmp loaded_in_memory

  
disk_reset:
  
  mov $0, %ax
  mov $0x80, %dl
  int $0x13
  
  jc disk_reset
  jmp load_to_memory
  

loaded_in_memory:

  lea BootDrive_leido, %si
  call writeString
  call newLine

 
  mov (cPos), %dx

  jmp 0x7e00        # No regreso mas

.include "IO.s"

/* Variables globales */
cPos:
  .int 0x0
bootdrive:
  .int 0x65
/* Mensajes */
RebootMsj:   
  .asciz "Apretar alguna tecla para reiniciar"
BootMsj:   
  .asciz "Bootloader cargado"
DiskError:
  .asciz "Error al leer el disco"
BootDrive_leido:
  .asciz "Cargando 2da parte en 0x7e00"

.fill (510-(.-_start)), 1, 0  # Pad with nulls up to 510 bytes (excl. boot magic)
Firma:  .int 0xAA55     # magic word for BIOS

