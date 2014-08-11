FOOTPRINTS=-d ~/.gEDA/Luciani_Footprints/ -d ~/.gEDA/myFootprints/

all:
	gsch2pcb --use-files $(FOOTPRINTS) project 

%.net: %.sch
	gnetlist -g spice-sdb -o $@ $^

clean: 
	rm -f *.net
	rm -f *.pcb*
