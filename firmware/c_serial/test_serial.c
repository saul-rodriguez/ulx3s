//test_irq.c

#include "hardware.h"

//extern uint32_t sram;


int main() 
{
	//unsigned char flag;
	uint8_t rec_b[20],rec,i,num;

	EUSART1_Initialize();

	reg_intcon_bits->IRQ5IE=1;
	reg_intcon_bits->IRQ6IE=1;
	reg_intcon_bits->IRQ7IE=1;

	reg_intcon_bits->GIE = 1;


	//uncomment the following lines for verilog testbench
	EUSART1_Write(0xaa);
	EUSART1_Write(0x5b);
	EUSART1_Write(0xcc);
	reg_porta = 0x77; // @suppress("Type cannot be resolved")


	/*
	// Checking rx flag
	while(1) {	
		if (EUSART1_is_rx_ready()) {			
			rec = EUSART1_Read();
			reg_porta = rec; // @suppress("Type cannot be resolved")
			EUSART1_Write(rec);
		}				
	}
	*/

	/*
	// Waiting for character to come
	while(1) {
		rec = EUSART1_Read();
		rec++;
		EUSART1_Write(rec);
	}
	*/


	//Wait for a packet of more than 4 characters
	while(1) {
		if (EUSART1_is_rx_ready()) {
			__delay_ms(10); //NOTE: circular buffer is not working properly

			reg_porta = eusart1RxCount;


			num = eusart1RxCount;
			for (i = 0; i < num; i++) {
				rec_b[i] = EUSART1_Read();
				EUSART1_Write(rec_b[i]);
			}

			/*
			if (eusart1RxCount > 3) {
				num = eusart1RxCount;

				for (i = 0; i < num; i++) {
					rec_b[i] = EUSART1_Read();
					//EUSART1_Write(rec[i]);
				}

				for (i=0; i < num; i++) {
					EUSART1_Write(rec_b[i]);
				}

				reg_porta = eusart1RxCount;
			}
			*/

		}
	}

}


