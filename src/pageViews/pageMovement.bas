B4A=true
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
	
	Private cboMovementSize As B4XComboBox
	Private MoveJogSize As String
	Private ExtruderLengthSize As Int = 10
	
	Private pnlJogMovement As B4XView
	Private pnlGeneral As B4XView
	
	Private btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength As Button
	Private btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback As Button
	Private btnZup,btnZhome,btnZdown As Button
	
	Private lblGeneral,lblHeaderZ,lblHeaderXY As B4XView
	Private mPageEnableDisable As Boolean
	
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
	
	guiHelpers.SkinButton(Array As Button(btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength, _
																btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback, _
																btnZup,btnZhome,btnZdown))
	
	'--- movement / jog sizes
	cboMovementSize.setitems(Array As String("0.1mm","1.0mm","10mm","100mm"))
	cboMovementSize.SelectedIndex = 1
	guiHelpers.ReSkinB4XComboBox(Array As B4XComboBox(cboMovementSize))

	MoveJogSize = "1.0"
	
	guiHelpers.SetTextColor(Array As B4XView(lblGeneral,lblHeaderZ,lblHeaderXY))
	
End Sub


public Sub Update_Printer_Btns
	
	#if klipper 
	If oc.isConnected = False Then
		CallSubDelayed2(mMainObj,"Switch_Pages",gblConst.PAGE_MENU)
		Return
	End If
	#End If
	
	'--- sets enable, disable
	mPageEnableDisable = IIf(oc.isPrinting,False,True)
	guiHelpers.EnableDisableBtns2(Array As Button( _
				btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength, _
				btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback, _
				btnZup,btnZhome,btnZdown), mPageEnableDisable)
				
	cboMovementSize.cmbBox.Enabled = mPageEnableDisable
	mPnlMain.Enabled = oc.isConnected
	
End Sub



Private Sub btnGeneral_Click
	
	Dim o As B4XView : o = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Then Return
	
	#if klipper
	If oc.JobPrintState.ToLowerCase <> "standby" Then
	#Else
	If oc.JobPrintState <> "Operational" Then
	#End If
		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
		Return
	End If
	
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
	
	If oc.isConnected = False Then Return
	
	#if klipper
	If oc.JobPrintState.ToLowerCase <> "standby" Then
	#Else
	If oc.JobPrintState <> "Operational" Then
	#End If
		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
		Return
	End If
		
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

Private Sub cboMovementSize_SelectedIndexChanged (Index As Int)
	
	MoveJogSize = cboMovementSize.SelectedItem.Replace("mm","")
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub

Private Sub ToolHeatChangeRequest
	
	Dim oo As HeaterRoutines : oo.Initialize
	oo.PopupToolHeaterMenu
	
End Sub

#region "EXTRUDER_LENGTH_EDIT"
Private Sub SetExtruderLength
		
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj,"Extruder Length","Enter Length",Me,"ExtruderLength_Set")
	o1.Show
	
End Sub
Private Sub ExtruderLength_Set(value As String)
	
	'--- callback for SetExtruderLength
	If value.Length = 0 Then Return
	
	ExtruderLengthSize = value
	btnLength.Text = ExtruderLengthSize.As(String) & "mm"
		
End Sub
#end region

#Region "FUNCTION_MENU"
private Sub FunctionMenu
	
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,"Function Menu",Me,"FunctionMenu_Event")
	o1.Show(250dip,320dip,BuildFunctionMnu)
	
End Sub

Private Sub BuildFunctionMnu() As Map
	Dim m As Map : m.Initialize
	m.Put("Pre-Heat Menu","prh")
	m.Put("Auto Bed Leveling (G29)","bl")
	If config.ShowBedLevelFLAG 	Then m.Put("Manual Bed Leveling","blw")
	If config.ShowFilamentChangeFLAG Then m.Put("Manual Change Filament","cf")
	Return m
End Sub

Private Sub FunctionMenu_Event(value As String, tag As Object)
	
	'--- callback for Function Menu
	If value.Length = 0 Then Return
	Dim msg As String = "Command sent: "
	Dim mb As dlgMsgBox 
	mb.Initialize(mMainObj.root,"Continue",IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth-40dip), 200dip,False)
	Dim Ask As String = "Touch OK to continue"
	
	Select Case value
		
		Case "blw"
			Dim uu As dlgBedLevelWiz
			uu.Initialize(mMainObj)
			uu.Show
			
		Case "bl" '--- firmware bed level
			Wait For (mb.Show(Ask,gblConst.MB_ICON_QUESTION,"OK","","CANCEL")) Complete (ret As Int)
			If ret = xui.DialogResponse_Cancel Then Return
			mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!","G29"))
			guiHelpers.Show_toast(msg & "Start Bed Leveling",3200)
			
'		Case "cfl" '--- Change filament through firmware
'			Wait For (mb.Show(Ask,gblConst.MB_ICON_QUESTION,"OK","","CANCEL")) Complete (ret As Int)
'			If ret = xui.DialogResponse_Cancel Then Return
'			mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!","M600"))
'			msg = msg & "Sending M600"
			
		Case "cf"'--- built in load / unload filament wiz
			Dim o1 As dlgFilamentCtrl
			o1.Initialize(mMainObj)
			o1.Show
			
		Case "prh" '--- pre-heat menu
			CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
			
		Case Else
			msg = " ...TODO... "
			
	End Select
	
End Sub

#end region



#Region "GCODE"
Private Sub ExtrudeRetract(Extrude As Boolean)
	
	If oc.Tool1ActualReal < 150 Then
		guiHelpers.Show_toast("Tool is not hot enough",1800)
		Return
	End If
	
	mMainObj.oMasterController.cn.PostRequest(oc.cCMD_TOOL_EXTRUDE_RETRACT.Replace("!LEN!", IIf(Extrude,"","-") & ExtruderLengthSize))
	guiHelpers.Show_toast(IIf(Extrude,"Extrusion","Retraction") & ": " & ExtruderLengthSize & "mm",1200)
	
End Sub

Private Sub MotorsOff
	'--- DISABLE_ALL_STEPPERS
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!","M18"))
	guiHelpers.Show_toast("Command sent: Motors Off",1800)
End Sub
#end region





