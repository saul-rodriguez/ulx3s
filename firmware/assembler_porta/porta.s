	.include "../common/vargen_inc.s"

#	.equ PORTA, 0x00100000
#	.equ DEL, 0x00000005
	.equ DEL, 0x0003d090
	
	.text

	#initialization	
main:	li x5, PORTA
		li x7, 0x0f
		sw x7, 0(x5)

	#do while 


/*
m_loop:	jal delay
		li x6,0xa5
		sw x6, 0(x5)
		jal delay
		li x6,0x00
		sw x6, 0(x5)
		j m_loop
*/

m_loop:	jal delay
		addi x7,x7,1
		sw x7, 0(x5)
		j m_loop
	
delay:
		li x6, DEL
	
l1:		addi x6,x6,-1
		bgt x6,x0,l1
		ret
	  
end:	j end
	
	


