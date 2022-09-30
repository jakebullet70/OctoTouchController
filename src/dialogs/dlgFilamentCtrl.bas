B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/24/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgFilamentCtrl"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private mDialog As B4XDialog
	Private pnlMain As B4XView, lblStatus As AutoTextSizeLabel
	Private btnStuff As B4XView, lblTemp As Label
	
	Private mCanceled As Boolean = False, mLoadUnload As String
	Private mData As Map, tmp As String
	
	Private pnlWorking As B4XView
	Private btnUnload,btnLoad,btnPark,btnHeat As B4XView
	Private chkHeatOff As CheckBox
	Private btnBack As B4XView
End Sub



Public Sub Initialize(mobj As B4XMainPage)
	mMainObj = mobj
End Sub


Private Sub BuildGUI
	pnlMain.Color = clrTheme.Background : pnlWorking.Color = clrTheme.Background
	
	'SetStatusLabel("Waiting for temperature...")
	Dim fn As B4XFont = xui.CreateDefaultFont(NumberFormat2(btnStuff.TextSize / guiHelpers.gFscale,1,0,0,False) - IIf(guiHelpers.gFscale > 1,2,0))
	btnStuff.Font = fn : btnUnload.Font = fn : btnPark.Font = fn
	btnLoad.Font = fn : btnHeat.Font = fn
	
	guiHelpers.SetEnableDisableColor(Array As B4XView(btnBack, btnStuff,btnHeat,btnLoad,btnPark,btnUnload))
	
	guiHelpers.SetTextColor(Array As B4XView(lblTemp,lblStatus.BaseLabel))
	ShowMainPnl
End Sub

Private Sub BuildChkbox
	chkHeatOff.Initialize("TurnOffHeat")
	chkHeatOff.Text = " Touch to turn off heat on close"
	chkHeatOff.TextColor = clrTheme.txtNormal
	chkHeatOff.TextSize = 18
	guiHelpers.SetCBDrawable(chkHeatOff, clrTheme.txtNormal, 1,clrTheme.txtNormal, Chr(8730), Colors.LightGray, 32dip, 2dip)
	mDialog.Base.AddView(chkHeatOff,10dip,mDialog.Base.Height - 50dip,280dip,36dip)
End Sub

Public Sub Show
	
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, _
		IIf(guiHelpers.gScreenSizeAprox < 6,460dip,560dip),IIf(guiHelpers.gScreenSizeAprox < 6,224dip,280dip))
		
	p.LoadLayout("viewFilamentCtrl")
	BuildGUI
	
	'SetTempMonitorTimer
		
	guiHelpers.ThemeDialogForm(mDialog, "Filament Change")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CLOSE")
	mDialog.Base.Parent.Tag = "" 'this will prevent the dialog from closing when the second dialog appears.
	BuildChkbox
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	Wait For (rs) Complete (Result As Int)
	If Result = xui.DialogResponse_Cancel Then
		EndWizard
		Return
	End If
	
End Sub


Private Sub EndWizard 'ignore
	If chkHeatOff.Checked Then
		CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Tool Heater Off", 1600)
		mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
	End If
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF) '--- turn it off if its on
	mCanceled = True
End Sub




Private Sub tmrTempCheck_Tick
	
	If mCanceled Then Return
	'Log(oc.Tool1TargetReal)
	If oc.Tool1TargetReal = 0 Then 
		SetTempMonitorTimer
		Return '--- waiting for target var to be set from thee HTTP read
	End If
	
	If oc.Tool1ActualReal >= oc.Tool1TargetReal Then
		Sleep(1000) '--- settle for a second 
		LoadUnLoadFil
	Else
		lblTemp.Text = oc.Tool1Actual
		SetTempMonitorTimer
	End If
	
End Sub

Private Sub SetTempMonitorTimer
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"tmrTempCheck_Tick",1000)
End Sub

Private Sub LoadUnLoadFil
	
	BeepMe
	If mLoadUnload.ToLowerCase = "load" Then
		SetStatusLabel("Insert filament and touch the 'Continue' button to load")
		btnStuff.Text = "Continue"
		btnStuff.Visible = True
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
	SetStatusLabel("Working...") : Sleep(100)
	SendCmds
	mDialog.Close(xui.DialogResponse_Positive) '--- close it, exit dialog
End Sub


Public Sub SendCmds
	
	mData = File.ReadMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE)
	
	'Wait For (ParkNozzle)   Complete(i As Int)
	If mLoadUnload.ToLowerCase = "load" Then
		Wait For (LoadFilament) Complete(i As Int)
	Else
		Wait For (UnLoadFilament) Complete(i As Int)
	End If
	
End Sub

Private Sub UnLoadFilament() As ResumableSub 'ignore
	
	SetStatusLabel("UnLoading filament") : Sleep(100)
	
	SendMGcode("M83") : Sleep(100)
	SendMGcode($"G1 E-${mData.Get(gblConst.filUnLoadLen)} F${mData.Get(gblConst.filUnLoadSpeed)}"$) : Sleep(100)
	SendMGcode("M18 E") : Sleep(100)
	
End Sub


Private Sub LoadFilament() As ResumableSub 'ignore
	
	SetStatusLabel("Loading filament") : Sleep(100)
	
	SendMGcode("M83") : Sleep(100)
	SendMGcode($"G1 E${mData.Get(gblConst.filLoadLen)} F${mData.Get(gblConst.filLoadSpeed)}"$) : Sleep(100)
	
End Sub



Private Sub ParkNozzle() As ResumableSub 'ignore
	
	'SetStatusLabel("Parking nozzle") : Sleep(100)
	
	CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Parking Nozzle...", 1600)
	If mData.Get(gblConst.filPauseBeforePark).As(Boolean) = True Then
		SendMGcode("M0") : Sleep(100)
	End If
	
	If mData.Get(gblConst.filRetractBeforePark).As(Boolean) = True Then
		SendMGcode("M83") : Sleep(100)
		SendMGcode("G1 E-5 F50") : Sleep(100)
	End If
	
	SendMGcode("G91") : Sleep(100)
	
	tmp = $"G0 Z${mData.Get(gblConst.filZLiftRel)} F${mData.Get(gblConst.filParkSpeed)}"$
	SendMGcode(tmp) : Sleep(100)
	
	If mData.Get(mData.Get(gblConst.filHomeBeforePark)).As(Boolean) = True Then
		SendMGcode("G28 X0 Y0") : Sleep(100)
	End If
	
	SendMGcode("G90") : Sleep(100)
	
	tmp = $"G0 Y${mData.Get(gblConst.filYPark)} X${mData.Get(gblConst.filXPark)} F${mData.Get(gblConst.filParkSpeed)}"$
	SendMGcode(tmp) : Sleep(100)
	
	'SetStatusLabel("Nozzle parked") : Sleep(100)
	
End Sub


Private Sub SendMGcode(code As String)
	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",code))
End Sub


Private Sub SetStatusLabel(txt As String)
	lblStatus.Text = txt & CRLF
End Sub

Private Sub btnCtrl_Click
	Dim btn As B4XView : btn = Sender
	Select Case btn.Tag
		Case "ht" 	'--- heater
			PromptHeater
		Case "pk"	'--- park
			ParkNozzle
		Case "ld"	'--- load
			'If oc.Tool1Target.ToLowerCase = "off" Then
			'End If
			ShowWorkingPnl
			
		Case "ul"	'--- unload
			ShowWorkingPnl
			
		Case "bk" 	'--- back btn
			pnlMain.Visible = True : pnlWorking.Visible = False
	End Select
	
End Sub

Private Sub ShowWorkingPnl
	pnlMain.Visible = False : pnlWorking.Visible = True
	btnStuff.Visible = False
	'SetStatusLabel("Waiting for temperature...")
	SetStatusLabel("Working...")
End Sub
Private Sub ShowMainPnl
	pnlMain.Visible = True : pnlWorking.Visible = False
End Sub

#region "SHOW TEMP SELECT"
Public Sub PromptHeater
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,"Filament Change",Me,"HeatTempChange_Tool")
	Dim mapTmp As Map = objHelpers.CopyMap(mMainObj.oMasterController.mapToolHeatValuesOnly)
	mapTmp.Remove("Tool Off")
	o1.Show(250dip,270dip,mapTmp)
	Wait For HeatTempChange_Tool(value As String, tag As Object)
	ProcessHeatTempChange(value,tag)
End Sub


Private Sub ProcessHeatTempChange(value As String, tag As Object) 'ignore
	
	'--- callback for Show_SelectTemp
	If value.Length = 0 Then
		mCanceled = True
		Return
	End If

	If value = "ev" Then
		TypeInHeatChangeRequest '--- type in a value
		Return
	End If
	
	If fnc.CheckTempRange("tool", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.oMasterController.cn.PostRequest( _
				oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))
		
End Sub

Private Sub TypeInHeatChangeRequest
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj,"Tool Temperature","Enter Temperature",Me,"HeatTempChange_ToolEdit")
	o1.Show
End Sub

Private Sub HeatTempChange_ToolEdit(value As String)
	'--- callback for TypeInHeatChangeRequest
	ProcessHeatTempChange(value,"")
End Sub
#END REGION

