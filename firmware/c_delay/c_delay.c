//test_delay.c

#include <stdint.h>
#include <stdbool.h>
#include "../common/vargen.h"
#include "../common/delay.h"

//extern uint32_t sram;

void irq(uint32_t irqs)
{
	if (reg_intcon_bits->IRQ5IE == 1 && reg_intflags_bits->IRQ5IF == 1) {
		reg_porta = 1;
	} else if (reg_intcon_bits->IRQ6IE == 1 && reg_intflags_bits->IRQ6IF == 1) {
		reg_porta = 2;
	} else if (reg_intcon_bits->IRQ7IE == 1 && reg_intflags_bits->IRQ7IF == 1) {
		reg_porta = 3;
	} else {
			//reg_porta = irqs;
	}
}


void main()
{
	int a;
		
	reg_intcon = 0x00;
	a = 10;
	
	while(1) {
		reg_porta = 0x00;
		//delay_cycles_11(a);
		//__delay_us(100);
		__delay_ms(1);
		reg_porta = 0xff;
		//__delay_us(100);
		__delay_ms(1);
		//delay_cycles_11(a);	
	}
	
}
