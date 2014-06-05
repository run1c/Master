/*
 * controller_min.c
 *
 * Created: 02/06/2014 10:06:43
 *  Author: run1c
 */ 


#include <avr/io.h>
#include "tn841_timer.h"
#include "tn841_usart.h"

#define ENA_PORT PORTA
#define ENA_DDR DDRA
#define ENA_LED PORTA0
#define ENA_PIN PORTA3

void driverSend(void);
void driverReceive(void);

uint32_t AsciiToHex(char* str, int len);
void HexToAscii(char* buf, int len, uint32_t hex);

void sendByte(char c);
void receiveString(char* str, int len);
void sendString(char* str);

int main(void)
{
	cli();
	timer_init();
	USART_init();
	sei();
	
	DDRA = (1 << ENA_LED) | (1 << ENA_PIN);
	ENA_PORT = 0x00;
	
	// init condition is receiving
	driverReceive();
	
	char cbuf = 'X';
	
    while(1)
    {
		ENA_PORT |= (1 << ENA_LED);
		driverReceive();
		cbuf = USART_receiveByte();
		sendByte(cbuf);
		ENA_PORT &= ~(1 << ENA_LED);
		//zsleep_ms(1000);
	}
}

void driverSend(void){
	ENA_PORT |= (1 << ENA_PIN);		// enable driver
	sleep_ms(10);
	return;
}

void driverReceive(void){
	ENA_PORT &= ~(1 << ENA_PIN);	// disable driver
	return;
}


uint32_t AsciiToHex(char* str, int len){
	// extract the number
	uint32_t buf = 0;
	int i;
	for (i = 0; i < len; i++){
		buf <<= 4;
		if (str[i] <= '9')
		buf |= str[i] - '0';
		else
		buf |= str[i] - 'A' + 0xA;
	}
	return buf;
}

void HexToAscii(char* buf, int len, uint32_t hex){
	int i;
	uint8_t byte = 0x00;
	for (i = 2; i <= len; i++){
		byte = hex & 0xF;
		if (byte < 0xA)
		buf[len - i] = byte + '0';
		else
		buf[len - i] = byte - 0xA + 'A';
		hex >>= 4;
	}
	buf[len - 1] = '\0';
	return;
}

void receiveString(char* str, int len){
	int ctr = 0;
	while (ctr < len){
		(*str) = USART_receiveByte();
		// echo the received byte
		sendByte(*str);
		str++;
		ctr++;
	}
	// append string termination character
	(*str) = '\0';
}

void sendByte(char c){
	// turn the driver on
	driverSend();
	// send one byte via usart
	USART_sendByte(c);
	sleep_ms(2);
	return;
}



void sendString(char* str){
	char* ptr = str;
	int len = 0;
	driverSend();
	while(*ptr != '\0'){	// '\0' is the string termination character
		USART_sendByte(*ptr);
		ptr++;
		len++;
	}
	sleep_ms(2*len);
	return;
}