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
	
	Private const mModule As String = "dlgOctoSetup"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	Private mEventName As String
	
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
	Private btnCheckConnection,btnGetOctoKey As B4XView
	
	Private txtOctoKey As B4XFloatTextField
	Private txtPrinterDesc As B4XFloatTextField
	Private txtPrinterIP As B4XFloatTextField
	Private txtPrinterPort As B4XFloatTextField
	Private pnlMain As B4XView
	
	Private ValidConnection As Boolean = False
	Private oConnectionCheck As CheckOctoConnection
	Private oGetOctoKey As RequestApiKey
	
	Private Dialog As B4XDialog
	
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String, EventName As String)
	
	mMainObj = mobj
	mTitle = title
	mEventName = EventName
	
End Sub


Public Sub Show(firstRun As Boolean)
	
	'--- init
	Dialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	Dim w, h As Float
	
	If guiHelpers.gScreenSizeAprox < 8 Then
		w = 80%x : h = 74%y
	Else
		w = 74%x : h = 70%y
	End If
	
	p.SetLayoutAnimated(0, 0, 0, w, h)
	p.LoadLayout("viewOctoSetup")
	
	Build_GUI 

	guiHelpers.ThemeDialogForm(Dialog, mTitle)
	Dim rs As ResumableSub = Dialog.ShowCustom(p, "SAVE", "", "CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(Dialog)

	If firstRun = False Then ReadSettingsFile
	InvalidateConnection
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)

	'--- show KB	
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"Show_KB",400)
	
	Wait For (rs) Complete (Result As Int)
	
	guiHelpers.RestoreImersiveIfNeeded
	If Result = xui.DialogResponse_Positive Then
		Save_settings
		CallSub(mMainObj,mEventName)
	End If
	
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub


Private Sub Show_KB
	txtPrinterDesc.RequestFocusAndShowKeyboard
End Sub


private Sub Build_GUI
	
	pnlMain.Color = clrTheme.Background
	guiHelpers.SetTextColorB4XFloatTextField( _
			Array As B4XFloatTextField(txtPrinterDesc,txtPrinterIP,txtPrinterPort))
	
	txtPrinterDesc.HintText = "Printer Description"
	txtPrinterDesc.NextField = txtPrinterIP
	
	txtPrinterIP.HintText = "Octoprint IP"
	txtPrinterIP.NextField = txtPrinterPort
	
	txtPrinterPort.HintText = "Octoprint Port"
	
	'txtPrinterPort.NextField = txtOctoKey
	'txtOctoKey.HintText = "Octoprint API Key"

	btnCheckConnection.Text= "Validate Connection"
	btnGetOctoKey.Text = "Request Octoprint Key"
	
	btnCheckConnection.Font = xui.CreateDefaultFont(NumberFormat2(btnCheckConnection.Font.Size / guiHelpers.gFscale,1,0,0,False))
	btnGetOctoKey.Font = xui.CreateDefaultFont(NumberFormat2(btnGetOctoKey.Font.Size / guiHelpers.gFscale,1,0,0,False))
End Sub


private Sub Save_settings
	
	'Dim fname As String = fnc.GetPrinterProfileConnectionFileName(txtPrinterDesc.text) 'TODO, for multi configs
	Dim fname As String = "default.psettings"
	Dim outMap As Map = CreateMap( _
						gblConst.PRINTER_DESC : txtPrinterDesc.text, gblConst.PRINTER_IP: txtPrinterIP.Text, _
						gblConst.PRINTER_PORT : txtPrinterPort.Text, gblConst.PRINTER_OCTO_KEY : txtOctoKey.Text)


	guiHelpers.Show_toast("Saved",2500)							
	fileHelpers.SafeKill(fname)
	File.WriteMap(xui.DefaultFolder,fname,outMap)
	oc.IsOctoConnectionVarsValid = True
	
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
		btnCheckConnection,btnGetOctoKey),en)
			
End Sub


#Region "CONNECTION CHECK"
Private Sub btnCheckConnection_Click
	
	'--- see if inputs are valid
	Dim msg As String = CheckInputs
	If msg.Length <> 0 Then
		B4XLoadingIndicator1.Hide
		'--- custom dlgMSgBox not working inside another dialog object
		'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",580dip, 220dip)
		'Wait For (mb.Show(msg,gblConst.MB_ICON_WARNING,"OK","","")) Complete (res As Int)
		Dim sf As Object = xui.Msgbox2Async($"Input Error! ${msg}"$, "Problem", "OK", "", "",Null)
		Wait For (sf) Msgbox_Result (Result As Int)
		Return
	End If
	
	'--- disable dialog
	pnlMain.Enabled = False
	'SetSaveButtonState
	EnableDisableBtns(False)
	B4XLoadingIndicator1.Show
	Sleep(200)
			
	'--- run connection check
	guiHelpers.Show_toast("Checking Connection...",800)
	
	oConnectionCheck.Initialize(Me,"connect")
	
	'--- Sub connect_Complete (result As String, success As Boolean) WILL FIRE ON COMPLETION
	'--- now lets check the connection
	oConnectionCheck.Check(txtPrinterIP.Text,txtPrinterPort.Text,txtOctoKey.Text)
	
End Sub


'--- Event Callback from 'ConnectionCheck' class
Public Sub connect_Complete (result As Object, success As Object)
	
	'--- re-enable the page
	pnlMain.Enabled = True
	B4XLoadingIndicator1.Hide
	
	ValidConnection = success.As(Boolean)
	EnableDisableBtns(True)
	SetSaveButtonState

	If ValidConnection Then
		guiHelpers.Show_toast("Connection OK",3000)
	Else
		Dim msg As StringBuilder : msg.Initialize
		msg.Append("Connection Failed.").Append(CRLF).Append("A couple of things to think about.").Append(CRLF)
		msg.Append("Is Octoprint turned on?").Append(CRLF).Append("Are Your IP And Port correct?")
		'--- custom dlgMSgBox not working inside another dialog object
		'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",580dip, 220dip)
		'Wait For (mb.Show(msg.ToString,gblConst.MB_ICON_WARNING,"OK","","")) Complete (res As Int)
		Dim oo As Object = xui.Msgbox2Async($"${msg}"$, "Problem", "OK", "", "",Null)
		Wait For (oo) Msgbox_Result (result1 As Int)
	End If
	
End Sub
#end region


#region "REQUEST OCTO KEY"
Private Sub btnGetOctoKey_Click

	If txtPrinterIP.Text.Length = 0 Or txtPrinterPort.Text.Length = 0 Then
		'--- custom dlgMSgBox not working inside another dialog object
		'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",540dip, 200dip)
		'Wait For (mb.Show("Please check if your IP and Port Are Set", _
		'			gblConst.MB_ICON_WARNING,"OK","","")) Complete (res As Int)
		Dim oo As Object = xui.Msgbox2Async("Please check if your IP and Port Are Set", "Problem", "OK", "", "",Null)
		Wait For (oo) Msgbox_Result (result1 As Int)
		Return
	End If
	
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("You are about to request a API key from Octoprint. ")
	msg.Append("Press the OK button and go to your Octoprint web interface. ")
	msg.Append("You will need to click OK in Octoprint to confirm that this app can have access").Append(CRLF & CRLF)
	msg.Append("Press OK when ready") '.Append(CRLF)
	'--- custom dlgMSgBox not working inside another dialog object
	'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"About",500dip, 220dip)
	'mb.lblTxt.Font = xui.CreateDefaultFont(20)
	'Wait For (mb.Show(msg.ToString,gblConst.MB_ICON_INFO,"OK","","")) Complete (res As Int)
	Dim o1 As Object = xui.Msgbox2Async(msg.ToString, "About", "OK", "", "CANCEL",Null)
	Wait For (o1) Msgbox_Result (res As Int)
	If res <> xui.DialogResponse_Positive Then
		Return
	End If
	
	
	'--- show I am busy!
	pnlMain.Enabled = False
	B4XLoadingIndicator1.Show
	EnableDisableBtns(False)
	Sleep(300)
	
	'--- start the request for an octokey
	oGetOctoKey.Initialize(Me,"RequestAPI",gblConst.APP_TITLE.Replace("™","").Trim, _
								txtPrinterIP.Text,txtPrinterPort.Text)
	oGetOctoKey.RequestAvailable
	
End Sub


'--- callback from oGetOctoKey
Public Sub RequestAPI_RequestComplete (result As Object, Success As Object)

	'--- end busy show
	pnlMain.Enabled = True
	B4XLoadingIndicator1.Hide

	Try
		If Success Then
			txtOctoKey.Text = result.As(String)
			ValidConnection = True
		Else
			'--- custom dlgMSgBox not working inside another dialog object
			'Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",540dip, 220dip)
			'Wait For (mb.Show(result.As(String),gblConst.MB_ICON_WARNING,"OK","","")) Complete (res As Int)
			Dim oo As Object = xui.Msgbox2Async(result.As(String), "Problem", "OK", "", "",Null)
			Wait For (oo) Msgbox_Result (result1 As Int)
		End If
		
	Catch
		
		logMe.LogIt2(LastException,mModule,"RequestAPI_RequestComplete")
		
	End Try

	EnableDisableBtns(True)
	SetSaveButtonState
		
End Sub
#end region


Private Sub CheckInputs() As String
	'--- Validation check
	Dim msg As String
	
	Do While True
		
		'If txtPrinterIP.Text.Length = 0 Or CheckValidIPAddr(txtPrinterIP.Text) Then
		If txtPrinterIP.Text.Length = 0  Then
			msg = "Missing IP address" : Exit
		End If
		
		If txtPrinterPort.Text.Length = 0  Then
			msg = "Missing Port Number" : Exit
		End If
		
		If txtOctoKey.Text.Length = 0 Then
			msg = "Missing Octoprint Key" : Exit
		End If
		
		If txtPrinterDesc.Text.Length = 0 Then
			msg = "Missing Printer Description" : Exit
		End If
		
		Exit
	Loop

	Return msg
	
End Sub

#Region "TEXT FIELD EVENTS"
Private Sub txtPrinterDesc_TextChanged (Old As String, New As String)
	InvalidateConnection
End Sub

Private Sub txtPrinterIP_TextChanged (Old As String, New As String)
	InvalidateConnection
End Sub

Private Sub txtPrinterPort_TextChanged (Old As String, New As String)
	InvalidateConnection
End Sub

Private Sub txtOctoKey_TextChanged (Old As String, New As String)
	InvalidateConnection
End Sub

Private Sub InvalidateConnection
	ValidConnection = False
	SetSaveButtonState
End Sub
#End Region


private Sub ReadSettingsFile

	'--- read settings file (if there is one) and pre-populate txt boxes
	Dim m As Map = fnc.LoadPrinterConnectionSettings
	If m.IsInitialized = False Then Return
	
	txtOctoKey.Text = m.Get( gblConst.PRINTER_OCTO_KEY)
	txtPrinterDesc.Text = m.Get( gblConst.PRINTER_DESC)
	txtPrinterIP.Text = m.Get( gblConst.PRINTER_IP)
	txtPrinterPort.Text = m.Get( gblConst.PRINTER_PORT)

End Sub
