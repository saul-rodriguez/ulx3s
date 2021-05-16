//interrupt_manager.c
#include "interrupt_manager.h"
#include "hardware.h"

void irq(uint32_t irqs)
{

	if (reg_intcon_bits->TMR0IE == 1 && reg_intflags_bits->TMR0IF == 1) {
		//reg_timer0_conf_bits->INT_TMR = 0; //also possible to use TMR0_ISR()
		TMR0_ISR();

		//tmr_flag = 1;
	}

	/*
	if (reg_intcon_bits->TXIE == 1 && reg_intflags_bits->TXIF == 1) {           
            EUSART1_Transmit_ISR();
    } else if (reg_intcon_bits->RXIE == 1 && reg_intflags_bits->RXIF == 1) {            
            EUSART1_RxDataHandler();            
    }
    //reg_porta = 0xcc;

	*/
	
	
}
