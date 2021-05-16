//delay.c

#include "delay.h"

/* delay_cycles 
 The following timing is obtained when compiling with -O3 optimization:
 18 clk_cycles total overhead 
 11 clk_cycles per loop itertion 
*/

void delay_cycles_11(unsigned int numLoop) 
{
					 
	asm volatile("1: 		beq %[anumLoop],zero,2f\n"
				 "			addi %[anumLoop],%[anumLoop],-1\n"
				 "	     	j 1b\n"
				 "2:\n"
				 : [anumLoop] "+r" (numLoop));

}


