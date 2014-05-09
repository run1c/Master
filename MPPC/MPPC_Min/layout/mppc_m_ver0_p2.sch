v 20110115 2
C 40000 40000 0 0 0 title-B.sym
C 47100 45400 1 0 0 MAX4228.sym
{
T 43700 46800 5 10 0 0 0 0 1
device=DUAL_OPAMP
T 47300 46300 5 10 1 1 0 0 1
refdes=U4
T 43700 46400 5 10 0 0 0 0 1
footprint=MSOP10
T 43700 47000 5 10 0 0 0 0 1
symversion=0.2
T 47100 45400 5 10 0 0 0 0 1
slot=1
}
C 49800 45600 1 0 0 MAX4228.sym
{
T 46400 47000 5 10 0 0 0 0 1
device=DUAL_OPAMP
T 50000 46500 5 10 1 1 0 0 1
refdes=U4
T 46400 46600 5 10 0 0 0 0 1
footprint=MSOP10
T 46400 47200 5 10 0 0 0 0 1
symversion=0.2
T 49800 45600 5 10 0 0 0 0 1
slot=2
}
C 43800 46200 1 0 0 photodiode-1.sym
{
T 44300 47300 5 10 0 0 0 0 1
device=photodiode
T 44800 47000 5 10 1 1 180 0 1
refdes=SiPM
T 43800 46200 5 10 0 0 0 0 1
footprint=SIP2
}
N 44300 45800 44300 46200 4
{
T 44400 46100 5 10 1 1 0 0 1
netname=sig
}
C 44200 45800 1 270 0 resistor_0805.sym
{
T 45100 45600 5 10 0 0 270 0 1
device=RESISTOR
T 44550 45400 5 10 1 1 0 0 1
refdes=R4
T 44900 45600 5 10 0 0 270 0 1
footprint=0805
T 44550 45200 5 10 1 1 0 0 1
value=10k
}
N 44300 44900 44300 44500 4
N 43000 44700 44300 44700 4
N 43000 44700 43000 46200 4
C 43200 46200 1 90 0 capacitor_0805.sym
{
T 42100 46400 5 10 0 0 90 0 1
device=CAPACITOR
T 43250 46650 5 10 1 1 0 0 1
refdes=C2
T 41900 46400 5 10 0 0 90 0 1
symversion=0.1
T 42300 46400 5 10 0 0 90 0 1
footprint=1206
T 43250 46450 5 10 1 1 0 0 1
value=22nF/100V
}
N 43000 47500 44300 47500 4
N 43000 47500 43000 47100 4
C 44200 44200 1 0 0 gnd-1.sym
C 46700 46100 1 180 0 resistor_0805.sym
{
T 46500 45200 5 10 0 0 180 0 1
device=RESISTOR
T 46050 45700 5 10 1 1 0 0 1
refdes=R7
T 46500 45400 5 10 0 0 180 0 1
footprint=0805
T 46050 45500 5 10 1 1 0 0 1
value=10k
}
N 44300 46000 45800 46000 4
N 46700 46000 47100 46000 4
C 47000 45300 1 0 0 gnd-1.sym
C 47800 45400 1 180 0 vee-1.sym
C 47400 46400 1 0 0 vcc-1.sym
N 47600 46400 47600 46200 4
N 47600 46300 47825 46300 4
N 47825 46300 47825 46050 4
C 48100 47100 1 180 0 resistor_0805.sym
{
T 47900 46200 5 10 0 0 180 0 1
device=RESISTOR
T 47450 47400 5 10 1 1 0 0 1
refdes=R6
T 47900 46400 5 10 0 0 180 0 1
footprint=0805
T 47450 47200 5 10 1 1 0 0 1
value=10k
}
N 46900 46000 46900 47000 4
N 46900 47000 47200 47000 4
C 50500 45600 1 180 0 vee-1.sym
C 50100 46600 1 0 0 vcc-1.sym
N 50300 46600 50300 46400 4
N 50300 46500 50525 46500 4
N 50525 46500 50525 46250 4
C 48400 45600 1 0 0 capacitor_0805.sym
{
T 48600 46700 5 10 0 0 0 0 1
device=CAPACITOR
T 48750 45350 5 10 1 1 0 0 1
refdes=C10
T 48600 46900 5 10 0 0 0 0 1
symversion=0.1
T 48600 46500 5 10 0 0 0 0 1
footprint=0805
T 48750 45150 5 10 1 1 0 0 1
value=100nF
}
N 48100 45800 48400 45800 4
C 49600 44700 1 90 0 resistor_0805.sym
{
T 48700 44900 5 10 0 0 90 0 1
device=RESISTOR
T 49650 45200 5 10 1 1 0 0 1
refdes=R11
T 48900 44900 5 10 0 0 90 0 1
footprint=0805
T 49650 45000 5 10 1 1 0 0 1
value=62
}
C 49400 44200 1 0 0 gnd-1.sym
N 49500 44500 49500 44700 4
N 49500 45600 49500 45800 4
N 49300 45800 49800 45800 4
C 49600 46300 1 180 0 resistor_0805.sym
{
T 49400 45400 5 10 0 0 180 0 1
device=RESISTOR
T 49050 46600 5 10 1 1 0 0 1
refdes=R9
T 49400 45600 5 10 0 0 180 0 1
footprint=0805
T 49050 46400 5 10 1 1 0 0 1
value=62
}
N 49600 46200 49800 46200 4
C 48400 46300 1 270 0 gnd-1.sym
C 50800 47200 1 180 0 resistor_0805.sym
{
T 50600 46300 5 10 0 0 180 0 1
device=RESISTOR
T 50250 47500 5 10 1 1 0 0 1
refdes=R10
T 50600 46500 5 10 0 0 180 0 1
footprint=0805
T 50250 47300 5 10 1 1 0 0 1
value=240
}
N 49700 46200 49700 47100 4
N 49700 47100 49900 47100 4
N 50800 46000 51300 46000 4
N 50800 47100 51000 47100 4
N 51000 47100 51000 46000 4
C 51300 45800 1 0 0 capacitor_0805.sym
{
T 51500 46900 5 10 0 0 0 0 1
device=CAPACITOR
T 51650 45550 5 10 1 1 0 0 1
refdes=C13
T 51500 47100 5 10 0 0 0 0 1
symversion=0.1
T 51500 46700 5 10 0 0 0 0 1
footprint=0805
T 51650 45350 5 10 1 1 0 0 1
value=100nF
}
C 53100 46100 1 180 0 resistor_0805.sym
{
T 52900 45200 5 10 0 0 180 0 1
device=RESISTOR
T 52550 46400 5 10 1 1 0 0 1
refdes=R12
T 52900 45400 5 10 0 0 180 0 1
footprint=0805
T 52550 46200 5 10 1 1 0 0 1
value=47
}
C 53100 46500 1 180 1 LEMO_female.sym
{
T 53800 43900 5 10 0 1 180 6 1
footprint=CON_SMA__Amphenol_901-10112
T 53300 45700 5 10 1 1 180 6 1
refdes=LEMO_OUT
}
C 53700 46700 1 180 0 gnd-1.sym
N 48300 45800 48300 47000 4
N 48300 47000 48100 47000 4
N 44300 47100 44300 48300 4
{
T 44400 48200 5 10 1 1 0 0 1
netname=VBIN
}
N 45300 46000 45300 48800 4
N 45300 48800 48500 48800 4
C 48600 47900 1 90 0 capacitor_0805.sym
{
T 47500 48100 5 10 0 0 90 0 1
device=CAPACITOR
T 48450 48050 5 10 1 1 0 0 1
refdes=C4
T 47300 48100 5 10 0 0 90 0 1
symversion=0.1
T 47700 48100 5 10 0 0 90 0 1
footprint=0805
T 48450 47850 5 10 1 1 0 0 1
value=100nF
}
C 49700 47900 1 90 0 capacitor_0805.sym
{
T 48600 48100 5 10 0 0 90 0 1
device=CAPACITOR
T 49550 48050 5 10 1 1 0 0 1
refdes=C5
T 48400 48100 5 10 0 0 90 0 1
symversion=0.1
T 48800 48100 5 10 0 0 90 0 1
footprint=0805
T 49550 47850 5 10 1 1 0 0 1
value=100nF
}
C 49400 48900 1 180 0 resistor_0805.sym
{
T 49200 48000 5 10 0 0 180 0 1
device=RESISTOR
T 48850 49200 5 10 1 1 0 0 1
refdes=R3
T 49200 48200 5 10 0 0 180 0 1
footprint=0805
T 48850 49000 5 10 1 1 0 0 1
value=10k
}
N 49400 48800 49600 48800 4
C 50500 48900 1 180 0 resistor_0805.sym
{
T 50300 48000 5 10 0 0 180 0 1
device=RESISTOR
T 49950 49200 5 10 1 1 0 0 1
refdes=R5
T 50300 48200 5 10 0 0 180 0 1
footprint=0805
T 49950 49000 5 10 1 1 0 0 1
value=10k
}
C 48000 47900 1 270 0 gnd-1.sym
N 48300 47800 49500 47800 4
N 49500 47800 49500 47900 4
N 48400 47800 48400 47900 4
N 50500 48800 51400 48800 4
{
T 50800 48800 5 10 1 1 0 0 1
netname=DAC0
}
C 53800 47900 1 90 0 capacitor_0805.sym
{
T 52850 48150 5 10 1 1 0 0 1
value=100nF
T 52700 48100 5 10 0 0 90 0 1
device=CAPACITOR
T 52850 48350 5 10 1 1 0 0 1
refdes=C8
T 52500 48100 5 10 0 0 90 0 1
symversion=0.1
T 52900 48100 5 10 0 0 90 0 1
footprint=0805
}
C 53800 49000 1 90 0 capacitor_0805.sym
{
T 52700 49200 5 10 0 0 90 0 1
device=CAPACITOR
T 52850 49450 5 10 1 1 0 0 1
refdes=C12
T 52500 49200 5 10 0 0 90 0 1
symversion=0.1
T 52900 49200 5 10 0 0 90 0 1
footprint=0805
T 52850 49250 5 10 1 1 0 0 1
value=100nF
}
C 53800 47900 1 180 0 vee-1.sym
C 53400 49900 1 0 0 vcc-1.sym
N 53600 48800 53600 49000 4
N 53600 48900 53300 48900 4
C 53200 48600 1 0 0 gnd-1.sym
C 44200 48300 1 0 0 testpt-1.sym
{
T 45100 49000 5 10 1 1 180 0 1
refdes=TP_VBIN
T 44600 49200 5 10 0 0 0 0 1
device=TESTPOINT
T 44600 49000 5 10 0 0 0 0 1
footprint=SIP1
}
C 45300 48100 1 270 0 testpt-1.sym
{
T 45700 48100 5 10 1 1 0 0 1
refdes=TP_LP
T 46200 47700 5 10 0 0 270 0 1
device=TESTPOINT
T 46000 47700 5 10 0 0 270 0 1
footprint=SIP1
}
C 47600 41400 1 0 0 connector6-2.sym
{
T 48300 44300 5 10 1 1 0 6 1
refdes=CONN_FRONT2
T 47900 44250 5 10 0 0 0 0 1
device=CONNECTOR_6
T 47900 44450 5 10 0 0 0 0 1
footprint=SIP6
}
N 47600 43800 46800 43800 4
{
T 46900 43800 5 10 1 1 0 0 1
netname=ADC
}
N 47600 43400 46800 43400 4
{
T 46900 43400 5 10 1 1 0 0 1
netname=sig
}
N 47600 43000 47000 43000 4
C 47000 42800 1 90 0 vcc-1.sym
N 47600 42200 46800 42200 4
{
T 46900 42200 5 10 1 1 0 0 1
netname=VBIN
}
C 46700 42700 1 270 0 gnd-1.sym
N 47000 42600 47600 42600 4
C 46700 41900 1 270 0 gnd-1.sym
N 47000 41800 47600 41800 4
