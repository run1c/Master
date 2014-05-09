#include "m88pa_timer.h"

// global timer variables, needed be wait_ms
volatile uint8_t tick = 0;
volatile uint16_t milliseconds = 0;

void timer_setup(void){
	
	/* Timer setup (required for sleep() etc. ...) */

	TCCR0A = 0x00;			// no PWM, no output compare match
	TCCR0B = (1 << CS00);		// prescaler = 1
	TIMSK0 |= (1 << TOIE0);		// timer/counter overflow interrupt enabled

	/* an interrupt will occur every 256us ! */
	return;
}


void wait_ms(uint16_t mil_sec){		// pretty selfexplanaroty
	while (milliseconds < mil_sec){};
	milliseconds = 0;
	return;
}

	/* Interrupt Service Routines */

ISR(TIMER0_OVF_vect){
	tick++;			// interrupt occurs every ~250us
	if (tick == 4){		// -> 1ms elapses every 4 interrupts
		milliseconds++;
		tick = 0;
	}	
}
