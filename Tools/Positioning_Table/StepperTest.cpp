#include <stdio.h>
#include <unistd.h>

#include <rs232/linux_rs232.h>
#include <rs232/RWTH/StepperController/StepperController.h>

#define COM "/dev/ttyACM0"
#define MOTOR 1

int main(){
	linux_rs232 port(COM, 9600);
	StepperController stepper(&port);
	// drive into kill switch

	for (int iMotor = 0; iMotor < 2; iMotor++){
		stepper.hold(iMotor, true);
		stepper.move(iMotor, 30000);
		stepper.hold(iMotor, false);
		stepper.setPosition(iMotor, 0);

		int steps = stepper.move(iMotor, -5000);
		if (stepper.getPosition(iMotor) == steps){
			printf("*** Success! ***\n");
		} else {
			printf("*** Failed! ***\n");
		}
	}

	return 0;
}
