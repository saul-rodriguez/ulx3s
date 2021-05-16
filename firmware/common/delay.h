//delay.h

#ifndef DELAY_H
#define DELAY_H

#include "vargen.h"

// CLK_FREQ must be defined before delay.h is read
//#define CLK_FREQ 16000000

#ifndef CLK_FREQ
	#error "CLK_FREQ must be defined before delay.h is read"
#endif

/* delay_cycles 
 The following timing is obtained when compiling with -O3 optimization:
 18 clk_cycles total overhead 
 11 clk_cycles per loop iteration
*/

void delay_cycles_11(unsigned int numLoop); 

#define CYCLES_PER_LOOP 11

#define __delay_us(time_us) {\
						delay_cycles_11((time_us*CLK_FREQ)/1000000/CYCLES_PER_LOOP); \
					}

#define __delay_ms(time_ms) {\
						delay_cycles_11((time_ms*CLK_FREQ)/1000/CYCLES_PER_LOOP); \
					}



#endif
