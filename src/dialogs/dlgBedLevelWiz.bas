B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Mar/11/2023
'			This is UGLY! Been through about 4 revisions...
'			It works but...
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "dlgBedLevelWiz"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mGeneralDlg As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper

	Private mPanelBG As B4XView
End Sub

Public Sub Initialize(mobj As B4XMainPage,p As B4XView)
	mainObj = mobj
	mPanelBG = p
End Sub


Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
	Dim h,w As Float '--- TODO - needs refactor
	If guiHelpers.gIsLandScape Then
		If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
			h = 62%y
		Else If guiHelpers.gScreenSizeAprox >= 8 Then
			h = 55%y
		Else '--- 4 to 5.9 inch
			h = 80%y
		End If
		w = 360dip
	Else
		h = 440dip
		w = guiHelpers.gWidth * .92
	End If
	w = 100%x
	'mGeneralDlg.Initialize(mainObj.root, "General Settings", w, h)
	
	
	mGeneralDlg.Initialize(mPanelBG, "General Settings", w, h)
	mGeneralDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgGeneral.json"))
	mGeneralDlg.SetEventsListener(Me,"dlgGeneral")
	
	
	prefHelper.Initialize(mGeneralDlg)
	prefHelper.ThemePrefDialogForm
	mGeneralDlg.PutAtTop = False
	Dim RS As ResumableSub = mGeneralDlg.ShowDialog(Data, "", "CLOSE")
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	
	Wait For (RS) Complete (Result As Int)
'	If Result = xui.DialogResponse_Positive Then
'		guiHelpers.Show_toast("General Data Saved",1500)
'		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,Data)
'		config.ReadGeneralCFG
'		CallSub(mainObj.oPageCurrent,"Set_focus")
'	End If
'	
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
End Sub


Private Sub dlgGeneral_IsValid (TempData As Map) As Boolean 'ignore
	Return True '--- all is good!
	'--- NOT USED BUT HERE IF NEEDED
	
'	Try
'		Dim number As Int = TempData.GetDefault("days", 1)
'		If number < 1 Or number > 14 Then
'			guiHelpers.Show_toast("Days must be between 1 and 14",1200)
'			pdlgLogging.ScrollToItemWithError("days")
'			Return False
'		End If
'		Return True
'	Catch
'		Log(LastException)
'	End Try
'	Return False

End Sub



Private Sub dlgGeneral_BeforeDialogDisplayed (Template As Object)
	prefHelper.SkinDialog(Template)
End Sub




'=================================================================

'
'Private Sub tmrTempCheck_Tick
'	
'	If mTmrOff Then Return
'	lblTemp.Text = oc.Tool1Actual
'	'Log("Tmr fired")
'	If oc.Tool1TargetReal = 0 Then 
'		SetTempMonitorTimer
'		Return '--- waiting for target var to be set from the HTTP read
'	End If
'	
'	If oc.Tool1ActualReal >= oc.Tool1TargetReal Then
'		Sleep(999) '--- settle for a second 
'		LoadUnLoadFil
'	Else
'		SetTempMonitorTimer
'	End If
'	
'End Sub
'
'Private Sub SetTempMonitorTimer
'	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"tmrTempCheck_Tick",1000)
'End Sub


Private Sub BeepMe
	
	Dim b As Beeper : 
	b.Initialize(120,500)
	For xx = 1 To 5
		b.Beep : Sleep(200)
	Next
	
End Sub

'
''======================================================================================
'
'
'Private Sub btnStuff_Click
'	
'	If btnStuff.Text.StartsWith("E") Then 
'		SendMGcode("G1 E5 F60") '--- Extrude 5mm more
'		CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Extruding 5mm...", 1000)
'		Return
'	End If
'	
'	'--------------------------------------------
'	Dim aLen() As String, speeds As String
'	If mLoadUnload = "load" Then
'		speeds = mData.Get(gblConst.filLoadSpeed)
'	Else
'		speeds = mData.Get(gblConst.filUnLoadSpeed)
'	End If
'	
'	Dim speed1, speed2 As String
'	If mData.Get(gblConst.filUnLoadSpeed).As(String).Contains(",") Then
'		speed1 = Regex.split(",", speeds)(0)
'		speed2 = Regex.split(",", speeds)(1)
'	Else
'		speed1 = mData.Get(gblConst.filUnLoadSpeed)
'		speed2 = speed1
'	End If
'	
'	Dim sLen As String
'	Dim first As Boolean = True
'	If mLoadUnload <> "load" Then
'		'--- UNLOAD	------
'		btnStuff.Visible = False
'		SendMGcode("M117 UnLoading filament")
'		SetStatusLabel("UnLoad filament") : Sleep(200)
'		SendMGcode("M83") : Sleep(100)
'		
'		If mData.Get(gblConst.filSmallExtBeforeUload).As(Boolean) = True Then
'			SendMGcode($"G1 E10 F${speed1}"$) : Sleep(500) '--- small push to avoid blobs
'		End If
'		
'		sLen = mData.Get(gblConst.filUnLoadLen)
'		If sLen.Contains(",") Then '--- multi lengths as marlin has EXTRUDE_MAXLENGTH set low
'			aLen = Regex.Split(",",sLen)
'			For Each partLen As String In aLen
'				SendMGcode($"G1 E-${partLen} F${IIf(first,speed1,speed2)}"$) : Sleep(400)
'				first = False
'			Next
'		Else
'			SendMGcode($"G1 E-${sLen} F${speed2}"$) : Sleep(100)
'		End If
'		
'		SendMGcode("M18 E") : Sleep(100)
'		Sleep(600)
'		ShowMainPnl
'		
'	Else
'		
'		'--- LOAD --------	
'		SetStatusLabel("Filament load") : Sleep(100)
'		SendMGcode("M117 Load filament") 
'		SendMGcode("M83") : Sleep(100)
'		sLen = mData.Get(gblConst.filLoadLen)
'		Dim first As Boolean = True
'		If sLen.Contains(",") Then '--- multi lengths as marlin has EXTRUDE_MAXLENGTH set low
'			aLen = Regex.Split(",",sLen)
'			Dim isLast As Int = 0
'			For Each partLen As String In aLen
'				SendMGcode($"G1 E${partLen} F${IIf(isLast = aLen.Length - 1,speed2,speed1)}"$) : Sleep(400)
'				isLast = isLast + 1
'			Next
'		Else
'			SendMGcode($"G1 E${sLen} F${speed2}"$) : Sleep(100)
'		End If
'		btnStuff.Text = "Extrude" & CRLF & "5mm More"
'	
'	End If
'	
'End Sub
'
'
'Private Sub ParkNozzle() As ResumableSub 'ignore
'	
'	CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Parking Nozzle...", 2600)
'	
'	If mData.GetDefault(gblConst.filPauseBeforePark,False).As(Boolean) = True Then
'		SendMGcode("M0") : Sleep(100)
'	End If
'	
'	If mData.GetDefault(gblConst.filRetractBeforePark,False).As(Boolean) = True Then
'		SendMGcode("M83") : Sleep(100)
'		SendMGcode("G1 E-5 F50") : Sleep(100)
'	End If
'	
'	SendMGcode("G91") : Sleep(100)
'	
'	tmp = $"G0 Z${mData.Get(gblConst.filZLiftRel)} F${mData.Get(gblConst.filParkSpeed)}"$
'	SendMGcode(tmp) : Sleep(100)
'	
'	If mData.GetDefault(mData.Get(gblConst.filHomeBeforePark),False).As(Boolean) = True Then
'		SendMGcode("G28 X0 Y0") : Sleep(100)
'	End If
'	
'	SendMGcode("G90") : Sleep(100)
'	
'	tmp = $"G0 Y${mData.Get(gblConst.filYPark)} X${mData.Get(gblConst.filXPark)} F${mData.Get(gblConst.filParkSpeed)}"$
'	SendMGcode(tmp) : Sleep(100)
'	
'End Sub
'
'Private Sub SendMGcode(code As String)
'	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",code))
'End Sub
'
'Private Sub SetStatusLabel(txt As String)
'	lblStatus.Text = txt & CRLF
'End Sub
'
'Private Sub btnCtrl_Click
'	Dim btn As B4XView : btn = Sender
'	mLoadUnload = "" : mTmrOff = True
'	btnStuff.Text = "Continue" ': btnStuff.Visible = True
'	Select Case btn.Tag
'		Case "ht" 	: PromptHeater
'		Case "pk"	: ParkNozzle
'		Case "ld"	'--- load
'			mLoadUnload = "load"
'			ShowWorkingPnl
'			
'		Case "ul"	'--- unload
'			ShowWorkingPnl
'			
'		Case "bk" 	'--- back btn
'			ShowMainPnl
'	End Select
'	
'End Sub
'
'Private Sub ShowWorkingPnl
'	Dim Const TOOL_NOT_HEATING As String = "0" & gblConst.DEGREE_SYMBOL & "C"
'	If oc.Tool1Target = TOOL_NOT_HEATING Then
'		CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Tool heater not set", 3000)
'		Return
'	End If
'	lblTemp.Text = "heating"
'	mTmrOff = False
'	pnlMain.Visible = False : pnlWorking.Visible = True
'	pnlWorking.BringToFront
'	btnStuff.Visible = False
'	SetStatusLabel("Waiting for temperature...")
'	SetTempMonitorTimer '--- turn on the timer and monitor temp
'End Sub
'Private Sub ShowMainPnl
'	pnlMain.Visible = True : pnlWorking.Visible = False
'	pnlMain.BringToFront
'End Sub
'
'
'#region "SHOW TEMP SELECT"
'Public Sub PromptHeater
'	Dim o1 As dlgListbox
'	o1.Initialize(mMainObj,"Filament Change",Me,"HeatTempChange_Tool")
'	'Dim mapTmp As Map = objHelpers.CopyMap(mMainObj.oMasterController.mapToolHeatValuesOnly)
'	'mapTmp.Remove("Tool Off")
'	o1.Show(250dip,270dip,mMainObj.oMasterController.mapToolHeatValuesOnly)
'	Wait For HeatTempChange_Tool(value As String, tag As Object)
'	ProcessHeatTempChange(value,tag)
'End Sub
'
'
'Private Sub ProcessHeatTempChange(value As String, tag As Object) 'ignore
'	
'	'--- callback for Show_SelectTemp
'	If value.Length = 0 Then
'		mTmrOff = True
'		Return
'	End If
'
'	If value = "ev" Then
'		'--- type in a value
'		Dim oo As HeaterRoutines : oo.Initialize
'		oo.ChangeTempTool
'		Return
'	End If
'	
'	If value.EndsWith("off") Then value = 0 '--- tool off
'	If fnc.CheckTempRange("tool", value) = False Then
'		guiHelpers.Show_toast("Invalid Temperature",1800)
'		Return
'	End If
'		
'	mMainObj.oMasterController.cn.PostRequest( _
'				oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))
'
'	oc.Tool1Target = "1" 
'	mTmrOff = False
'	
'End Sub
'
'
'#END REGION
'
