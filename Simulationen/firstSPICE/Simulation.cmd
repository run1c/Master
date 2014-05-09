.op
.ac 	dec 	20 	1Hz 	100MegHz
*.dc 	Vinput	0	5	.01	
*.dc 	Vinput	1	2	.01	
.plot 	ac 	v(Vout)	v(Vin)
.print	ac	v(Vout)	v(Vin)	
