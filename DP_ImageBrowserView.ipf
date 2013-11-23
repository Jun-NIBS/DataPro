//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

#pragma rtGlobals=3		// Use modern global access method and strict wave access

//---------------------------------------------------------- IMAGE DISPLAY PROCEDURES -----------------------------------------//

Function ImageBrowserViewConstructor()
	// If the view already exists, just bring it forward
	if (GraphExists("ImageBrowserView"))
		DoWindow /F ImageBrowserView
		return 0
	endif

	// Create the graph window, widgets
	Display /W=(45,40,345,340) /K=1 /N=ImageBrowserView as "Image Browser"

	SetVariable plane_setvar0,win=ImageBrowserView,pos={45,23},size={80,16},proc=ImagePlaneSetVarProc,title="Frame:"

	//Variable nFrames=DimSize($imageWaveName, 2)
	//SetVariable plane_setvar0,win=ImageBrowserView,limits={0,nFrames-1,1},value= iFrame

	SetVariable gray_setvar0,win=ImageBrowserView,pos={137,1},size={130,16},proc=BlackCountSetVarProc,title="Black count:"
	SetVariable gray_setvar0,win=ImageBrowserView,limits={0,2^16-1,1024}

	SetVariable gray_setvar1,win=ImageBrowserView,pos={137,23},size={130,16},proc=WhiteCountSetVarProc,title="White count:"
	SetVariable gray_setvar1,win=ImageBrowserView,limits={0,2^16-1,1024}

	Button autogray_button0,win=ImageBrowserView,pos={282,0},size={80,20},proc=AutoGrayScaleButtonProc,title="Autoscale"

	CheckBox auto_on_fly_check0,win=ImageBrowserView,pos={282,25},size={111,14},title="Autoscale on the fly"
	CheckBox auto_on_fly_check0,win=ImageBrowserView, proc=ImageBrowserContAutoscaleCB
	//CheckBox auto_on_fly_check0,win=ImageBrowserView,value=autoscaleOnTheFly

	PopupMenu image_popup0,win=ImageBrowserView,pos={17,0},size={111,21},proc=ImagePopMenuProc,title="Image"
	PopupMenu image_popup0,win=ImageBrowserView,value="(none)",mode=1
	
	//AppendImage /W=ImageBrowserView root:DP_Imager:$imageWaveName
	//ModifyImage /W=ImageBrowserView $imageWaveName ctab= {blackCount,whiteCount,Grays,0}
	
	//ModifyGraph /W=ImageBrowserView margin(left)=29,margin(bottom)=22,margin(top)=36,gfSize=8,gmSize=8
	//ModifyGraph /W=ImageBrowserView manTick={0,64,0,0},manMinor={8,8}
End





Function ImageBrowserViewModelChanged()
	ImageBrowserViewUpdate()
End





Function ImageBrowserViewUpdate()
	// If the view doesn't exist, nothing to do
	if (!GraphExists("ImageBrowserView"))
		return 0
	endif

	// Update the autoscaleOnFly checkbox
	Variable autoscaleOnTheFly=ImageBrowserModGetAutoscaleFly()
	CheckBox auto_on_fly_check0, win=ImageBrowserView, value=autoscaleOnTheFly
	
	// Update the image popup
	String imageWaveName=ImageBrowserModGetImageWaveName()
	String allVideoWaveNames=ImagerGetAllVideoWaveNames()
	String allVideoWaveNamesFU="\""+allVideoWaveNames+"\""
	Variable iVideo=WhichListItem(imageWaveName,allVideoWaveNames)
	PopupMenu image_popup0, mode=iVideo+1, value= #allVideoWaveNamesFU

	// Update the frame selector
	Variable nFrames=DimSize($imageWaveName, 2)
	Variable iFrame=ImageBrowserModelGetIFrame()
	SetVariable plane_setvar0,win=ImageBrowserView,limits={0,nFrames-1,1}, value=_NUM:iFrame

	// Update the blackCount SetVariable
	Variable blackCount=ImageBrowserModelGetBlackCount()
	SetVariable gray_setvar0,win=ImageBrowserView, value= _NUM:blackCount
	
	// Update the whiteCount SetVariable
	Variable whiteCount=ImageBrowserModelGetWhiteCount()	
	SetVariable gray_setvar1, win=ImageBrowserView, value= _NUM:whiteCount
	
	// Update the image
	//String oldImageName=ImageNameList("ImageBrowserView",";")
	//printf "oldImageName: %s\r", oldImageName
	//RemoveImage /Z /W=ImageBrowserView $oldImageName
	RemoveAllImagesFromGraph("ImageBrowserView")
	AppendImage /W=ImageBrowserView /G=1 $imageWaveName
	
	// Update the scaling, frame
	ModifyImage /W=ImageBrowserView $imageWaveName ctab= {blackCount,whiteCount,Grays,0}, plane=iFrame

	// Re-do the formating stuff (do we need to do this here?)
	ModifyGraph /W=ImageBrowserView margin(left)=29,margin(bottom)=22,margin(top)=36,gfSize=8,gmSize=8
	ModifyGraph /W=ImageBrowserView manTick={0,64,0,0},manMinor={8,8}
End






Function ImageBrowserViewDrawROI()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Imager

	// instance vars
	NVAR iROI
	//NVAR iROILeft, iROIRight, iROITop, iROIBottom
	//NVAR binWidth, binHeight
	//NVAR binnedFrameWidth, binnedFrameHeight
	WAVE roisWave
	WAVE roibox_x0, roibox_y0
	WAVE roibox_x1, roibox_y1
	NVAR binWidth
	NVAR binHeight

	// Extract things we need
	Variable iROILeft=roisWave[0][iROI]
	Variable iROIRight=roisWave[1][iROI]
	Variable iROITop=roisWave[2][iROI]
	Variable iROIBottom=roisWave[3][iROI]

	String thebox_yName=sprintf1v("roibox_y%d", iROI)
	WAVE thebox_y=$thebox_yName
	thebox_y={iROITop, iROITop, iROIBottom, iROIBottom, iROITop}
	String thebox_xName=sprintf1v("roibox_x%d", iROI)
	WAVE thebox_x=$thebox_xName	
	thebox_x={iROILeft, iROIRight, iROIRight, iROILeft, iROILeft}
	if ( GraphExists("ImageBrowserView") )
		DoWindow /F ImageBrowserView
		String removeit=Wavelist("roibox_yName*",";","WIN:ImageBrowserView")
		RemoveFromGraph /W=ImageBrowserView $removeit
		AppendToGraph roibox_y0 vs roibox_x0
		ModifyGraph /Z lsize(roibox_y0)=1.5
		AppendToGraph roibox_y1 vs roibox_x1
		ModifyGraph /Z lsize(roibox_y1)=1.5,rgb(roibox_y1)=(0,65280,0)
	endif
	
	// Restore the original DF
	SetDataFolder savedDF
End



