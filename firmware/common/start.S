//start.S

#include "custom_ops.S"

			.section .data
			.balign 4

flag_isr:	.byte	0  //this flag is used as workaround to avoid isr re-entry

			.section .text
			.global irq
	
reset_vec:
			picorv32_maskirq_insn(zero, zero)	//activate interrups
			j start
			

		   /*
		    * Interrupt handler
		    */
			.balign 16
			
irq_vec:	
	/*
			// check status of flag_isr

	//		picorv32_setq_insn(q2, t0)	// q2 = ra
	//		picorv32_setq_insn(q3, a0)	// q3 = sp

			la t0, flag_isr
			lw a0,0(t0)
			beq a0,zero,1f   //if (flag_isr == 0) { jump 1: } else {
	
			//re-entering isr, clear flag and jump to exit
			li a0, 00
			la t0, flag_isr
			sw a0,0(t0)
			j 2f

1:			// set flag_isr
			li a0, 1
			la t0, flag_isr
			sw a0,0(t0)
			*/

			/*Save registers*/
			
			//picorv32_setq_insn(q2, x1)	// q2 = ra
			//picorv32_setq_insn(q3, x2)	// q3 = sp
			
			addi sp, sp, -128
			
			sw x1, 0*4(sp) //ra
			sw x2, 1*4(sp) //sp TODO: is it needed at all?
			sw x3, 2*4(sp)
			sw x4, 3*4(sp)
			sw x5, 4*4(sp)
			sw x6, 5*4(sp)
			sw x7, 6*4(sp)
			sw x8, 7*4(sp)
			sw x9, 8*4(sp)
			sw x10, 9*4(sp)
			sw x11, 10*4(sp)
			sw x12, 11*4(sp)
			sw x13, 12*4(sp)
			sw x14, 13*4(sp)
			sw x15, 14*4(sp)
			sw x16, 15*4(sp)
			sw x17, 16*4(sp)
			sw x18, 17*4(sp)
			sw x19, 18*4(sp)
			sw x20, 19*4(sp)
			sw x21, 20*4(sp)
			sw x22, 21*4(sp)
			sw x23, 22*4(sp)
			sw x24, 23*4(sp)
			sw x25, 24*4(sp)
			sw x26, 25*4(sp)
			sw x27, 26*4(sp)
			sw x28, 27*4(sp)
			sw x29, 28*4(sp)
			sw x30, 29*4(sp)
			sw x31, 30*4(sp)
			
			// Call C function
			
			picorv32_getq_insn(a0, q1)
			jal irq
			
			//Restore registers
			lw x1, 0*4(sp)
			lw x2, 1*4(sp)
			lw x3, 2*4(sp)
			lw x4, 3*4(sp)
			lw x5, 4*4(sp)
			lw x6, 5*4(sp)
			lw x7, 6*4(sp)
			lw x8, 7*4(sp)
			lw x9, 8*4(sp)
			lw x10, 9*4(sp)
			lw x11, 10*4(sp)
			lw x12, 11*4(sp)
			lw x13, 12*4(sp)
			lw x14, 13*4(sp)
			lw x15, 14*4(sp)
			lw x16, 15*4(sp)
			lw x17, 16*4(sp)
			lw x18, 17*4(sp)
			lw x19, 18*4(sp)
			lw x20, 19*4(sp)
			lw x21, 20*4(sp)
			lw x22, 21*4(sp)
			lw x23, 22*4(sp)
			lw x24, 23*4(sp)
			lw x25, 24*4(sp)
			lw x26, 25*4(sp)
			lw x27, 26*4(sp)
			lw x28, 27*4(sp)
			lw x29, 28*4(sp)
			lw x30, 29*4(sp)
			lw x31, 30*4(sp)
									
			addi sp, sp, 128
			
	//		picorv32_getq_insn(t0,q2)	// q2 = ra
	//		picorv32_getq_insn(a0,q3)	// q3 = sp

2:			picorv32_retirq_insn()


disable_irq:
			.globl disable_irq
			addi sp, sp, -16
			sw t0, 12(sp)
			li t0,0xffffffff
			picorv32_maskirq_insn(zero, t0)
			lw t0, 12(sp)
			addi sp, sp, 16
			ret

enable_irq:
			.globl enable_irq
			addi sp, sp, -16
			sw t0, 12(sp)
			li t0,0x00000000
			picorv32_maskirq_insn(zero, t0)
			lw t0, 12(sp)
			addi sp, sp, 16
			ret


start:
		/* zero-initialize all registers */
			addi x1, zero, 0
			//addi x2, zero, 0 Stack pointer is already initialized to 4*MEM_WORDS on reset
			addi x3, zero, 0
			addi x4, zero, 0
			addi x5, zero, 0
			addi x6, zero, 0
			addi x7, zero, 0
			addi x8, zero, 0
			addi x9, zero, 0
			addi x10, zero, 0
			addi x11, zero, 0
			addi x12, zero, 0
			addi x13, zero, 0
			addi x14, zero, 0
			addi x15, zero, 0
			addi x16, zero, 0
			addi x17, zero, 0
			addi x18, zero, 0
			addi x19, zero, 0
			addi x20, zero, 0
			addi x21, zero, 0
			addi x22, zero, 0
			addi x23, zero, 0
			addi x24, zero, 0
			addi x25, zero, 0
			addi x26, zero, 0
			addi x27, zero, 0
			addi x28, zero, 0
			addi x29, zero, 0
			addi x30, zero, 0
			addi x31, zero, 0

			//copy data section
			
			la a0, _sidata
			la a1, _sdata
			la a2, _edata
			bge a1, a2, end_init_data
loop_init_data:
			lw a3, 0(a0)
			sw a3, 0(a1)
			addi a0, a0, 4
			addi a1, a1, 4
			blt a1, a2, loop_init_data
end_init_data:
			
			// zero-init bss section
			
			la a0, _sbss
			la a1, _ebss
			bge a0, a1, end_init_bss
loop_init_bss:
			sw zero, 0(a0)
			addi a0, a0, 4
			blt a0, a1, loop_init_bss
end_init_bss:
			
			//initialize flag_isr 
			//NOTE: this has already been done in loop_init_data!
			/*
			li a0, 0
			la t0, flag_isr
			sw a0,0(t0)
			*/	
			
			// call main
			call main
loop:		
			j loop
			
			
