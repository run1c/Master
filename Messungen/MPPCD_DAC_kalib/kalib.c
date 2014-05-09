void kalib(){
	TF1* f1 = new TF1("f1", "[0] + [1]*x", 0, 0xFFFF);
	TF1* f2 = new TF1("f2", "[0] + [1]*x", 0, 0xFFFF);
	f2->SetLineColor(kBlue);
	double dac_counts[] = {0x0500, 0x1000, 0x1500, 0x2000, 0x2500, 0x3000};
	double U_biasA[] = {8200, 26200, 34400, 52400, 60600, 78600};
	double U_biasB[] = {8100, 26000, 34100, 52000, 60100, 77900};
	int n = 6;

	TGraph* grA = new TGraph(n, U_biasA, dac_counts); 
	grA->SetTitle("SiPM A;U[mV];counts");
	grA->Fit(f1);
	TGraph* grB = new TGraph(n, U_biasB, dac_counts);
	grB->SetTitle("SiPM B;U[mV];counts");
	grB->Fit(f2);

	TCanvas* c1 = new TCanvas();
	c1->Divide(2,1);
	c1->cd(1);
	grA->Draw("A*");
	c1->cd(2);
	grB->Draw("A*");

	return;
}
