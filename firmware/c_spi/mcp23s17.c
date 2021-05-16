#include "mcp23s17.h"
#include "hardware.h"


unsigned char SPI_address;

// flag state for writing the mcp23s17
volatile MCP23S17_COMMAND mcp23s17_command;

// value to write to the spi using no_wait
volatile unsigned char SPI_write_val;

void MCP23S17_setAddress(unsigned char add)
{
    SPI_address = add << 1;
}

void MCP23S17_setTrisA(unsigned char tris)
{

	reg_spi_master_conf_bits->CS = 0;
    SPI1_ExchangeByte(SPI_address);
    SPI1_ExchangeByte(MCP23017_IODIRA);
    SPI1_ExchangeByte(tris);
    reg_spi_master_conf_bits->CS = 1;

}

void MCP23S17_writePortA(unsigned char val)
{

	reg_spi_master_conf_bits->CS = 0;
    SPI1_ExchangeByte(SPI_address);
    SPI1_ExchangeByte(MCP23017_GPIOA);
    SPI1_ExchangeByte(val);
    reg_spi_master_conf_bits->CS = 1;

}
/*
void writePortA_nowait()
{
    switch (mcp23s17_command) {
        case IDLE:                    
                    SS_SetLow();
                    SPI1_ExchangeByte_nowait(SPI_address);
                    mcp23s17_command = SEND1;
                    break;
        case SEND1:
                    SPI1_ExchangeByte_nowait(MCP23017_GPIOA);
                    mcp23s17_command = SEND2;
                    break;           
        case SEND2:
                    SPI1_ExchangeByte_nowait(SPI_write_val);
                    mcp23s17_command = SEND3;
                    break;
        case SEND3:
                    SS_SetHigh();
                    mcp23s17_command = IDLE;
                    break;
        default:
                    break;                    
    }

    
}
*/

