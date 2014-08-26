BIN=pulse_shape
BIN2=pulse_shape_comparison
OBJ=
CC=g++

# ROOT flags
ROOTCFLAGS:=$(shell root-config --cflags)
ROOTLIBS:=$(shell root-config --libs)
ROOTGLIBS:=$(shell root-config --glibs)

CFLAGS=-g -Wall $(ROOTCFLAGS)

all: $(BIN) $(BIN2)

%.o: %.cpp
	$(CC) -c $(CFLAGS) $<

$(BIN): $(BIN).o
	$(CC) $^ -o $@ $(ROOTGLIBS)

$(BIN2): $(BIN2).o
	$(CC) $^ -o $@ $(ROOTGLIBS)

clean:
	rm -f *.o
	rm -f $(BIN)
	rm -f pulse_shape 
