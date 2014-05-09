#include "m88pa_adc.h"

void ADC_init(){
	ADMUX = (1 << REFS1) | (1 << REFS0);	// use internal 1.1V reference and ADC0 (PORTC0) as analog output 
	DIDR0 = (1 << ADC0D);			// disable ADC0's digital buffer (reduces power consumption)
	ADCSRA = (1 << ADPS2) | (1 << ADPS1);	// ADC prescaler = 64
	ADCSRA |= (1 << ADEN);			// enable ADC

	uint16_t dummy = ADC_read(0);		// init readout

	return;
}

uint16_t ADC_read(int adc_chan){
	uint16_t ret;
	// select channel
	ADMUX = (ADMUX & ~0x0F) | (adc_chan & 0x0F);
	ADCSRA |= (1 << ADSC);			// start conversion and clear interrupt flag
	while ( ADCSRA & (1 << ADSC) ){};	// wait until conversion is complete

	ret = ADCL;		// low byte (has to be read first to block further writing to ADCH)
	ret += (ADCH << 8);	// high byte
	return ret;	 
}
