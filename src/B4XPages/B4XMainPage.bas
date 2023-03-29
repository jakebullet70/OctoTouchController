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
	Public oMasterController As MasterController
	Private toast As BCToast

	'--- panel to cover screen for power ctrl
	Public pnlScreenOff As Panel
	
	'--- splash screen crap
	Private ivSpash As ImageView, pnlSplash As Panel
	
	'--- master base panel
	Private pnlMaster As B4XView 
	
	'--- header
	Private pnlHeader As B4XView,  lblTemp As Label
	Private btnPower, btnPageAction As Button
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
	
	'--- gesture crap --------------------------------------
'	Private GD As GestureDetector
'	Private FilterMoveEvents As Boolean 'ignore
'	Private DiscardOtherGestures As Boolean = True 'ignore
	'-------------------------------------------------------

	Private mapMasterPreHeaterMenu As Map
	
End Sub

'======================================================================================
'
' --- main page (displays panels, has public utility classes)
'
'======================================================================================


Public Sub Initialize
	
	config.Init
	logMe.Init(xui.DefaultFolder,"_OCTOTC_","log")
	clrTheme.Init(Starter.kvs.Get(gblConst.SELECTED_CLR_THEME).As(String).ToLowerCase)
	
	Starter.InitLogCleanup
	
	'  debug - remove for release
	'fileHelpers.DeleteFiles(xui.DefaultFolder,"*.log")
	'  debug - remove for release
	
	
	fileHelpers.DeleteFiles(xui.DefaultFolder,"sad_*.png") '--- delete all thumbnails
	logMe.LogIt("App Startup...","")
	
	powerHelpers.Init(config.AndroidTakeOverSleepFLAG)
	CfgAndroidPowerOptions
	
	'--- set toast text size
	mToastTxtSize = IIf(guiHelpers.gScreenSizeAprox > 5,24,22) 
	
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"Check4_Update",8000)
	
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
		LoadSplashPic
		pnlMaster.Visible = False
		pnlSplash.Visible = True
	Else
		Starter.FirstRun = False
	End If

	BuildGUI
	
	'--- gesture crap
	'GD.SetOnGestureListener(pnlMenu, "Gesture")
	
	TryPrinterConnection
	
End Sub

Private Sub B4XPage_CloseRequest As ResumableSub
	
	'--- catch the android BACK button
	If oPageCurrent <> oPageMenu Then
		Switch_Pages(gblConst.PAGE_MENU)		
		Return False '--- cancel close request
	End If
	
	If PromptExitTwice = False Then
		Show_toast("Tap again to exit",2200)
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

Private Sub BuildGUI
	
	pnlMaster.Color  = clrTheme.Background
	pnlHeader.Color	 = clrTheme.BackgroundHeader
	
	'--- hide all page views
	guiHelpers.HidePageParentObjs(Array As B4XView(pnlMenu,pnlFiles,pnlMovement))
	
	guiHelpers.SetTextColor(Array As B4XView(lblStatus,lblTemp,btnPower,btnPageAction))
	
	If guiHelpers.gIsLandScape = False Then
		Select Case True
			Case guiHelpers.gScreenSizeAprox > 6.5 And guiHelpers.gScreenSizeAprox < 9.5
				lblStatus.TextSize = lblStatus.TextSize + 4
				lblTemp.TextSize   = lblTemp.TextSize + 4
			Case guiHelpers.gScreenSizeAprox > 9.5
				lblStatus.TextSize = lblStatus.TextSize + 2
				lblTemp.TextSize   = lblTemp.TextSize + 4
		End Select
	End If
	
	guiHelpers.SkinButton_Pugin(Array As Button(btnPower, btnPageAction))
	ShowNoShow_PowerBtn
	
	Switch_Pages(gblConst.PAGE_MENU)
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
End Sub

Private Sub LoadSplashPic
	Dim fname As String = "splash.png"
	#if klipper
	fname = "splashklipper.png"
	#End If
	ivSpash.Bitmap = LoadBitmapSample(File.DirAssets, fname, ivSpash.Width, ivSpash.Height)
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
		Dim o9 As dlgOctoSetup 
		#if klipper
		o9.Initialize(Me,"Klipper Connection","PrinterSetup_Closed")
		#else
		o9.Initialize(Me,"Octoprint Connection","PrinterSetup_Closed")
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
		lblStatus.Text = gblConst.NOT_CONNECTED
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
	o1.Initialize(Me,"Options Menu",Me,"OptionsMenu_Event")
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
			oo9.Show(Me)
			
		Case "ab" '--- about
			Dim o2 As dlgAbout : o2.Initialize(Me)
			o2.Show
			
		Case "gn"  '--- general settings
			Dim o3 As dlgGeneralOptions : o3.Initialize(Me)
			o3.Show
			
		Case "oc"  '--- octo setup
			Dim o9 As dlgOctoSetup
			o9.Initialize(Me,"Printer Connection","PrinterSetup_Closed")
			o9.Show(False)
		
		Case "pw"  '--- android power setup
			Dim o1 As dlgPowerOptions : o1.Initialize(Me)
			o1.Show
			
		Case "plg"  '--- plugins menu
			PopupPluginOptionMenu
			
		Case "fn"  '--- functions menu
			PopupFunctionOptionsMnu
			
		Case "rt" '---read text file
			Dim vt As dlgViewText : vt.Initialize(Me,"Read Text")
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

'--- called from PSU setup
Public Sub  ShowNoShow_PowerBtn
	btnPower.Visible = config.ShowPwrCtrlFLAG
End Sub

'--- options plugin sub menu
Private Sub PopupFunctionOptionsMnu
	
	Dim popUpMemuItems As Map = CreateMap("Filament Control Wizard":"fl","Bed Leveling Wizard":"bl")
		
	Dim cs As CSBuilder : cs.Initialize
	Dim title As Object = cs.Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
										Typeface(Typeface.DEFAULT).Append("  Functions Menu").PopAll
	
	Dim o1 As dlgListbox
	o1.Initialize(Me,title,Me,"FncMenu_Event")
	o1.IsMenu = True
	o1.Show(260dip,300dip,popUpMemuItems)
	
End Sub

'--- callback for plugins options Menu
Private Sub FncMenu_Event(value As String, tag As Object)
	
	If value.Length = 0 Then PopupMainOptionMenu
	
	Select Case value
			
		Case "fl" '--- filament control
			Dim oB As dlgFilamentSetup
			oB.Initialize(Me)
			oB.Show
			
		Case "bl" '--- bed level control
			If oc.PrinterCustomBoundingBox = True Then
				Show_toast("Custom bounding box not supported at this time.",4500)
				Return
			End If
			Dim o1 As dlgBedLevelSetup
			o1.Initialize(Me)
			o1.Show
			
	End Select
	
End Sub


'--------------------------------------

'--- options plugin sub menu
Private Sub PopupPluginOptionMenu
	
	#if klipper
	Dim popUpMemuItems As Map = CreateMap("SonOff Control":"psu")
	#else
	Dim popUpMemuItems As Map = CreateMap("PSU Control":"psu","ZLED Setup":"led","ws281x Setup":"ws2")
	#End If
	
	Dim cs As CSBuilder : cs.Initialize
	Dim title As Object = cs.Typeface(Typeface.MATERIALICONS).VerticalAlign(4dip).Append(Chr(0xE8C1)). _
	        	 					   Typeface(Typeface.DEFAULT).Append("  Plugins Menu").PopAll
	Dim o1 As dlgListbox
	o1.Initialize(Me,title,Me,"PluginsMenu_Event")
	o1.IsMenu = True
	o1.Show(260dip,300dip,popUpMemuItems)
	
End Sub

'--- callback for plugins options Menu
Private Sub PluginsMenu_Event(value As String, tag As Object)
	
	If value.Length = 0 Then PopupMainOptionMenu
	
	Select Case value
			
		Case "psu"  '--- sonoff / PSU control setup
			Dim oA As dlgPsuSetup
			#if klipper
			oA.Initialize(Me,"PSU SonOff Config")
			#else
			oA.Initialize(Me,"PSU Config")
			#End If
			
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

	If mConnectionErrDlgShowingFLAG Or pPrinterCfgDlgShowingFLAG Then Return
	mConnectionErrDlgShowingFLAG = True
	Log("starting error setup cfg")

	'--- turn timers off
	CallSub2(Main,"TurnOnOff_MainTmr",False)
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	
	'--- back to the main menu
	If oPageCurrent <> oPageMenu Then Switch_Pages(gblConst.PAGE_MENU)
	
	If pnlScreenOff.Visible = True Then
		Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"ScreenOff_2Front",600)
	End If
	
	'--- if sonoff power is configed, show power btn - remember, if no connection to octoprint
	'--- so cannot use any octoprint installed plugin
	Dim PowerCtrlAvail As String = ""
	If Starter.kvs.GetDefault(gblConst.PWR_SONOFF_PLUGIN,False).As(Boolean) = True Then
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
			Dim o As dlgPsuCtrl : o.Initialize(Null)
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
		
	ht.Initialize(Me,title,Me,"TempChange_Presets")
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



#Region "GESTURES"
'======================================================================================================

'Private Sub Gesture_onTouch(Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
'	Log("onTouch action=" & Action & ", x=" & X & ", y=" & Y & ", ev=" & MotionEvent)
'
'	If FilterMoveEvents Then
'		If Action = GD.ACTION_MOVE Then
'			Log("[Filtered]")
'			Return True
'		Else
'			FilterMoveEvents = False
'		End If
'	End If
'
'	Return DiscardOtherGestures
'End Sub
'
'Private Sub Gesture_onDrag(deltaX As Float, deltaY As Float, MotionEvent As Object)
'	Log("   onDrag deltaX=" & deltaX & ", deltaY=" & deltaY)
'
'	'If the gesture is more horizontal than vertical and covered more than the minimal distance (10%x)...
'	If Abs(deltaX) > Abs(deltaY) And Abs(deltaX) > 10%x And Not(FilterMoveEvents) Then
'		FilterMoveEvents = True 'We handle all the touch events with Action = Move so no vertical scrolling is possible
'		If deltaX > 0 Then
'			'CallSubDelayed3(Me, "DisplayMsg", "Swipe to the right", deltaX)
'		Else
'			'CallSubDelayed3(Me, "DisplayMsg", "Swipe to the left", -deltaX)
'		End If
'	End If
'End Sub'
'
'Private Sub Gesture_onScroll(distanceX As Float, distanceY As Float, MotionEvent1 As Object, MotionEvent2 As Object)
'	Log("   onScroll distanceX = " & distanceX & ", distanceY = " & distanceY & ", ev1 = " & MotionEvent1 & ", ev2=" & MotionEvent2)
'End Sub

'Private Sub Gesture_onFling(velocityX As Float, velocityY As Float, MotionEvent1 As Object, MotionEvent2 As Object)
'	Dim left2right As Boolean = False
'	Dim right2left As Boolean = False
'	Dim up2down As Boolean = False
'	Dim down2up As Boolean = False
'	Select Case True
'		Case velocityX < 0 And velocityY < 0
'			right2left = True
'		Case velocityX > 0 And velocityY > 0
'			left2right = True
'		Case velocityX > 0 And velocityY > 0
'	End Select
'	
'	Log("   onFling velocityX = " & velocityX & ", velocityY = " & velocityY & ", ev1 = " & MotionEvent1 & ", ev2 = " & MotionEvent2)
'	'onFling velocityX = 0.009265188127756119, velocityY = 596.5069580078125,
'	
'	'Log("      X1, Y1 = " & GD.getX(MotionEvent1, 0) & ", " & GD.getY(MotionEvent1, 0))
'	'Log("      X2, Y2 = " & GD.getX(MotionEvent2, 0) & ", " & GD.getY(MotionEvent2, 0))
'	Log(GD.getAction(MotionEvent1))
'	'ev1 = MotionEvent { action=ACTION_DOWN, id[0]=0, x[0]=724.98047, y[0]=824.96924,
'	'toolType[0]=TOOL_TYPE_FINGER, buttonState=0, metaState=0, flags=0x0, edgeFlags=0x0,
'	'pointerCount=1, historySize=0, eventTime=11159052, downTime=11159052, deviceId=3, source=0x1002 },
'	
'	'ev2 = MotionEvent { action=ACTION_UP, id[0]=0, x[0]=744.02344, y[0]=118.96948,
'	'toolType[0]=TOOL_TYPE_FINGER, buttonState=0, metaState=0, flags=0x0, edgeFlags=0x0,
'	'pointerCount=1, historySize=0, eventTime=11159447, downTime=11159052, deviceId=3, source=0x1002 }
'End Sub
#END REGION
