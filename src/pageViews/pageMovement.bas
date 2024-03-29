﻿B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.1 	Aug/7/2022  - Kherson Ukraine
'			Added code to bal file for larger screen size
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "pageMovement" 'ignore
	Private xui As XUI
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private mMainObj As B4XMainPage
	Private fp As sadAS_FloatingPanel
	
	Private MoveJogSize As String
	Private ExtruderLengthSize As Int = 10
	
	Private pnlJogMovement As B4XView
	Private pnlGeneral As B4XView
	
	Private btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength As Button
	Private btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback As Button
	Private btnZup,btnZhome,btnZdown As Button
	
	Private lblGeneral,lblHeaderZ,lblHeaderXY As B4XView
	Private mPageEnableDisable As Boolean
	
	Private pnlGeneral2,pnlGeneral1 As Panel
	Private pnlJogMovement1 As Panel
	Private btnMoveMM0 As Button
	Private btnMoveMM1 As Button
	Private btnMoveMM2 As Button
	Private btnMoveMM3 As Button
	Private lblMovePopup As Label
	Private pnlMoveMM As B4XView
End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageMovement")
	
	Build_GUI
	
End Sub

public Sub Set_focus()
	mPnlMain.SetVisibleAnimated(500,True)
	mPnlMain.Enabled = oc.isConnected
	Update_Printer_Btns
End Sub

public Sub Lost_focus()
	mPnlMain.SetVisibleAnimated(500,False)
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
End Sub

Private Sub Build_GUI
	
	fp.Initialize(Me,"fp",B4XPages.MainPage.Root)
	fp.PreSize(260dip, 210dip)
	fp.Panel.LoadLayout("viewMovementMM")
	fp.ArrowVisible = False
	'fp.ArrowProperties.Left = lblMovePopup.Height/2
	'fp.ArrowProperties.ArrowOrientation = fp.ArrowOrientation_Left
	
	
	guiHelpers.SkinButton(Array As Button(btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength, _
																btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback, _
																btnZup,btnZhome,btnZdown,btnMoveMM0,btnMoveMM1,btnMoveMM2,btnMoveMM3))
	
	'Log(guiHelpers.gScreenSizeAprox)
	If guiHelpers.gScreenSizeAprox < 5.1 Then
		Dim bs As Float = btnExtrude.TextSize - 2
		guiHelpers.SetTextSize(Array As Button(btnRetract,btnMOff,btnExtrude),bs)
	End If
	guiHelpers.SetTextColor(Array As B4XView(lblGeneral,lblHeaderZ,lblHeaderXY,lblMovePopup))
	guiHelpers.ResizeText("General",lblGeneral)
	guiHelpers.ResizeText("Z",lblHeaderZ)
	guiHelpers.ResizeText("X/Y",lblHeaderXY)
	Sleep(0)
	
	'--- sync btns with already adusted btns
	For Each btn As Button In Array As B4XView(btnXYleft,btnXYright,btnZhome,btnZup,btnZdown)
		btn.Height = btnXYhome.Height
	Next
	btnXYleft.Top = btnXYhome.Top : btnXYright.Top = btnXYhome.Top : btnZhome.Top = btnXYhome.Top
	btnZdown.Top = btnXYforward.Top : btnZup.Top = btnXYback.Top
	btnZdown.Top = btnXYforward.Top : btnZup.Top = btnXYback.Top
	
	
	lblMovePopup.Top = btnXYforward.Top +btnXYforward.Height / 2
	pnlMoveMM.SetColorAndBorder(clrTheme.BackgroundHeader,1dip,clrTheme.txtNormal,8dip)
	
	MoveJogSize = "10"
	lblMovePopup.Text = "10mm"
	
End Sub


public Sub Update_Printer_Btns
	
	'--- sets enable, disable
	mPageEnableDisable = IIf(oc.isPrinting,False,True)
	If oc.IsPaused2 And File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE).GetDefault("mpsd",False).As(Boolean) Then '--- over ride flag to show movement screen when paused
		mPageEnableDisable = True
		If oc.JobPrintState = "Resuming" Then mPageEnableDisable = False
	End If
		
	guiHelpers.EnableDisableBtns2(Array As Button( _
				btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength, _
				btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback, _
				btnZup,btnZhome,btnZdown), mPageEnableDisable)
				
	'cboMovementSize.cmbBox.Enabled = mPageEnableDisable
	mPnlMain.Enabled = oc.isConnected
	
End Sub

'Public Sub Update_Printer_Temps
'
'	
'	
'	'--- TODO, strip the 'C' of the temps and just use degree symbol
'	'--- TODO, strip the 'C' of the temps and just use degree symbol
'	'--- TODO, strip the 'C' of the temps and just use degree symbol
'	
'End Sub


Private Sub btnGeneral_Click
	
	Dim o As B4XView : o = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Then Return
	
	'--- Check over-ride movement flag	
'	If oc.JobPrintState <> "Operational" And File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE).GetDefault("mpsd",False).As(Boolean) = False Then
'		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
'		Return
'	End If
	
	Select Case o.Tag
		Case "heat" 	: ToolHeatChangeRequest
		Case "elength" 	: SetExtruderLength
		Case "ext"		: ExtrudeRetract(True)
		Case "ret"		: ExtrudeRetract(False)
		Case "fmnu"		: FunctionMenu
		Case "moff"		: MotorsOff
	End Select
	
End Sub

Private Sub btnXYZ_Click
	
	Dim btn As B4XView : btn = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
'	If oc.isConnected = False Then Return
'		If oc.JobPrintState <> "Operational" Then
'		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
'		Return
'	End If
		
'	Log("PrinterProfileInvertedZ" & oc.PrinterProfileInvertedZ )
'	Log("PrinterProfileInvertedY" & oc.PrinterProfileInvertedy )
'	Log("PrinterProfileInvertedX" & oc.PrinterProfileInvertedx )
	
	Select Case btn.Tag
		
		Case "Zhome"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_Z_HOME)
		Case "XYhome"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_XY_HOME)
		Case "Zup"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedZ,"-","")}"$ & MoveJogSize).Replace("!DIR!","z"))
		Case "Zdown"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedZ,"","-")}"$ & MoveJogSize).Replace("!DIR!","z"))
		Case "XYleft"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedX,"","-")}"$ & MoveJogSize).Replace("!DIR!","x"))
		Case "XYright"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedX,"-","")}"$ & MoveJogSize).Replace("!DIR!","x"))
		Case "XYforward"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedY,"","-")}"$ & MoveJogSize).Replace("!DIR!","y"))
		Case "XYback"
			mMainObj.oMasterController.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedY,"-","")}"$ & MoveJogSize).Replace("!DIR!","y"))
	
	End Select
	guiHelpers.Show_toast("Command Sent",1200)
	
End Sub

#if klipper
Private Sub SendRelPosCmd
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!",oc.gcodeRelPos))
End Sub
#End If

Private Sub ToolHeatChangeRequest
	
	Dim oo As HeaterRoutines : oo.Initialize
	oo.PopupToolHeaterMenu
	
End Sub

#region "EXTRUDER_LENGTH_EDIT"
Private Sub SetExtruderLength
		
	Dim o1 As dlgNumericInput
	o1.Initialize("Extruder Length","Enter Length",Me,"ExtruderLength_Set")
	o1.Show
	
End Sub
Private Sub ExtruderLength_Set(value As String)
	
	'--- callback for SetExtruderLength
	If value.Length = 0 Then Return
	
	ExtruderLengthSize = value
	btnLength.Text = ExtruderLengthSize.As(String) & "mm"
		
End Sub
#end region


#Region "FUNCTION - WIZ MENU IN MOVMENT PANEL"
Private Sub FunctionMenu
	
	Dim o1 As dlgListbox
	mMainObj.pObjCurrentDlg1 = o1.Initialize("Function Menu",Me,"FunctionMenu_Event",mMainObj.pObjCurrentDlg1)
	Dim w As Float = 320dip
	If guiHelpers.gIsLandScape = False And guiHelpers.gScreenSizeAprox < 4.5 Then w = guiHelpers.gWidth * .9
	o1.IsMenu = True
	o1.Show(250dip,w,BuildFunctionMnu)
	
End Sub


Private Sub BuildFunctionMnu() As Map
	Dim m As Map : m.Initialize
	m.Put("Pre-Heat Menu","prh")
	m.Put("Cooling Fan Menu","clf")
	
	If config.ReadManualBedScrewLevelFLAG 	Then m.Put("Manual Bed Leveling Wizard","blw")
	If config.ReadWizardFilamentChangeFLAG  Then m.Put("Change Filament Wizard","cf")
	If config.ReadBLCRtouchFLAG     		Then m.Put("BL/CR Touch Probe Testing","blcr")
	If config.ReadZOffsetFLAG 				Then m.Put("Set Z Offset For Auto Bed Leveling)","zo")
	If config.ReadManualBedMeshLevelFLAG	Then m.Put("Manual Mesh Bed Leveling Wizard","mblw")
	
	For jj =0 To 7
		Dim f As String = jj & gblConst.GCODE_CUSTOM_SETUP_FILE
		Dim da As Map = File.ReadMap(xui.DefaultFolder,f)
		If da.Get("wmenu").As(Boolean) = True Then
			m.Put(da.Get("desc"),"f" & jj)
		End If
	Next
	Return m
End Sub

Private Sub FunctionMenu_Event(value As String, tag As Object)
	
	'--- callback for Function Menu
	B4XPages.MainPage.pObjCurrentDlg1 = Null
	If value.Length = 0 Then Return
	Dim msg As String = "Command sent: " 'ignore
	Dim mb As dlgMsgBox 
	mb.Initialize(mMainObj.root,"Continue",IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth-40dip), 200dip,False)
	Dim Ask As String = "Touch OK to continue" 'ignore
	
	Select Case value
		Case "clf"
			CallSub(B4XPages.MainPage,"Cooling_Fan")
			
		Case "f0","f1","f2","f3","f4","f5","f6","f7"
			CallSubDelayed2(mMainObj,"RunGCodeOnOff_Menu",value.As(String).Replace("f","") & gblConst.GCODE_CUSTOM_SETUP_FILE)
			
		Case "zo" '--- Z offset
			Dim bm As dlgBedLevelMeshWiz2
			mMainObj.pobjWizards = bm.Initialize(mMainObj.pnlWizards,value)'--- value tells class z-offset or mesh
			bm.Show("Set Z Offset Wizard")
			
		Case "mblw"
			Dim bm As dlgBedLevelMeshWiz2
			mMainObj.pobjWizards = bm.Initialize(mMainObj.pnlWizards,value) '--- value tells class z-offset or mesh
			bm.Show("Mesh Bed Leveling Wizard")
		
		Case "blw"
			Dim uu As dlgBedLevelManualWiz
			mMainObj.pobjWizards = uu.Initialize(mMainObj.pnlWizards)
			uu.Show
			
		Case "cf"'--- built in load / unload filament wiz
			Dim o1 As dlgFilamentCtrl
			Dim AreWeInTheMiddleOfPrint As Boolean = True
			If oc.JobPrintState.EqualsIgnoreCase("Operational") Then AreWeInTheMiddleOfPrint = False
			mMainObj.pObjCurrentDlg2 = o1.Initialize(AreWeInTheMiddleOfPrint)
			o1.Show
			
		Case "prh" '--- pre-heat menu
			CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
			
		Case "blcr"
			BLCR_TouchMenu
			
		Case Else
			msg = " ...TODO... "
			
	End Select
	
End Sub

#end region

#Region "Send Btn GCODE"
Private Sub ExtrudeRetract(Extrude As Boolean)
	
	If oc.Tool1ActualReal < 150 Then
		guiHelpers.Show_toast("Tool is not hot enough",1800)
		Return
	End If
	
	#if klipper
	SendRelPosCmd
	Dim pp As String = oc.cPOST_GCODE.Replace("!G!","G1 E" & IIf(Extrude,"","-") & ExtruderLengthSize & "F150")
	mMainObj.oMasterController.cn.PostRequest(pp)
	guiHelpers.Show_toast(IIf(Extrude,"Extrusion","Retraction") & ": " & ExtruderLengthSize & "mm",1200)
	#else
	mMainObj.oMasterController.cn.PostRequest(oc.cCMD_TOOL_EXTRUDE_RETRACT.Replace("!LEN!", IIf(Extrude,"","-") & ExtruderLengthSize))
	guiHelpers.Show_toast(IIf(Extrude,"Extrusion","Retraction") & ": " & ExtruderLengthSize & "mm",1200)
	#End If
	
End Sub

Private Sub MotorsOff
	'--- DISABLE_ALL_STEPPERS
	#if klipper
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M18"))
	#else
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!","M18"))
	#End If
	
	guiHelpers.Show_toast("Command sent: Motors Off",1800)
End Sub
#end region

Private Sub lblMovePopup_Click
	Dim Top As Float
	If guiHelpers.gIsLandScape Then
		Top = lblMovePopup.Top - (pnlMoveMM.Height/2)
		fp.OpenOrientation = fp.OpenOrientation_BottomTop
	Else
		Top = lblMovePopup.Top + lblMovePopup.Height + 10dip
		fp.OpenOrientation = fp.OpenOrientation_LeftTop
	End If
	fp.Show(lblMovePopup.Left,Top, pnlMoveMM.Width,pnlMoveMM.Height)
End Sub

Private Sub btnJogMoveMM_Click
	Dim o As Button = Sender
	MoveJogSize = o.Text.Replace("mm","")
	lblMovePopup.Text = o.Text
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	fp.Close '--- close floating panel
End Sub



#Region BLCRtouchMenu/CR Touch MENU"
Private Sub BLCR_TouchMenu
	
	Dim o2 As dlgBLTouchActions
	mMainObj.pObjCurrentDlg1 = o2.Initialize
	o2.Show
	
End Sub



#end region