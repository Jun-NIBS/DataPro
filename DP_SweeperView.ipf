//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

Function SweeperViewConstructor() : Panel
	// If the view already exists, just raise it
	if (PanelExists("SweeperView"))
		DoWindow /F SweeperView
		return 0
	endif

	// Save, set the DF
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper
	
	NVAR dtWanted
	NVAR totalDuration
	
	NewPanel /W=(730,54,730+290,54+708+26) /K=1 /N=SweeperView as "Sweeper Controls"
	ModifyPanel /W=SweeperView fixedSize=1

	CheckBox autoAnalyzeCheckBox,win=SweeperView,pos={175,1},size={58,14},title="Run hook functions"
	CheckBox autoAnalyzeCheckBox,win=SweeperView,variable=runHookFunctionsChecked

	// Sweep Control widgets
	Variable yOffset=0
	GroupBox sweepControlGroup,win=SweeperView,pos={6,3},size={278,140},title="Sweep Control"
	Button getDataButton,win=SweeperView,pos={19,22},size={80,20},proc=SCGetDataButtonPressed,title="Get Data"
	
	SetVariable iSweepSV,win=SweeperView,pos={130,25},size={100,15},title="Next sweep:"
	SetVariable iSweepSV,win=SweeperView,format="%d"
	SetVariable iSweepSV,win=SweeperView,limits={0,10000,1},value= nextSweepIndex
	
	Variable xOffset=30
	SetVariable nSweepsPerTrialSV,win=SweeperView,pos={xOffset,50},size={85,15},title="Sweeps:"
	SetVariable nSweepsPerTrialSV,win=SweeperView,value= root:DP_Sweeper:nSweepsPerTrial, proc=SweeperControllerSVTwiddled
	
	xOffset=140
	SetVariable sweepIntervalSetVariable,win=SweeperView,pos={xOffset,50},size={120,15},title="Sweep Interval:"
	SetVariable sweepIntervalSetVariable,win=SweeperView,limits={0.1,10000,1},value= root:DP_Sweeper:sweepInterval, proc=SweeperControllerSVTwiddled
	TitleBox intervalTitleBox,win=SweeperView,pos={220-138+xOffset+40,50+2},frame=0,title="s"
	
	Variable width=140
	yOffset=75
	xOffset=70
	SetVariable totalDurationSV,win=SweeperView,pos={xOffset,yOffset},size={width,15},title="Total Duration:"
	SetVariable totalDurationSV,win=SweeperView,limits={10,200000,100},value= _NUM:totalDuration, proc=SweepContTotalDurationSVTwid
	TitleBox totalDurationUnitsTitleBox,win=SweeperView,pos={xOffset+width+2,yOffset+2},frame=0,title="ms"

	width=175
	yOffset+=25
	xOffset=55
	SetVariable dtWantedSV,win=SweeperView,pos={xOffset,yOffset},size={width,15},title="Desired sampling interval:"
	SetVariable dtWantedSV,win=SweeperView,limits={0.001,100,0.01},value= _NUM:dtWanted, proc=SweeperContDtWantedSVTwiddled
	TitleBox dtWantedUnitsTitleBox,win=SweeperView,pos={xOffset+width+2,yOffset+2},frame=0,title="ms"

	yOffset+=20
	xOffset=55
	//Variable dt=SweeperGetDt()
	TitleBox dtTitleBox,win=SweeperView,pos={xOffset,yOffset+2},frame=0
	//,title=sprintf1v("Achievable sampling interval: %g ms",dt)

	// ADC Channel controls
	yOffset+=30
	GroupBox adcGroup,win=SweeperView,pos={6,yOffset},size={278,196},title="ADC Channels"
	// ADC checkboxes, wave name editboxes
	xOffset=68
	Variable xShift=60	// offset from checkbox to setvariable
	Variable yShift=22	// offset from one row to the next
	Variable xSize=90	// width of setvariables
	yOffset+=20
	CheckBox ADC0Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC0"
	SetVariable adc0BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"
	yOffset+=yShift	
	CheckBox ADC1Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC1"
	SetVariable adc1BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"
	yOffset+=yShift	
	CheckBox ADC2Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC2"
	SetVariable adc2BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"
	yOffset+=yShift	
	CheckBox ADC3Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC3"
	SetVariable adc3BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"
	yOffset+=yShift	
	CheckBox ADC4Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC4"
	SetVariable adc4BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"
	yOffset+=yShift	
	CheckBox ADC5Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC5"
	SetVariable adc5BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"
	yOffset+=yShift	
	CheckBox ADC6Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC6"
	SetVariable adc6BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"
	yOffset+=yShift	
	CheckBox ADC7Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerADCCheckbox,title="ADC7"
	SetVariable adc7BaseNameSetVariable,win=SweeperView,pos={xOffset+xShift,yOffset-1},size={xSize,15},proc=SweeperControllerADCBaseNameSV,title="Name:"

	// DAC Channel controls
	Variable xShiftPopup=60	// offset from checkbox to popup
	Variable xShiftSV=125	// offset from popup to setvariable
	Variable xShiftUnits=55
	yShift=25	// offset from one row to the next
	Variable yShimPopup=3		// amount to subtract from the row yOffset for the popup

	xOffset=6
	yOffset+=30
	GroupBox dacGroup,win=SweeperView,pos={xOffset,yOffset},size={278,120},title="DAC Channels"

	// Do checkbox, popup, and SV for each DAC channel
	xOffset+=14
	yOffset+=21
	CheckBox DAC0Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerDACCheckbox,title="DAC0"
	PopupMenu DAC0WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu DAC0WavePopupMenu,win=SweeperView,proc=SweeperControllerDACWavePopup,bodyWidth=115
	SetVariable dacMultiplier0SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={52,15},title="x",proc=SweeperControllerDACMultiplier
	SetVariable dacMultiplier0SetVariable,win=SweeperView,limits={-10000,10000,100}
	TitleBox DAC0UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV+xShiftUnits,yOffset+2},frame=0

	yOffset+=yShift
	CheckBox DAC1Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerDACCheckbox,title="DAC1"
	PopupMenu DAC1WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu DAC1WavePopupMenu,win=SweeperView,proc=SweeperControllerDACWavePopup,bodyWidth=115
	SetVariable dacMultiplier1SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={52,15},title="x",proc=SweeperControllerDACMultiplier
	SetVariable dacMultiplier1SetVariable,win=SweeperView,limits={-10000,10000,100}
	TitleBox DAC1UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV+xShiftUnits,yOffset+2},frame=0

	yOffset+=yShift
	CheckBox DAC2Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerDACCheckbox,title="DAC2"
	PopupMenu DAC2WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu DAC2WavePopupMenu,win=SweeperView,proc=SweeperControllerDACWavePopup,bodyWidth=115
	SetVariable dacMultiplier2SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={52,15},title="x",proc=SweeperControllerDACMultiplier
	SetVariable dacMultiplier2SetVariable,win=SweeperView,limits={-10000,10000,100}
	TitleBox DAC2UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV+xShiftUnits,yOffset+2},frame=0

	yOffset+=yShift
	CheckBox DAC3Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerDACCheckbox,title="DAC3"
	PopupMenu DAC3WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu DAC3WavePopupMenu,win=SweeperView,proc=SweeperControllerDACWavePopup,bodyWidth=115
	SetVariable dacMultiplier3SetVariable,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV,yOffset},size={52,15},title="x",proc=SweeperControllerDACMultiplier
	SetVariable dacMultiplier3SetVariable,win=SweeperView,limits={-10000,10000,100}
	TitleBox DAC3UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftSV+xShiftUnits,yOffset+2},frame=0

	// TTL Channel controls
	xOffset=6
	yOffset+=30
	GroupBox ttlGroup,win=SweeperView,pos={xOffset,yOffset},size={278,120},title="TTL Output Channels"

	// Do checkbox, popup, and SV for each TTL channel
	xShiftUnits=xShiftSV		// Want the TTL Units to left-align with the DAC multiplier SetVariables
	xOffset+=14
	yOffset+=21
	CheckBox TTL0Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerTTLCheckbox,title="TTL0"
	PopupMenu TTL0WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu TTL0WavePopupMenu,win=SweeperView,proc=SweeperControllerTTLWavePopup,bodyWidth=115
	TitleBox TTL0UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftUnits,yOffset+2},frame=0,title="x (5 Volts)"

	yOffset+=yShift
	CheckBox TTL1Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerTTLCheckbox,title="TTL1"
	PopupMenu TTL1WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu TTL1WavePopupMenu,win=SweeperView,proc=SweeperControllerTTLWavePopup,bodyWidth=115
	TitleBox TTL1UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftUnits,yOffset+2},frame=0,title="x (5 Volts)"

	yOffset+=yShift
	CheckBox TTL2Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerTTLCheckbox,title="TTL2"
	PopupMenu TTL2WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu TTL2WavePopupMenu,win=SweeperView,proc=SweeperControllerTTLWavePopup,bodyWidth=115
	TitleBox TTL2UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftUnits,yOffset+2},frame=0,title="x (5 Volts)"

	yOffset+=yShift
	CheckBox TTL3Checkbox,win=SweeperView,pos={xOffset,yOffset},size={44,14},proc=SweeperControllerTTLCheckbox,title="TTL3"
	PopupMenu TTL3WavePopupMenu,win=SweeperView,pos={xOffset+xShiftPopup,yOffset-yShimPopup},size={115,20}
	PopupMenu TTL3WavePopupMenu,win=SweeperView,proc=SweeperControllerTTLWavePopup,bodyWidth=115
	TitleBox TTL3UnitsTitleBox,win=SweeperView,pos={xOffset+xShiftPopup+xShiftUnits,yOffset+2},frame=0,title="x (5 Volts)"
	
	// Built-in Pulse DAC
	xOffset=6
	yOffset+=30
	GroupBox builtinPulseGroup,win=SweeperView,pos={xOffset,yOffset},size={278,45+26},title="Built-In Pulse"

	xOffset+=19
	yOffset+=22
	SetVariable builtinPulseDelaySetVariable,win=SweeperView,pos={xOffset,yOffset},size={80,15},title="Delay:"
	SetVariable builtinPulseDelaySetVariable,win=SweeperView,limits={0,200000,10},value= root:DP_Sweeper:builtinPulseDelay, proc=SweeperControllerSVTwiddled
	TitleBox delayUnitsTitleBox,win=SweeperView,pos={xOffset+82,yOffset+2},frame=0,title="ms"

	xOffset+=122
	SetVariable builtinPulseDurationSetVariable,win=SweeperView,pos={xOffset,yOffset},size={100,15},proc=DPdurProc,title="Duration:"
	SetVariable builtinPulseDurationSetVariable,win=SweeperView,limits={1e-05,200000,100},value= root:DP_Sweeper:builtinPulseDuration, proc=SweeperControllerSVTwiddled	
	TitleBox durationUnitsTitleBox,win=SweeperView,pos={xOffset+102,yOffset+2},frame=0,title="ms"

	yOffset+=26
	xOffset=90
	SetVariable builtinPulseAmplitudeSV,win=SweeperView,pos={xOffset,yOffset},size={106,15},proc=DPampProc,title="Amplitude:"
	SetVariable builtinPulseAmplitudeSV,win=SweeperView,limits={-1000,10000,10},value= root:DP_Sweeper:builtinPulseAmplitude, proc=SweeperControllerSVTwiddled
	
	// Built-in TTL Pulse
	xOffset=6
	yOffset+=28		// baseline for the next few UI widgets
	GroupBox builtinTTLPulseGroup,win=SweeperView,pos={xOffset,yOffset},size={278,45},title="Built-In TTL Pulse"
	yOffset+=22
	xOffset+=19
	SetVariable builtinTTLPulseDelaySetVariable,win=SweeperView,pos={xOffset,yOffset},size={80,15},title="Delay:"
	SetVariable builtinTTLPulseDelaySetVariable,win=SweeperView,limits={0,200000,10},value= root:DP_Sweeper:builtinTTLPulseDelay, proc=SweeperControllerSVTwiddled
	TitleBox builtinTTLDelayUnitsTB,win=SweeperView,pos={xOffset+92,yOffset+2},frame=0,title="ms"
	xOffset+=122
	SetVariable builtinTTLPulseDurationSV,win=SweeperView,pos={xOffset,yOffset},size={100,15},title="Duration:"
	SetVariable builtinTTLPulseDurationSV,win=SweeperView,limits={0.001,inf,0.1},value= root:DP_Sweeper:builtinTTLPulseDuration, proc=SweeperControllerSVTwiddled
	TitleBox builtinTTLPulseDurationUnitsTB,win=SweeperView,pos={xOffset+102,yOffset+2},frame=0,title="ms"
	
	// Sync to model
	SweeperViewSweeperChanged()
	
	// Restore original DF
	SetDataFolder savedDF
End

Function SweeperViewSweeperChanged()
	// Notify the SweeperView that the Sweeper (model) has changed.
	// Currently, this calls the (private) SweeperViewUpdate method.
	SweeperViewUpdate()
End

Function SweeperViewDigitizerChanged()
	// Notify the SweeperView that the Digitizer (model) has changed.
	// Currently, this calls the (private) SweeperViewUpdate method.
	SweeperViewUpdate()
End

Function SweeperViewImagerChanged()
	SweeperViewUpdate()
End

Function SweeperViewEpiLightChanged()
	SweeperViewUpdate()
End

Function SweeperViewUpdate()
	// This is intended to be a private method in SweeperView.
	// It updates pretty much the whole view, using values in the model and
	// also the Digitizer model.

	// If the window doesn't exist, nothing to do
	if (!PanelExists("SweeperView"))
		return 0		// Have to return something
	endif

	// Change to the Sweeper data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	// Declare the DF vars we need
	WAVE adcChannelOn
	WAVE /T adcBaseName
	WAVE dacChannelOn
	WAVE /T dacWaveName
	WAVE dacMultiplier
	WAVE ttlOutputChannelOn
	WAVE /T ttlOutputWaveName
	Variable nADCChannels=DigitizerModelGetNumADCChans()
	Variable nDACChannels=DigitizerModelGetNumDACChans()
	Variable nTTLChannels=DigitizerModelGetNumTTLChans()

	// Sync the dt display
	SweeperViewUpdateDt()

	// Sync all the ADC-related controls
	String listOfChannelModes=DigitizerModelGetChanModeList()
	String listOfChannelModesFU="\""+listOfChannelModes+"\""	
	String controlName
	Variable i
	for (i=0; i<nADCChannels; i+=1)
		// Checkbox
		controlName=sprintf1v("ADC%dCheckbox", i)
		CheckBox $controlName, win=SweeperView, value=adcChannelOn[i]
		// Channel base name
		controlName=sprintf1v("adc%dBaseNameSetVariable", i)
		SetVariable $controlName,win=SweeperView,value= _STR:adcBaseName[i]
		SweeperViewADCEnablementChanged(i)
	endfor

	// Sync all the DAC-related controls
	String listOfDACWaveNames=SweeperGetDACWaveNames()
	if (IsListEmpty(listOfDACWaveNames))
		listOfDACWaveNames="(none)"
	endif
	String listOfDACWaveNamesFU="\""+listOfDACWaveNames+"\""
	String popupSelection
	for (i=0;i<nDACChannels;i+=1)
		// Checkbox
		controlName=sprintf1v("DAC%dCheckbox", i)
		CheckBox $controlName win=SweeperView, value=dacChannelOn[i]
		// Wave to be output through the channel
		controlName=sprintf1v("DAC%dWavePopupMenu", i)		
		PopupMenu $controlName,win=SweeperView,value=#listOfDACWaveNamesFU
		popupSelection=SelectString(IsItemInList(dacWaveName[i],listOfDACWaveNames),"(none)",dacWaveName[i])
		PopupMenu $controlName,win=SweeperView,popmatch=popupSelection
 		// Wave multiplier
		controlName=sprintf1v("dacMultiplier%dSetVariable", i)		
		SetVariable $controlName,win=SweeperView,value= _NUM:dacMultiplier[i]
		controlName=sprintf1v("DAC%dUnitsTitleBox", i)		
		TitleBox $controlName,win=SweeperView, title=DigitizerModelGetDACUnitsString(i)
		SweeperViewDACEnablementChanged(i)
	endfor
	
	// Sync all the TTL-related controls
	String listOfTTLWaveNames=SweeperGetTTLWaveNames()
	if (IsListEmpty(listOfTTLWaveNames))
		listOfTTLWaveNames="(none)"
	endif
	String listOfTTLWaveNamesFU="\""+listOfTTLWaveNames+"\""
	for (i=0;i<nTTLChannels;i+=1)
		// Checkbox
		controlName=sprintf1v("TTL%dCheckbox", i)
		CheckBox $controlName, win=SweeperView, value=ttlOutputChannelOn[i]
		// Wave to be output through the channel
		controlName=sprintf1v("TTL%dWavePopupMenu", i)
		PopupMenu $controlName,win=SweeperView,value=#listOfTTLWaveNamesFU
		popupSelection=SelectString(IsItemInList(ttlOutputWaveName[i],listOfTTLWaveNames),"(none)",ttlOutputWaveName[i])
		PopupMenu $controlName,win=SweeperView,popmatch=popupSelection
		SweeperViewTTLEnablementChanged(i)
	endfor

	// Set the enablement of the Get Data button
	SweeperViewUpdateGetDataButton()

	// Restore the original DF
	SetDataFolder savedDF
End

Function SweeperViewTTLEnablementChanged(i)
	// Used to notify the view that the enablement of TTL channel i has changed
	Variable i
	
	// If the window doesn't exist, nothing to do
	if (!PanelExists("SweeperView"))
		return 0		// Have to return something
	endif
	
	// Change to the Sweeper data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	WAVE ttlOutputChannelOn
	//NVAR isEpiLightInUse	
	//NVAR epiLightTTLOutputIndex
	
	// If using the imaging module, have to disable the TTL channel entirely if it is being used for epi-illumination control
	//Variable inUseForEpi= ( IsImagingModuleInUse() && (i==EpiLightGetTTLOutputIndex() )
	//Variable inUseForEpi= ( isEpiLightInUse && (i==epiLightTTLOutputIndex ) )
	Variable isHijacked=SweeperGetTTLOutputHijacked(i)
	
	String controlName=sprintf1v("TTL%dCheckbox", i)
	CheckBox $controlName, win=SweeperView, value=ttlOutputChannelOn[i], disable=fromEnable(!isHijacked)
	controlName=sprintf1v("TTL%dWavePopupMenu", i)
	PopupMenu $controlName,win=SweeperView,disable=fromEnable(ttlOutputChannelOn[i]&&!isHijacked)
	controlName=sprintf1v("TTL%dUnitsTitleBox", i)
	TitleBox $controlName,win=SweeperView,disable=fromEnable(ttlOutputChannelOn[i]&&!isHijacked)

	// Update the dt display
	SweeperViewUpdateDt()
	SweeperViewUpdateGetDataButton()

	// Restore the original DF
	SetDataFolder savedDF
End

Function SweeperViewDACEnablementChanged(i)
	// Used to notify the view that the enablement of DAC channel i has changed
	Variable i
	
	// If the window doesn't exist, nothing to do
	if (!PanelExists("SweeperView"))
		return 0		// Have to return something
	endif
	
	// Change to the Sweeper data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	WAVE dacChannelOn
	
	String controlName=sprintf1v("DAC%dCheckbox", i)
	CheckBox $controlName, win=SweeperView, value=dacChannelOn[i]
	controlName=sprintf1v("DAC%dWavePopupMenu", i)
	PopupMenu $controlName,win=SweeperView,disable=(dacChannelOn[i]?0:2)	
	controlName=sprintf1v("dacMultiplier%dSetVariable", i)		
	SetVariable $controlName,win=SweeperView,disable=(dacChannelOn[i]?0:2)
	controlName=sprintf1v("DAC%dUnitsTitleBox", i)		
	TitleBox $controlName,win=SweeperView,disable=(dacChannelOn[i]?0:2)

	// Update the dt display
	SweeperViewUpdateDt()
	SweeperViewUpdateGetDataButton()

	// Restore the original DF
	SetDataFolder savedDF
End

Function SweeperViewADCEnablementChanged(i)
	// Used to notify the view that the enablement of ADC channel i has changed
	Variable i
	
	// If the window doesn't exist, nothing to do
	if (!PanelExists("SweeperView"))
		return 0		// Have to return something
	endif
	
	// Change to the Sweeper data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Sweeper

	WAVE adcChannelOn
	
	Variable isHijacked=SweeperGetADCHijacked(i)
	
	String controlName=sprintf1v("ADC%dCheckbox", i)
	CheckBox $controlName, win=SweeperView, value=adcChannelOn[i], disable=fromEnable(!isHijacked)
	controlName=sprintf1v("adc%dBaseNameSetVariable", i)		
	SetVariable $controlName, win=SweeperView, disable=fromEnable(!isHijacked&&adcChannelOn[i])

	// Update the dt display
	SweeperViewUpdateDt()
	SweeperViewUpdateGetDataButton()

	// Restore the original DF
	SetDataFolder savedDF
End

Function	SweeperViewUpdateDt()
	// If the window doesn't exist, nothing to do
	if (!PanelExists("SweeperView"))
		return 0		// Have to return something
	endif

	Variable dt=SweeperGetDt()
	TitleBox dtTitleBox,win=SweeperView, title=sprintf1v("Achievable sampling interval: %g ms",dt)
End

Function SweeperViewUpdateGetDataButton()
	// If the window doesn't exist, nothing to do
	if (!PanelExists("SweeperView"))
		return 0		// Have to return something
	endif

	// Set the enablement of the Get Data button
	Button getDataButton,win=SweeperView,disable=fromEnable(SweeperIsSamplingPossible())
End
