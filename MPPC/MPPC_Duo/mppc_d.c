#include "mppc_d.h"

	////////////
	// EEPROM //
	////////////

#ifndef MODULE_NO
/* These are default values for calibration */
// own address
uint8_t eeAddress EEMEM = 0x00;
// temperature progression coefficient in mV/K
uint8_t eeVcoef EEMEM = 0;
// operation voltage @ 25°C in mV
uint32_t eeVopA EEMEM = 0;
uint32_t eeVopB EEMEM = 0;
// 8 byte serial number of the SiPMs (fill up with leading 0's)
char eeSerNoA[9] EEMEM  = "00000000\0";  
char eeSerNoB[9] EEMEM  = "00000000\0";  
// mV per DAC count
float eeDACGainA EEMEM = 1.27f;	
float eeDACGainB EEMEM = 1.27f;
// DAC offset in mV
float eeDACOffA EEMEM = 0;
float eeDACOffB EEMEM = 0;
// pt100 temperature coefficient in degree celcius per count & offset
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x04
// state 06.08.2015
uint8_t eeAddress EEMEM = 0x04;
uint8_t eeVcoef EEMEM = 54;
uint32_t eeVopA EEMEM = 55000;
uint32_t eeVopB EEMEM = 55400;
char eeSerNoA[9] EEMEM  = "00010100\0";
char eeSerNoB[9] EEMEM  = "00010101\0";
float eeDACGainA EEMEM = 1.2763f;	
float eeDACGainB EEMEM = 1.2756f;
float eeDACOffA EEMEM = 54;
float eeDACOffB EEMEM = 128;
float eeTGain EEMEM = 0.09934f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x07
// state 27.10.2015
uint8_t eeAddress EEMEM = 0x07;
uint8_t eeVcoef EEMEM = 60;
uint32_t eeVopA EEMEM = 55400;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM  = "00010093\0";
char eeSerNoB[9] EEMEM  = "00010062\0";
float eeDACGainA EEMEM = 1.2811f;	
float eeDACGainB EEMEM = 1.2779f;
float eeDACOffA EEMEM = 6;
float eeDACOffB EEMEM = 28; 
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x10
// state 10.05.2017
uint8_t eeAddress EEMEM = 0x10;
uint8_t eeVcoef EEMEM = 54;
uint32_t eeVopA EEMEM = 55200;
uint32_t eeVopB EEMEM = 40000;
char eeSerNoA[9] EEMEM  = "00010099\0";
char eeSerNoB[9] EEMEM  = "00000000\0";
float eeDACGainA EEMEM = 1.2698f;	
float eeDACGainB EEMEM = 1.2690f;
float eeDACOffA EEMEM = -89;
float eeDACOffB EEMEM = -13;
float eeTGain EEMEM = 0.09934f;
float eeTOff EEMEM = -45.49f;
#elif MODULE_NO == 0x11
// state 10.10.2014
uint8_t eeAddress EEMEM = 0x11;
uint8_t eeVcoef EEMEM = 56;
uint32_t eeVopA EEMEM = 72769;
uint32_t eeVopB EEMEM = 72889;
char eeSerNoA[9] EEMEM  = "2K000925\0";
char eeSerNoB[9] EEMEM  = "2K000926\0";
float eeDACGainA EEMEM = 1.2738f;	
float eeDACGainB EEMEM = 1.2787f;
float eeDACOffA EEMEM = 15;
float eeDACOffB EEMEM = 54;
float eeTGain EEMEM = 0.0991f;
float eeTOff EEMEM = -45.91f;
#elif MODULE_NO == 0x12
// state 29.10.2015
uint8_t eeAddress EEMEM = 0x12;
uint8_t eeVcoef EEMEM = 60;
uint32_t eeVopA EEMEM = 55400;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM  = "00010094\0";
char eeSerNoB[9] EEMEM  = "00010063\0";
float eeDACGainA EEMEM = 1.2738f;	
float eeDACGainB EEMEM = 1.2763f;
float eeDACOffA EEMEM = -18;
float eeDACOffB EEMEM = 18;
float eeTGain EEMEM = 0.10018f;
float eeTOff EEMEM = -42.25f;
#elif MODULE_NO == 0x13
// state 10.10.2014
uint8_t eeAddress EEMEM = 0x13;
uint8_t eeVcoef EEMEM = 56;
uint32_t eeVopA EEMEM = 72815;
uint32_t eeVopB EEMEM = 72776;
char eeSerNoA[9] EEMEM  = "2K000929\0";
char eeSerNoB[9] EEMEM  = "2K000930\0";
float eeDACGainA EEMEM = 1.2787f;	
float eeDACGainB EEMEM = 1.2682f;
float eeDACOffA EEMEM = -9;
float eeDACOffB EEMEM = -8;
float eeTGain EEMEM = 0.09916f;
float eeTOff EEMEM = -45.769f;
#elif MODULE_NO == 0x14
uint8_t eeAddress EEMEM = 0x14;
uint8_t eeVcoef EEMEM = 56;
uint32_t eeVopA EEMEM = 72810;
uint32_t eeVopB EEMEM = 72810;
char eeSerNoA[9] EEMEM  = "00000000\0";
char eeSerNoB[9] EEMEM  = "00000000\0";
float eeDACGainA EEMEM = 1.2642f;	
float eeDACGainB EEMEM = 1.2684f;
float eeDACOffA EEMEM = -65;
float eeDACOffB EEMEM = -185;
float eeTGain EEMEM = 0.0991f;
float eeTOff EEMEM = -49.14f;
#elif MODULE_NO == 0x15
// state 04.09.2015
uint8_t eeAddress EEMEM = 0x15;
uint8_t eeVcoef EEMEM = 56;
uint32_t eeVopA EEMEM = 55000;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM  = "00010085\0";
char eeSerNoB[9] EEMEM  = "00010054\0";
float eeDACGainA EEMEM = 1.27152f;	
float eeDACGainB EEMEM = 1.2742f;
float eeDACOffA EEMEM = 43.;
float eeDACOffB EEMEM = -4.;
float eeTGain EEMEM = 0.10f;
float eeTOff EEMEM = -45.0f;
#elif MODULE_NO == 0x16
// state 04.09.2015
uint8_t eeAddress EEMEM = 0x16;
uint8_t eeVcoef EEMEM = 56;
uint32_t eeVopA EEMEM = 54800;
uint32_t eeVopB EEMEM = 54600;
char eeSerNoA[9] EEMEM  = "00010084\0";
char eeSerNoB[9] EEMEM  = "00010053\0";
float eeDACGainA EEMEM = 1.280f;	
float eeDACGainB EEMEM = 1.271f;
float eeDACOffA EEMEM = -181;
float eeDACOffB EEMEM = 79;
float eeTGain EEMEM = 0.10f;
float eeTOff EEMEM = -50.7f;
#elif MODULE_NO == 0x1F
// state 30.06.2014
uint8_t eeAddress EEMEM	= 0x1F;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 54800;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM = "10083\0";
char eeSerNoB[9] EEMEM = "10055\0"; 
float eeDACGainA EEMEM = 1.27568f;
float eeDACGainB EEMEM = 1.2858f;
float eeDACOffA EEMEM = 45;
float eeDACOffB EEMEM = -554;
float eeTGain EEMEM = 0.09996f;
float eeTOff EEMEM = -44.757;

/*
 *	Config for MPPC Ds used in the lab course
 */

#elif MODULE_NO == 0x20
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x20;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 54800;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM = "10083\0";
char eeSerNoB[9] EEMEM = "10052\0"; 
float eeDACGainA EEMEM = 1.26944f;
float eeDACGainB EEMEM = 1.27741f;
float eeDACOffA EEMEM = -0.04 ;
float eeDACOffB EEMEM = -78.92;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x21
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x21;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 54800;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM = "10084\0";
char eeSerNoB[9] EEMEM = "10053\0"; 
float eeDACGainA EEMEM = 1.26981f;
float eeDACGainB EEMEM = 1.27249f;
float eeDACOffA EEMEM = 123;
float eeDACOffB EEMEM = -35.6;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x22
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x22;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 55000;
uint32_t eeVopB EEMEM = 54600;
char eeSerNoA[9] EEMEM = "10085\0";
char eeSerNoB[9] EEMEM = "10054\0"; 
float eeDACGainA EEMEM = 1.27541f;
float eeDACGainB EEMEM = 1.27591f;
float eeDACOffA EEMEM = -24.13;
float eeDACOffB EEMEM = -96.85;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x23
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x23;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 55200;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM = "10086\0";
char eeSerNoB[9] EEMEM = "10055\0"; 
float eeDACGainA EEMEM = 1.27238f;
float eeDACGainB EEMEM = 1.27701f;
float eeDACOffA EEMEM = 60.77;
float eeDACOffB EEMEM = 5.61;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x24
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x24;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 55200;
uint32_t eeVopB EEMEM = 54800;
char eeSerNoA[9] EEMEM = "10087\0";
char eeSerNoB[9] EEMEM = "10056\0"; 
float eeDACGainA EEMEM = 1.27762f;
float eeDACGainB EEMEM = 1.27630f;
float eeDACOffA EEMEM = 71.;
float eeDACOffB EEMEM = -46.41;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x25
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x25;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 55200;
uint32_t eeVopB EEMEM = 54600;
char eeSerNoA[9] EEMEM = "10088\0";
char eeSerNoB[9] EEMEM = "10057\0"; 
float eeDACGainA EEMEM = 1.27715f;
float eeDACGainB EEMEM = 1.27505f;
float eeDACOffA EEMEM = 19.96;
float eeDACOffB EEMEM = 192.89;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x26
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x26;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 55600;
uint32_t eeVopB EEMEM = 54600;
char eeSerNoA[9] EEMEM = "10089\0";
char eeSerNoB[9] EEMEM = "10058\0"; 
float eeDACGainA EEMEM = 1.28082f;
float eeDACGainB EEMEM = 1.27766f;
float eeDACOffA EEMEM = -31.;
float eeDACOffB EEMEM = 7.7;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#elif MODULE_NO == 0x27
// state 22.04.2015
uint8_t eeAddress EEMEM	= 0x27;
uint8_t eeVcoef EEMEM = 0;
uint32_t eeVopA EEMEM = 55000;
uint32_t eeVopB EEMEM = 55000;
char eeSerNoA[9] EEMEM = "10090\0";
char eeSerNoB[9] EEMEM = "10059\0"; 
float eeDACGainA EEMEM = 1.27338f;
float eeDACGainB EEMEM = 1.27388f;
float eeDACOffA EEMEM = 40;
float eeDACOffB EEMEM = 76.76;
float eeTGain EEMEM = 0.1f;
float eeTOff EEMEM = -50.f;
#endif

	//////////
	// MAIN //
	//////////

// global variables
uint8_t MPPC_status = IDLE;
uint8_t own_addr, Vcoef;
char SerNoA[9], SerNoB[9];
uint32_t VopA, VopB;
float DACGainA, DACGainB;
float DACOffA, DACOffB;
float TGain, TOff;

int main(void){
	cli();
			
	timer_setup();
	USART_init();
	ADC_init();
	SPI_MasterInit();
	
	sei();	// activate interrupts
	
	ENA_PORT &= ~(1 << ENA_PIN);			// disable driver
	ENA_PORT |= (1 << SEL_LED); 			// disable selection led
	ENA_DDR |= (1 << ENA_PIN) | (1 << SEL_LED);	// set output

	receiveDriver();	

	/* 	Read constants from EEPROM 	*/
	own_addr 	= eeprom_read_byte(&eeAddress);
	VopA 		= eeprom_read_dword(&eeVopA);
	VopB 		= eeprom_read_dword(&eeVopB);
	eeprom_read_block( (void*)SerNoA, (const void*)eeSerNoA, 9);
	eeprom_read_block( (void*)SerNoB, (const void*)eeSerNoB, 9);
	Vcoef 		= eeprom_read_byte(&eeVcoef);
	DACGainA 	= eeprom_read_float(&eeDACGainA);
	DACGainB 	= eeprom_read_float(&eeDACGainB);
	DACOffA 	= eeprom_read_float(&eeDACOffA);
	DACOffB 	= eeprom_read_float(&eeDACOffB);
	TGain 		= eeprom_read_float(&eeTGain);
	TOff 		= eeprom_read_float(&eeTOff);

	uint8_t read_buf = 0x00, ascii_bufh = 0x00, ascii_bufl = 0x00;
	char str_buf[10];
	HexToAscii(str_buf, 3, own_addr);
	sendString(str_buf);
	sendString(EOM);

	while(1){
		// check if there is something to be read
	 	if ( USART_dataAvaliable() ){
			read_buf = 0x00;
      			read_buf = USART_readByte();
			switch(MPPC_status){
				// no start delimiter, awaits start delimiter
				case IDLE:
				if (read_buf == '<'){
					MPPC_status = LISTENING;
				} else {
					MPPC_status = IDLE;
					wait_ms(2);
				}
				break;

				// received a start delimiter, awaits adress
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
					toggleLED(1);
					// echo in ASCII
				} else {
					MPPC_status = IDLE;
				}
				break;

				// received it's own address, awaits command
				case ADDRESSED:
				if (read_buf == '>'){		// stop delimiter
					MPPC_status = IDLE;
					toggleLED(0);			// SEL_LED off -> module has been deselected		
				} else {			
					command_handler(read_buf);	// yet another switch/case stucture...
				}
				break;

			} // end switch

      		} // end if

		// time to adjust the bias voltage
		adjustVoltages();
	}

	return 0;
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
		// readout ADC0
		wbuf = ADC_read(TEMP_PIN);		
		// calculate temperature
		fbuf = getTemperature(wbuf);	 
		// convert to string
		floatToString(fbuf, sbuf);
		// send the string
		sendString(sbuf);
		// transmission complete!
		sendString(EOM);
		break;

		/* read temperature in raw ADC counts */
		case READ_TEMP_RAW:
		sendByte(command);
		// readout ADC0
		wbuf = ADC_read(TEMP_PIN);
		// convert hex to string		
		HexToAscii(sbuf, 5, wbuf);
		sendString(sbuf);
		// transmission complete!
		sendString(EOM);
		break;

		/* set operational voltage @25°C */

		case SET_UBIAS_A:
		// echo the command
		sendByte(command);	
		// waiting for a 4 character string
		receiveString(sbuf, 4);
		sendString(EOM);
		VopA = AsciiToHex(sbuf, 4);	
		// apply change (remember; 5mV steps and max value = 0x3FFF)
		VopA = (0x3FFF & VopA)*5;
		break;

		case SET_UBIAS_B:
		// echo the command
		sendByte(command);
		// waiting for a 4 character string
		receiveString(sbuf, 4);
		sendString(EOM);
		VopB = AsciiToHex(sbuf, 4);	
		// apply change (remember; 5mV steps and max value = 0x3FFF)
		VopB = (0x3FFF & VopB)*5;
		break;

		/* set the temperature progression coefficient */

		case SET_COEFF:
		// echo...
		sendByte(command);
		wait_ms(2);
		// waiting for a 2 character string
		receiveString(sbuf, 2);
		sendString(EOM);
		Vcoef = AsciiToHex(sbuf, 2);
		// max value = 0x7F
		Vcoef &= 0x7F;
		break;

		/* read the calculated adjusted operational voltage */

		case READ_UADJ_A:
		sendByte(command);
		// readout ADC0
		wbuf = ADC_read(TEMP_PIN);		
		// calculate temperature
		fbuf = getTemperature(wbuf);	 
		// calculate adjusted voltage
		wbuf = getVopAdjusted(SIPM_A, fbuf);
		HexToAscii(sbuf, 5, wbuf);
		sendString(sbuf);
		// message complete!
		sendString(EOM);
		break;
	
		case READ_UADJ_B:
		sendByte(command);
		// readout ADC0
		wbuf = ADC_read(TEMP_PIN);		
		// calculate temperature
		fbuf = getTemperature(wbuf);	 
		// calculate adjusted voltage
		wbuf = getVopAdjusted(SIPM_B, fbuf);
		HexToAscii(sbuf, 5, wbuf);
		sendString(sbuf);
		// message complete!
		sendString(EOM);
		break;
	
		/* read temperature coefficient */

		case READ_COEFF:
		sendByte(command);
		HexToAscii(sbuf, 3, Vcoef);	
		sendString(sbuf);
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
		sendString(" Sensor A No.: ");
		sendString(SerNoA);
		sendString(" Voltage:");
		HexToAscii(sbuf, 5, VopA/5);
		sendString(sbuf);
		
		sendString(" Sensor B No.: ");
		sendString(SerNoB);
		sendString(" Voltage:");
		HexToAscii(sbuf, 5, VopB/5);
		sendString(sbuf);

		sendString(EOM);
		break;

		/* adjust settings for external DAC calibration */

		case DAC_CAL:
		sendByte(command);
		// the DAC counts can be directly set with commands 'A'/'B' by changing the 
		// values of DACGain, DACOff and deactivating the temperature correction
		DACGainA = 1;
		DACGainB = 1;
		DACOffA = 0;
		DACOffB = 0;
		Vcoef = 0;	 
		sendString(EOM);
		break;	

		default: 
		MPPC_status = ADDRESSED;
	}
}

void sendDriver(void){
	ENA_PORT |= (1 << ENA_PIN);	// enable driver
	wait_ms(10);			// needs ~5us to be ready to send
	return;
}

void receiveDriver(void){
	ENA_PORT &= ~(1 << ENA_PIN);	// disable driver
	return;
}

void toggleLED(int on_off){
	if (on_off == 0)	// LED off
		ENA_PORT |= (1 << SEL_LED);
	if (on_off == 1)	// LED on
		ENA_PORT &= ~(1 << SEL_LED);
	
	return;
}

void setSupplyVoltage(int SiPM_no, uint16_t val){
	if ( (SiPM_no < 0) || (SiPM_no > 1) ) return ;	
	// start communication
	SPI_PORT &= ~(1 << SPI_CS1);
	// create a writethrough header, DAC0 = SiPM_A, DAC1 = SiPM_B
	uint8_t header = 0x30 | (1 << SiPM_no); 
	SPI_sendByte(header);
	SPI_sendByte( 0xFF & (val >> 8) );	
	SPI_sendByte( 0xFF & val );	
	// communication finished! 
	SPI_PORT |= (1 << SPI_CS1);		
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

float getTemperature(uint16_t temperature){
	return ( TGain*temperature + TOff ); 
}

uint16_t getVopAdjusted(int SiPM_no, float temperature){
	// return the operation voltage in 5mV steps
	if (SiPM_no == SIPM_A)
		return (uint16_t)(( Vcoef*(temperature - 25.) + VopA )/5.);
	if (SiPM_no == SIPM_B)
		return (uint16_t)(( Vcoef*(temperature - 25.) + VopB )/5.);
	// neither SIPM_A, nor SIPM_A = ERROR!
	return -1;
}

void adjustVoltages(void){
	uint16_t adc_counts, dac_counts;
	// read the Temperature
	adc_counts = ADC_read(TEMP_PIN);
	// calculate DAC value 
	dac_counts = 5. * (getVopAdjusted(SIPM_A, getTemperature(adc_counts)) - DACOffA/5.)/DACGainA;	// VopAdj in 5mV/count, DACOffA not!!		
	setSupplyVoltage(SIPM_A, dac_counts);
	
	dac_counts = 5. * (getVopAdjusted(SIPM_B, getTemperature(adc_counts)) - DACOffB/5.)/DACGainB;		
	setSupplyVoltage(SIPM_B, dac_counts);
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
	sendDriver();
	// send one byte via usart
	USART_sendByte(c);
	wait_ms(2);	
	return;
}

void sendString(char* str){
	char* ptr = str;
	int len = 0;
	sendDriver();
	while(*ptr != '\0'){	// '\0' is the string termination character
		USART_sendByte(*ptr);
		ptr++;
		len++;
	}
	wait_ms(2*len);
	return;
}

	/* interrupt service routine */

ISR(USART_TX_vect){
	// transmission is complete, time to turn off the driver
	receiveDriver();
}
