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
	
	Private mValidConnection As Boolean = False
	Private mDialog As B4XDialog
	
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String)
	
	mMainObj = mobj
	mTitle = title
	
End Sub


Public Sub Show
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 510dip, 300dip)
	p.LoadLayout("viewSonOffSetup")
	
	Build_GUI 

	guiHelpers.ThemeDialogForm(mDialog, mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "SAVE", "", "CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	ReadSettingsFile
	InvalidateConnection
	
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)

	'--- show KB	
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"Show_KB",400)
	
	Wait For (rs) Complete (Result As Int)
	
	guiHelpers.RestoreImersiveIfNeeded
	If Result = xui.DialogResponse_Positive Then
		Save_settings
		config.ReadSonoffCFG
		CallSub(mMainObj.oPageCurrent,"Set_focus")
	End If
	
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
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
			Array As B4XView(mDialog.GetButton(xui.DialogResponse_Positive)),mValidConnection)	
	Catch
		'Log(LastException)
	End Try 'ignore
End Sub

Private Sub EnableDisableBtns(en As Boolean)
	
	guiHelpers.EnableDisableBtns(Array As B4XView( _
		mDialog.GetButton(xui.DialogResponse_Positive),mDialog.GetButton(xui.DialogResponse_Cancel), _
		btnCheckConnection),en)
			
End Sub


#Region "CONNECTION CHECK"
Private Sub btnCheckConnection_Click
	
	'--- see if inputs are valid
	Dim msg As String = CheckInputs
	If msg.Length <> 0 Then
		'--- custom dlgMSgBox not working inside another dialog object
		'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",580dip, 220dip)
		'Wait For (mb.Show(msg,gblConst.MB_ICON_WARNING,"OK","","")) Complete (res As Int)
		Dim sf As Object = xui.Msgbox2Async($"Input Error! ${msg}"$, "Problem", "OK", "", "",Null)
		Wait For (sf) Msgbox_Result (Result As Int)
		Return
	End If
	
	'--- disable dialog
	pnlMain.Enabled = False
	EnableDisableBtns(False)
	B4XLoadingIndicator1.Show
	Sleep(20)
			
	'--- run connection check
	guiHelpers.Show_toast("Checking Sonoff Connection...",800)
	
	Dim o As HttpDownloadStr : o.Initialize
	Wait For (o.SendRequest($"http://${txtPrinterIP.Text}"$)) Complete(s As String)

	If s.Contains("Tasmota") Then
		mValidConnection = True
	Else If s.Length > 0 Then
		If config.logREST_API Then
			logMe.logit2(s,mModule,"btnCheckConnection_Click")
		End If
	End If
	
	B4XLoadingIndicator1.Hide
	
	If mValidConnection Then
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
	Else
		If fnc.IsValidIPv4Address(txtPrinterIP.Text) = False Then
			msg = "Invalid IPv4 address"
		End If
	End If
	
	Return msg
	
End Sub

#Region "TEXT FIELD EVENTS"
Private Sub txtPrinterIP_TextChanged (Old As String, New As String)
	InvalidateConnection
End Sub

Private Sub InvalidateConnection
	mValidConnection = False
	SetSaveButtonState
End Sub
#End Region


private Sub ReadSettingsFile

	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE)
	txtPrinterIP.Text = Data.Get(gblConst.SONOFF_IP)
	B4XSwitch1.Value = Data.Get(gblConst.SONOFF_ON).As(Boolean)

End Sub

