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
  mov $0x800, %sp        # 4k de stack
  mov %sp, %bp
  sti
  

  call clear_screen            # limpio la pantalla
  
  lea BootMsj, %si
  call writeString
  call newLine


  /* Cargamos la segunda parte en memoria */
load_to_memory: 

  xor %dx, %dx
  mov $0x07e0, %ax
  mov %ax, %es           
  mov $0, %bx         	 # cargamos en 0x7e00:0000
  mov $0x2, %ah          # leer el disco en modo chs
  mov $0x2, %al          # sectores a leer, el minimo es 1
  mov $0x2, %cx          # empezar del sector 2
  mov (bootdrive), %dl   # leer del disco de donde arranque 
  int $0x13

  jc disk_reset
  jmp loaded_in_memory


  /* Resetamos el HDD */
disk_reset:
  xor %cx, %cx
disk_reset_:
  cmp $3, %cx
  je system_reboot
  inc %cx
  
  lea DiskError, %si
  call writeString
  call newLine
  
  mov $0, %ax           # Subfuncion para el reseteo de discos
  mov $0x80, %dl        # disco a resetear, 0x80 es la representacion del HDD
  int $0x13
  
  jc disk_reset_
  jmp load_to_memory

system_reboot:
  call reboot

  /* Disco leido exitosamente */ 
loaded_in_memory:
 
  #lea BootDrive_leido, %si
  #call writeString
  #call newLine

  /* Salvo la posicion del cursor */
  mov (cPos), %dx

  /* Saltamos donde cargamos la segunda parte */
  jmp 0x7e00            # No regreso mas

.func reboot
reboot:
  mov $RebootMsj, %si
  call writeString
  
  xor %ax, %ax
  int $0x16
  .byte  0xEA             # machine language to jump to FFFF:0000 (reboot)
  .word  0x0000
  .word  0xFFFF
.endfunc
  
.include "IO.s"

  /* Variables globales */

  /* cPos guarda la posición del cursor en la pantalla*/
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
  .asciz "2da parte cargada en 0x7e00"

.fill (510-(.-_start)), 1, 0  # Rellena con ceros hasta los 510 bytes
Firma:  .int 0xAA55           # Firma para que la BIOS reconozca que
                              # es un bootloader 

