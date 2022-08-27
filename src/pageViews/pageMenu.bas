B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region

Sub Class_Globals
	Private Const mModule As String = "pageMenu" 'ignore
	Private xui As XUI
	Private mPnlMain As B4XView
	Private mCallBackEvent As String
	Private mMainObj As B4XMainPage'ignore
	
	'--- menu icons
	Private mnuFiles As B4XView
	Private mnuMovement As B4XView
	Private mnuPrinting As B4XView
	
	Public Dialog As B4XDialog
	
	Private btnScrnOff,btnBrightness As B4XView
	Private btnSonoff As B4XView
End Sub


Public Sub Initialize(masterPanel As B4XView,callBackEvent As String) 
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageMenu")
	
	Build_GUI
	
End Sub


public Sub Set_focus()
	
	mPnlMain.Visible = True
	
	'--- set bottom action btn if visible
	btnBrightness.Visible = config.ChangeBrightnessSettingsFLAG
	btnScrnOff.Visible    = config.ShowScreenOffFLAG
	If btnBrightness.Visible = False And btnScrnOff.Visible = True Then
		btnScrnOff.Left = btnBrightness.Left
	else If btnBrightness.Visible = True And btnScrnOff.Visible = True Then
		btnScrnOff.Left = btnBrightness.Left - (60dip + IIf(guiHelpers.gScreenSizeAprox < 5.4,0dip,10dip))
	End If
	
	btnSonoff.Visible = config.SonoffFLAG
	
End Sub


public Sub Lost_focus()
	mPnlMain.Visible = False
End Sub


Private Sub Build_GUI
	
	'--- build the main menu screen
	BuildMenuCard(mnuMovement,"menuMovement.png","Move",gblConst.PAGE_MOVEMENT)
	BuildMenuCard(mnuFiles,"menuFiles.png","Files",gblConst.PAGE_FILES)
	BuildMenuCard(mnuPrinting,"menuPrint.png","Printing",gblConst.PAGE_PRINTING)
	
	guiHelpers.SetTextColor(Array As B4XView(btnSonoff,btnScrnOff,btnBrightness))
	
End Sub


Private Sub BuildMenuCard(mnuPanel As Panel,imgFile As String, Text As String, mnuAction As String)
	
	'mnuPanel.SetLayoutAnimated(0,0,0,mnuPanel.Width,mnuPanel.Height)
	mnuPanel.LoadLayout("menuCard")
	For Each v As View In mnuPanel.GetAllViewsRecursive
		
		If v.Tag <> Null Then
			If v.Tag Is lmB4XImageViewX Then
				Dim o1 As lmB4XImageViewX = v.Tag
				o1.Load(File.DirAssets,imgFile)
				o1.Tag2 = mnuAction '--- set menu action
				
			else if v.Tag Is AutoTextSizeLabel Then
				Dim o6 As AutoTextSizeLabel = v.Tag
				o6.Text = Text
				
			End If
		End If
		
	Next
	
End Sub


Private Sub mnuCardImg_Click
	
	'--- pass the menu selection back to main page
	Dim oo As lmB4XImageViewX : oo = Sender
	Sleep(50)
	CallSub2(mMainObj,mCallBackEvent,oo.Tag2)
	
End Sub


#Region "BRIGHTNESS BTN"
Private Sub DoBrightnessDlg
	
	Dim o1 As dlgBrightness
	o1.Initialize(mMainObj,"Screen Brightness",Me,"Brightness_Change")
	o1.Show(IIf(powerHelpers.pScreenBrightness < 0.05,0.1,powerHelpers.pScreenBrightness) * 100)
	
End Sub
Private Sub Brightness_Change(value As Float)
	
	'--- callback for btnBrightness_Click
	Dim v As Float = value / 100
	powerHelpers.SetScreenBrightnessAndSave(v,True) 
	powerHelpers.pScreenBrightness = v
	
End Sub

#end region


Private Sub btnSubBtnAction_Click
	Dim o As B4XView : o = Sender
	Select Case o.Tag
		Case "br" '--- brightness
			DoBrightnessDlg
			
		Case "soff" '--- screen off
			CallSub2(Main,"TurnOnOff_ScreenTmr",False)
			fnc.BlankScreen
			
		Case "snof" '--- Sonoff crap
			Dim o1 As dlgSonoffCtrl
			o1.Initialize(mMainObj,"Sonoff Control")
			o1.Show
				
	End Select
	
End Sub






