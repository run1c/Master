#include "m88pa_usart.h"

void USART_init(void){

	/* USART setup (required for RS485 communication) */

	uint8_t dummy;

	UBRR0H = 0x00;
	UBRR0L = 0x0C;						// baud rate prescaler = 12
	UCSR0A = (1 << U2X0);					// normal speed and 2x mode => BAUD = fosc/(8*(UBRR+1)) = 9615 ~= 9600 bit/s @ 1MHz
	UCSR0B = (1 << RXEN0) | (1 << TXEN0) | (1 <<TXCIE0);	// RX, TX and TX complete interrupt enabled  
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);			// UART, no parity, 1 bit stop, 8 bit character size = 8N1	
	while ( UCSR0A & (1 << RXC0) ) dummy = UDR0;		// flush the USART
		
	return;
}

void USART_sendByte(char c){
	// wait until UDRE0 = 0 => data buffer is empty and ready to be written to
	while ( !( UCSR0A & (1 << UDRE0) ) ){};
	UDR0 = c;	// send character
	return;
}

void USART_sendString(char* s){
	char* ptr = s;
	while(*ptr != '\0'){	// '\0' is the string termination character
		USART_sendByte(*ptr);
		wait_ms(2);
		ptr++;
	}
	return;	
}

uint8_t USART_dataAvaliable(void){
	// check for unread data in the buffer
	return ( UCSR0A & (1 << RXC0) ); 
}

char USART_readByte(void){
	// return data in the buffer (better check first, if there is anything to read)
	return UDR0;
}

char USART_receiveByte(void){
	// wait until there is data to be received
	while( !USART_dataAvaliable() ){};
	return USART_readByte();
}

void USART_receiveString(char* str, int len){
	int ctr = 0;
	while (ctr < len){
		(*str) = USART_receiveByte();
		str++;
		ctr++;
	}
	// append string termination character
	(*str) = '\0';
}
