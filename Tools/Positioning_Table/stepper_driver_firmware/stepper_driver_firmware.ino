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

// read one byte, but only there is something to be read!
int readByte(bool echo = true);  
// parse the next integer number, if one is there
int readInt(bool echo = true);  
// empty serial buffer
void flushBuffer();
// command or character could not be identified
void failed();  
// move a certain number of steps
int moveSteps(int iMotor, int iSteps); 
// hold or release the stepper motor coils
void holdStepper(bool hold);

// create motor shield object
Adafruit_MotorShield motor_shield = Adafruit_MotorShield();
// get two stepper motors (200 steps per revelation)
Adafruit_StepperMotor* stepper1 = motor_shield.getStepper(200, 1);
Adafruit_StepperMotor* stepper2 = motor_shield.getStepper(200, 2);

Adafruit_StepperMotor* cur_stepper;	// current stepper in motion, needed for interrupts 
bool is_interrupt = false;		// is set when an interrupt happens
bool stepper_hold = false;		// send current pulses to hold coil position (increases power consumption)
char cbuf;				// char buffer...
int nMotor = 0;
int nSteps = 0;				// stores the no of steps to go
int curSteps[2] = {0, 0};		// stores current position in steps
const int correctionSteps = 100;	// no of steps to step back after hitting a kill switch 

uint8_t old_int = 0x00, new_int = 0x00;	// stores status of pin change interrupts

void setup() {
	// serial communication @ 9600 BAUD
	Serial.begin(9600);
	motor_shield.begin();
	stepper1->setSpeed(STEPPER_SPEED);
	stepper2->setSpeed(STEPPER_SPEED);
  	flushBuffer();
  
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
}

void loop() {

	/* 
	 *	command format ':<motor no><command>[<value>]'
	 */

	// check if theres data to be read
	if ( Serial.available() ){
                digitalWrite(LED_DATA, HIGH);
		cbuf = Serial.read();
		if (cbuf == CMD_DELIMITER){
			// command delimiter has to be followed by a motor number
			nMotor = readInt();
			if ( (nMotor != 0) && (nMotor != 1) )	// should be 0 or 1
				failed();
			// next byte should be a command
			cbuf = readByte();
        		digitalWrite(LED_DATA, LOW);
			switch(cbuf){  // which command?
			case MOVE:  // we need another integer!
				nSteps = readInt(false);
				Serial.print(moveSteps(nMotor, nSteps));
				Serial.print(EOM);
				break;
			case HOLD:
				stepper_hold = true;
			  	Serial.print(EOM);
			  	break;
			case RELEAS:
				stepper_hold = false;
			  	Serial.print(EOM);
			  	break;
			case GET_POS:
			  	Serial.print(curSteps[nMotor], DEC);
			  	Serial.print(EOM);
			  	break;
			case SET_POS:
			  	curSteps[nMotor] = readInt();
			  	Serial.print(EOM);
			  	break;
			case PC_INT:
				Serial.print(PINB, HEX);
			  	Serial.print(EOM);
			  	break;
			default:  // command not understood
			 	failed();
      			}
    		} else {
			//failed();
        		digitalWrite(LED_DATA, LOW);
  		}
	} 
}

int readByte(bool echo){
	char buf = 0;
	while ( !(Serial.available()) ){}  // wait until received byte

	buf = Serial.read();
	if (echo) Serial.print(buf);
	return buf;
}

int readInt(bool echo){
	int buf = 0;
	while ( !(Serial.available()) ){}  // wait until received byte

	buf = Serial.parseInt();
	if (echo) Serial.print(buf);
	return buf;  
}

void flushBuffer(){
	int dummy;
	// read all data, until buffer is empty
	while ( Serial.available() ){
	  	dummy = Serial.read();
	}

	return;
}

void failed(){
	flushBuffer();
	Serial.print(CMD_ERROR);
	Serial.print(EOM);
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
