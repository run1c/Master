#include <Adafruit_MotorShield.h>
#include <Wire.h>
#include "utility/Adafruit_PWMServoDriver.h"

// commands
#define MOVE 	'm'
#define HOLD 	'h'
#define RELEAS 	'r'
#define GET_POS 'p'
#define SET_POS 's'
#define PC_INT	'i'

#define CMD_DELIMITER 	':'
#define CMD_ERROR 	'?'
#define EOM 		"*\n"
#define MAX_LENGTH	6

// front leds
#define LED_MOTOR_X  	7
#define LED_MOTOR_Y  	6
#define LED_DATA  	8
#define LED_KILL_X  	4
#define LED_KILL_MX  	5
#define LED_KILL_Y  	3  
#define LED_KILL_MY  	2

// kill switch pins
#define PIN_KILL	PINB
#define PIN_KILL_X	PORTB1
#define PIN_KILL_MX	PORTB2
#define PIN_KILL_Y	PORTB4
#define PIN_KILL_MY	PORTB3

#define STEPPER_SPEED 	50
#define SINGLE_STEP_DELAY 5

/*
 *	Stepper motor control
 */

// move a certain number of steps
int moveSteps(int iMotor, int iSteps); 
// hold or release the stepper motor coils
void holdStepper(bool hold);

/*
 *	Serial communication
 */


// convert an ASCII string into an integer
int ASCIItoInt(char* str, int digits);
// convert interger to 5 digit ASCII string with sign
void InttoASCII(char* str, int in);
// send single ASCII character
void UART_sendByte(char c);
// send ASCII string terminated with '\0'
void UART_sendString(char* s);
// checks for data in RX buffer
uint8_t UART_dataAvaliable(void);
// read RX buffer
char UART_readByte(void);
// clear RX buffer
void UART_flush();
// wait for one byte to be read
char UART_receiveByte(void);
// wait for a string of given length
void UART_receiveString(char* str, int len);
// command or character could not be identified
void failed(); 

// create motor shield object
Adafruit_MotorShield motor_shield = Adafruit_MotorShield();
// get two stepper motors (200 steps per revelation)
Adafruit_StepperMotor* stepper1 = motor_shield.getStepper(200, 1);
Adafruit_StepperMotor* stepper2 = motor_shield.getStepper(200, 2);

/*
 *	Global variables stuff
 */

Adafruit_StepperMotor* cur_stepper;	// current stepper in motion, needed for interrupts 
bool is_interrupt = false;		// is set when an interrupt happens
bool stepper_hold = false;		// send current pulses to hold coil position (increases power consumption)
char cbuf;				// char buffer...
char sbuf[6];				// string buffer
int ibuf;
int nMotor = 0;
int nSteps = 0;				// stores the no of steps to go
int curSteps[2] = {0, 0};		// stores current position in steps
const int correctionSteps = 100;	// no of steps to step back after hitting a kill switch 

uint8_t old_int = 0x00, new_int = 0x00;	// stores status of pin change interrupts

void setup() {
	// init motor shield
	motor_shield.begin();
	stepper1->setSpeed(STEPPER_SPEED);
	stepper2->setSpeed(STEPPER_SPEED);
 
        // set up leds
	pinMode(LED_MOTOR_X, OUTPUT);
	pinMode(LED_MOTOR_Y, OUTPUT);
	pinMode(LED_DATA, OUTPUT);
	pinMode(LED_KILL_X, OUTPUT);
	pinMode(LED_KILL_MX, OUTPUT);
	pinMode(LED_KILL_Y, OUTPUT);
	pinMode(LED_KILL_MY, OUTPUT);

	// set all kill switches to input
	DDRB &= ~( (1 << PIN_KILL_X) | (1 << PIN_KILL_MX) | (1 << PIN_KILL_Y) | (1 << PIN_KILL_MY) );

	// uart setup
	UCSR0A = (1 << U2X0);	// double transmission speed
	UCSR0B = (1 << RXEN0) | (1 << TXEN0);	// enable receiver and transmitter
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);	// uart, 8n1 encoding
	UBRR0H = 0x00;	
	UBRR0L = 0xCF;	// 9600 baud @ 16 MHz	
}

void loop() {

	/* 
	 *	command format ':<motor no><command>[<value>]'
	 */
	
	fail:	// serial communication failed
        digitalWrite(LED_DATA, LOW);
	
	// check for incoming data
	if ( UART_dataAvaliable() ){
                digitalWrite(LED_DATA, HIGH);
	
		// command delimiter expected	
		cbuf = UART_receiveByte();
		if (cbuf != CMD_DELIMITER) { 
			failed();
			goto fail; 
		}

		// motor number expected
		cbuf = UART_receiveByte();
		if ( (cbuf != '0') && (cbuf != '1') ) { 
			failed();
			goto fail; 
		}
		nMotor = cbuf & 0x03;		// get 0 or 1 from ASCII character
		UART_sendByte(nMotor + '0');	// echo actual chacter

		// command expected
		cbuf = UART_receiveByte();
        	digitalWrite(LED_DATA, LOW);
		switch(cbuf){
		case MOVE:
			UART_sendByte(cbuf);	
			// 6 more bytes (number of steps to move)	
			UART_receiveString(sbuf, MAX_LENGTH);
			ibuf = moveSteps( nMotor, ASCIItoInt(sbuf, MAX_LENGTH) );			
			// echo steps done
			InttoASCII(sbuf, ibuf);
			UART_sendString(sbuf);

			UART_sendString(EOM);
			break;
		case HOLD:
			UART_sendByte(cbuf);	
			stepper_hold = true;
			UART_sendString(EOM);
			break;
		case RELEAS:
			UART_sendByte(cbuf);	
			stepper_hold = false;
			UART_sendString(EOM);
			break;
		case GET_POS:
			UART_sendByte(cbuf);
			// send current steps...	
			InttoASCII(sbuf, curSteps[nMotor]);
			UART_sendString(sbuf);
			UART_sendString(EOM);
			break;
		case SET_POS:
			UART_sendByte(cbuf);	
			// read and set position 
			UART_receiveString(sbuf, MAX_LENGTH);
			UART_sendString(sbuf);
			curSteps[nMotor] = ASCIItoInt(sbuf, MAX_LENGTH);
			UART_sendString(EOM);
			break;
		default:  // command not understood
			failed();
			goto fail;
		}
	}
}

// converts an ASCII string with 5 digits and sign to integer
//	e.g. "-00200" -> -200

int ASCIItoInt(char* str, int len){
	int ret = 0, pow = 1;
	char* ptr = str + len;
	// loop until sign
	while ( ptr != (str + 1) ) {
		ptr--;	
		ret += pow*( (*ptr) & 0x0F );
		pow *= 10;
	}
	// check sign
	if ( (*str) == '-' )
		ret *= -1;
	return ret; 
}

// converts an integer to ASCII string with 5 digits and sign
//	e.g. 100 -> "+00100"

void InttoASCII(char* str, int in){
	int dec = 10000; 	// max digits we need (arbitrary)
	int temp;

	// get sign
	if (in < 0){
		(*str) = '-';
		in *= -1;
	} else 
		(*str) = '+';

	str++;
	
	// get digits
	while ( dec > 0 ){
		temp = in/dec;
		(*str) = temp + '0';
		in -= temp*dec;
		dec /= 10;
		str++;
	}
	(*str) = '\0';		
}

void UART_sendByte(char c){
	// wait until data register is empty
	while ( !(UCSR0A & (1 << UDRE0)) ) {};
	UDR0 = c;	// send c

	return;
}

void UART_sendString(char* s){
	char* ptr = s;
	while ( (*ptr) != '\0' ){
		UART_sendByte( (*ptr) );
		ptr++;
	}

	return;
}

char UART_readByte(void){
	return UDR0;	
}

uint8_t UART_dataAvaliable(void){
	return ( UCSR0A & (1 << RXC0) );
}

char UART_receiveByte(void){
	while ( !( UART_dataAvaliable() ) ) {};
	return UART_readByte();
}

void UART_receiveString(char* str, int len){
	while ( len != 0 ){
		(*str) = UART_receiveByte();
		str++;
		len--;
	}
	// end of string
	(*str) = '\0';
}

void UART_flush(){
	int dummy;
	// read all data, until buffer is empty
	while ( UART_dataAvaliable ){
	  	dummy = UART_readByte();
	}

	return;
}

void failed(){
//	UART_flush();
	UART_sendByte(CMD_ERROR);
	UART_sendString(EOM);

	return;
}

int moveSteps(int iMotor, int iSteps){
	int mult = 1, led_pin; 
	uint8_t dir = 0x00, kill_status = 0x00;

	// get direction
	if (iSteps < 0){
	  	iSteps *= -1;
		mult = -1;
	  	dir = BACKWARD;
	} else {
		mult = 1;
	  	dir = FORWARD;
	}
	// get motor
	if (iMotor == 0){ 
          cur_stepper = stepper1;
          led_pin = LED_MOTOR_X;
        }
	if (iMotor == 1){ 
          cur_stepper = stepper2;
          led_pin = LED_MOTOR_Y;
        }

	// do single steps to count every single step
	int i;
	digitalWrite(led_pin, HIGH); 
	for (i = 0; i < iSteps; i++){
	  	cur_stepper->onestep(dir, DOUBLE);
		curSteps[iMotor] += 1*mult;	// +- 1 step
		delay(SINGLE_STEP_DELAY);

		// check if a kill switch was toggled
		kill_status = PIN_KILL & ( (1 << PIN_KILL_X) | (1 << PIN_KILL_MX) | (1 << PIN_KILL_Y) | (1 << PIN_KILL_MY) );
		if ( kill_status ){
			// turn leds on
			switch (kill_status){
			case ( (1 << PIN_KILL_X) ):
				digitalWrite(LED_KILL_X, HIGH);
				break;
			case ( (1 << PIN_KILL_MX) ):
				digitalWrite(LED_KILL_MX, HIGH);
				break;
			case ( (1 << PIN_KILL_Y) ):
				digitalWrite(LED_KILL_Y, HIGH);
				break;
			case ( (1 << PIN_KILL_MY) ): 
				digitalWrite(LED_KILL_MY, HIGH);
				break;
			default:
				break;
			}

			if (dir == FORWARD)	// FORWARD = 1, BACKWARD = 2...
				cur_stepper->step(correctionSteps, BACKWARD, DOUBLE);
			else
				cur_stepper->step(correctionSteps, FORWARD, DOUBLE);
			
			// take correction steps into account	
			i = (i- correctionSteps)*mult;
			curSteps[iMotor] -= correctionSteps*mult;	// -+ 10 steps

			// turn leds off again...
			digitalWrite(LED_KILL_X, LOW);
			digitalWrite(LED_KILL_MX, LOW);
			digitalWrite(LED_KILL_Y, LOW);
			digitalWrite(LED_KILL_MY, LOW);

			break;
		}
	}
	digitalWrite(led_pin, LOW); 
	if (!stepper_hold) cur_stepper->release();
	// return actual number of steps taken
	return i*mult;
}
