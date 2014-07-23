v 20110115 2
C 40000 40000 0 0 0 title-B.sym
C 48900 44300 1 0 0 MAX13430.sym
{
T 49795 45100 5 10 1 1 0 0 1
refdes=U3
T 49100 46200 5 10 0 0 0 0 1
footprint=MSOP10
T 48900 44300 5 10 0 0 0 0 1
value=MAX13430E
}
C 43200 43600 1 0 0 ATtiny841-441.sym
{
T 43200 46800 5 10 0 0 0 0 1
footprint=SO14
T 43900 46300 5 10 1 1 0 6 1
refdes=U2
T 43200 47600 5 10 0 0 0 0 1
device=ATtiny841-441
T 43200 43600 5 10 0 0 0 0 1
value=ATtiny841
}
N 46000 44100 46800 44100 4
{
T 46300 44100 5 10 1 1 0 0 1
netname=MOSI
}
N 46000 44400 46800 44400 4
{
T 46300 44400 5 10 1 1 0 0 1
netname=MISO
}
N 46000 44700 46800 44700 4
{
T 46400 44700 5 10 1 1 0 0 1
netname=SCK
}
N 46000 45300 48900 45300 4
{
T 46000 45300 5 10 0 0 0 0 1
netname=RX
}
N 46000 45600 47400 45600 4
{
T 46000 45600 5 10 0 0 0 0 1
netname=TX
}
N 47400 45600 47400 44400 4
N 47400 44400 48900 44400 4
N 48900 45600 48600 45600 4
N 48600 45600 48600 46600 4
N 50900 45600 51200 45600 4
N 51200 45600 51200 46300 4
N 51200 46300 48600 46300 4
C 48400 46600 1 0 0 vcc-1.sym
N 47700 44700 48900 44700 4
{
T 47800 44700 5 10 1 1 0 0 1
netname=ENA
}
N 48600 44700 48600 45000 4
C 51100 43800 1 0 0 gnd-1.sym
N 51200 44100 51200 44400 4
N 51200 44400 50900 44400 4
C 51600 44900 1 270 0 resistor_0805.sym
{
T 52500 44700 5 10 0 0 270 0 1
device=RESISTOR
T 51950 44500 5 10 1 1 0 0 1
refdes=R8
T 52300 44700 5 10 0 0 270 0 1
footprint=my_SMD_603
T 51950 44300 5 10 1 1 0 0 1
value=120
}
N 50900 45300 52400 45300 4
{
T 51900 45300 5 10 1 1 0 0 1
netname=RTX-
}
N 50900 45000 52400 45000 4
{
T 51900 45000 5 10 1 1 0 0 1
netname=RTX+
}
N 51700 44900 51700 45300 4
N 51500 45000 51500 43900 4
N 51500 43900 51700 43900 4
N 51700 43900 51700 44000 4
N 42000 43800 43300 43800 4
{
T 42100 43800 5 10 1 1 0 0 1
netname=/RES
}
C 42600 43700 1 270 0 resistor_0805.sym
{
T 43500 43500 5 10 0 0 270 0 1
device=RESISTOR
T 42950 43300 5 10 1 1 0 0 1
refdes=R1
T 43300 43500 5 10 0 0 270 0 1
footprint=my_SMD_603
T 42950 43100 5 10 1 1 0 0 1
value=10k
}
N 42700 43700 42700 43800 4
C 42900 42700 1 180 0 vcc-1.sym
N 42700 42700 42700 42800 4
N 43300 44100 42000 44100 4
{
T 42100 44100 5 10 1 1 0 0 1
netname=DAC0
}
N 46000 43800 46800 43800 4
{
T 46800 43800 5 10 1 1 0 6 1
netname=DAC1
}
C 53100 49200 1 90 0 capacitor_0805.sym
{
T 52000 49400 5 10 0 0 90 0 1
device=CAPACITOR
T 52150 49650 5 10 1 1 0 0 1
refdes=C6
T 51800 49400 5 10 0 0 90 0 1
symversion=0.1
T 52200 49400 5 10 0 0 90 0 1
footprint=my_SMD_603
T 52150 49450 5 10 1 1 0 0 1
value=100nF
}
N 52400 49100 55900 49100 4
N 52900 50100 52900 50300 4
C 52700 50300 1 0 0 vcc-1.sym
C 52300 48800 1 0 0 gnd-1.sym
C 41100 45700 1 0 0 TMP35-36-37.sym
{
T 42100 47000 5 10 1 1 0 0 1
refdes=U1
T 41200 47400 5 10 0 0 0 0 1
footprint=TO92
T 41100 45700 5 10 0 0 0 0 1
value=TMP36
}
C 41800 45500 1 0 0 gnd-1.sym
C 41700 47100 1 0 0 vcc-1.sym
N 42700 46400 43000 46400 4
T 41100 47800 5 10 1 0 0 0 1
TEMPERATURE SENSOR
C 54100 49200 1 90 0 capacitor_0805.sym
{
T 53000 49400 5 10 0 0 90 0 1
device=CAPACITOR
T 53150 49650 5 10 1 1 0 0 1
refdes=C7
T 52800 49400 5 10 0 0 90 0 1
symversion=0.1
T 53200 49400 5 10 0 0 90 0 1
footprint=my_SMD_603
T 53150 49450 5 10 1 1 0 0 1
value=100nF
}
N 53900 49100 53900 49200 4
N 53900 50100 53900 50200 4
N 52900 50200 55900 50200 4
C 43000 44900 1 180 0 capacitor_0805.sym
{
T 42800 43800 5 10 0 0 180 0 1
device=CAPACITOR
T 42650 45150 5 10 1 1 180 0 1
refdes=C1
T 42800 43600 5 10 0 0 180 0 1
symversion=0.1
T 42800 44000 5 10 0 0 180 0 1
footprint=my_SMD_603
T 42650 45350 5 10 1 1 180 0 1
value=100nF
}
C 41800 44800 1 270 0 gnd-1.sym
N 52900 49100 52900 49200 4
T 53500 50500 5 10 1 0 0 0 1
BYPASS CAPACITORS
N 54500 44400 55300 44400 4
{
T 54600 44400 5 10 1 1 0 0 1
netname=MISO
}
N 54500 43600 55300 43600 4
{
T 54600 43600 5 10 1 1 0 0 1
netname=SCK
}
N 54500 42800 55300 42800 4
{
T 54600 42800 5 10 1 1 0 0 1
netname=/RES
}
C 54800 43800 1 90 0 vcc-1.sym
N 54800 44000 55300 44000 4
N 54500 43200 55300 43200 4
{
T 54600 43200 5 10 1 1 0 0 1
netname=MOSI
}
C 54500 42500 1 270 0 gnd-1.sym
N 54800 42400 55300 42400 4
C 43100 45700 1 0 0 vcc-1.sym
C 43200 45000 1 0 0 gnd-1.sym
N 43300 45700 43300 45600 4
C 54800 47300 1 90 0 vee-1.sym
C 54800 46900 1 90 0 vcc-1.sym
C 53500 46800 1 270 0 gnd-1.sym
N 53800 46700 55300 46700 4
N 54800 47100 55300 47100 4
N 54800 47500 55300 47500 4
C 55100 49200 1 90 0 capacitor_0805.sym
{
T 54000 49400 5 10 0 0 90 0 1
device=CAPACITOR
T 54150 49650 5 10 1 1 0 0 1
refdes=C11
T 53800 49400 5 10 0 0 90 0 1
symversion=0.1
T 54200 49400 5 10 0 0 90 0 1
footprint=my_SMD_603
T 54150 49450 5 10 1 1 0 0 1
value=100nF
}
N 54900 49100 54900 49200 4
N 54900 50200 54900 50100 4
N 55300 45900 54600 45900 4
{
T 54700 45900 5 10 1 1 0 0 1
netname=RTX-
}
N 55300 46300 54600 46300 4
{
T 54700 46300 5 10 1 1 0 0 1
netname=RTX+
}
N 54000 47900 55300 47900 4
{
T 54600 47900 5 10 1 1 0 0 1
netname=VBIN
}
C 55300 45500 1 0 0 connector6-2.sym
{
T 56000 48400 5 10 1 1 0 6 1
refdes=CONN_SLOW_CONTROL
T 55600 48350 5 10 0 0 0 0 1
device=CONNECTOR_6
T 55600 48550 5 10 0 0 0 0 1
footprint=HEADER6_2
T 55300 45500 5 10 0 0 0 0 1
value=SLOW CONTROL
}
C 54200 46900 1 90 0 capacitor_0805.sym
{
T 53100 47100 5 10 0 0 90 0 1
device=CAPACITOR
T 52750 47350 5 10 1 1 0 0 1
refdes=C3
T 52900 47100 5 10 0 0 90 0 1
symversion=0.1
T 53300 47100 5 10 0 0 90 0 1
footprint=my_SMD_603
T 52750 47150 5 10 1 1 0 0 1
value=100nF/100V
}
N 54000 46700 54000 46900 4
N 54000 47900 54000 47800 4
C 55300 42000 1 0 0 connector6-2.sym
{
T 56000 44900 5 10 1 1 0 6 1
refdes=CONN_ISP
T 55600 44850 5 10 0 0 0 0 1
device=CONNECTOR_6
T 55600 45050 5 10 0 0 0 0 1
footprint=HEADER6_2
T 55300 42000 5 10 0 0 0 0 1
value=ISP
}
C 50800 47500 1 0 0 connector6-2.sym
{
T 51500 50400 5 10 1 1 0 6 1
refdes=CONN_MAIN
T 51100 50350 5 10 0 0 0 0 1
device=CONNECTOR_6
T 51100 50550 5 10 0 0 0 0 1
footprint=SIP6
T 50800 47500 5 10 0 0 0 0 1
value=CONN MALE
}
N 50800 49500 50000 49500 4
{
T 50100 49500 5 10 1 1 0 0 1
netname=ADC
}
N 50800 48300 50000 48300 4
{
T 50100 48300 5 10 1 1 0 0 1
netname=sig
}
N 50800 49100 50200 49100 4
C 50200 48900 1 90 0 vcc-1.sym
N 50800 48700 50000 48700 4
{
T 50100 48700 5 10 1 1 0 0 1
netname=VBIN
}
C 49900 50000 1 270 0 gnd-1.sym
N 50200 49900 50800 49900 4
C 49900 48000 1 270 0 gnd-1.sym
N 50200 47900 50800 47900 4
N 43000 44700 43000 46400 4
N 48900 45000 48600 45000 4
N 46000 45900 47700 45900 4
N 43300 44700 43000 44700 4
{
T 42600 45600 5 10 1 1 0 0 1
netname=ADC
}
C 56100 49200 1 90 0 capacitor_0805.sym
{
T 55000 49400 5 10 0 0 90 0 1
device=CAPACITOR
T 55150 49650 5 10 1 1 0 0 1
refdes=C20
T 54800 49400 5 10 0 0 90 0 1
symversion=0.1
T 55200 49400 5 10 0 0 90 0 1
footprint=my_SMD_603
T 55150 49450 5 10 1 1 0 0 1
value=2.2uF
}
N 55900 50200 55900 50100 4
N 55900 49200 55900 49100 4
N 47700 44700 47700 45900 4
