B4A=true
Group=B4XPAGES
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
Sub Class_Globals
	
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private Const mModule As String = "B4XSetupPage" 'ignore
	
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
	Private btnCheckConnection As B4XView
	Private btnGetOctoKey As B4XView
	Private txtOctoKey As B4XFloatTextField
	Private txtPrinterDesc As B4XFloatTextField
	Private txtPrinterIP As B4XFloatTextField
	Private txtPrinterPort As B4XFloatTextField
	Private pnlMain As B4XView
	
	Private ValidConnection As Boolean = False
	Private oConnectionCheck As CheckOctoConnection
	Private oGetOctoKey As RequestApiKey
	Private toast As BCToast
	Private firstRun As Boolean = False
	
	'Public mCanceled As Boolean = True
	Private btnCancel,btnSave As Button
	
End Sub

'
'Public Sub getCanceled As Boolean
'	Return mCanceled
'End Sub


Public Sub Initialize(firstTime As Boolean) As Object
	firstRun = firstTime
	Return Me
End Sub

'================================================================================

#region "PAGE EVENTS"
Private Sub B4XPage_Created (Root1 As B4XView)
	
	Root = Root1
	Root.LoadLayout("pageSetup")
	toast.Initialize(Root)
	pnlMain.Color = xui.Color_Transparent
	CallSubDelayed(Me,"Build_GUI") 
		
End Sub

Sub B4XPage_Appear
	btnSave.Enabled = False
End Sub

'Sub B4XPage_Disappear
'End Sub
#end region

private Sub Build_GUI
	
	guiHelpers.SetTextColorB4XFloatTextField( _
			Array As B4XFloatTextField(txtOctoKey,txtPrinterDesc,txtPrinterIP,txtPrinterPort))
	
	txtPrinterDesc.HintText = "Printer Description"
	txtPrinterDesc.NextField = txtPrinterIP
	txtPrinterIP.HintText = "Octoprint IP"
	txtPrinterIP.NextField = txtPrinterPort
	txtPrinterPort.HintText = "Octoprint Port"
	txtPrinterPort.NextField = txtOctoKey
	txtOctoKey.HintText = "Octoprint API Key"

	btnCheckConnection.Text= "Validate Connection"
	btnGetOctoKey.Text = "Request Octoprint Key"
	
	btnCancel.Text = "Close"
	btnSave.Text = "Save"

	If firstRun = False Then 
		ReadSettingsFile
	End If
	
	InvalidateConnection
	'EnableDisableValidationCheckBtn
	
	txtPrinterDesc.RequestFocusAndShowKeyboard
	
'	#if debug	
'	If txtPrinterIP.Text.Length = 0 Then
'		txtPrinterIP.Text = "192.168.1.236"
'		txtPrinterPort.Text= "5003"
'	End If
'	#end if	

	
End Sub


private Sub ReadSettingsFile

	'--- read settings file (if there is one) and pre-populate txt boxes
	Dim m As Map = fnc.LoadPrinterConnectionSettings
	If m.IsInitialized = False Then Return
	
	txtOctoKey.Text = m.Get( gblConst.PRINTER_OCTO_KEY)
	txtPrinterDesc.Text = m.Get( gblConst.PRINTER_DESC)
	txtPrinterIP.Text = m.Get( gblConst.PRINTER_IP)
	txtPrinterPort.Text = m.Get( gblConst.PRINTER_PORT)

End Sub


private Sub Save_settings
	
	Dim fname As String = fnc.GetPrinterProfileConnectionFileName(txtPrinterDesc.text)
	Dim outMap As Map = CreateMap( _
						gblConst.PRINTER_DESC : txtPrinterDesc.text, gblConst.PRINTER_IP: txtPrinterIP.Text, _
						gblConst.PRINTER_PORT : txtPrinterPort.Text, gblConst.PRINTER_OCTO_KEY : txtOctoKey.Text)

							
	toast.DurationMs = 2500 : toast.Show("Saved")
	fileHelpers.SafeKill(fname)
	File.WriteMap(xui.DefaultFolder,fname,outMap)
	oc.IsOctoConnectionVarsValid = True
	
	
End Sub


Private Sub SetSaveButtonState
	btnSave.Enabled = ValidConnection
End Sub


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


Private Sub btnSave_Click
	Save_settings
	CallSub2(B4XPages.MainPage,"PrinterSetup_Closed",True)
	B4XPages.ShowPageAndRemovePreviousPages(gblConst.PAGE_MAIN)
End Sub


Private Sub btnCancel_Click
	B4XPages.ShowPageAndRemovePreviousPages(gblConst.PAGE_MAIN)
End Sub


#Region "CONNECTION CHECK"
Private Sub btnCheckConnection_Click
	
	'--- see if inputs are valid
	Dim msg As String = CheckInputs
	If msg.Length <> 0 Then
		B4XLoadingIndicator1.Hide
		Dim sf As Object = xui.Msgbox2Async($"Input Error! ${msg}"$, "Problem", "OK", "", "", Null)
		Wait For (sf) Msgbox_Result (Result As Int)
		Return
	End If
	
	'--- disable dialog
	pnlMain.Enabled = False
	SetSaveButtonState
	B4XLoadingIndicator1.Show
	Sleep(200)
			
	'--- run connection check
	toast.DurationMs = 500 : toast.Show("Checking Connection...")
	
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
	SetSaveButtonState

	If ValidConnection Then
		toast.DurationMs = 1500 : toast.Show("Connection OK")
	Else
		Dim msg As StringBuilder : msg.Initialize
		msg.Append("Connection Failed.").Append(CRLF).Append("A couple of things to think about").Append(CRLF)
		msg.Append("Is Octoprint turned on?").Append(CRLF).Append("Are Your IP And Port correct?").Append(CRLF)
		Dim sf As Object = xui.Msgbox2Async(msg.ToString, "Problem", "OK", "", "", Null)
		Wait For (sf) Msgbox_Result (result1 As Int)
	End If
	
	
End Sub
#end region


#region "REQUEST OCTO KEY"
Private Sub btnGetOctoKey_Click

	If txtPrinterIP.Text.Length = 0 Or txtPrinterPort.Text.Length = 0 Then
		Dim sf As Object = xui.Msgbox2Async("Please check if your IP and Port Are Set", "Problem", "OK", "", "", Null)
		Wait For (sf) Msgbox_Result (result1 As Int)
		Return
	End If
	
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("You are about to request a API key from Octoprint. ")
	msg.Append("Press the OK button and go to your Octoprint web interface. ")
	msg.Append("You will need to click OK in Octoprint to confirm that this app can have access").Append(CRLF & CRLF)
	msg.Append("Press OK when ready").Append(CRLF)
	Dim sf As Object = xui.Msgbox2Async(msg.ToString, "Information", "OK", "", "CANCEL", Null)
	Wait For (sf) Msgbox_Result (result1 As Int)
	If result1 <> xui.DialogResponse_Positive Then
		Return
	End If
	
	
	'--- show I am busy!
	pnlMain.Enabled = False
	B4XLoadingIndicator1.Show
	Sleep(300)
	
	'--- start the request for an octokey
	oGetOctoKey.Initialize(Me,"RequestAPI",gblConst.APP_TITLE,txtPrinterIP.Text,txtPrinterPort.Text)
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
			SetSaveButtonState
		Else
			'--- some error happened
			Dim sf1 As Object = xui.Msgbox2Async(result.As(String), "Problem", "OK", "", "", Null)
			Wait For (sf1) Msgbox_Result (result1 As Int)
		End If
		
	Catch
		Log(LastException)
	End Try
		
End Sub
#end region


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
	btnSave.Enabled = False
End Sub
#End Region



'Private Sub EnableDisableValidationCheckBtn
'	btnCheckConnection.Enabled = Not ( txtOctoKey.Text.Length = 0  Or _
'														 txtPrinterIP.Text.Length = 0  Or _
'														 txtPrinterPort.Text.Length = 0 )
'														 
'	btnGetOctoKey.Enabled = Not ( txtPrinterIP.Text.Length = 0  Or  txtPrinterPort.Text.Length = 0 )
'End Sub
