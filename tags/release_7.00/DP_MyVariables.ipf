//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998//	last updated 8/7/2002//	Use this file to set all of your preferences for DataPro#pragma rtGlobals=1		// Use modern global access method.Function SetupGlobalsForMe()	// USER: DON'T CHANGE THE NEXT TWO LINES	String savDF=GetDataFolder(1)	SetDataFolder root:DP_ADCDACcontrol		// DECLARE THE digitizer variables	NVAR itc	SVAR unitsCurrent, unitsVoltage	//NVAR dac_current, dac_voltage, adc_current, adc_voltage	//NVAR dacgain0_current,dacgain1_current,dacgain2_current,dacgain3_current	//NVAR dacgain0_voltage,dacgain1_voltage,dacgain2_voltage,dacgain3_voltage	//NVAR adcgain0_current,adcgain1_current,adcgain2_current,adcgain3_current	//NVAR adcgain4_current,adcgain5_current,adcgain6_current,adcgain7_current	//NVAR adcgain0_voltage,adcgain1_voltage,adcgain2_voltage,adcgain3_voltage	//NVAR adcgain4_voltage,adcgain5_voltage,adcgain6_voltage,adcgain7_voltage	WAVE adcgain_current	WAVE adcgain_voltage	WAVE dacgain_current	WAVE dacgain_voltage	NVAR testadc	NVAR testdac	NVAR tpamp	NVAR tpgate	NVAR tpgateamp	NVAR tpdur	// Variables for the Data Pulse (StepPulse_DAC)	NVAR dplow	NVAR dphigh	NVAR dpshort	NVAR dplong	NVAR dpamp	NVAR dpdur	// Variables for synaptic stimulation	NVAR syntime	NVAR syndur	NVAR multdac, multdac0, multdac1, multdac2, multdac3, multdacD	//	what type of interface are you using?	itc=18	// set equal to 16 or 18//	Set the units you will be working in for current and voltage//	It is extremely important that you set the gains using the units you designate below//	For example, if you want to work in pA for current units,//	but your amplifier says the gain is 1 V/nA, you need to set the gain to 0.001 (V/pA)	unitsCurrent="pA"	unitsVoltage="mV"//	set up the dac and adc channels and gains (default values)////	setup the DAC/ADC channels used for voltage clamp and current clamp//	dac_current=0//	dac_voltage=0//	adc_current=0//	adc_voltage=1//	read DACgain values off the appropriate external command on the amplifier//	for voltage clamp, units are unitsVoltage/V	dacgain_current[0]=20	dacgain_current[1]=20	dacgain_current[2]=20		// for Isolator-10, make it 0.001, units are mA/V	dacgain_current[3]=20//	for current clamp, units are unitsCurrent/V	dacgain_voltage[0]=200	dacgain_voltage[1]=200		dacgain_voltage[2]=200	dacgain_voltage[3]=200//	multiplier values for dacs	multdac=1; multdac0=1; multdac1=1; multdac2=1; multdac3=1; multdacD=1//	read ADCgain values off the appropriate output on the amplifier//	don't forget filter gain and appropriate units conversion//	for voltage clamp, units are volts/unitsCurrent 	adcgain_current[0]=0.001	adcgain_current[1]=0.001	adcgain_current[2]=0.001	adcgain_current[3]=0.001	adcgain_current[4]=0.001	adcgain_current[5]=0.001	adcgain_current[6]=0.001	adcgain_current[7]=0.001//	for current clamp, units are volts/unitsVoltage	adcgain_voltage[0]=0.1	adcgain_voltage[1]=0.1	adcgain_voltage[2]=0.1	adcgain_voltage[3]=0.1	adcgain_voltage[4]=0.1	adcgain_voltage[5]=0.1	adcgain_voltage[6]=0.1	adcgain_voltage[7]=0.1//	Variables related to the Test Pulse	testadc=0			// display ADC in test pulse window	testdac=0			// output DAC for test pulse	tpamp=1	tpgate=5000	tpgateamp=10	tpdur=10//	Variables for the Data Pulse (StepPulse_DAC)	dplow=1	dphigh=200	dpshort=50	dplong=1000	dpamp=dplow	dpdur=dplong//	Variables for synaptic stimulation	syntime=50	syndur=0.1////	Variables for LTP analysis//	SetDataFolder root:DP_Analysis//	slope_left=8//	slope_right=30//	ltp_interval=10////	Variables for analysis display//	SetDataFolder root:DP_Browser//	ymax=3//	ymin=-3//	xmin=0//	xmax=100//	acsrx=0//	bcsrx=0	// USER: DON'T CHANGE ANYTHING BELOW HERE	SetDataFolder savDFEnd