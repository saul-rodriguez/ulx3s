/*
 * spi1.h
 *
 *  Created on: Nov 10, 2020
 *      Author: saul
 */

#ifndef SPI1_H_
#define SPI1_H_

#include <stdint.h>
#include "vargen.h"

/**
SPI1_Initialize() sets CS to H and configures the spi clock with the parameter
clks_par_half_bit. This parameter can be calculated using the following #define
macros in the calling function (they should not be uncommented here!):

#define CLK_FREQ 16000000
#define SPI_FREQ 1600000
#define CLKS_PER_HALF_BIT  ((CLK_FREQ/SPI_FREQ)/2)

*/

/*
#define SPI1_ExchangeByte(a) ({\
			reg_spi_master = a;\
			while(!reg_intflags_bits->SPIIF);\
			reg_spi_master;\
		})
*/

/*
 * Polling based SPI
 * NOTE: IRQ must be disabled during communications
*/

void SPI1_Initialize(uint16_t clks_per_half_bit);
uint8_t SPI1_ExchangeByte(uint8_t data);


/*
 * Interrupt based SPI
*/
extern volatile uint8_t spi1TxBufferRemaining;
//extern volatile uint8_t spi1RxCount;

void SPI1_Initialize_ISR(uint16_t clks_per_half_bit);
bool SPI1_is_tx_ready(void);
void SPI1_Write(uint8_t txData);
void SPI1_Transmit_ISR(void);
void SPI1_SetTxInterruptHandler(void (* interruptHandler)(void));





#endif /* SPI1_H_ */
