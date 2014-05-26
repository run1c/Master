BIN=temp_cal_cooli
OBJ=CooliHandler.o
CC=g++

# ROOT flags
ROOTCFLAGS:=$(shell root-config --cflags)
ROOTLIBS:=$(shell root-config --libs)
ROOTGLIBS:=$(shell root-config --glibs)

LIBLAB=$(HOME)/liblab/
LIBSUB=$(HOME)/sdvlp/subsystem/

CFLAGS=-Wall $(ROOTCFLAGS) -I$(LIBLAB) -I$(LIBSUB)
LDFLAGS=-L$(LIBLAB) -L$(LIBSUB) $(ROOTGLIBS) -llab -lsubsystem

all: $(BIN)

%.o: %.cpp
	$(CC) -c $(CFLAGS) $^

$(BIN): $(BIN).o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS) $(CFLAGS)

clean:
	rm -f *.o
	rm -f $(BIN)
