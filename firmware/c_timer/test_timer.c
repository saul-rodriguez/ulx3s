//test_irq.c

#include "hardware.h"

//extern uint32_t sram;
//#define TIMER_VALUE 0xffffffc0
#define TIMER_VALUE 0xfff00000

volatile unsigned char tmr_flag;

void myTMR0_handler()
{
	tmr_flag = 1;
}

int main() 
{
	//unsigned char flag;
	unsigned char aux;
	
	//TMR0_Initialize(EN);
	TMR0_Initialize(EN | AUTO_LOAD);
	TMR0_WriteTimer(TIMER_VALUE);
	TMR0_SetInterruptHandler(myTMR0_handler); // Redirect default interrupt handler to user's handler

	TMR0_StartTimer(); //it is the same as reg_timer0_conf_bits->GO = 1;

	aux = 0x00;
	tmr_flag = 0;

	//Enable the timer0 interrupt
	reg_intcon_bits->TMR0IE = 1;
	reg_intcon_bits->GIE = 1;

	while(1) {
		/* Use of timer0 with polling */

		/*//Direct use of registers
		if (reg_timer0_conf_bits->INT_TMR) {
			reg_timer0_conf_bits->INT_TMR = 0; //Clear timer flag
			reg_timer0_conf_bits->GO = 1; //manual restart (disabled autoload)
			reg_porta = aux++;
		}

		// the timer flag is also available in reg_intflags_bits->TMR0IF
		if (reg_intflags_bits->TMR0IF) {
					reg_timer0_conf_bits->INT_TMR = 0; //Clear timer flag
					reg_timer0_conf_bits->GO = 1; //manual restart (disabled autoload)
					reg_porta = aux++;
		}

		// Use of inline functions instead of config registers
		if (TMR0_is_done()) {
							TMR0_clear_int_flag();
							TMR0_StartTimer(); //manual restart (disabled autoload)
							reg_porta = aux++;
		}
		*/

		/* Use of timer0 with interrupt */

		if (tmr_flag) {
			tmr_flag = 0;
			reg_porta = aux++;
			//TMR0_StartTimer();

			//reg_timer0_conf_bits->EN = 0;
			/*

			if (aux == 3) {
				TMR0_StopTimer();   // #pragma GCC optimize ("O2") was used to prevent the optimizer O3 to remove this
			} else {
				TMR0_StartTimer(); // if auto_load is not enabled
			}
			*/
		}

	}

}

