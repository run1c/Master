#include <Adafruit_MotorShield.h>
#include <Wire.h>
#include "utility/Adafruit_PWMServoDriver.h"

#define MOVE 'm'
#define HOLD 'h'
#define RELEASE 'r'
#define GET_POS 'p'
#define SET_POS 's'

#define CMD_DELIMITER ':'
#define CMD_ERROR '?'
#define EOM "*\n"

#define STEPPER_SPEED 50

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

bool is_interrupt = false;	// is set when an interrupt happens
char cbuf;			// char buffer...
int nMotor = 0;
int nSteps = 0;			// stores the no of steps to go
int curSteps[2] = {0, 0};	// stores current position in steps

void setup() {
	// serial communication @ 9600 BAUD
	Serial.begin(9600);
	motor_shield.begin();
	stepper1->setSpeed(STEPPER_SPEED);
	stepper2->setSpeed(STEPPER_SPEED);
  	flushBuffer();
}

void loop() {

	/* 
	 *	command format ':<motor no><command>[<value>]'
	 */
	// check if theres data to be read
	if ( Serial.available() ){
		cbuf = Serial.read();
		if (cbuf == CMD_DELIMITER){
			// command delimiter has to be followed by a motor number
			nMotor = readInt();
			if ( (nMotor != 0) && (nMotor != 1) )	// should be 0 or 1
				goto fail;	// no exceptions in C, so a goto will have to do..
			// next byte should be a command
			cbuf = readByte();
			switch(cbuf){  // which command?
			case MOVE:  // we need another integer!
				nSteps = readInt(false);
				Serial.print(moveSteps(nMotor, nSteps));
				Serial.print(EOM);
				break;
			case HOLD:
				holdStepper(true);
			  	Serial.print(EOM);
			  	break;
			case RELEASE:
			  	holdStepper(false);
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
			default:  // command not understood
			 	fail: failed();
      			}
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
	Serial.print(CMD_ERROR);
	Serial.print(EOM);
	flushBuffer();
	return;
}

int moveSteps(int iMotor, int iSteps){
	int dir = 0, mult = 1;
	Adafruit_StepperMotor* cur_stepper;

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
	if (iMotor == 0) cur_stepper = stepper1;
	if (iMotor == 1) cur_stepper = stepper2;

	// do single steps to count every single step
	int i; 
	for (i = 0; i < iSteps; i++){
	  	cur_stepper->onestep(dir, DOUBLE);
		delay(10);
		if (is_interrupt) break;	// if an interrupt happened, stop moving
		curSteps[iMotor] += 1*mult;
	}  
	// return actual number of steps taken
	return i*mult;
}

void holdStepper(bool hold){
	// TODO: hold & release..
	// maybe add a bool which is checked, after every movement
  	return;
}
