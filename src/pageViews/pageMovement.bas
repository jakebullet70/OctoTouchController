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
	
	Private btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength As B4XView
	Private btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback As B4XView
	Private btnZup,btnZhome,btnZdown As B4XView
	
	Private lblGeneral,lblHeaderZ,lblHeaderXY As B4XView
	
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
End Sub


Private Sub Build_GUI
	
	'--- movement / jog sizes
	Dim options As List : options.initialize2(Array As String("0.1mm","1.0mm","10mm","100mm"))
	cboMovementSize.setitems(options)
	cboMovementSize.SelectedIndex = 1
	cboMovementSize.cmbBox.TextColor = clrTheme.txtNormal
	cboMovementSize.cmbBox.Color = clrTheme.BackgroundHeader
	cboMovementSize.cmbBox.DropdownBackgroundColor = clrTheme.BackgroundHeader
	cboMovementSize.cmbBox.DropdownTextColor = clrTheme.txtNormal
	MoveJogSize = "1.0"
	
	guiHelpers.SetTextColor(Array As B4XView(lblGeneral,lblHeaderZ,lblHeaderXY))
	
End Sub


public Sub Update_Printer_Btns
	
	'--- sets enable, disable
	guiHelpers.EnableDisableBtns(Array As B4XView( _
		btnRetract,btnMOff,btnHeat,btnFN,btnExtrude,btnLength, _
		btnXYright,btnXYleft,btnXYhome,btnXYforward,btnXYback, _
		btnZup,btnZhome,btnZdown), _
		IIf(oc.isPrinting,False,True))
	
	mPnlMain.Enabled = oc.isConnected
	
End Sub



Private Sub btnGeneral_Click
	
	Dim o As B4XView : o = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Then Return
	
	If oc.JobPrintState <> "Operational" Then
		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
		Return
	End If
	
	Select Case o.Tag
		Case "heat" 	: HeatChangeRequest
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
	
	If oc.JobPrintState <> "Operational" Then
		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
		Return
	End If
	
	Select Case btn.Tag
		
		Case "Zhome"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_Z_HOME)
		Case "XYhome"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XY_HOME)
		Case "Zup"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedZ,"-","")}"$ & MoveJogSize).Replace("!DIR!","z"))
		Case "Zdown"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedZ,"","-")}"$ & MoveJogSize).Replace("!DIR!","z"))
		Case "XYleft"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","-" & MoveJogSize).Replace("!DIR!","x")) 'TODO, add inverted check code
		Case "XYright"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","" & MoveJogSize).Replace("!DIR!","x"))
		Case "XYforward"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","-" & MoveJogSize).Replace("!DIR!","y"))
		Case "XYback"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","" & MoveJogSize).Replace("!DIR!","y"))
	
	End Select
	guiHelpers.Show_toast("Command Sent",1200)
	
End Sub

Private Sub cboMovementSize_SelectedIndexChanged (Index As Int)
	MoveJogSize = cboMovementSize.SelectedItem.Replace("mm","")
End Sub

#region "HEAT_CHANGE_EDIT"
Private Sub TypeInHeatChangeRequest
		
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj,"Tool Temperature","Enter Temperature",Me,"HeatTempChange_ToolEdit")
	o1.Show
	
End Sub
Private Sub HeatTempChange_ToolEdit(value As String)
	'--- callback for TypeInHeatChangeRequest
	HeatTempChange_Tool(value,"")
End Sub

	
Private Sub HeatChangeRequest
	
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,"Tool Presets",Me,"HeatTempChange_Tool")
	o1.Show(250dip,220dip,mMainObj.MasterCtrlr.mapToolHeatValuesOnly)
	
End Sub
Private Sub HeatTempChange_Tool(value As String, tag As String)
	
	'--- callback for HeatChangeRequest
	If value.Length = 0 Then Return
	
	If value = "ev" Then
		'--- type in a value
		TypeInHeatChangeRequest
		Return
	End If
	
	If value.EndsWith("off") Then value = 0 '--- tool off
	
	If fnc.CheckTempRange("tool", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))
		
	guiHelpers.Show_toast("Tool Temperature Change",1400)
	
End Sub
#end region

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
	
'	Dim mapOptions As Map = CreateMap( _
'			"Auto Bed Leveling (G29)":"bl","Change filament (M600)":"cl","Load Filament":"lf","UnLoad Filament":"uf")
	Dim mapOptions As Map = CreateMap( _
			"Auto Bed Leveling (G29)":"bl","Change filament (M600)":"cfl")
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,"Function Menu",Me,"FunctionMenu_Event")
	o1.Show(250dip,320dip,mapOptions)
	
End Sub

Private Sub FunctionMenu_Event(value As String, tag As Object)
	
	'--- callback for Function Menu
	If value.Length = 0 Then Return
	Dim msg As String = "Command sent: "
	Dim mb As dlgMsgBox : mb.Initialize(mMainObj.root,"Continue",500dip, 200dip,False)
	Dim Ask As String = "Touch OK to continue"
	
	Select Case value
		Case "bl" '--- bed level
			Wait For (mb.Show(Ask,gblConst.MB_ICON_QUESTION,"OK","","CANCEL")) Complete (ret As Int)
			If ret = xui.DialogResponse_Cancel Then Return
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!","G29"))
			msg = msg & "Start Bed Leveling"
			
		Case "cfl" '--- Change filament
			Wait For (mb.Show(Ask,gblConst.MB_ICON_QUESTION,"OK","","CANCEL")) Complete (ret As Int)
			If ret = xui.DialogResponse_Cancel Then Return
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!","M600"))
			msg = msg & "Sending M600"
			
		Case Else
			msg = " ...TODO... "
			
	End Select
	guiHelpers.Show_toast(msg,3200)
	
	
End Sub

#end region



#Region "GCODE"
Private Sub ExtrudeRetract(Extrude As Boolean)
	
	If oc.Tool1ActualReal < 150 Then
		guiHelpers.Show_toast("Tool is not hot enough",1600)
		Return
	End If
	mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_TOOL_EXTRUDE_RETRACT.Replace("!LEN!", IIf(Extrude,"","-") & ExtruderLengthSize))
	guiHelpers.Show_toast(IIf(Extrude,"Extrusion","Retraction") & ": " & ExtruderLengthSize & "mm",1200)
	
End Sub

Private Sub MotorsOff
	'--- DISABLE_ALL_STEPPERS
	mMainObj.MasterCtrlr.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!","M18"))
	guiHelpers.Show_toast("Command sent: Motors Off",1800)
End Sub
#end region





