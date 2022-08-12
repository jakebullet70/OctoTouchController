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
	
	If mMainObj.MasterCtrlr.gMapOctoTempSettings.IsInitialized Then
		Set_HeatingCBOoptions(mMainObj.MasterCtrlr.gMapOctoTempSettings)
		Log("gMapOctoTempSettings IS NOT SET!")
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
	
End Sub



Private Sub btnPresetTemp_Click
	Dim o As Button : o = Sender
	If o.Tag = "bed" Then
		
	Else '--- tool
		
	End If
	
End Sub

Private Sub lblTempChange_Click
	
	Dim o As Label : o = Sender
	Dim Dialog As B4XDialog, inputTemplate As B4XInputTemplate
	
	'--- init
	Dialog.Initialize(mMainObj.Root)
	inputTemplate.Initialize
	Dim et As EditText = inputTemplate.TextField1
	et.InputType = et.INPUT_TYPE_NUMBERS
	inputTemplate.ConfigureForNumbers(False, False) 'AllowDecimals, AllowNegative
	
	If o.Tag = "bed" Then
		inputTemplate.lblTitle.Text = "Enter Bed Temperture"
	Else '--- tool
		inputTemplate.lblTitle.Text = "Enter Tool Temperture"
	End If

	'--- make it pretty
	guiHelpers.ThemeInputDialogForm(Dialog,inputTemplate,et)
	Dim rs As ResumableSub = Dialog.ShowTemplate(inputTemplate, "Set", "", "Cancel")
	guiHelpers.ThemeInputDialogBtnsResize(Dialog)
	
	'--- display dialog
	Wait For(rs)complete(intResult As Int)
	If intResult = xui.DialogResponse_Positive Then
		
		Dim msg As String, target As String
		target = inputTemplate.Text
		
		If fnc.CheckTempRange(o.tag, target) = False Then
			guiHelpers.Show_toast("Invalid Temperture",1800)
			Return	
		End If
		
		msg = IIf(o.Tag = "bed","Bed ","Tool ")
		
		If o.Tag = "bed" Then
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",target))
		Else '--- tool
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",target).Replace("!VAL1!",0))
		End If
		
		msg = msg & "Temp Change"
		guiHelpers.Show_toast(msg,1400)
		
	End If

End Sub


public Sub Set_HeatingCBOoptions(mapOfOptions As Map)
	
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



