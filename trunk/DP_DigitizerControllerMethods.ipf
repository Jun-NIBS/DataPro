//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998#pragma rtGlobals=1		// Use modern global access method.Function HandleADCChannelModePopupMenu(ctrlName,popNum,popStr) : PopupMenuControl	String ctrlName	Variable popNum	String popStr	Variable iChannel		iChannel=str2num(ctrlName[strlen(ctrlName)-1])	SwitchADCChannelMode(iChannel,popNum-1)  // notify the model	ADCChannelModeChanged(iChannel)  // notify the viewEndFunction HandleDACChannelModePopupMenu(ctrlName,popNum,popStr) : PopupMenuControl	String ctrlName	Variable popNum	String popStr	Variable iChannel		iChannel=str2num(ctrlName[strlen(ctrlName)-1])	SwitchDACChannelMode(iChannel,popNum-1)  // notify the model	DACChannelModeChanged(iChannel)  // notify the viewEndFunction LoadSettingsButtonPressed(ctrlName) : ButtonControl	String ctrlName	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	WAVE adcChannelOn	WAVE /T adcBaseName	WAVE adcMode	WAVE adcGainAll	WAVE dacChannelOn	WAVE dacMode	WAVE dacGainAll	WAVE dacMultiplier	WAVE /T dacWavePopupSelection	WAVE ttlOutputChannelOn	WAVE /T ttlWavePopupSelection	NVAR nChannelModes	NVAR nADCChannels	NVAR nDACChannels	NVAR nTTLChannels	// Prompt user for a filename	String fileFilters="DataPro Digitizer Settings Files (*.dds):.dds;"	fileFilters += "All Files:.*;"	Variable settingsFile	Open /D /R /F=fileFilters settingsFile	// Doesn't actually open, just brings up file chooser	String fileNameAbs=S_fileName	Variable userCancelled=( strlen(fileNameAbs)==0 )	if (!userCancelled)		// Actually open the file		Open /Z /R settingsFile as fileNameAbs		Variable fileOpenedSuccessfully=(V_flag==0)		if (fileOpenedSuccessfully)			// Read the ADC settings from the file, set in model			String oneLine			Variable i,j			for (i=0; i<nADCChannels; i+=1)				FReadLine settingsFile, oneLine				adcChannelOn[i]=str2num(oneLine)				FReadLine settingsFile, oneLine				adcBaseName[i]=oneLine[0,strlen(oneLine)-2]				FReadLine settingsFile, oneLine				adcMode[i]=str2num(oneLine)				for (j=0; j<nChannelModes; j+=1)					FReadLine settingsFile, oneLine					adcGainAll[i][j]=str2num(oneLine)				endfor			endfor			// Read the DAC settings from the file, set in model			for (i=0; i<nDACChannels; i+=1)				FReadLine settingsFile, oneLine				dacChannelOn[i]=str2num(oneLine)				FReadLine settingsFile, oneLine				dacMode[i]=str2num(oneLine)				for (j=0; j<nChannelModes; j+=1)					FReadLine settingsFile, oneLine					dacGainAll[i][j]=str2num(oneLine)				endfor				FReadLine settingsFile, oneLine				String dacWaveNameInFile=oneLine[0,strlen(oneLine)-2]				String listOfDACWaveNames="(none);"+Wavelist("*_DAC",";","")				if ( IsItemInList(dacWaveNameInFile,listOfDACWaveNames) )					dacWavePopupSelection[i]=dacWaveNameInFile				endif							FReadLine settingsFile, oneLine				dacMultiplier[i]=str2num(oneLine)			endfor			// Read the TTL output settings from the file, set in model			for (i=0; i<nTTLChannels; i+=1)				FReadLine settingsFile, oneLine				ttlOutputChannelOn[i]=str2num(oneLine)				FReadLine settingsFile, oneLine				String ttlWaveNameInFile=oneLine[0,strlen(oneLine)-2]				String listOfTTLWaveNames="(none);"+Wavelist("*_TTL",";","")				if ( IsItemInList(ttlWaveNameInFile,listOfTTLWaveNames) )					ttlWavePopupSelection[i]=ttlWaveNameInFile				endif						endfor			// Close the file			Close settingsFile			// Do some housekeeping on the model			//SyncGainsToChannelTypes()			// Notify the view that the model has changed			DigitizerModelChanged()		endif	endif		// Restore the original DF	SetDataFolder savedDF	EndFunction SaveSettingsButtonPressed(ctrlName) : ButtonControl	String ctrlName	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	WAVE adcChannelOn	WAVE adcGainAll	WAVE /T adcBaseName	WAVE dacChannelOn	WAVE dacGainAll	WAVE /T dacWavePopupSelection	WAVE ttlOutputChannelOn	WAVE /T ttlWavePopupSelection	WAVE adcMode, dacMode	WAVE dacMultiplier	NVAR nChannelModes	NVAR nADCChannels	NVAR nDACChannels	NVAR nTTLChannels	// Prompt user for a filename	String fileFilters="DataPro Digitizer Settings Files (*.dds):.dds;"	fileFilters += "All Files:.*;"	Variable settingsFile	Open /D  /F=fileFilters settingsFile		// Doesn't actually open, just brings up file chooser	String fileNameAbs=S_fileName	Variable userCancelled=( strlen(fileNameAbs)==0 )	if (!userCancelled)		// Actually open the file		Open /Z settingsFile as fileNameAbs		Variable fileOpenedSuccessfully=(V_flag==0)		if (fileOpenedSuccessfully)			// Save the ADC parameters			Variable i,j			for (i=0;i<nADCChannels;i+=1)				fprintf settingsFile, "%d\r", adcChannelOn[i]				fprintf settingsFile, "%s\r", adcBaseName[i]				fprintf settingsFile, "%d\r", adcMode[i]				for (j=0; j<nChannelModes; j+=1)					fprintf settingsFile, "%g\r", adcGainAll[i][j]				endfor			endfor						// Save the DAC parameters			String controlName			for (i=0;i<nDACChannels;i+=1)				fprintf settingsFile, "%d\r", dacChannelOn[i]				fprintf settingsFile, "%d\r", dacMode[i]				for (j=0; j<nChannelModes; j+=1)					fprintf settingsFile, "%g\r", dacGainAll[i][j]				endfor				fprintf settingsFile, "%s\r", dacWavePopupSelection[i]				fprintf settingsFile, "%g\r", dacMultiplier[i]					endfor						// Save the TTL output parameters			for (i=0;i<nTTLChannels;i+=1)				fprintf settingsFile, "%d\r", ttlOutputChannelOn[i]				fprintf settingsFile, "%s\r", ttlWavePopupSelection[i]			endfor						// Close the file			Close settingsFile		else			// unable to open the file			DoAlert /T="Unable to open file" 0, "Unable to open file."		endif	endif		// Restore the original DF	SetDataFolder savedDFEndFunction HandleADCGainSetVariable(ctrlName,varNum,varStr,varName) : SetVariableControl	String ctrlName	Variable varNum	String varStr	String varName	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE adcMode	WAVE adcGainAll		Variable i=str2num(ctrlName[7])  // ADC channel index	adcGainAll[i][adcMode[i]]=varNum		SetDataFolder savedDFEndFunction HandleDACGainSetVariable(ctrlName,varNum,varStr,varName) : SetVariableControl	String ctrlName	Variable varNum	String varStr	String varName		String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		WAVE dacMode	WAVE dacGainAll	Variable i=str2num(ctrlName[7])  // DAC channel index	dacGainAll[i][dacMode[i]]=varNum		SetDataFolder savedDFEnd