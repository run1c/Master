// std c++
#include <stdlib.h>	// for rand()
#include <stdio.h>
#include <fstream>
#include <string>
#include <sstream>
// unix
#include <unistd.h>
#include <sys/time.h>
// liblab
#include <rs232/linux_rs232.h>
#include <rs232/RWTH/SiPM/rs232_SiPM.h>
#include <rs232/RWTH/SiPM/MPPC_D/MPPC_D.h>

#define USB "/dev/ttyUSB0"

#define BAUD 9600

// colours

#define PRED  "\x1B[31m"	// print red
#define PGRN  "\x1B[32m"	// print green	
#define PNRM  "\x1B[0m"		// print normal

using namespace std;

int main(int argc, char** argv){
	uint16_t fe_addr = 0xFF;
	char* dev_file;
	int nTries = 0;
	stringstream ssBuf;

	if (argc != 4){
		printf("Usage: ./bus_debugger <address> <device> <number of commands>\n\te.g. ./bus_debugger 1F /dev/ttyUBS1 1000\n");
		return -1;
	} else {
		ssBuf << argv[1];
		ssBuf >> hex >> fe_addr;
		dev_file = argv[2];	
		nTries = atoi(argv[3]);
	}

	// setup communication with frontend board
	linux_rs232 usb(dev_file, BAUD);
	rs232_SiPM sipm(&usb, BAUD);
	MPPC_D fe(&sipm, fe_addr);

	double dummy = .0, ex_time[7], avg_ex_time[7];
	string cmd_map[7] = {	"get Ubias_A",
				"get Ubias_B",
				"get Temp",
				"get dU/dT",
				"set Ubias_A",
				"set Ubias_B",
				"set dU/dT"};
	int err = 0, cmd = 0, last_cmd = 0, nCmd[7];
	struct timeval start, stop;	// for time logging
	bool retry = false;
	// error logging
	stringstream sName;
	sName << "log_" << time(0) << ".txt";
	ofstream err_log(sName.str().c_str(), ofstream::out);		
	err_log << "---- " << sName.str() << endl;
	fill_n(nCmd, 7, 0);
	for (int i = 0; i < nTries; i++){
		// if the command had to be resent due to an exception
		// use the old starting point
		if (!retry){ 
			gettimeofday(&start, NULL);
			cmd = rand()%7;		// execute a random command 
		}
		retry = true;	// will be set to false if no exception occurs
		try{
			switch (cmd){		
			// read commands
			case 0:	
				dummy = fe.get_temperature_adjusted_voltage_A();
				break;
			case 1:	
				dummy = fe.get_temperature_adjusted_voltage_B();
				break;
			case 2:	
				dummy = fe.get_temperature();
				break;
			case 3:	
				dummy = fe.get_progression_coefficient();
				break;
			// write commands
			case 4: 
				fe.set_bias_voltage_at_25_degree_A(60.);	
				break;
			case 5: 
				fe.set_bias_voltage_at_25_degree_B(60.);	
				break;
			case 6: 
				fe.set_bias_voltage_progression_coefficient(0.050);	
				break;
			}	

			// this section will only be reached if no exception occured
			retry = false;	
			nCmd[cmd]++;
			gettimeofday(&stop, NULL);

			// calc execution time for command
			ex_time[cmd] = stop.tv_sec - start.tv_sec + 1e-6*(stop.tv_usec - start.tv_usec);
			avg_ex_time[cmd] += ex_time[cmd];

			printf("%i - " PGRN "Success on '%s'" PNRM " - ret=%2.3f after %1.4fs...\n", i, cmd_map[cmd].c_str(), dummy, ex_time[cmd]);
		} catch (llbad_SiPM_interface &ex) {
			printf("%i - " PRED "Error on %s" PNRM " - ret=%2.3f after '%s'\n", i, cmd_map[cmd].c_str(), dummy, ex.what());
			err_log << err << " Error on " << cmd_map[cmd] << " after " << last_cmd << " '" << ex.what() << "'" << endl;
			err++;
		} catch (llbad_MPPC_D &ex) {
			printf("%i - " PRED "Error on %s" PNRM " - ret=%2.3f after '%s'\n", i, cmd_map[cmd].c_str(), dummy, ex.what());
			err_log << err << " Error on " << cmd_map[cmd] << " after " << last_cmd << " '" << ex.what() << "'" << endl;
			err++;
		} catch (...) {
			printf("%i - " PRED "Unknown error on %s" PNRM "\n", i, cmd_map[cmd].c_str());
			err_log << err << " Unknown error on " << cmd_map[cmd] << " after " << last_cmd << endl;
			err++;
		}
	}

	// logging
	err_log << "---- end" << endl;
	err_log << "nErrors=" << err << endl;
	err_log << "nTries=" << nTries << endl;
	
	printf("Received %i errors.\n", err);
	printf("Average command execution time:\n");
	for (int j = 0; j < 7; j++){
		avg_ex_time[j] /= nCmd[j];
		printf("\t%s\t%1.4fs (n=%i)\n", cmd_map[j].c_str(), avg_ex_time[j], nCmd[j]);
		err_log << cmd_map[j] << "\tt=" << avg_ex_time[j] << "\t(nCmd=" << dec << nCmd[j] << ")" << endl;
	}
	
	// average up and down data throughput
	float upStream = 4./avg_ex_time[4] + 4./avg_ex_time[5] + 2./avg_ex_time[6];
	float downStream = 4./avg_ex_time[0] + 4./avg_ex_time[1] + 7./avg_ex_time[2] + 2./avg_ex_time[3];

	printf("\tupStream=%f bytes/s\n\tdownStream=%f bytes/s\n", upStream, downStream);

	err_log.close();	
	return 0;
}
