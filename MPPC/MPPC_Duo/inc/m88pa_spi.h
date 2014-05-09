#ifndef M88PA_SPI_H
#define M88PA_SPI_H

#include <avr/io.h>
#include <avr/interrupt.h>

#define SPI_PORT	PORTB
#define SPI_CS1		PORTB2
#define SPI_MOSI	PORTB3
#define SPI_SCK		PORTB5

// initialize the uC as SPI Master
void SPI_MasterInit(void);

// send one byte to slave
void SPI_sendByte(uint8_t c);


#endif
