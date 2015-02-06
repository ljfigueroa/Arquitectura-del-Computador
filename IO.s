.code16
.text
/*  
.func wstring
wstring:
  pusha
wstring_:
#  cld     
  lodsb
  or %al, %al
  jz done
  mov $0xE, %ah 
  mov $7, %bx
  int $0x10
  jmp wstring_
done:
  popa
  ret
.endfunc

.func nl
nl: 
  mov $newline, %si 
  call wstring
  ret
.endfunc
*/
  
.func print_hex
print_hex:
  push %ds
  pusha
 
  push %dx
  mov $'0', %dl
  call putchar_
  mov $'x', %dl
  call putchar_
  pop %dx

loop:
  cmp $0, %cx
  je fin
  dec %cx
  
  mov $0xff00, %ax
  and %dx, %ax
  shr $12, %ax
  shl $4, %dx

  cmp $9, %al
  jbe digit
letter:
  push %ds
  add $55, %al
  mov %al, %dl
  call putchar_
  pop %ds
  jmp loop
digit:
  push %ds
  add $48, %al
  mov %al, %dl
  call putchar_
  pop %ds
  jmp loop

fin:
  popa
  pop %ds
  ret
.endfunc

.func putchar
putchar:
  mov $0xE, %ah 
  mov $7, %bx
  int $0x10
  ret
.endfunc
/*
.func print_
print_:
  pusha
  xor %di, %di
  mov $0xb800, %ax
  mov %ax, %ds
move:
  xor %dx, %dx
  mov %cs:(%si), %dl
  cmp $0, %dl
idle:
  jz print_done
  mov %dl, (%di)
  inc %di
  movb $0x1e, (%di)
  inc %di
  inc %si
  jmp move
print_done:
  popa
  ret
.endfunc
*/
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
  movb $0x1e, (%di)

  /* Preparo la pos para el siguiente
  carater */
  mov %bx, %ds              # restauro ds
  inc %di
  mov %di, (cPos)

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
  
  xor %dx, %dx
  mov (cPos), %ax
  mov $160, %bx
  mov %ax, %cx
  div %bx
  mov $160, %bx
  sub %dx, %bx
  add %bx, %cx
  mov %cx, (cPos)

  
  ret 
.endfunc
