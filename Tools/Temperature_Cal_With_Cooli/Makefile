BIN=temp_cal_cooli
OBJ=CooliHandler.o
CC=g++

# ROOT flags
ROOTCFLAGS:=$(shell root-config --cflags)
ROOTLIBS:=$(shell root-config --libs)
ROOTGLIBS:=$(shell root-config --glibs)

#LIBLAB=$(HOME)/liblab/
#LIBSUB=$(HOME)/sdvlp/subsystem/

## makefile settings for my setup
#CFLAGS=-Wall $(ROOTCFLAGS) -I$(LIBLAB) -I$(LIBSUB)
#LDFLAGS=-L$(LIBLAB) -L$(LIBSUB) $(ROOTGLIBS) -llab -lsubsystem

## makefile settings on sipm01
CFLAGS=-Wall $(ROOTCFLAGS) -I$(HOME)/include/liblab/ -I$(HOME)/include/subsystem/
LDFLAGS=-L$(HOME)/lib/ $(ROOTGLIBS) -llab -lsubsystem

all: $(BIN)

%.o: %.cpp
	$(CC) -c $(CFLAGS) $^

$(BIN): $(BIN).o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS) $(CFLAGS)

clean:
	rm -f *.o
	rm -f $(BIN)
