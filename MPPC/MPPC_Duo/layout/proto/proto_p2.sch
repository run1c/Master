v 20110115 2
C 40000 40000 0 0 0 title-B.sym
C 40000 40000 0 0 0 title-B.sym
C 42900 46100 1 0 0 MAX5215.sym
{
T 43795 46900 5 10 1 1 0 0 1
refdes=U3
T 43100 48000 5 10 0 0 0 0 1
footprint=MSOP8
}
N 44900 47400 45000 47400 4
N 45000 47400 45000 48000 4
N 45000 48000 42700 48000 4
N 42700 47100 42700 48400 4
N 42700 47100 42900 47100 4
N 42900 47400 42300 47400 4
N 42300 47400 42300 48400 4
N 44900 47100 45200 47100 4
N 45200 47100 45200 48200 4
N 45200 48200 42300 48200 4
C 42100 48400 1 0 0 vcc-1.sym
C 42800 48700 1 180 0 gnd-1.sym
N 42900 46800 41700 46800 4
{
T 41900 46800 5 10 1 1 0 0 1
netname=SCL
}
N 42900 46500 41700 46500 4
{
T 41900 46500 5 10 1 1 0 0 1
netname=SDA
}
C 52600 50000 1 270 0 capacitor_0805.sym
{
T 53700 49800 5 10 0 0 270 0 1
device=CAPACITOR
T 53250 49150 5 10 1 1 90 0 1
refdes=CBP_ADVDD
T 53900 49800 5 10 0 0 270 0 1
symversion=0.1
T 53500 49800 5 10 0 0 270 0 1
footprint=0805
T 53450 49150 5 10 1 1 90 0 1
value=100nF
}
C 51600 50000 1 270 0 capacitor_0805.sym
{
T 52700 49800 5 10 0 0 270 0 1
device=CAPACITOR
T 52250 49150 5 10 1 1 90 0 1
refdes=CBP_ADREF
T 52900 49800 5 10 0 0 270 0 1
symversion=0.1
T 52500 49800 5 10 0 0 270 0 1
footprint=0805
T 52450 49150 5 10 1 1 90 0 1
value=100nF
}
N 52800 50000 52800 50300 4
N 49500 50300 55700 50300 4
N 51800 50300 51800 50000 4
N 51800 49100 51800 48800 4
N 49500 48800 55700 48800 4
N 52800 48800 52800 49100 4
C 52200 44800 1 0 0 MAX998EU_T.sym
{
T 48800 46200 5 10 0 0 0 0 1
device=MAX988EU-T
T 52400 45700 5 10 1 1 0 0 1
refdes=U10
T 48800 45800 5 10 0 0 0 0 1
footprint=SOT26
T 48800 46400 5 10 0 0 0 0 1
symversion=0.2
}
C 52500 45800 1 0 0 vcc-1.sym
C 52600 44500 1 0 0 gnd-1.sym
N 52700 45800 52700 45600 4
C 49100 44600 1 0 0 MAX4224.sym
{
T 45700 46000 5 10 0 0 0 0 1
device=SINGLE OPAMP
T 49300 45500 5 10 1 1 0 0 1
refdes=U5
T 45700 45600 5 10 0 0 0 0 1
footprint=SOT26
T 45700 46200 5 10 0 0 0 0 1
symversion=0.2
}
C 49400 45500 1 0 0 vcc-1.sym
C 49800 44600 1 180 0 vee-1.sym
C 48800 44900 1 270 0 gnd-1.sym
C 49100 45900 1 0 0 resistor_0805.sym
{
T 49300 46800 5 10 0 0 0 0 1
device=RESISTOR
T 49350 46400 5 10 1 1 0 0 1
refdes=R_HG_F
T 49300 46600 5 10 0 0 0 0 1
footprint=0805
T 49350 46200 5 10 1 1 0 0 1
value=130
}
N 48700 45200 48700 46000 4
N 48700 46000 49100 46000 4
N 50000 46000 50400 46000 4
N 50400 46000 50400 45000 4
N 49600 45500 49600 45400 4
N 49600 45400 49825 45400 4
N 49825 45400 49825 45250 4
N 52700 45700 52925 45700 4
N 52925 45700 52925 45450 4
C 50600 50000 1 270 0 capacitor_0805.sym
{
T 51700 49800 5 10 0 0 270 0 1
device=CAPACITOR
T 51250 49150 5 10 1 1 90 0 1
refdes=CBP_COMP
T 51900 49800 5 10 0 0 270 0 1
symversion=0.1
T 51500 49800 5 10 0 0 270 0 1
footprint=0805
T 51450 49150 5 10 1 1 90 0 1
value=100nF
}
C 49600 50000 1 270 0 capacitor_0805.sym
{
T 50700 49800 5 10 0 0 270 0 1
device=CAPACITOR
T 50250 49150 5 10 1 1 90 0 1
refdes=CBP_HG
T 50900 49800 5 10 0 0 270 0 1
symversion=0.1
T 50500 49800 5 10 0 0 270 0 1
footprint=0805
T 50450 49150 5 10 1 1 90 0 1
value=100nF
}
N 50800 48800 50800 49100 4
N 49800 48800 49800 49100 4
N 49800 50000 49800 50300 4
N 50800 50000 50800 50300 4
C 49200 48900 1 270 0 gnd-1.sym
C 49500 50100 1 90 0 vcc-1.sym
N 53800 48800 53800 49100 4
N 53800 50300 53800 50000 4
N 52200 45400 52100 45400 4
N 52100 45400 52100 46800 4
N 52100 46800 44900 46800 4
{
T 45300 46900 5 10 1 1 0 0 1
netname=THRESHOLD
}
C 43700 42300 1 0 0 MAX4228.sym
{
T 43700 43700 5 10 0 0 0 0 1
device=DUAL_OPAMP
T 43700 43200 5 10 1 1 0 0 1
refdes=U4
T 43700 43300 5 10 0 0 0 0 1
footprint=MSOP10
T 43700 43900 5 10 0 0 0 0 1
symversion=0.2
T 43700 42300 5 10 0 0 0 0 1
slot=1
}
C 49000 42100 1 0 0 MAX4228.sym
{
T 49000 43500 5 10 0 0 0 0 1
device=DUAL_OPAMP
T 48900 43000 5 10 1 1 0 0 1
refdes=U4
T 49000 43100 5 10 0 0 0 0 1
footprint=MSOP10
T 49000 43700 5 10 0 0 0 0 1
symversion=0.2
T 49000 42100 5 10 0 0 0 0 1
slot=2
}
C 49300 43000 1 0 0 vcc-1.sym
N 49500 43000 49500 42900 4
N 49500 42900 49725 42900 4
N 49725 42900 49725 42750 4
C 49700 42100 1 180 0 vee-1.sym
C 49100 43500 1 0 0 resistor_0805.sym
{
T 49300 44400 5 10 0 0 0 0 1
device=RESISTOR
T 49150 44000 5 10 1 1 0 0 1
refdes=R_DIFF_F
T 49300 44200 5 10 0 0 0 0 1
footprint=0805
T 49150 43800 5 10 1 1 0 0 1
value=240
}
C 47500 42600 1 0 0 resistor_0805.sym
{
T 47700 43500 5 10 0 0 0 0 1
device=RESISTOR
T 47750 43100 5 10 1 1 0 0 1
refdes=R_DIFF_G
T 47700 43300 5 10 0 0 0 0 1
footprint=0805
T 47750 42900 5 10 1 1 0 0 1
value=62
}
N 48400 42700 49000 42700 4
N 49100 43600 48700 43600 4
N 48700 43600 48700 42700 4
C 48700 42400 1 270 0 gnd-1.sym
C 47200 42500 1 270 0 resistor_0805.sym
{
T 48100 42300 5 10 0 0 270 0 1
device=RESISTOR
T 47550 42200 5 10 1 1 0 0 1
refdes=R_HP
T 47900 42300 5 10 0 0 270 0 1
footprint=0805
T 47550 42000 5 10 1 1 0 0 1
value=62
}
C 46200 42500 1 0 0 capacitor_0805.sym
{
T 46400 43600 5 10 0 0 0 0 1
device=CAPACITOR
T 47050 43150 5 10 1 1 180 0 1
refdes=C_HP
T 46400 43800 5 10 0 0 0 0 1
symversion=0.1
T 46400 43400 5 10 0 0 0 0 1
footprint=0805
T 47050 43350 5 10 1 1 180 0 1
value=100pF
}
N 47100 42700 47500 42700 4
N 47300 42500 47300 42700 4
N 44700 42700 46200 42700 4
C 47200 41100 1 0 0 gnd-1.sym
N 47300 41400 47300 41600 4
C 45600 42700 1 180 0 testpt-1.sym
{
T 45600 42200 5 8 1 1 0 0 1
refdes=TP_PREAMP
T 45200 41800 5 10 0 0 180 0 1
device=TESTPOINT
T 45200 42000 5 10 0 0 180 0 1
footprint=SIP1
}
N 50000 42500 50500 42500 4
N 50000 43600 50300 43600 4
N 50300 43600 50300 42500 4
C 44400 42300 1 180 0 vee-1.sym
N 44200 43100 44425 43100 4
N 44425 43100 44425 42950 4
N 44200 43200 44200 43100 4
C 44000 43200 1 0 0 vcc-1.sym
C 43400 42600 1 270 0 gnd-1.sym
C 42400 42800 1 0 0 resistor_0805.sym
{
T 42600 43700 5 10 0 0 0 0 1
device=RESISTOR
T 42250 43300 5 10 1 1 0 0 1
refdes=R_PREAMP_G
T 42600 43500 5 10 0 0 0 0 1
footprint=0805
T 42250 43100 5 10 1 1 0 0 1
value=62
}
N 43300 42900 43700 42900 4
N 43500 43800 43500 42900 4
C 43800 43700 1 0 0 resistor_0805.sym
{
T 44000 44600 5 10 0 0 0 0 1
device=RESISTOR
T 43250 44200 5 10 1 1 0 0 1
refdes=R_PREAMP_F
T 44000 44400 5 10 0 0 0 0 1
footprint=0805
T 43650 44000 5 10 1 1 0 0 1
value=240
}
N 44700 43800 45000 43800 4
N 43800 43800 43500 43800 4
C 47400 45100 1 0 0 resistor_0805.sym
{
T 47600 46000 5 10 0 0 0 0 1
device=RESISTOR
T 47550 45600 5 10 1 1 0 0 1
refdes=R_HG_G
T 47600 45800 5 10 0 0 0 0 1
footprint=0805
T 47550 45400 5 10 1 1 0 0 1
value=15
}
N 48300 45200 49100 45200 4
C 41900 41200 1 0 0 gnd-1.sym
N 42000 41500 42000 41800 4
C 41900 42700 1 270 0 resistor_0805.sym
{
T 42800 42500 5 10 0 0 270 0 1
device=RESISTOR
T 42250 42300 5 10 1 1 0 0 1
refdes=R_PD_SIPM
T 42600 42500 5 10 0 0 270 0 1
footprint=0805
T 42250 42100 5 10 1 1 0 0 1
value=10k
}
N 42000 42700 42000 43400 4
N 42000 42900 42400 42900 4
C 41500 43400 1 0 0 photodiode-1.sym
{
T 42000 44500 5 10 0 0 0 0 1
device=photodiode
T 42700 44200 5 10 1 1 180 0 1
refdes=SiPM
T 41500 43400 5 10 0 0 0 0 1
footprint=SIP2
}
N 42000 44300 42000 45000 4
{
T 42300 45100 5 10 1 1 0 0 1
netname=VB
}
C 40600 43400 1 270 0 capacitor_0805.sym
{
T 41700 43200 5 10 0 0 270 0 1
device=CAPACITOR
T 40850 43250 5 10 1 1 0 0 1
refdes=C_BP_SIPM
T 41900 43200 5 10 0 0 270 0 1
symversion=0.1
T 41500 43200 5 10 0 0 270 0 1
footprint=0805
T 40850 43050 5 10 1 1 0 0 1
value=22nF/100V
}
N 42000 44500 40800 44500 4
N 40800 44500 40800 43400 4
N 40800 42500 40800 41600 4
N 40800 41600 42000 41600 4
C 51600 42400 1 0 0 resistor_0805.sym
{
T 51800 43300 5 10 0 0 0 0 1
device=RESISTOR
T 51850 42900 5 10 1 1 0 0 1
refdes=R_LEMO
T 51800 43100 5 10 0 0 0 0 1
footprint=0805
T 51850 42700 5 10 1 1 0 0 1
value=47
}
C 50500 42300 1 0 0 capacitor_0805.sym
{
T 50700 43400 5 10 0 0 0 0 1
device=CAPACITOR
T 51350 42950 5 10 1 1 180 0 1
refdes=C_LEMO
T 50700 43600 5 10 0 0 0 0 1
symversion=0.1
T 50700 43200 5 10 0 0 0 0 1
footprint=0805
T 51350 43150 5 10 1 1 180 0 1
value=100nF
}
N 51400 42500 51600 42500 4
C 52700 42000 1 0 0 LEMO_female.sym
{
T 53400 44600 5 10 0 1 0 0 1
footprint=CON_SMA__Amphenol_901-10112
T 52900 42800 5 10 1 1 0 0 1
refdes=LEMO_OUT
}
N 52700 42500 52500 42500 4
C 53100 41800 1 0 0 gnd-1.sym
N 53200 45200 53900 45200 4
{
T 54000 45100 5 10 1 1 0 0 1
netname=COMP_OUT
}
C 51000 45000 1 180 0 testpt-1.sym
{
T 51000 44500 5 8 1 1 0 0 1
refdes=TP_HG
T 50600 44100 5 10 0 0 180 0 1
device=TESTPOINT
T 50600 44300 5 10 0 0 180 0 1
footprint=SIP1
}
C 53800 45200 1 0 0 testpt-1.sym
{
T 54000 45600 5 8 1 1 0 0 1
refdes=TP_CL
T 54200 46100 5 10 0 0 0 0 1
device=TESTPOINT
T 54200 45900 5 10 0 0 0 0 1
footprint=SIP1
}
C 47100 46800 1 0 0 testpt-1.sym
{
T 47300 47200 5 8 1 1 0 0 1
refdes=TP_THRESH
T 47500 47700 5 10 0 0 0 0 1
device=TESTPOINT
T 47500 47500 5 10 0 0 0 0 1
footprint=SIP1
}
C 54000 50000 1 90 1 capacitor_0805.sym
{
T 52900 49800 5 10 0 0 270 2 1
device=CAPACITOR
T 54150 49150 5 10 1 1 90 2 1
refdes=CBP_THR
T 52700 49800 5 10 0 0 270 2 1
symversion=0.1
T 53100 49800 5 10 0 0 270 2 1
footprint=0805
T 54350 49150 5 10 1 1 90 2 1
value=100nF
}
N 45000 43800 45000 42700 4
N 46000 42700 46000 45200 4
N 46000 45200 47400 45200 4
C 50800 44800 1 0 0 capacitor_0805.sym
{
T 51000 45900 5 10 0 0 0 0 1
device=CAPACITOR
T 51650 45450 5 10 1 1 180 0 1
refdes=C_DEC
T 51000 46100 5 10 0 0 0 0 1
symversion=0.1
T 51000 45700 5 10 0 0 0 0 1
footprint=0805
T 51650 45650 5 10 1 1 180 0 1
value=100nF
}
N 50800 45000 50100 45000 4
N 51700 45000 52200 45000 4
C 49500 47100 1 90 0 vee-1.sym
C 49600 48500 1 270 0 capacitor_0805.sym
{
T 50700 48300 5 10 0 0 270 0 1
device=CAPACITOR
T 50250 47650 5 10 1 1 90 0 1
refdes=CBP_HG2
T 50900 48300 5 10 0 0 270 0 1
symversion=0.1
T 50500 48300 5 10 0 0 270 0 1
footprint=0805
T 50450 47650 5 10 1 1 90 0 1
value=100nF
}
C 55000 50000 1 90 1 capacitor_0805.sym
{
T 53900 49800 5 10 0 0 270 2 1
device=CAPACITOR
T 55050 48950 5 10 1 1 90 2 1
refdes=CBP_PREAMP
T 53700 49800 5 10 0 0 270 2 1
symversion=0.1
T 54100 49800 5 10 0 0 270 2 1
footprint=0805
T 55250 48950 5 10 1 1 90 2 1
value=100nF
}
N 54800 48800 54800 49100 4
N 54800 50300 54800 50000 4
C 51000 48500 1 90 1 capacitor_0805.sym
{
T 49900 48300 5 10 0 0 270 2 1
device=CAPACITOR
T 51050 47350 5 10 1 1 90 2 1
refdes=CBP_PREAMP2
T 49700 48300 5 10 0 0 270 2 1
symversion=0.1
T 50100 48300 5 10 0 0 270 2 1
footprint=0805
T 51250 47350 5 10 1 1 90 2 1
value=100nF
}
N 49500 47300 50800 47300 4
N 50800 47300 50800 47600 4
N 50800 48500 50800 48800 4
N 49800 48800 49800 48500 4
N 49800 47600 49800 47300 4
C 55900 50000 1 90 1 capacitor_0805.sym
{
T 54800 49800 5 10 0 0 270 2 1
device=CAPACITOR
T 55950 48950 5 10 1 1 90 2 1
refdes=CBP_PREAMP2
T 54600 49800 5 10 0 0 270 2 1
symversion=0.1
T 55000 49800 5 10 0 0 270 2 1
footprint=0805
T 56150 48950 5 10 1 1 90 2 1
value=100nF
}
N 55700 48800 55700 49100 4
N 55700 50000 55700 50300 4
T 53900 40100 5 10 1 0 0 0 1
Weinstock, Lars Steffen, BSc RWTH
T 53900 40400 5 10 1 0 0 0 1
1
T 50000 40400 5 10 1 0 0 0 1
proto.sch
T 50000 40100 5 10 1 0 0 0 1
2
T 50000 40700 5 10 1 0 0 0 1
MPPC_S Prototype
T 52300 50600 5 10 1 0 0 0 1
BYPASS CAPACITORS
T 46400 43900 5 10 1 0 0 0 1
LOW GAIN DIFFERENTIATOR
T 51500 40100 5 10 1 0 0 0 1
3
C 46000 46800 1 90 1 capacitor_0805.sym
{
T 44900 46600 5 10 0 0 270 2 1
device=CAPACITOR
T 46150 45850 5 10 1 1 90 2 1
refdes=C_THR
T 44700 46600 5 10 0 0 270 2 1
symversion=0.1
T 45100 46600 5 10 0 0 270 2 1
footprint=0805
T 46350 45850 5 10 1 1 90 2 1
value=47nF
}
C 45700 45600 1 0 0 gnd-1.sym
