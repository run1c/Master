// clib + unix
#include <sstream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
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
	float pulse_height, mean = 0, sigma, width = 0.01, min_height;
	float mean_err, sigma_err;
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
		mean = h_spec->GetBinCenter( h_spec->GetMaximumBin() );
		gaus_fit->SetParameter(0, h_spec->GetBinContent(h_spec->GetMaximumBin()));
		gaus_fit->SetParameter(1, mean); 
		gaus_fit->SetParameter(2, width);

		printf("[Gain Analysis] - Fit%i [%.3f, %.3f] :", iMax, mean-2.*width, mean+2.*width);

		// fit a gauss to the peak
		h_spec->Fit(gaus_fit, "Q", "", mean - 2.*width, mean + 2.*width);
		h_spec->Draw();

		// truncate filename "file.root" to "file"
		string sbuf;
		sbuf = file_name;
		sbuf = sbuf.substr(0, sbuf.find(".root"));
		ssbuf.str("");
		ssbuf << "fit" << (iMax+1) << "_" << sbuf.c_str() << ".jpg";
		// save image
		c1->SaveAs(ssbuf.str().c_str());
		// get parameters
		mean = gaus_fit->GetParameter(1);
		mean_err = gaus_fit->GetParError(1);
		sigma = gaus_fit->GetParameter(2);
		sigma_err = gaus_fit->GetParError(2);

		printf(" mean=(%.3f+-%.3f)mV, sigma=(%.3f+-%.3f)mV\n", 1000.*mean, 1000.*mean_err, 1000.*sigma, 1000.*sigma_err);

		// exclude first peak for next fit
		min_height = mean + width;
	}

	// cleanup
	file->Close();
	return 0;
}
