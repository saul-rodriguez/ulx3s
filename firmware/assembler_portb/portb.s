	.include "../common/vargen_inc.s"

	.equ DEL, 0x000000f

	.text
	li t0, PORTB
	li t1, PORTA
	
m_loop:	lw t2,0(t0)
	sw t2,0(t1)
	jal delay
	j m_loop

delay:	li t3, DEL

l1:	addi t3,t3,-1
	bgt t3,x0,l1
	ret
end:	j end
	
	
	

