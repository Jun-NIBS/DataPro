//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998Function SweeperViewConstructor() : Panel	// Save, set the DF	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper		NewPanel /W=(720,54,720+290,54+690) /K=1 /N=SweeperView as "Sweeper Controls"	ModifyPanel /W=SweeperView fixedSize=1	CheckBox autoAnalyzeCheckBox,win=SweeperView,pos={180,1},size={58,14},title="Auto analyze on"	CheckBox autoAnalyzeCheckBox,win=SweeperView,variable=autoAnalyzeChecked	// Sweep Control widgets	Variable yOffset=0	GroupBox sweepControlGroup,win=SweeperView,pos={6,3},size={278,120},title="Sweep Control"	Button getDataButton,win=SweeperView,pos={19,22},size={80,20},proc=SCGetDataButtonPressed,title="Get Data"		SetVariable iSweepSV,win=SweeperView,pos={130,25},size={100,15},title="Next sweep:"	SetVariable iSweepSV,win=SweeperView,format="%d"	SetVariable iSweepSV,win=SweeperView,limits={0,10000,1},value= iSweep		Variable xOffset=30	SetVariable nSweepsPerTrialSV,win=SweeperView,pos={13-13+xOffset,50},size={85,15},title="Sweeps:"	SetVariable nSweepsPerTrialSV,win=SweeperView,value= root:DP_Sweeper:nSweepsPerTrial, proc=SweeperControllerSVTwiddled	//TitleBox numacquireTitleBox,pos={95-13+xOffset,51+2},frame=0,title="time"		xOffset=140	SetVariable sweepIntervalSetVariable,win=SweeperView,pos={138-138+xOffset,50},size={120,15},title="Sweep interval:"	SetVariable sweepIntervalSetVariable,win=SweeperView,limits={0.1,10000,1},value= root:DP_Sweeper:sweepInterval, proc=SweeperControllerSVTwiddled	TitleBox intervalTitleBox,win=SweeperView,pos={220-138+xOffset+40,50+2},frame=0,title="s"		xOffset=70	SetVariable dtSetVariable,win=SweeperView,pos={13-13+xOffset,75},size={140,15},title="Sampling interval:"	SetVariable dtSetVariable,win=SweeperView,limits={0.001,100,0.01},value=dt, proc=SweeperControllerSVTwiddled	TitleBox dtUnitsTitleBox,win=SweeperView,pos={156-14+xOffset,75+2},frame=0,title="ms"	xOffset=70	SetVariable totalDurationSV,win=SweeperView,pos={13-13+xOffset,100},size={140,15},title="Total duration:"	SetVariable totalDurationSV,win=SweeperView,limits={10,10000,100},value=totalDuration, proc=SweeperControllerSVTwiddled	TitleBox totalDurationUnitsTitleBox,win=SweeperView,pos={156-14+xOffset,100+2},frame=0,title="ms"	// ADC Channel controls	yOffset+=130	GroupBox adcGroup,win=SweeperView,pos={6,yOffset},size={278,196},title="ADC Channels"	// ADC checkboxes, wave name editboxes	xOffset=68	Variable xShift=60	// offset from checkbox to setvariable	Variable yShift=22	// offset from one row to the next	Variable xSize=90	// width of setvariables	yOffset+=20	CheckBox ADC0Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC0"	SetVariable adc0BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	yOffset+=yShift		CheckBox ADC1Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC1"	SetVariable adc1BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	yOffset+=yShift		CheckBox ADC2Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC2"	SetVariable adc2BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	yOffset+=yShift		CheckBox ADC3Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC3"	SetVariable adc3BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	yOffset+=yShift		CheckBox ADC4Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC4"	SetVariable adc4BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	yOffset+=yShift		CheckBox ADC5Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC5"	SetVariable adc5BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	yOffset+=yShift		CheckBox ADC6Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC6"	SetVariable adc6BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	yOffset+=yShift		CheckBox ADC7Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleADCCheckbox,title="ADC7"	SetVariable adc7BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=HandleADCBaseNameSetVariable,title="name:"	// DAC Channel controls	Variable xShiftPopup=60	// offset from checkbox to popup	Variable xShiftSV=120	// offset from popup to setvariable	yShift=25	// offset from one row to the next	Variable yShimPopup=3		// amount to subtract from the row yOffset for the popup	xOffset=6	yOffset+=30	GroupBox dacGroup,win=SweeperView,pos={xOffset,yOffset},size={278,120},title="DAC Channels"	// Do checkbox, popup, and SV for each DAC channel	xOffset+=14	yOffset+=21	CheckBox DAC0Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleDACCheckbox,title="DAC0"	PopupMenu DAC0WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu DAC0WavePopupMenu,win=SweeperView,proc=HandleDACWavePopupMenu	SetVariable dacMultiplier0SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier0SetVariable,win=SweeperView,limits={-10000,10000,100}	yOffset+=yShift	CheckBox DAC1Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleDACCheckbox,title="DAC1"	PopupMenu DAC1WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu DAC1WavePopupMenu,win=SweeperView,proc=HandleDACWavePopupMenu	SetVariable dacMultiplier1SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier1SetVariable,win=SweeperView,limits={-10000,10000,100}	yOffset+=yShift	CheckBox DAC2Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleDACCheckbox,title="DAC2"	PopupMenu DAC2WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu DAC2WavePopupMenu,win=SweeperView,proc=HandleDACWavePopupMenu	SetVariable dacMultiplier2SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier2SetVariable,win=SweeperView,limits={-10000,10000,100}	yOffset+=yShift	CheckBox DAC3Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleDACCheckbox,title="DAC3"	PopupMenu DAC3WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu DAC3WavePopupMenu,win=SweeperView,proc=HandleDACWavePopupMenu	SetVariable dacMultiplier3SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier3SetVariable,win=SweeperView,limits={-10000,10000,100}	// TTL Channel controls	yOffset+=30	GroupBox ttlGroup,win=SweeperView,pos={6,yOffset},size={278,120},title="TTL Output Channels"	// ADC checkboxes, wave name editboxes	xOffset=84	// Do checkbox, popup, and SV for each TTL channel	yOffset+=21	CheckBox TTL0Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleTTLCheckbox,title="TTL0"	PopupMenu TTL0WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu TTL0WavePopupMenu,win=SweeperView,proc=HandleTTLWavePopupMenu	yOffset+=yShift	CheckBox TTL1Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleTTLCheckbox,title="TTL1"	PopupMenu TTL1WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu TTL1WavePopupMenu,win=SweeperView,proc=HandleTTLWavePopupMenu	yOffset+=yShift	CheckBox TTL2Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleTTLCheckbox,title="TTL2"	PopupMenu TTL2WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu TTL2WavePopupMenu,win=SweeperView,proc=HandleTTLWavePopupMenu	yOffset+=yShift	CheckBox TTL3Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=HandleTTLCheckbox,title="TTL3"	PopupMenu TTL3WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={113,20}	PopupMenu TTL3WavePopupMenu,win=SweeperView,proc=HandleDACWavePopupMenu		// Step Pulse DAC	xOffset=6	yOffset+=30	GroupBox stepPulseGroup,win=SweeperView,pos={xOffset,yOffset},size={278,45},title="StepPulse_DAC"	yOffset+=22	xOffset+=19	SetVariable stepPulseAmplitudeSetVariable,win=SweeperView,pos={xOffset,yOffset},size={95,15},proc=DPampProc,title="Amplitude:"	SetVariable stepPulseAmplitudeSetVariable,win=SweeperView,limits={-1000,10000,10},value= root:DP_Sweeper:stepPulseAmplitude, proc=SweeperControllerSVTwiddled	xOffset+=117	SetVariable stepPulseDurationSetVariable,win=SweeperView,pos={xOffset,yOffset},size={100,15},proc=DPdurProc,title="Duration:"	SetVariable stepPulseDurationSetVariable,win=SweeperView,limits={1e-05,100000,100},value= root:DP_Sweeper:stepPulseDuration, proc=SweeperControllerSVTwiddled	xOffset+=102	TitleBox durationUnitsTitleBox,win=SweeperView,pos={xOffset,yOffset+2},frame=0,title="ms"		// Syn Pulse DAC	xOffset=6	yOffset+=28		// baseline for the next few UI widgets	GroupBox synPulseGroup,win=SweeperView,pos={xOffset,yOffset},size={278,45},title="SynPulse_TTL"	yOffset+=22	xOffset+=14	SetVariable synPulseDelaySetVariable,win=SweeperView,pos={xOffset,yOffset},size={85,15},title="Delay:"	SetVariable synPulseDelaySetVariable,win=SweeperView,limits={0,1000,10},value= root:DP_Sweeper:synPulseDelay, proc=SweeperControllerSVTwiddled	TitleBox delayUnitsTitleBox,win=SweeperView,pos={xOffset+87,yOffset+2},frame=0,title="ms"	xOffset+=120	SetVariable synPulseDurationSetVariable,win=SweeperView,pos={xOffset,yOffset},size={120,15},title="Pulse duration:"	SetVariable synPulseDurationSetVariable,win=SweeperView,limits={0.001,10,0.1},value= root:DP_Sweeper:synPulseDuration, proc=SweeperControllerSVTwiddled	TitleBox pulseDurationUnitsTitleBox,win=SweeperView,pos={xOffset+122,yOffset+2},frame=0,title="ms"		// Sync to model	SweeperViewSweeperChanged()		// Restore original DF	SetDataFolder savedDFEndFunction SweeperViewSweeperChanged()	// Change to the Sweeper data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Sweeper	// Declare the DF vars we need	WAVE adcChannelOn	WAVE /T adcBaseName	WAVE dacChannelOn	WAVE /T dacWavePopupSelection	WAVE dacMultiplier	WAVE ttlOutputChannelOn	WAVE /T ttlWavePopupSelection	Variable nADCChannels=GetNumberOfADCChannels()	Variable nDACChannels=GetNumberOfDACChannels()	Variable nTTLChannels=GetNumberOfTTLChannels()	// Sync all the ADC-related controls	String listOfChannelModes=GetListOfChannelModes()	String listOfChannelModesFU="\""+listOfChannelModes+"\""		String controlName	Variable i	for (i=0; i<nADCChannels; i+=1)		// Checkbox		controlName=sprintf1d("ADC%dCheckbox", i)		CheckBox $controlName, win=SweeperView, value=adcChannelOn[i]		// Channel base name		controlName=sprintf1d("adc%dBaseNameSetVariable", i)		SetVariable $controlName,win=SweeperView,value= _STR:adcBaseName[i]	endfor	// Sync all the DAC-related controls	String listOfDACWaveNames="(none);"+Wavelist("*_DAC",";","")	String listOfDACWaveNamesFU="\""+listOfDACWaveNames+"\""	String popupSelection	for (i=0;i<nDACChannels;i+=1)		// Checkbox		controlName=sprintf1d("DAC%dCheckbox", i)		CheckBox $controlName win=SweeperView, value=dacChannelOn[i]		// Wave to be output through the channel		controlName=sprintf1d("DAC%dWavePopupMenu", i)				PopupMenu $controlName,win=SweeperView,value=#listOfDACWaveNamesFU		popupSelection=SelectString(IsItemInList(dacWavePopupSelection[i],listOfDACWaveNames),"(none)",dacWavePopupSelection[i])		PopupMenu $controlName,win=SweeperView,popmatch=popupSelection 		// Wave multiplier		controlName=sprintf1d("dacMultiplier%dSetVariable", i)				SetVariable $controlName,win=SweeperView,value= _NUM:dacMultiplier[i]	endfor		// Sync all the TTL-related controls	String listOfTTLWaveNames="(none);"+Wavelist("*_TTL",";","")	String listOfTTLWaveNamesFU="\""+listOfTTLWaveNames+"\""	for (i=0;i<nTTLChannels;i+=1)		// Checkbox		controlName=sprintf1d("TTL%dCheckbox", i)		CheckBox $controlName, win=SweeperView, value=ttlOutputChannelOn[i]		// Wave to be output through the channel		controlName=sprintf1d("TTL%dWavePopupMenu", i)		PopupMenu $controlName,win=SweeperView,value=#listOfTTLWaveNamesFU		popupSelection=SelectString(IsItemInList(ttlWavePopupSelection[i],listOfTTLWaveNames),"(none)",ttlWavePopupSelection[i])		PopupMenu $controlName,win=SweeperView,popmatch=popupSelection	endfor	// Restore the original DF	SetDataFolder savedDFEnd