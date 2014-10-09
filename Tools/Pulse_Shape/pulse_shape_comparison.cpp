
#include <TROOT.h>
#include <TFile.h>
#include <TTree.h>
#include <TCanvas.h>
#include <TH1D.h>
#include <THStack.h>
#include <TStyle.h>

// just for camparison, no other use, everything is pretty static...

#define OLD_FILE
#define NEW_FILE
#define DIFF_FILE

int main(int argc, char** argv){

	gStyle->SetLabelSize(0.04, "x");
	gStyle->SetTitleSize(0.05, "x");
	gStyle->SetTitleOffset(0.9, "x");
	gStyle->SetLabelSize(0.04, "x");
	gStyle->SetNdivisions(505, "x");

	gStyle->SetLabelSize(0.04, "y");
	gStyle->SetTitleSize(0.05, "y");
	gStyle->SetLabelSize(0.04, "y");

	const int nFiles = 3;	// max files

	if (argc < 2){
		printf("Usage: ./pulse_shape_comparison <mppcd file> <mppcm file> <mppcdiff file>\n");
		return -1;
	}

	int curFiles = argc - 1;

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
	int colours[nFiles] = {kRed, kBlue, kViolet + 2}, nEvents = 0;

	THStack* hstack_rise = new THStack("Risetime", "Risetime comparison;t_{r} [s];entries");
	THStack* hstack_fall = new THStack("Falltime", "Falltime comparison;t_{f} [s];entries");
	THStack* hstack_duration = new THStack("Duration", "Pulse duration comparison;t_{p} [s];entries");

	// setup

	for (int iFile = 0; iFile < curFiles; iFile++){
		// open files and get trees
		mppc_files[iFile] = TFile::Open(argv[iFile + 1], "READ");
		mppc_trees[iFile] = (TTree*)mppc_files[iFile]->Get("out_tree");

		// assign branches
		mppc_trees[iFile]->SetBranchAddress("risetime", &rise_time[iFile]);
		mppc_trees[iFile]->SetBranchAddress("falltime", &fall_time[iFile]);
		mppc_trees[iFile]->SetBranchAddress("pulseduration", &pulse_duration[iFile]);
	
		h_rise[iFile] = new TH1D("Risetime Histogram", "Risetime Histogram;t_{r} [s];entries", 26, 0, 10e-9);
		h_rise[iFile]->SetFillColorAlpha( colours[iFile], 0.40 );
		h_rise[iFile]->SetLineColor( colours[iFile] );
		h_rise[iFile]->SetFillColor( colours[iFile] );
		h_rise[iFile]->SetFillStyle(3001);
		
		h_fall[iFile] = new TH1D("Falltime Histogram", "Falltime Histogram;t_{f} [s];entries", 125, 0, 50e-9); ;
		h_fall[iFile]->SetFillColorAlpha( colours[iFile], 0.40 );
		h_fall[iFile]->SetLineColor( colours[iFile] );
		h_fall[iFile]->SetFillColor( colours[iFile] );
		h_fall[iFile]->SetFillStyle(3001);
		
		h_duration[iFile] = new TH1D("Pulse Duration Histogram", "Pulse Duration Histogram;t_{p} [s];entries", 125, 5e-9, 55e-9);;
		h_duration[iFile]->SetFillColorAlpha(colours[iFile], 0.40);
		h_duration[iFile]->SetLineColor( colours[iFile] );
		h_duration[iFile]->SetFillColor( colours[iFile] );
		h_duration[iFile]->SetFillStyle(3001);

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

	// since root is dumb as fuck it cannot write/read to multiple of its OWN fucking files
	// stupid piece of shit	
	TCanvas* c1 = new TCanvas();

	for (int i = 0; i < curFiles; i++){
		h_rise[i]->Draw();
		c1->Write("c_rise");
		h_fall[i]->Draw();
		c1->Write("c_fall");
		h_duration[i]->Draw();
		c1->Write("c_duration");
	}
	
	hstack_rise->Draw("NOSTACK");
	c1->Write();
	
	hstack_fall->Draw("NOSTACK");
	c1->Write();
	
	hstack_duration->Draw("NOSTACK");
	c1->Write();

	out_file->Write();
	
	// cleanup
	out_file->Close();
	for (int i = 0; i < curFiles; i++)
		mppc_files[i]->Close();

	return 0;
}
