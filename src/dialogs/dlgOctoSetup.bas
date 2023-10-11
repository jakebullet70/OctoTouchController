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

'
' --- NOT USED IN KLIPPER, USED FOR OCTOPRINT
' --- NOT USED IN KLIPPER, USED FOR OCTOPRINT
'


Sub Class_Globals
	
	Private const mModule As String = "dlgOctoSetup"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	Private mEventName As String
	
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
	Private btnCheckConnection As Button
	Private btnGetOctoKey As Button
	
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



Public Sub Initialize( title As String, EventName As String) As Object
	
	mMainObj = B4XPages.MainPage
	mTitle = title
	mEventName = EventName
	
	Return Me
End Sub


Public Sub Show(firstRun As Boolean)
	
	mMainObj.pPrinterCfgDlgShowingFLAG = True
	
	'--- init
	Dialog.Initialize(mMainObj.Root)
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(Dialog)
	
	Dim p As B4XView = xui.CreatePanel("")
	Dim w, h As Float
	
	If guiHelpers.gScreenSizeAprox < 8 Then
		w = 92%x
		h = IIf(guiHelpers.gIsLandScape,74%y,62%y)
	Else
		w = 74%x : h = 70%y
	End If
	
	p.SetLayoutAnimated(0, 0, 0, w, h)
	p.LoadLayout("viewOctoSetup")
	
	Build_GUI 

	dlgHelper.ThemeDialogForm(mTitle)
	Dim rs As ResumableSub = Dialog.ShowCustom(p, "SAVE", "", "CLOSE")
	Dialog.Base.Parent.Tag = "" 'this will prevent the dialog from closing when the second dialog appears.
	dlgHelper.ThemeInputDialogBtnsResize
	
	If firstRun = False Then 
		ReadSettingsFile
	Else
		txtPrinterDesc.Text = "Default"		
	End If
	InvalidateConnection
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)

	'--- show KB	
	Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Show_KB",100)
	
	Wait For (rs) Complete (Result As Int)
	
	mMainObj.pPrinterCfgDlgShowingFLAG = False
	
	If Result = xui.DialogResponse_Positive Then
		Save_settings
		CallSub(mMainObj,mEventName)
	End If
	
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
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
	guiHelpers.SkinButton(Array As Button(btnCheckConnection,btnGetOctoKey))
	
	btnCheckConnection.TextSize = NumberFormat2(btnCheckConnection.TextSize / guiHelpers.gFscale,1,0,0,False)
	btnGetOctoKey.TextSize = NumberFormat2(btnGetOctoKey.TextSize / guiHelpers.gFscale,1,0,0,False)
	
End Sub


private Sub Save_settings
	
	'Dim fname As String = fnc.GetPrinterProfileConnectionFileName(txtPrinterDesc.text) 'TODO, for multi configs
	
	Dim outMap As Map = CreateMap( _
						gblConst.PRINTER_DESC : txtPrinterDesc.text, gblConst.PRINTER_IP: txtPrinterIP.Text, _
						gblConst.PRINTER_PORT : txtPrinterPort.Text, gblConst.PRINTER_OCTO_KEY : txtOctoKey.Text)


	guiHelpers.Show_toast(gblConst.DATA_SAVED,2500)
	fileHelpers.SafeKill(gblConst.PRINTER_SETUP_FILE)
	File.WriteMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE,outMap)
	oc.IsConnectionValid = True
	
	'--- when DEV'n and switching printers forces a rescan of files
	If mMainObj.oPageFiles.IsInitialized Then
		mMainObj.oPageFiles.FileEvent = True
	End If
	
	
End Sub




Private Sub SetSaveButtonState
	Try
		guiHelpers.EnableDisableViews( _
			Array As B4XView(Dialog.GetButton(xui.DialogResponse_Positive)),ValidConnection)	
	Catch
		'Log(LastException)
	End Try 'ignore
End Sub


Private Sub EnableDisableBtns(en As Boolean)

	guiHelpers.EnableDisableViews(Array As B4XView( _
									Dialog.GetButton(xui.DialogResponse_Positive),Dialog.GetButton(xui.DialogResponse_Cancel), _
								 	btnCheckConnection,btnGetOctoKey),en)
		
End Sub


#Region "CONNECTION CHECK"
Private Sub btnCheckConnection_Click
	
	'--- see if inputs are valid
	Dim msg As String = CheckInputs
	If msg.Length <> 0 Then
		B4XLoadingIndicator1.Hide
		Dim mb As dlgMsgBox
		Dim w As Float = IIf(guiHelpers.gIsLandScape,460dip,94%x)
		mb.Initialize(mMainObj.Root,"Problem",w, 220dip,False)
		Wait For (mb.Show(msg,gblConst.MB_ICON_WARNING,"","","OK")) Complete (res As Int)
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
		
		Dim w As Float = IIf(guiHelpers.gIsLandScape,500dip,90%x)

		Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",w, 220dip,False)
		Dim gui As guiMsgs  : gui.Initialize
		Wait For (mb.Show(gui.GetConnectFailedMsg,gblConst.MB_ICON_WARNING,"","","OK")) Complete (res As Int)
	End If
	
End Sub
#end region


#region "REQUEST OCTO KEY"
Private Sub btnGetOctoKey_Click
	
	If txtPrinterPort.Text.Length = 0 Then txtPrinterPort.Text = "80"

	Dim w As Float
	If guiHelpers.gIsLandScape Then
		w = 500dip
	Else
		w = 94%x
	End If
	
	If txtPrinterIP.Text.Length = 0 Then
		'--- custom dlgMSgBox not working inside another dialog object
		Dim mb As dlgMsgBox 
		mb.Initialize(mMainObj.Root,"Problem",w, 200dip,False)
		Wait For (mb.Show("Please check if your IP and Port Are Set", _
					gblConst.MB_ICON_WARNING,"","","OK")) Complete (res As Int)
		Return
	End If
	
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("You are about to request a API key from Octoprint. ")
	msg.Append("Press the OK button and go to your Octoprint web interface. ")
	msg.Append("You will need to click OK in Octoprint to confirm that this app can have access").Append(CRLF & CRLF)
	msg.Append("Press OK when ready") '.Append(CRLF)

	Dim mb As dlgMsgBox 
	mb.Initialize(mMainObj.Root,"Request Octo Key", w, 220dip,False)
	Wait For (mb.Show(msg.ToString,gblConst.MB_ICON_INFO,"OK","","CANCEL")) Complete (res As Int)
	'Dim o1 As Object = xui.Msgbox2Async(msg.ToString, "About", "OK", "", "CANCEL",Null)
	'Wait For (o1) Msgbox_Result (res As Int)
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
			guiHelpers.Show_toast("Requested API key OK!",1800)
			
			oc.OctoIp = txtPrinterIP.Text
			oc.OctoKey = txtOctoKey.Text
			oc.OctoPort = txtPrinterPort.text
			
			'--- WS check
			'Dim SocketOK As Boolean = False
			Dim ws As OctoWebSocket
			ws.Initialize
			Wait For (ws.ProviderInstall) Complete (b As Boolean) '--- SSL / Android 4.x crap / cleanup
			Wait For (ws.Connect) Complete (msg As String) '--- connect to socket
			If msg = "" Then
				'--- if error we never get here, this needs a refatctor but as this will only happen 1 in a million times...
				'Dim mb As dlgMsgBox : mb.Initialize(mainObj.Root,"Problem",320dip, 160dip,False)
				'Wait For (mb.Show("Web Socket Connection failure.", gblConst.MB_ICON_WARNING,"","","OK")) Complete (res As Int)
				Log("------------- Socket FAILED ------")
			Else
				'mPrefDlg.Dialog.GetButton(xui.DialogResponse_Positive).Visible = True
				'guiHelpers.Show_toast2("Connection OK!",2000)
				Log("------------- Socket OK ------")
			End If
			ws.wSocket.Close
			
		Else
			Dim w As Float = IIf(guiHelpers.gIsLandScape,500dip,94%x)
			Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Problem",w, 220dip,False)
			Wait For (mb.Show(result.As(String),gblConst.MB_ICON_WARNING,"","","OK")) Complete (res As Int)
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
			txtPrinterPort.Text = "80"
			'msg = "Missing Port Number" : Exit
		End If

		#if not (klipper)
		If txtOctoKey.Text.Length = 0 Then
			msg = "Missing Octoprint Key" : Exit
		End If
		#End If
		
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
	Dim m As Map = File.ReadMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE)
	If m.IsInitialized = False Then Return
	
	
	txtOctoKey.Text = m.Get( gblConst.PRINTER_OCTO_KEY)
	txtPrinterDesc.Text = m.Get( gblConst.PRINTER_DESC)
	txtPrinterIP.Text = m.Get( gblConst.PRINTER_IP)
	txtPrinterPort.Text = m.Get( gblConst.PRINTER_PORT)

End Sub
