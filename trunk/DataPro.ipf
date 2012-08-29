//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998//	last updated 7/28/2004#pragma rtGlobals=1		// Use modern global access method.#include <Strings as Lists>#include "DP_DigitizerModelMethods"#include "DP_DigitizerViewMethods"#include "DP_DigitizerControllerMethods"#include "DP_Acquire"#include "DP_BrowserModelMethods"#include "DP_BrowserViewMethods"#include "DP_BrowserControllerMethods"#include "DP_Analyze"#include "DP_Utilities"//#include "DP_Image"//#include "DP_SIDX"#include "DP_Windows"#include "DP_MyVariables"#include "DP_MyProcedures"//#include "DP_LTP"//---------------------- DataPro MENU -----------------------//Menu "DataPro"	"Start DataPro", StartDataPro()	"DataPro", RaiseOrCreatePanel("DataPro")	"Create DataPro Browser", CreateDataProBrowser()	"-"	"DataAcq Panel", RaiseOrCreatePanel("DataAcq")	"ADC DAC Control Panel", RaiseOrCreatePanel("ADCDACControl")	"-"	"Calibrator"	"SetDataUnits"	"GetRidofGraphAxes"	"Display Series"	"Kill Windows"	"Kill Waves With Name"EndFunction StartDataPro()	Silent 1	String savDF=GetDataFolder(1)	NewDataFolder /O/S root:DP_ADCDACcontrol	NewPath DataPro "C:\\Documents and Settings\\Adam\\My Documents\\WaveMetrics\\Igor Pro 6 User Files\\User Procedures\\DataPro\\"	LoadPICT /P=DataPro "DataProMenu.jpg", DataProMenu	SetupGlobals()	SetupGlobalsForMe()  // Allows user to set desired channel gains, etc.	SetupGlobalsPostUser()	MakeADCDACWaves()	//NVAR dacout	//NVAR outgain	//outgain=SetDACGain(dacout)	//SyncDACGainWaveToVars()	//SyncADCGainWaveToVars()//	NVAR adcin//	NVAR ingain//	ingain=SetADCGain(adcin)	BuildTestPulse()	BuildStepPulse()	BuildSynTTLPulse()	RaiseOrCreatePanel("DataPro")//	if (wintype("DataPro")<1)//		DataPro()//	endif	SetDataFolder savDFEndFunction AcquisitionPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl	String ctrlName	Variable popNum	String popStrEndFunction StartPanel() : Panel	PauseUpdate; Silent 1		// building window...	NewPanel /W=(271,307,737,541)	SetDrawLayer UserBack	SetDrawEnv fstyle= 1	DrawText 68,30,"It is very important that you save this as an"	SetDrawEnv fstyle= 1	DrawText 38,56,"unpacked experiment before you begin acquiring data."	SetDrawEnv fstyle= 1	DrawText 66,85,"Click the start button below and this will be"	SetDrawEnv fstyle= 1	DrawText 86,115,"the first thing you are prompted to do."	Button startbutton0,pos={177,136},size={100,30},proc=StartButtonProc,title="Start DataPro"EndMacroFunction StartButtonProc(ctrlName) : ButtonControl	String ctrlName	Execute "StartDataPro()"	DoWindow /K StartPanel//	HideProcedures//	SaveExperimentEnd