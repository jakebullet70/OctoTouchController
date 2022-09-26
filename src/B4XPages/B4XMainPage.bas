B4A=true
Group=B4XPAGES
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	Private Const mModule As String = "B4XMainPage" 'ignore
	Public Root As B4XView
	Private xui As XUI
	Private oMasterController As MasterController
	Private toast As BCToast

	'--- panel to cover screen for power ctrl
	Public pnlScreenOff As B4XView
	
	'--- splash screen crap
	Private ivSpash As ImageView, pnlSplash As Panel
	
	'--- master base panel
	Private pnlMaster As B4XView 
	
	'--- header
	Private pnlHeader As B4XView, lblStatus As Label,  lblTemp As Label
	Private btnPower, btnPageAction As B4XView
	
	'--- page-panel classes
	Public oPageCurrent As Object = Null
	Public oPageMenu As pageMenu, oPageFiles As pageFiles
	Public oPagePrinting As pagePrinting, oPageMovement As pageMovement
	Private pnlMovement, pnlPrinting, pnlFiles, pnlMenu As B4XView
	
	'--- only show the dialog once (should not be needed)
	Private mConnectionErrDlgShowingFLAG As Boolean = False
	
	Private PromptExitTwice As Boolean = False

	'--- checking for app update - busy screen
	Private pnlUpdate,lblUpdate As B4XView, ivUpdate As ImageView
	
End Sub

'======================================================================================
'
' --- main page (displays panels, has public utility classes)
' --- just shows panel-classes
'
'======================================================================================

Public Sub getMasterCtrlr() As MasterController
	'--- master Octo controller / methods
	Return oMasterController
End Sub

Public Sub Initialize
	
	config.Init
	logMe.Init(xui.DefaultFolder,"_OCTOTC_","log")
	clrTheme.Init(config.ColorTheme)
	
	Starter.InitLogCleanup
	
	'  debug - remove for release
	fileHelpers.DeleteFiles(xui.DefaultFolder,"*.log")
	'  debug - remove for release
	
	
	fileHelpers.DeleteFiles(xui.DefaultFolder,"sad_*.png") '--- delete all thumbnails
	logMe.LogIt("App Startup...","")
	
	powerHelpers.Init(config.AndroidTakeOverSleepFLAG)
	CfgAndroidPowerOptions
	
End Sub

#Region "PAGE EVENTS"
Private Sub B4XPage_Created (Root1 As B4XView)

	Root = Root1
	Root.SetLayoutAnimated(0,0,0,Root.Width,Root.Height)
	Root.LoadLayout("MainPage")
	
	toast.Initialize(Root)
	toast.pnl.Color = clrTheme.txtNormal
	toast.DefaultTextColor = clrTheme.Background
	toast.MaxHeight = 120dip
	
	'--- splash screen
	If Starter.FirstRun Then
		pnlMaster.Visible = False
		pnlSplash.Visible = True
	Else
		Starter.FirstRun = False
	End If

	Build_GUI
	TryOctoConnection
	
End Sub

Private Sub B4XPage_CloseRequest As ResumableSub
	
	'--- catch the android BACK button
	If oPageCurrent <> oPageMenu Then
		Switch_Pages(gblConst.PAGE_MENU)		
		Return False '--- cancel close request
	End If
	
	If PromptExitTwice = False Then
		Show_toast(Chr(0xE879) & " Tap 'back' button again to exit",2200)
		Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"Prompt_Exit_Reset",2200)
		PromptExitTwice = True
		Return False
	End If
	
	powerHelpers.ReleaseLocks
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)
	
	'--- Needed to turn on 'UserClosed' var in Main.Activity_Pause
	'--- as 'back button' should turn it on but is not
	B4XPages.GetNativeParent(Me).Finish 
	
	Return True '--- exit app
	
End Sub

Private Sub B4XPage_Appear
	'Log("B4XPage_Appear")
End Sub

Private Sub B4APage_Disappear
	Log("B4APage_Disappear")
End Sub

Private Sub B4XPage_Foreground
	CallSub(oPageCurrent,"Set_Focus")
	If oc.isConnected Then CallSub2(Main,"TurnOnOff_MainTmr",True)
	'Log("B4XPage_Foreground - calling Set_Focus, main tmr on")
End Sub

Private Sub B4XPage_Background
	CallSub2(Main,"TurnOnOff_MainTmr",False)
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	CallSub2(Main,"TurnOnOff_ScreenTmr",False)
	Log("B4XPage_Background - timers off")
End Sub

#end region

Private Sub Build_GUI
	
	pnlMaster.Color = clrTheme.Background
	pnlHeader.Color	 = clrTheme.BackgroundHeader
	
	'--- hide all page views
	guiHelpers.HidePageParentObjs(Array As B4XView(pnlMenu,pnlFiles,pnlMovement))
	
	'guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
	guiHelpers.SetTextColor(Array As B4XView(lblStatus,lblTemp,btnPower,btnPageAction))
	
	btnPower.Visible = config.ShowPwrCtrlFLAG
	
	Switch_Pages(gblConst.PAGE_MENU)
	
End Sub


Public Sub HideSplash_StartUp
	pnlSplash.Visible = False
	pnlMaster.Visible = True
End Sub

Private Sub TryOctoConnection
	
	If oMasterController.IsInitialized = False Then 
		oMasterController.Initialize
	End If
	If fnc.ReadConnectionFile(oMasterController.CN) = False Then
		Dim o9 As dlgOctoSetup 
		o9.Initialize(Me,"Octoprint Connection","PrinterSetup_Closed")
		o9.Show(True)
	Else
		If oc.IsOctoConnectionVarsValid Then
			oMasterController.SetCallbackTargets(Me,"Update_Printer_Temps","Update_Printer_Status","Update_Printer_Btns")
			oMasterController.Start
		End If
	End If

End Sub

#Region "OCTO_EVENTS"
'--- events called from the masterController

Public Sub Update_Printer_Temps

	'---  update the main header
	lblTemp.Text = oc.FormatedTemps
	
	'--- see if the current page has the proper event
	If SubExists(oPageCurrent,"Update_Printer_Temps") Then
		CallSub(oPageCurrent,"Update_Printer_Temps")
	End If
	
End Sub

Public Sub Update_Printer_Status
	
	'guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	If oc.isConnected Then
		lblStatus.Text = oc.FormatedStatus
	Else
		lblStatus.Text = "No Connection"
	End If
	
	'--- see if the current page has the proper event
	If SubExists(oPageCurrent,"Update_Printer_Stats") Then
		CallSub(oPageCurrent,"Update_Printer_Stats")
	End If
	
End Sub


Public Sub Update_Printer_Btns
	
	'--- see if the current page has the proper event
	If SubExists(oPageCurrent,"Update_Printer_Btns") Then
		CallSub(oPageCurrent,"Update_Printer_Btns")
	End If
		
End Sub
#end region

#region "MENUS"
Private Sub btnPageAction_Click
	If oPageCurrent = oPageMenu Then
		PopupMainOptionMenu
	Else
		Switch_Pages(gblConst.PAGE_MENU) '--- back key, go to main menu
	End If
End Sub


Public Sub Switch_Pages(action As String)
	
	'--- called from menu page class and back button
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	'--- fire the lost focus event
	If oPageCurrent <> Null Then
		CallSub(oPageCurrent,"Lost_Focus")
	End If
	
	'--- set defaults
	btnPageAction.Text = Chr(0xE5C4)  '--- back button
	
	Select Case action
		Case gblConst.PAGE_MENU
			If oPageMenu.IsInitialized = False Then oPageMenu.Initialize(pnlMenu,"Switch_Pages")
			oPageCurrent = oPageMenu
			btnPageAction.Text = Chr(0xE5D2)
			
		Case gblConst.PAGE_FILES
			If oPageFiles.IsInitialized = False Then oPageFiles.Initialize(pnlFiles,"")
			oPageCurrent = oPageFiles
			
		Case gblConst.PAGE_PRINTING
			If oPagePrinting.IsInitialized = False Then oPagePrinting.Initialize(pnlPrinting,"")
			oPageCurrent = oPagePrinting
			
		Case gblConst.PAGE_MOVEMENT
			If oPageMovement.IsInitialized = False Then oPageMovement.Initialize(pnlMovement,"")
			oPageCurrent = oPageMovement
			
			
	End Select
	
	'--- set focus to page object
	CallSub(oPageCurrent,"Set_Focus")
	
End Sub
#end region

Public Sub Show_toast(msg As String, ms As Int)
	toast.DurationMs = ms
	toast.Show("[TextSize=24][b]" & msg & "[/b][/TextSize]")
End Sub

#Region "POPUP_MAIN_SETUP_MENU"
Private Sub PopupMainOptionMenu
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	Dim popUpMemuItems As Map = _
		CreateMap("General Settings":"gn","Power Settings":"pw","Octoprint Connection":"oc", _
				  "Plugins Menu":"plg","Read Err File":"rt","About":"ab")

		
	If oc.isPrinting Or oc.IsPaused2 Then
		Show_toast("Cannot Change OctoPrint Settings While Printing",2500)
		popUpMemuItems.Remove("Octoprint Connection")
	End If
	Sleep(20)
	
	Dim o1 As dlgListbox
	o1.Initialize(Me,"Options Menu",Me,"OptionsMenu_Event")
	o1.IsMenu = True
	o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,310dip,260dip),300dip,popUpMemuItems)
	
End Sub

Private Sub OptionsMenu_Event(value As String, tag As Object)
	
	'--- callback for options Menu
	If value.Length = 0 Then Return
	
	Select Case value
		
		Case "ab" '--- about
			Dim mb As dlgMsgBox : mb.Initialize(Root,"About",560dip, 200dip,False)
			Wait For (mb.Show( _
				 guiHelpers.GetAboutText() ,"splash.png","OK","","")) Complete (res As Int)
			
		Case "gn"  '--- general settings
			Dim o3 As dlgGeneralOptions
			o3.Initialize(Me)
			o3.Show
			
		Case "oc"  '--- octo setup
			Dim o9 As dlgOctoSetup
			o9.Initialize(Me,"Octoprint Connection","PrinterSetup_Closed")
			o9.Show(False)
		
		Case "pw"  '--- android power setup
			Dim o1 As dlgPowerOptions : o1.Initialize(Me)
			o1.Show
			
		Case "plg"  '--- plugins menu
			PopupPluginOptionMenu
			
		Case "led"  '--- zled setup
			Dim oA As dlgPsuSetup
			oA.Initialize(Me,"PSU Config")
			oA.Show
			
		Case "rt" '---read text file
			Dim vt As dlgViewText
			vt.Initialize(Me,"Read Text")
			Dim f As String = Gettxtfile
			If f <> "" Then 
				vt.Show(f)
			Else
				guiHelpers.Show_toast("no error file found",6000)
			End If
			
	End Select
	
	
End Sub

Private Sub Gettxtfile() As String

	Dim o1 As WildCardFilesList : o1.Initialize
	Dim lstFolder As List = o1.GetFiles(xui.DefaultFolder,"*.log",False,False)
	If lstFolder.Size > 0 Then
		Return lstFolder.Get(0)
	End If
	Return ""
	
End Sub

'--- called from dlgOctoSetup on exit
Public Sub PrinterSetup_Closed

	If oc.IsOctoConnectionVarsValid Then
		guiHelpers.Show_toast("Trying to connect...",3000)		
		TryOctoConnection
	End If
	Sleep(100)
	'guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
End Sub

'--- called from PSU setup
Public Sub  ShowNoShow_PowerBtn
	btnPower.Visible = config.ShowPwrCtrlFLAG
End Sub

'--------------------------------------

'--- options plugin sub menu
Private Sub PopupPluginOptionMenu
	
	Dim popUpMemuItems As Map = CreateMap("PSU Control":"psu","ZLED Setup":"led","ws281x Setup":"ws2")
		
	Dim o1 As dlgListbox
	o1.Initialize(Me,"Plugins Menu",Me,"PluginsMenu_Event")
	o1.IsMenu = True
	o1.Show(260dip,300dip,popUpMemuItems)
	
End Sub

'--- callback for plugins options Menu
Private Sub PluginsMenu_Event(value As String, tag As Object)
	
	If value.Length = 0 Then PopupMainOptionMenu
	
	Select Case value
			
		Case "psu"  '--- sonoff / PSU control setup
			Dim oA As dlgPsuSetup
			oA.Initialize(Me,"PSU Config")
			oA.Show
			
		Case "led" '--- ZLED
			Dim oB As dlgZLEDSetup
			oB.Initialize(Me,"ZLED Config",gblConst.ZLED_OPTIONS_FILE)
			oB.Show
			
		Case "ws2" '--- ws281x
			Dim o1 As dlgZLEDSetup
			o1.Initialize(Me,"ws281x Config",gblConst.WS281_OPTIONS_FILE)
			o1.Show
		
	End Select
	
	
End Sub



#end region

Public Sub CallSetupErrorConnecting(connectedButError As Boolean)

	If mConnectionErrDlgShowingFLAG Then Return
	mConnectionErrDlgShowingFLAG = True
	Log("starting error setup cfg")

	'--- turn timers off
	CallSub2(Main,"TurnOnOff_MainTmr",False)
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	
	'--- back to the main menu
	If oPageCurrent <> oPageMenu Then Switch_Pages(gblConst.PAGE_MENU)
	
	Dim Msg As String = guiHelpers.GetConnectionText(connectedButError)
	
	'--- if printer / sonoff power is configed, show power btn	
	Dim PowerCtrlAvail As String = ""
	If Starter.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean) = True Then
		PowerCtrlAvail = "POWER ON"
	End If

	Dim Const JUSTIFY_BUTTON_2_LEFT As Boolean = True
	Dim ErrorDlg As dlgMsgBox
	ErrorDlg.Initialize(Root,"Connetion Problem",560dip, 180dip,JUSTIFY_BUTTON_2_LEFT)
	Wait For (ErrorDlg.Show(Msg,gblConst.MB_ICON_WARNING, _
					"RETRY",PowerCtrlAvail,"SETUP")) Complete (res As Int)
	
	Select Case res
		Case xui.DialogResponse_Positive '--- retry
			Show_toast("Retrying connection...",1300)
			oMasterController.Start
			
		Case xui.DialogResponse_Cancel	 '--- this runs printer setup
			OptionsMenu_Event("oc","oc")
			
		Case xui.DialogResponse_Negative '--- Power on 
			Dim o As dlgPsuCtrl : o.Initialize(Null)
			Wait For (o.SendCmd("on")) Complete(s As String)
			Sleep(3000)
			oMasterController.Start
			
	End Select
	
	CfgAndroidPowerOptions
	mConnectionErrDlgShowingFLAG = False
	Log("exiting error setup cfg")

End Sub

Private Sub CfgAndroidPowerOptions
	
	If config.AndroidTakeOverSleepFLAG = False Then 
		powerHelpers.ScreenON(False) '--- power options not configured
		Return 
	End If
		
	fnc.ProcessPowerFlags
	
End Sub

Private Sub pnlScreenOff_Click
	
	'--- eat the click, hide the panel
	If config.logPOWER_EVENTS Then Log("screen off panel click - show screen")
	pnlScreenOff.Visible = False	
	pnlScreenOff.SendToBack
	powerHelpers.SetScreenBrightness2
	fnc.ProcessPowerFlags
	
End Sub

Private Sub Prompt_Exit_Reset
	'--- user has to tap 'back' button twice to exit in 2 seconds
	'--- this resets the var if they do not do it in 2 seconds
	PromptExitTwice = False
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
End Sub

Private Sub lblStatus_Click
	'--- if not connected then popup the connection screen
	If lblStatus.Text.Contains("No C") Or oc.isConnected = False Then
		CallSetupErrorConnecting(False)
	End If
End Sub

Private Sub btnPower_Click
	'--- printer on/off
	Dim o1 As dlgPsuCtrl
	o1.Initialize(Me)
	o1.Show
End Sub


