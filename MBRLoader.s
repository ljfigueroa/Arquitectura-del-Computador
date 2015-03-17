.code16
.text
.org 0x0

.globl _start

_start:
  mov %dx, (cPos)
  
  cli 
  /* Creando el stack  */
  mov $0x0900, %ax
  mov %ax, %ss
  mov $0x800, %sp    # 4k de stack
  mov %sp, %bp
  sti

  
smbr:

  mov $0, %ax
  
  mov $boot2, %si
  call writeString
  call newLine

  call get_mbr

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
boot2:   
  .asciz "Segunda parte cargada en memoria"
rebootmsj:   
  .asciz "Apretar alguna tecla para reiniciar"
diskerror:
  .asciz "ERROR AL LEER EL DISCO"
diskok:
  .asciz "Cargando MBR en 0x8000"
diskread:
  .asciz "Disco leido"
Tabla:
  .asciz "Boot  Start          End           Sectors          Size Id"
