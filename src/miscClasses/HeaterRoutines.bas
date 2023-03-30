B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0	Feb/01/2023
#End Region

Sub Class_Globals
	Private mMainObj As B4XMainPage'ignore
End Sub

Public Sub Initialize
	mMainObj = B4XPages.MainPage
End Sub


Public Sub PopupToolHeaterMenu
	
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,"Tool Presets",Me,"HeatTempChange_Tool")
	o1.Show(250dip,220dip,mMainObj.oMasterController.mapToolHeatValuesOnly)
	
End Sub
Private Sub HeatTempChange_Tool(value As String, tag As String)
	
	'--- callback for HeatChangeRequest
	If value.Length = 0 Then Return
	
	If value = "ev" Then
		'--- type in a value
		'Dim oo As HeaterRoutines : oo.Initialize
		'oo.ChangeTempTool
		ChangeTempTool
		Return
	End If
	
	If value.EndsWith("off") Then value = 0 '--- tool off
	
	If fnc.CheckTempRange("tool", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If

	#if klipper
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M104 S" & value))
	#else
	mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))		
	#End If
	
		
	guiHelpers.Show_toast("Tool Temperature Change",1400)
	
End Sub


'--------------------------------------------------------------------
'------------------ Enter Temp dialogs ------------------------------
'--------------------------------------------------------------------
Public Sub ChangeTempTool
	TempChangePrompt("tool")
End Sub
Public Sub ChangeTempBed
	TempChangePrompt("bed")
End Sub

Private Sub TempChangePrompt(what As String)
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Or oc.isPrinting Or oc.IsPaused2 Then Return
	
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj, _
		IIf(what = "bed","Bed Temperature","Tool Temperature"), _
		"Enter Temperature",Me, _
		IIf(what = "bed","TempChange_Bed","TempChange_Tool1"))
		
	o1.Show
	
End Sub

Private Sub TempChange_Tool1(value As String)
	
	'--- callback for TempChangePrompt
	'--- callback for TempChangePrompt
	If value.Length = 0 Then Return
	If fnc.CheckTempRange("tool", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.oMasterController.cn.PostRequest( _
		oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))
		
	guiHelpers.Show_toast("Tool Temperature Change",1400)
	
End Sub


Private Sub TempChange_Bed(value As String)
	
	'--- callback for TempChangePrompt
	'--- callback for TempChangePrompt
	If value = "" Then Return
	If fnc.CheckTempRange("bed", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",value))
	guiHelpers.Show_toast("Bed Temperature Change",1400)
	
End Sub





