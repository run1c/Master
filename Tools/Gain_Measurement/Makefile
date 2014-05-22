BIN=gain_meas
OBJ=
CC=g++

# ROOT flags
ROOTCFLAGS:=$(shell root-config --cflags)
ROOTLIBS:=$(shell root-config --libs)
ROOTGLIBS:=$(shell root-config --glibs)

LIBLAB=$(HOME)/liblab/

CFLAGS=-Wall $(ROOTCFLAGS) -I$(LIBLAB) 
LDFLAGS=-L$(LIBLAB) $(ROOTGLIBS) -llab

all: $(BIN) gain_analysis

%.o: %.cpp
	$(CC) -c $(CFLAGS) $^

$(BIN): $(BIN).o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

%: %.o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

clean:
	rm -f *.o
	rm -f $(BIN)
	rm -f gain_analysis
