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
	
	'--- master parent obj used for all templates dialogs
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
	toast.DefaultTextColor = clrTheme.txtAccent
	
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
	powerHelpers.ActionBar_On
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
		B4XPages.AddPage(gblConst.PAGE_SETUP, (pageSetup.Initialize(True)))
		B4XPages.ShowPage(gblConst.PAGE_SETUP)
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
	Dim popUpMemuItems As Map = CreateMap("General Settings":"gn","Power Settings":"pw","Octoprint Connection":"oc","About":"ab")
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
		top = 22%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		top = 27%y
	Else
		top = 9%y
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
'				Dim mb As ASMsgBox : mb.Initialize(Me,"ASMsgBox")
'				sadMB(Me,mb,"About",msg,"INFO","","","OK",460dip,300dip)
'				Wait For ASMsgBox1_result(res As Int)
'				Wait For (mb.Close(True)) Complete (Closed As Boolean)
				
			Case "gn"  '--- general settings
				Dim o3 As dlgGeneral
				o3.Initialize(Me)
				o3.Show
			
				
			Case "oc"  '--- octo setup
				If pageSetup.IsInitialized = False Then
					B4XPages.AddPage(gblConst.PAGE_SETUP, (pageSetup.Initialize(False)))
				End If
				B4XPages.ShowPage(gblConst.PAGE_SETUP)
			
			Case "pw"  '--- android power setup
				Dim o1 As dlgPower
				o1.Initialize(Me)
				o1.Show
			
		End Select
		
	Catch
		Log(LastException)
	End Try
	
End Sub
#end region




Public Sub CallSetupErrorConnecting(connectedButError As Boolean)

	CallSub2(Main,"TurnOnOff_MainTmr",False)
	CallSub2(Main,"TurnOnOff_ScreenTmr",False)
	
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
	
	Dim sf As Object = xui.Msgbox2Async(Msg.ToString, "Connetion Problem", "Retry", "Setup", "", Null)
	guiHelpers.ThreeDMsgboxCorner(sf)
	Wait For (sf) Msgbox_Result (Result As Int)
	
	Select Case Result
		Case xui.DialogResponse_Positive '--- retry
			oMasterController.Start
		Case xui.DialogResponse_Cancel	 '--- run setup
			Setup_Closed(0,"oc")
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

'--- callled from B4XSetupPage on exit
Public Sub PrinterSetup_Closed(NewConfig As Boolean)

	If oc.IsOctoConnectionVarsValid Then
		TryOctoConnection
	End If
	guiHelpers.SetActionBtnColorIsConnected(btnPageAction)
	
End Sub



'
''icon = "INFO","QUES","STOP"
'public Sub sadMB(act As B4XView, ASMsgBox1 As ASMsgBox,headerTXT As String, bodyTXT As String, icon As String, _
'					btn1 As String, btn2 As String,btn3 As String, _
'					width As Float, height As Float) 
'		
'	Try
'	
'		Dim icon_file As String = ""
'	
'		ASMsgBox1.Initialize(act,"ASMsgBox1")
'		ASMsgBox1.InitializeWithoutDesigner(act.root,clrTheme.BackgroundMenu,True,True,False,460dip,300dip)
'		ASMsgBox1.InitializeBottom(btn1,btn2,btn3)
'		ASMsgBox1.HeaderColor = clrTheme.BackgroundHeader
'		ASMsgBox1.BottomColor = clrTheme.BackgroundHeader
'		ASMsgBox1.Header_Text = headerTXT
'		ASMsgBox1.Header_Font_Size = 28
'		ASMsgBox1.Icon_direction = "LEFT"
'		ASMsgBox1.Button3.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,5dip)
'		ASMsgBox1.Button2.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,5dip)
'		ASMsgBox1.Button1.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,5dip)
'	
'		Select Case icon
'			Case "INFO" : icon_file = "mb_info.png"
'			Case "QUES" : icon_file = "mb_question.png"
'			Case "STOP" : icon_file = "mb_stop.png"
'		End Select
'		
'		ASMsgBox1.icon_set_icon(xui.LoadBitmap(File.DirAssets,icon_file))
'		ASMsgBox1.CenterDialog(act)
'		ASMsgBox1.ShowWithText(bodyTXT,True)
'		
'	Catch
'		Log(LastException)
'	End Try
'	
'End Sub
'
'
'







