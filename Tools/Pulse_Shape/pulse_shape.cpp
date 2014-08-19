// clib
#include <stdio.h>
// root
#include <TSystem.h>
#include <TFile.h>
#include <TTree.h>
#include <TGraph.h>
#include <TCanvas.h>
#include <TF1.h>

int main(int argc, char** argv){

	// because root is a piece of shit	
	gSystem->Load("libTree");

	if (argc != 2){
		printf("Usage: ./pulse_shape <gain_meas root file>\n\te.g. ./pulse_shape test.root\n");
		return -1;
	}

	char* file_name = argv[1];
//	float t_min = -70e-9, t_max = 130e-9, u_min = -1., u_max = 2.; 
	int sample_len;
	float baseline;
	

	// open root file and extract tree
 	printf("[Pulse Shape] - Opening file '%s'..\n", file_name);
	TFile* in_file = TFile::Open(file_name, "READ");
	TTree* in_tree = (TTree*)in_file->Get("outtree");
	in_tree->SetBranchAddress("len", &sample_len);
	in_tree->SetBranchAddress("baseline", &baseline);
	in_tree->GetEntry(0);

	double* u = new double[sample_len];
	double* t = new double[sample_len];
	in_tree->SetBranchAddress("amplitude", u);
	in_tree->SetBranchAddress("time", t);
	const int nEvents = in_tree->GetEntries();

 	printf("[Pulse Shape] - Found tree with %i events, %i samples per event.\n", nEvents, sample_len);

	TFile* out_file = new TFile("out.root", "RECREATE");
	TTree* out_tree = new TTree("out_tree", "outtree");
	double riseTime, fallTime, pulseDuration;
	out_tree->Branch("risetime", &riseTime);
	out_tree->Branch("falltime", &fallTime);
	out_tree->Branch("pulseduration", &pulseDuration);
	
	TCanvas* c1 = new TCanvas();
	TGraph* pulse = new TGraph();
	pulse->SetTitle("Output pulse;t [s];U [V]");
	pulse->SetMarkerStyle(7);
	TGraph* rf = new TGraph();	// drawing rise and fall time points
	rf->SetMarkerStyle(8);
	rf->SetMarkerColor(46);
	TF1* bl = new TF1("baseline", "[0]", -100, 100);	// baseline
	bl->SetLineColor(38);
	
        // loop over data
	float uMax, lPos, hPos, lTime, hTime, rTime, buf;
	int maxEntry;
        for (int iEvent = 0; iEvent < nEvents; iEvent++){
                uMax = -1.;
                in_tree->GetEntry(iEvent);
                for (int i = 0; i < sample_len; i++){
                        u[i] *= -1;
                        pulse->SetPoint(i, t[i], u[i]);
                        // find Maximum by Hand because root apparently isnt able to do so
                        if (u[i] > uMax){
                                uMax = u[i];
                                maxEntry = i;
                        }
                }
		// get 10% and 90% amplitude
                lPos = 0.1*(uMax - baseline) + baseline;
                hPos = 0.9*(uMax - baseline) + baseline;
                
		// get rise time -> start at maximum and go left
		lTime = -1;
                hTime = -1;
                for (int i = maxEntry; (buf = pulse->GetY()[i]) > 0.9*lPos; i--){
                        if ( buf > hPos )
                                hTime = pulse->GetX()[i];
                        if ( buf > lPos ){
                                lTime = pulse->GetX()[i];
                        }
                }
                riseTime = hTime - lTime;
		rf->SetPoint(0, lTime, lPos);               
		rf->SetPoint(1, hTime, hPos);               
 
		// get fall time -> start at maximum and go right
		rTime = -1;
                hTime = -1;
                for (int i = maxEntry; (buf = pulse->GetY()[i]) > 0.9*lPos; i++){
                        if ( buf > hPos )
                                hTime = pulse->GetX()[i];
                        if ( buf > lPos ){
                                rTime = pulse->GetX()[i];
                        }
                }
                fallTime = rTime - hTime;
		pulseDuration = rTime - lTime; 
		rf->SetPoint(2, rTime, lPos);               
		rf->SetPoint(3, hTime, hPos);               

		out_tree->Fill();

                // draw & save every 500th event
                if (iEvent%10 == 0) {
 			printf("[Pulse Shape] - Risetime = %e s\n", riseTime);
			printf("[Pulse Shape] - Falltime = %e s\n", pulseDuration);
 			printf("[Pulse Shape] - Pulse duration = %e s\n", fallTime);
			
			bl->SetParameter(0, baseline);
                        pulse->Draw("A*");
			bl->Draw("SAME");
			rf->Draw("SAME*");
			c1->Write();
                }
	}




	// cleanup
	out_tree->Write();
	out_file->Close();
	in_file->Close();
	return 0;
}
