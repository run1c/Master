FOOTPRINTS=~/Documents/Projekte/circuit_layouts/footprints

all:

%.pcb: %.sch
	gsch2pcb --use-files --elements-dir $(FOOTPRINTS) $^ 

%.net: %.sch
	gnetlist -g spice-sdb -o $@ $^

clean: 
	rm -f *.net
	rm -f *.pcb*
