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
	Private pageSetup As B4XSetupPage
	
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
	
	'--- master parent used for all templates dialogs
	Public Dialog As B4XDialog 
	
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
	logMe.Init(xui.DefaultFolder,"__OCTOTC__","log")
	clrTheme.Init("red")
	
	logMe.Clean_OldLogs
	
	powerHelpers.Init
	fnc.ProcessPowerFlags
	
End Sub

#Region "PAGE EVENTS"
Private Sub B4XPage_Created (Root1 As B4XView)

	Root = Root1
	Root.SetLayoutAnimated(0,0,0,Root.Width,Root.Height)
	Root.LoadLayout("MainPage")
	
	toast.Initialize(Root)
	
	'--- splash screen
	pnlMaster.Visible = False
	pnlSplash.Visible = True
		
	ConfigPowerOption
	Build_GUI
	
End Sub

Private Sub B4XPage_CloseRequest As ResumableSub
	
	'--- catch the android BACK button
	If oPageCurrent <> oPageMenu Then
		Switch_Pages(gblConst.PAGE_MENU)
		Return False '--- cancel close request
	End If
	
	Return True '--- exit app
End Sub

Private Sub B4XPage_Appear
End Sub

Private Sub B4APage_Disappear
End Sub

Private Sub B4XPages_Foreground
	Log("B4XPages_Foreground")
End Sub

Private Sub B4XPages_Background
End Sub
#end region

Private Sub Build_GUI
	
	pnlMaster.Color = clrTheme.Background
	pnlHeader.Color	 = clrTheme.BackgroundHeader
	
	'--- hide all page views
	guiHelpers.HidePageParentObjs(Array As B4XView(pnlMenu,pnlFiles,pnlMovement))
	
	'btnPageAction.TextSize = 48 'guiHelpers.btnResizeText(btnPageAction,False,28) + 2
	guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
	Switch_Pages(gblConst.PAGE_MENU)
	
End Sub


Public Sub HideSplash_StartUp
	
	pnlSplash.Visible = False
	pnlMaster.Visible = True
	TryOctoConnection
	
End Sub

Private Sub TryOctoConnection
	
	If oMasterController.IsInitialized = False Then 
		oMasterController.Initialize
	End If
	If fnc.ReadConnectionFile(oMasterController.CN) = False Then
		B4XPages.AddPage(gblConst.PAGE_SETUP, (pageSetup.Initialize(True)))
		B4XPages.ShowPage(gblConst.PAGE_SETUP)
	Else
		If oc.IsOctoConnectionVarsValid Then
			oMasterController.SetCallbackObj(Me,"Update_Printer_Temps","Update_Printer_Status","Update_Printer_Btns")
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
		'--- back key, go to main menu
		Switch_Pages(gblConst.PAGE_MENU)
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

#Region "POPUP_MAIN_MENU"
Private Sub PopupMainMenu
	
	Dim o As mnuPopup
	Dim popUpMemuItems As Map = CreateMap("General Settings":"gn","Power Settings":"pw","Octoprint Connection":"oc","Logging - Debuging":"log","About":"ab")
	If oc.isPrinting Or oc.IsPaused2 Then
		Show_toast("Cannot Change OctoPrint Settings While Printing",2500)
		popUpMemuItems.Remove("Octoprint Connection") 
	End If
	Sleep(400)
	 
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
				Dim sf As Object = xui.Msgbox2Async(msg, "About", "OK", "", "", Null)
				Wait For (sf) Msgbox_Result (result1 As Int)
				' TODO, change to a panel with more info
				
		
			Case "gn"  '--- general settings
				toast.Show("Not done")
				'https://www.b4x.com/android/forum/threads/immersive-mode-hide-the-navigation-bar.90882/
				'V4.4 and above, add it to the general settings
				'V4.0-3  just dim the bar
			
			Case "oc"  '--- octo setup
				If pageSetup.IsInitialized = False Then
					B4XPages.AddPage(gblConst.PAGE_SETUP, (pageSetup.Initialize(False)))
				End If
				B4XPages.ShowPage(gblConst.PAGE_SETUP)
			
			Case "pw"  '--- android power setup
				Dim o1 As dlgPower
				o1.Initialize(Me)
				o1.Show
			
			Case "log"  '--- logging
				toast.Show("Needs work")
				'Dim o As dlgLogging
				'o.Initialize(Me)
				'o.Show
			
		End Select
		
	Catch
		Log(LastException)
	End Try
	
End Sub

'--- callled from B4XSetupPage on exit
Public Sub PrinterSetup_Closed(NewConfig As Boolean)

	If oc.IsOctoConnectionVarsValid Then
		TryOctoConnection
	End If
	guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
End Sub
#end region


Private Sub ConfigPowerOption
	
	If config.AndroidTakeOverSleepFLAG = False Then 
		'--- power options not configured
		powerHelpers.ScreenON(False)
		Return 
	End If
		
	'--- turn the screen on
	powerHelpers.ScreenON(True)
	
End Sub








