//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998Function DACViewer() : Graph	String fldrSav= GetDataFolder(1)	SetDataFolder root:DP_Digitizer:	//Display /W=(78,138,698,408) ThetaTETNUS_DAC	String dacWaveNames=GetSweeperWaveNamesEndingIn("DAC")	String firstDACWaveName=StringFromList(0,DACWaveNames,";")	String popupItems, initialPopupItem	if ( strlen(firstDACWaveName)==0 )		popupItems="(None)"		initialPopupItem="(None)"	else		popupItems="(None);" + dacWaveNames		initialPopupItem=firstDACWaveName	endif	Display /W=(100,150,700,400) /K=1 $initialPopupItem	ModifyGraph grid(left)=1	PopupMenu dacpopup,pos={650,20},size={115,20},proc=handleViewDACPopupSelection	String popupItemsStupidized="\""+popupItems+"\""	PopupMenu dacpopup,mode=3,popvalue=initialPopupItem,value=#popupItemsStupidized	SetDataFolder fldrSavEndFunction handleViewDacPopupSelection(ctrlName,itemNum,itemStr) : PopupMenuControl	String ctrlName	Variable itemNum	String itemStr	// Save current data folder, set to one we want.	String savedFolderName= GetDataFolder(1)	SetDataFolder root:DP_Digitizer:		// Remove the current trace, put in the new one.	RemoveFromGraph /Z $"#0"	if ( cmpstr(itemStr,"(none)")!=0 )		AppendToGraph $itemStr		ModifyGraph grid(left)=1  // put the grid back	endif		// Restore the original data folder.	SetDataFolder savedFolderNameEnd