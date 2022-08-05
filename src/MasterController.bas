B4A=true
Group=Default Group
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
	
	Public gMapOctoFilesList As Map '--- populated by a REST call
	Public gMapOctoTempSettings As Map '--- populated by a REST call
	
	#region "TIMER FLAGS"
	Private mGotProfileInfoFLAG As Boolean = False
	Private mGotProfileInfoFLAG_IsBusy As Boolean = False
'	'--
	Private mGotOctoSettingFLAG As Boolean = False
	Private mGotOctoSettingFLAG_IsBusy As Boolean = False
'	'---
	Private mGotFilesListFLAG As Boolean = False
	Private mGotFilesListFLAG_IsBusy As Boolean = False
#end region
	
End Sub


Public Sub getCN() As HttpOctoRestAPI
	Return oCN
End Sub


Public Sub Initialize
	
	mainObj = B4XPages.MainPage
	parser.Initialize() '--- init the octo rest parser
	
End Sub

Public Sub Start
	GetConnectionPrinterStatus
End Sub


Public Sub SetCallbackObj(CallBack As Object,EventNameTemp As String, _
																EventNameStatus As String, _
																EventNameBtns As String)
	mEventNameTemp = EventNameTemp
	mEventNameStatus = EventNameStatus
	mEventNameBtns = EventNameBtns
	mCallBack = CallBack
	
End Sub


'============================================================================================
'============================================================================================
'============================================================================================

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
	
	'Update_PrintingButtonsStatus
	
'	If config.pTurnOnDebugTabFLAG  Then
'	'	CallSubDelayed(oTabHome.oSubTab,"Update_DebuggingWindow")
'	End If
	
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



Private Sub GetAllOctoSettingInfo
	
	If mGotOctoSettingFLAG_IsBusy = True Then
		logMe.LogDebug2("mGotOctoSettingFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotOctoSettingFLAG_IsBusy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo( oc.cSETTINGS)
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
	
		Dim o As JsonParserMasterPrinterSettings  : o.Initialize
		gMapOctoTempSettings.Initialize
		gMapOctoTempSettings = o.GetPresetHeaterSettings(Result)
		mGotOctoSettingFLAG = True '--- will stop it from firing in the main loop
		
'		If oTabHome.oSubTab.oSubTabHeater.IsInitialized Then
'			CallSubDelayed2(oTabHome.oSubTab.oSubTabHeater,"Set_HeatingCBOoptions",gMapOctoTempSettings)
'		End If
	
		mGotOctoSettingFLAG_IsBusy = False
	Else
		
		'oc.RestPrinterProfileVars
		
	End If
	
End Sub


Private Sub GetPrinterProfileInfo
	
	If oc.PrinterProfile.Length = 0 Then Return
	
	If mGotProfileInfoFLAG_IsBusy = True Then
		logMe.LogDebug2("mGotProfileInfoFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotProfileInfoFLAG_IsBusy = True
	
	Dim sendMe As String = oc.cPRINTER_PROFILES & "\" & oc.PrinterProfile
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo(sendMe)
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
	
		Dim o As JsonParserMasterPrinterSettings : 	o.Initialize
		o.ParsePrinterProfile(Result)
		mGotProfileInfoFLAG = True '--- will stop it from fiting in the main loop
		'CallSubDelayed(oTabHome,"Update_PrinterName")
		
		mGotProfileInfoFLAG_IsBusy = False
		
	Else
		
		oc.RestPrinterProfileVars
		
	End If
	
End Sub



Private Sub GetTemps
	
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
	
End Sub


Private Sub GetJobStatus
	
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
	
End Sub


Private Sub GetConnectionPrinterStatus
	
	'--- called once on 1st start
	Dim rs As ResumableSub = oCN.SendRequestGetInfo(oc.cCONNECTION)
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		
		parser.ConnectionStatus(Result)
		
		'--- turn on main loop timer
		CallSub(Main,"TurnOn_MainTmr")
		tmrMain_Tick
		
	Else
		oc.ResetStateVars
		
	End If
	
End Sub

public Sub Download_ThumbnailAndCache2File(JobFileName As String,outFileName As String)
	
	Try
		
		Dim link As String
		''http://192.168.1.236:5003/plugin/prusaslicerthumbnails/thumbnail/asus_eee_pad_bracket_fixed (2).png
		link  = $"http://${oCN.gIP}:${oCN.gPort}/"$ & JobFileName'oc.JobPrintThumbnail.SubString2(0,oc.JobPrintThumbnail.IndexOf("?"))
		'Dim fname As String = gbl.BuildThumbnailTempFilename(gbl.GetFilenameFromHTTP(link))
		oCN.Download_AndSaveFile(link,outFileName)
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		Log(LastException)
	End Try

	
End Sub


public Sub GetAllOctoFilesInfo
	
	If mGotFilesListFLAG_IsBusy = True Then
		logMe.LogDebug2("mGotFilesListFLAG_IsBusy = True",mModule)
		Return '---already been called
	End If
	
	mGotFilesListFLAG_IsBusy = True
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo( oc.cFILES)
	
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then

		Dim o As JsonParserFiles  : o.Initialize(True) '--- download thumbnails
		gMapOctoFilesList.Initialize
		gMapOctoFilesList = o.GetAllFiles(Result)
		
		'--- populate the listview - this will hapen when the File TAB gets focus
		'If oTabHome.oSubTab.oSubTabHeater.IsInitialized Then
		'	CallSubDelayed(oTabHome.oSubTab.oSubTabHeater,"Set_HeatingCBOoptions")
		'End If
	
		mGotFilesListFLAG = True '--- will stop it from firing in the main loop
		mGotFilesListFLAG_IsBusy = False '--- reset the is busy flag
		
	Else
		
		'oc.RestPrinterProfileVars
		
	End If
	
End Sub






