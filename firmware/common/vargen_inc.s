#Memory mapped peripherals definitions

#interrupt configuration register
.equ INTCON,  0x00100000

#Interrupt flags
.equ INTFLAGS,  0x00100004

#uart registers
.equ UART_TX,   0x00100008
.equ UART_RX,   0x0010000c
.equ UART_CONF, 0x00100010

#input porta
.equ PORTA,	0x00100014
#.equ PORTA_WIDTH 8

#output porta
.equ PORTB,	0x00100018
#.equ PORTB_WIDTH 8

#External interrupts flags available in pircorv32 reg q0
#q0 is passed as parameter irqs in void irq(uint32_t irqs);
.equ IRQ_5, 0x00000010
.equ IRQ_6, 0x00000020
.equ IRQ_7, 0x00000040

#uart interrupts available in reg_intcon
.equ UART_RX_IF, 0x01
.equ UART_TX_IF, 0x02


//Interrupt config
.equ INTCON, 0x00100000

//Interrupt flags
.equ INTFLAGS, 0x00100004
