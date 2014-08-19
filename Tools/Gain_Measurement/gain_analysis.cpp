// clib + unix
#include <sstream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
// root
#include <TSystem.h>
#include <TTree.h>
#include <TH1F.h>
#include <TF1.h>
#include <TCanvas.h>
#include <TFile.h>

using namespace std;

int main(int argc, char** argv){
   	gSystem->Load("libTree");

	char* file_name;
	int nMax;

	if (argc != 3){
		printf("Usage: ./gain_analysis <no of maxima> <name of root file>\n");
		printf("\te.g.: ./gain_analysis 3 test.root\n");
		return -1;
	} else {
		nMax = atoi(argv[1]);				
		file_name = argv[2];
	} 

	printf("[Gain Analysis] - Opening file '%s'..\n", file_name);

	// init root stuff
	TFile* file = TFile::Open(file_name, "READ");
	TTree* tree = (TTree*)file->Get("outtree");
	TH1F* h_spec = new TH1F("h_spec", "fingerspectrum", 200, 0, 0.1);

	stringstream ssbuf;
	int nSamples = tree->GetEntries();
	float pulse_height, width = 0.002, min_height = 0.;
	float* mean = new float[nMax];
	float* sigma = new float[nMax];
	float* mean_err = new float[nMax];
	float* sigma_err = new float[nMax];
	tree->SetBranchAddress("pulse_height", &pulse_height);

	// look at fingerspectrum from 0 to 100mV
	TF1* gaus_fit = new TF1("gfit", "gaus(0)", 0, 0.1);	
	TCanvas* c1 = new TCanvas();
	
	printf("[Gain Analysis] - Trying to find %i maxima..\n", nMax);

	// new loop for each maximum
	for (int iMax = 0; iMax < nMax; iMax++){
		h_spec->Reset();
		// fill histo with entries above the minimum pulse height
		for (int iSample = 0; iSample < nSamples; iSample++){
			tree->GetEntry(iSample);
			if (pulse_height < min_height) continue;
			h_spec->Fill(pulse_height);
		}
		
		// set preleminary parameters to improve fit results
		mean[iMax] = h_spec->GetBinCenter( h_spec->GetMaximumBin() );
		gaus_fit->SetParameter(0, h_spec->GetBinContent(h_spec->GetMaximumBin()));
		gaus_fit->SetParameter(1, mean[iMax]); 
		gaus_fit->SetParameter(2, width);

		printf("[Gain Analysis] - Fit%i [%.3f, %.3f] :", iMax, mean[iMax]-2.*width, mean[iMax]+2.*width);

		// fit a gauss to the peak
		h_spec->Fit(gaus_fit, "Q", "", mean[iMax] - 2.*width, mean[iMax] + 2.*width);
		h_spec->Draw();

		// truncate filename "file.root" to "file"
		string sbuf;
		sbuf = file_name;
		sbuf = sbuf.substr(0, sbuf.find(".root"));
		ssbuf.str("");
		ssbuf << sbuf.c_str() << "fit" << (iMax+1) << "_" << ".jpg";
		// save image
		c1->SaveAs(ssbuf.str().c_str());
		// get parameters
		mean[iMax] = gaus_fit->GetParameter(1);
		mean_err[iMax] = gaus_fit->GetParError(1);
		sigma[iMax] = gaus_fit->GetParameter(2);
		sigma_err[iMax] = gaus_fit->GetParError(2);

		printf(" mean=(%.3f+-%.3f)mV, sigma=(%.3f+-%.3f)mV\n", 1000.*mean[iMax], 1000.*mean_err[iMax], 1000.*sigma[iMax], 1000.*sigma_err[iMax]);

		// exclude first peak for next fit
		min_height = mean[iMax] + width;
	}

	// calculate gain as distance of the maxima
	float* gain = new float[nMax-1];
	float* gain_err = new float[nMax-1];
	float mean_gain = 0., mean_gain_err = 0., separability = 0., sep_err = 0.;
	for (int i = 0; i < (nMax-1); i++){
		gain[i] = mean[i + 1] - mean[i];
		gain_err[i] = sqrt( pow(mean_err[i], 2) + pow(mean_err[i + 1], 2) );
		printf("[Gain Analysis] - Measured gain (%f-+%f)mV\n", 1000.*gain[i], 1000.*gain_err[i]);
		
		// weighted mean
		mean_gain += gain[i]/(gain_err[i]*gain_err[i]);
		mean_gain_err += 1./(gain_err[i]*gain_err[i]);
	}
	
	mean_gain_err = 1./mean_gain_err;
	mean_gain *= mean_gain_err;
	printf("[Gain Analysis] - Mean gain (%f-+%f)mV\n", 1000.*mean_gain, 1000.*sqrt(mean_gain_err));

	separability = gain[0]/sqrt( sigma[0]*sigma[0] + sigma[1]*sigma[1] );

	sep_err = sqrt( gain_err[0]*gain_err[0]/(sigma[0]*sigma[0] + sigma[1]*sigma[1]) + 
			sigma[0]*sigma[0]*gain[0]*gain[0]*sigma_err[0]*sigma_err[0]/pow( sigma[0]*sigma[0] + sigma[1]*sigma[1] , 3) + 
			sigma[1]*sigma[1]*gain[0]*gain[0]*sigma_err[1]*sigma_err[1]/pow( sigma[0]*sigma[0] + sigma[1]*sigma[1] , 3) );

	printf("[Gain Analysis] - separability (%f-+%f)\n", separability, sep_err);
	
	// cleanup
	file->Close();
	return 0;
}
