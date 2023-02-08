B4A=true
Group=MAIN
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
Sub Class_Globals
	
	Private Const mModule As String = "MasterController" 
	Private mEventNameTemp As String 
	Private mEventNameStatus As String 
	Private mEventNameBtns As String 
	Private mCallBack As Object 
	Private mainObj As B4XMainPage 'ignore
	
	Private oCN As HttpOctoRestAPI
	Public parser As JsonParsorMain
	
	'--- populated by a REST calls, will be grabbed by their pages
	Public gMapOctoFilesList As Map
		
	Private mapMasterOctoTempSettings As Map
	
	#region "TIMER FLAGS"
	Private mGotProfileInfoFLAG As Boolean = False
	Private mGotProfileInfoFLAG_IsBusy As Boolean = False
	'--
	Private mGotOctoSettingFLAG As Boolean = False
	Private mGotOctoSettingFLAG_IsBusy As Boolean = False
	'---
	Private mGotFilesListFLAG As Boolean = False
	Private mGotFilesListFLAG_IsBusy As Boolean = False
	#end region
	
	'--- maps for popup listboxes - formated!
	Public mapBedHeatingOptions, mapToolHeatingOptions,mapAllHeatingOptions,mapToolHeatValuesOnly As Map
	
	'--- stops calls from backing up if we have had a disconnect	
	Private mGetTempFLAG_Busy, mJobStatusFLAG_Busy As Boolean = False
	
End Sub



Public Sub getCN() As HttpOctoRestAPI
	Return oCN
End Sub

#Region "CLASS CRAP"
Public Sub Initialize
	
	mainObj = B4XPages.MainPage
	parser.Initialize() '--- init the octo rest parser
	
End Sub

Public Sub Start
	GetConnectionPrinterStatus
End Sub

Public Sub SetCallbackTargets(CallBack As Object,EventNameTemp As String, _
												 EventNameStatus As String, _
												 EventNameBtns As String)
	mEventNameTemp = EventNameTemp
	mEventNameStatus = EventNameStatus
	mEventNameBtns = EventNameBtns
	mCallBack = CallBack
	
End Sub
#end region

'============================================================================================

#Region "TIMERS"
Public Sub tmrFilesCheckChange_Tick
	
	'--- check for added, deleted files
	If SubExists(mainObj.oPageCurrent,"tmrFilesCheckChange_Tick") Then
		CallSub(mainObj.oPageCurrent,"tmrFilesCheckChange_Tick")
	Else
		CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False) '--- turn off timer, not even on the right page
	End If

End Sub


Public Sub tmrMain_Tick

	'--- make API requested and update screen
	'--- Timer is in 'Main'
	GetTemps
	GetJobStatus
	
	'--- do we have a valid printer profile?
	If mGotProfileInfoFLAG = False And mGotProfileInfoFLAG_IsBusy = False Then
		GetPrinterProfileInfo
	End If
	
	'--- do we have Octo main settings
	If mGotOctoSettingFLAG = False And mGotOctoSettingFLAG_IsBusy = False Then
		GetAllOctoSettingInfo
	End If
	
	'--- have we grabbed all loaded files fron octoprint
	If mGotFilesListFLAG = False And  mGotFilesListFLAG_IsBusy = False Then
		GetAllOctoFilesInfo
	End If

End Sub
#end region

'============================================================================================

#Region "OCTO API CALLS"
Private Sub GetAllOctoSettingInfo
	
	If mGotOctoSettingFLAG_IsBusy = True Then
		logMe.logDebug2("mGotOctoSettingFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotOctoSettingFLAG_IsBusy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo( oc.cSETTINGS)
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
	
		Dim o As JsonParserMasterPrinterSettings  : o.Initialize
		mapMasterOctoTempSettings.Initialize
		mapMasterOctoTempSettings = o.GetPresetHeaterSettings(Result)
		mGotOctoSettingFLAG = True '--- will stop it from firing in the main loop
		
		Build_PresetHeaterOption(mapMasterOctoTempSettings)
	
		mGotOctoSettingFLAG_IsBusy = False
	Else
		
		'oc.RestPrinterProfileVars
		
	End If
	
End Sub


Private Sub GetPrinterProfileInfo
	
	If oc.PrinterProfile.Length = 0 Then Return
	
	If mGotProfileInfoFLAG_IsBusy = True Then
		logMe.logDebug2("mGotProfileInfoFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotProfileInfoFLAG_IsBusy = True
	
	Dim sendMe As String = oc.cPRINTER_PROFILES & "\" & oc.PrinterProfile
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(sendMe)
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
	
		Dim o As JsonParserMasterPrinterSettings : o.Initialize
		o.ParsePrinterProfile(Result)
		mGotProfileInfoFLAG = True '--- will stop it from fiting in the main loop
		mGotProfileInfoFLAG_IsBusy = False
		
	Else
		
		oc.RestPrinterProfileVars
		
	End If
	
End Sub


Public Sub GetSysCmds() As ResumableSub 'ignore

	Dim rs As ResumableSub =  oCN.SendRequestGetInfo("/api/system/commands/core")
	'[{"action":"shutdown","confirm":"<strong>You are about to shutdown the system.</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints run directly from your printer's internal storage).","name":"Shutdown system","resource":"http://192.168.1.207/api/system/commands/core/shutdown","source":"core"},{"action":"reboot","confirm":"<strong>You are about to reboot the system.</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints run directly from your printer's internal storage).","name":"Reboot system","resource":"http://192.168.1.207/api/system/commands/core/reboot","source":"core"},{"action":"restart","confirm":"<strong>You are about to restart the OctoPrint server.</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints run directly from your printer's internal storage).","name":"Restart OctoPrint","resource":"http://192.168.1.207/api/system/commands/core/restart","source":"core"},{"action":"restart_safe","confirm":"<strong>You are about to restart the OctoPrint server in safe mode.</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints run directly from your printer's internal storage).","name":"Restart OctoPrint in safe mode","resource":"http://192.168.1.207/api/system/commands/core/restart_safe","source":"core"}]
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		Return Result
	End If
	Return ""
	
End Sub



Private Sub GetTemps
	
	If mGetTempFLAG_Busy = True Then Return '--- stop calls from backing up if we have had a disconect
	mGetTempFLAG_Busy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(oc.cPRINTER_MASTER_STATE)

	'{"error":"You don't have the permission to access the requested resource. It is either read-protected or not readable by the server."}
	'Dim rs As ResumableSub =  gbl.cn.SendRequestGetInfo(oc.cPRINTER_HEATER) ERROR!!
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		parser.TempStatus(Result)
	Else
		oc.ResetTempVars
	End If
	
	Dim tmp As StringBuilder : tmp.Initialize
	tmp.Append($"Tool: ${oc.Tool1Actual} / ${IIf(oc.tool1Target = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.tool1Target)}"$).Append(CRLF)
	tmp.Append($"Bed: ${oc.BedActual} / ${IIf(oc.BedTarget = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.BedTarget)}"$)
	oc.FormatedTemps = tmp.ToString
	
	CallSub(mCallBack,mEventNameTemp)
	
	mGetTempFLAG_Busy = False
	
End Sub


Private Sub GetJobStatus
	
	If mJobStatusFLAG_Busy = True Then Return '--- stop calls from backing up if we have had a disconnect
	mJobStatusFLAG_Busy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(oc.cJOB_INFO)
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		parser.JobStatus(Result)
	Else
		oc.ResetJobVars
	End If

	'--- Update printer btns (enable, disabled)
	CallSub(mCallBack,mEventNameBtns)
	
	oc.FormatedJobPct = IIf(oc.isPrinting = True And oc.isHeating = False,fnc.RoundJobPctNoDecimals(oc.JobCompletion),"")
	If oc.JobPrintState = "Printing" Then
		oc.FormatedStatus = oc.JobPrintState & " " & oc.FormatedJobPct
	Else
		oc.FormatedStatus = oc.JobPrintState
	End If
	
	CallSub(mCallBack,mEventNameStatus)
	
	mJobStatusFLAG_Busy = False
	
End Sub

Private Sub GetConnectionPrinterStatus
	
	'--- called once on 1st start
	If oCN.IsInitialized = False Then
		oCN.Initialize(oc.OctoIp ,oc.OctoPort,oc.OctoKey) 
	End If

	'---force a connection if its not there	
	Dim rs As ResumableSub = oCN.PostRequest(oc.cCMD_AUTO_CONNECT_STARTUP)
	Wait For(rs) Complete (Result As String)
	
	'--- get some info!
	Dim rs As ResumableSub = oCN.SendRequestGetInfo(oc.cCONNECTION_INFO)
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		
		Dim o2 As JsonParsorConnectionStatus
		o2.Initialize
		o2.ConnectionStatus(Result)
		
		'--- turn on main loop timer
		CallSub2(Main,"TurnOnOff_MainTmr",True)
		tmrMain_Tick
		
	Else
		
		oc.ResetStateVars
		
	End If
	
End Sub


Public Sub GetAllOctoFilesInfo
	
	If mGotFilesListFLAG_IsBusy = True Then
		If config.logFILE_EVENTS Then logMe.Logit("mGotFilesListFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotFilesListFLAG_IsBusy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo( oc.cFILES)
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then

		Dim o As JsonParserFiles  : o.Initialize(True) '--- download thumbnails
		gMapOctoFilesList.Initialize
		gMapOctoFilesList = o.StartParseAllFiles(Result)
		
		mGotFilesListFLAG = True '--- will stop it from firing in the main loop
		
	Else
		
		'oc.RestPrinterProfileVars
		
	End If
	
	mGotFilesListFLAG_IsBusy = False '--- reset the is busy flag

	
End Sub
#end region

'============================================================================================


Private Sub Build_PresetHeaterOption(mapOfOptions As Map)
	
	'--- clear them out
	mapBedHeatingOptions.Initialize
	mapToolHeatingOptions.Initialize
	mapAllHeatingOptions.Initialize
	mapToolHeatValuesOnly.Initialize
		
	Dim allOff As String = "** All Off **"

	mapBedHeatingOptions.Put(allOff,"alloff")
	mapBedHeatingOptions.Put("** Bed Off **","bedoff")
	
	mapToolHeatingOptions.Put(allOff,"alloff")
	mapToolHeatingOptions.Put("** Tool Off **","tooloff")
	mapToolHeatValuesOnly.Put("Tool Off","tooloff")
		
	mapAllHeatingOptions.Put(allOff,"alloff")
	
	Dim cboStr As String
	Dim FilamentType As String
	Dim tmp,ToolTemp As String
	Dim BedTemp As String
	
	Try
		For x  = 0 To mapOfOptions.Size - 1
		
			FilamentType = mapOfOptions.GetKeyAt(x)
			tmp = mapOfOptions.GetValueAt(x)
			ToolTemp = Regex.Split("!!",tmp)(0)
			BedTemp = Regex.Split("!!",tmp)(1)
			
			'--- build string for CBO
			cboStr = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapToolHeatingOptions.Put(cboStr,cboStr)
			mapToolHeatValuesOnly.Put($"${ToolTemp}${gblConst.DEGREE_SYMBOL}C"$,ToolTemp)
			
			cboStr = $"Set ${FilamentType} (Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapBedHeatingOptions.Put(cboStr,cboStr)
			
			cboStr = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C  / Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapAllHeatingOptions.Put(cboStr,cboStr)
		
		Next
		
		mapToolHeatValuesOnly.Put("Enter Value","ev")
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
End Sub


#Region "PUBLIC METHODS"


public Sub AllHeaters_Off
	
	If oc.PrinterProfileNozzleCount > 1 Then
		'TODO  2 tool support
	End If
	oCN.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
	oCN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",0))
	
End Sub


public Sub Download_ThumbnailAndCache2File(JobFileName As String,outFileName As String)
	
	Try
		
		Dim link As String
		''http://192.168.1.236:5003/plugin/prusaslicerthumbnails/thumbnail/asus_eee_pad_bracket_fixed (2).png
		link  = $"http://${oCN.gIP}:${oCN.gPort}/"$ & JobFileName'oc.JobPrintThumbnail.SubString2(0,oc.JobPrintThumbnail.IndexOf("?"))
		'Dim fname As String = gbl.BuildThumbnailTempFilename(gbl.GetFilenameFromHTTP(link))
		oCN.Download_AndSaveFile(link,outFileName)
		
	Catch
		
		'If config.logFILE_EVENTS Then logMe.LogIt2(LastException,mModule,"Download_ThumbnailAndCache2File")
		logMe.LogIt2(LastException,mModule,"Download_ThumbnailAndCache2File")
		
	End Try

	
End Sub
#end region


Public Sub IsIncompleteFileData() As Boolean
	For Each o As tOctoFileInfo In gMapOctoFilesList.Values
		If o.missingData Then
			If config.logFILE_EVENTS Then logMe.LogIt("Incomplete data in files array",mModule)
			'Log("incompleteData=True")
			Return True
		End If
	Next
	'Log("incompleteData=False")
	Return False
End Sub






