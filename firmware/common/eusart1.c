//eusart1.c
#include "eusart1.h"

/**
  Section: Macro Declarations
*/

#define EUSART1_TX_BUFFER_SIZE 8
#define EUSART1_RX_BUFFER_SIZE 8

/**
  Section: Global Variables
*/
volatile uint8_t eusart1TxHead = 0;
volatile uint8_t eusart1TxTail = 0;
volatile uint8_t eusart1TxBuffer[EUSART1_TX_BUFFER_SIZE];
volatile uint8_t eusart1TxBufferRemaining;

volatile uint8_t eusart1RxHead = 0;
volatile uint8_t eusart1RxTail = 0;
volatile uint8_t eusart1RxBuffer[EUSART1_RX_BUFFER_SIZE];
//volatile eusart1_status_t eusart1RxStatusBuffer[EUSART1_RX_BUFFER_SIZE];
volatile uint8_t eusart1RxCount;
//volatile eusart1_status_t eusart1RxLastError;

void (*EUSART1_TxDefaultInterruptHandler)(void);
void (*EUSART1_RxDefaultInterruptHandler)(void);

void EUSART1_Initialize(void)
{
	// disable interrupts before changing states
	reg_intcon_bits->RXIE = 0;	
	//EUSART1_SetRxInterruptHandler(EUSART1_Receive_ISR);
	EUSART1_SetRxInterruptHandler(EUSART1_RxDataHandler);

	reg_intcon_bits->TXIE = 0;	
	EUSART1_SetTxInterruptHandler(EUSART1_Transmit_ISR);
	
	//configure baud rate counter
	reg_uart_conf = UART_CONF_VAL;	
	
	// initializing the driver state
    eusart1TxHead = 0;
    eusart1TxTail = 0;
    eusart1TxBufferRemaining = sizeof(eusart1TxBuffer);

    eusart1RxHead = 0;
    eusart1RxTail = 0;
    eusart1RxCount = 0;
	
	//Enable RX interrupt
	reg_intcon_bits->RXIE = 1;	
}

bool EUSART1_is_tx_ready(void)
{
    return (eusart1TxBufferRemaining ? true : false);
}

bool EUSART1_is_rx_ready(void)
{
    return (eusart1RxCount ? true : false);
}


uint8_t EUSART1_Read(void)
{
    uint8_t readValue  = 0;
    
    while(0 == eusart1RxCount)
    {
    }

    //eusart1RxLastError = eusart1RxStatusBuffer[eusart1RxTail];

    readValue = eusart1RxBuffer[eusart1RxTail++];
    //if(sizeof(eusart1RxBuffer) <= eusart1RxTail)
    if(EUSART1_RX_BUFFER_SIZE <= eusart1RxTail)
    {
        eusart1RxTail = 0;
    }
    reg_intcon_bits->RXIE = 0;
    eusart1RxCount--;
    reg_intcon_bits->RXIE = 1;

    return readValue;
}


void EUSART1_Write(uint8_t txData)
{
    while(0 == eusart1TxBufferRemaining)
    {
    }

    if(0 == reg_intcon_bits->TXIE)
    {
        reg_uart_tx = txData;
    }
    else
    {
        reg_intcon_bits->TXIE = 0;
        eusart1TxBuffer[eusart1TxHead++] = txData;
        if(sizeof(eusart1TxBuffer) <= eusart1TxHead)
        {
            eusart1TxHead = 0;
        }
        eusart1TxBufferRemaining--;
    }
    reg_intcon_bits->TXIE = 1;
}




void EUSART1_Transmit_ISR(void)
{

    // add your EUSART1 interrupt custom code
    if(sizeof(eusart1TxBuffer) > eusart1TxBufferRemaining)
    {
        //TX1REG = eusart1TxBuffer[eusart1TxTail++];
        reg_uart_tx = eusart1TxBuffer[eusart1TxTail++];
        if(sizeof(eusart1TxBuffer) <= eusart1TxTail)
        {
            eusart1TxTail = 0;
        }
        eusart1TxBufferRemaining++;
    }
    else
    {
        //PIE3bits.TX1IE = 0;
        reg_intcon_bits->TXIE = 0;
    }
}

/*
void EUSART1_Receive_ISR(void)
{
    
    //eusart1RxStatusBuffer[eusart1RxHead].status = 0;

	
    if(RC1STAbits.FERR){
        eusart1RxStatusBuffer[eusart1RxHead].ferr = 1;
        EUSART1_FramingErrorHandler();
    }

    if(RC1STAbits.OERR){
        eusart1RxStatusBuffer[eusart1RxHead].oerr = 1;
        EUSART1_OverrunErrorHandler();
    }
    
    
    if(eusart1RxStatusBuffer[eusart1RxHead].status){
        EUSART1_ErrorHandler();
    } else {
        EUSART1_RxDataHandler();
    }
    
    //  EUSART1_RxDataHandler();
    
    // or set custom function using EUSART1_SetRxInterruptHandler()
}
*/

void EUSART1_RxDataHandler(void){
    // use this default receive interrupt handler code
    eusart1RxBuffer[eusart1RxHead++] = reg_uart_rx;
   // if(sizeof(eusart1RxBuffer) <= eusart1RxHead)
    if(EUSART1_RX_BUFFER_SIZE <= eusart1RxHead)
    {
        eusart1RxHead = 0;
    }
    eusart1RxCount++;
}


void EUSART1_SetTxInterruptHandler(void (* interruptHandler)(void)){
    EUSART1_TxDefaultInterruptHandler = interruptHandler;
}

void EUSART1_SetRxInterruptHandler(void (* interruptHandler)(void)){
    EUSART1_RxDefaultInterruptHandler = interruptHandler;
}



