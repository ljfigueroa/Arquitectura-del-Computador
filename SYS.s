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
  mov $0x80,   %dl  # hhd (usar bootdrive)
  int $0x13
  */


load: 
  mov $0x0800, %ax
  mov %ax, %es
  mov $0, %bx       # 0x10000 (4ceros)
  mov $0x2, %ah
  mov $0x1, %al
  mov $0x1, %cx
  mov $0x80, %dx
  int $0x13
  
  jc disk_error_
  jmp disk_read


disk_error_:
  /*
  mov %ax, %dx
  call print_hex
  call newLine
  */
  
  mov $0, %ax
  mov $0x80, %dl
  int $0x13
  
  jc disk_error_
  jmp load

disk_error:
  /*
  mov $diskerror, %si
  call writeString
  call newLine
  */
  call reboot
  
disk_read:
  /*
  mov $diskok, %si
  call writeString
  call newLine
  */

   
  mov $'L', %al
  call putchar

  jmp mbr_layout

mbr_layout:
  
  push %ds
  push %ds
  
  
  mov $0x0800, %ax
  mov %ax, %es
  mov %ax, %ds

  mov $4, %cx       # 4 particiones a imprimir
mbr_load_stack:  

  pop %ax
  
  xor %di, %di
  mov $478, %di     # offset +0x0 

  /* Status / physical drive  1 byte */

  xor %dx, %dx
  movb (%di), %dh
  push %dx

  /* CHS addres   */
  /* Head    */
  xor %dx, %dx
  movb 1(%di), %dh
  push %dx

  /* Sector in bits 5–0
     Cylinder in bits 7–6 */
  xor %dx, %dx
  movb 2(%di), %dh
  push %dx

  /* Cylinder */
  xor %dx, %dx
  movb 3(%di), %dh
  push %dx

  /* Partition type */
  xor %dx, %dx
  movb 4(%di), %dh
  push %dx


  /* CHS address of last absolute
     sector in partition. */
  /* Head */
  xor %dx, %dx
  movb 5(%di), %dh
  push %dx

  /* Sector in bits 5-0
     Cylinder in bits 7-6 */
  xor %dx, %dx
  movb 6(%di), %dh
  push %dx
  
  /* Cylinder */
  xor %dx, %dx
  movb 7(%di), %dh
  push %dx

  /* LBA of first absolute sector
     in the partition  4 Bytes */

  movw 8(%di), %dx
  push %dx
  movw 10(%di), %dx
  push %dx

  /* LBA number of sectors
     in patition */

  movw 12(%di), %dx
  push %dx
  movw 14(%di), %dx
  push %dx

   
  mov $'D', %al
  call putchar

  
  /*
  #call print_partition_entry
  dec %cx
  cmp $0, %cx
  jz mbr_print_done
  add $16, %di
  jmp mbr_print
  */
mbr_print:
  /*
  mov %ax, %ds
  
  lea mbr_LBA_Sectors, %si
  call writeString

  pop %ax
  mov %ah, %dl
  mov %al, %dh

  pop %ax
  mov %ah, %bl
  mov %al, %bh

  mov $4, %cx
  call print_hex
  mov %bx, %dx
  call print_hex

  /* FIN  */
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
  call putchar
  
  xor %ax, %ax
  int $0x16
  .byte  0xEA             # machine language to jump to FFFF:0000 (reboot)
  .word  0x0000
  .word  0xFFFF

.endfunc

