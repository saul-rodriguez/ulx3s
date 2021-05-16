//porta_b.c

#include <stdint.h>
#include <stdbool.h>

//extern uint32_t sram;

//Memory mapped peripherals definitions
#define reg_porta (*(volatile uint32_t*) 0x00100000) // 8 bit digital output
#define reg_portb (*(volatile uint32_t*) 0x00100004) // 8 bit digital input

void main()
{
	uint32_t val;
	
	while (1) {
		val = reg_portb;
		reg_porta = val;
	}
	
	
}



