#include "tn841_timer.h"

volatile uint8_t __tick = 0;		// tick counts the number of overflow interrupts
volatile int __milliseconds = 0;	// number of milliseconds


void timer_init(void){

	/*
	 *	8 bit timer TIMER0 setup for sleep_XX methods
	 */

	TCCR0A = 0x00;		// no OCA	
	TCCR0B = (1 << CS00);	// no prescaler
	TIMSK0 |= (1 << TOIE0);	// time overflow interrupt enabled

	TCNT0 = 0x00;

	/*
	 *	16 bit timer TIMER1 setup for PWM 
	 */
	
	TCCR1A = (1 << COM1A1);	// non inverting pwm
	TCCR1A |= (1 << WGM11);	// fast pwm, TOP = ICR1
	TCCR1B = (1 << WGM12) | (1 << WGM13);
	TCCR1B |= (1 << CS10);	// prescaler N = 1 

	TCNT1 = 0x0000;
	
	OCR1A = 0x0000;	// sets the duty cycle of the signal -> PWM off
	ICR1 = 0x07FF;	// 1 period = counting from 0 to 2^11
	
	// set multiplexer to output OC1A to TOCC7
	DDRB |= (1 << PORTB2);	// PB2 = TOCC7 output
	TOCPMSA1 = (1 << TOCC7S0);
	TOCPMCOE = (1 << TOCC7OE);	// enable output

	return;
}

void sleep_ms(int ms){
	__tick = 0;
	__milliseconds = 0;
	while (__milliseconds < ms){};
	return;
}

ISR(TIMER0_OVF_vect){
	__tick++;				// 1MHz clock, prescaler 1, 8 bit counter => 1e-6s/tick * 2^8-1 = every 2.55e-4s 1 interrupt
	if (__tick == 4){		// 1 tick every 0.255ms -> about every four ticks 1ms
		__tick = 0;
		__milliseconds++;
	}
}
