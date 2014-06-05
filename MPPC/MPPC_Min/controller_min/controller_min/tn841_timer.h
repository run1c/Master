/*
 * tn841_usart.h
 *
 * Created: 04/06/2014 14:13:10
 *  Author: run1c
 */ 


#ifndef TN841_TIMER_H_
#define TN841_TIMER_H_

#include <avr/io.h>
#include <avr/interrupt.h>

// initialize all timers (two 16 bit, one 8 bit)
void timer_init(void);

// well... guess what this function does
void sleep_ms(int ms);

#endif /* TN841_TIMER_H_ */