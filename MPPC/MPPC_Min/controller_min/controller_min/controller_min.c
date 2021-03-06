/*
 * controller_min.c
 *
 * Created: 02/06/2014 10:06:43
 *  Author: run1c
 */ 


#include <avr/io.h>
#include "tn841_timer.h"
#include "tn841_usart.h"
#include "tn841_adc.h"

#define ENA_PORT PORTA
#define ENA_DDR DDRA
//#define ENA_LED PORTA0
#define ENA_PIN PORTA0

// commands
#define READ_TEMP 'I'
#define READ_TEMP_RAW 'J'
#define SET_UBIAS_A 'A'
#define SET_COEFF 'C'
#define READ_UADJ_A 'D'
#define READ_COEFF 'F'
#define PRINT_HELP 'H'
#define SIPM_INFO 'S'
#define DAC_CAL 'Q'

// end of message
#define EOM "\n\r*"

// MPPC status
#define IDLE 0
#define LISTENING 1
#define ADDRESSED 2
#define ISSUED 3
#define READING 4
#define SENDING 5

#define ADC_REG OCR1A

void driverSend(void);
void driverReceive(void);

uint32_t AsciiToHex(char* str, int len);
void HexToAscii(char* buf, int len, uint32_t hex);
void floatToString(float val, char* string);

void sendByte(char c);
void receiveString(char* str, int len);
void sendString(char* str);

void command_handler(uint8_t command);
float getTemperature(uint16_t temp);
uint16_t calcAdjustedBiasVoltage(float temperature);

// global variables
uint8_t MPPC_status = IDLE;
uint8_t own_addr = 0x20, Vcoef = 57;
char SerNoA[9] = "3H00004\0";
uint32_t VopA = 67290;
float DACGainA = -1.627f;
float DACOffA = 68698;

int main(void)
{
	// init all needed services
	cli();
	timer_init();
	USART_init();
	ADC_init();
	sei(); 
	
	// set up enable port
	ENA_DDR = /*(1 << ENA_LED) |*/ (1 << ENA_PIN);
//	ENA_PORT = (1 << ENA_LED);
	
	// init condition is receiving
	driverReceive();
	
	// string, char and ascii buffers for serial comm.
	uint8_t read_buf = 0x00, ascii_bufh = 0x00, ascii_bufl = 0x00;
	char str_buf[10];
	
	// send own address on startup
	HexToAscii(str_buf, 3, own_addr);
	sendString(str_buf);
	sendString(EOM);
	
    while(1) {
		// check if there is something to be read (non blocking...)
		if ( USART_dataAvaliable() ){
			read_buf = 0x00;
			read_buf = USART_readByte();
			switch(MPPC_status){
				
				/* no start delimiter, awaits start delimiter */
				
				case IDLE:
				if (read_buf == '<'){
					MPPC_status = LISTENING;
				} else {
					MPPC_status = IDLE;
					sleep_ms(2);
				}
				break;
	
				/* received a start delimiter, awaits adress */
				
				case LISTENING:
				// check wether there are characters or ASCII numbers beeing send
				if ( ((read_buf >= '0') && (read_buf <= '9')) ||
				((read_buf >= 'A') && (read_buf <= 'F')) ) {
					// a ASCII number has been sent, we need another digit
					str_buf[0] = read_buf;
					str_buf[1] = USART_receiveByte();
					// convert both ascii numbers into a 'real' hex number
					read_buf = AsciiToHex(str_buf, 2);
					HexToAscii(str_buf, 3, read_buf);
				} else {
					// in this stage we need an address; if there are no numbers beeing sent, we are not interested anymore!
					MPPC_status = IDLE;
					break;
				}
				// We received an address, converted it to hex and now want to check, if it is our's
				if (read_buf == own_addr){
					MPPC_status = ADDRESSED;
					// SEL_LED on -> module has been selected + echo
					sendString(str_buf);
//					ENA_PORT&= ~(1 << ENA_LED);
					// echo in ASCII
				} else {
					MPPC_status = IDLE;
				}
				break;

				/* received it's own address, awaits command */
				
				case ADDRESSED:
				if (read_buf == '>'){	// stop delimiter
					MPPC_status = IDLE;
//					ENA_PORT |= (1 << ENA_LED);	// SEL_LED off -> module has been deselected
				} else {
					command_handler(read_buf);	// yet another switch/case stucture...
				}
				break;

			} // end switch

		} // end if
		
		// apply bias voltages
		setBiasVoltage();
	}
}

	/////////////
	// METHODS //
	/////////////

void command_handler(uint8_t command){
	uint16_t wbuf;
	uint8_t bufh, bufl;
	float fbuf;
	char sbuf[10];
	switch(command){

		/* read temperature in human readable form */

		case READ_TEMP:
		sendByte(command);
		fbuf = getTemperature( ADC_read() );
		floatToString(fbuf, sbuf);
		sendString(sbuf);
		sendString(EOM);
		break;

		/* read temperature in raw ADC counts */
		case READ_TEMP_RAW:
		sendByte(command);
		wbuf = ADC_read();
		HexToAscii(sbuf, 4, wbuf);
		sendString(sbuf);
		sendString(EOM);
		break;

		/* set operational voltage @25�C */

		case SET_UBIAS_A:
		// echo the command
		sendByte(command);
		// waiting for a 4 character string
		receiveString(sbuf, 4);
		sendString(EOM);
		// set ADC register to given value
		wbuf = AsciiToHex(sbuf, 4);
		// max 0x7FF
		ADC_REG = 0x7FF & wbuf;
		break;

		/* set the temperature progression coefficient */

		case SET_COEFF:
		// echo...
		sendByte(command);
		// waiting for a 2 character string
		receiveString(sbuf, 2);
		sendString(EOM);
//		Vcoef = AsciiToHex(sbuf, 2);
		// max value = 0x7F
//		Vcoef &= 0x7F;		
		break;

		/* read the calculated adjusted operational voltage */

		case READ_UADJ_A:
		sendByte(command);
		// get temperature
		fbuf = getTemperature( ADC_read() );
		// calculate temperature adjusted voltage
		wbuf = calcAdjustedBiasVoltage(fbuf);
		// create string
		HexToAscii(sbuf, 5, wbuf);
		sendString(sbuf);
		sendString(EOM);
		break;

		/* read temperature coefficient */

		case READ_COEFF:
		sendByte(command);
		sendString(EOM);
		break;

		/* print help */

		case PRINT_HELP:
		sendByte(command);
		sendString("HW Version x.x SW Version 2.0");
		sendString(EOM);
		break;

		/* print sipm info of module */
		case SIPM_INFO:
		sendByte(command);
		sendString(EOM);
		break;
		
		case DAC_CAL:
		sendByte(command);
		sendString(EOM);
		break;
	
		default:
		MPPC_status = ADDRESSED;
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

void floatToString(float val, char* string){
	int temp, i = 1;
	float dec = 10;
	// get the right sign
	if (val < 0) {
		string[0] = '-';
	val *= -1.0;}
	else {
		string[0] = '+';
	}

	do{
		if (dec == 0.1f){	// decimal point
			string[i] = '.';
			i++;
		}

		if (val < dec) {
			string[i] = '0';
			} else {
			temp = val/dec;
			string[i] = temp + '0';
			val -= temp*dec;
		}

		// inc counter
		i++;
		dec /= 10;
	} while (i < 7);
	string[7] = '\0';

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

float getTemperature(uint16_t temp){
	float voltage = (float)temp/1024. * 1.1;	// 10 bit adc, internal 1V1 analog reference
	return ( (voltage - 0.5) * 100. );	// 500mV offset = 0degC, 0.01V/degC = 100degC/V
}

uint16_t calcAdjustedBiasVoltage(float temperature){
	return (uint16_t)(( Vcoef*(temperature - 25.) + VopA )/5.); 
}

void setBiasVoltage(){
	float temperature;
	uint16_t biasVoltage_5mV;	// bias voltage in 5mV steps
	uint16_t DACcounts;
	// get the temperature and calculate the voltage	
	temperature = getTemperature( ADC_read() );
	biasVoltage_5mV = calcAdjustedBiasVoltage(temperature);
	// calculate dac counts
	DACcounts = (uint16_t) ( (biasVoltage_5mV*5. - DACOffA)/DACGainA );
	// apply changes to PWM register
	OCR1A = DACcounts;
	return;
}

ISR(USART0_TX_vect){
	driverReceive();	
}