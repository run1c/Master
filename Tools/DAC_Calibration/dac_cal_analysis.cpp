#include <stdio.h>
#include <cmath>
// root
#include <TSystem.h>
#include <TFile.h>
#include <TTree.h>
#include <TCanvas.h>
#include <TH1F.h>
#include <TGraphErrors.h>
#include <TMultiGraph.h>

int main(int argc, char** argv){

   	gSystem->Load("libTree");

	if (argc != 2){
		printf("Usage: ./dac_cal_analysis <dac cal file>\n");
		return -1;
	}
	// open file
	char* file_name = argv[1];
	int dac_counts, nSteps, nMeas, dac_min, dac_max;
	double volt, volt_min, volt_max, volt_rms_min = 999., volt_rms_max = 0.;

	printf("[DAC Analysis] - Openig file '%s'...\n", file_name);

	TFile* in_file = new TFile(file_name, "open");
	TTree* in_tree = (TTree*)in_file->Get("cal_tree");	
	in_tree->SetBranchAddress("voltage_mV", &volt);
	in_tree->SetBranchAddress("DAC_counts", &dac_counts);
	in_tree->SetBranchAddress("n_steps", &nSteps);
	in_tree->SetBranchAddress("n_measurements", &nMeas);

	// get nMeas, nSteps, min and max val for dac and volt
	in_tree->GetEntry(in_tree->GetEntries() - 1);
	dac_max = dac_counts;
	volt_max = volt;

	in_tree->GetEntry(0);
	dac_min = dac_counts;
	volt_min = volt;

	printf("[DAC Analysis] - Found %i steps with %i measurements per step (total %i events)...\n", nSteps, nMeas, nSteps*nMeas);
	printf("[DAC Analysis] - Range DAC (%i..%i), range voltage (%.1f..%.1f)mV.\n", dac_min, dac_max, volt_min, volt_max);

	TFile* out_file = new TFile("out.root", "recreate");
	TH1F* volt_histo = new TH1F("volt", "h_volt; bias voltage [mV]", (int)(volt_max - volt_min), volt_min - 10., volt_max + 10.);
	TH1F* volt_rms_histo = new TH1F("voltage RMS", "voltage RMS;RMS [mV];#", 25 , 0., 2.5);
	TF1* lin_fit = new TF1("lin_fit", "[0] + [1]*x", dac_min, dac_max);
	lin_fit->SetParNames("U_{0} [V]", "#DeltaU/#DeltaDAC [V/counts]");

	float volt_mean, volt_rms;
	TGraphErrors* gr_dac_vs_volt = new TGraphErrors();
	gr_dac_vs_volt->SetTitle("output voltage vs. DAC counts;DAC [counts];U_{out} [mV]");
	gr_dac_vs_volt->GetYaxis()->SetTitleOffset(1.55);
	gr_dac_vs_volt->SetLineColor(35);
	gr_dac_vs_volt->SetMarkerStyle(7);

	TGraphErrors* gr_residuals = new TGraphErrors();
	gr_residuals->SetTitle("residuals;DAC [counts];U_{out} - U_{fit} [mV]");
	gr_residuals->GetYaxis()->SetTitleOffset(1.55);
	gr_residuals->SetLineColor(35);
	gr_residuals->SetMarkerStyle(7);
	TF1* zero = new TF1("zero", "0", -1e6, 1e6);

	printf("[DAC Analysis]\tstep\tdac\tvolt\t\trms\n");
	printf("[DAC Analysis]\t===================================\n");

	for (int iStep = 0; iStep < nSteps; iStep++){
		in_tree->GetEntry(iStep*nMeas);
		volt_histo->Reset();
		in_tree->GetEntry(iStep*nMeas + 1);
		volt_histo->GetXaxis()->SetRangeUser(volt - 10., volt + 10.);
		for (int iMeas = 0; iMeas < nMeas; iMeas++){
			in_tree->GetEntry(iMeas + iStep*nMeas);
			volt_histo->Fill(volt);
		}
		// extract mean and rms 
		volt_mean = volt_histo->GetMean();
		volt_rms = volt_histo->GetRMS();

		// keep track of min and max rms!
		if ( (volt_rms < volt_rms_min) && (volt_rms > 0) )
			volt_rms_min = volt_rms; 
		
		if (volt_rms > volt_rms_max)
			volt_rms_max = volt_rms; 

		printf("[DAC Analysis]\t%i\t%i\t%.3f\t%.3f\n", iStep, dac_counts, volt_mean, volt_rms);

		// fill taken data into corresponding histos/graphs
		volt_rms_histo->Fill(volt_rms);
		gr_dac_vs_volt->SetPoint(iStep, dac_counts, volt_mean);
		gr_dac_vs_volt->SetPointError(iStep, 0., volt_rms/sqrt(nMeas));

		// write out..
		volt_histo->Write();
	}
	gr_dac_vs_volt->Fit(lin_fit, "Q");

	// time for residuals
	float res;
	for (int i = 0; i < nSteps; i++){
		in_tree->GetEntry(i*nMeas + 1);
		res = gr_dac_vs_volt->GetY()[i] - lin_fit->Eval(dac_counts);
		gr_residuals->SetPoint(i, dac_counts, res);
		gr_residuals->SetPointError(i, 0., gr_dac_vs_volt->GetErrorY(i));	// plot in mV..
	}	

	TCanvas* c1 = new TCanvas();
	c1->Divide(2);

	c1->cd(1);
	gr_dac_vs_volt->Draw("AP");
	c1->cd(2);
	gr_residuals->Draw("AP");
	zero->Draw("same");

	c1->Write();
	volt_rms_histo->Write();

	printf("[DAC Analysis] - Done!\n");
	printf("[DAC Analysis] - DAC Gain\t= (%f\t+-\t%f)mV/count\n", lin_fit->GetParameter(1), lin_fit->GetParError(1));
	printf("[DAC Analysis] - DAC Offset\t= (%f\t+-\t%f)mV\n", lin_fit->GetParameter(0), lin_fit->GetParError(0));
	printf("[DAC Analysis] - (Min.=%.4f\tAvg.=%.4f\tMax.=%.4f)mV!\n", volt_rms_min, volt_rms_histo->GetMean(), volt_rms_max);

	// cleanup
	out_file->Close();
	in_file->Close();
	return 0;
}
