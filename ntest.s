.code16
.text
.org 0x0                                        
 
.globl main
main:
  jmp _start                 # Saltar al principio del codigo
  nop
 
_start:
  jmp booting
  jmp idleloop



booting:
  mov $bootmsj, %si
  call wstring 
  ret

idleloop:
  hlt
  jmp idleloop

.func wstring
wstring:
#  cld     /* set direction to increment */
  lodsb
  or %al, %al
  jz done
  mov $0xE, %ah 
  mov $7, %bx
  int $0x10
  jmp wstring
done:
  ret
.endfunc

bootmsj:   
  .ascii "____Bootloader cargado____"

.fill (510-(.-main)), 1, 0  # Pad with nulls up to 510 bytes (excl. boot magic)
BootMagic:  .int 0xAA55     # magic word for BIOS
