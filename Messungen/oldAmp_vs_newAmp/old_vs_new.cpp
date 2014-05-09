#include <stdio.h>
#include <fstream>

#include <TFile.h>
#include <TH1.h>
#include <TTree.h>
#include <TGraph.h>

// cutoff conditions for baseline fit
#define MAX_SLOPE1 1e5
#define MIN_SLOPE1 -1e5
#define MAX_SLOPE2 1e5 
#define MIN_SLOPE2 -1e5

#define INPUT "oldAmp2.root"
#define OUTPUT "out_oldAmp2.root"


double getBaseline(TGraph* grPulse);

void old_vs_new(){

	/*
	 *	get old stuff from files
	 */

	TFile* file = new TFile(INPUT, "OPEN");
	TTree* tree = (TTree*)file->Get("out_tree");
	double u, t;
	tree->SetBranchAddress("ch1Voltage", &u);
	tree->SetBranchAddress("time", &t);
	
	const int nEntries = tree->GetEntries();
	const int nPoints = 400;	// points per event
	int nEvents = nEntries/nPoints;

	/*
	 *	init new stuff for analysis
	 */

	double buf;
	Double_t uMax, tMax, base; 
	Double_t lTime, hTime, riseTime, lPos, hPos;
	TGraph* gr = new TGraph(nPoints + 1);
	gr->SetTitle("SiPM pulse;t[s];U[V]");
	gr->SetMarkerStyle(7);
	TF1* baseline = new TF1("baseline", "[0]", -100, 100);
	baseline->SetLineColor(38);
	TFile* outfile = new TFile(OUTPUT, "recreate");	
	TTree* outtree = new TTree("tree", "tree");
	outtree->Branch("riseTime", &riseTime);
	outtree->Branch("PulseHeight", &uMax);
	
	TGraph* rf = new TGraph(2);	// to draw rise and fall time points!
	rf->SetMarkerStyle(8);
	rf->SetMarkerColor(46);

	TCanvas* c1 = new TCanvas();

	// loop over data
	for (int iEvent = 0; iEvent < nEvents; iEvent++){
		uMax = -1.;
		tMax = -1.;	
		for (int i = 0; i < nPoints; i++){
			tree->GetEntry(i + iEvent*nPoints);
			u *= -1;
			gr->SetPoint(i, t, u);
			// find Maximum by Hand because root apparently isnt able to do so
			if (u > uMax){
				uMax = u;
				tMax = t;
				maxEntry = i;
			}
		}
		gr->SetPoint(nPoints, 150e-9, 0);		
		// continue if there was no good baseline found
		base = getBaseline(gr);
		if (base == -1.) continue;

		/* 
		 *	Now we know the base line and the pulse height -> time to get the rise time!
		 */
	
		lPos = 0.1*(uMax - base) + base;
		hPos = 0.9*(uMax - base) + base;
		lTime = -1;
		hTime = -1;

		for (int i = maxEntry; (buf = gr->GetY()[i]) > 0.9*lPos; i--){
			if ( buf > hPos )
				hTime = gr->GetX()[i];	
			if ( buf > lPos ){
				lTime = gr->GetX()[i];
			} 
		}		

		riseTime = hTime - lTime;
		gr->GetXaxis()->SetRange(-30e-9, 140e-9);

		// draw & save every 500th event
		if (iEvent%500 == 0) {
			printf("Event %i \t Max. %2.2fmV @ %2.2fns \t baseline@%2.2fmV \n", iEvent, uMax*1e3, tMax*1e9, base*1e3);
			rf->SetPoint(0, lTime, lPos);
			rf->SetPoint(1, hTime, hPos);
			baseline->SetParameter(0, base);
			gr->Draw("AP");
			rf->Draw("PSAME");
			baseline->Draw("SAME");
			c1->Write();
		}

		outtree->Fill();
	}

	// cleanup
	outtree->Write();
	file->Close();
	outfile->Close();
	return;
}

double getBaseline(TGraph* grPulse){
	double buf, base = .0;
	bool lGood = true, rGood = true;
	TF1* baseFit = new TF1("baseFit", "[0] + [1]*x");
	baseFit->SetParameter(0, 0);
	baseFit->SetParameter(1, 0);
	// get min and max time to limit fit ranges
	Double_t min = grPulse->GetX()[0];
	Double_t max = grPulse->GetX()[grPulse->GetN() - 1];

	// the first and last 20ns should be baseline
	// right fit
	grPulse->Fit(baseFit, "WQN", "", min, min + 40e-9);
	buf = baseFit->GetParameter(1);
	if ( (buf > MAX_SLOPE1) || (buf < MIN_SLOPE1) ){
		lGood = false;
	}
	// left fit
	grPulse->Fit(baseFit, "WQN", "", max - 30e-9, max);
	buf = baseFit->GetParameter(1);
	if ( (buf > MAX_SLOPE2) || (buf < MIN_SLOPE2) ){
		rGood = false;
	}

	// bad pulses sorted out; now determine the baseline
	int i = 0, n = 0;
	while ( (buf = grPulse->GetX()[i]) < max ){
		// only use baselines, if the fits were "good"
		if ( ((buf < min + 20e-9) && lGood) || ((buf > max - 20e-9) && rGood) ){
			base += grPulse->GetY()[i];
			n++;
		}
		i++;
	}
	base /= (double)n;

	// cleanup
	delete baseFit;
	if (!rGood && !lGood)
		return -1.;
	return base;
}

