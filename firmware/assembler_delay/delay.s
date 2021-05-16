# 1 "delay.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 32 "<command-line>" 2
# 1 "delay.S"
#-- delay.asm
  .globl delay_cycles
  .text

main: li a0,10
  jal delay_cycles

end: j end

delay_cycles:
  addi sp,sp,-4
  sw ra, 0(sp)

loop: beq a0,zero,end_loop
  addi a0,a0,-1
  j loop

end_loop:
  lw ra,0(sp)
  addi sp,sp,4
  ret
