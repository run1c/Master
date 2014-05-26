#include <stdio.h>
#include <iostream>
#include <math.h>
#include <sstream>
#include <fstream>
#include <ctime>

// liblab
#include <rs232/linux_rs232.h>
#include <rs232/RWTH/SiPM/rs232_SiPM.h>
#include <rs232/RWTH/SiPM/MPPC_D/MPPC_D.h>

// ROOT
#include <TFile.h>
#include <TTree.h>
#include <TF1.h>
#include <TGraphErrors.h>

#include "CooliHandler.h"

#define SIPM_COM "/dev/ttyUSB0"

using namespace std;

int main(int argc, char** argv){
	uint16_t fe_addr = 0xFF;
	stringstream ssBuf, sName;
	int nSteps, nMeas;
	float tStart, tStop;

	if (argc != 6){
		printf("Usage: ./temperature_cal <fe address> <start temperature> <stop temperature> <no points> <no measurements per point>\n");
		printf("\te.g.: ./temperature_cal 1F 0 25 10 1000\n");
		return -1;
	} else {
		ssBuf << argv[1];
		ssBuf >> hex >> fe_addr;
		tStart = atof(argv[2]);
		tStop = atof(argv[3]);
		nSteps = atoi(argv[4]);
		nMeas = atoi(argv[5]);
	}
	

	/* MPPC_D setup */

	linux_rs232 usb_sipm(SIPM_COM, 9600);
	rs232_SiPM apdpi(&usb_sipm, 9600);
	MPPC_D fe(&apdpi, fe_addr);	

	printf("[Temp Cal] - Calibration for controller 0x%02X.\n", fe_addr);

	float cur_temp = 0.,
	      temp_per_step = (tStop - tStart)/(float)nSteps;
	uint16_t adc_count = 0;		// 10 bit adc register
	double mean_adc = .0,
	      mean_adc2 = .0,
	      adc_err = .0;
	stringstream ssbuf;
	unsigned long int time0 = time(0), cur_time;	// seconds since 01 Jan 1970 (UNIX time)
	int timestamp;

	/* init output - root stuff */
	sName << "TempCal_mod0x" << hex << fe_addr << ".root";
	TFile* out_file = new TFile(sName.str().c_str(), "RECREATE");
	TTree* out_tree = new TTree("temp_cal", "temp_cal");
	out_tree->Branch("temperature", &cur_temp);
	out_tree->Branch("adc_count", &adc_count);
	out_tree->Branch("nMeas", &nMeas);
	out_tree->Branch("nSteps", &nSteps);
	out_tree->Branch("timestamp", &timestamp);

	sName.str("");
	sName << "TempCal_mod0x" << hex << fe_addr << ".txt";
	ofstream result(sName.str().c_str(), ofstream::out);

	TGraphErrors* cal_gr = new TGraphErrors();
	TF1* cal_fit = new TF1("cal_fit", "[0] + [1]*x");

	CooliHandler cooli;

	for (int iStep = 0; iStep < nSteps; iStep++){
		mean_adc = 0.;
		mean_adc2 = 0.;
		cur_temp = tStart + temp_per_step*iStep;
		ssbuf << cur_temp;  
		printf("[Temp Cal] - Setting temperature to %s deg C...\n", ssbuf.str().c_str());

		// set temperature
		cooli.setTemperature(ssbuf.str());
		// wait for setting...
		while (!cooli.isReady(ssbuf.str())){ 
			printf("[Temp Cal] - Waiting for cooli to @%.2fdegC/%sdegC ...\n", cooli.getTemperature(), ssbuf.str().c_str());
			sleep(60); 
		};
	
		// take measurements
		for (int iMeas = 0; iMeas < nMeas; iMeas++){
			adc_count = fe.get_temperature_raw();
			cur_time = time(0);
			timestamp = cur_time - time0;
			out_tree->Fill();
			cout << (float)iMeas/(float)nMeas*100. << "%\r" << flush;				
			mean_adc += adc_count;	
			mean_adc2 += pow(adc_count, 2);
		}
		mean_adc /= (double)nMeas;
		mean_adc2 /= (double)nMeas;
		adc_err = sqrt( mean_adc2 - pow(mean_adc, 2) );

		cal_gr->SetPoint(iStep, cur_temp, mean_adc);
		cal_gr->SetPointError(iStep, 0., adc_err);

		printf("[Temp Cal] - measured (%4.1f+-%1.4f) adc counts.\n", mean_adc, adc_err);	
	}

	// quiet plx!
	cal_gr->Fit(cal_fit, "Q");
	cal_gr->Write();

	double temp_offset = cal_fit->GetParameter(0),
	       temp_offset_err = cal_fit->GetParError(0),
	       temp_gain = cal_fit->GetParameter(1),
	       temp_gain_err = cal_fit->GetParError(1);

	printf("[Temp Cal] - Calibration result: gain=(%1.5f+-%1.5f)counts/degC, offset=(%2.3f+-%2.3f)counts\n", temp_gain, temp_gain_err, temp_offset, temp_offset_err);
	
	result << "# temperature calibration 0x" << hex << fe_addr << endl; 
	result << "temperature gain\t" << temp_gain << endl;
	result << "temperature gain err\t" << temp_gain_err << endl;
	result << "temperature offset\t" << temp_offset << endl;
	result << "temperature offset err\t" << temp_offset_err << endl;

	// cleanup
	out_tree->Write();
	out_file->Close();
	result.close();
	return 0;
}
