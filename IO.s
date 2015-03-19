.code16
.text

/* Representa un byte como su equivalente hexadecimal,
 * eliminando de existir cero a la izquierda */
.func print_hex
print_hex:
  /* Guardo los valores de los registros */
  push %ds
  pusha

  mov $2, %cx
high_nibble:
  dec %cx
  mov $0x00f0, %ax
  and %dx, %ax
  push %dx
  shr $4, %ax
  cmp $0, %ax
  je low_nibble
  jmp letter_or_digit
low_nibble:  
  cmp $0, %cx
  je print_hex_end
  dec %cx
  mov $0x000f, %ax
  pop %dx
  and %dx, %ax
    
letter_or_digit:  
  cmp $9, %al
  jbe digit
letter:
  push %ds
  add $55, %al
  mov %al, %dl
  call putchar_
  pop %ds
  jmp low_nibble
digit:
  push %ds
  add $48, %al
  mov %al, %dl
  call putchar_
  pop %ds
  jmp low_nibble

print_hex_end:
  popa
  pop %ds
  ret
.endfunc

/* Modulo/Division entera de un numero de 32bits por otro de 16bit
 * donde el resultado de dividir puede ser de 32bits. Dado un numero
 * en %dx:%ax como dividendo y como divisor %bx, el cociente se
 * devuelve en %dx:%ax y el resto en %bx */
.func div32
div32:

  push %ax

  mov %dx, %ax  
  mov $0, %dx   # 0000:dx
  div %bx
  mov %ax, %si  # cociente, futuro dx
  pop %ax       # (resto de la div anteriror):ax
  div %bx        
  mov %dx, %bx  # resto 
  mov %si, %dx  # dx:ax = div

  ret
.endfunc

/* Imprime números en representación decimal */
.func print_num
print_num:
  pusha

  mov $0, %cx
  /* loop1 cumple la función de calcular los ceros izquierda */
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

/* Imprime una cadena asciz utilizando
 mapeo de memoria */
.func writeString
writeString:
  push %ds
  pusha

  xor %di, %di
read_char:
  xor %dx, %dx
  /* Muevo un byte apuntado por %si en el code segment hacia %dl */
  mov %cs:(%si), %dl
  cmp $0, %dl
  /* Las cadenas son asciz terminan con byte null, ie, 0*/
  jz print_string_end
  call putchar_
  inc %si
  jmp read_char
print_string_end:
  popa
  pop %ds
  ret
.endfunc


.func clear_screen
clear_screen:
  push %ds
  pusha
  
  mov $2000, %cx
clear_screen_loop:
  cmp $0, %cx
  jz clear_screen_done
  mov $' ', %dl
  call putchar_
  dec %cx
  jmp clear_screen_loop
clear_screen_done:
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
