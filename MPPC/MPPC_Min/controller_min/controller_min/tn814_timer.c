#include "tn841_timer.h"

volatile uint8_t __tick = 0;		// tick counts the number of overflow interrupts
volatile int __milliseconds = 0;	// number of milliseconds

void timer_init(void){
	TCCR0A = 0x00;			// no OCA	
	TCCR0B = (1 << CS00);	// no prescaler
	TIMSK0 |= (1 << TOIE0);	// time overflow interrupt enabled

	TCNT0 = 0x00;
	
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