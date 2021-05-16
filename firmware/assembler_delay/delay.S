#-- delay.asm
		.globl delay_cycles
		.text
		
main:		li a0,10
		jal delay_cycles
		
end:		j end
		
delay_cycles:	
		addi sp,sp,-4
		sw ra, 0(sp)
		
loop:		beq a0,zero,end_loop
		addi a0,a0,-1
		j loop
						
end_loop:							
		lw ra,0(sp)																		
		addi sp,sp,4
		ret
		
		
		
		
	
	

