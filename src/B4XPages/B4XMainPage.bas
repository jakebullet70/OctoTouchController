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
	
	Public pPrinterCfgDlgShowingFLAG As Boolean = False
	Private PromptExitTwice As Boolean = False
	Private mToastTxtSize As Int	
	
End Sub

'======================================================================================
'
' --- main page (displays panels, has public utility classes)
' --- just shows panel-classes
'
'======================================================================================


Public Sub Initialize
	
	config.Init
	logMe.Init(xui.DefaultFolder,"_OCTOTC_","log")
	clrTheme.Init(Starter.kvs.Get(gblConst.CLR_THEME_KEY).As(String).ToLowerCase)
	
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
		pnlMaster.Visible = False
		pnlSplash.Visible = True
	Else
		Starter.FirstRun = False
	End If

	BuildGUI
	TryOctoConnection
	
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
	
	
	btnPower.Visible = config.ShowPwrCtrlFLAG
	
	Switch_Pages(gblConst.PAGE_MENU)
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
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
	toast.Show($"[TextSize=${mToastTxtSize}][b][FontAwesome=0xF05A/]  ${msg}[/b][/TextSize]"$)
End Sub

#Region "POPUP_MAIN_SETUP_MENU"
Private Sub PopupMainOptionMenu
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	Dim popUpMemuItems As Map 
		
	If oc.isPrinting Or oc.IsPaused2 Then
		Show_toast("Cannot Change OctoPrint Settings While Printing",2500)
		popUpMemuItems = guiHelpers.BuildOptionsMenu(True)
	Else
		popUpMemuItems = guiHelpers.BuildOptionsMenu(False)
	End If
	
	Dim o1 As dlgListbox
	o1.Initialize(Me,"Options Menu",Me,"OptionsMenu_Event")
	o1.IsMenu = True
	If guiHelpers.gIsLandScape Then '- TODO needs refactor for sizes
		o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,320dip,280dip),340dip,popUpMemuItems)
	Else
		o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,380dip,280dip),300dip,popUpMemuItems)
	End If
	
End Sub

Private Sub OptionsMenu_Event(value As String, tag As Object)
	
	'--- callback for options Menu
	If value = Null Or value.Length = 0 Then Return
	
	Select Case value
		Case "thm1"
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
			o9.Initialize(Me,"Octoprint Connection","PrinterSetup_Closed")
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

	If oc.IsOctoConnectionVarsValid Then
		Show_toast("Trying to connect...",3000)		
		TryOctoConnection
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
	
	Dim popUpMemuItems As Map = CreateMap("Filament Control":"fl")
		
	Dim cs As CSBuilder : cs.Initialize
	Dim title As Object = cs.Typeface(Typeface.MATERIALICONS).VerticalAlign(4dip).Append(Chr(0xE24A)). _
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
			
	End Select
	
	
End Sub




'--------------------------------------

'--- options plugin sub menu
Private Sub PopupPluginOptionMenu
	
	Dim popUpMemuItems As Map = CreateMap("PSU Control":"psu","ZLED Setup":"led","ws281x Setup":"ws2")
	
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
	
	'--- if printer / sonoff power is configed, show power btn	
	Dim PowerCtrlAvail As String = ""
	If Starter.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean) = True Then
		PowerCtrlAvail = "POWER ON"
	End If

	Dim Const JUSTIFY_BUTTON_2_LEFT As Boolean = True
	Dim ErrorDlg As dlgMsgBox
	Dim h,w As Float
	If guiHelpers.gIsLandScape Then
		h = 180dip : w = 560dip
	Else
		h = 310dip : w = 360dip
	End If
	ErrorDlg.Initialize(Root,"Connetion Problem",w, h,JUSTIFY_BUTTON_2_LEFT)
	Wait For (ErrorDlg.Show(guiHelpers.GetConnectionText(connectedButError),gblConst.MB_ICON_WARNING, _
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
		oMasterController.AllHeaters_Off
		Show_toast("Tool / Bed Off",1200)
		Return
	End If
	
	Dim tagme As String = tag.As(String)
	Dim msg, getTemp As String
	Dim startNDX, endNDX As Int
	
	Select Case True
		
		Case selectedMsg.EndsWith("off")
			If tagme = "bed" Then
				oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",0))
				msg = "Bed Off"
			Else
				oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
				msg = "Tool Off"
			End If
			
		Case selectedMsg.Contains("Tool") And Not (selectedMsg.Contains("Bed"))
			'--- Example, Set PLA (Tool: 60øC )
			startNDX = selectedMsg.IndexOf(": ")
			endNDX   = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
			
		Case selectedMsg.Contains("Bed") And Not (selectedMsg.Contains("Tool"))
			'--- Example, PLA (Bed: 60øC )
			startNDX = selectedMsg.IndexOf(": ")
			endNDX   = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
			
		Case Else
			'--- Example, Set ABS (Tool: 240øC  / Bed: 105øC )
			Dim toolMSG As String = Regex.Split("/",selectedMsg)(0)
			Dim bedMSG  As String = Regex.Split("/",selectedMsg)(1)
				
			startNDX = toolMSG.IndexOf(": ")
			endNDX   = toolMSG.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = toolMSG.SubString2(startNDX + 2,endNDX).Trim
			oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
				
			startNDX = bedMSG.IndexOf(": ")
			endNDX   = bedMSG.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp  = bedMSG.SubString2(startNDX + 2,endNDX).Trim
			oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
			
	End Select
	
	Show_toast(msg,3000)
	
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
		Return
	End If
	Dim ht As dlgListbox
	Dim cs As CSBuilder : cs.Initialize
	Dim title As Object = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF2CA)). _
	Typeface(Typeface.DEFAULT).Append("  " & titleTxt).PopAll
	ht.Initialize(Me,title,Me,"TempChange_Presets")
	Dim w As Float = IIf(guiHelpers.gIsLandScape,450dip,390dip)
	ht.Show(220dip,w,oMasterController.mapAllHeatingOptions)
End Sub

