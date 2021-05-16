//interrupt_manager.c
#include "interrupt_manager.h"
#include "hardware.h"

void irq(uint32_t irqs)
{
/*
	if (reg_intcon_bits->TXIE == 1 && reg_intflags_bits->TXIF == 1) {
		EUSART1_TxDefaultInterruptHandler();
        //    EUSART1_Transmit_ISR();
    } else if (reg_intcon_bits->RXIE == 1 && reg_intflags_bits->RXIF == 1) {
    	EUSART1_RxDefaultInterruptHandler();
        //    EUSART1_RxDataHandler();
    } else */
	if (reg_intcon_bits->SPIIE == 1 && reg_intflags_bits->SPIIF == 1) {
		SPI1_Transmit_ISR();
	} else if (reg_intcon_bits->IRQ5IE == 1 && reg_intflags_bits->IRQ5IF == 1) {
		reg_porta = 1;
	} else if (reg_intcon_bits->IRQ6IE == 1 && reg_intflags_bits->IRQ6IF == 1) {
		reg_porta = 2;
	} else if (reg_intcon_bits->IRQ7IE == 1 && reg_intflags_bits->IRQ7IF == 1) {
		reg_porta = 3;
	} else {
		reg_porta = irqs;
	}
	
}


