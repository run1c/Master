#include "m88pa_spi.h"

void SPI_MasterInit(void){
	// /SS must be high before setting SPE
	SPI_PORT |= (1 << SPI_CS1);			
	// CLK and MOSI = output, MISO = input, /SS = output 
	DDRB = (1 << SPI_MOSI) | (1 << SPI_SCK) | (1 << SPI_CS1);
	// enable SPI, AVR is master	
	SPCR = (1 << SPE) | (1 << MSTR);	
	// setup on rising, sample on falling edge, clk prescaler = 16	
	SPCR |= (1 << CPHA) | (1 << SPR0);		
	
	return;
}

void SPI_sendByte(uint8_t c){
	SPDR = c;				// write data to data register
	while ( !(SPSR & (1 << SPIF)) ) {};	// wait until data transfer is complete
	
	return;
}
