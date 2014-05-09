void test(){
	TF1* gain = new TF1("gain", "[0]*pow( (x - [1]), 2)", 0, 100);
	gain->SetParameter(1, 70);	// breakdown voltage
	gain->SetParameter(0, 35e-12);	// 35pF cell capacitance
	TCanvas* c1 = new TCanvas();
	gain->Draw();
}
