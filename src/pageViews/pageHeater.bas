B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/6/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "pageHeater" 'ignore
	Private xui As XUI
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private  mMainObj As B4XMainPage'ignore
	Private mTmrTempatureTabUserClick As Timer
	
	Private mTempatureUpdatingByRestAPI As Boolean = False
	Private mTempatureCboUpdatedByRestAPI As Boolean = False
	Private mapBedHeatingOptions, mapToolHeatingOptions,mapAllHeatingOptions As Map

	Private pnlMisc,pnlBed,pnlTool As B4XView
	
	Private spnrBedActualTarget, spnrToolActualTarget As B4XPlusMinus
	Private oSpnrBedEdit, oSpnrToolEdit As B4XPlusMinusEdt
	
	
End Sub

#region "PAGE INIT - EVENTS"
Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageHeater")
	
	mTmrTempatureTabUserClick.Initialize("tmrTempTabUserClick",9000)
	
	Build_GUI
	
End Sub

public Sub Set_focus()
	mPnlMain.Visible = True
End Sub

public Sub Lost_focus()
	mPnlMain.Visible = False
End Sub
#end region


Private Sub Build_GUI

	Set_HeatingCBOoptions(mMainObj.MasterCtrlr.gMapOctoTempSettings)
	
	'BuildHeaterPanel(pnlTool,"Hotend")
	'BuildHeaterPanel(pnlBed,"Bed")
	
	oSpnrToolEdit.Initialize(spnrToolActualTarget)
	oSpnrBedEdit.Initialize(spnrBedActualTarget)
	
End Sub

Private Sub BuildHeaterPanel(mnuPanel As B4XView, Text As String)
'	
'	'mnuPanel.SetLayoutAnimated(0, mnuPanel.Width / 2 ,mnuPanel.Height /2 ,mnuPanel.Width,mnuPanel.Height)
'	mnuPanel.LoadLayout("viewSetTemps")
'	For Each v As View In mnuPanel.GetAllViewsRecursive
'		
'		If v.Tag <> Null Then
'			If v.Tag Is B4XPlusMinus Then
'				If Text = "Bed" Then
'					spnrBedActualTarget = v.tag
'					guiHelpers.ReSkinPlusMinusControl(spnrBedActualTarget)
'					spnrBedActualTarget.SetNumericRange(0,140,1)
'					spnrBedActualTarget.Tag = Text
'				Else
'					spnrToolActualTarget = v.tag
'					guiHelpers.ReSkinPlusMinusControl(spnrToolActualTarget)
'					spnrToolActualTarget.SetNumericRange(0,300,1)
'					spnrToolActualTarget.Tag = Text
'				End If
'				
'			Else If v.Tag = "hdr" Then
'				Dim o2 As Label = v
'				o2.Text = Text
'				
'			Else If v.Tag = "btn" Then
'				Dim o3 As Button = v
'				o3.Tag = Text
'				
'			Else if v.Tag = "bg" Then
'				Dim o4 As Panel = v
'				o4.Color = xui.Color_Transparent
'				
'			End If
'		End If
'		
'	Next
'	
End Sub


public Sub Update_Printer_Btns
	'--- sets enable, disable - 
	
End Sub


Private Sub tmrTempTabUserClick_Tick
	
	'--- turn off tempature entry timer, if printing, values will be reset to what octo has
	'--- TODO, at this point you cannot enter a temp directly !!!!!!!!!!!!!!!!!!!
	'--- TODO, at this point you cannot enter a temp directly !!!!!!!!!!!!!!!!!!!
	
	mTmrTempatureTabUserClick.Enabled = False
	logMe.LogIt("tmrTempatureTabUserClick OFF",mModule)
	
	
End Sub

public Sub Set_HeatingCBOoptions(mapOfOptions As Map)
	
	'--- clear them out
	mapBedHeatingOptions.Initialize
	mapToolHeatingOptions.Initialize
	mapAllHeatingOptions.Initialize
		
	Dim allOff As String = "** All Off **"
'	#if b4a or b4i
'	Dim cs As CSBuilder : cs.Initialize '--- not used. HATES B4J!
'	#end if
	
'	#if b4a or b4j
'	tmpListBed.Add(cs.Initialize.BackgroundColor(clrTheme.DialogButtonsColor).Alignment("ALIGN_CENTER").Bold _
'			.Color(clrTheme.DialogButtonsTextColor) _ 
'			.Append("  Bed Options  ").PopAll)
'	#else
'	tmpListBed.Add("Bed Options") '--- just a header
'	#end if

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

Private Sub btnSetTemp_Click
	'--- this is the SET button for both TOOL and BED
	
	tmrTempTabUserClick_Tick '--- will turn timer off if its on
	
	Dim o As Button : o = Sender
	Dim msg As String
	
	If o.Tag = "Bed" Then
		Dim v1 As Int = spnrBedActualTarget.SelectedValue
		mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",v1))
		'spnrBedActualTarget.SelectedValue = v1
		msg = "Bed Temp Change"
	Else '--- hotend
		'--- use cCMD_SET_TOOL_TEMP2 if you have 2 print heads
		Dim v0 As Int = spnrToolActualTarget.SelectedValue
		mMainObj.MasterCtrlr.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",v0).Replace("!VAL1!",0))
		'spnrToolActualTarget.SelectedValue = v0
		msg = "Hotend Temp Change"
	End If
		
	guiHelpers.Show_toast($"Sending Command (${msg})"$,2000)
	
	'--- turn off timer if its on
	mTmrTempatureTabUserClick.Enabled = False
	
	CallSub(mMainObj.MasterCtrlr,"tmrMain_Tick")
			
End Sub

Private Sub btnPresetTemp_Click
	Dim o As Button : o = Sender
	If o.Tag = "Bed" Then
		
	Else '--- hotend
		
	End If
End Sub

Private Sub spnrTemp_ValueChanged (Value As Object)
	'Dim v As B4XPlusMinus : v = Sender
	
	If mTempatureUpdatingByRestAPI = True Then
		mTempatureUpdatingByRestAPI = False '--- triggered by a REST API call, we dont care
		Return
	End If

	'--- user is printing, set the timer (8 seconds) so we can get user input without updating
	'--- the screen with the actual temps, reset the 8 seconds everytime the user changes it
	mTmrTempatureTabUserClick.Enabled = False : 	mTmrTempatureTabUserClick.Enabled = True
	
	logMe.LogIt("spnrBedActualTarget_ValueChanged - tmrTempatureTabUserClick ON",mModule)
	
End Sub

public Sub Update_Printer_Temps()
	
	'--- is the user changing the temps?
	If mTmrTempatureTabUserClick.Enabled = False Then ' And oc.isPrinting = False Then
	
		Try
		
			mTempatureUpdatingByRestAPI = True
			spnrBedActualTarget.MainLabel.Text = ( Abs(oc.BedTarget.Replace("C","").Replace("c","").Replace(gblConst.DEGREE_SYMBOL,"")).As(String) )
			spnrToolActualTarget.MainLabel.Text = ( Abs(oc.Tool1Target.Replace("C","").Replace("c","").Replace(gblConst.DEGREE_SYMBOL,"")).As(String) )
			
			'--- reset the internal spinner tracker 
			spnrBedActualTarget.SelectedValue = spnrBedActualTarget.MainLabel.Text
			spnrToolActualTarget.SelectedValue = spnrToolActualTarget.MainLabel.Text
			
		Catch
		
			logMe.LogIt(LastException,mModule)
		
		End Try
		
	End If
	
End Sub


Private Sub btnPresetMaster_Click
	
End Sub






