import ROOT
import numpy
from math import *

# open file
file_name = raw_input("Enter file name: ")
in_file = ROOT.TFile( str(file_name), "OPEN" )

print "[Temperature Analysis] - Successfully opened '" + file_name + "'"

# extract tree
in_tree = in_file.Get("temp_cal")
# now we need nMeas and nStep for looping over all data
# need numpy arrays to mimic c++ pointers
nMeas = numpy.zeros(1, dtype=int)
nSteps = numpy.zeros(1, dtype=int)

in_tree.SetBranchAddress("nMeas", nMeas)	# instead of &nMeas
in_tree.SetBranchAddress("nSteps", nSteps)
in_tree.GetEntry(0)

print "[Temperature Analysis] - Found tree with nMeas=" + str(nMeas[0]) + " and nSteps=" + str(nSteps[0])

# need ADC counts and temperature
temperature = numpy.zeros(1, dtype=numpy.float32)	# = Float_t (32 bit floating point number)
adc_counts = numpy.zeros(1, dtype=int)

in_tree.SetBranchAddress("temperature", temperature)
in_tree.SetBranchAddress("adc_count", adc_counts)

c1 = ROOT.TCanvas()
c1.Divide(2);
gr_temperature = ROOT.TGraphErrors()
gr_temperature.SetTitle("Temperature probe calibration (Pt100 simulator);ADC [count];T_{sim} [#circC]")
gr_temperature.SetMarkerStyle(7)

gr_res = ROOT.TGraphErrors()
gr_res.SetTitle("Residuals;ADC [count];T_{sim} - T_{fit} [#circC]")
gr_res.SetMarkerStyle(7)

fit = ROOT.TF1("fit", "[0] + [1]*x")
fit.SetParNames("TOffset [#circC]", "TGain [#circC/count]")
zero = ROOT.TF1("zero", "0", -1000, 100000)

adc_mean_list = []
adc_rms_list = []
temperature_list = []

for iStep in range(nSteps):
	adc_mean = 0.
	adc_mean2 = 0.
	for iMeas in range(nMeas):
		in_tree.GetEntry(iMeas + iStep*nMeas)
		adc_mean += adc_counts[0]
		adc_mean2 += adc_counts[0]*adc_counts[0]

	adc_mean = adc_mean/nMeas
	adc_mean_list.append(adc_mean)
	adc_mean2 = adc_mean2/nMeas

	temperature_list.append(temperature[0])

	# calculate rms
	adc_rms_list.append( sqrt( adc_mean2 - adc_mean*adc_mean) )
	print "[Temperature Analysis] - " + str(iStep) + " " + str(adc_mean) + "+-" + str(adc_rms_list[iStep]) + "\t" + str(temperature[0]) + "degC"
	gr_temperature.SetPoint(iStep, adc_mean, temperature[0]) 
	gr_temperature.SetPointError(iStep, adc_rms_list[iStep], 0.0001)

c1.cd(1)
gr_temperature.Fit(fit)
gr_temperature.Draw("AP")

res_list = []
# residuals
for iStep in range(nSteps):
	res_list.append( temperature_list[iStep] - fit(adc_mean_list[iStep]) )
	gr_res.SetPoint(iStep, adc_mean_list[iStep], res_list[iStep])
	gr_res.SetPointError(iStep, adc_rms_list[iStep], 0.)

c1.cd(2)
gr_res.Draw("AP")
zero.Draw("SAME")

c1.Update()

raw_input("Press enter to exit...") 
