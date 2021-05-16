/*
 * spi1.c
 *
 *  Created on: Nov 10, 2020
 *      Author: saul
 */

#include "spi1.h"

//volatile unsigned char token;

#define SPI1_TX_BUFFER_SIZE 8
#define SPI1_RX_BUFFER_SIZE 8

/**
  Section: Global Variables
*/
volatile uint8_t spi1TxHead = 0;
volatile uint8_t spi1TxTail = 0;
volatile uint8_t spi1TxBuffer[SPI1_TX_BUFFER_SIZE];
volatile uint8_t spi1TxBufferRemaining;

void (*SPI1_TxDefaultInterruptHandler)(void);

void SPI1_Initialize(uint16_t clks_per_half_bit)
{
	reg_intcon_bits->SPIIE = 0;
	reg_spi_master_conf_bits->CS = 1;
	reg_spi_master_conf_bits->CLKS_PER_HLF_BIT = clks_per_half_bit;
}


uint8_t SPI1_ExchangeByte(uint8_t data)
{
	//volatile unsigned char aux;
	reg_spi_master = data;
	while(!reg_intflags_bits->SPIIF);
//	do {
//		token = reg_intflags_bits->SPIIF;
//	} while(token == 0);

	return reg_spi_master;
	//return 0;
}

void SPI1_Initialize_ISR(uint16_t clks_per_half_bit)
{
	//disable interrupts before changing states
	reg_intcon_bits->SPIIE = 0;
	reg_spi_master_conf_bits->CS = 1;
	SPI1_SetTxInterruptHandler(SPI1_Transmit_ISR);

	reg_spi_master_conf_bits->CLKS_PER_HLF_BIT = clks_per_half_bit;

	// initializing the driver state
	spi1TxHead = 0;
	spi1TxTail = 0;
	spi1TxBufferRemaining = sizeof(spi1TxBuffer);

	//reg_intcon_bits->SPIIE = 1;
}

bool SPI1_is_tx_ready(void)
{
	return (spi1TxBufferRemaining ? true : false);
}

void SPI1_Write(uint8_t txData)
{
	while (0 == spi1TxBufferRemaining) {
	}

	if (0 == reg_intcon_bits->SPIIE) {
		reg_spi_master = txData;
	} else {
	    reg_intcon_bits->SPIIE = 0;
	    spi1TxBuffer[spi1TxHead++] = txData;
	    if (sizeof(spi1TxBuffer) <= spi1TxHead) {
	    	spi1TxHead = 0;
	    }
	    spi1TxBufferRemaining--;
	}

	reg_intcon_bits->SPIIE = 1;
}

void SPI1_Transmit_ISR(void)
{
	  // add your EUSART1 interrupt custom code
	if(sizeof(spi1TxBuffer) > spi1TxBufferRemaining) {
	        //TX1REG = eusart1TxBuffer[eusart1TxTail++];
		reg_spi_master = spi1TxBuffer[spi1TxTail++];
	    if (sizeof(spi1TxBuffer) <= spi1TxTail) {
	    	spi1TxTail = 0;
	    }
	    spi1TxBufferRemaining++;
	} else {
		//PIE3bits.TX1IE = 0;
	    reg_intcon_bits->SPIIE = 0;
	}
}

void SPI1_SetTxInterruptHandler(void (* interruptHandler)(void))
{
	SPI1_TxDefaultInterruptHandler = interruptHandler;
}






