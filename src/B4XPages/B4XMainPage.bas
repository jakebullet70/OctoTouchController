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
	
	Public pnlScreenOff As B4XView
	
	'--- splash screen
	Private ivSpash As B4XView, pnlSplash As Panel
	
	'--- master base panel
	Private pnlMaster As B4XView 
	
	'--- header
	Private pnlHeader As B4XView, lblStatus As Label,  lblTemp As Label, btnPageAction As B4XView
	
	'--- page-panel classes
	Public oPageCurrent As Object = Null
	Private pnlMenu As B4XView,       oPageMenu As pageMenu
	Private pnlFiles As B4XView,      oPageFiles As pageFiles
	Private pnlPrinting As B4XView,   oPagePrinting As pagePrinting
	Private pnlMovement As B4XView,   oPageMovement As pageMovement
	
	'--- master parent obj used for some templates dialogs
	Private mDialog As B4XDialog 

End Sub

'======================================================================================
'
' --- main page (displays panels, has public utility classes)
' --- just shows panel-classes
'
'======================================================================================

Public Sub getDialog() As B4XDialog
	Return mDialog
End Sub

Public Sub getMasterCtrlr() As MasterController
	'--- master Octo controller / methods
	Return oMasterController
End Sub

Public Sub Initialize
	
	'fileHelpers.DeleteFiles(xui.DefaultFolder,"*.psettings") '--- DEV - delete all printing settings files
	config.Init
	logMe.Init(xui.DefaultFolder,"__OCTOTC__","log")
	clrTheme.Init(config.ColorTheme)
	
	'--- in about 15 minutes check for old logs, crash files (3 days old) and delete them
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Starter,"Clean_OldLogs",60000 * 13)
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Starter,"Clean_OldCrash",60000 * 17)
	
	powerHelpers.Init(config.AndroidTakeOverSleepFLAG)
	ConfigPowerOption
	
End Sub

#Region "PAGE EVENTS"
Private Sub B4XPage_Created (Root1 As B4XView)

	Root = Root1
	Root.SetLayoutAnimated(0,0,0,Root.Width,Root.Height)
	Root.LoadLayout("MainPage")
	
	toast.Initialize(Root)
	toast.pnl.Color = clrTheme.txtNormal
	toast.DefaultTextColor = clrTheme.Background
	
	'--- splash screen
	pnlMaster.Visible = False
	pnlSplash.Visible = True
	
	Build_GUI
	
End Sub

Private Sub B4XPage_CloseRequest As ResumableSub
	
	'--- catch the android BACK button
	If oPageCurrent <> oPageMenu Then
		Switch_Pages(gblConst.PAGE_MENU)
		Return False '--- cancel close request
	End If
	
	powerHelpers.ReleaseLocks
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)
	Return True '--- exit app
	
End Sub

Private Sub B4XPage_Appear
End Sub

Private Sub B4APage_Disappear
End Sub

Private Sub B4XPages_Foreground
End Sub

Private Sub B4XPages_Background
End Sub
#end region

Private Sub Build_GUI
	
	pnlMaster.Color = clrTheme.Background
	pnlHeader.Color	 = clrTheme.BackgroundHeader
	
	'--- hide all page views
	guiHelpers.HidePageParentObjs(Array As B4XView(pnlMenu,pnlFiles,pnlMovement))
	
	guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
	Switch_Pages(gblConst.PAGE_MENU)
	
End Sub


Public Sub HideSplash_StartUp
	
	TryOctoConnection
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
	
	guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
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
		PopupMainMenu
	Else
		Switch_Pages(gblConst.PAGE_MENU) '--- back key, go to main menu
	End If
End Sub


Public Sub Switch_Pages(action As String)
	'--- called from menu page class and back button
	
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
	toast.Show(msg)
End Sub

#Region "POPUP_MAIN_SETUP_MENU"
Private Sub PopupMainMenu
	
	Dim o As mnuPopup
	Dim popUpMemuItems As Map = _
		CreateMap("General Settings":"gn","Power Settings":"pw","Octoprint Connection":"oc", _
				  "Sonoff Connection":"snf","About":"ab")
		
	If oc.isPrinting Or oc.IsPaused2 Then
		Show_toast("Cannot Change OctoPrint Settings While Printing",2500)
		popUpMemuItems.Remove("Octoprint Connection") 
	End If
	Sleep(20)
	 
	o.Initialize(Me,"Setup",Me,popUpMemuItems,btnPageAction,"Options")
	o.MenuWidth = 260dip '--- defaults to 100
	o.ItemHeight = 56dip

	o.MenuObj.OrientationVertical = o.MenuObj.OrientationHorizontal_LEFT '--- change menu position
	
	Dim top As Float
	If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
		top = 21%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		top = 26%y
	Else
		top = 8%y
	End If
	
	o.MenuObj.OpenMenuAdvanced((50%x - 130dip) ,top,260dip)
	
End Sub


Private Sub Setup_Closed (index As Int, tag As Object)
	
	Try
		Select Case tag.As(String)
			
			Case "ab" '--- about
				Dim msg As String = guiHelpers.GetAboutText()
				Dim mb As dlgMsgBox : mb.Initialize(Root,"About",560dip, 200dip)
				Wait For (mb.Show(msg,"splash.png","OK","","")) Complete (res As Int)
				
				
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
				
			Case "snf"  '--- sonoff setup
				Dim oA As dlgSonoffSetup
				oA.Initialize(Me,"Sonoff Connection")
				oA.Show
			
		End Select
		
	Catch
		Log(LastException)
	End Try
	
End Sub

'--- callled from dlgOctoSetup on exit
Public Sub PrinterSetup_Closed

	If oc.IsOctoConnectionVarsValid Then
		TryOctoConnection
	End If
	Sleep(100)
	guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
End Sub


#end region

Public Sub CallSetupErrorConnecting(connectedButError As Boolean)

	CallSub2(Main,"TurnOnOff_MainTmr",False)
	CallSub2(Main,"TurnOnOff_ScreenTmr",False)
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	
	Dim Msg As StringBuilder : Msg.Initialize
	
	If connectedButError Then
		Msg.Append("Connected to Octoprint but there is an error.").Append(CRLF)
		Msg.Append("Check that Octoprint is connected to the printer?").Append(CRLF)
		Msg.Append("Make sure you can print from the Octoprint UI.")
	Else
		Msg.Append("No connection to Octoprint").Append(CRLF)
		Msg.Append("Is Octoprint turned on?")
		Msg.Append(CRLF).Append("Connected to the printer?")
	End If
	
	Dim mb As dlgMsgBox : mb.Initialize(Root,"Connetion Problem",560dip, 180dip)
	Dim IsPowerCtrl As String = ""
	Wait For (mb.Show(Msg.ToString,gblConst.MB_ICON_WARNING,"Retry",IsPowerCtrl,"")) Complete (res As Int)
	
	Select Case res
		Case xui.DialogResponse_Positive '--- retry
			oMasterController.Start
		Case xui.DialogResponse_Cancel	 '--- run setup
			Setup_Closed(0,"oc")
		Case xui.DialogResponse_Negative '--- Power on 
			
	End Select
	
	ConfigPowerOption

End Sub

Private Sub ConfigPowerOption
	
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



