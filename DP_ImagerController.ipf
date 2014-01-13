//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

#pragma rtGlobals=3		// Use modern global access method and strict wave access

static constant moveSize=5	// pixels in the full-CCD frame
static constant nudgeSize=1	// pixels in the full-CCD frame

Function ImagerContConstructor()
	ImagerConstructor()
	ImagerViewConstructor()
End


//
//  Front-line functions for handling user actions
//

Function ICTempSetpointSVTwiddled(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	//FancyCameraSetTempAndWait(varNum)
	ImagerSetCCDTargetTemp(varNum)
	ImagerViewModelChanged()
End



Function ICTakeSnapshotButtonPressed(ctrlName) : ButtonControl
	String ctrlName
	ImagerContAcquireSnapshot()
End



Function ICFocusButtonPressed(ctrlName) : ButtonControl
	String ctrlName
	ImagerContFocus()
End



Function ICAcquireVideoButtonPressed(ctrlName) : ButtonControl
	String ctrlName
	ImagerContAcquireVideo()
End



Function ICTriggeredCBTwiddled(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	ImagerSetIsTriggered(checked)
	ImagerViewModelChanged()
End



Function ICEpiTTLChannelSVTouched(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	EpiLightSetTTLOutputIndex(varNum)
	ImagerViewEpiLightChanged()	
	SweeperViewEpiLightChanged()
	TestPulserViewEpiLightChanged()
End



Function ICEpiLightToggleButtonPressed(ctrlName) : ButtonControl
	String ctrlName
	
	EpiLightSetIsOn(!EpiLightGetIsOn())
	ImagerViewEpiLightChanged()
End



Function ICROISVTwiddled(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	Variable iROI=ImagerGetCurrentROIIndex()
	if ( AreStringsEqual(ctrlName,"iROILeftSV") )
		ImagerSetIROILeft(iROI,varNum)
	elseif ( AreStringsEqual(ctrlName,"iROIRightSV") )
		ImagerSetIROIRight(iROI,varNum)
	elseif ( AreStringsEqual(ctrlName,"iROITopSV") )
		ImagerSetIROITop(iROI,varNum)
	elseif ( AreStringsEqual(ctrlName,"iROIBottomSV") )
		ImagerSetIROIBottom(iROI,varNum)
	endif
	ImagerViewModelChanged()
	ImageBrowserModelImagerChanged()
	ImageBrowserViewModelEtcChanged()
End

Function ICBinSizePMTouched(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	ImagerSetBinSizeIndex(popNum-1)
	ImagerViewModelChanged()		
End

Function ICCurrentROIIndexSVTwiddled(svStruct) : SetVariableControl
	STRUCT WMSetVariableAction &svStruct
	
	// If control is being killed, do nothing
	if ( svStruct.eventCode==-1 ) 
		return 0
	endif	

	// Do stuff
	Variable iROINew=svStruct.dval
	ImagerSetCurrentROIIndex(iROINew)
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICDeleteROIButtonPressed(ctrlName) : ButtonControl
	String ctrlName
	ImagerDeleteCurrentROI()
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICCalculationPMTouched(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Variable iChannel
	
	ImagerSetCalculationIndex(popNum-1)
	ImagerViewModelChanged()
End



Function ICBackgroundCBTouched(ctrlName,isChecked) : CheckBoxControl
	String ctrlName
	Variable isChecked
	ImagerSetCurrentROIIsBackground(isChecked)
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICNudgeUpButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(0,-nudgeSize)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICMoveUpButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(0,-moveSize)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICNudgeDownButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(0,+nudgeSize)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICMoveDownButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(0,+moveSize)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICNudgeLeftButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(-nudgeSize,0)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICMoveLeftButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(-moveSize,0)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICNudgeRightButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(+nudgeSize,0)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICMoveRightButtonPressed(ctrlName) : ButtonControl
	String ctrlName

	ImagerTranslateCurrentROIOrAll(+moveSize,0)
	ImageBrowserModelImagerChanged()
	ImagerViewModelChanged()
	ImageBrowserViewModelEtcChanged()
End



Function ICMoveAllCBTouched(ctrlName,isChecked) : CheckBoxControl
	String ctrlName
	Variable isChecked

	ImagerSetMoveAllROIs(isChecked)
	ImagerViewModelChanged()
End

Function ICUpdateTempButtonPressed(ctrlName) : ButtonControl
	String ctrlName
	ImagerUpdateCCDTemperature()	
	ImagerViewModelChanged()
End





//
// The routines that do substantial stuff are below
//


Function ImagerContAcquireVideo()
	Variable iSweep=SweeperGetNextSweepIndex()
	Variable wasVideoAcqStarted=ImagerContAcquireVideoStart()
	if (wasVideoAcqStarted)
		ImagerContAcquireFinish(iSweep)
	else
		Abort FancyCameraGetErrorMessage()
	endif
	// Make everything update itself
	DoUpdate		
End



Function ImagerContAcquireVideoStart()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Imager

	// Declare the instance vars
	WAVE roisWave
	NVAR videoExposure
	NVAR ccdTargetTemperature	
	//NVAR binSizeIndex
	//WAVE binSizeList
	SVAR videoWaveBaseName
	NVAR nFramesForVideo
	NVAR isTriggered
	
	// Unpack the bin width, bin height
	Variable binWidth=ImagerGetBinWidth()
	Variable binHeight=ImagerGetBinHeight()
	
	// Do stuff
	//Variable iSweep=SweeperGetNextSweepIndex()
	FancyCameraSetupVideoAcq(binWidth,binHeight,roisWave,isTriggered,videoExposure,ccdTargetTemperature)
	Variable wasVideoAcqStarted
	Variable isCameraArmed=FancyCameraArm(nFramesForVideo)
	if (isCameraArmed)
		ImagerSetIsAcquiringVideo(1)
		EpiLightSetIsOn(1)
		ImagerViewSomethingChanged()
		DoUpdate	
		wasVideoAcqStarted=FancyCameraStartAcquire()
		if (!wasVideoAcqStarted)
			// Do this if the acquire failed to start
			EpiLightSetIsOn(0)
			ImagerSetIsAcquiringVideo(0)
			ImagerViewSomethingChanged()
		endif
	else
		wasVideoAcqStarted=0
	endif
	
	// Restore the data folder
	SetDataFolder savedDF	
	
	// Return the sweep index
	return wasVideoAcqStarted
End



Function ImagerContAcquireFinish(iSweep)
	Variable iSweep

	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Imager

	// Declare the instance vars
	WAVE roisWave
	WAVE isBackgroundROI
	NVAR videoExposure
	NVAR ccdTargetTemperature	
	NVAR binWidth
	NVAR binHeight
	SVAR videoWaveBaseName
	NVAR nFramesForVideo
	NVAR isTriggered
	
	// Do stuff
	Wave imageWave=FancyCameraWaitForFrames(nFramesForVideo)
	FancyCameraDisarm()
	
	EpiLightSetIsOn(0)
	String imageWaveName=sprintf2sv("%s_%d", videoWaveBaseName, iSweep)
	MoveWave imageWave, $imageWaveName 	// Cage the once-free wave
	
	// Calculate ROI signals, store in root DF
	String calculationName=ImagerGetCalculationName()
	AddROIWavesToRoot(imageWave,roisWave,iSweep,calculationName,isBackgroundROI)
	
	// Tell the image browser controller to show the newly-acquired video
	ImageBrowserContSetVideo(imageWaveName)
	
	// If video acquisition is free-running, notify the Sweeper that free-running video was just acquired.
	// This updates the next sweep index.  We don't need to do this for triggered video b/c the call to
	// SweeperControllerAcquireTrial()
	if (!isTriggered)
		SweeperFreeRunVideoJustAcqd(iSweep)
	endif
	SweeperViewSweeperChanged()
	
	// Update the sweep number and signals in the DP Browsers
	Wave browserNumbers=GetAllBrowserNumbers()  // returns a free wave	
	Variable nBrowsers=numpnts(browserNumbers)
	Variable i
	for (i=0; i<nBrowsers; i+=1)
		BrowserContSetCurSweepIndex(browserNumbers[i],iSweep)
	endfor
	
	// Tell that model that we're done acquiring video, and update the view to reflect
	ImagerSetIsAcquiringVideo(0)
	ImagerViewModelChanged()
	
	// Make everything update itself
	//DoUpdate	
	
	// Restore the data folder
	SetDataFolder savedDF	
End







Function ImagerContFocus()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Imager

	// Declare the object vars
	SVAR snapshotWaveBaseName
	//NVAR iFocusWave
	//NVAR iFullFrameWave
	WAVE roisWave
	NVAR snapshotExposure
	NVAR ccdTargetTemperature

	// Do stuff
	//Variable isBinnedAndROIed=0
	//Variable binWidth=1
	//Variable binHeight=1

	ImagerSetIsFocusing(1)
	ImagerViewModelChanged()
	DoUpdate

	//Variable isImagingTriggered=0			// set to one for triggered images
	//FancyCameraSetupAcquisition(isBinnedAndROIed,roisWave,isImagingTriggered,snapshotExposure,ccdTargetTemperature,binWidth,binHeight)
	FancyCameraSetupSnapshotAcq(snapshotExposure,ccdTargetTemperature)

	Variable iFullFrameWave=SweeperGetNextSweepIndex()
	String imageWaveNameRel=sprintf2sv("%s_%d", snapshotWaveBaseName, iFullFrameWave)
	String imageWaveNameAbs=sprintf1s("root:DP_Imager:%s",imageWaveNameRel)	
	EpiLightSetIsOn(1)
	Variable	nFrames=1	
	Variable isCameraArmed=FancyCameraArm(nFrames)
	if (isCameraArmed)
		Variable iFrame=0
		do
			// Start a sequence of images. In the current case, there is 
			// only one frame in the sequence.
			//Wave imageWaveFree=FancyCameraAcquire(nFrames)
			Variable wasAcqStarted=FancyCameraStartAcquire()
			if (wasAcqStarted)
				Wave imageWaveFree=FancyCameraWaitForFrames(nFrames)
				if (iFrame==0)
					MoveWave imageWaveFree, $imageWaveNameAbs 	// Cage the once-free wave
					Wave imageWaveCaged= $imageWaveNameAbs
					ImageBrowserContSetVideo(imageWaveNameRel)
					DoUpdate
				else
					// replace the wave data with the new data
					imageWaveCaged=imageWaveFree[p][q]
					DoUpdate
				endif
				iFrame+=1
				printf "."
				DoUpdate
			else
				// if acquire failed to start
				EpiLightSetIsOn(0)
				ImagerSetIsFocusing(0)
				ImagerViewModelChanged()
				SetDataFolder savedDF
				Abort FancyCameraGetErrorMessage()				
			endif			
		while (!EscapeKeyWasPressed())	
		EpiLightSetIsOn(0)
		ImagerSetIsFocusing(0)
		ImagerViewModelChanged()
		DoUpdate
		FancyCameraDisarm()	
			
		SweeperFreeRunVideoJustAcqd(iFullFrameWave)
		SweeperViewSweeperChanged()
	
		// Call this to make sure the image gets auto-scaled properly if needed
		ImageBrowserModelSetVideo(imageWaveNameRel)
		ImageBrowserViewModelEtcChanged()	
	else
		// If unable to arm camera
		EpiLightSetIsOn(0)
		ImagerSetIsFocusing(0)
		ImagerViewModelChanged()
		SetDataFolder savedDF
		Abort FancyCameraGetErrorMessage()
	endif		

	// Restore the data folder
	SetDataFolder savedDF
End



Function ImagerContAcquireSnapshot()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Imager

	// Declare the object vars
	SVAR snapshotWaveBaseName
	SVAR videoWaveBaseName
	WAVE roisWave
	NVAR snapshotExposure
	NVAR ccdTargetTemperature
	
	// Do stuff
	FancyCameraSetupSnapshotAcq(snapshotExposure,ccdTargetTemperature)
	EpiLightSetIsOn(1)
	Variable nFrames=1
	Variable isCameraArmed=FancyCameraArm(nFrames)
	if (isCameraArmed)
		//FancyCameraStartAcquire()
		Variable wasAcqStarted=FancyCameraStartAcquire()
		if (wasAcqStarted)
			Wave imageWave=FancyCameraWaitForFrames(nFrames)
		endif
		FancyCameraDisarm()
		EpiLightSetIsOn(0)
		if (wasAcqStarted)
			Variable iFullFrameWave=SweeperGetNextSweepIndex()
			String imageWaveName=sprintf2sv("%s_%d", snapshotWaveBaseName, iFullFrameWave)
			if (WaveExists($imageWaveName))
				 KillWaves $imageWaveName
			endif
			MoveWave imageWave, root:DP_Imager:$imageWaveName 	// Cage the once-free wave
			ImageBrowserContSetVideo(imageWaveName) 
			String allVideoWaveNames=WaveList(snapshotWaveBaseName+"*",";","")+WaveList(videoWaveBaseName+"*",";","")
			SweeperFreeRunVideoJustAcqd(iFullFrameWave)
			SweeperViewSweeperChanged()
		else
			// acquire failed to start
			Abort FancyCameraGetErrorMessage()
		endif
	else
		// camera failed to arm
		EpiLightSetIsOn(0)
		Abort FancyCameraGetErrorMessage()
	endif			

	// Restore the data folder
	SetDataFolder savedDF
End
