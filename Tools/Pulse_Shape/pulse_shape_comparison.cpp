

#include <TFile.h>
#include <TTree.h>
#include <TCanvas.h>
#include <TH1D.h>
#include <THStack.h>

// just for camparison, no other use, everything is pretty static...

#define OLD_FILE
#define NEW_FILE
#define DIFF_FILE

int main(int argc, char** argv){
	const int nFiles = 3;

	if (argc != (nFiles + 1)){
		printf("Usage: ./pulse_shape_comparison <mppcd file> <mppcm file> <mppcdiff file>\n");
		return -1;
	}

	// 1st = old mppc_d
	// 2nd = new mppc_min
	// 3rd = new mppc_min with diff amplifier stage

	TFile* mppc_files[nFiles];
	TTree* mppc_trees[nFiles];

	double rise_time[nFiles], fall_time[nFiles], pulse_duration[nFiles];
	
	// Histograms for comparison
	TH1D* h_rise[nFiles];
	TH1D* h_fall[nFiles];
	TH1D* h_duration[nFiles];
	int colours[nFiles] = {kRed, kBlue, kGreen}, nEvents = 0;

	THStack* hstack_rise = new THStack("Risetime", "Risetime comparison;t_{r} [s]");
	THStack* hstack_fall = new THStack("Falltime", "Falltime comparison;t_{f} [s]");
	THStack* hstack_duration = new THStack("Duration", "Pulse duration comparison;t_{p} [s]");

	// setup
	
	for (int iFile = 0; iFile < nFiles; iFile++){
		// open files and get trees
		mppc_files[iFile] = TFile::Open(argv[iFile + 1], "READ");
		mppc_trees[iFile] = (TTree*)mppc_files[iFile]->Get("out_tree");

		// assign branches
		mppc_trees[iFile]->SetBranchAddress("risetime", &rise_time[iFile]);
		mppc_trees[iFile]->SetBranchAddress("falltime", &fall_time[iFile]);
		mppc_trees[iFile]->SetBranchAddress("pulseduration", &pulse_duration[iFile]);
	
		h_rise[iFile] = new TH1D("Risetime Histogram", "Risetime Histogram", 25, 0, 10e-9);
		h_rise[iFile]->SetLineColor( colours[iFile] );
		h_rise[iFile]->SetFillColor( colours[iFile] );
		h_rise[iFile]->SetFillStyle( 3001 );
		
		h_fall[iFile] = new TH1D("Falltime Histogram", "Falltime Histogram", 125, 0, 50e-9); ;
		h_fall[iFile]->SetLineColor( colours[iFile] );
		h_fall[iFile]->SetFillColor( colours[iFile] );
		h_fall[iFile]->SetFillStyle( 3001 );
		
		h_duration[iFile] = new TH1D("Pulse Duration Histogram", "Pulse Duration Histogram", 125, 5e-9, 55e-9);;
		h_duration[iFile]->SetLineColor( colours[iFile] );
		h_duration[iFile]->SetFillColor( colours[iFile] );
		h_duration[iFile]->SetFillStyle( 3001 );

		// loop over all entries of current tree
		nEvents = mppc_trees[iFile]->GetEntries();
		for (int iEvent = 0; iEvent < nEvents; iEvent++){
			mppc_trees[iFile]->GetEntry(iEvent);
	
			// fill rise-, falltime and pulse duration histos
			h_rise[iFile]->Fill(rise_time[iFile]);
			h_fall[iFile]->Fill(fall_time[iFile]);
			h_duration[iFile]->Fill(pulse_duration[iFile]);
		}

		// histo is filled, add to hstack!
		hstack_rise->Add(h_rise[iFile]);
		hstack_fall->Add(h_fall[iFile]);
		hstack_duration->Add(h_duration[iFile]);
	}

	// save everything..
	TFile* out_file = new TFile("comp_result.root", "RECREATE");
	TCanvas* c1 = new TCanvas();
	
	hstack_rise->Draw("NOSTACK");
	c1->Write();
	
	hstack_fall->Draw("NOSTACK");
	c1->Write();
	
	hstack_duration->Draw("NOSTACK");
	c1->Write();
	
	// cleanup
	out_file->Close();
	for (int i = 0; i < nFiles; i++)
		mppc_files[i]->Close();

	return 0;
}
