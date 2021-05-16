//interrupt_manager.c
#include "interrupt_manager.h"
#include "hardware.h"

void irq(uint32_t irqs) // @suppress("Type cannot be resolved")
{

    if (irqs & IRQ_5) {
		reg_porta = IRQ_5; // @suppress("Type cannot be resolved")
	} 

	if (irqs & IRQ_6) {
		reg_porta = IRQ_6;		 // @suppress("Type cannot be resolved")
	}

	if (irqs & IRQ_7) {
		reg_porta = IRQ_7; // @suppress("Type cannot be resolved")
	}
	
	
}
