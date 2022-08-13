B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/5/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "pagePrinting" 'ignore
	Private xui As XUI
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private mMainObj As B4XMainPage'ignore

	Private lblToolTemp, lblBedTemp As Label
	Private mapBedHeatingOptions, mapToolHeatingOptions,mapAllHeatingOptions As Map
	
	Private btnPresetMaster As B4XView
	Private btnPresetBed As Button
	Private btnPresetTool As Button
End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pagePrinting")
	
	Build_GUI
	
End Sub

public Sub Set_focus()
	mPnlMain.Visible = True
End Sub

public Sub Lost_focus()
	mPnlMain.Visible = False
End Sub


Private Sub Build_GUI
	
	If mMainObj.MasterCtrlr.gMapOctoTempSettings.IsInitialized = False Then
		Log("gMapOctoTempSettings IS NOT SET!")
	Else
		Build_PresetHeaterOption(mMainObj.MasterCtrlr.gMapOctoTempSettings)
	End If
	
End Sub


public Sub Update_Printer_Btns
	'--- sets enable, disable
	
End Sub

Public Sub Update_Printer_Stats
	'--- update printer job
	
End Sub

Public Sub Update_Printer_Temps
	'--- temps
	lblToolTemp.Text = IIf(oc.tool1Target = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.tool1Target)
	lblBedTemp.Text = IIf(oc.BedTarget = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.BedTarget)
End Sub


Private Sub btnPresetMaster_Click
	
	If oc.isConnected = False Then Return
	Dim o As mnuHeatersAll
	o.Initialize(mMainObj,mapAllHeatingOptions,btnPresetMaster)
	o.Show
	
End Sub



Private Sub btnPresetTemp_Click
	
	If oc.isConnected = False Then Return
	
	Dim o As Button : o = Sender
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,IIf(o.tag = "tool","Tool Presets","Bed Presets"),Me,"TempChange_Presets")
	o1.Tag = o.tag
	o1.Show(IIf(guiHelpers.gScreenSizeAprox >= 6,280dip,280dip),290dip, _
	    	IIf(o.Tag = "tool",mapToolHeatingOptions,mapBedHeatingOptions))
	
End Sub


Private Sub TempChange_Presets(selectedMsg As String, tag As Object)
	
	'--- callback for btnPresetTemp_Click
	If selectedMsg.Length = 0 Then Return
	
	If selectedMsg = "alloff" Then
		mMainObj.MasterCtrlr.AllHeaters_Off
		guiHelpers.Show_toast("Tool / Bed Off",1200)
		Return
	End If
	
	Dim tagme As String = tag.As(String)
	Dim msg As String
	
	Log(selectedMsg)
	Select Case True
		
		Case selectedMsg.EndsWith("off")
			If tagme = "bed" Then
				mMainObj.MasterCtrlr.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",0))
				msg = "Bed Off"
			Else
				mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
				msg = "Tool Off"	
			End If
			
		Case selectedMsg.Contains("Tool") And Not (selectedMsg.Contains("Bed"))
			'--- Example, Set PLA (Tool: 60øC )
			Dim startNDX As Int = selectedMsg.IndexOf(": ")
			Dim endNDX As Int = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			Dim getTemp As String = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
			
		Case selectedMsg.Contains("Bed") And Not (selectedMsg.Contains("Tool"))
			'--- Example, PLA (Bed: 60øC )
			Dim startNDX As Int = selectedMsg.IndexOf(": ")
			Dim endNDX As Int = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			Dim getTemp As String = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			mMainObj.MasterCtrlr.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
		
	End Select
	
	guiHelpers.Show_toast(msg,3000)
	
End Sub

#region "TEMP_CHANGE_EDIT"
Private Sub lblTempChange_Click
	
	If oc.isConnected = False Then Return
	Dim o As Label : o = Sender
	
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj, _
		IIf(o.Tag = "bed","Bed Temperature","Tool Temperature"),"Enter Temperature",Me, _
		IIf(o.Tag = "bed","TempChange_Bed","TempChange_Tool1"))
		
	o1.Show
	
End Sub

Private Sub TempChange_Bed(value As String)
	
	'--- callback for lblTempChange_Click
	If value = "" Then Return
	If fnc.CheckTempRange("bed", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",value))
	guiHelpers.Show_toast("Bed Temperature Change",1400)
	
End Sub

Private Sub TempChange_Tool1(value As String)
	
	'--- callback for lblTempChange_Click
	If value.Length = 0 Then Return
	If fnc.CheckTempRange("tool", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))
		
	guiHelpers.Show_toast("Tool Temperature Change",1400)
	
End Sub
#end region

public Sub Build_PresetHeaterOption(mapOfOptions As Map)
	
	'--- clear them out
	mapBedHeatingOptions.Initialize
	mapToolHeatingOptions.Initialize
	mapAllHeatingOptions.Initialize
		
	Dim allOff As String = "** All Off **"

	mapBedHeatingOptions.Put(allOff,"alloff")
	mapBedHeatingOptions.Put("Bed Off","bedoff")
	
	mapToolHeatingOptions.Put(allOff,"alloff")
	mapToolHeatingOptions.Put("Tool Off","tooloff")
		
	mapAllHeatingOptions.Put(allOff,"alloff")
	
	Dim cboStr As String
	Dim FilamentType As String
	Dim tmp,ToolTemp As String
	Dim BedTemp As String
	
	Try
		For x  = 0 To mapOfOptions.Size - 1
		
			FilamentType = mapOfOptions.GetKeyAt(x)
			tmp = mapOfOptions.GetValueAt(x)
			ToolTemp = Regex.Split("!!",tmp)(0)
			BedTemp = Regex.Split("!!",tmp)(1)
			
			'--- build string for CBO
			cboStr = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapToolHeatingOptions.Put(cboStr,cboStr)
			
			cboStr = $"Set ${FilamentType} (Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapBedHeatingOptions.Put(cboStr,cboStr)
			
			cboStr = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C  / (Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapAllHeatingOptions.Put(cboStr,cboStr)
		
		Next
	Catch
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
End Sub



