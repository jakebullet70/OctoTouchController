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
	
	Private btnScrnOff,btnBrightness As Button
	Private btnPlugin1,btnPlugin2,btnPlugin3 As Button
	
End Sub


Public Sub Initialize(masterPanel As B4XView,callBackEvent As String) 
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageMenu")
	
	BuildGUI
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"ShowVer",2300)
	
End Sub

Public Sub ShowVer
	guiHelpers.Show_toast("Version: V" & Application.VersionName,2200)
End Sub


Public Sub Set_focus()
	
	mPnlMain.SetVisibleAnimated(500,True)
	
	'--- set bottom action btn if visible
	btnBrightness.Visible = config.ChangeBrightnessSettingsFLAG
	btnScrnOff.Visible    = config.ShowScreenOffFLAG
	If btnBrightness.Visible = False And btnScrnOff.Visible = True Then
		btnScrnOff.Left = btnBrightness.Left
	else If btnBrightness.Visible = True And btnScrnOff.Visible = True Then
		btnScrnOff.Left = btnBrightness.Left - (btnBrightness.Width + IIf(guiHelpers.gScreenSizeAprox < 5.4,0dip,10dip))
	End If
	
	btnPlugin1.Visible = config.ShowWS281CtrlFLAG Or config.ShowZLEDCtrlFLAG
		
End Sub


Public Sub Lost_focus()
	mPnlMain.SetVisibleAnimated(500,False)
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
End Sub


Private Sub BuildGUI
	
	'--- build the main menu screen
	BuildMenuCard(mnuMovement,"menuMovement.png","Movement",gblConst.PAGE_MOVEMENT)
	BuildMenuCard(mnuFiles,"menuFiles.png","Files",gblConst.PAGE_FILES)
	BuildMenuCard(mnuPrinting,"menuPrint.png","Printing",gblConst.PAGE_PRINTING)
	
	guiHelpers.SetVisible(Array As B4XView(btnPlugin3,btnPlugin1),False)
	guiHelpers.SkinButton_Pugin(Array As Button(btnPlugin3,btnPlugin2,btnPlugin1,btnScrnOff,btnBrightness))

End Sub

Private Sub BuildMenuCard(mnuPanel As Panel,imgFile As String, Text As String, mnuAction As String)
	
	'mnuPanel.SetLayoutAnimated(0,0,0,mnuPanel.Width,mnuPanel.Height)
	mnuPanel.LoadLayout("menuCard")
	For Each v As View In mnuPanel.GetAllViewsRecursive
		
		If v.Tag <> Null Then
			If v.Tag Is lmB4XImageViewX Then
				Dim o1 As lmB4XImageViewX = v.Tag
				o1.mClickAnimationColor = clrTheme.txtAccent
				o1.Load(File.DirAssets,imgFile)
				o1.SetBitmap(guiHelpers.ChangeColorBasedOnAlphaLevel(o1.Bitmap,clrTheme.txtNormal))
				o1.Tag2 = mnuAction '--- set menu action
				
			else if v.Tag Is AutoTextSizeLabel Then
				Dim o6 As AutoTextSizeLabel = v.Tag
				o6.Text = Text
				o6.TextColor = clrTheme.txtNormal
				
			End If
		End If
		
	Next
	
End Sub


Private Sub mnuCardImg_Click
	
	If oc.isConnected = False Then 
		guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
		Return
	End If
	
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

' small action buttons on main menu
Private Sub btnSubBtnAction_Click
	
	Dim o As B4XView : o = Sender
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	Select Case o.Tag
		Case "br" '--- brightness
			DoBrightnessDlg
			
		Case "soff" '--- screen off
			CallSub2(Main,"TurnOnOff_ScreenTmr",False)
			fnc.BlankScreen
			
		Case "snof" '--- Sonoff / power crap
			If oc.isConnected = False And Starter.kvs.GetDefault(gblConst.PWR_SONOFF_PLUGIN,False).As(Boolean) = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			Dim o1 As dlgPsuCtrl
			o1.Initialize(mMainObj)
			o1.Show
			
		Case "lt" '--- WLED - ws281x
			If oc.isConnected = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			Dim o3 As dlgOnOffCtrl
			o3.Initialize(mMainObj,IIf(config.ShowZLEDCtrlFLAG,"ZLED","WS281x") & " Control")
			o3.Show
			
		Case "phe" '--- pre-heat
			If oc.isConnected = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			If oc.isPrinting Then 
				guiHelpers.Show_toast("Printer is busy",2000)
			Else
				CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
			End If
				
	End Select
	
End Sub


