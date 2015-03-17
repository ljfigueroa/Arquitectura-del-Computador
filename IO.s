.code16
.text
  
.func print_hex
print_hex:
  push %ds
  pusha

  mov $2, %cx
fst:
  dec %cx
  mov $0x00f0, %ax
  and %dx, %ax
  push %dx
  shr $4, %ax
  cmp $0, %ax
  je snd
  jmp des
snd:  
  cmp $0, %cx
  je fin
  dec %cx
  mov $0x000f, %ax
  pop %dx
  and %dx, %ax
    
des:  
  cmp $9, %al
  jbe digit
letter:
  push %ds
  add $55, %al
  mov %al, %dl
  call putchar_
  pop %ds
  jmp snd
digit:
  push %ds
  add $48, %al
  mov %al, %dl
  call putchar_
  pop %ds
  jmp snd

fin:
  popa
  pop %ds
  ret
.endfunc

.func div32
div32:
  push %ax

  /* */
  mov %dx, %ax  
  mov $0, %dx   # 0000:dx
  div %bx
  mov %ax, %si  # dx:
  pop %ax       # mod:ax
  div %bx        
  mov %dx, %bx  # resto
  mov %si, %dx  # dx:ax = div

  ret
.endfunc


.func print_num
print_num:
  pusha

  mov $0, %cx
loop1:
  cmp $0, %dx
  je loop2
  inc %cx
  mov $10, %bx
  call div32
  push %bx
  jmp loop1

loop2:
  cmp $0, %ax
  je print_loop
  inc %cx
  mov $10, %bx
  call div32
  push %bx
  jmp loop2
  
print_loop:
  cmp $0, %cx
  je print_end
  dec %cx
  pop %dx
  add $'0', %dx
  call putchar_
  jmp print_loop

print_end:  

  popa
  ret
.endfunc

.func putchar_
putchar_:
  
  pusha
  mov %ds, %bx          # salvo ds

  /* Calculo la pos */ 
  mov (cPos), %di

  mov $0xb800, %ax
  mov %ax, %ds
  
  /* Imprimo */
  #xor %di, %di
  mov %dl, (%di)
  inc %di
  movb $0x70, (%di)     # 0x1e 

 
  
  /* Preparo la pos para el siguiente
  carater */
  mov %bx, %ds              # restauro ds
  inc %di
  mov %di, (cPos)

/* #Posicion del cursor 
  mov $0x3, %ah
  mov $0, %al
  int $0x10

*/
  popa
  ret
.endfunc

.func writeString
writeString:
  push %ds
  pusha

  xor %di, %di
move_:
  xor %dx, %dx
  mov %cs:(%si), %dl
  cmp $0, %dl

  jz print_string_done
  call putchar_
  inc %si
  jmp move_
print_string_done:
  popa
  pop %ds
  ret
.endfunc

.func screen
screen:
  push %ds
  pusha
  
  mov $2000, %cx
loop_:
  cmp $0, %cx
  jz screen_done
  mov $' ', %dl
  call putchar_
  dec %cx
  jmp loop_
screen_done:
  mov $0, %ax
  mov %ax, (cPos)
  
  popa
  pop %ds
  ret
.endfunc
  
.func newLine
newLine:
  pusha
  
  xor %dx, %dx
  mov (cPos), %ax
  mov $160, %bx
  mov %ax, %cx
  div %bx
  mov $160, %bx
  sub %dx, %bx
  add %bx, %cx
  mov %cx, (cPos)

  popa
  ret 
.endfunc
