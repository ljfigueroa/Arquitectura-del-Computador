.code16
.text

.func get_mbr
get_mbr:
  pusha

  /* Cargo el MBR en memoria */
load_MBR:
  mov $0x0980, %ax  # Donde termina el stack
  mov %ax, %es
  mov $0, %bx       # 0x9800:0000 dir a cargar el mbr
  mov $0x2, %ah     # leer del disco en modo chs
  mov $0x1, %al     # sectores a leer, el minimo es 1
  mov $0x1, %cx     # empezar del sector 2
  mov $0x80, %dx    # hhd (usar bootdrive)
  int $0x13

  jc disk_error
  jmp disk_read

disk_error:
  xor %cx, %cx
disk_error_:
  cmp $3, %cx
  je disk_unreadable
  inc %cx
  
  mov $0, %ax
  mov $0x80, %dl
  int $0x13
  
  jc disk_error_
  jmp load_MBR

disk_unreadable:
  
  mov $diskerror, %si
  call writeString
  call newLine
  
  call reboot

disk_read:
  
  call newLine
    
  lea Tabla, %si
  call writeString
    
  call newLine
  jmp mbr_layout

mbr_layout:
  
  push %ds
    
  mov $0x0980, %ax
  #mov %ax, %es
  mov %ax, %ds
  
  mov $4, %cx       # 4 particiones a imprimir

mbr_load_stack:  

  mov $0, %cx
  
mbr_print:
  /* 446 - 494 */
  mov $446, %di
  
  cmp $4, %cx
  je mbr_print_fin
  push %cx
  mov %cx, %ax
  mov $16,  %bx
  mul %bx
  add %ax, %di
  
testprint:   
  
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov %cx, %ax
  inc %ax
  mov $0, %dx
  call print_num
  pop %ds

  /* Formato */
  push %ds
  mov $0, %ax
  mov %ax, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $14, %ax
  mov %ax, (cPos)
  #pop %bx
  #mov %bx, %ds
  pop %ds
  
  /* Booteable */
  mov $0x980, %ax
  mov %ax, %ds
  mov $0, %ax
  movb 0(%di), %al
  cmp $0x80, %al
  jne not_bootable

  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov $'B', %dl
  call putchar_
  pop %ds
  jmp end_boot
  
not_bootable:
  mov $0x980, %ax
  mov %ax, %ds
  mov $0, %ax
  movb 0(%di), %al
  cmp $0, %al
  je inactive

  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov $'-', %dl
  call putchar_
  call newLine
  pop %ds
  jmp fin_linea
  
inactive: 
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov $'I', %dl
  call putchar_
  pop %ds
end_boot: 
  
  


  /* Start */
  
  /* Formato */
  push %ds
  mov $0, %ax
  mov %ax, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $26, %ax
  mov %ax, (cPos)
  #pop %bx
  #mov %bx, %ds
  pop %ds
start:
  mov $0x980, %ax
  mov %ax, %ds
  movw 8(%di), %ax
  movw 10(%di), %dx

  push %ds
  mov $0, %bx
  mov %bx, %ds
  call print_num
  pop %ds

  /* End */

  /* Formato */
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $56, %ax
  mov %ax, (cPos)
  pop %ds

end:  
  movw 8(%di), %ax
  movw 10(%di), %dx

  movw 12(%di), %bx
  movw 14(%di), %cx

  add %bx, %ax
  adc %cx, %dx

  dec %ax
  jno no_cero
  dec %dx
no_cero:
  
  push %ds
  mov $0, %bx
  mov %bx, %ds
  call print_num
  pop %ds 

  /* Sectors */

  /* Formato */
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $84, %ax
  mov %ax, (cPos)
  pop %ds
  
  movw 12(%di), %ax
  movw 14(%di), %dx
    
  push %ds
  mov $0, %bx
  mov %bx, %ds
  call print_num
  pop %ds

  /* Tamaño */

  /* Formato */
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $114, %ax
  mov %ax, (cPos)
  pop %ds

  push %cx
  movw 12(%di), %ax
  movw 14(%di), %dx
  mov $2048, %bx
  call div32
  mov $'M', %si
  push %si
  cmp $1000, %ax  
  jbe megabytes
  pop %bx
  mov $1024, %bx
  call div32
  mov $'G', %si
  push %si
megabytes:
  push %ds
  mov $0, %bx
  mov %bx, %ds
  call print_num
  pop %ds

  pop %dx

  push %ds
  mov $0, %bx
  mov %bx, %ds
  call putchar_
  pop %ds

  pop %cx
  
  
  /* ID */

  /* Formato */
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $128, %ax
  mov %ax, (cPos)
  pop %ds
  
  mov $0, %ax
  movb 4(%di), %al
  mov $0, %dx
    
  push %ds
  mov $0, %bx
  mov %bx, %ds
testss: 
  push %cx
  mov $2, %cx
  mov %ax, %dx
  call print_hex
  pop %cx

  call newLine
  pop %ds

fin_linea:

  
  pop %cx
  inc %cx
  jmp mbr_print

  
mbr_print_fin:
  
  popa
  ret

.endfunc

.func reboot
reboot:
 
  mov $rebootmsj, %si
  call writeString
 
  
  xor %ax, %ax
  int $0x16
  .byte  0xEA             # machine language to jump to FFFF:0000 (reboot)
  .word  0x0000
  .word  0xFFFF

.endfunc

