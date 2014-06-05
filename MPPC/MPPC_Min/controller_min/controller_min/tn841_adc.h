/*
 * tn841_adc.h
 *
 * Created: 05/06/2014 14:45:39
 *  Author: run1c
 */ 

#include <avr/io.h>

#ifndef TN841_ADC_H_
#define TN841_ADC_H_

void ADC_init(void);

uint16_t ADC_read(void);

#endif /* TN841_ADC_H_ */