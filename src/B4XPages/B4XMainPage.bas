﻿B4A=true
Group=B4XPAGES
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 2.0	Aug/2023
' V. 1.1-3	Mar-Jul/2023	
' V. Rocket artillery attack while in bed, almost killed, lost home. Dec 1st 2022
' V. 1.x	Oct/2022 - Nov/2022
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
	Private csHdr As CSBuilder
	Private strTMP As String, iiTMP As Int

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
	
	'--- popups and wiz screens
	Public pObjCurrentDlg1 As Object = Null
	Public pObjCurrentDlg2 As Object = Null
	Public pObjPreHeatDlg1 As dlgListbox
	Public pnlWizards As Panel
	Public pDlgFilSetup As dlgFilamentSetup
	Public pObjWizards As Object = Null
	Private mErrorDlg As dlgMsgBox 
	Public pMBox2 As dlgMsgBox2 
	
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
	logMe.LogDebug2("B4XPage_CloseRequest",mModule)
	'--- catch the android BACK button
	'--- catch the android BACK button
	
	
	If Drawer.RightOpen Then
		Drawer.RightOpen = False
		Return False
	End If
	
	If mConnectionErrDlgShowingFLAG Or pPrinterCfgDlgShowingFLAG Then
		mErrorDlg.Close_Me
		Return False
	End If
	
	If pDlgFilSetup.IsInitialized And pDlgFilSetup.pPrefDlg.Dialog.Visible Then
		CallSubDelayed(pDlgFilSetup,"Close_Me") 
		Return False
	End If
	
	If pMBox2.IsInitialized And pMBox2.Visible Then
		CallSubDelayed(pMBox2,"Close_Me")
		Return False '--- cancel close request
	End If
	
	If pObjPreHeatDlg1 <> Null And SubExists(pObjPreHeatDlg1,"Close_Me") Then
		CallSubDelayed(pObjPreHeatDlg1,"Close_Me") 'ignore
		pObjPreHeatDlg1 = Null
		If oPageCurrent = oPageMovement Then pObjCurrentDlg1 = Null
		Return False '--- cancel close request
	End If
		
	'If pnlWizards.Visible = True And (pObjWizards <> Null) And SubExists(pObjWizards,"Close_Me") Then
	If (pObjWizards <> Null) And SubExists(pObjWizards,"Close_Me") Then
		CallSubDelayed(pObjWizards,"Close_Me") 'ignore
		pObjWizards = Null
		Return False '--- cancel close request
	End If
	
	
	
	'--- NEED 2 BE CHECKED !!!!!!!!!!!!!!!!!!  v2 SEEMS 2 WORK ONLY IN RELEASE MODE?????
	If pObjCurrentDlg2 <> Null And SubExists(pObjCurrentDlg2,"Close_Me") Then 'pObjCurrentDlg2.As(dlgIpOnOffSetup).Visible = True Then
		Log("maybe i will log something - closing pObjCurrentDlg2")
		CallSubDelayed(pObjCurrentDlg2,"Close_Me") 'ignore
		pObjCurrentDlg2 = Null
		Return False '--- cancel close request
	End If
	If pObjCurrentDlg1 <> Null And SubExists(pObjCurrentDlg1,"Close_Me") Then
		Log("maybe i will log something - closing pObjCurrentDlg1")
		CallSubDelayed(pObjCurrentDlg1,"Close_Me") 'ignore
		pObjCurrentDlg1 = Null
		Return False '--- cancel close request
	End If
	'--- NEED 2 BE CHECKED !!!!!!!!!!!!!!!!!!  v2 SEEMS 2 WORK ONLY IN RELEASE MODE ----   Above
	
	
	
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
	CallSub2(Main,"TurnOnOff_MainTmr",False)
	Main.isAppClosing = True
	guiHelpers.Show_toast("Shutting down...",2000)
	oMasterController.oWS.wSocket.Close : Sleep(1500) '--- give sometime to close socket
	
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
	
	guiHelpers.SkinButton_Pugin(Array As Button(btnSliderMenu, btnPageAction))
	Dim bs As Float = 35
	If guiHelpers.gIsLandScape Then bs = 24
	btnSliderMenu.TextSize = bs
	btnPageAction.TextSize = bs
	
	pnlMainDrawer.Color = clrTheme.Background2
	SideMenu.SkinMe(Array As Button(btnSTOP,btnFRESTART,btnRESTART),pnlMainDrawer,pnlBtnsDrawer)
	pnlLineBreakDrawer.Color = clrTheme.txtNormal
	btnFRESTART.Visible = False : 	btnRESTART.Visible = False : btnSTOP.Visible = True '--- default these 
	
	
	clvDrawer.DefaultTextBackgroundColor = clrTheme.Background
	clvDrawer.PressedColor = clrTheme.BackgroundHeader
	clvDrawer.DefaultTextColor = clrTheme.txtNormal
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
		Dim o9 As dlgOctoSetup : 
		o9.Initialize("Printer Connection","PrinterSetup_Closed")
		o9.Show(True)
	Else
		If oc.IsConnectionValid Then
			oMasterController.SetCallbackTargets(Me,"Update_Printer_Temps","Update_Printer_Status","Update_Printer_Btns")
			oMasterController.Start
			oMasterController.oWS.pParserWO.EventAdd("MetadataAnalysisFinished",Me,"ev_file_change")
			oMasterController.oWS.pParserWO.EventAdd("FileRemoved",Me,"ev_file_del")
'			oMasterController.oWS.pParserWO.EventAdd("PrinterStateChanged",Me,"ev_get_jobstatus")
'			Main.tmrTimerCallSub.CallSubDelayedPlus2(Me,"ev_get_jobstatus",1200,Null)
			If Main.kvs.ContainsKey(gblConst.IS_OCTO_KLIPPY) = False Then
				Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Is_OctoKlipper",800)
			Else
				oc.Klippy = Main.kvs.Get(gblConst.IS_OCTO_KLIPPY)
			End If
			
		End If
	End If

End Sub

Private Sub Is_OctoKlipper
	'--- only happens on 1st connection
	Dim oo As OctoKlippyMisc : oo.Initialize 
	Wait For (oo.IsOctoKlipper) Complete(i As Boolean)
	oo.CreateDefGCodeFiles
	If oc.Klippy Then 
		'--- side menu defaulted to Marlin firmware, reset it
		SideMenu.SkinMe(Array As Button(btnSTOP,btnFRESTART,btnRESTART),pnlMainDrawer,pnlBtnsDrawer)
		SideMenu.Display_Btns
	End If
	Build_RightSideMenu
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
		
		
		If oPageCurrent Is pageMovement Or oPageCurrent Is pageFiles Then
			If guiHelpers.gIsLandScape = False Then
				lblStatus.TextSize = 18
			Else
				lblStatus.TextSize = 22
			End If
			
		'	lblStatus.Text = lblStatus.Text.As(String) & _
		'		"  (" & oc.FormatedTemps.Replace(CRLF,"   ").Replace("C","") & ")"
			
			lblStatus.Text = csHdr.Initialize.Append(lblStatus.Text).Append("  ").Append(oc.FormatedTemps).PopAll
			
			'oc.FormatedTemps
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

#region "MY PAGE CHANGING-SWITCHING CODE"
Public Sub btnPageAction_Click
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
			'--- are we already on the menu page? this can be called when printer disapears and we are on another page
			If oPageCurrent = Null Or oPageCurrent <> oPageMenu Then 
				oPageCurrent = oPageMenu
				btnPageAction.Text = Chr(0xE5D2)
			Else
				Return
			End If
			
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


'================================================================================================
'================================================================================================
'================================================================================================


#Region "POPUP_MAIN_SETUP_MENU_AND_FUNCTIONS"
Private Sub PopupMainOptionMenu
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	Dim popUpMemuItems As Map 

	Dim gui As guiMsgs : gui.Initialize		
	popUpMemuItems = gui.BuildOptionsMenu(False)
	
	Dim o1 As dlgListbox
	pObjCurrentDlg1 = o1.Initialize("Options Menu",Me,"OptionsMenu_Event",pObjCurrentDlg1)
	o1.IsMenu = True
'	Log(guiHelpers.gScreenSizeAprox)
'	Log(guiHelpers.gHeight)
'	Log(guiHelpers.gWidth)
'	Log(guiHelpers.gFscale)
'	Log(guiHelpers.gScreenSizeDPI)
		
	If guiHelpers.gIsLandScape Then '- TODO needs refactor for sizes
		o1.Show(guiHelpers.gHeight*.8, 340dip,popUpMemuItems)
	Else
		If guiHelpers.gScreenSizeAprox < 5 Then
			o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,436dip,340dip),guiHelpers.gWidth - 10dip,popUpMemuItems)
		Else		
			o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,436dip,340dip),354dip,popUpMemuItems)
		End If
		
	End If
	
End Sub

Private Sub OptionsMenu_Event(value As String, tag As Object)
	
	'--- callback for options Menu
	pObjCurrentDlg1 = Null
	If value = Null Or value.Length = 0 Then 
		Return
	End If
	
	Select Case value
		Case "thm1" '--- themes
			Dim oo9 As dlgThemeSelect 
			pObjWizards = oo9.Initialize
			oo9.Show(pnlWizards)
			
		Case "ab" '--- about
			Dim o2 As dlgAbout 
			pObjCurrentDlg1 = o2.Initialize
			o2.Show
			
		Case "gn"  '--- general settings
			Dim o3 As dlgGeneralOptions 
			pObjCurrentDlg1 = o3.Initialize
			o3.Show
			
		Case "oc"  '--- octo setup
			Dim o9 As dlgOctoSetup
			o9.Initialize("Printer Connection","PrinterSetup_Closed")
			o9.Show(False)
			
		Case "pw"  '--- android power setup
			Dim o1 As dlgAndroidPowerOptions 
			pObjCurrentDlg1 = o1.Initialize
			o1.Show
			
		Case "plg"  '--- plugins menu
			PopupPluginOptionMenu
			
		Case "fn"  '--- functions menu
			PopupFunctionOptionsMnu
			
		Case "rt" '---read text file
			Dim f As String = fnc.GetTxtLogFile
			If f = "" Then
				Show_toast("no log file found",6000)
				Return
			End If
			Dim vt As dlgViewText 
			pObjCurrentDlg1 = vt.Initialize("Read Text")
			vt.Show(f)
			
		Case "cup" '--- check for update
			Dim up As dlgAppUpdate 
			pObjCurrentDlg1 = up.Initialize(B4XPages.MainPage.Root)
			up.Show
			
	End Select
	
	
End Sub


'--- called from dlgOctoSetup on exit
Public Sub PrinterSetup_Closed

	If oc.IsConnectionValid Then
		Show_toast("Trying to connect... This might take a few moments...",3000)		
		TryPrinterConnection
	End If
	'Sleep(100)
	'guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
End Sub


'--- options plugin sub menu
Private Sub PopupFunctionOptionsMnu
	
	Dim cs As CSBuilder 
	Dim gui As guiMsgs : gui.Initialize
	Dim po As Map = gui.BuildFunctionSetupMenu
			
	Dim title As Object = cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
										Typeface(Typeface.DEFAULT).Append("  Movement Functions Menu").PopAll
	
	Dim o1 As dlgListbox
	pObjCurrentDlg1 = o1.Initialize(title,Me,"FncMenu_Event",pObjCurrentDlg1)
	o1.IsMenu = True
	Dim h As Float = 300dip
	If guiHelpers.gIsLandScape Then h = guiHelpers.MaxVerticalHeight_Landscape
	o1.Show(h,300dip,po)
	
	
End Sub

'--- callback for plugins options Menu
Private Sub FncMenu_Event(value As String, tag As Object)
	
	If value.Length = 0 Then PopupMainOptionMenu
	Dim onOff As Boolean
	Dim msg As String = ""
	
	Select Case value
			
'		Case "g29"
'			Main.kvs.Put("g29", Not (Main.kvs.GetDefault("g29",False)))
'			Show_toast("G29 Option Saved",2000)

		Case "mms"
			onOff = Main.kvs.Get(gblConst.MANUAL_MESH_FLAG).As(Boolean)
			msg = "Manual mesh wizard turned "
			If onOff Then
				msg = msg & "off"
			Else
				msg = msg & "on"
			End If
			Main.kvs.Put(gblConst.MANUAL_MESH_FLAG, Not (onOff))
			
		Case "zo"
			onOff = Main.kvs.Get(gblConst.Z_OFFSET_FLAG).As(Boolean)
			msg = "Z Offset wizard turned "
			If onOff Then 
				msg = msg & "off"
			Else
				msg = msg & "on"
			End If
			Main.kvs.Put(gblConst.Z_OFFSET_FLAG, Not (onOff))

		Case "blcr" '--- BL touch
			Dim oB7 As dlgBLTouchSetup
			oB7.Initialize : oB7.Show
			
		Case "fl" '--- filament control
			''Dim pDlgFilSetup As dlgFilamentSetup
			pDlgFilSetup.Initialize 
			pDlgFilSetup.Show
			
		Case "bl" '--- bed level control
			If oc.PrinterCustomBoundingBox = True Then
				Show_toast("Custom bounding box not supported at this time.",4500)
				Return
			End If
			Dim o1 As dlgBedLevelSetup
			o1.Initialize : o1.Show
			
		Case "g0","g1","g2","g3","g4","g5","g6","g7"
			strTMP = value.Replace("g","")
			Dim o23 As dlgGCodeCustSetup
			pObjCurrentDlg2 = o23.Initialize(Me,"Rebuild_RightMnu")
			o23.Show("GCode Control Config - " & strTMP,strTMP & gblConst.GCODE_CUSTOM_SETUP_FILE)
			
	End Select
	
	If msg.Length <> 0 Then Show_toast(msg,2400)
	
End Sub


'--------------------------------------

'--- options plugin sub menu
Private Sub PopupPluginOptionMenu

	Dim o As guiMsgs : 	o.Initialize
	Dim popUpMemuItems As Map = o.BuildPluginOptionsMenu
	Dim title As Object = "  Plugins Menu"
	
	Dim cs As CSBuilder 
	Dim title As Object = cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(4dip). _
										Append(Chr(0xE8C1)).Typeface(Typeface.DEFAULT).Append(title).PopAll
	Dim o1 As dlgListbox
	pObjCurrentDlg1 = o1.Initialize(title,Me,"PluginsMenu_Event",pObjCurrentDlg1)
	o1.IsMenu = True
	Dim h As Float = 300dip
	If guiHelpers.gIsLandScape Then h = guiHelpers.gHeight*.8
	o1.Show(h,300dip,popUpMemuItems)
	
End Sub

'--- callback for plugins options Menu
Private Sub PluginsMenu_Event(value As String, tag As Object)
	
	pObjCurrentDlg1 = Null
	If value.Length = 0 Then 
		PopupMainOptionMenu
		Return
	End If
	
	Select Case value
			
		Case "psu"  '--- sonoff / PSU control setup		
			Dim oA As dlgOctoPsuSetup
			pObjCurrentDlg2 = oA.Initialize("PSU Config")
			oA.Show
			
		Case "1","2","3","4","5","6","7","8"
			Dim oA1 As dlgIpOnOffSetup
			pObjCurrentDlg2 = oA1.Initialize(Me,"Rebuild_RightMnu")
			oA1.Show("HTTP Control Config - " & value,value & gblConst.HTTP_ONOFF_SETUP_FILE)

	End Select
		
End Sub

#end region

Public Sub CallSetupErrorConnecting(connectedButError As Boolean)

	If mConnectionErrDlgShowingFLAG Or pPrinterCfgDlgShowingFLAG Then Return
	mConnectionErrDlgShowingFLAG = True
	Log("starting error setup cfg")

	'--- turn timers off
	CallSub2(Main,"TurnOnOff_MainTmr",False)
	'CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	
	'--- back to the main menu
	If oPageCurrent <> oPageMenu Then Switch_Pages(gblConst.PAGE_MENU)
	
	If pnlScreenOff.Visible = True Then
		Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"ScreenOff_2Front",600)
	End If
	
	'--- if sonoff power is configed, show power btn - remember, if no connection to octoprint
	'--- so cannot use any octoprint installed plugin
	'----------------------------------------------------------------------  KLIPPER TODO ?????
	Dim PowerCtrlAvail As String = ""
	If Main.kvs.GetDefault(gblConst.PWR_SONOFF_PLUGIN,False).As(Boolean) = True Then 'TODO 2, how will klipper handle this
		PowerCtrlAvail = "POWER"
	End If
	'----------------------------------------------------------------------  KLIPPER TODO ?????

	Dim Const JUSTIFY_BUTTON_2_LEFT As Boolean = True
	Dim h,w As Float
	If guiHelpers.gIsLandScape Then
		h = guiHelpers.MaxVerticalHeight_Landscape
		w = 500dip
	Else
		h = 310dip : w = 88%x
	End If
	mErrorDlg.Initialize(Root,"Connetion Problem", w, h,JUSTIFY_BUTTON_2_LEFT)
	Dim gui As guiMsgs : gui.Initialize
	Wait For (mErrorDlg.Show(gui.GetConnectionText(connectedButError),gblConst.MB_ICON_WARNING, _
					"RETRY",PowerCtrlAvail,"SETUP")) Complete (res As Int)
	
	Select Case res
		Case xui.DialogResponse_Positive '--- retry
			Show_toast("Retrying connection...",1300)
			oMasterController.Start
			
		Case xui.DialogResponse_Cancel	 '--- this runs printer setup
			mConnectionErrDlgShowingFLAG = False
			OptionsMenu_Event("oc","oc")
			
		Case xui.DialogResponse_Negative '--- Power on 
			Dim o As dlgOctoPsuCtrl : o.Initialize(Me)
			o.mRunMasterCtrlrStart = True
			o.Show
			
	End Select
	
	CfgAndroidPowerOptions
	mConnectionErrDlgShowingFLAG = False
	Log("exiting error connecting setup cfg")

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
	If lblStatus.Text.ToLowerCase.Contains("no c") Or oc.isConnected = False Or oMasterController.oWS.pConnected = False  Then
		CallSetupErrorConnecting(False)
	End If
End Sub

'Private Sub btnPower_Click
'	'--- printer on/off
'	Dim o1 As dlgOctoPsuCtrl
'	o1.Initialize(Me)
'	o1.Show
'End Sub


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
	Dim cs As CSBuilder 
	Dim title As Object = cs.Initialize.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF2CA)). _
		Typeface(Typeface.DEFAULT).Append("  " & titleTxt).PopAll
		
	pObjPreHeatDlg1 = ht.Initialize(title,Me,"TempChange_Presets",pObjPreHeatDlg1)
	Dim w As Float = IIf(guiHelpers.gIsLandScape,450dip,guiHelpers.gWidth - 10dip)
	Dim h As Float = IIf(guiHelpers.gIsLandScape,guiHelpers.MaxVerticalHeight_Landscape,guiHelpers.gHeight * .7)
		
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

#end region

#region "RIGHT_SIDE_DRAWER"
'--- side drawer
Public Sub btnSidePnl_Click
	Dim b As Button : b = Sender
	SideMenu.BtnPressed(b)
End Sub

Private Sub btnSliderMenu_Click
	'--- righty menu gear icon
	SideMenu.OpenRightMenu 
	CallSubDelayed(SideMenu,"Display_Btns")
End Sub


Private Sub Build_RightSideMenu
'	If oc.Klippy Then
'		
'	End If
	Log("Build_RightSideMenu")

	clvDrawer.Clear
	If oc.IsKlippyConnected = False Then Return
	Dim size As Float = IIf(guiHelpers.gIsLandScape,20,22)
	Dim txt As Object, dataMap As Map
	Dim cs As CSBuilder
	
	Dim dataMapG As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
'	If lblStatus.Text = gblConst.NOT_CONNECTED Then
'		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Retry Connection").PopAll,"rcnt")
'	End If

	'If oc.isPrinting Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Filament Cooling Menu").PopAll,"fcm")
	'End If
	
	If dataMapG.GetDefault("m600",False).As(Boolean) Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Filament Change M600").PopAll,"m600")
	End If
	
	If (oPageFiles.IsInitialized) And (oPageCurrent = oPageFiles) Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Force Refresh Of Files").PopAll,"refl")
	End If
	
	
	'clvDrawer.AddTextItem(cs.Initialize.Size(12).Alignment("ALIGN_CENTER").Append("------------ SYS CMDS -----------").PopAll,"")
	For iiTMP = 0 To 7
		strTMP = iiTMP & gblConst.GCODE_CUSTOM_SETUP_FILE
		dataMap = File.ReadMap(xui.DefaultFolder,strTMP)
		If dataMap.GetDefault("rmenu",False).As(Boolean) = True Then
			txt = dataMap.Get("desc")
			If strHelpers.IsNullOrEmpty(txt) Then 
				txt = "GCode " & iiTMP & "Menu"
			End If
			clvDrawer.AddTextItem(cs.Initialize.Size(size).Append(txt).PopAll,"g" & iiTMP)
		End If
	Next
	
	
	For iiTMP = 1 To 8
		strTMP = iiTMP & gblConst.HTTP_ONOFF_SETUP_FILE
		If File.Exists(xui.DefaultFolder,strTMP) = True Then
			dataMap  = File.ReadMap(xui.DefaultFolder,strTMP)
			If dataMap.GetDefault("active",False).As(Boolean) = True Then
				txt = dataMap.Get("desc")
				If strHelpers.IsNullOrEmpty(txt) Then 
					txt = "HTTP " & iiTMP & "Menu"
				End If
				clvDrawer.AddTextItem(cs.Initialize.Size(size).Append(txt).PopAll,iiTMP)
			End If
		End If
	Next
	
	If config.ReadPwrCfgFLAG Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Printer Power Menu").PopAll,"pwr")
	End If
		
	If dataMapG.GetDefault("syscmds",False).As(Boolean) Then
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("OS Systems Menu").PopAll,"sys")
	End If
	
	If oc.Klippy And oc.IsKlippyConnected Then
		'--- add a complete firmware restart btn and yes/no prompt
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("Klipper Full Restart").PopAll,"kst")
	End If
	
	If clvDrawer.Size = 0 Then '--- nothing in the menu so add something.
		clvDrawer.AddTextItem(cs.Initialize.Size(size).Append("About This Program").PopAll,"ab")
	End If
		
End Sub

Private Sub Rebuild_RightMnu(editdata As Map)
	Build_RightSideMenu
End Sub


Private Sub clvDrawer_ItemClick (Index As Int, Value As Object)
	Dim txt As String = "", w As Float
	
	SideMenu.CloseRightMenu
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	Select Case Value.As(String)
		
		
		Case "fcm"  : Cooling_Fan
		
		Case "kst" '--- full octokliiper firmware restart
			w = 400dip
			If guiHelpers.gIsLandScape = False Then w = 90%x
			pMBox2.Initialize(B4XPages.MainPage.Root,"Question", w, 150dip,False)
			pMBox2.NewTextSize = 24
			txt = "Touch RESTART to fully" & CRLF & "restart klipper"
			If guiHelpers.gIsLandScape Then txt = txt.Replace(CRLF," ")
			Wait For (pMBox2.Show(txt,gblConst.MB_ICON_QUESTION, "RESTART","","CANCEL")) Complete (res As Int)
			If res = xui.DialogResponse_Cancel Then
				Return
			End If
			SideMenu.BtnPressed(btnFRESTART)
			If B4XPages.MainPage.oPageCurrent <> B4XPages.MainPage.oPageMenu Then
				'--- back to main page if page is anything else
				btnPageAction_Click
			End If
			
					
		Case "m600"
			w = 400dip
			If guiHelpers.gIsLandScape = False Then w = 90%x
			pMBox2.Initialize(B4XPages.MainPage.Root,"Question", w, 150dip,False)
			pMBox2.NewTextSize = 24
			txt = "Touch RUN to start M600" & CRLF & "Filament change"
			If guiHelpers.gIsLandScape Then txt = txt.Replace(CRLF," ")
			Wait For (pMBox2.Show(txt,gblConst.MB_ICON_QUESTION, "RUN","","CANCEL")) Complete (res As Int)
			If res = xui.DialogResponse_Cancel Then
				Return
			End If
			Send_Gcode("M600")

		Case "refl" : FilesCheckChange
			
		Case "ab" '--- about screen
			Dim o2 As dlgAbout : pObjCurrentDlg1 = o2.Initialize
			o2.Show
		
		Case "sys" '--- system menu
			Dim oa As dlgOctoSysCmds 
			pObjCurrentDlg1 = oa.Initialize(oMasterController.CN) 
			oa.Initialize(oMasterController.CN)
			oa.Show
		
		Case "pwr" '--- printer power
			If oc.isConnected = False And Main.kvs.GetDefault(gblConst.PWR_SONOFF_PLUGIN,False).As(Boolean) = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			Dim o1 As dlgOctoPsuCtrl 
			pObjCurrentDlg1 = o1.Initialize(Me)
			o1.Show
			
		Case "1","2","3","4","5","6","7","8" '--- misc HTTP commands
			RunHTTPOnOff_Menu(Value.As(String) & gblConst.HTTP_ONOFF_SETUP_FILE)
			
		Case "g0","g1","g2","g3","g4","g5","g6","g7" '--- misc GCode commands
			RunGCodeOnOff_Menu(Value.As(String).Replace("g","") & gblConst.GCODE_CUSTOM_SETUP_FILE)
			
		Case "rcnt"
			lblStatus_Click
		
	End Select
			
	
End Sub
#end region

#Region "COOLING FAN CRAP"
Public Sub Cooling_Fan
	Dim cs As CSBuilder
	Dim gui As guiMsgs : gui.Initialize
	Dim po As Map = gui.BuildCoolingFanMnu
	
	Dim title As Object = cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
										Typeface(Typeface.DEFAULT).Append("  Cooling Fan Menu").PopAll
	
	Dim o1 As dlgListbox
	pObjCurrentDlg1 = o1.Initialize(title,Me,"CoolMenu_Event",pObjCurrentDlg1)
	o1.IsMenu = True
	Dim h As Float = 300dip
	If guiHelpers.gIsLandScape Then h = guiHelpers.MaxVerticalHeight_Landscape
	o1.Show(h,300dip,po)
End Sub
Public Sub CoolMenu_Event(selectedMsg As String, tag As Object)
	'--- callback for Cooling_Fan
	If selectedMsg.Length = 0 Then Return
	Dim o As B4XEval : o.Initialize(Me,"")
	Dim g As String = "M106 S"
	Dim txt As String, v As Int
	Select Case True
		
		Case selectedMsg = "0"   : txt = "M107"
		Case selectedMsg = "100" : txt = g & "255"
		Case Else
			v = o.Eval("255 * ." & selectedMsg)
			txt = (g & v)
		
	End Select
	Send_Gcode(txt)
	pObjCurrentDlg1 = Null
	
End Sub
#end region





#region "FUCTIONS / GCODE METHODS FROM MENUS"

Private Sub RunHTTPOnOff_Menu(fname As String)
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,fname)
	If  Data.GetDefault("tgl",False).As(Boolean) Then '--- toggle cmd
		oMasterController.cn.PostRequest2(Data.Get("ipon"),"")
		guiHelpers.Show_toast2("Toggle Command Sent",1300)
		Return
	End If
	Dim o1 As dlgOnOffCtrl
	pObjCurrentDlg1 = o1.Initialize(Data.GetDefault("desc","On / Off"))
	o1.Data = Data
	o1.Show
End Sub


Public Sub RunGCodeOnOff_Menu(fname As String)
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,fname)
	Dim gc As String = Data.GetDefault("gcode","")
	Dim desc As String = Data.GetDefault("desc","")
	
	If gc.Trim = "" Then
		guiHelpers.Show_toast2("No GCODE found",2600)
		Return
	End If
	
	If Data.GetDefault("prompt",False).As(Boolean) = True Then
		Dim mb2 As dlgMsgBox2 
		Dim w As Float = 400dip
		If guiHelpers.gIsLandScape = False Then w = 90%x
		mb2.Initialize(B4XPages.MainPage.Root,"Question", w, 150dip,False)
		mb2.NewTextSize = 24
		Wait For (mb2.Show("Touch RUN to start:" & CRLF & desc,gblConst.MB_ICON_QUESTION, "RUN","","CANCEL")) Complete (res As Int)
		If res = xui.DialogResponse_Cancel Then 
			Return
		End If
	End If
	
	guiHelpers.Show_toast2("Runnning..." & CRLF & desc,3500)
	Send_Gcode(gc)
	Wait For Send_Gcode
	
End Sub


Public Sub Send_Gcode(code As String)
	If strHelpers.IsNullOrEmpty(code.Trim) Then Return
	'  TODO ----  this function is like in 3 places - needs to be put in 1
'	#if debug
	'Log(code)
'	Return
'	#End If
	
	If code.Contains(CRLF) Then
		Dim cd() As String = Regex.Split(CRLF, code)
		
		For Each s As String In cd
			s = CleanGcodeString(s)
			If strHelpers.IsNullOrEmpty(s) Then Continue
			#if klipper
			B4XPages.MainPage.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!",s))
			#else
			B4XPages.MainPage.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",s.ToUpperCase))
			#End If
			Sleep(250) '--- 1/4 second between
		Next
	Else
		code = CleanGcodeString(code)
		If strHelpers.IsNullOrEmpty(code) Then Return
		#if klipper
		B4XPages.MainPage.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!",code))
		#else
		B4XPages.MainPage.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",code))
		#end if
	End If
	
	Return
	
End Sub

Private Sub CleanGcodeString(s As String) As String
	s = s.Trim
	If s.StartsWith(";") Or s.StartsWith("#") Then
		Return ""		
	Else
		Return s
	End If
End Sub


#end region



Private Sub ev_file_change(msg As String)
	logMe.LogDebug2("ev_file_change","")
	If oPageFiles.IsInitialized = False Then Return
	If oPageCurrent <> oPageFiles Then
		oPageFiles.FileEvent = True
	Else
'		Dim parser As JSONParser : parser.Initialize(msg)
'		Dim R1 As Map = parser.NextObject
'		Dim event As Map = R1.Get("event")
'		Dim etype As String = event.Get("type")
'		If etype = "MetadataAnalysisFinished" Then
'			Dim payload As Map = event.Get("payload")
'			Dim result As Map = payload.Get("result")
'			Dim analysisPending As String = result.Get("analysisPending")
'			If analysisPending = "true" Then 
'				logMe.LogDebug2("analysisPending=true","")
'				Return
'			End If
'		End If
		'--- see if 'FilesCheckChange' is already queud up to run
		If Main.tmrTimerCallSub.Exists(Me,"FilesCheckChange") <>  Null Then Return
		'Main.tmrTimerCallSub.ExistsRemove(Me,"FilesCheckChange")
		
		Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"FilesCheckChange",1200)
	End If
End Sub
Private Sub ev_file_del(msg As String)
	logMe.LogDebug2("ev_file_del","")
	If oPageFiles.IsInitialized = False Then Return
	If oPageCurrent <> oPageFiles Then
		oPageFiles.FileEvent = True
	Else
		'--- see if 'FilesCheckChange' is already queud up to run
		If Main.tmrTimerCallSub.Exists(Me,"FilesCheckChange") <> Null Then Return
		'Main.tmrTimerCallSub.ExistsRemove(Me,"FilesCheckChange")
		
		Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"FilesCheckChange",1200)
	End If
End Sub

Private Sub FilesCheckChange
	oPageFiles.FilesCheckChange(False)
End Sub
'
'Private Sub ev_get_jobstatus(msg As String)
'	'oMasterController.Get_JobStatus(msg As String)
'End Sub
