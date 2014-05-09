#ifndef MPPC_D_H
#define MPPC_D_H

/*
 * 	22. Nov. 2013
 *	mppc_d.h - main definitions file (firmware) for Multi Pixel Photon Counter (MPPC) aka SiPM frontend board 
 *	by Lars Steffen Weinstock <weinstock@pyhsik.rwth-aachen.de>
 *
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>

#include "m88pa_usart.h"
#include "m88pa_adc.h"
#include "m88pa_timer.h"
#include "m88pa_spi.h"

	/////////////////
	// definitions //
	/////////////////

#define SIPM_A	0
#define SIPM_B	1

// ENAble port for serial communication
#define ENA_PORT	PORTD
#define ENA_DDR		DDRD
#define ENA_PIN		PORTD4
#define SEL_LED		PORTD5
#define TEMP_PIN	PORTC0

// MPPC status
#define IDLE		0
#define LISTENING	1
#define ADDRESSED	2
#define ISSUED		3
#define READING		4
#define SENDING		5

// commands
#define READ_TEMP	'I'
#define READ_TEMP_RAW	'J'
#define SET_UBIAS_A	'A'
#define SET_UBIAS_B	'B'
#define SET_COEFF	'C'
#define READ_UADJ_A	'D'
#define READ_UADJ_B	'E'
#define READ_COEFF	'F'
#define PRINT_HELP	'H'
#define SIPM_INFO	'S'
#define DAC_CAL		'Q'
// end of message
#define EOM		"\n\r*"

	////////////////////////
	// module definitions //
	////////////////////////

// turn the driver on (send)
void sendDriver(void);

// turn the driver off (read)
void receiveDriver(void);

// toggle led
void toggleLED(int on_off);

// convert a float to string (eg. +01.230 -> hardcoded!!)
void floatToString(float val, char* string);

// interprets the received command
void command_handler(uint8_t command);

// changes the supply voltage of given SiPM via SPI comm. 
void setSupplyVoltage(int SiPM_no, uint16_t val);

// converts 16 bit adc_count to temperature in °C
float getTemperature(uint16_t adc_counts);

// returns temperature adjusted operational voltage in 5mV counts
uint16_t getVopAdjusted(int SiPM_no, float temperature);

// converts the given adjusted voltage in 5mV counts to DAC counts
uint16_t getDACCounts(uint16_t Vadj);

// adjust bias voltage to temperature 
void adjustVoltages(void);

// convert ascii to hex
uint32_t AsciiToHex(char* str, int len);
void HexToAscii(char* buf, int len, uint32_t hex);

// send one byte
void sendByte(char c);
void sendString(char* str);

// receive a string a echo each single character (according to protocol)
void receiveString(char* str, int len);

#endif
