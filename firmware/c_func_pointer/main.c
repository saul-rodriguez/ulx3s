//test_irq.c

#include "hardware.h"

//extern uint32_t sram;
unsigned char (*mypt)(unsigned char, unsigned char);

unsigned char my_func(unsigned char a, unsigned char b)
{
	unsigned char aux;

	aux = a + b;

	return aux;
}

int main() 
{
	//unsigned char flag;
	unsigned char a,b,c,d;

	a = 1;
	b = 2;

	mypt = &my_func;

	while(1) {
		c = my_func(a, b);
		reg_porta = c;
		a++;
		d = mypt(a,b);
		reg_porta = d;
	}
}

