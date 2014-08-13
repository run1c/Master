#include <stdio.h>
#include <unistd.h>

#include <rs232/linux_rs232.h>
#include <rs232/RWTH/StepperController/StepperController.h>

#define COM "/dev/ttyACM0"
#define MOTOR 0

int main(){
	linux_rs232 port(COM, 9600);
	StepperController stepper(&port);
	// drive into kill switch
	stepper.hold(MOTOR, true);
	stepper.move(MOTOR, 30000);
	stepper.hold(MOTOR, false);
	stepper.setPosition(MOTOR, 0);

	int steps = stepper.move(MOTOR, -1000);
	if (stepper.getPosition(MOTOR) == steps){
		printf("*** Success! ***\n");
	} else {
		printf("*** Failed! ***\n");
	}
	
	return 0;
}
