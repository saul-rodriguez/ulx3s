//hardware.h

#ifndef HARDWARE_H
#define HARDWARE_H

//System clock
#define CLK_FREQ 25000000
//Note: This define is not visible to the common libraries. It is much better to pass a
//      global define as part of CLFAGS during compilation: -DCLK_FREQ=25000000

//Uart bitrate
#define BRATE 9600
#define UART_CONF_VAL (CLK_FREQ/BRATE)

//SPI frequency
#define SPI_FREQ 1000000
#define CLKS_PER_HALF_BIT  ((CLK_FREQ/SPI_FREQ)/2)


#include "../common/vargen.h"
#include "../common/eusart1.h"
#include "../common/delay.h"
#include "../common/spi1.h"
#include "interrupt_manager.h"


#endif
