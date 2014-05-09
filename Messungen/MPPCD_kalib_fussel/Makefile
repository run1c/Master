#MAKEFILE

ROOTCFLAGS=$(shell root-config --cflags)
ROOTLDFLAGS=$(shell root-config --ldflags)
ROOTLIBS=$(shell root-config --libs)

LIBPATH=/lib/

CCFLAGS=$(ROOTCFLAGS)
LDFLAGS=-L$(LIBPATH) $(ROOTLDFLAGS) $(ROOTLIBS)

PROG=MPPCD_Kali

.PHONY: clean all

all: $(PROG)

$(PROG): %:	%.o
	@echo -n ">>> Linking "
	g++ $^ -o $@ $(LDFLAGS)

%.o:	%.cpp| %.h
	echo 'TEEEEEST'
	echo $(ROOTCFLAGS)
	@echo -n ">>> Compiling "
	g++ -c $< $(CCFLAGS) -o $@

%.o:	%.cpp
	@echo -n ">>> Compiling "
	g++ -c $< $(CCFLAGS) -o $@

clean:
	rm -f $(PROG)
	rm -f *.o 
