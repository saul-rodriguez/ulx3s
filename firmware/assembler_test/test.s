#lui	x5,0xfffffff0
	.text
start:
	lui	x5,0xfffff
	addi	x5,x5,0x00000010
	addi	x6,x0,0x000000ff
	sw	x6,0x00000000(x5)
bucle:	
	sw x6, 0(x5)
	addi x6, x6, 1	
	addi x5, x5, 4	
	j bucle
stop:
	j stop


