#include <TFile.h>
#include <TTree.h>
#include <TH1.h>

void risetime_comparison(){
	TFile* file = new TFile("out_newAmp2.root", "OPEN");
	TTree* tree = (TTree*)file->Get("tree");
	TH1F* hNew = new TH1F("h1", "Risetime (10%-90%) - old vs. new;t [ns]", 24, 0, 12);
	int n = tree->GetEntries();
	Double_t t;
	tree->SetBranchAddress("riseTime", &t);

	for (int i = 0; i < n; i++){
		tree->GetEntry(i);
		hNew->Fill(t*1e9);
	}
	
	TFile* oFile = new TFile("out_oldAmp2.root", "OPEN");
	TTree* oTree = (TTree*)oFile->Get("tree");
	TH1F* hOld = new TH1F("h2", "h2", 24, 0, 12);
	n = oTree->GetEntries();
	oTree->SetBranchAddress("riseTime", &t);
	
	for (int i = 0; i < n; i++){
		oTree->GetEntry(i);
		hOld->Fill(t*1e9);
	}

	hOld->SetLineColor(kRed);
	hNew->Draw();
	hOld->Draw("SAME");
//	oFile->Close();
//	file->Close();
	return;
} 
