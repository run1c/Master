#ifndef M88PA_USART_H
#define M88PA_USART_H

/* 	USART methods 	*/

#include <avr/io.h>
#include <avr/interrupt.h>

// set all status and control registers 
void USART_init(void);	

// send one character out
void USART_sendByte(char c);

// send out a string terminated by '\0'
void USART_sendString(char* s);

// check if there is unread data in the buffer
uint8_t USART_dataAvaliable(void);

// read one character from the data register
char USART_readByte(void);

// read one character from data register (blocking)
char USART_receiveByte(void);

// read one string with given length (blocking)
void USART_receiveString(char* str, int len);

#endif
