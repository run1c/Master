/*
 * tn841_usart.h
 *
 * Created: 04/06/2014 14:13:10
 *  Author: run1c
 */ 


#ifndef TN841_USART_H_
#define TN841_USART_H_

#include <avr/io.h>
#include <avr/interrupt.h>

// set all status and control registers
void USART_init(void);

// clear receiver data buffer
void USART_flush(void);

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

#endif /* TN841_USART_H_ */