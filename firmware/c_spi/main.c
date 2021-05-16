/*
 * main.c
 *
 *  Created on: Nov 10, 2020
 *      Author: saul
 */

#include "hardware.h"
#include "mcp23s17.h"

//#define SPI_IRQ

int main()
{


#ifndef SPI_IRQ
	unsigned char aux, rec;

	SPI1_Initialize(CLKS_PER_HALF_BIT);

	MCP23S17_setAddress(0x20);
	MCP23S17_setTrisA(0x00);

/*
	//Test exchange byte in loop back test
	aux = 0;
	rec = 0;
	while(1) {

		rec = SPI1_ExchangeByte(aux);
		reg_porta = aux;
		aux++;
		//reg_spi_master = aux;
		//while(!reg_intflags_bits->SPIIF);
		//reg_porta = rec;
	//	reg_spi_master_conf_bits->CS = 0;
		//reg_spi_master = aux;
		//reg_porta = reg_intflags;
		//reg_spi_master_conf_bits->CS = 1;


		//aux++;

	}
*/


	// Test port expander
	aux = 0xff;

	reg_intcon_bits->IRQ5IE = 1;
	reg_intcon_bits->IRQ6IE = 1;
	reg_intcon_bits->IRQ7IE = 1;
	reg_intcon_bits->GIE = 1;

	while(1) {
		if (reg_portb_bits->B0) {

			reg_intcon_bits->GIE = 0;
			for (rec = 0; rec < 10; rec++) {
				MCP23S17_writePortA(aux);
				reg_porta = aux;
				aux++;

			}
			reg_intcon_bits->GIE = 1;
			__delay_ms(50);
		}

	}
#else

	volatile unsigned char data[5],i;

	SPI1_Initialize_ISR(CLKS_PER_HALF_BIT);
	reg_intcon_bits->IRQ5IE = 1;
	reg_intcon_bits->IRQ6IE = 1;
	reg_intcon_bits->IRQ7IE = 1;
	reg_intcon_bits->GIE = 1;

	for (i = 0; i < 5; i++) {
			data[i] = 0xa0 + i;
	}

	while(1) {
		for (i = 0; i < 5; i++) {
			SPI1_Write(data[i]);
		}
	}

#endif


}


