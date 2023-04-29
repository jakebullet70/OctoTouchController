B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/24/2022
'			This is UGLY! Been through about 4 revisions...
'			It works but...
#End Region


'=============================================
'
'   needs work for klipper - TODO
'
'============================================



Sub Class_Globals
	
	Private const mModule As String = "dlgFilamentCtrl"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private mDialog As B4XDialog
	Private pnlMain As B4XView, lblStatus As AutoTextSizeLabel
	Private btnStuff As Button, lblTemp As Label
	
	Private mTmrOff As Boolean = False, mLoadUnload As String
	Private mData As Map, tmp As String
	
	Private pnlWorking As B4XView
	Private btnUnload,btnLoad,btnPark,btnHeat As Button
	Private chkHeatOff As CheckBox
	Private btnBack As B4XView
End Sub

Public Sub Initialize() As Object
	mMainObj = B4XPages.MainPage
	mData = File.ReadMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE)
	Return Me
End Sub

Public Sub Close_Me  '--- class method, called from android back btn
	mDialog.Close(xui.DialogResponse_Cancel)
End Sub


Private Sub BuildGUI
	pnlMain.Color = clrTheme.Background : pnlWorking.Color = clrTheme.Background
	
	guiHelpers.SkinButton(Array As Button(btnUnload,btnLoad,btnPark,btnHeat,btnStuff))
	guiHelpers.SetTextSize(Array As Button(btnUnload,btnLoad,btnPark,btnHeat,btnStuff), _
							NumberFormat2(btnStuff.TextSize / guiHelpers.gFscale,1,0,0,False) - IIf(guiHelpers.gFscale > 1,2,0))
	
	btnStuff.TextSize = btnStuff.TextSize - 2 '--- 
	
	guiHelpers.SkinButton_Pugin(Array As Button(btnBack))
	btnBack.BringToFront
	
	guiHelpers.SetTextColor(Array As B4XView(lblTemp,lblStatus.BaseLabel))
	ShowMainPnl
End Sub

Private Sub BuildChkbox
	chkHeatOff.Initialize("TurnOffHeat")
	chkHeatOff.Text = " Heater off on close"
	chkHeatOff.TextColor = clrTheme.txtNormal
	chkHeatOff.TextSize = 18
	guiHelpers.SetCBDrawable(chkHeatOff, clrTheme.txtNormal, 1,clrTheme.txtNormal, Chr(8730), Colors.LightGray, 32dip, 2dip)
	mDialog.Base.AddView(chkHeatOff,10dip,mDialog.Base.Height - 50dip, _
		(mDialog.Base.Width - mDialog.GetButton(xui.DialogResponse_Cancel).Width - 16dip),36dip)
	'chkHeatOff.Checked = Main.kvs.GetDefault(FIL_WIZ_TURN_OFF_ON_HEAT,False)
End Sub

Private Sub TurnOffHeat_CheckedChange(Checked As Boolean)
	' save?
	'Main.kvs.Put(FIL_WIZ_TURN_OFF_ON_HEAT,Checked)
End Sub

Public Sub Show
	
	mDialog.Initialize(mMainObj.Root)
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	
	Dim p As B4XView = xui.CreatePanel("")
	Log(mMainObj.pObjCurrentDlg1)
	
	'--- TODO - needs cleanup
	If guiHelpers.gIsLandScape Then
		p.SetLayoutAnimated(0, 0, 0, _
					IIf(guiHelpers.gScreenSizeAprox < 6,460dip,560dip),IIf(guiHelpers.gScreenSizeAprox < 6,224dip,280dip))
	Else
		p.SetLayoutAnimated(0, 0, 0, _
					IIf(guiHelpers.gScreenSizeAprox < 5,guiHelpers.gWidth-20dip,560dip),IIf(guiHelpers.gScreenSizeAprox < 5,280dip,320dip))
	End If
	'---
		
	p.LoadLayout("viewFilamentCtrl")
	BuildGUI
	
	dlgHelper.ThemeDialogForm("Filament Change")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CLOSE")
	mDialog.Base.Parent.Tag = "" 'this will prevent the dialog from closing when the second dialog appears.
	BuildChkbox
	dlgHelper.ThemeInputDialogBtnsResize

	Wait For (rs) Complete (Result As Int)
	
	If chkHeatOff.Checked Then
		CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Tool Heater Off", 1600)
		#if klipper
		mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","M104 S0"))
		#else
		mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
		#End If
	End If
	
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF) '--- turn it off if its on
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	mTmrOff = True '--- if temp tmr is running will turn it off
	mMainObj.pObjCurrentDlg2 = Null
	
End Sub


'=================================================================


Private Sub tmrTempCheck_Tick
	
	If mTmrOff Then Return
	lblTemp.Text = oc.Tool1Actual
	'Log("Tmr fired")
	If oc.Tool1TargetReal = 0 Then 
		SetTempMonitorTimer
		Return '--- waiting for target var to be set from the HTTP read
	End If
	
	If oc.Tool1ActualReal >= oc.Tool1TargetReal Then
		Sleep(999) '--- settle for a second 
		LoadUnLoadFil
	Else
		SetTempMonitorTimer
	End If
	
End Sub

Private Sub SetTempMonitorTimer
	Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"tmrTempCheck_Tick",1000)
End Sub

Private Sub LoadUnLoadFil
	
	BeepMe
	btnStuff.Visible = True
	If mLoadUnload.ToLowerCase = "load" Then
		SetStatusLabel("Insert filament and touch the 'Continue' button to load")	
	Else
		SetStatusLabel("Touch The 'Continue' button to start unload")
	End If
	
End Sub

Private Sub BeepMe
	
	Dim b As Beeper : 
	b.Initialize(120,500)
	For xx = 1 To 5
		b.Beep : Sleep(200)
	Next
	
End Sub

Private Sub btnStuff_Click
	
	If btnStuff.Text.StartsWith("E") Then 
		SendMGcode("G1 E10 F60") '--- Extrude 5mm more
		CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Extruding 10mm...", 1000)
		Return
	End If
	
	'--------------------------------------------
	Dim aLen() As String, speeds As String
	If mLoadUnload = "load" Then
		speeds = mData.Get(gblConst.filLoadSpeed)
	Else
		speeds = mData.Get(gblConst.filUnLoadSpeed)
	End If
	
	Dim speed1, speed2 As String
	If mData.Get(gblConst.filUnLoadSpeed).As(String).Contains(",") Then
		speed1 = Regex.split(",", speeds)(0)
		speed2 = Regex.split(",", speeds)(1)
	Else
		speed1 = mData.Get(gblConst.filUnLoadSpeed)
		speed2 = speed1
	End If
	
	Dim sLen As String
	Dim first As Boolean = True
	If mLoadUnload <> "load" Then
		'--- UNLOAD	------
		btnStuff.Visible = False
		SendMGcode("M117 UnLoading filament")
		SetStatusLabel("UnLoad filament") : Sleep(200)
		SendMGcode("M83") : Sleep(100)
		
		If mData.Get(gblConst.filSmallExtBeforeUload).As(Boolean) = True Then
			SendMGcode($"G1 E10 F${speed1}"$) : Sleep(500) '--- small push to avoid blobs
		End If
		
		sLen = mData.Get(gblConst.filUnLoadLen)
		If sLen.Contains(",") Then '--- multi lengths as marlin has EXTRUDE_MAXLENGTH set low
			aLen = Regex.Split(",",sLen)
			For Each partLen As String In aLen
				SendMGcode($"G1 E-${partLen} F${IIf(first,speed1,speed2)}"$) : Sleep(400)
				first = False
			Next
		Else
			SendMGcode($"G1 E-${sLen} F${speed2}"$) : Sleep(100)
		End If
		
		SendMGcode("M18 E") : Sleep(100)
		Sleep(600)
		ShowMainPnl
		
	Else
		
		'--- LOAD --------	
		SetStatusLabel("Filament load") : Sleep(100)
		SendMGcode("M117 Load filament") 
		SendMGcode("M83") : Sleep(100)
		sLen = mData.Get(gblConst.filLoadLen)
		Dim first As Boolean = True
		If sLen.Contains(",") Then '--- multi lengths as marlin has EXTRUDE_MAXLENGTH set low
			aLen = Regex.Split(",",sLen)
			Dim isLast As Int = 0
			For Each partLen As String In aLen
				SendMGcode($"G1 E${partLen} F${IIf(isLast = aLen.Length - 1,speed2,speed1)}"$) : Sleep(400)
				isLast = isLast + 1
			Next
		Else
			SendMGcode($"G1 E${sLen} F${speed2}"$) : Sleep(100)
		End If
		btnStuff.Text = "Extrude" & CRLF & "10mm More"
	
	End If
	
End Sub


Private Sub ParkNozzle() As ResumableSub 'ignore
	
	CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Parking Nozzle...", 2600)
	
	If mData.GetDefault(gblConst.filPauseBeforePark,False).As(Boolean) = True Then
		SendMGcode("M0") : Sleep(100)
	End If
	
	If mData.GetDefault(gblConst.filRetractBeforePark,False).As(Boolean) = True Then
		SendMGcode("M83") : Sleep(100)
		SendMGcode("G1 E-5 F50") : Sleep(100)
	End If
	
	SendMGcode("G91") : Sleep(100)
	
	tmp = $"G0 Z${mData.Get(gblConst.filZLiftRel)} F${mData.Get(gblConst.filParkSpeed)}"$
	SendMGcode(tmp) : Sleep(100)
	
	If mData.GetDefault(mData.Get(gblConst.filHomeBeforePark),False).As(Boolean) = True Then
		SendMGcode("G28 X0 Y0") : Sleep(100)
	End If
	
	SendMGcode("G90") : Sleep(100)
	
	tmp = $"G0 Y${mData.Get(gblConst.filYPark)} X${mData.Get(gblConst.filXPark)} F${mData.Get(gblConst.filParkSpeed)}"$
	SendMGcode(tmp) : Sleep(100)
	
End Sub


Private Sub SendMGcode(code As String)
	
	#if klipper
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!",code))
	#else
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",code))
	#End If
	
End Sub


Private Sub SetStatusLabel(txt As String)
	lblStatus.Text = txt & CRLF
End Sub

Private Sub btnCtrl_Click
	Dim btn As B4XView : btn = Sender
	mLoadUnload = "" : mTmrOff = True
	btnStuff.Text = "Continue" ': btnStuff.Visible = True
	Select Case btn.Tag
		Case "ht" 	: PromptHeater
		Case "pk"	: ParkNozzle
		Case "ld"	'--- load
			mLoadUnload = "load"
			ShowWorkingPnl
			
		Case "ul"	'--- unload
			ShowWorkingPnl
			
		Case "bk" 	'--- back btn
			ShowMainPnl
	End Select
	
End Sub

Private Sub ShowWorkingPnl
	Dim Const TOOL_NOT_HEATING As String = "0" & gblConst.DEGREE_SYMBOL & "C"
	If oc.Tool1Target = TOOL_NOT_HEATING Then
		CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Tool heater not set", 3000)
		Return
	End If
	lblTemp.Text = "heating"
	mTmrOff = False
	pnlMain.Visible = False : pnlWorking.Visible = True
	pnlWorking.BringToFront
	btnStuff.Visible = False
	SetStatusLabel("Waiting for temperature...")
	SetTempMonitorTimer '--- turn on the timer and monitor temp
End Sub
Private Sub ShowMainPnl
	pnlMain.Visible = True : pnlWorking.Visible = False
	pnlMain.BringToFront
End Sub


#region "SHOW TEMP SELECT"
Public Sub PromptHeater
	Dim o1 As dlgListbox
	o1.Initialize("Filament Change",Me,"HeatTempChange_Tool")
	'Dim mapTmp As Map = objHelpers.CopyMap(mMainObj.oMasterController.mapToolHeatValuesOnly)
	'mapTmp.Remove("Tool Off")
	o1.Show(250dip,270dip,mMainObj.oMasterController.mapToolHeatValuesOnly)
	Wait For HeatTempChange_Tool(value As String, tag As Object)
	ProcessHeatTempChange(value,tag)
End Sub


Private Sub ProcessHeatTempChange(value As String, tag As Object) 'ignore
	
	'--- callback for Show_SelectTemp
	If value.Length = 0 Then
		mTmrOff = True
		Return
	End If

	If value = "ev" Then
		'--- type in a value
		Dim oo As HeaterRoutines : oo.Initialize
		oo.ChangeTempTool
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
	mMainObj.oMasterController.cn.PostRequest( _
				oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))		
	oc.Tool1Target = "1" 
	#End If
	
	If value = 0 Then
		guiHelpers.Show_toast2("Tool turned off",1200)
	Else
		guiHelpers.Show_toast2("Tool set to: " & value & gblConst.DEGREE_SYMBOL & "C",2200)
	End If
	
	mTmrOff = False
	
End Sub


#END REGION

