// libc and unix
#include <stdio.h>
// root
#include <TSystem.h>
#include <TFile.h>
#include <TTree.h>
#include <TCanvas.h>
#include <TH1F.h>
#include <TGraphErrors.h>
#include <TMultiGraph.h>
#include <TLegend.h>

int main(int argc, char** argv){

   	gSystem->Load("libTree");

	if (argc != 2){
		printf("Usage: ./temp_cal_analysis <temp cal file>\n");
		return -1;
	}
	// open file
	char* file_name = argv[1];
	float pt100_temp, cooli_temp, fix_temp, temp_min, temp_max;
	unsigned short adc_count;
	int nMeas, nSteps, time;

	printf("[Temperature Analysis] - Openig file '%s'...\n", file_name);

	TFile* in_file = new TFile(file_name, "open");
	TTree* in_tree = (TTree*)in_file->Get("temp_cal");	
	in_tree->SetBranchAddress("pt100_temp", &pt100_temp);
	in_tree->SetBranchAddress("cooli_temp", &cooli_temp);
	in_tree->SetBranchAddress("temperature", &fix_temp);
	in_tree->SetBranchAddress("adc_count", &adc_count);
	in_tree->SetBranchAddress("nMeas", &nMeas);
	in_tree->SetBranchAddress("nSteps", &nSteps);
	in_tree->SetBranchAddress("timestamp", &time);

	// get nMeas and nSteps
	in_tree->GetEntry(0);
	temp_min = fix_temp;
	in_tree->GetEntry(in_tree->GetEntries() - 1);
	temp_max = fix_temp;

	printf("[Temperature Analysis] - Found %i steps with %i measurements per step (total %i events)...\n", nSteps, nMeas, nSteps*nMeas);
	printf("[Temperature Analysis] - Measuring from %.2fdegC-%.2fdegC\n", temp_min, temp_max);

	TFile* out_file = new TFile("out.root", "recreate");
	// pt100 temperatures seem to be slightly smaller than set temperature
	TH1F* pt100_histo = new TH1F("pt100", "h_pt100", 100, temp_min - 3., temp_max + 1.);
	// cooli and difference between pt100 and cooli
	TH1F* cooli_histo = new TH1F("cooli", "h_cooli", 100, temp_min - 1., temp_max + 1.);
	TH1F* diff_histo = new TH1F("diff", "h_diff", 100, -5., 5.);
	// histo of RMSs of the differences to get the mean deviation of the pt100 sensor
	TH1F* diff_rms_histo = new TH1F("RMS distribution", "h_diff_rms", 21, 0., 0.2);

	// we would also like to see the temporal progress of the temperature
	float pt100_mean, pt100_rms, cooli_mean, cooli_rms, diff_mean, diff_rms;
	float diff_min = 999, diff_max = 0;
	TGraphErrors* t_pt100 = new TGraphErrors();
	t_pt100->SetLineColor(35);
	t_pt100->SetMarkerColor(35);
	t_pt100->SetMarkerStyle(7);
	TGraphErrors* t_cooli = new TGraphErrors();
	t_cooli->SetLineColor(46);
	t_cooli->SetMarkerColor(46);
	t_cooli->SetMarkerStyle(7);
	TGraphErrors* t_diff = new TGraphErrors();
	t_diff->SetLineColor(30);
	t_diff->SetMarkerColor(30);
	t_diff->SetMarkerStyle(7);
	TMultiGraph* mg = new TMultiGraph();
	mg->SetTitle("Temperature Progression;t [s];T[#circC]");
	TLegend* leg = new TLegend(0.1, 0.7, 0.3, 0.9, "");
	
	printf("[Temperature Analysis]\tstep\tpt100\trms\tcooli\trms\tdiff\trms\n");
	printf("[Temperature Analysis]\t==================================================\n");

	for (int iStep = 0; iStep < nSteps; iStep++){
		in_tree->GetEntry(iStep*nMeas);
		// temperature measured by pt100 is slightly below the regulated temperature
		pt100_histo->Reset();
		cooli_histo->Reset();
		diff_histo->Reset();
		for (int iMeas = 0; iMeas < nMeas; iMeas++){
			in_tree->GetEntry(iMeas + iStep*nMeas);
			// fill the histos
			pt100_histo->Fill(pt100_temp);
			cooli_histo->Fill(cooli_temp);
			diff_histo->Fill(cooli_temp - pt100_temp);
		}
		// extract mean and rms 
		pt100_mean = pt100_histo->GetMean();
		pt100_rms = pt100_histo->GetRMS();
		cooli_mean = cooli_histo->GetMean();
		cooli_rms = cooli_histo->GetRMS();
		diff_mean = diff_histo->GetMean();
		diff_rms = diff_histo->GetRMS();

		// keep track of min and max rms!
		if ( (diff_rms < diff_min) && (diff_rms > 0) )
			diff_min = diff_rms; 
		
		if (diff_rms > diff_max)
			diff_max = diff_rms; 

		printf("[Temperature Analysis]\t%i\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n", iStep, pt100_mean, pt100_rms, cooli_mean, cooli_rms, diff_mean, diff_rms);

		t_pt100->SetPoint(iStep, (float)time, pt100_mean);
		t_pt100->SetPointError(iStep, 0., pt100_rms);
		t_cooli->SetPoint(iStep, (float)time, cooli_mean);
		t_cooli->SetPointError(iStep, 0., cooli_rms);
		t_diff->SetPoint(iStep, (float)time, diff_mean);
		t_diff->SetPointError(iStep, 0., diff_rms);
		diff_rms_histo->Fill(diff_rms);

		// write out..
		pt100_histo->Write();
		cooli_histo->Write();
		diff_histo->Write();
	}

	printf("[Temperature Analysis] - Done!\n");
	printf("[Temperature Analysis] - Min.=%.4f\tAvg.=%.4f\tMax.=%.4f!\n", diff_min, diff_rms_histo->GetMean(), diff_max);

	diff_rms_histo->Write();
	mg->Add(t_pt100);
	mg->Add(t_cooli);
	mg->Add(t_diff);

	leg->AddEntry(t_pt100, "PT100 probe", "p");
	leg->AddEntry(t_cooli, "Sensirion probe (Cooli)", "p");
	leg->AddEntry(t_diff, "temperature difference", "p");
	// graphics output
	TCanvas* c2 = new TCanvas();
	mg->Draw("ap");
	leg->Draw("same");
	c2->Write();

//	mg->Write();
	// cleanup
	out_file->Close();
	in_file->Close();
	return 0;
}
