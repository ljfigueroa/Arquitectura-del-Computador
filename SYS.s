.code16
.text

.func get_mbr
get_mbr:
  pusha
  /*
  xor %ax,     %ax
  mov %ax,     %es  #es = 0x0000
  mov $0x8000, %bx  # copiar a la dir 0x0000:0x8000
  mov $2,      %cx  # empezar del sector 2
  mov $1,      %al  # sectores a leer, el minimo es 1
  mov $0x2,    %ah  # leer del disco en modo chs
  mov $0x80,   %dl  
  int $0x13
  */

  /*
  lea  test, %si
  call writeString
  call newLine
  */
  
  push %es

load:
  mov $0x0980, %ax  # Donde termina el stack
  mov %ax, %es
  mov $0, %bx       # 0x9800:0000 dir a cargar el mbr
  mov $0x2, %ah     # leer del disco en modo chs
  mov $0x1, %al     # sectores a leer, el minimo es 1
  mov $0x1, %cx     # empezar del sector 2
  mov $0x80, %dx    # hhd (usar bootdrive)
  int $0x13

  jc disk_error_
  jmp disk_read

disk_error_:
    
  mov $0, %ax
  mov $0x80, %dl
  int $0x13
  
  jc disk_error_
  jmp load

disk_error:
  
  mov $diskerror, %si
  call writeString
  call newLine
  
  call reboot
  
disk_read:

  #pop %es

  lea diskread, %si
  call writeString
  call newLine

  
  lea Tabla, %si
  call writeString
  
  
  call newLine
  jmp mbr_layout

mbr_layout:
  
  push %ds
  

  
  mov $0x0980, %ax
  mov %ax, %es
  mov %ax, %ds
  
  mov $4, %cx       # 4 particiones a imprimir

mbr_load_stack:  

  mov $0, %cx
  
  #push %cx
mbr_print:
  mov $446, %di
  /* 446 - 494 */
  #pop %cx
  cmp $4, %cx
  je mbr_print_fin
  push %cx
  mov %cx, %ax
  mov $16,  %bx
  mul %bx
  add %ax, %di
  
  #add $1, %si

  
  #lea (%bx,%di,1), %di
  #mov %ds, %ax
  #pop %ds
  #push %cx
  #push %ds
  #push %ds
  #mov %ax, %ds #*/
testprint:   

  /* Booteable */
  mov $0x980, %ax
  mov %ax, %ds
  mov $0, %ax
  movb 0(%di), %al
  cmp $0x80, %al
  jne notequal

  
  #mov %ds, %bx
  #pop %ds
  #push %ds
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov $'*', %dl
  call putchar_
  #mov %bx, %ds
  pop %ds
  
notequal:

  /* Start */
/*
  mov $0xFFFF, %ax
  mov $0xFFFF, %dx
  mov $10, %bx

  div %bx
*/
  
  /* Formato */
  #pop %ds
  #push %ds
  #push %bx
  push %ds
  mov $0, %ax
  mov %ax, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $12, %ax
  mov %ax, (cPos)
  #pop %bx
  #mov %bx, %ds
  pop %ds
start:
  mov $0x980, %ax
  mov %ax, %ds
  movw 8(%di), %ax
  movw 10(%di), %dx

  #mov $0, %dx
  #mov $100, %ax

  #mov %ds, %bx
  #pop %ds
  push %ds
  mov $0, %bx
  mov %bx, %ds
  call print_num
 
  #mov %bx, %ds
  pop %ds

  /* End */

  /* Formato */
  #pop %ds
  #push %ds
  #push %bx
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $42, %ax
  mov %ax, (cPos)
  #pop %bx
  #mov %bx, %ds
  pop %ds

end:  
  movw 8(%di), %ax
  movw 10(%di), %dx

  #mov $0, %dx
  #mov $100, %ax

  movw 12(%di), %bx
  movw 14(%di), %cx

  add %bx, %ax
  adc %cx, %dx

  dec %ax
  jno no_cero
  dec %dx
no_cero:
  
  #mov %ds, %bx
  #pop %ds
  push %ds
  mov $0, %bx
  mov %bx, %ds
  call print_num
  #mov %bx, %ds
  pop %ds 

  /* Sectors */

  /* Formato */
  #pop %ds
  #push %ds
  #push %bx
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $70, %ax
  mov %ax, (cPos)
  #pop %bx
  #mov %bx, %ds
  pop %ds
  
  movw 12(%di), %ax
  movw 14(%di), %dx
    
  #pop %ds
  #push %ds
  push %ds
  mov $0, %bx
  mov %bx, %ds
  call print_num
  #mov %bx, %ds
  pop %ds
  /* ID */

  /* Formato */
  #pop %ds
  #push %ds
  #push %bx
  push %ds
  mov $0, %bx
  mov %bx, %ds
  mov (cPos), %ax
  mov $0, %dx
  mov $160, %bx
  div %bx
  mov $160, %bx
  mul %bx
  add $100, %ax
  mov %ax, (cPos)
  #pop %bx
  #mov %bx, %ds
  pop %ds
  
  mov $0, %ax
  movb 4(%di), %al
  mov $0, %dx
    
  #pop %ds
  #push %ds
  push %ds
  mov $0, %bx
  mov %bx, %ds
  #call print_num
  #mov %bx, %ds
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



  mov $0, %bx
  mov %bx, %ds
  mov $'D', %dl
  call putchar_

  
  /*
  mov $7, %al
  call putnum_
  */
  
  /*
  #call print_partition_entry
  dec %cx
  cmp $0, %cx
  jz mbr_print_done
  add $16, %di
  jmp mbr_print
  */
mbr_print2:

  
  
  /*
  mov %ax, %ds
  
  lea mbr_LBA_Sectors, %si
  call writeString
  */
  /*
  pop %ax
  mov %ah, %dl
  mov %al, %dh

  pop %ax
  mov %ah, %bl
  mov %al, %bh
  
  pop %ax
  pop %ax
  
  
 
  mov $0, %dx
  call print_num

  mov $'D', %dl
  call putchar_
  
  /*
  mov $4, %cx
  call print_hex
  mov %bx, %dx
  call print_hex

  /* FIN  */

mbr_print_fin:
  
  popa
  ret

.endfunc

.func reboot
reboot:
  /*
  mov $rebootmsj, %si
  call writeString
  */
  mov 'R', %al
#  call putchar
  
  xor %ax, %ax
  int $0x16
  .byte  0xEA             # machine language to jump to FFFF:0000 (reboot)
  .word  0x0000
  .word  0xFFFF

.endfunc

