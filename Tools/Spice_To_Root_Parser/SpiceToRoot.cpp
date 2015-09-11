// libc
#include <stdio.h>
#include <sstream>
#include <iostream>
#include <fstream>
#include <string>

// root
#include <TFile.h>
#include <TTree.h>

#define ARGV_IN		1
#define ARGV_OUT	2
#define ARGV_COLS	3
#define SBUF_SIZE	256

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
	
	if ( !infile.is_open() ){
		printf("[Spice to root] Error on opening '%s'.\n", argv[ARGV_IN]);
		exit(1);
	}

	// create output file
	TFile* outfile = new TFile(argv[ARGV_OUT], "RECREATE");
	TTree* outtree = new TTree("SpiceTree", "SpiceTree");
	stringstream branchName;
	// create the branches
	for (int iCol = 0; iCol < nCols; iCol++){
		branchName.str("");	branchName << "var" << iCol;
		outtree->Branch(branchName.str().c_str(), &var[iCol]);
	}

	int line = -1;
	char sbuf[SBUF_SIZE];

	do {
		// Stop if end of file is reached	
		if (infile.eof()){ 
			printf("[Spice to root] Done!\n");
			break;
		}
	
		// Ignore all non-data lines
		if ( !(infile >> line) ) {			// line does not start with a character
			infile.clear();				// clear error bits
			infile.getline(sbuf, SBUF_SIZE);	// read and dump complete line
			printf("'%s'\n", sbuf);
			continue;
		}

		printf("[Spice to root] - line %i\t", line);
		for (int iCol = 0; iCol < nCols; iCol++){
			infile >> var[iCol];	
			printf("var%i = %f\t", iCol, var[iCol]);
		}
		printf("\n");

		outtree->Fill();

	} while ( true );

	outfile->Write();
	infile.close();
	outfile->Close();
	return 0;
}
