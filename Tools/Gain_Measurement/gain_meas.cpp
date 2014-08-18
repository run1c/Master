// clib + unix
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>
#include <math.h>
// liblab
#include <rs232/linux_rs232.h>
#include <rs232/TEKTRONIX/TDS3000.h>
// root
#include <TH1F.h>
#include <TF1.h>
#include <TCanvas.h>
#include <TTree.h>
#include <TFile.h>

// colours
#define PRED  "\x1B[31m"	// print red
#define PGRN  "\x1B[32m"	// print green	
#define PNRM  "\x1B[0m"		// print normal

using namespace std;

// #define VERBOSE

// determines the baseline by fitting a line to the first n points of the histo
// slope and offset determine the quality of the fit
// (slope ~= 0, offset ~= 0)
float getBaseline(TH1F* histo, float start, float stop, float &slope, float &offset);

int main(int argc, char** argv){

	/*
	 *	I M P O R T A N T
	 * 	=================
	 * 	
	 * 	First you have to adjust the readout ON the scope itself! 
	 *	ACQUIRE -> MENU -> Horizontal Resolution -> Fast Trigger (500 Points)
	 *	Also the screen has to start @ -70ns and end @130ns (20ns per division)
	 */ 

	int nSamples = 0;
	float t_min = -70e-9, t_max = 130e-9;	// min and max time on the scope screen

	if (argc < 3){
		printf("Usage: ./gain_meas <nSamples> <filename> [<tmin in s> <tmax in s>]\n");
		printf("\te.g.: ./gain_meas 1000 test.root -70e-9 130e-9\n");
		return -1;
	} else if (argc == 3){
		nSamples = atoi(argv[1]);
	} else {
		printf("Usage: ./gain_meas <nSamples> <filename> [<tmin in s> <tmax in s>]\n");
		printf("\te.g.: ./gain_meas 1000 test.root -70e-9 130e-9\n");
		return -1;
	} 

	// serial port setup
	linux_rs232 com("/dev/ttyUSB2", 38400);
	TDS3000 scope(&com);

	printf("[Gain Measurement] - Init scope..\n");
 
	// scope setup
	const int sample_len = 500;	// or 10000 (slower...)
	scope.selectSource(TDS3000_CH1);
	scope.setRecordLength(sample_len);
	scope.setStartPoint(1);
	scope.setStopPoint(sample_len);
	scope.setWaveformDataWidth(TDS3000_8BIT);
	// measurement is set up, get info 
	scope.getWaveformPreamble();
	
	printf("[Gain Measurement] - Setting up output files..\n");

	// to be saved by root
	double t[sample_len], u[sample_len];
	Int_t len;
	float baseline, pulse_height, slope, offset;
	// root stuff
	TFile* out_file = new TFile(argv[2], "RECREATE");
	TH1F* h_pulse = new TH1F("h_pulse", "h_pulse", sample_len+1, t_min, t_max);
	TCanvas* c1 = new TCanvas();
	TTree* out_tree = new TTree("outtree", "gain_tree");
	out_tree->Branch("time", t, "t[500]/D");
	out_tree->Branch("amplitude", u, "u[500]/D");
	out_tree->Branch("len", &len);
	out_tree->Branch("slope", &slope);
	out_tree->Branch("offset", &offset);
	out_tree->Branch("baseline", &baseline);
	out_tree->Branch("pulse_height", &pulse_height);
	
	printf("[Gain Measurement] - Starting measurement of %i samples.\n", nSamples);
	int iSample = 0, rejects = 0;
	while (iSample < nSamples){
		h_pulse->Reset();
#ifdef VERBOSE
		printf("[Gain Measurement] - Reading scope... ");
#endif
		fill_n(t, sample_len, 0.);
		fill_n(u, sample_len, 0.);
		len = scope.getWaveformReading(t, u);
#ifdef VERBOSE
		printf("DONE\n");
#endif
		usleep(1e5);
		// fill histo
		for (int i = 0; i < len; i++){
			h_pulse->Fill(t[i], -1*u[i]);
//			printf("%e \t %e\n", t[i], u[i]);
		}
#ifndef VERBOSE	
		cout << "[Gain Measurement] - Progress " << iSample << "/" << nSamples << "\t\r" << flush;
#endif
		// calculate baseline
		baseline = getBaseline(h_pulse, t_min, 0, slope, offset);
		// reject if baseline too steep
		if ( fabs(slope) > 1e5 ){ 
			rejects++;
			printf("[Gain Measurement] - rejected sample, baseline too steep (%.3e).\n", fabs(slope));
			continue;
		}
		// everything seems to be fine
		pulse_height = h_pulse->GetBinContent( h_pulse->GetMaximumBin() ) - baseline;
		iSample++;

		// save
		out_tree->Fill();
#ifdef VERBOSE
		printf("[Gain Measurement] - " PGRN "# SAMPLE %i/%i #" PNRM "\n", iSample, nSamples);
		printf("[Gain Measurement] -\tbaseline = %fV\n", baseline);
		printf("[Gain Measurement] -\tpulse height = %fV\n", pulse_height);
		h_pulse->Write();
		printf("[Gain Measurement] -\tHisto written...\n", pulse_height);
#endif
	}
	printf("[Gain Measurement] - Done -  rejected %i samples (eff. %2.1f%).\n", rejects, 100.*(float)iSample/(float)(rejects + iSample) );

	// cleanup
	out_tree->Write();
	out_file->Close();
}

float getBaseline(TH1F* histo, float start, float stop, float &slope, float&offset){
	float baseline = 0.;
	TF1* f_baseline = new TF1("fun baseline", "[0] + [1]*x", start, stop);
	histo->Fit(f_baseline, "Q", "", start, stop);
	offset = f_baseline->GetParameter(0);
	slope = f_baseline->GetParameter(1);
	int i = 1;
	while ( histo->GetXaxis()->GetBinCenter(i) < stop ){
		baseline += histo->GetBinContent(i);
		i++;
	}
	baseline /= (float)(i-1);
	delete f_baseline;
	return baseline;
}
