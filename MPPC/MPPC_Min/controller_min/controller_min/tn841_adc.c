/*
 * tn841_adc.c
 *
 * Created: 05/06/2014 14:46:05
 *  Author: run1c
 */ 

#include "tn841_adc.h"

void ADC_init(void){
	// set ADC11 (PB0) as single ended adc input
	ADMUXA = (1 << MUX0) | (1 << MUX1) | (1 << MUX3);
	// disable digital buffer for PB0 (not needed and saves power)
	DIDR1 = (1 << ADC11D);
	// select internal 1V1 reference & gain to 1
	ADMUXB = (1 << REFS0);
	// set adc clock prescaler to 64
	ADCSRA = (1 << ADPS2) | (1 << ADPS1);
	// enable adc
	ADCSRA |= (1 << ADEN );
	return;	
};

uint16_t ADC_read(void){
	uint16_t ret = 0x00;
	// start conversion
	ADCSRA |= (1 << ADSC);
	// wait until conversion has finished (ADSC cleared)
	while ( ADCSRA & (1 << ADSC) ){};

	// reading of ADCL will block new conversion to avoid readout errors
	ret = ADCL;
	ret += ( ADCH << 8);
	return ret;
}