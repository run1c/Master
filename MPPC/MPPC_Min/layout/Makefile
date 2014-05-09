FOOTPRINTS=~/EDA/Luciani_Footprints

all:
	gsch2pcb --use-files --elements-dir $(FOOTPRINTS) project 

%.net: %.sch
	gnetlist -g spice-sdb -o $@ $^

clean: 
	rm -f *.net
	rm -f *.pcb*
