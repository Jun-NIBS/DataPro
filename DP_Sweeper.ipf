//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

#pragma rtGlobals=1		// Use modern global access method.

Function SweeperConstructor()
	// if the DF already exists, nothing to do
	if (DataFolderExists("root:DP_Sweeper"))
		return 0		// have to return something
	endif

	// Make sure the digitizer exists
	DigitizerModelConstructor()

	// Make sure the sampler exists
	SamplerConstructor()

	// Save the current DF
	String savedDF=GetDataFolder(1)
	
	// Create a new DF
	NewDataFolder /S root:DP_Sweeper
	
	// And new DFs for the DAC and TTL waves
	NewDataFolder /O root:DP_Sweeper:dacWaves
	NewDataFolder /O root:DP_Sweeper:ttlWaves
	
	// Should we run the user's custom automatic analysis function after each sweep?
	Variable /G autoAnalyzeChecked=0		// true iff AutoAnalyze checkbox is checked

	// Variables controlling the trials and sweeps
	Variable /G nextSweepIndex=1		// index of the next sweep to be acquired
	Variable /G nSweepsPerTrial=1
	Variable /G sweepInterval=10		// seconds

	// These are used by all kinds of Sweeper stimuli
	Variable /G dtWanted=0.05	// desired sampling interval, ms
	Variable /G totalDuration=200		// total duration, ms

	// Multipliers for the DAC channels
	Variable nDACChannels=DigitizerModelGetNumDACChans()
	Make /O /N=(nDACChannels) dacMultiplier={1,1,1,1}
	
	// string variables for adc in wave names
	Variable nADCChannels=DigitizerModelGetNumADCChans()
	Make /O/T/N=(nADCChannels) adcBaseName={"ad0","ad1","ad2","ad3","ad4","ad5","ad6","ad7"}

	// wave names for DAC, TTL output channels
	Make /O /T /N=(nDACChannels) dacWaveName
	dacWaveName={"stepPulse","stepPulse","stepPulse","stepPulse"}
	Variable nTTLChannels=DigitizerModelGetNumTTLChans()
	Make /O /T /N=(nTTLChannels) ttlOutputWaveName
	ttlOutputWaveName={"synPulse","synPulse","synPulse","synPulse"}
	
	// Make waves to store which adc/dac/ttl devices should be used
	Make /O /N=(nADCChannels) adcChannelOn
	adcChannelOn[0]=1		// turn on ADC 0 by default, leave rest off
	Make /O /N=(nDACChannels) dacChannelOn
	dacChannelOn[0]=1		// turn on DAC 0 by default, leave rest off
	Make /O /N=(nTTLChannels) ttlOutputChannelOn  	// all TTL outputs off by default

	// These control the stepPulse wave
	Variable /G stepPulseAmplitude=1		// amplitude in units given by channel mode
	Variable /G stepPulseDuration=100		// duration in ms

	// Initialize the history
	Variable /G nHistoryCols=13
	Make /O /T /N=(1,nHistoryCols) history	
	history[0][ 0]="Sweep Index"
	history[0][ 1]="Sweeps in Trial"
	history[0][ 2]="Sweep Index In Trial"
	history[0][ 3]="Channel Type Name"  // one of "DAC", "TTL Output", "ADC", "TTL Input"
	history[0][ 4]="Channel Index"
	history[0][ 5]="Channel Mode Name"
	history[0][ 6]="Channel Units"
	history[0][ 7]="Wave Base Name"
	history[0][ 8]="Builder Name"
	history[0][ 9]="Builder Parameters"
	history[0][10]="Multiplier"
	history[0][11]="Channel Gain"
	history[0][12]="Channel Gain Units"
	
	// Initialize the StepPulse wave
	SetDataFolder dacWaves
	Make /O stepPulse
	SetDataFolder root:DP_Sweeper
	SweeperUpdateStepPulseWave()

	// Parameters of synPulse
	Variable /G synPulseDelay=50	
	Variable /G synPulseDuration=0.1	// ms

	// Initialize the SynPulse wave
	SetDataFolder ttlWaves
	Make /O synPulse
	SetDataFolder root:DP_Sweeper
	SweeperUpdateSynPulseWave()

	// Do the usr customization
	SetupSweeperForUser()  // Allows user to set desired channel gains, etc.
		
	// Restore the original data folder
	SetDataFolder savedDF
End

Function SweeperAddHistoryForSweep(sweepIndex,iSweepWithinTrial)
  	Variable sweepIndex
  	Variable iSweepWithinTrial		// zero-based
  	
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
  	
	WAVE /T history
	Variable nHistoryRows=DimSize(history,0)
	Variable iRow=nHistoryRows
	Variable nNewRows= SweeperGetNumADCsOn()+SweeperGetNumDACsOn()+SweeperGetNumTTLOutputsOn()
	NVAR nHistoryCols
	Redimension /N=(nHistoryRows+nNewRows,nHistoryCols) history
	
	Variable nADCChannels=DigitizerModelGetNumADCChans()
	NVAR nSweepsPerTrial
	WAVE adcChannelOn
	WAVE /T adcBaseName
	Variable iChan	
	for (iChan=0; iChan<nADCChannels; iChan+=1)
		if (adcChannelOn[iChan])
			history[iRow][ 0]=sprintf1v("%d",sweepIndex)
			history[iRow][ 1]=sprintf1v("%d",nSweepsPerTrial)
			history[iRow][ 2]=sprintf1v("%d",iSweepWithinTrial+1)			
			history[iRow][ 3]="ADC"	// channel type name
			history[iRow][ 4]=sprintf1v("%d",iChan)	// channel index
			history[iRow][ 5]=DigitizerModelGetADCModeName(iChan)
			history[iRow][ 6]=DigitizerModelGetADCUnitsString(iChan)			
			history[iRow][ 7]=adcBaseName(iChan)
			history[iRow][ 8]=""	// builder name
			history[iRow][ 9]=""	//builder parameters
			history[iRow][10]=""	// multiplier
			history[iRow][11]=sprintf1v("%.17g",DigitizerModelGetADCGain(iChan))	// channel gain
			history[iRow][12]=DigitizerModelADCGainUnits(iChan)	// channel gain units
			iRow+=1
		endif		
	endfor
	Variable nDACChannels=DigitizerModelGetNumDACChans()
	WAVE dacChannelOn, dacMultiplier
	WAVE /T dacWaveName
	for (iChan=0; iChan<nDACChannels; iChan+=1)
		if (dacChannelOn[iChan])
			history[iRow][ 0]=sprintf1v("%d",sweepIndex)
			history[iRow][ 1]=sprintf1v("%d",nSweepsPerTrial)
			history[iRow][ 2]=sprintf1v("%d",iSweepWithinTrial+1)
			history[iRow][ 3]="DAC"	// channel type name
			history[iRow][ 4]=sprintf1v("%d",iChan)	// channel index
			history[iRow][ 5]=DigitizerModelGetDACModeName(iChan)
			history[iRow][ 6]=DigitizerModelGetDACUnitsString(iChan)			
			history[iRow][ 7]=dacWaveName(iChan)
			String waveNote=SweeperGetDACWaveNoteByName(dacWaveName(iChan))
			String builderName=StringByKey("WAVETYPE", waveNote, "=", "\r", 1)  // 1 means match case
			history[iRow][ 8]=builderName		// builder name
			history[iRow][ 9]=extractBuilderParamsString(waveNote)	//builder parameters
			history[iRow][10]=sprintf1v("%.17g",dacMultiplier(iChan))	// multiplier
			history[iRow][11]=sprintf1v("%.17g",DigitizerModelGetDACGain(iChan))	// channel gain
			history[iRow][12]=DigitizerModelDACGainUnits(iChan)	// channel gain units
			iRow+=1
		endif		
	endfor
	Variable nTTLChannels=DigitizerModelGetNumTTLChans()
	WAVE ttlOutputChannelOn
	WAVE /T ttlOutputWaveName
	for (iChan=0; iChan<nTTLChannels; iChan+=1)
		if (ttlOutputChannelOn[iChan])
			history[iRow][ 0]=sprintf1v("%d",sweepIndex)
			history[iRow][ 1]=sprintf1v("%d",nSweepsPerTrial)
			history[iRow][ 2]=sprintf1v("%d",iSweepWithinTrial+1)
			history[iRow][ 3]="TTL Output"	// channel type name
			history[iRow][ 4]=sprintf1v("%d",iChan)	// channel index
			history[iRow][ 5]=""
			history[iRow][ 6]=""			
			history[iRow][ 7]=ttlOutputWaveName(iChan)
			waveNote=SweeperGetTTLWaveNoteByName(ttlOutputWaveName(iChan))
			builderName=StringByKey("WAVETYPE", waveNote, "=", "\r", 1)  // 1 means match case
			history[iRow][ 8]=builderName		// builder name
			history[iRow][ 9]=extractBuilderParamsString(waveNote)	//builder parameters
			history[iRow][10]=""	// multiplier
			history[iRow][11]=""	// channel gain
			history[iRow][12]=""	// channel gain units
			iRow+=1
		endif		
	endfor
	
	SetDataFolder savedDF
End		// method

Function SweeperUpdateStepPulseWave()
	// Updates the step pulse wave to be consistent with the rest of the model state.
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	NVAR totalDuration,stepPulseAmplitude, stepPulseDuration
	Variable dt=SweeperGetDt()
	SetDataFolder root:DP_Sweeper:dacWaves
	WAVE stepPulse		// bound wave
		
	Variable offDuration=totalDuration-stepPulseDuration
	Variable delayDuration=offDuration/4
	Duplicate /O SimplePulse(dt,totalDuration,delayDuration,stepPulseDuration,stepPulseAmplitude) stepPulse
	
	Note /K stepPulse
	ReplaceStringByKeyInWaveNote(stepPulse,"WAVETYPE","StepPulse")
	ReplaceStringByKeyInWaveNote(stepPulse,"TIME",time())
	ReplaceStringByKeyInWaveNote(stepPulse,"duration",num2str(stepPulseDuration))
	ReplaceStringByKeyInWaveNote(stepPulse,"amplitude",num2str(stepPulseAmplitude))
	ReplaceStringByKeyInWaveNote(stepPulse,"STEP",num2str(stepPulseAmplitude))
		// The value stored in STEP is shown in the Browser window, and can be used
		// to select which sweeps will be included in an average.
	SetDataFolder savedDF
End

Function SweeperUpdateSynPulseWave()
	// Updates the step pulse wave to be consistent with the rest of the model state.
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	NVAR totalDuration, synPulseDelay, synPulseDuration
	Variable dt=SweeperGetDt()
	SetDataFolder root:DP_Sweeper:ttlWaves
	WAVE synPulse
	Duplicate /O SimplePulseBoolean(dt,totalDuration,synPulseDelay,synPulseDuration) synPulse
	Note /K synPulse
	ReplaceStringByKeyInWaveNote(synPulse,"WAVETYPE","SynPulse")
	ReplaceStringByKeyInWaveNote(synPulse,"TIME",time())
	ReplaceStringByKeyInWaveNote(synPulse,"delay",num2str(synPulseDelay))
	ReplaceStringByKeyInWaveNote(synPulse,"duration",num2str(synPulseDuration))
	SetDataFolder savedDF
End

Function SweeperGetNumADCsOn()
	// Gets the number of ADC channels currently in use in the model.
	
	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	WAVE adcChannelOn
	Variable nADCChannels=DigitizerModelGetNumADCChans()

	// Build up the strings that the ITC functions use to sequence the
	// inputs and outputs	
	Variable nADCChannelsInUse=0
	Variable i
	for (i=0; i<nADCChannels; i+=1)
		nADCChannelsInUse+=adcChannelOn[i]
	endfor
	
	// Restore the original DF
	SetDataFolder savedDF

	return nADCChannelsInUse
End

Function SweeperGetADCOn(i)
	// Returns true iff ADC i is currently on.
	Variable i
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	WAVE adcChannelOn
	Variable result=adcChannelOn[i]
	SetDataFolder savedDF
	return result
End

Function SweeperGetDACOn(i)
	// Returns true iff ADC i is currently on.
	Variable i
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	WAVE dacChannelOn
	Variable result=dacChannelOn[i]
	SetDataFolder savedDF
	return result
End


Function SweeperGetNumDACsOn()
	// Gets the number of DAC channels currently in use in the model.

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	WAVE dacChannelOn
	Variable nDACChannels=DigitizerModelGetNumDACChans()

	// Build up the strings that the ITC functions use to sequence the
	// inputs and outputs	
	Variable nDACChannelsInUse=0
	Variable i
	for (i=0; i<nDACChannels; i+=1)
		nDACChannelsInUse+=dacChannelOn[i]
	endfor
	
	// Restore the original DF
	SetDataFolder savedDF

	return nDACChannelsInUse
End

Function SweeperGetNumTTLOutputsOn()
	// Gets the number of TTL output channels currently in use in the model.

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	WAVE ttlOutputChannelOn
	Variable nTTLChannels=DigitizerModelGetNumTTLChans()

	// Build up the strings that the ITC functions use to sequence the
	// inputs and outputs	
	Variable nTTLOutputChannelsInUse=0
	Variable i
	for (i=0; i<nTTLChannels; i+=1)
		nTTLOutputChannelsInUse+=ttlOutputChannelOn[i]
	endfor
	
	// Restore the original DF
	SetDataFolder savedDF

	return nTTLOutputChannelsInUse
End

Function /S SweeperGetRawDACSequence()
	// Computes the DAC sequence string needed by the ITC functions, given the model state.
	//  Note, however, that this is the RAW sequence string.  The raw DAC sequence must be reconciled with
	// the raw ADC sequence to produce the final DAC and ADC seqeuences.

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	WAVE dacChannelOn, ttlOutputChannelOn	// boolean waves that say which DAC, TTL channels are on
	Variable nDACChannels=DigitizerModelGetNumDACChans()

	// Build up the strings that the ITC functions use to sequence the
	// inputs and outputs, by probing the view state
	String dacSequence=""
	Variable i
	for (i=0; i<nDACChannels; i+=1)
		if ( dacChannelOn[i] )
			dacSequence+=num2str(i)
		endif
	endfor
	// All the TTL outputs are controlled by a single 16-bit number.
	// (There are 16 TTL outputs, but only 0-3 are exposed in the front panel.  All are available
	// on a multi-pin connector in the back.)
	// If the user has checked any of the TTL outputs, we need to add a "D" to the DAC sequence,
	// which reads a 16-bit value to set all of the TTL outputs.
	if (sum(ttlOutputChannelOn)>0)
		dacSequence+="D"
	endif
	
	// Restore the original DF
	SetDataFolder savedDF

	return dacSequence	
End

Function /S SweeperGetRawADCSequence()
	// Computes the ADC sequence string needed by the ITC functions, given the model state
	// Note, however, that this is the RAW sequence string.  The raw DAC sequence must be reconciled with
	// the raw ADC sequence to produce the final DAC and ADC seqeuences.

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	WAVE adcChannelOn
	Variable nADCChannels=DigitizerModelGetNumADCChans()

	// Build up the strings that the ITC functions use to sequence the
	// inputs and outputs	
	String adcSequence=""
	Variable i
	for (i=0; i<nADCChannels; i+=1)
		if ( adcChannelOn[i] )
			adcSequence+=num2str(i)
		endif
	endfor

	// Restore the original DF
	SetDataFolder savedDF

	return adcSequence	
End

Function /S SweeperGetDACSequence()
	// Computes the DAC sequence string needed by the ITC functions, given the model state.
	String dacSequenceRaw=SweeperGetRawDACSequence()
	String adcSequenceRaw=SweeperGetRawADCSequence()
	String dacSequence=reconcileDACSequence(dacSequenceRaw,adcSequenceRaw)
	return dacSequence	
End

Function /S SweeperGetADCSequence()
	// Computes the ADC sequence string needed by the ITC functions, given the model state.
	String dacSequenceRaw=SweeperGetRawDACSequence()
	String adcSequenceRaw=SweeperGetRawADCSequence()
	String adcSequence=reconcileADCSequence(adcSequenceRaw,dacSequenceRaw)
	return adcSequence	
End

//Function SweeperGetRawDACSequenceLength()
//	String dacSequenceRaw=SweeperGetRawDACSequence()
//	Variable nSequence=strlen(dacSequenceRaw)
//	return nSequence
//End

//Function SweeperGetRawADCSequenceLength()
//	String adcSequenceRaw=SweeperGetRawADCSequence()
//	Variable nSequence=strlen(adcSequenceRaw)
//	return nSequence
//End

Function SweeperGetSequenceLength()
	String dacSequenceRaw=SweeperGetRawDACSequence()
	String adcSequenceRaw=SweeperGetRawADCSequence()
	Variable nSequence=lcmLength(dacSequenceRaw,adcSequenceRaw)
	return nSequence
End

Function /WAVE SweeperGetMultiplexedTTLOutput()
	// Multiplexes the active TTL outputs onto a single wave.  If there are no active and valid
	// TTL output waves, returns a length-zero wave.

	// Switch to the digitizer control data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	
	WAVE ttlOutputChannelOn
	WAVE /T ttlOutputWaveName

	Make /FREE /N=(0) multiplexedTTL  // default return value
	Variable nTTLChannels=DigitizerModelGetNumTTLChans()
	
	Variable firstActiveChannel=1	// boolean
	Variable i
	for (i=0; i<nTTLChannels; i+=1)
		if (ttlOutputChannelOn[i])
			if ( AreStringsEqual(ttlOutputWaveName[i],"(none)") )
				Abort "An active TTL output channel can't have the wave set to \"(none)\"."
			endif
			String thisTTLWaveNameRel=ttlOutputWaveName[i]
			SetDataFolder root:DP_Sweeper:ttlWaves
			WAVE thisTTLWave=$thisTTLWaveNameRel
			SetDataFolder root:DP_Sweeper			
			if (firstActiveChannel)
				firstActiveChannel=0
				Duplicate /FREE /O thisTTLWave multiplexedTTL
				multiplexedTTL=0
			endif
			multiplexedTTL+=(2^i)*thisTTLWave
		endif
	endfor

	// Restore the data folder
	SetDataFolder savedDF
	
	// Return the wave	
	return multiplexedTTL
End

Function /WAVE SweeperGetFIFOout()
	// Builds the FIFOout wave, as a free wave, and returns a reference to it.
	
	// Switch to the digitizer control data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	
	// Declare data folder vars we access
	WAVE /T dacWaveName
	WAVE dacMultiplier
		
	// get the DAC sequence
	String daSequence=SweeperGetDACSequence()
	Variable sequenceLength=strlen(daSequence)
	
	Variable dt=SweeperGetDt() 	// sampling interval, ms
	NVAR totalDuration		// total duration, ms
	Variable nScans=SweeperGetNumberOfScans()		// number of samples in each output wave ("scans" is an NI-ism)
	
	// Create the FIFOout wave
	Make /FREE /N=(sequenceLength*nScans) FIFOout
	
	// First, need to multiplex all the TTL outputs the user has specified onto a single wave, where each
	// sample is interpreted 16-bit number that specifies all the 16 TTL outputs, only the first four
	// of which are exposed on the front panel.
	// Source TTL waves should consist of zeros (low) and ones (high) only.
	// The multiplexed wave is called multiplexedTTL
	Wave multiplexedTTL=SweeperGetMultiplexedTTLOutput()

	// now assign values to FIFOout according to the DAC sequence
	Variable outgain
	String stepAsString=""
	Variable i
	Variable thisOneIsDAC
	for (i=0; i<sequenceLength; i+=1)
		// Either use the specified DAC wave, or use the multiplexed TTL wave, as appropriate
		if ( AreStringsEqual(daSequence[i],"D") )
			// Means this is the slot for the multiplexed TTL output
			Wave thisDACWave=multiplexedTTL
			thisOneIsDAC=0
		else			
			Variable iDACChannel=str2num(daSequence[i])
			if ( AreStringsEqual(dacWaveName[iDACChannel],"(none)") )
				Abort "An active DAC channel can't have the wave set to \"(none)\"."
			endif
			String thisDACWaveNameRel=dacWaveName[iDACChannel]
			SetDataFolder root:DP_Sweeper:dacWaves			
			Wave thisDACWave=$thisDACWaveNameRel
			SetDataFolder root:DP_Sweeper
			outgain=DigitizerModelGetDACPntsPerNtv(iDACChannel)
			thisOneIsDAC=1
		endif
		// Make sure this wave has the correct dt
		if (dt!=deltax(thisDACWave))
			Abort "Internal error: There is a sample interval mismatch in your DAC and/or TTL output waves."
		endif
		// Make sure this wave has the correct nScans
		if (nScans!=numpnts(thisDACWave))
			Abort "Internal error: There is a mismatch in the number of points in your DAC and/or TTL output waves."
		endif
		// Get the step value, if it's present in this wave
		String stepAsStringThis=StringByKeyInWaveNote(thisDACWave,"STEP")
		if ( !IsEmptyString(stepAsStringThis) )
			stepAsString=stepAsStringThis
		endif
		// Finally, write this output wave into FIFOout
		if (thisOneIsDAC)
			FIFOout[i,;sequenceLength]=min(max(-32768,thisDACWave[floor(p/sequenceLength)]*outgain*dacMultiplier[iDACChannel]),32767)		// limit to 16-bits
		else
			// this one is TTL
			FIFOout[i,;sequenceLength]=thisDACWave[floor(p/sequenceLength)]
		endif
	endfor
		
	// Set the time scaling for FIFOout
	Setscale /P x, 0, dt/sequenceLength, "ms", FIFOout
	
	// Set the STEP wave note in FIFOout, so that it can be copied into the ADC waves eventually
	if (!IsEmptyString(stepAsString))
		ReplaceStringByKeyInWaveNote(FIFOout,"STEP",stepAsString)
	endif
	
	// Restore the data folder
	SetDataFolder savedDF
	
	// Return
	return FIFOout
End

//Function /S GetSweeperWaveNamesEndingIn(suffix)
//	String suffix
//	String theFolderPath = "root:DP_Sweeper"
//	if (!DataFolderExists(theFolderPath))
//		return ""
//	endif
//	String dfSave = GetDataFolder(1)
//	SetDataFolder theFolderPath
//	String items, theString
//	theString="*"+suffix
//	items=WaveList(theString, ";", "")
//	SetDataFolder dfSave	
//	return items
//End

Function SweeperGetDtWanted()
	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	NVAR dtWanted
	Variable result=dtWanted

	// Restore the original DF
	SetDataFolder savedDF

	return result
End

Function SweeperGetDt()
	Variable dtWanted=SweeperGetDtWanted()
	Variable sequenceLength=SweeperGetSequenceLength()
	Variable dt
	if ( IsNan(sequenceLength) )
		// If the sequence length is invalid, just pretend we can
		// acheive the desired dt
		dt=dtWanted
	else
		dt=SamplerGetNearestPossibleDt(dtWanted,sequenceLength)
	endif
	return dt
End

Function SweeperGetTotalDuration()
	// Gets the number of TTL output channels currently in use in the model.

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	NVAR totalDuration
	Variable result=totalDuration

	// Restore the original DF
	SetDataFolder savedDF

	return result
End

Function SweeperGetNextSweepIndex()
	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	NVAR nextSweepIndex
	Variable result=nextSweepIndex

	// Restore the original DF
	SetDataFolder savedDF

	return result
End

Function SweeperIncrementNextSweepIndex()
	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	NVAR nextSweepIndex
	nextSweepIndex+=1

	// Restore the original DF
	SetDataFolder savedDF
End


Function /WAVE SweeperGetWaveByFancyName(fancyWaveNameString)
	String fancyWaveNameString
	
	String waveNameString
	if (GrepString(fancyWaveNameString," \(TTL\)$"))
		waveNameString=fancyWaveNameString[0,strlen(fancyWaveNameString)-6-1]
		Wave exportedWave=SweeperGetTTLWaveByName(waveNameString)
	else
		waveNameString=fancyWaveNameString
		Wave exportedWave=SweeperGetDACWaveByName(waveNameString)
	endif
	return exportedWave
End

Function /WAVE SweeperGetDACWaveByName(waveNameString)
	String waveNameString

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:dacWaves

	// Duplicate the wave to a free wave
	Wave exportedWave
	Duplicate /FREE $waveNameString exportedWave

	// Restore the original DF
	SetDataFolder savedDF

	return exportedWave	
End

Function /T SweeperGetDACWaveNoteByName(waveNameString)
	String waveNameString

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:dacWaves

	// Get the wave note
	String waveNote=note($waveNameString)

	// Restore the original DF
	SetDataFolder savedDF

	return waveNote
End

Function /WAVE SweeperGetTTLWaveByName(waveNameString)
	String waveNameString

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:ttlWaves

	// Duplicate the wave to a free wave
	Wave exportedWave
	Duplicate /FREE $waveNameString exportedWave

	// Restore the original DF
	SetDataFolder savedDF

	return exportedWave	
End

Function /T SweeperGetTTLWaveNoteByName(waveNameString)
	String waveNameString

	// Change to the Digitizer data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:ttlWaves

	// Get the wave note
	String waveNote=note($waveNameString)

	// Restore the original DF
	SetDataFolder savedDF

	return waveNote
End

Function SweeperResampleInternalWaves()
	// Private method, called to resample all the internal waves using the current dtWanted, totalDuration
	SweeperUpdateStepPulseWave()
	SweeperUpdateSynPulseWave()
	SweeperUpdateImportedWaves()
End

Function SweeperGetNumberOfScans()
	// Get the number of time points ("scans") for the current sampling interval and duration settings.
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	NVAR totalDuration
	Variable dt=SweeperGetDt()	
	Variable result=numberOfScans(dt,totalDuration)
	SetDataFolder savedDF
	return result
End

Function SweeperUpdateImportedWaves()
	// Updates all the imported waves to make them consistent with the current
	// dtWanted and totalDuration, and their own parameters as stored in their wave notes.
	SweeperUpdateImportedDACWaves()
	SweeperUpdateImportedTTLWaves()
End

Function SweeperUpdateImportedDACWaves()
	// Updates all the imported DAC waves to make them consistent with the current
	// dtWanted and totalDuration, and their own parameters as stored in their wave notes.
	String dacWaveNames=SweeperGetDACWaveNames()
	String importedDACWaveNames=RemoveFromList("stepPulse",dacWaveNames)
	Variable nWaves=ItemsInList(importedDACWaveNames)
	Variable i
	for (i=0; i<nWaves; i+=1)
		String waveNameThis=StringFromList(i,importedDACWaveNames)
		SweeperResampleNamedWave(waveNameThis,"DAC")
	endfor
End

Function SweeperUpdateImportedTTLWaves()
	// Updates all the imported TTL waves to make them consistent with the current
	// dtWanted and totalDuration, and their own parameters as stored in their wave notes.
	String dacWaveNames=SweeperGetDACWaveNames()
	String ttlWaveNames=SweeperGetTTLWaveNames()
	String importedTTLWaveNames=RemoveFromList("synPulse",ttlWaveNames)
	Variable nWaves=ItemsInList(importedTTLWaveNames)
	Variable i
	for (i=0; i<nWaves; i+=1)
		String waveNameThis=StringFromList(i,importedTTLWaveNames)
		SweeperResampleNamedWave(waveNameThis,"TTL")
	endfor
End

Function SweeperAddDACWave(w,waveNameString)
	Wave w
	String waveNameString
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:dacWaves
	Duplicate /O w $waveNameString	// copy into our DF
	//SweeperResampleNamedWave(waveNameString)		// Make sure it matches the current dt, T
	Wave ourWave=$waveNameString
	SweeperResampleWave(ourWave)		// Make sure it matches the current dt, T
	SetDataFolder savedDF
End

Function SweeperAddTTLWave(w,waveNameString)
	Wave w
	String waveNameString
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:ttlWaves
	
	Duplicate /O w $waveNameString	// copy into our DF
	//SweeperResampleNamedWave(waveNameString)		// Make sure it matches the current dt, T
	Wave ourWave=$waveNameString
	SweeperResampleWave(ourWave)		// Make sure it matches the current dt, T
	
	SetDataFolder savedDF
End

Function SweeperResampleNamedWave(waveNameString,dacOrTTLString)
	// Private method, resamples the named wave to the current dt, totalDuration
	String waveNameString
	String dacOrTTLString		// either "DAC" or "TTL"
	String savedDF=GetDataFolder(1)
	String dataFolderName="root:DP_Sweeper:"+LowerStr(dacOrTTLString)+"Waves"
	SetDataFolder $dataFolderName
	Wave w=$waveNameString
	SetDataFolder "root:DP_Sweeper"

	NVAR totalDuration
	
	Variable dt=SweeperGetDt()	
	String builderType=StringByKeyInWaveNote(w,"WAVETYPE")
	resampleBang(builderType,w,dt,totalDuration)

	SetDataFolder savedDF	
End

Function SweeperResampleWave(w)
	// Private method, resamples the named wave to the current dt, totalDuration
	Wave w
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	NVAR totalDuration
	Variable dt=SweeperGetDt()	

	String builderType=StringByKeyInWaveNote(w,"WAVETYPE")
	resampleBang(builderType,w,dt,totalDuration)
	
	SetDataFolder savedDF	
End

Function SweeperSetDtWanted(newDtWanted)
	Variable newDtWanted

	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	
	NVAR dtWanted
	
	dtWanted=newDtWanted
	SweeperResampleInternalWaves()
	
	SetDataFolder savedDF
End

Function SweeperSetTotalDuration(newTotalDuration)
	Variable newTotalDuration

	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	
	NVAR totalDuration
	
	totalDuration=newTotalDuration
	SweeperResampleInternalWaves()
	
	SetDataFolder savedDF
End

Function SweeperSetADCChannelOn(i,state)
	Variable i, state
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	WAVE adcChannelOn
	adcChannelOn[i]=state
//	// Have to make sure at least one input channel always stays on
//	if (state)
//		adcChannelOn[i]=1
//	elseif ( SweeperGetNumADCsOn()>1 )
//		adcChannelOn[i]=0
//	endif
	SweeperResampleInternalWaves()
	SetDataFolder savedDF	
End

Function SweeperSetDACChannelOn(i,state)
	Variable i, state
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	WAVE dacChannelOn
	dacChannelOn[i]=state
//	// Have to make sure at least one output channel always stays on
//	if (state)
//		dacChannelOn[i]=1
//	elseif ( SweeperGetNumDACsOn()>1 || SweeperGetNumTTLOutputsOn()>0 )
//		dacChannelOn[i]=0
//	endif
	SweeperResampleInternalWaves()	
	SetDataFolder savedDF
End

Function SweeperSetTTLOutputChannelOn(i,state)
	Variable i, state
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	WAVE ttlOutputChannelOn
	ttlOutputChannelOn[i]=state
//	// Have to make sure at least one output channel always stays on
//	if (state)
//		ttlOutputChannelOn[i]=1
//	elseif ( SweeperGetNumDACsOn()>0 || SweeperGetNumTTLOutputsOn()>1 )
//		ttlOutputChannelOn[i]=0
//	endif
	SweeperResampleInternalWaves()	
	SetDataFolder savedDF	
End

Function /S SweeperGetDACWaveNames()
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:dacWaves
	String listOfWaveNames=Wavelist("*",";","")
	SetDataFolder savedDF
	return listOfWaveNames	
End

Function /S SweeperGetDACWaveNamesOfType(waveTypeString)
	// Get DAC wave names of such that the wave note WAVETYPE matches the
	// given waveTypeString
	String waveTypeString
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:dacWaves
	String listOfWaveNamesRaw=Wavelist("*",";","")
	Variable nWavesRaw=ItemsInList(listOfWaveNamesRaw)
	Variable i
	String listOfWaveNames=""
	for (i=0; i<nWavesRaw; i+=1)
		String thisWaveName=StringFromList(i,listOfWaveNamesRaw)
		Wave thisWave=$thisWaveName
		String waveTypeStringThis=StringByKeyInWaveNote(thisWave,"WAVETYPE")
		if (AreStringsEqual(waveTypeStringThis,waveTypeString))
			listOfWaveNames+=thisWaveName+";"
		endif
	endfor
	SetDataFolder savedDF
	return listOfWaveNames	
End

Function /S SweeperGetTTLWaveNames()
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:ttlWaves
	String listOfWaveNames=Wavelist("*",";","")
	SetDataFolder savedDF
	return listOfWaveNames	
End

Function /S SweeperGetTTLWaveNamesOfType(waveTypeString)
	// Get TTL wave names of such that the wave note WAVETYPE matches the
	// given waveTypeString
	String waveTypeString
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper:ttlWaves
	String listOfWaveNamesRaw=Wavelist("*",";","")
	Variable nWavesRaw=ItemsInList(listOfWaveNamesRaw)
	Variable i
	String listOfWaveNames=""
	for (i=0; i<nWavesRaw; i+=1)
		String thisWaveName=StringFromList(i,listOfWaveNamesRaw)
		Wave thisWave=$thisWaveName
		String waveTypeStringThis=StringByKeyInWaveNote(thisWave,"WAVETYPE")
		if (AreStringsEqual(waveTypeStringThis,waveTypeString))
			listOfWaveNames+=thisWaveName+";"
		endif
	endfor
	SetDataFolder savedDF
	return listOfWaveNames	
End

Function /S SweeperGetFancyWaveList()
	String dacWaveNames=SweeperGetDACWaveNames()
	String ttlWaveNames=SweeperGetTTLWaveNames()
	return fancyWaveList(dacWaveNames,ttlWaveNames)
End

Function /S SweeperGetFancyWaveListOfType(waveTypeString)
	String waveTypeString
	String dacWaveNames=SweeperGetDACWaveNamesOfType(waveTypeString)
	String ttlWaveNames=SweeperGetTTLWaveNamesOfType(waveTypeString)	
	return fancyWaveList(dacWaveNames,ttlWaveNames)
End



//
// Functions below here are "class methods"
//

Function resampleStepPulseBang(w,dt,totalDuration)
	Wave w
	Variable dt, totalDuration
	
	Variable duration=NumberByKeyInWaveNote(w,"duration")
	Variable amplitude=NumberByKeyInWaveNote(w,"amplitude")
	
	resampleStepPulseFromParamsBang(w,dt,totalDuration,duration,amplitude)
End

Function resampleStepPulseFromParamsBang(w,dt,totalDuration,duration,amplitude)
	// Compute the sine wave from the parameters
	Wave w
	Variable dt,totalDuration,duration,amplitude
	
	Variable nScans=numberOfScans(dt,totalDuration)
	Redimension /N=(nScans) w
	Setscale /P x, 0, dt, "ms", w
	Variable offDuration=totalDuration-duration
	Variable delay=offDuration/4
	Wave temp
	Duplicate /FREE SimplePulse(dt,totalDuration,delay,duration,amplitude) temp
	w=temp
End

Function /S fancyWaveList(dacWaveNames,ttlWaveNames)
	// A "class method" to take a list of DAC wave names and a list
	// of TTL wave names, and make a merged list where all the items
	// in ttlWaveNames have " (TTL)" appended.
	String dacWaveNames
	String ttlWaveNames

	Variable nWavesDAC=ItemsInList(dacWaveNames)
	Variable nWavesTTL=ItemsInList(ttlWaveNames)
	Variable nWaves=nWavesDAC+nWavesTTL

	String fancyList=""
	Variable i
	for (i=0;i<nWavesDAC;i+=1)
		fancyList=fancyList+StringFromList(i,dacWaveNames)+";"
	endfor
	for (i=0;i<nWavesTTL;i+=1)
		fancyList=fancyList+StringFromList(i,ttlWaveNames)+" (TTL);"
	endfor

	return fancyList
End

Function /S reconcileADCSequence(adcSequenceRaw,dacSequenceRaw)
	// Reconciles the raw ADC sequence with the given raw DAC sequence, returning an
	// ADC sequence which consists of some number of repeats of the raw ADC sequence.
	String adcSequenceRaw,dacSequenceRaw

	Variable nCommon=lcmLength(dacSequenceRaw,adcSequenceRaw)  // the reconciled sequences must be the same length
	Variable nRepeats=nCommon/strlen(adcSequenceRaw)
	String adcSequence=RepeatString(adcSequenceRaw,nRepeats)
		
	return adcSequence	
End

Function /S reconcileDACSequence(dacSequenceRaw,adcSequenceRaw)
	// Reconciles the raw DAC sequence with the given raw ADC sequence, returning a
	// DAC sequence which consists of some number of repeats of the raw DAC sequence.
	String adcSequenceRaw,dacSequenceRaw

	Variable nCommon=lcmLength(dacSequenceRaw,adcSequenceRaw)  // the reconciled sequences must be the same length
	Variable nRepeats=nCommon/strlen(dacSequenceRaw)
	String dacSequence=RepeatString(dacSequenceRaw,nRepeats)
		
	return dacSequence
End

Function resampleSynPulseBang(w,dt,totalDuration)
	Wave w
	Variable dt, totalDuration
	
	Variable delay=NumberByKeyInWaveNote(w,"delay")
	Variable duration=NumberByKeyInWaveNote(w,"duration")
	
	resampleSynPulseFromParamsBang(w,dt,totalDuration,delay,duration)
End

Function resampleSynPulseFromParamsBang(w,dt,totalDuration,delay,duration)
	// Compute the sine wave from the parameters
	Wave w
	Variable dt,totalDuration,delay,duration
	
	Variable nScans=numberOfScans(dt,totalDuration)
	Redimension /N=(nScans) w
	Setscale /P x, 0, dt, "ms", w
	Wave temp
	Duplicate /FREE SimplePulseBoolean(dt,totalDuration,delay,duration) temp
	w=temp
End

Function /T extractBuilderParamsString(waveNote)
	// Given a wave note from a builder-made stimulus wave, remove all the non-parameter
	// key-value pairs and return just the parameter key-value pairs
	// Also, use semicolon as item separator, instead of carriage return
	String waveNote
	String paramKVList
	
	paramKVList=RemoveByKey("WAVETYPE",waveNote,"=","\r",1)		// 1 means match case
	paramKVList=RemoveByKey("STEP",paramKVList,"=","\r",1)		// 1 means match case
	paramKVList=RemoveByKey("TIME",paramKVList,"=","\r",1)		// 1 means match case
	paramKVList=ReplaceString("\r",paramKVList,";")

	return paramKVList
End