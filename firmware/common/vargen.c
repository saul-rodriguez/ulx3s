//vargen.c

#ifndef VARGEN_C
#define VARGEN_C

#include "vargen.h"

volatile PORTA_bits_s* reg_porta_bits = (PORTA_bits_s*)(PORTA);
volatile PORTB_bits_s* reg_portb_bits = (PORTB_bits_s*)(PORTB);
volatile INTCON_bits_s* reg_intcon_bits = (INTCON_bits_s*)(INTCON);
volatile INTFLAGS_bits_s* reg_intflags_bits = (INTFLAGS_bits_s*)(INTFLAGS);
volatile TIMER0_CONF_bits_s* reg_timer0_conf_bits = (TIMER0_CONF_bits_s*)(TIMER0_CONF);
volatile SPI_MST_CONF_bits_s* reg_spi_master_conf_bits = (SPI_MST_CONF_bits_s*)(SPI_MST_CONF);

void disable_interrupts()
{
	asm volatile("call disable_irq\n");
}

void enable_interrupts()
{
	asm volatile("call enable_irq\n");
}

#endif
