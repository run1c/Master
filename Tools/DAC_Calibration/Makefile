BIN=dac_cal
BIN2=dac_cal_analysis
OBJ=
CC=g++

# ROOT flags
ROOTCFLAGS:=$(shell root-config --cflags)
ROOTLIBS:=$(shell root-config --libs)
ROOTGLIBS:=$(shell root-config --glibs)

LIBLAB=$(HOME)/liblab/

CFLAGS=-Wall $(ROOTCFLAGS) -I$(LIBLAB) 
LDFLAGS=-L$(LIBLAB) $(ROOTGLIBS) -llab

all: $(BIN) $(BIN2)

%.o: %.cpp
	$(CC) -c $(CFLAGS) $^

$(BIN): $(BIN).o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

$(BIN2): $(BIN2).o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

clean:
	rm -f $(BIN)
	rm -f $(BIN2)
	rm -f *.o
