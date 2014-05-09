v 20110115 2
C 40000 40000 0 0 0 title-B.sym
C 46100 46400 1 0 0 resistor-1.sym
{
T 46400 46800 5 10 0 0 0 0 1
device=RESISTOR
T 46300 46700 5 10 1 1 0 0 1
refdes=R1
T 46200 46200 5 10 1 1 0 0 1
value=10
}
C 47300 46300 1 0 0 capacitor-1.sym
{
T 47500 47000 5 10 0 0 0 0 1
device=CAPACITOR
T 47500 46800 5 10 1 1 0 0 1
refdes=C1
T 47500 47200 5 10 0 0 0 0 1
symversion=0.1
T 47400 46100 5 10 1 1 0 0 1
value=2.2u
}
N 47300 46500 47000 46500 4
{
T 46900 46700 5 10 1 1 0 0 1
netname=Vout
}
N 48200 46500 48700 46500 4
N 46100 46500 45600 46500 4
{
T 45700 46700 5 10 1 1 0 0 1
netname=Vin
}
C 49000 46400 1 90 0 gnd-1.sym
C 45300 45300 1 0 0 vac-1.sym
{
T 46000 45950 5 10 1 1 0 0 1
refdes=Vinput
T 46000 46150 5 10 0 0 0 0 1
device=vac
T 46000 46350 5 10 0 0 0 0 1
footprint=none
T 46000 45750 5 10 1 1 0 0 1
value=ac 10mV SIN(0 1mV 1kHz)
}
C 45500 45000 1 0 0 gnd-1.sym
C 43100 47500 1 0 0 spice-include-1.sym
{
T 43200 47800 5 10 0 1 0 0 1
device=include
T 43200 47900 5 10 1 1 0 0 1
refdes=A1
T 43600 47600 5 10 1 1 0 0 1
file=./Simulation.cmd
}
C 43100 46900 1 0 0 spice-directive-1.sym
{
T 43200 47200 5 10 0 1 0 0 1
device=directive
T 43200 47300 5 10 1 1 0 0 1
refdes=A2
T 43200 47000 5 10 1 1 0 0 1
file=?
T 43200 47000 5 10 1 1 0 0 1
value=.options TEMP=25
}
