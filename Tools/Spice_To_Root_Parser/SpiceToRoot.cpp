// libc
#include <stdio.h>
#include <sstream>
#include <iostream>
#include <fstream>

// root
#include <TFile.h>
#include <TTree.h>

#define ARGV_IN		1
#define ARGV_OUT	2
#define ARGV_COLS	3

using namespace std;

int main(int argc, char** argv){

	if (argc != 4){
		printf("Usage: ./SpiceToRoot <.txt spice input file> <.root output file> <number of columns>\n");
		return -1;
	}

	int nCols = atoi(argv[ARGV_COLS]);
	double* var = new double[nCols];

	// open input file
	ifstream infile;
	infile.open(argv[ARGV_IN], ifstream::in);
	
	// create output file
	TFile* outfile = new TFile(argv[ARGV_OUT], "RECREATE");
	TTree* outtree = new TTree("SpiceTree", "SpiceTree");
	stringstream branchName;
	// create the branches
	for (int iCol = 0; iCol < nCols; iCol++){
		branchName.str("");	branchName << "var" << iCol;
		outtree->Branch(branchName.str().c_str(), &var[iCol]);
	}

	int line;

	do {
		infile >> line;	// first entry of a line is the column number; not needed
		if (!infile.good()) break;
		printf("[Spice to root] - line %i\t", line);
		for (int iCol = 0; iCol < nCols; iCol++){
			infile >> var[iCol];	
			printf("var%i = %f\t", iCol, var[iCol]);
		}
		printf("\n");
		outtree->Fill();
	} while ( infile.good() );

	outfile->Write();

	return 0;
}
