#include <TFile.h>
#include <TTree.h>
#include <TH1F.h>
#include <THStack.h>

#include <stdio.h>
#include <sstream>

void temp_ana(){
	const int nChans = 4;

	TFile* file = new TFile("temp_meas3.root", "READ");
	TTree* tree = (TTree*)file->Get("out_tree");

	// get depth of count array
	Int_t nSteps;
	tree->SetBranchAddress("nSteps", &nSteps);
	tree->GetEntry(0);

	// create count arrays
	Int_t* counts[nChans];
	for (int iChan = 0; iChan < nChans; iChan++){
		counts[iChan] = new Int_t[nSteps];
	}
	tree->SetBranchAddress("Count4", counts[0]);	
	tree->SetBranchAddress("Count5", counts[1]);	
	tree->SetBranchAddress("Count6", counts[2]);	
	tree->SetBranchAddress("Count7", counts[3]);	

	// get the rest...
	Int_t temperature;
	Int_t* threshold = new Int_t[nSteps];
	tree->SetBranchAddress("temp_degC", &temperature);	
	tree->SetBranchAddress("thresh", threshold);
	int nEvents = tree->GetEntries();

	/*
	 *	Draw finger-/differential-spectra
	 */	

	Int_t* diffCounts[nChans];
	TGraphErrors* gr1PE[4];
	for (int iChan = 0; iChan < nChans; iChan++){
		diffCounts[iChan] = new Int_t[nSteps-1];
		gr1PE[iChan] = new TGraphErrors();
	}

	// Scaler
	TCanvas* c2 = new TCanvas();
	TGraph* gr = (TGraph*)file->Get("ScalerCh0");
	TH1F* h1 = new TH1F("h1", "integrated noise spectrum;U_{thresh}[mV];counts", 100, -120, -20);
	h1->SetLineWidth(2);
	h1->SetLineColor(9);
	for (int i = 0; i < gr->GetN(); i++){
		h1->Fill(gr->GetX()[i], gr->GetY()[i]/256.);
	}	

	h1->Draw("L");
	
	/*
	 *	Plotting all finger spectra
	 */

	THStack* hs = new THStack();
	hs->SetTitle("noise spectrum vs. temp;U_{thresh}[mV];counts");
	TH1F* hDiffCount[10];
	stringstream ssName;
	int colour[] = {46, 0, 45, 0, 8, 0, 38};
	for (int i = 0; i < nEvents; i++){ 
		tree->GetEntry(i);
		ssName.str("");
		ssName << "diffSpec" << i << " T@" << temperature;
		hDiffCount[i] = new TH1F(ssName.str().c_str(), ssName.str().c_str(), 100, -120, -20);
		hDiffCount[i]->SetLineColor(colour[i]);
		hDiffCount[i]->SetLineWidth(2);
	}

	int max_pe = -1, max_pos = -1;
	for (int iChan = 0; iChan < 1; iChan++){				// loop over all channels
		for (int i = 0; i < nEvents; i++){				// loop over temperature measurments
			tree->GetEntry(i);
			max_pe = 0;
			for (int iStep = 0; iStep < (nSteps-1); iStep++){	// loop over all points of one measurment
				diffCounts[iChan][iStep] = counts[iChan][iStep-1] - counts[iChan][iStep];	// "differatiation"
				if (diffCounts[iChan][iStep] < 0) 
					diffCounts[iChan][iStep] = 0;
				// find maximum
				if (diffCounts[iChan][iStep] > max_pe){
					max_pe = diffCounts[iChan][iStep];
					max_pos = threshold[iStep];
				}	
				hDiffCount[i]->Fill(threshold[iStep], diffCounts[iChan][iStep]/256.);
			}
//			printf("1PE %i@%imV (%idegC)\n", max_pe, max_pos, temperature);
			gr1PE[iChan]->SetPoint(i, temperature, max_pos);
			gr1PE[iChan]->SetPointError(i, 0.5, 1.0/sqrt(12));
			if (i%2 == 0){ 
				hs->Add(hDiffCount[i], "L");
				printf("Temp %i\n", temperature);
			}
		}
	}
	TCanvas* c1 = new TCanvas();
	hs->Draw("NOSTACK");
//	gr1PE[0]->Draw("A*");

	// cleanup
	for (int iChan = 0; i < nChans; iChan++)
		delete counts[iChan];

	return;
}
