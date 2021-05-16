#include "timer0.h"

#pragma GCC push_options
#pragma GCC optimize ("O2")

void (*TMR0_InterruptHandler)(void);

void TMR0_Initialize(TMR0_Config conf)
{

	reg_timer0_conf = conf;

	//reg_timer0_conf_bits->INT_TMR = 0;0
	//reg_timer0_conf_bits->GO = 0;
	//reg_timer0_conf_bits->EN = 1;
	//reg_timer0_conf_bits->AUTO_LOAD = 0;

	TMR0_SetInterruptHandler(TMR0_DefaultInterruptHandler);

}

void TMR0_StartTimer(void)
{
	reg_timer0_conf_bits->GO = 1;
}

//#pragma GCC push_options
//#pragma GCC optimize ("O2")

void TMR0_StopTimer(void)
{
	reg_timer0_conf_bits->EN = 0;
	reg_timer0_conf_bits->GO = 0;
}

//#pragma GCC pop_options

void TMR0_ISR(void)
{
	reg_timer0_conf_bits->INT_TMR = 0;

	if(TMR0_InterruptHandler) {
		TMR0_InterruptHandler();
	}
}

void TMR0_WriteTimer(uint32_t timerVal)
{
	reg_timer0 = timerVal;
}


void TMR0_clear_int_flag(void)
{
	reg_timer0_conf_bits->INT_TMR = 0;
}

bool TMR0_is_done(void)
{
	return (reg_timer0_conf_bits->INT_TMR ? true : false);
}

void TMR0_SetInterruptHandler(void (* InterruptHandler)(void)){
    TMR0_InterruptHandler = InterruptHandler;
}

void TMR0_DefaultInterruptHandler(void){
    // add your TMR0 interrupt custom code
    // or set custom function using TMR0_SetInterruptHandler()
}

#pragma GCC pop_options
