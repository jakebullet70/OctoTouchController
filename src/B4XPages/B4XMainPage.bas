﻿B4A=true
Group=B4XPAGES
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region


'============ SEARCH FOR -------- 'TODO V2
'============ SEARCH FOR -------- 'TODO V2
'============ SEARCH FOR -------- 'TODO V2
'============ SEARCH FOR -------- 'TODO V2
'============ SEARCH FOR -------- 'TODO V2


Sub Class_Globals
	Private Const mModule As String = "B4XMainPage" 'ignore
	Public Root As B4XView
	Private xui As XUI
	Public oMasterController As MasterController
	Private toast As BCToast

	'--- panel to cover screen for power ctrl
	Public pnlScreenOff As Panel
	
	'--- splash screen crap
	Private ivSpash As ImageView, pnlSplash As Panel,lblSplash As Label
	
	'--- master base panel
	Private pnlMaster As B4XView 
	
	'--- header
	Private pnlHeader As B4XView
	Private btnSliderMenu, btnPageAction As Button
	Public lblStatus As Label
	
	'--- page-panel classes
	Public oPageCurrent As Object = Null
	Public oPageMenu As pageMenu, oPageFiles As pageFiles
	Public oPagePrinting As pagePrinting, oPageMovement As pageMovement
	Private pnlMovement, pnlPrinting, pnlFiles, pnlMenu As B4XView
	
	'--- only show the dialog once (should not be needed)
	Private mConnectionErrDlgShowingFLAG As Boolean = False
	
	Public pPrinterCfgDlgShowingFLAG As Boolean = False
	Private PromptExitTwice As Boolean = False
	Private mToastTxtSize As Int
	
	Private mapMasterPreHeaterMenu As Map
	
	'--- side menu
	Public SideMenu As sadB4XDrawerAdvancedHelper
	Private Drawer As sadB4XDrawerAdvanced
	Private btnSTOP,btnFRESTART,btnRESTART As Button
	Private pnlBtnsDrawer,pnlMainDrawer As B4XView
	Private pnlLineBreakDrawer As Panel
	Private clvDrawer As CustomListView
	
	Public mPrefDlg1 As sadPreferencesDialog
	Public mPrefDlg2 As sadPreferencesDialog
	
	Public pnlWizards As Panel
End Sub

'======================================================================================
'
' --- main page (displays panels, has public utility classes)
'
'======================================================================================


Public Sub Initialize
	
	config.Init
	logMe.Init(xui.DefaultFolder,"_OCTOTC_","log")
	clrTheme.Init(Main.kvs.Get(gblConst.SELECTED_CLR_THEME).As(String).ToLowerCase)
	
	CallSub(Main,"InitLog_Cleanup")
	
	'  debug - remove for release
	'fileHelpers.DeleteFiles(xui.DefaultFolder,"*.log")
	'  debug - remove for release
	
	
	fileHelpers.DeleteFiles(xui.DefaultFolder,"sad_*.png") '--- delete all thumbnails
	logMe.LogIt("App Startup...","")
	
	powerHelpers.Init(config.AndroidTakeOverSleepFLAG)
	CfgAndroidPowerOptions
	
	'--- set toast text size
	mToastTxtSize = IIf(guiHelpers.gScreenSizeAprox > 5,24,22) 
	
	Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Check4_Update",8000)
	
End Sub


#Region "PAGE EVENTS"
Private Sub B4XPage_Created (Root1 As B4XView)

	Root = Root1
	Root.SetLayoutAnimated(0,0,0,Root.Width,Root.Height)
	
	'--- sliding side menu ---------------------------
	SideMenu.Initialize(Drawer)
	Drawer.Initialize(SideMenu, "mnuPanel", Root, 260dip)
	Drawer.CenterPanel.LoadLayout("MainPage2")
	Drawer.RightPanel.LoadLayout("viewSlidingWindow")
	Drawer.RightPanelEnabled = True
	Drawer.LeftPanelEnabled = False
	
	toast.Initialize(Root)
	toast.pnl.Color = clrTheme.txtNormal
	toast.DefaultTextColor = clrTheme.Background
	toast.MaxHeight = 120dip
	
	'--- splash screen
'	If Starter.FirstRun Then
		LoadSplashPic
		pnlMaster.Visible = False
		pnlSplash.Visible = True
'	Else
'		Starter.FirstRun = False
'	End If

	BuildGUI
	
	TryPrinterConnection
	
End Sub

Private Sub B4XPage_CloseRequest As ResumableSub
	
	If Drawer.RightOpen Then
		Drawer.RightOpen = False
		Return False
	End If
	
	'--- catch the android BACK button
	If oPageCurrent <> oPageMenu Then
		Switch_Pages(gblConst.PAGE_MENU)		
		Return False '--- cancel close request
	End If
	
	If PromptExitTwice = False Then
		Show_toast("Tap again to exit",2200)
		Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Prompt_Exit_Reset",2200)
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
	Log("B4XPage_Foreground - calling Set_Focus, main tmr on")
End Sub

Private Sub B4XPage_Background
	CallSub2(Main,"TurnOnOff_MainTmr",False)
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	CallSub2(Main,"TurnOnOff_ScreenTmr",False)
	Log("B4XPage_Background - timers off")
End Sub

#end region

Private Sub BuildGUI
	
	pnlMaster.Color  = clrTheme.Background
	pnlHeader.Color = clrTheme.BackgroundHeader

	'--- hide all page views
	guiHelpers.HidePageParentObjs(Array As B4XView(pnlMenu,pnlFiles,pnlMovement,pnlWizards))
	guiHelpers.SetTextColor(Array As B4XView(lblStatus,btnSliderMenu,btnPageAction))
	
	
'	If guiHelpers.gIsLandScape = False Then
'		Select Case True
'			Case guiHelpers.gScreenSizeAprox > 6.5 And guiHelpers.gScreenSizeAprox < 9.5
'				lblStatus.TextSize = lblStatus.TextSize + 4
'				'lblTemp.TextSize   = lblTemp.TextSize + 4
'			Case guiHelpers.gScreenSizeAprox > 9.5
'				lblStatus.TextSize = lblStatus.TextSize + 2
'				'lblTemp.TextSize   = lblTemp.TextSize + 4
'		End Select
'	End If
	

	guiHelpers.SkinButton_Pugin(Array As Button(btnSliderMenu, btnPageAction))
	Dim bs As Float = 35
	If guiHelpers.gIsLandScape Then bs = 24
	btnSliderMenu.TextSize = bs
	btnPageAction.TextSize = bs
	
	pnlMainDrawer.Color = clrTheme.Background2
	SideMenu.SkinMe(Array As Button(btnSTOP,btnFRESTART,btnRESTART),pnlMainDrawer,pnlBtnsDrawer)
	pnlLineBreakDrawer.Color = clrTheme.txtNormal
	btnFRESTART.Visible = False : 	btnRESTART.Visible = False : btnSTOP.Visible = True '--- default these 
	Build_RightSideMenu
		
	Switch_Pages(gblConst.PAGE_MENU)
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
End Sub

Private Sub LoadSplashPic
	
	#if klipper
	Dim fname As String = "splashklipper.png"
	lblSplash.Text = "Powered by Moonraker"
	If guiHelpers.gIsLandScape = False Then lblSplash.TextSize = lblSplash.TextSize - 7
	#else
	Dim fname As String = "splash.png"
	#End If
	ivSpash.Bitmap = LoadBitmapResize(File.DirAssets, fname, ivSpash.Width, ivSpash.Height,True)
	
End Sub

Public Sub HideSplash_StartUp
	pnlSplash.Visible = False
	pnlMaster.Visible = True
End Sub

Private Sub TryPrinterConnection
	
	If oMasterController.IsInitialized = False Then 
		oMasterController.Initialize
	End If
	If fnc.ReadConnectionFile(oMasterController.CN) = False Then
		#if klipper
		Dim o9 As dlgPrinterSetup : o9.Initialize(Me)
		#else
		Dim o9 As dlgOctoSetup : o9.Initialize("Printer Connection","PrinterSetup_Closed")
		#End If
		o9.Show(True)
	Else
		If oc.IsConnectionValid Then
			oMasterController.SetCallbackTargets(Me,"Update_Printer_Temps","Update_Printer_Status","Update_Printer_Btns")
			oMasterController.Start
		End If
	End If

End Sub

#Region "PRINTER_EVENTS"
'--- events called from the masterController

Public Sub Update_Printer_Temps

	'--- see if the current page has the proper event
	If SubExists(oPageCurrent,"Update_Printer_Temps") Then
		CallSubDelayed(oPageCurrent,"Update_Printer_Temps")
	End If
	
End Sub

Public Sub Update_Printer_Status
	
	'guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	If oc.isConnected Then
		If guiHelpers.gIsLandScape = False Then lblStatus.TextSize = 32 Else lblStatus.TextSize = 28
		#if klipper
		lblStatus.Text = oc.FormatedStatus.SubString2(0,1).ToUpperCase & oc.FormatedStatus.SubString(1)
		#else
		lblStatus.Text = oc.FormatedStatus
		#End If
		
		
		If oPageCurrent Is pageMovement  Or oPageCurrent Is pageFiles Then
			If guiHelpers.gIsLandScape = False Then lblStatus.TextSize = 18 Else lblStatus.TextSize = 22
			lblStatus.Text = lblStatus.Text & "  (" & oc.FormatedTemps.Replace(CRLF,"   ").Replace("C","") & ")"
'			If guiHelpers.gIsLandScape  Then
'				lblStatus.Text = lblStatus.Text & "  (" & oc.FormatedTemps.Replace(CRLF,"   ").Replace("C","") & ")"
'			Else
'				lblStatus.Text = lblStatus.Text & "  --  " & oc.FormatedTemps.Replace("C","") 
'			End If
		End If
			
	Else
		lblStatus.TextSize = 30
		lblStatus.Text = gblConst.NOT_CONNECTED
	End If
	
	'--- see if the current page has the proper event
	If SubExists(oPageCurrent,"Update_Printer_Stats") Then
		CallSub(oPageCurrent,"Update_Printer_Stats")
	End If

	
	#if klipper
	If SideMenu.IsOpen Then  CallSubDelayed(SideMenu,"Display_Btns")
	#end if
	
	'lblStatus.TextSize = oldTxtSize
	
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
	toast.Show($"[TextSize=${mToastTxtSize}][b][FontAwesome=0xF05A/]  ${msg}[/b][/TextSize]"$)
End Sub

#Region "POPUP_MAIN_SETUP_MENU"
Private Sub PopupMainOptionMenu
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	Dim popUpMemuItems As Map 

	Dim gui As guiMsgs : gui.Initialize		
	If oc.isPrinting Or oc.IsPaused2 Then
		'--- do not know why i did this, does not seem to matter
		'--- if you change when printing
		Show_toast("Cannot Change Printer Connection Settings While Printing",2500)
		popUpMemuItems = gui.BuildOptionsMenu(True)
	Else
		popUpMemuItems = gui.BuildOptionsMenu(False)
	End If
	
	Dim o1 As dlgListbox
	o1.Initialize("Options Menu",Me,"OptionsMenu_Event")
	o1.IsMenu = True
	If guiHelpers.gIsLandScape Then '- TODO needs refactor for sizes
		o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,320dip,280dip),340dip,popUpMemuItems)
	Else
		o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,436dip,340dip),354dip,popUpMemuItems)
	End If
	
End Sub

Private Sub OptionsMenu_Event(value As String, tag As Object)
	
	'--- callback for options Menu
	If value = Null Or value.Length = 0 Then Return
	
	Select Case value
		Case "thm1" '--- themes
			Dim oo9 As dlgThemeSelect : oo9.Initialize
			oo9.Show(pnlWizards)
			
		Case "ab" '--- about
			Dim o2 As dlgAbout : o2.Initialize
			o2.Show
			
		Case "gn"  '--- general settings
			Dim o3 As dlgGeneralOptions : o3.Initialize
			o3.Show
			
		Case "oc"  '--- octo / klipper setup
			#if klipper
			Dim o9 As dlgPrinterSetup
			o9.Initialize(Me)
			o9.Show(False)
			#else
			Dim o9 As dlgOctoSetup
			o9.Initialize("Printer Connection","PrinterSetup_Closed")
			o9.Show(False)
			#End If
			
		Case "pw"  '--- android power setup
			Dim o1 As dlgAndroidPowerOptions : o1.Initialize
			o1.Show
			
		Case "plg"  '--- plugins menu
			PopupPluginOptionMenu
			
		Case "fn"  '--- functions menu
			PopupFunctionOptionsMnu
			
		Case "rt" '---read text file
			Dim vt As dlgViewText : vt.Initialize("Read Text")
			Dim f As String = Gettxtfile
			If f <> "" Then 
				vt.Show(f)
			Else
				Show_toast("no log file found",6000)
			End If
			
		Case "cup" '--- check for update
			Dim up As dlgAppUpdate : up.Initialize(B4XPages.MainPage.Root)
			up.Show
			
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

	If oc.IsConnectionValid Then
		Show_toast("Trying to connect...",3000)		
		TryPrinterConnection
	End If
	'Sleep(100)
	'guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
End Sub

''--- called from PSU setup
 'TODO V2
'Public Sub  ShowNoShow_PowerBtn
'	btnPower.Visible = config.ShowPwrCtrlFLAG
'End Sub

'--- options plugin sub menu
Private Sub PopupFunctionOptionsMnu
	
	Dim cs As CSBuilder 
	Dim gui As guiMsgs : gui.Initialize
	Dim po As Map = gui.BuildFunctionSetupMenu
			
	Dim title As Object = cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
										Typeface(Typeface.DEFAULT).Append("  Internal Functions Menu").PopAll
	
	Dim o1 As dlgListbox
	o1.Initialize(title,Me,"FncMenu_Event")
	o1.IsMenu = True
	o1.Show(260dip,300dip,po)
	
End Sub

'--- callback for plugins options Menu
Private Sub FncMenu_Event(value As String, tag As Object)
	
	If value.Length = 0 Then PopupMainOptionMenu
	
	Select Case value
			
		Case "g29"
			Main.kvs.Put("g29", Not (Main.kvs.GetDefault("g29",False)))
			Show_toast("G29 Option Saved",2000)
			
		Case "fl" '--- filament control
			Dim oB As dlgFilamentSetup
			oB.Initialize
			oB.Show
			
		Case "bl" '--- bed level control
			If oc.PrinterCustomBoundingBox = True Then
				Show_toast("Custom bounding box not supported at this time.",4500)
				Return
			End If
			Dim o1 As dlgBedLevelSetup
			o1.Initialize
			o1.Show
			
	End Select
	
End Sub


'--------------------------------------

'--- options plugin sub menu
Private Sub PopupPluginOptionMenu
	
	Dim Const gc As String = "Generic HTTP Control"
	#if klipper
	Dim popUpMemuItems As Map = CreateMap("Power Supply HTTP Control":"psu", _
																	gc & " 1":"1",gc & " 2":"2",gc & " 3":"3",gc & " 4":"4")
	Dim title As Object = "  External Control Menu"
	#else
	Dim popUpMemuItems As Map = CreateMap("PSU Control":"psu","ZLED Setup":"led","ws281x Setup":"ws2", _
																			gc & " 1":"1",gc & " 2":"2",gc & " 3":"3",gc & " 4":"4")
	Dim title As Object = "  Plugins Menu"
	#End If
	
	
	Dim cs As CSBuilder : cs.Initialize
	Dim title As Object = cs.Typeface(Typeface.MATERIALICONS).VerticalAlign(4dip).Append(Chr(0xE8C1)). _
	        	 					   Typeface(Typeface.DEFAULT).Append(title).PopAll
	Dim o1 As dlgListbox
	o1.Initialize(title,Me,"PluginsMenu_Event")
	o1.IsMenu = True
	o1.Show(260dip,300dip,popUpMemuItems)
	
End Sub

'--- callback for plugins options Menu
Private Sub PluginsMenu_Event(value As String, tag As Object)
	
	If value.Length = 0 Then PopupMainOptionMenu
	
	Select Case value
			
		Case "psu"  '--- sonoff / PSU control setup		
			#if klipper
			Dim oA1 As dlgIpOnOffSetup
			oA1.Initialize(mPrefDlg1,Me,"ExtCtrl_BtnEdit")
			oA1.Show("Printer Power Config",gblConst.PSU_KLIPPER_SETUP_FILE)
			#else
			Dim oA As dlgOctoPsuSetup
			oA.Initialize("PSU Config")
			oA.Show
			#End If
			
		Case "1","2","3","4"
			Dim oA1 As dlgIpOnOffSetup
			oA1.Initialize(mPrefDlg1,Me,"ExtCtrl_BtnEdit")
			oA1.Show("HTTP Control Config - " & value,value & gblConst.HTTP_ONOFF_SETUP_FILE)
				
		#if not (klipper)	
		Case "led" '--- ZLED
			Dim oB As dlgZLEDSetup
			oB.Initialize("ZLED Config",gblConst.ZLED_OPTIONS_FILE)
			oB.Show
			
		Case "ws2" '--- ws281x
			Dim o1 As dlgZLEDSetup
			o1.Initialize("ws281x Config",gblConst.WS281_OPTIONS_FILE)
			o1.Show
		#end if
		
	End Select
		
End Sub

#end region

Public Sub CallSetupErrorConnecting(connectedButError As Boolean)

	If mConnectionErrDlgShowingFLAG Or pPrinterCfgDlgShowingFLAG Then Return
	mConnectionErrDlgShowingFLAG = True
	Log("starting error setup cfg")

	'--- turn timers off
	CallSub2(Main,"TurnOnOff_MainTmr",False)
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	
	'--- back to the main menu
	If oPageCurrent <> oPageMenu Then Switch_Pages(gblConst.PAGE_MENU)
	
	If pnlScreenOff.Visible = True Then
		Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"ScreenOff_2Front",600)
	End If
	
	'--- if sonoff power is configed, show power btn - remember, if no connection to octoprint
	'--- so cannot use any octoprint installed plugin
	Dim PowerCtrlAvail As String = ""
	If Main.kvs.GetDefault(gblConst.PWR_SONOFF_PLUGIN,False).As(Boolean) = True Then
		PowerCtrlAvail = "POWER ON"
	End If

	Dim Const JUSTIFY_BUTTON_2_LEFT As Boolean = True
	Dim ErrorDlg As dlgMsgBox
	Dim h,w As Float
	If guiHelpers.gIsLandScape Then
		h = 180dip : w = 560dip
	Else
		h = 310dip : w = 88%x
	End If
	ErrorDlg.Initialize(Root,"Connetion Problem",w, h,JUSTIFY_BUTTON_2_LEFT)
	Dim gui As guiMsgs : gui.Initialize
	Wait For (ErrorDlg.Show(gui.GetConnectionText(connectedButError),gblConst.MB_ICON_WARNING, _
					"RETRY",PowerCtrlAvail,"SETUP")) Complete (res As Int)
	
	Select Case res
		Case xui.DialogResponse_Positive '--- retry
			Show_toast("Retrying connection...",1300)
			oMasterController.Start
			
		Case xui.DialogResponse_Cancel	 '--- this runs printer setup
			OptionsMenu_Event("oc","oc")
			
		Case xui.DialogResponse_Negative '--- Power on 
			Dim o As dlgOctoPsuCtrl : o.Initialize(Null)
			Wait For (o.SendCmd("on")) Complete(s As String)
			Sleep(3000)
			oMasterController.Start
			
	End Select
	
	CfgAndroidPowerOptions
	mConnectionErrDlgShowingFLAG = False
	Log("exiting error setup cfg")

End Sub

Private Sub ScreenOff_2Front
	pnlScreenOff.BringToFront
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
	If lblStatus.Text.Contains("No C") Or oc.isConnected = False  Then
		CallSetupErrorConnecting(False)
	End If
End Sub

Private Sub btnPower_Click
	'--- printer on/off
	Dim o1 As dlgOctoPsuCtrl
	o1.Initialize(Me)
	o1.Show
End Sub

Public Sub TempChange_Presets(selectedMsg As String, tag As Object)
	
	'--- callback for btnPresetTemp_Click
	'--- called from pageMenu and pagePrinting via Sub ShowPreHeatMenu_All
	
	If selectedMsg.Length = 0 Then Return
	
	If selectedMsg = "alloff" Then
		
		#if klipper
		oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M140 S0"))
		oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M104 S0"))
		#else
		oMasterController.AllHeaters_Off
		#End If
		
		Show_toast("Tool / Bed Off",1200)
		Return
		
	End If
	
	'Dim tagme As String = tag.As(String)
	Dim msg, getTemp As String
	Dim startNDX, endNDX As Int
	
	Select Case True
		
		Case selectedMsg = "bedoff"
			#if klipper
			oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M140 S0"))
			#else
			oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",0))
			#End If
			msg = "Bed Off"

		Case selectedMsg = "tooloff"
			#if klipper
			oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M104 S0"))
			#else
			oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
			#End If
			msg = "Tool Off"
		
		Case selectedMsg = "evb"
			Dim oo1 As HeaterRoutines : oo1.Initialize
			oo1.ChangeTempBed
			
		Case selectedMsg = "evt"
			Dim oo2 As HeaterRoutines : oo2.Initialize
			oo2.ChangeTempTool
			
		Case selectedMsg.Contains("Tool") And Not (selectedMsg.Contains("Bed"))
			'--- Example, Set PLA (Tool: 60øC )
			startNDX = selectedMsg.IndexOf(": ")
			endNDX   = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			#if klipper
			oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M104 S" & getTemp))
			#else
			oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
			#End If
			msg = selectedMsg.Replace("Set","Setting")
			
		Case selectedMsg.Contains("Bed") And Not (selectedMsg.Contains("Tool"))
			'--- Example, PLA (Bed: 60øC )
			startNDX = selectedMsg.IndexOf(": ")
			endNDX   = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			#if klipper
			oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M140 S" & getTemp))
			#else
			oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
			#End If
			msg = selectedMsg.Replace("Set","Setting")
			
		Case Else
			'--- Example, Set ABS (Tool: 240øC  / Bed: 105øC )
			Dim toolMSG As String = Regex.Split("/",selectedMsg)(0)
			Dim bedMSG  As String = Regex.Split("/",selectedMsg)(1)
				
			startNDX = toolMSG.IndexOf(": ")
			endNDX   = toolMSG.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = toolMSG.SubString2(startNDX + 2,endNDX).Trim
			#if klipper
			oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M104 S" & getTemp))
			#else
			oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
			#End If
							
			startNDX = bedMSG.IndexOf(": ")
			endNDX   = bedMSG.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = bedMSG.SubString2(startNDX + 2,endNDX).Trim
			#if klipper
			oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M140 S" & getTemp))
			#else
			oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
			#End If
			msg = selectedMsg.Replace("Set","Setting")
			
	End Select
	
	If msg.Length <> 0 Then Show_toast(msg,3000)
	
End Sub

Public Sub Check4_Update
	
	Dim obj As dlgAppUpdate : obj.Initialize(Null)
	Wait For (obj.CheckIfNewDownloadAvail()) Complete (yes As Boolean)
	If yes Then
		guiHelpers.Show_toast2("App update available", 3600)
	End If
	
End Sub

#Region HEATER_STUFF_MENU

Public Sub ShowPreHeatMenu_All
	ShowPreHeatMenu_All2("Pre-Heat")
End Sub
Public Sub ShowPreHeatMenu_All2(titleTxt As String)
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	If oc.isConnected = False Or oMasterController.mapAllHeatingOptions.IsInitialized = False Then
		guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
		Return
	End If
	Dim ht As dlgListbox
	Dim cs As CSBuilder : cs.Initialize
	Dim title As Object = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF2CA)). _
		Typeface(Typeface.DEFAULT).Append("  " & titleTxt).PopAll
		
	ht.Initialize(title,Me,"TempChange_Presets")
	Dim w As Float = IIf(guiHelpers.gIsLandScape,450dip,guiHelpers.gWidth - 10dip)
	Dim h As Float = IIf(guiHelpers.gIsLandScape,guiHelpers.gHeight * .8,guiHelpers.gHeight * .7)
	
	
	BuildPreHeatMenu
	ht.Show(h,w,mapMasterPreHeaterMenu)
End Sub


Private Sub BuildPreHeatMenu
	
	If mapMasterPreHeaterMenu.IsInitialized Then Return
	
	'--- put together all heating options
	Dim mTmp As Map = objHelpers.ConcatMaps(Array As Map( _
				oMasterController.mapAllHeatingOptions, _
				oMasterController.mapToolHeatingOptions))
				
	Dim m1 As Map : m1.Initialize : m1.Put("Enter Tool Value","evt")
	mapMasterPreHeaterMenu = objHelpers.ConcatMaps(Array As Map(mTmp,m1,oMasterController.mapBedHeatingOptions))
	mapMasterPreHeaterMenu.Put("Enter Bed Value","evb")
				
End Sub
#end region


'#if klipper
'--- side drawer
Public Sub btnSidePnl_Click
	Dim b As Button : b = Sender
	SideMenu.BtnPressed(b)
End Sub
'#end if

Private Sub btnSliderMenu_Click
	'--- righty menu gear icon
	SideMenu.OpenRightMenu 
	CallSubDelayed(SideMenu,"Display_Btns")
End Sub


Private Sub Build_RightSideMenu
	Log("Build_RightSideMenu")
	#if not (klipper )
	'--- hide the klipper crap!
	clvDrawer.GetBase.Top = 0
	pnlBtnsDrawer.Visible = False
	pnlLineBreakDrawer.Visible = False
	#else
	
	#End If
	
	clvDrawer.DefaultTextBackgroundColor = clrTheme.Background
	clvDrawer.PressedColor = clrTheme.BackgroundHeader
	clvDrawer.DefaultTextColor = clrTheme.txtNormal
	
	
	clvDrawer.Clear
	Dim size As Float = IIf(guiHelpers.gIsLandScape,20,22)
	Dim txt As Object 
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	#if klipper
	Dim DataPSU As Map = File.ReadMap(xui.DefaultFolder,gblConst.PSU_KLIPPER_SETUP_FILE)
	#end if
	
	Dim cs As CSBuilder
	If Data.GetDefault("m600",False).As(Boolean) Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Filament Change M600").PopAll,"m600")
	End If
	
	'clvDrawer.AddTextItem(cs.Initialize.Size(12).Alignment("ALIGN_CENTER").Append("------------ SYS CMDS -----------").PopAll,"")
	
	For ii = 1 To 4
		Dim fn As String = ii & gblConst.HTTP_ONOFF_SETUP_FILE
		If File.Exists(xui.DefaultFolder,fn) = True Then
			Dim dataEX As Map  = File.ReadMap(xui.DefaultFolder,fn)
			If dataEX.GetDefault("active",False).As(Boolean) Then
				txt = dataEX.Get("desc")
				If strHelpers.IsNullOrEmpty(txt) Then txt = "HTTP " & ii & "Menu"
				clvDrawer.AddTextItem(cs.Initialize.Size(size).Append(txt).PopAll,ii)
			End If
		End If
	Next
	
	#if klipper
	If DataPSU.GetDefault("active",False).As(Boolean) Then
		txt = DataPSU.Get("desc")
		If strHelpers.IsNullOrEmpty(txt) Then txt = "Printer Power Menu"
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append(txt).PopAll,"pwr")
	End If
	#else
	If config.ShowZLEDCtrlFLAG Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("ZLED Menu").PopAll,"zled")
	End If
	If config.ShowWS281CtrlFLAG Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("WS281 Menu").PopAll,"ws2")
	End If
	If config.ShowPwrCtrlFLAG Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Printer Power Menu").PopAll,"pwr")
	End If
	#End If
	
		
	If Data.GetDefault("syscmds",False).As(Boolean) Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("OS Systems Menu").PopAll,"sys")
	End If
	
	If clvDrawer.Size = 0 Then
		'--- nothing in the menu so add something.
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("About This Program").PopAll,"ab")
	End If
		
End Sub

Private Sub ExtCtrl_BtnEdit(editdata As Map)
	Build_RightSideMenu
End Sub


Private Sub clvDrawer_ItemClick (Index As Int, Value As Object)
	SideMenu.CloseRightMenu
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	Select Case Value.As(String)
		
		Case "ab"
			Dim o2 As dlgAbout : o2.Initialize
			o2.Show
		
		Case "sys"
			#if klipper
			Dim oa As dlgKlipperSysCmds : oa.Initialize(Me) : 	oa.Show
			#Else
			Dim oa As dlgOctoSysCmds : oa.Initialize(oMasterController.CN) : oa.Show
			#end if
		
		Case "pwr"
			#if not (klipper)
			If oc.isConnected = False And Main.kvs.GetDefault(gblConst.PWR_SONOFF_PLUGIN,False).As(Boolean) = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			Dim o1 As dlgOctoPsuCtrl : o1.Initialize(Me)
			o1.Show
			#else
			RunHTTPOnOffMenu(gblConst.PSU_KLIPPER_SETUP_FILE)
			#end if
			
		Case "1","2","3","4"
			RunHTTPOnOffMenu(Value.As(String) & gblConst.HTTP_ONOFF_SETUP_FILE)
		
		#if not (klipper)
		Case "zled" '--- ZLED
			If oc.isConnected = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			Dim o3 As dlgOnOffCtrl
			o3.Initialize("ZLED Control")
			o3.Show
			
		Case "ws2" '--- ws281x
			If oc.isConnected = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			Dim o3 As dlgOnOffCtrl
			o3.Initialize("WS281x Control")
			o3.Show
		#end if
		
	End Select
			
	
End Sub


Private Sub RunHTTPOnOffMenu(fname As String)
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,fname)
	If  Data.GetDefault("tgl",False).As(Boolean) Then '--- toggle cmd
		oMasterController.cn.PostRequest2(Data.Get("ipon"),"")
		guiHelpers.Show_toast2("Toggle Command Sent",1300)
		Return
	End If
	Dim o1 As dlgOnOffCtrl
	o1.Initialize(Data.GetDefault("desc","On / Off"))
	o1.Data = Data
	o1.Show
End Sub








