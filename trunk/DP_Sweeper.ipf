//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998#pragma rtGlobals=1		// Use modern global access method.Function SweeperConstructor()	// Save the current DF	String savedDF=GetDataFolder(1)		// Create a new DF	NewDataFolder /O/S root:DP_Sweeper		// Should we run the user's custom automatic analysis function after each sweep?	Variable /G autoAnalyzeChecked=0		// true iff AutoAnalyze checkbox is checked	// Variables controlling the trials and sweeps	Variable /G iSweep=1		// index of the current/next sweep to be acquired	Variable /G nSweepsPerTrial=1	Variable /G sweepInterval=10		// seconds	// These are used by all kinds of Sweeper stimuli	Variable /G dt=0.05	// sampling interval, ms	Variable /G totalDuration=200		// total duration, ms	// These control the StepPulse_DAC wave	Variable /G stepPulseAmplitude=1		// amplitude in units given by channel mode	Variable /G stepPulseDuration=100		// duration in ms	// Initialize the StepPulse wave	Make /O StepPulse_DAC	SweeperUpdateStepPulseWave()	// Parameters of SynPulse_TTL	Variable /G synPulseDelay=50		Variable /G synPulseDuration=0.1	// ms	// Initialize the SynPulse wave	Make /O SynPulse_TTL	SweeperUpdateSynPulseWave()	// Multipliers for the DAC channels	Variable nDACChannels=getNumberOfDACChannels()	Make /O /N=(nDACChannels) dacMultiplier={1,1,1,1}		// string variables for adc in wave names	Variable nADCChannels=getNumberOfADCChannels()	Make /O/T/N=(nADCChannels) adcBaseName={"ad0","ad1","ad2","ad3","ad4","ad5","ad6","ad7"}	// wave names for DAC, TTL output channels	Make /O /T /N=(nDACChannels) dacWaveName	dacWaveName={"StepPulse_DAC","StepPulse_DAC","StepPulse_DAC","StepPulse_DAC"}	Variable nTTLChannels=getNumberOfTTLChannels()	Make /O /T /N=(nTTLChannels) ttlOutputWaveName	ttlOutputWaveName={"SynPulse_TTL","SynPulse_TTL","SynPulse_TTL","SynPulse_TTL"}		// Make waves to read which adc/dac/ttl devices should be on	Make /O /N=(nADCChannels) adcChannelOn	adcChannelOn[0]=1		// turn on ADC 0 by default, leave rest off	Make /O /N=(nDACChannels) dacChannelOn	dacChannelOn[0]=1		// turn on DAC 0 by default, leave rest off	Make /O /N=(nTTLChannels) ttlOutputChannelOn  	// all TTL outputs off by default		// Do the usr customization	SetupSweeperForUser()  // Allows user to set desired channel gains, etc.		// Restore the original data folder	SetDataFolder savedDFEndFunction SweeperUpdateStepPulseWave()	// Updates the step pulse wave to be consistent with the rest of the model state.	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper		NVAR dt, totalDuration,stepPulseAmplitude, stepPulseDuration	WAVE StepPulse_DAC	// bound wave		Variable offDuration=totalDuration-stepPulseDuration	Variable delayDuration=offDuration/4	Duplicate /O SimplePulse(dt,totalDuration,delayDuration,stepPulseDuration,stepPulseAmplitude) StepPulse_DAC		Note /K StepPulse_DAC	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"WAVETYPE","StepPulse")	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"TIME",time())	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"duration",num2str(stepPulseDuration))	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"amplitude",num2str(stepPulseAmplitude))	SetDataFolder savedDFEndFunction resampleStepPulseBang(w,dt,totalDuration)	Wave w	Variable dt, totalDuration		Variable duration=NumberByKeyInWaveNote(w,"duration")	Variable amplitude=NumberByKeyInWaveNote(w,"amplitude")		resampleStepPulseFromParamsBang(w,dt,totalDuration,duration,amplitude)EndFunction resampleStepPulseFromParamsBang(w,dt,totalDuration,duration,amplitude)	// Compute the sine wave from the parameters	Wave w	Variable dt,totalDuration,duration,amplitude		Variable nScans=numberOfScans(dt,totalDuration)	Redimension /N=(nScans) w	Setscale /P x, 0, dt, "ms", w	Variable offDuration=totalDuration-duration	Variable delay=offDuration/4	Wave temp	Duplicate /FREE SimplePulse(dt,totalDuration,delay,duration,amplitude) temp	w=tempEndFunction SweeperUpdateSynPulseWave()	// Updates the step pulse wave to be consistent with the rest of the model state.	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	NVAR dt, totalDuration, synPulseDelay, synPulseDuration	WAVE SynPulse_TTL	Duplicate /O SimplePulseBoolean(dt,totalDuration,synPulseDelay,synPulseDuration) SynPulse_TTL	Note /K SynPulse_TTL	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"WAVETYPE","SynPulse")	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"TIME",time())	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"delay",num2str(synPulseDelay))	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"duration",num2str(synPulseDuration))	SetDataFolder savedDFEndFunction resampleSynPulseBang(w,dt,totalDuration)	Wave w	Variable dt, totalDuration		Variable delay=NumberByKeyInWaveNote(w,"delay")	Variable duration=NumberByKeyInWaveNote(w,"duration")		resampleSynPulseFromParamsBang(w,dt,totalDuration,delay,duration)EndFunction resampleSynPulseFromParamsBang(w,dt,totalDuration,delay,duration)	// Compute the sine wave from the parameters	Wave w	Variable dt,totalDuration,delay,duration		Variable nScans=numberOfScans(dt,totalDuration)	Redimension /N=(nScans) w	Setscale /P x, 0, dt, "ms", w	Wave temp	Duplicate /FREE SimplePulseBoolean(dt,totalDuration,delay,duration) temp	w=tempEndFunction GetNumADCChannelsInUse()	// Gets the number of ADC channels currently in use in the model.		// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Declare the DF vars we need	WAVE adcChannelOn	Variable nADCChannels=GetNumberOfADCChannels()	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		Variable nADCChannelsInUse=0	Variable i	for (i=0; i<nADCChannels; i+=1)		nADCChannelsInUse+=adcChannelOn[i]	endfor		// Restore the original DF	SetDataFolder savedDF	return nADCChannelsInUseEndFunction GetNumDACChannelsInUse()	// Gets the number of DAC channels currently in use in the model.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Declare the DF vars we need	WAVE dacChannelOn	Variable nDACChannels=GetNumberOfDACChannels()	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		Variable nDACChannelsInUse=0	Variable i	for (i=0; i<nDACChannels; i+=1)		nDACChannelsInUse+=dacChannelOn[i]	endfor		// Restore the original DF	SetDataFolder savedDF	return nDACChannelsInUseEndFunction GetNumTTLOutputChannelsInUse()	// Gets the number of TTL output channels currently in use in the model.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Declare the DF vars we need	WAVE ttlOutputChannelOn	Variable nTTLChannels=GetNumberOfTTLChannels()	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		Variable nTTLOutputChannelsInUse=0	Variable i	for (i=0; i<nTTLChannels; i+=1)		nTTLOutputChannelsInUse+=ttlOutputChannelOn[i]	endfor		// Restore the original DF	SetDataFolder savedDF	return nTTLOutputChannelsInUseEndFunction /S GetRawDACSequence()	// Computes the DAC sequence string needed by the ITC functions, given the model state.	//  Note, however, that this is the RAW sequence string.  The raw DAC sequence must be reconciled with	// the raw ADC sequence to produce the final DAC and ADC seqeuences.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	WAVE dacChannelOn, ttlOutputChannelOn	// boolean waves that say which DAC, TTL channels are on	Variable nDACChannels=GetNumberOfDACChannels()	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs, by probing the view state	String dacSequence=""	Variable i	for (i=0; i<nDACChannels; i+=1)		if ( dacChannelOn[i] )			dacSequence+=num2str(i)		endif	endfor	// All the TTL outputs are controlled by a single 16-bit number.	// (There are 16 TTL outputs, but only 0-3 are exposed in the front panel.  All are available	// on a multi-pin connector in the back.)	// If the user has checked any of the TTL outputs, we need to add a "D" to the DAC sequence,	// which reads a 16-bit value to set all of the TTL outputs.	if (sum(ttlOutputChannelOn)>0)		dacSequence+="D"	endif		// Restore the original DF	SetDataFolder savedDF	return dacSequence	EndFunction /S GetRawADCSequence()	// Computes the ADC sequence string needed by the ITC functions, given the model state	// Note, however, that this is the RAW sequence string.  The raw DAC sequence must be reconciled with	// the raw ADC sequence to produce the final DAC and ADC seqeuences.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Declare the DF vars we need	WAVE adcChannelOn	Variable nADCChannels=GetNumberOfADCChannels()	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		String adcSequence=""	Variable i	for (i=0; i<nADCChannels; i+=1)		if ( adcChannelOn[i] )			adcSequence+=num2str(i)		endif	endfor	// Restore the original DF	SetDataFolder savedDF	return adcSequence	EndFunction /S ReconcileADCSequence(adcSequenceRaw,dacSequenceRaw)	// Reconciles the raw ADC sequence with the given raw DAC sequence, returning an	// ADC sequence which consists of some number of repeats of the raw ADC sequence.	String adcSequenceRaw,dacSequenceRaw	Variable nCommon=lcmLength(dacSequenceRaw,adcSequenceRaw)  // the reconciled sequences must be the same length	Variable nRepeats=nCommon/strlen(adcSequenceRaw)	String adcSequence=RepeatString(adcSequenceRaw,nRepeats)			return adcSequence	EndFunction /S ReconcileDACSequence(dacSequenceRaw,adcSequenceRaw)	// Reconciles the raw DAC sequence with the given raw ADC sequence, returning a	// DAC sequence which consists of some number of repeats of the raw DAC sequence.	String adcSequenceRaw,dacSequenceRaw	Variable nCommon=lcmLength(dacSequenceRaw,adcSequenceRaw)  // the reconciled sequences must be the same length	Variable nRepeats=nCommon/strlen(dacSequenceRaw)	String dacSequence=RepeatString(dacSequenceRaw,nRepeats)			return dacSequenceEndFunction /S GetDACSequence()	// Computes the DAC sequence string needed by the ITC functions, given the model state.	String dacSequenceRaw=GetRawDACSequence()	String adcSequenceRaw=GetRawADCSequence()	String dacSequence=ReconcileDACSequence(dacSequenceRaw,adcSequenceRaw)	return dacSequence	EndFunction /S GetADCSequence()	// Computes the ADC sequence string needed by the ITC functions, given the model state.	String dacSequenceRaw=GetRawDACSequence()	String adcSequenceRaw=GetRawADCSequence()	String adcSequence=ReconcileADCSequence(adcSequenceRaw,dacSequenceRaw)	return adcSequence	EndFunction GetRawDACSequenceLength()	String dacSequenceRaw=GetRawDACSequence()	Variable nSequence=strlen(dacSequenceRaw)	return nSequenceEndFunction GetRawADCSequenceLength()	String adcSequenceRaw=GetRawADCSequence()	Variable nSequence=strlen(adcSequenceRaw)	return nSequenceEndFunction GetSequenceLength()	String dacSequenceRaw=GetRawDACSequence()	String adcSequenceRaw=GetRawADCSequence()	Variable nSequence=lcmLength(dacSequenceRaw,adcSequenceRaw)	return nSequenceEndFunction /WAVE GetMultiplexedTTLOutput()	// Multiplexes the active TTL outputs onto a single wave.  If there are no active and valid	// TTL output waves, returns a length-zero wave.	WAVE ttlOutputChannelOn	WAVE /T ttlOutputWaveName	Make /FREE /N=(0) multiplexedTTL  // default return value	Variable nTTLChannels=GetNumberOfTTLChannels()		Variable firstActiveChannel=1	// boolean	Variable i	for (i=0; i<nTTLChannels; i+=1)		if (ttlOutputChannelOn[i])			if ( AreStringsEqual(ttlOutputWaveName[i],"(none)") )				Abort "An active TTL output channel can't have the wave set to \"(none)\"."			endif			String thisTTLWaveNameRel=ttlOutputWaveName[i]			WAVE thisTTLWave=$thisTTLWaveNameRel			if (firstActiveChannel)				firstActiveChannel=0				Duplicate /FREE /O thisTTLWave multiplexedTTL				multiplexedTTL=0			endif			multiplexedTTL+=(2^i)*thisTTLWave		endif	endfor		return multiplexedTTLEndFunction /WAVE GetFIFOout()	// Builds the FIFOout wave, as a free wave, and returns a reference to it.		// Switch to the digitizer control data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper		// Declare data folder vars we access	WAVE /T dacWaveName	WAVE dacMultiplier			// get the DAC sequence	String daSequence=GetDACSequence()	Variable sequenceLength=strlen(daSequence)		// These things will be set to finite values at soon as we are able to determine them from a wave	NVAR dt 	// sampling interval, ms	NVAR totalDuration		// total duration, ms	Variable nScans=SweeperGetNumberOfScans()		// number of samples in each output wave ("scans" is an NI-ism)		// Create the FIFOout wave	Make /FREE /N=(sequenceLength*nScans) FIFOout		// First, need to multiplex all the TTL outputs the user has specified onto a single wave, where each	// sample is interpreted 16-bit number that specifies all the 16 TTL outputs, only the first four	// of which are exposed on the front panel.	// Source TTL waves should consist of zeros (low) and ones (high) only.	// The multiplexed wave is called multiplexedTTL	Wave multiplexedTTL=GetMultiplexedTTLOutput()	// now assign values to FIFOout according to the DAC sequence	Variable outgain	String stepAsString=""	Variable i	Variable thisOneIsDAC	for (i=0; i<sequenceLength; i+=1)		// Either use the specified DAC wave, or use the multiplexed TTL wave, as appropriate		if ( AreStringsEqual(daSequence[i],"D") )			// Means this is the slot for the multiplexed TTL output			Wave thisDACWave=multiplexedTTL			thisOneIsDAC=0		else						Variable iDACChannel=str2num(daSequence[i])			if ( AreStringsEqual(dacWaveName[iDACChannel],"(none)") )				Abort "An active DAC channel can't have the wave set to \"(none)\"."			endif			String thisDACWaveNameRel=dacWaveName[iDACChannel]			Wave thisDACWave=$thisDACWaveNameRel			outgain=GetDACPointsPerNativeUnit(iDACChannel)			thisOneIsDAC=1		endif		// Make sure this wave has the correct dt		if (dt!=deltax(thisDACWave))			Abort "Internal error: There is a sample interval mismatch in your DAC and/or TTL output waves."		endif		// Make sure this wave has the correct nScans		if (nScans!=numpnts(thisDACWave))			Abort "Internal error: There is a mismatch in the number of points in your DAC and/or TTL output waves."		endif		// Get the step value, if it's present in this wave		String stepAsStringThis=StringByKeyInWaveNote(thisDACWave,"STEP")		if ( !IsEmptyString(stepAsStringThis) )			stepAsString=stepAsStringThis		endif		// Finally, write this output wave into FIFOout		if (thisOneIsDAC)			FIFOout[i,;sequenceLength]=min(max(-32768,thisDACWave[floor(p/sequenceLength)]*outgain*dacMultiplier[iDACChannel]),32767)		// limit to 16-bits		else			// this one is TTL			FIFOout[i,;sequenceLength]=thisDACWave[floor(p/sequenceLength)]		endif	endfor			// Set the time scaling for FIFOout	Setscale /P x, 0, dt/sequenceLength, "ms", FIFOout		// Set the STEP wave note in FIFOout, so that it can be copied into the ADC waves eventually	if (!IsEmptyString(stepAsString))		ReplaceStringByKeyInWaveNote(FIFOout,"STEP",stepAsString)	endif		// Restore the data folder	SetDataFolder savedDF		// Return	return FIFOoutEndFunction /S GetSweeperWaveNamesEndingIn(suffix)	String suffix	String theFolderPath = "root:DP_Sweeper"	if (!DataFolderExists(theFolderPath))		return ""	endif	String dfSave = GetDataFolder(1)	SetDataFolder theFolderPath	String items, theString	theString="*"+suffix	items=WaveList(theString, ";", "")	SetDataFolder dfSave		return itemsEndFunction SweeperGetDt()	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Declare the DF vars we need	NVAR dt	Variable result=dt	// Restore the original DF	SetDataFolder savedDF	return resultEndFunction SweeperGetTotalDuration()	// Gets the number of TTL output channels currently in use in the model.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Declare the DF vars we need	NVAR totalDuration	Variable result=totalDuration	// Restore the original DF	SetDataFolder savedDF	return resultEndFunction /WAVE SweeperGetWaveByName(waveNameString)	String waveNameString	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Duplicate the wave to a free wave	Wave exportedWave	Duplicate /FREE $waveNameString exportedWave	// Restore the original DF	SetDataFolder savedDF	return exportedWave	EndFunction SweeperResampleInternalWaves()	// Private method, called to resample all the internal waves using the current dt, totalDuration	SweeperUpdateStepPulseWave()	SweeperUpdateSynPulseWave()	SweeperUpdateImportedWaves()EndFunction SweeperGetNumberOfScans()	// Get the number of time points ("scans") for the current sampling interval and duration settings.	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	NVAR dt,totalDuration	Variable result=numberOfScans(dt,totalDuration)	SetDataFolder savedDF	return resultEndFunction SweeperUpdateImportedWaves()	// Updates all the imported waves to make them consistent with the current	// dt and totalDuration, and their own parameters as stored in their wave notes.	String dacWaveNames=GetSweeperWaveNamesEndingIn("_DAC")	String ttlWaveNames=GetSweeperWaveNamesEndingIn("_TTL")	String outputWaveNames=CatLists(dacWaveNames,ttlWaveNames)	String importedWaveNames=RemoveFromList("StepPulse_DAC;SynPulse_TTL",outputWaveNames)	//String importedWaveNames=outputWaveNames	Variable nWaves=ItemsInList(importedWaveNames)	Variable i	for (i=0; i<nWaves; i+=1)		String waveNameThis=StringFromList(i,importedWaveNames)		SweeperResampleNamedWave(waveNameThis)	endforEndFunction SweeperAddDACWave(w,waveNameString)	Wave w	String waveNameString	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	if (!GrepString(waveNameString,"_DAC$"))		waveNameString+="_DAC"	endif	Duplicate /O w $waveNameString	// copy into our DF	SweeperResampleNamedWave(waveNameString)		// Make sure it matches the current dt, T	SetDataFolder savedDFEndFunction SweeperAddTTLWave(w,waveNameString)	Wave w	String waveNameString	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper		if (!GrepString(waveNameString,"_TTL$"))		waveNameString+="_TTL"	endif	Duplicate /O w $waveNameString	// copy into our DF	SweeperResampleNamedWave(waveNameString)		// Make sure it matches the current dt, T	SetDataFolder savedDFEnd//Function SweeperAddDACOrTTLWave(w,waveNameString)//	Wave w//	String waveNameString//	String savedDF=GetDataFolder(1)//	SetDataFolder root:DP_Sweeper////	if (!GrepString(waveNameString,"_DAC$") && !GrepString(waveNameString,"_TTL$"))//		waveNameString+="_DAC"	// assume a DAC wave if unclear//	endif//	Duplicate /O w $waveNameString	// copy into our DF//	SweeperResampleNamedWave(waveNameString)	// Make sure it matches the current dt, T////	SetDataFolder savedDF//EndFunction SweeperResampleNamedWave(waveNameString)	// Private method, resamples the named wave to the current dt, totalDuration	String waveNameString	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	String waveTypeString=StringByKeyInWaveNote($waveNameString,"WAVETYPE")	String resampleFunctionName="resample"+waveTypeString+"Bang"	String executeString=sprintf2ss("%s(%s,dt,totalDuration)",resampleFunctionName,waveNameString)	Execute executeString	SetDataFolder savedDF	EndFunction SweeperSetDt(newDt)	Variable newDt	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper		NVAR dt		dt=newDt	SweeperResampleInternalWaves()		SetDataFolder savedDFEndFunction SweeperSetTotalDuration(newTotalDuration)	Variable newTotalDuration	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper		NVAR totalDuration		totalDuration=newTotalDuration	SweeperResampleInternalWaves()		SetDataFolder savedDFEnd