#include <fstream>
#include <stdio.h>
#include <sstream>
#include <math.h>
#include <iomanip> 	// setprecision

// unix
#include <unistd.h>
#include <stdint.h>

// liblab
#include <rs232/linux_rs232.h>
#include <rs232/KEITHLEY/SourceMeter_2400/KEITHLEY_SourceMeter_2400.h>
#include <rs232/RWTH/SiPM/rs232_SiPM.h>
#include <rs232/RWTH/SiPM/MPPC_D/MPPC_D.h>

// ROOT
#include <TFile.h>
#include <TTree.h>
#include <TGraphErrors.h>
#include <TF1.h>

#define SIPM_COM "/dev/ttyUSB1"
#define KEITHLEY_COM "/dev/ttyUSB0"

using namespace std;

void print_usage();

int main(int argc, char** argv){

	// input variables	
	int start_DAC, stop_DAC, nSteps, nMeas;
	uint16_t fe_addr = 0xFF; 
	stringstream ssBuf;
	char sipm_no = 'X';

	if (argc < 3){			// FE address and sipm number have to be specified!
		print_usage();
		return -1;
	} else {
		ssBuf << argv[1];
		ssBuf >> hex >> fe_addr;
		sipm_no = argv[2][0];
		if ( !(sipm_no == 'A' || sipm_no =='B') ) {
			printf("[DAC Cal] - SiPM number has to be 'A' or 'B'!\n");
			return -1;
		}

		if (argc == 3) {	// default setup
			start_DAC = 0;
			stop_DAC = 60000;
			nSteps = 10;
			nMeas = 3;	
		} else if (argc < 7) {
			print_usage();
			return -1;
		} else if (argc < 8) {
			start_DAC = atoi(argv[3]);
			stop_DAC = atoi(argv[4]);
			nSteps = atoi(argv[5]);
			nMeas = atoi(argv[6]);
		}
	}

	printf("[DAC cal] - Setup: FE addr 0x%02X SiPM %c; DAC %i-%i in %i steps with %i measurements.\n", fe_addr, 'B', start_DAC, stop_DAC, nSteps, nMeas);

	/* MPPC_D setup */

	linux_rs232 usb_sipm(SIPM_COM, 9600);
	rs232_SiPM apdpi(&usb_sipm, 9600);
	MPPC_D fe(&apdpi, fe_addr);	

	/* 
	 * 	turn on calibration mode:
	 * 	This command will set DACOff=0, DACGain=1 and dU/dT=0
	 * 	thus the DAC registers can be accessed directly with
	 * 	'Axxxx'/'Bxxxx' to 5*xxxx
	 */

	apdpi.read_value(fe_addr, "Q");	
	printf("[DAC Cal] - Set MPPC_D to calibration mode.\n"); 
	if (sipm_no == 'A') fe.set_bias_voltage_at_25_degree_A(0);
	if (sipm_no == 'B') fe.set_bias_voltage_at_25_degree_B(0);
	printf("[DAC Cal] - Set DAC to 0.\n"); 

	/* sourcemeter setup */

	linux_rs232 usb_keithley(KEITHLEY_COM, 57600);
	KEITHLEY_SourceMeter_2400 source_meter(&usb_keithley, KEITHLEY_SourceMeter_2400::KEITHLEY_M2400);
	// no outputs needed, we only want to measure voltages
	source_meter.TurnOutputOff();
	source_meter.RestoreGPIBDefaults();	// reset
	source_meter.SelectFrontTerminals();
	source_meter.Select2WireSenseMode();
	// set to current source with no amplitude
	source_meter.SelectCurrentSourceFunction();
	source_meter.SelectFixedCurrentSourcingMode();
	source_meter.SelectCurrentMeasurementRange(.1);
	source_meter.SetSourceCurrentAmplitude(.0);
	// we will calibrate from 60V-80V
	source_meter.SelectVoltageMeasureFunction();
	source_meter.SelectVoltageMeasurementRange(80.);
	source_meter.SetVoltageCompliance(100.);
	// everything is configured
	usleep(1e3);
	source_meter.TurnOutputOn();
	printf("[DAC Cal] - Source meter configured.\n"); 
	usleep(1e6);

	/* output setup - root files */

	int cur_DAC = 0;
	float DAC_per_step = (float)(stop_DAC - start_DAC)/(float)nSteps;
	
	double voltage = .0,
	       mean_voltage,	// <U>
	       mean_voltage2,	// <U²>
	       voltage_err;	// sigma² = <U²> - <U>²

	stringstream sName;
	sName.str("");
	sName << "CAL_0x" << hex << fe_addr << "_SiPM_" << sipm_no << ".root";
	TFile* out_file = new TFile(sName.str().c_str(), "RECREATE");
	TTree* out_tree = new TTree("cal_tree", "calibration");
	out_tree->Branch("voltage_mV", &voltage);
	out_tree->Branch("DAC_counts", &cur_DAC);
	out_tree->Branch("n_measurements", &nMeas);
	out_tree->Branch("n_steps", &nSteps);

	TGraphErrors* cal_gr = new TGraphErrors();
	cal_gr->SetTitle(";DAC counts;U[mV]");
	TF1* cal_fit = new TF1("cal fit", "[0] + [1]*x", start_DAC, stop_DAC);	

	// and now what we would like to know..
	double DAC_gain, DAC_gain_err,
	       DAC_offset, DAC_offset_err;
	sName.str("");
	sName << "CAL_0x" << hex << fe_addr << "_SiPM_" << sipm_no << ".txt";
	ofstream result(sName.str().c_str(), ofstream::out);

	/* Start calibration */
	for (int iStep = 0; iStep < nSteps; iStep++){
		mean_voltage = 0;
		mean_voltage2 = 0;
		voltage_err = 0;

		/*
		 *	In calibration mode 'Q' the DAC registers on the FE can be directly written to
		 *	with the command 'Axxxx' or 'Bxxxx'. The DAC registers will then be set to 5*xxxx.
		 *	-> divide by 5, also multiply by 0.005, because the number will be internally mutliplied
		 * 	by 0.005 by the MPPC_D class
		 */

		cur_DAC = start_DAC + DAC_per_step*iStep;
		if (sipm_no == 'A') fe.set_bias_voltage_at_25_degree_A(cur_DAC*0.001);
		if (sipm_no == 'B') fe.set_bias_voltage_at_25_degree_B(cur_DAC*0.001);
		printf("[DAC Cal] - DAC %i\r", cur_DAC);

		for (int iMeas = 0; iMeas < nMeas; iMeas++){
			// voltage in mV
			voltage = 1000.*source_meter.getVoltageReading();
			mean_voltage += voltage;
			mean_voltage2 += pow(voltage, 2);
			out_tree->Fill();
			cout << "\t\t\t\t... " << setprecision(3) << (float)iMeas/(float)nMeas*100. << "%\r" << flush;
		}

		// calculate mean, mean² and sigma
		mean_voltage /= nMeas;
		mean_voltage2 /= nMeas;
		voltage_err = sqrt( mean_voltage2 - pow(mean_voltage, 2) );
		
		printf("\t\t\t(%5.2f+-%5.2f)mV\n", mean_voltage, voltage_err);

		// fill data into graph (voltage in mV and DAC to real DAC counts)
		cal_gr->SetPoint(iStep, (double)cur_DAC, mean_voltage);
		cal_gr->SetPointError(iStep, 1., voltage_err);
	}

	// fit for final result
	cal_gr->Fit(cal_fit, "Q");
	DAC_offset = cal_fit->GetParameter(0);
	DAC_offset_err = cal_fit->GetParError(0);
	DAC_gain = cal_fit->GetParameter(1);
	DAC_gain_err = cal_fit->GetParError(1);

	printf("[DAC Cal] - gain = (%1.5f+-%1.5f)mV/DAC count\n", DAC_gain, DAC_gain_err);
	printf("[DAC Cal] - offset = (%4.2f+-%4.2f)DAC counts\n", DAC_offset, DAC_offset_err);

	result << "# DAC calibration 0x" << hex << fe_addr << " SiPM " << dec << sipm_no << " #" << endl;
	result << "DAC gain\t" << DAC_gain << endl;
	result << "DAC gain err\t" << DAC_gain_err << endl;
	result << "DAC offset\t" << DAC_offset << endl;
	result << "DAC offset err\t" << DAC_offset_err << endl;

	printf("[DAC Cal] - Results written to '%s'!\n", sName.str().c_str());

	cal_gr->Write();
	out_tree->Write();

	// cleanup
	source_meter.TurnOutputOff();
	out_file->Close();
	result.close();
	return 0;
}

void print_usage(){
	printf("Usage: ./dac_cal <FE address> <SiPM name> [optional: <start DAC> <stop DAC> <no of steps> <no of points per step>]\n");
	printf("\te.g.: ./dac_cal 1F A 30000 60000 20 10\n");
	return;
}
