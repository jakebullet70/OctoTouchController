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
	#if klipper
	Public parsorConStatus As JsonParsorConnectionStatus
	Private oWSk As moonrakerWebSocket
	Public parserK As KlippySocketParser
	#End If
	
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
	Public mapBedHeatingOptions, mapToolHeatingOptions,mapAllHeatingOptions As Map
	Public mapToolHeatValuesOnly,mapBedHeatValuesOnly As Map

	#if klipper	
	Public KlipperFrontEnd As Int
	#end if
	
	'--- stops calls from backing up if we have had a disconnect	
	Private mGetTempFLAG_Busy, mJobStatusFLAG_Busy As Boolean = False
	
End Sub


Public Sub getWSk() As moonrakerWebSocket
	Return oWSk
End Sub
Public Sub getCN() As HttpOctoRestAPI
	Return oCN
End Sub

#Region "CLASS CRAP"
Public Sub Initialize
	
	mainObj = B4XPages.MainPage
	parser.Initialize() '--- init the rest parser
	
	#if klipper
	parsorConStatus.Initialize
	parserK.Initialize
	#End If
	
	
End Sub

Public Sub Start
	GetConnectionPrinterStatus
End Sub


#if klipper
Private Sub GetKlipperFrontEnd As ResumableSub
'	#if debug
'	Return gblConst.KLIPPER_FRONTEND_MAINSAIL
'	#end if

	KlipperFrontEnd = gblConst.KLIPPER_FRONTEND_NONE
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo("/server/database/list")
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		If Result.ToLowerCase.Contains("fluidd") Then
			Return gblConst.KLIPPER_FRONTEND_FLUIDD
		Else if Result.ToLowerCase.Contains("mainsail") Then
			Return gblConst.KLIPPER_FRONTEND_MAINSAIL
		End If
	End If
	Return gblConst.KLIPPER_FRONTEND_NONE
	
End Sub
#end if

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

	'--- do we have a valid printer profile?
	If mGotProfileInfoFLAG = False And mGotProfileInfoFLAG_IsBusy = False Then
		GetPrinterProfileInfo
	End If
	
	'--- do we have Octo main settings
	If mGotOctoSettingFLAG = False And mGotOctoSettingFLAG_IsBusy = False Then
		GetAllPrinterSettings
	End If
	
	'--- have we grabbed all loaded files fron octoprint
	If mGotFilesListFLAG = False And  mGotFilesListFLAG_IsBusy = False Then
		GetAllOctoFilesInfo
	End If
	
	
	'--- make API requested and update screen
	'--- Timer is in 'Main'
	#if klipper
	If oc.isConnected Then GetTemps
	#else
	GetTemps
	#End If
	GetJobStatus
	

End Sub
#end region

'============================================================================================

#Region "MAIN API CALLS"
Private Sub GetAllPrinterSettings
	
	If mGotOctoSettingFLAG_IsBusy = True Then
		logMe.logDebug2("mGotOctoSettingFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotOctoSettingFLAG_IsBusy = True ' TODO KLIPPER
	
	#if not (klipper)
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo("/api/settings")
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
	
		Dim o As JsonParserMasterPrinterSettings  : o.Initialize
		mapMasterOctoTempSettings.Initialize
		mapMasterOctoTempSettings = o.GetPresetHeaterSettings(Result)
		mGotOctoSettingFLAG = True '--- will stop it from firing in the main loop
		
		Build_PresetHeaterOption(mapMasterOctoTempSettings)
			
		
	Else
		
		'oc.RestPrinterProfileVars
		
	End If
	
	#else
	
	'--- klipper!!!!!!!!!!!!!!!!
	Do While True
		
		Wait For (GetKlipperFrontEnd) complete (retval As Int)
		KlipperFrontEnd = retval
				
		Dim api As String = "" '--- assume no front end
		Select Case KlipperFrontEnd
			Case gblConst.KLIPPER_FRONTEND_MAINSAIL
				api = "/server/database/item?namespace=mainsail&key=presets"
			Case gblConst.KLIPPER_FRONTEND_FLUIDD
				api = "/server/database/item?namespace=fluidd&key=uiSettings"
		End Select
		
		If api <> "" Then
			Dim rs As ResumableSub =  oCN.SendRequestGetInfo(api)
		
			Wait For(rs) Complete (Result As String)
			If Result.Length <> 0 Then
		
				Dim o As JsonParserMasterPrinterSettings  : o.Initialize
				mapMasterOctoTempSettings.Initialize
				mapMasterOctoTempSettings = o.GetPresetHeaterSettings(Result)
				mGotOctoSettingFLAG = True '--- will stop it from firing in the main loop
				
				Build_PresetHeaterOption(mapMasterOctoTempSettings)
			
			Else
				'oc.RestPrinterProfileVars
			End If
		
		Else
			'--- no front end detected detected
				
		End If
		
		
		
		
		Exit 'Do
	Loop
	#end if
	
	mGotOctoSettingFLAG_IsBusy = False
	
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
		
		logMe.LogIt2("reseting vars",mModule,"GetPrinterProfileInfo") 
		oc.RestPrinterProfileVars
		
	End If
	
End Sub

Private Sub GetTemps
	
'	#if klipper
'	If oc.isConnected = False Then
'		mGetTempFLAG_Busy = False
'		Return
'	End If
'	#End If
	
	If mGetTempFLAG_Busy = True Then Return '--- stop calls from backing up if we have had a disconect
	mGetTempFLAG_Busy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(oc.cPRINTER_MASTER_STATE)

	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		parser.TempStatus(Result)
		#if klipper
		'--- moonraker can still be running even though it is not connected to klipper
		parsorConStatus.ConnectionStatusKlipper(Result)
		#End If
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
	
	#if klipper
	If oc.isConnected = False Then
		mJobStatusFLAG_Busy = False
		Return
	End If
	#End If
	
	If mJobStatusFLAG_Busy = True Then Return '--- stop calls from backing up if we have had a disconnect
	mJobStatusFLAG_Busy = True
	
	
	#if klipper
	Dim jobInfo As String = "/printer/objects/query?webhooks&virtual_sdcard&print_stats"
	#else
	Dim jobInfo As String =  "/api/job"
	#End If
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(jobInfo)
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		parser.JobStatus(Result)
	Else
		oc.ResetJobVars
	End If

	'--- Update printer btns (enable, disabled)
	CallSub(mCallBack,mEventNameBtns)
	
	#if klipper
	oc.FormatedJobPct = IIf(oc.isPrinting = True And oc.isHeating = False,fnc.RoundJobPctNoDecimals(oc.JobCompletion),"")
	Dim Const OP As String = "operational"
	If oc.JobPrintState = "cancelled" Then
		oc.isKlipperCanceling = False
		oc.JobPrintState = OP
		oc.FormatedStatus = oc.JobPrintState
	else If oc.isKlipperCanceling Then
		oc.FormatedStatus = "--> canceling <--"
	Else If oc.JobPrintState = "printing" Then
		oc.FormatedStatus = oc.JobPrintState & " " & oc.FormatedJobPct
	Else
		If oc.JobPrintState = "complete" Then
			oc.JobPrintState = OP
			oc.FormatedStatus = OP
		Else
			oc.FormatedStatus = oc.JobPrintState
		End If
		
	End If
	#else
	oc.FormatedJobPct = IIf(oc.isPrinting = True And oc.isHeating = False,fnc.RoundJobPctNoDecimals(oc.JobCompletion),"")
	If oc.JobPrintState = "Printing" Then
		oc.FormatedStatus = oc.JobPrintState & " " & oc.FormatedJobPct
	Else
		oc.FormatedStatus = oc.JobPrintState
	End If
	#End If
	'Log(oc.JobPrintState)
	CallSub(mCallBack,mEventNameStatus)
	
	mJobStatusFLAG_Busy = False
	
End Sub

Private Sub GetConnectionPrinterStatus
	
	'--- called once on 1st start
	If oCN.IsInitialized = False Then
		oCN.Initialize(oc.OctoIp ,oc.OctoPort,oc.OctoKey)
	End If
	
	#if klipper
	oWSk.Initialize(parserK,"wsocket",oc.OctoIp,oc.WSocketPort)
	oWSk.Connect
	#End If
	
	#if klipper
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(oc.cPRINTER_MASTER_STATE)
	'--- get some info!
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		
		Dim o2 As JsonParsorConnectionStatus
		o2.Initialize
		o2.ConnectionStatusKlipper(Result)
		
		'--- turn on main loop timer
		CallSub2(Main,"TurnOnOff_MainTmr",True)
		tmrMain_Tick
		
	Else
		oc.ResetStateVars
	End If
	
	#else	


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
	
	

	#End If

	
End Sub


Public Sub GetAllOctoFilesInfo
	
	#if klipper
	If oc.isConnected = False Then 
		mGotFilesListFLAG_IsBusy = False
		Return
	End If
	#End If
	
	If mGotFilesListFLAG_IsBusy = True Then
		If config.logFILE_EVENTS Then logMe.Logit("mGotFilesListFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotFilesListFLAG_IsBusy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(oc.cFILES)
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		gMapOctoFilesList.Initialize
		
		Dim o As JsonParserFiles  
		o.Initialize(True) '--- download thumbnails
		
		#if klipper
		If oc.KlipperFileSrcPath.Length <> 0 Then
			Wait For (o.GetKlipperFilePath) Complete (retval As String)
			'--- TODO, if supporting paths --- https://moonraker.readthedocs.io/en/latest/web_api/#list-available-files
			oc.KlipperFileSrcPath = retval
		End If
		Wait For (o.StartParseAllFilesKlipper(Result)) Complete (m As Map)
		gMapOctoFilesList = m
		#else
		gMapOctoFilesList = o.StartParseAllFilesOcto(Result)
		#End If
		
		
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
	mapBedHeatValuesOnly.Initialize
		
	Dim allOff As String = "** All Off **"

	mapBedHeatingOptions.Put(allOff,"alloff")
	mapBedHeatingOptions.Put("** Bed Off **","bedoff")
	mapBedHeatValuesOnly.Put("Bed Off","bedoff")
	
	mapToolHeatingOptions.Put(allOff,"alloff")
	mapToolHeatingOptions.Put("** Tool Off **","tooloff")
	mapToolHeatValuesOnly.Put("Tool Off","tooloff")
		
	mapAllHeatingOptions.Put(allOff,"alloff")
	
	Dim s As String
	Dim FilamentType As String
	Dim tmp,ToolTemp As String
	Dim BedTemp As String
	
	Try
		For x  = 0 To mapOfOptions.Size - 1
		
			FilamentType = mapOfOptions.GetKeyAt(x)
			tmp = mapOfOptions.GetValueAt(x)
			ToolTemp = Regex.Split("!!",tmp)(0)
			BedTemp = Regex.Split("!!",tmp)(1)
			
			'--- build string
			s = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapToolHeatingOptions.Put(s,s)
			mapToolHeatValuesOnly.Put($"${ToolTemp}${gblConst.DEGREE_SYMBOL}"$,ToolTemp)

			'--- bed only			
			If BedTemp <> 0 Then
				s = $"Set ${FilamentType} (Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
				mapBedHeatingOptions.Put(s,s)
				mapBedHeatValuesOnly.Put($"${BedTemp}${gblConst.DEGREE_SYMBOL}"$,BedTemp)
			End If
			
			s = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C  / Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapAllHeatingOptions.Put(s,s)
		
		Next
		
		mapToolHeatValuesOnly.Put("Enter Value","ev")
		mapBedHeatValuesOnly.Put("Enter Value","ev")
		
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


#if not (klipper)
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
#end if

