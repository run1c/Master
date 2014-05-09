#ifndef M88PA_TIMER_H
#define M88PA_TIMER_H

#include <avr/io.h>
#include <avr/interrupt.h>

/* 	Timer methods 	*/

// set up 8 bit timer with overflow interrupt
void timer_setup(void);	

// wait some milliseconds (via timer) 
void wait_ms(uint16_t mil_sec);

#endif
