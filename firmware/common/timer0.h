#ifndef TIMER0_H
#define TIMER0_H

#include "vargen.h"

typedef enum {
	INT_TMR = 1,
	GO = 2,
	EN = 4,
	AUTO_LOAD = 8
} TMR0_Config;

extern void (*TMR0_InterruptHandler)(void);

void TMR0_Initialize(TMR0_Config conf);
void TMR0_StartTimer(void);
void TMR0_StopTimer(void);
void TMR0_ISR(void);
void TMR0_WriteTimer(uint32_t timerVal);
void TMR0_clear_int_flag(void);
bool TMR0_is_done(void);
void TMR0_SetInterruptHandler(void (* InterruptHandler)(void));
void TMR0_DefaultInterruptHandler(void);





//#define TMR0_is_done() reg_timer0_conf_bits->INT_TMR

#define TMR0_Stop()  {\
		reg_timer0_conf_bits->EN = 0; \
		reg_timer0_conf_bits->GO = 0; \
	}



#endif
