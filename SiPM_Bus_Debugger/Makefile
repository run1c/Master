BIN=bus_debugger
OBJ=
CC=g++

LIBLAB=$(HOME)/liblab/

CFLAGS=-Wall -I$(LIBLAB)
LDFLAGS=-L$(LIBLAB) -llab

all: $(BIN)

%.o: %.cpp
	$(CC) -c $(CFLAGS) $^

$(BIN): $(BIN).o $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

clean:
	rm -f *.o
	rm -f $(BIN)
