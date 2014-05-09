#ifndef M88PA_ADC_H
#define M88PA_ADC_H

#include <avr/io.h>
#include <avr/interrupt.h>

void ADC_init(void);

uint16_t ADC_read(int adc_pin);

#endif
