B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/23/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgSonOff"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
	Private btnCheckConnection As B4XView
	Private B4XSwitch1 As B4XSwitch, lblSwitch As B4XView
	
	Private txtPrinterIP As B4XFloatTextField
	Private pnlMain As B4XView
	
	Private ValidConnection As Boolean = False
	Private Dialog As B4XDialog
	
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String)
	
	mMainObj = mobj
	mTitle = title
	
End Sub


Public Sub Show
	
	'--- init
	Dialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 510dip, 300dip)
	p.LoadLayout("viewSonOffSetup")
	
	Build_GUI 

	guiHelpers.ThemeDialogForm(Dialog, mTitle)
	Dim rs As ResumableSub = Dialog.ShowCustom(p, "SAVE", "", "CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(Dialog)

	ReadSettingsFile
	InvalidateConnection

	'--- show KB	
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"Show_KB",400)
	
	Wait For (rs) Complete (Result As Int)
	
	guiHelpers.RestoreImersiveIfNeeded
	If Result = xui.DialogResponse_Positive Then
		Save_settings
		config.ReadSonoffCFG
		CallSub(mMainObj.oPageCurrent,"Set_focus")
	End If
	
End Sub


Private Sub Show_KB
	txtPrinterIP.RequestFocusAndShowKeyboard
End Sub


private Sub Build_GUI
	
	pnlMain.Color = clrTheme.Background
	guiHelpers.SetTextColorB4XFloatTextField(Array As B4XFloatTextField(txtPrinterIP))
	
	txtPrinterIP.HintText = "Sonoff IP"
	
	btnCheckConnection.Text= "Test"
	btnCheckConnection.Font = xui.CreateDefaultFont(NumberFormat2(btnCheckConnection.Font.Size / guiHelpers.gFscale,1,0,0,False))
	
End Sub

Public Sub CreateDefaultFile

	File.WriteMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE, _
		CreateMap(gblConst.SONOFF_IP : "", gblConst.SONOFF_ON : "false"))
	
End Sub


private Sub Save_settings
	
	Dim outMap As Map = CreateMap( _
						gblConst.SONOFF_IP : txtPrinterIP.text, gblConst.SONOFF_ON : B4XSwitch1.Value.As(String))


	guiHelpers.Show_toast("Saved",2500)							
	fileHelpers.SafeKill(gblConst.SONOFF_OPTIONS_FILE)
	File.WriteMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE,outMap)
	
End Sub


Private Sub SetSaveButtonState
	Try
		guiHelpers.EnableDisableBtns( _
			Array As B4XView(Dialog.GetButton(xui.DialogResponse_Positive)),ValidConnection)	
	Catch
		'Log(LastException)
	End Try 'ignore
End Sub

Private Sub EnableDisableBtns(en As Boolean)
	
	guiHelpers.EnableDisableBtns(Array As B4XView( _
		Dialog.GetButton(xui.DialogResponse_Positive),Dialog.GetButton(xui.DialogResponse_Cancel), _
		btnCheckConnection),en)
			
End Sub


#Region "CONNECTION CHECK"
Private Sub btnCheckConnection_Click
	
	'--- see if inputs are valid
	
	Dim msg As String = CheckInputs
	If msg.Length <> 0 Then
		'B4XLoadingIndicator1.Hide
		'--- custom dlgMSgBox not working inside another dialog object
		'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",580dip, 220dip)
		'Wait For (mb.Show(msg,gblConst.MB_ICON_WARNING,"OK","","")) Complete (res As Int)
		Dim sf As Object = xui.Msgbox2Async($"Input Error! ${msg}"$, "Problem", "OK", "", "",Null)
		Wait For (sf) Msgbox_Result (Result As Int)
		Return
	End If
	
	Dim inSub As String = "btnCheckConnection_Click"
	'--- disable dialog
	pnlMain.Enabled = False
	'SetSaveButtonState
	EnableDisableBtns(False)
	B4XLoadingIndicator1.Show
	Sleep(200)
			
	'--- run connection check
	guiHelpers.Show_toast("Checking Connection...",800)
	
	Dim sAPI As String = $"http://${txtPrinterIP.Text}"$
	Dim j As HttpJob: j.Initialize("", Me)
	
	If config.logREST_API Then
		logMe.logit2($"ConnectCheck:-->${sAPI}"$,mModule,inSub)
	End If

	Dim connected2something As Boolean = False 'ignore - TODO, do we want expanded error checking?
	j.Download(sAPI)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		If j.GetString.Contains("Tasmota") Then
			ValidConnection = True
		Else
			connected2something = True
			If config.logREST_API Then
				logMe.logit2($"ConnectCheck:-->${j.GetString}"$,mModule,inSub)
			End If
		End If
	End If
	
	j.Release '--- free up resources
	
	If config.logREST_API Then
		logMe.logit2($"ConnectCheck:-->${sAPI}"$,mModule,inSub)
	End If
	
	B4XLoadingIndicator1.Hide
	
	If ValidConnection Then
		guiHelpers.Show_toast("Connection OK",3000)
	Else
		'--- custom dlgMSgBox not working inside another dialog object
		'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",580dip, 220dip)
		'Wait For (mb.Show(msg.ToString,gblConst.MB_ICON_WARNING,"OK","","")) Complete (res As Int)
		Dim oo As Object = xui.Msgbox2Async("Connection Failed. Check your IP", "Problem", "OK", "", "",Null)
		Wait For (oo) Msgbox_Result (result1 As Int)
	End If
	
	EnableDisableBtns(True)
	SetSaveButtonState

End Sub
#end region



Private Sub CheckInputs() As String

	'--- Validation check
	Dim msg As String = ""
	If txtPrinterIP.Text.Length = 0  Then
		msg = "Missing IP address" 
	End If
	Return msg
	
End Sub

#Region "TEXT FIELD EVENTS"
Private Sub txtPrinterIP_TextChanged (Old As String, New As String)
	InvalidateConnection
End Sub

Private Sub InvalidateConnection
	ValidConnection = False
	SetSaveButtonState
End Sub
#End Region


private Sub ReadSettingsFile

	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE)
	txtPrinterIP.Text = Data.Get(gblConst.SONOFF_IP)
	B4XSwitch1.Value = Data.Get(gblConst.SONOFF_ON).As(Boolean)

End Sub


'Private Sub B4XSwitch1_ValueChanged (Value As Boolean)
	
'End Sub