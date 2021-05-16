//test_irq.c

#include <stdint.h>
#include <stdbool.h>

#include "../common/vargen.h"

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
			reg_porta = irqs;
	}

}


int main()
{
	//unsigned char aux;

	reg_intcon_bits->IRQ5IE = 1;
	reg_intcon_bits->IRQ6IE = 1;
	reg_intcon_bits->IRQ7IE = 1;
	reg_intcon_bits->GIE = 1;

	//aux = 0xa0;
	while(1) {
		//aux++;
		reg_porta = reg_portb;
	}
}

