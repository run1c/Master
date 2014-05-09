// Includes
#include <Riostream.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <iostream>
#include <fstream>
#include <cstdio>
#include <math.h>
#include <iomanip>
#include <sstream>

// Root Includes
#include <TROOT.h>
#include <TFile.h>
#include <TTree.h>
#include <TGraph.h>
#include <TF1.h>
#include <TMath.h>
#include <TSystem.h>
#include <TInterpreter.h>

using namespace std;

struct DataStruct{
	Double_t slope;
	Double_t slopeErr;
	Double_t offset;
	Double_t offsetErr;
};

int getDACKali();
int getPt100Kali();
DataStruct linRegression(int, uint16_t*, int*);

int main(){
	cout << "starting evaluation of MPPC_D Kalibration values ... written by -Fussel- 2014\n" << endl;
	TFile *file = new TFile("output/MPPCD_Kalibration.root", "RECREATE");
	file->Close();
	getDACKali();
	getPt100Kali();	

	cout << "everthing done" << endl;
	return 0;
}

int getDACKali(){

	cout << "starting evaluation of DAC Kalibration values for voltage adjustment" << endl;
	int mppc;

	DataStruct resultA, resultB;
	TFile *file = new TFile("output/MPPCD_Kalibration.root", "UPDATE");
	TTree *treeDAC  = new TTree("treeDAC", "DACKalibrationVoltageAdjustment");
	treeDAC->Branch("mppcID", &mppc);
	treeDAC->Branch("SlopeA", &resultA.slope);
	treeDAC->Branch("SlopeErrorA", &resultA.slopeErr);
	treeDAC->Branch("OffsetA", &resultA.offset);
	treeDAC->Branch("OffsetErrorA", &resultA.offsetErr);
	treeDAC->Branch("SlopeB", &resultB.slope);
	treeDAC->Branch("SlopeErrorB", &resultB.slopeErr);
	treeDAC->Branch("OffsetB", &resultB.offset);
	treeDAC->Branch("OffsetErrorB", &resultB.offsetErr);

	int nLines = 0;
	for(int i = 10; i < 15; i++){
		mppc = i;
		stringstream ss;
		ss << "data/DACKali_";
		ss << mppc;
		ss << ".txt";

		uint16_t dacCounts[10] = {0};
		int voltageA[10] = {0};
		int voltageB[10] = {0};
		int voltageResidualA[10] = {0};
		int voltageResidualB[10] = {0};

		fstream in;
		in.open(Form(ss.str().c_str(), ios::in));

		if(!in.is_open())
			cout << "Error: something went wrong while read in data." << endl;
		nLines = 0;
		uint16_t x;
		int y;
		int z;
		
		while(1){
			in >> hex >> x >> dec >> y >> dec >> z;
			if(!in.good()) 
				break;
//			cout << hex << x << " " << dec << y << " " << dec << z << endl;

			dacCounts[nLines] = x*5;
			voltageA[nLines] = y;
			voltageB[nLines] = z;
			nLines++;
		}
		
		cout << "\n\tmppc 0x" << mppc << " Channel A:" << endl;
		resultA = linRegression(nLines, dacCounts, voltageA);	
		cout << "\tmppc 0x" << mppc << " Channel B:" << endl;
		resultB = linRegression(nLines, dacCounts, voltageB);	
		treeDAC->Fill();
	}
	
	treeDAC->Write();
	file->Close();
	cout << "evaluation done...\n" << endl;

	return 1;
}

int getPt100Kali(){
	
	cout << "starting evaluation of DAC Kalibration values for temperature adjustment" << endl;

	stringstream ss;
	ss << "data/TempKali";
	ss << ".txt";

	int temperature[7] = {0};
	uint16_t dacCounts10[7] = {0};
	uint16_t dacCounts11[7] = {0};
	uint16_t dacCounts12[7] = {0};
	uint16_t dacCounts13[7] = {0};
	uint16_t dacCounts14[7] = {0};

	fstream in;
	in.open(Form(ss.str().c_str(), ios::in));


	if(!in.is_open())
		cout << "Error: something went wrong while read in data." << endl;

	int nLines = 0;
	int x;
	uint16_t y0, y1, y2, y3, y4;
	
	while(1){
		if(nLines < 1){
			in >> hex >> y0 >> hex >> y1 >> hex >> y2 >> hex >> y3 >> hex >> y4;
			nLines++;
			continue;
		}

		in >> dec >> x >> hex >> y0 >> hex >> y1 >> hex >> y2 >> hex >> y3 >> hex >> y4;
		if(!in.good()) 
			break;
//		cout << dec << x << " " << hex << y0 << " " << hex << y1 << " " << hex << y2 << " " << hex << y3 << " " << hex << y4 << endl;

		temperature[nLines-1] = x;
		dacCounts10[nLines-1] = y0;
		dacCounts11[nLines-1] = y1;
		dacCounts12[nLines-1] = y2;
		dacCounts13[nLines-1] = y3;
		dacCounts14[nLines-1] = y4;
		nLines++;
	}

	DataStruct resultLR;
	Int_t mppc;
	TFile *file = new TFile("output/MPPCD_Kalibration.root", "UPDATE");
	TTree *treeTemp  = new TTree("treeTemp", "Pt100Kalibration");
	treeTemp->Branch("mppcID", &mppc);
	treeTemp->Branch("tempSlope", &resultLR.slope);
	treeTemp->Branch("tempSlopeError", &resultLR.slopeErr);
	treeTemp->Branch("tempOffset", &resultLR.offset);
	treeTemp->Branch("tempOffsetError", &resultLR.offsetErr);

	mppc = 10;
	cout << "\n\tmppc 0x" << mppc << endl;
	resultLR = linRegression(nLines-1, dacCounts10, temperature);	
	treeTemp->Fill();

	mppc = 11;
	cout << "\n\tmppc 0x" << mppc << endl;
	resultLR = linRegression(nLines-1, dacCounts11, temperature);	
	treeTemp->Fill();
	
	mppc = 12;
	cout << "\n\tmppc 0x" << mppc << endl;
	resultLR = linRegression(nLines-1, dacCounts12, temperature);	
	treeTemp->Fill();

	mppc = 13;
	cout << "\n\tmppc 0x" << mppc << endl;
	resultLR = linRegression(nLines-1, dacCounts13, temperature);	
	treeTemp->Fill();

	mppc = 14;
	cout << "\n\tmppc 0x" << mppc << endl;
	resultLR = linRegression(nLines-1, dacCounts14, temperature);	
	treeTemp->Fill();

	treeTemp->Write();
	file->Close();

	cout << "evaluation done...\n" << endl;
	return 1;
}

DataStruct linRegression(int n, uint16_t *xdataUint16, int *ydata){
	
	int *xdata = new int[n];
	for(int i = 0; i < n; i++){
		xdata[i] = static_cast<int>(xdataUint16[i]);
	}	

	DataStruct ret;
	TGraph *graph = new TGraph(n, xdata, ydata);
	TF1 *fLinReg = new TF1("fLinReg", "[0] + [1]*x", xdata[0], xdata[n-1]);

	graph->Fit(fLinReg, "RQ");
	cout << "Fit Result - Slope :   " << fLinReg->GetParameter(1) << " +/- " << fLinReg->GetParError(1) << endl;
	cout << "Fit Result - Offset:   " << fLinReg->GetParameter(0) << " +/- " << fLinReg->GetParError(0) << endl;
	cout << "Fit Result - Chi2/ndf: " << fLinReg->GetChisquare()/fLinReg->GetNDF() << endl;

	ret.slope = fLinReg->GetParameter(1);
	ret.slopeErr = fLinReg->GetParError(1);
	ret.offset = fLinReg->GetParameter(0);
	ret.offsetErr = fLinReg->GetParError(0);

	delete graph;
	delete fLinReg;
	return ret;
}
