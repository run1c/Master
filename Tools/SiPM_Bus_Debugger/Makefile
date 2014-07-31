BIN=bus_debugger
OBJ=
CC=g++

## private config
#LIBLAB=$(HOME)/liblab/
#CFLAGS=-Wall -I$(LIBLAB)
#LDFLAGS=-L$(LIBLAB) -llab

## lab pc config
CFLAGS=-Wall -I$(HOME)/include/liblab
LDFLAGS=-L$(HOME)/lib -llab


all: $(BIN)

%.o: %.cpp
	$(CC) -c $(CFLAGS) $^

$(BIN): $(BIN).o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

clean:
	rm -f *.o
	rm -f $(BIN)
