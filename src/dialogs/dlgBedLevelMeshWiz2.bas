B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Apr/26/2023
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "dlgBedLevelMeshWiz"' 'ignore
	Private mainObj As B4XMainPage'ignore
	Private xui As XUI
	
'	Private zAct As String = "?"
'	Private zSaved As String = "?"
'	Private zNew As String = "?"
	
	Private parent As Panel
	
	Private pnlSteps,pnlBG As Panel
	Private btnClose,btn1,btn2,btnPreheat As Button
	Private alblHeader,alblMenu As AutoTextSizeLabel
	Private lblHeaterBed,lblHeaterTool As Label
	Private pnlSpacer1,pnlSpacer2 As B4XView
	
	Private tmrHeaterOnOff As Timer
	Private mDIstance As Double = .01
	'Private mInProbeMode As Boolean = False
	
	Private Button5,Button4 ,Button3,Button2,Button1 As Button
	Private lblZinfo As Label
	Private btnDn,btnUp As Button
	
	Public pMode As String 
	
End Sub

Public Sub Initialize(p As Panel,mode As String) As Object
	
	mainObj = B4XPages.MainPage
	p.RemoveAllViews
	parent = p
	#if klipper
	mainObj.oMasterController.WSk.pCallbackModule2 = Me
	mainObj.oMasterController.WSk.pCallbackSub2 = "Rec_Text"
	#else
	
	#end if
	pMode = mode
	Return Me

End Sub

'Private Sub Check4MeshSupport() As ResumableSub
'	
'	Dim ns As String = "Mesh bed leveling is not supported in the firmware."
'	#if klipper
'	
'	#else
'	
'	#End If
'	
'	Return True
'End Sub



Public Sub Show(headerTxt As String)
	
	'Wait For (Check4MeshSupport) Complete (b As Boolean)
	'If b = False Then Return
	
	parent.SetLayoutAnimated(0, 0, 0, parent.Width, parent.Height)
	parent.LoadLayout("wizManualMeshBedLevel")
	BuildGUI(headerTxt)
	btn2.Visible = False

	tmrHeaterOnOff.Initialize("tmrHeater",1500)
	tmrHeater_Tick
	tmrHeaterOnOff.Enabled = True
	
	
	
End Sub

Private Sub tmrHeater_Tick
	lblHeaterTool.Text ="Tool: " & CRLF & oc.Tool1Actual.Replace("C","")
	lblHeaterBed.Text = "Bed: " & CRLF & oc.BedActual.Replace("C","")
End Sub



''=================================================================

'Private Sub BeepMe(num As Int	)'ignore
'	
'	Dim b As Beeper :
'	b.Initialize(120,500)
'	For xx = 1 To num
'		b.Beep : Sleep(200)
'	Next
'	
'End Sub

Private Sub btnClose_Click
	Close_Me
End Sub

Public Sub Close_Me  '--- class method, also called from android back btn
	'--- out of here!
	#if klipper
	mainObj.oMasterController.WSk.pCallbackModule2 = Null
	#end if
	parent.SetVisibleAnimated(500,False)
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	tmrHeaterOnOff.Enabled = False
	tmrHeaterOnOff = Null
	parent.RemoveAllViews
End Sub

Private Sub btnPreHeat_Click
	CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
End Sub

Private Sub BuildGUI(headerTxt As String)
	pnlBG.Color = clrTheme.Background
	pnlSpacer1.SetColorAndBorder(clrTheme.txtNormal,2dip,clrTheme.txtNormal,8dip)
	pnlSpacer2.SetColorAndBorder(clrTheme.txtNormal,2dip,clrTheme.txtNormal,8dip)
	guiHelpers.SetTextColor(Array As B4XView(lblZinfo,alblHeader.BaseLabel,alblMenu.BaseLabel,lblHeaterBed,lblHeaterTool))
	If guiHelpers.gIsLandScape = False Then  alblMenu.BaseLabel.Visible = False
	alblHeader.Text = headerTxt
	pnlSteps.Color =clrTheme.Background
	guiHelpers.SkinButton(Array As Button(btnClose,btnPreheat,btn1,btn2,btnDn,btnUp))
	DistanceBtnsLookReset
	guiHelpers.ResizeText("Tool: " & CRLF & "200",lblHeaterTool)
	guiHelpers.ResizeText("Bed: " &CRLF & "100",	lblHeaterBed)
	btn1.Text = "START" : btn2.Text = "STOP"
	btn1.TextSize =  20   : btn2.TextSize = btn1.TextSize
	btnDistance_Highlight(Button1)
	ShowZinfo("Touch START to begin")
	parent.Visible = True
End Sub

Private Sub ProcessStop_GUI
	'mInProbeMode = False
	btn2.Visible = False
	btnPreheat.Visible = True
	btn1.Text = "START"
	btnClose.Visible = True
	btnClose.RequestFocus
End Sub


Private Sub btnUpDown_Click
	Dim btn As Button = Sender
	If btn1.Text = "START" Then Return
	Dim nVal As String = Round2(mDIstance,3).As(String)
	If btn.Text.ToUpperCase.Contains("LO") Then
		nVal = "-" & nVal 
	End If
	#if klipper
	Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","TESTZ Z=" & nVal))) Complete (msg As String)
	ParseZInfo(msg)
	#else
	
	#end if
	
	'Log("btnUP-DN: " & msg)
End Sub

Private Sub DistanceBtnsLookReset
	guiHelpers.SkinButton(Array As Button(Button5,Button4 ,Button3,Button2,Button1))
End Sub

Private Sub btnDistance_Click
	Dim b As Button : b = Sender
	btnDistance_Highlight(b.As(B4XView))
	mDIstance = b.Text
	CallSubDelayed(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
End Sub

Private Sub btnDistance_Highlight(b As B4XView)
	DistanceBtnsLookReset
	b.SetColorAndBorder(xui.Color_Transparent, 8dip,clrTheme.txtAccent,8dip)
End Sub

Private Sub ShowZinfo(info As String)
	If info = "" Then info = "Z Location ???"
	info = info.Replace("Z position: ","Z pos: ")
	guiHelpers.ResizeText(info,	lblZinfo)
End Sub
Private Sub ParseZInfo(s As String)'ignore
	If s.IndexOf("Z pos") = -1 Then Return
	Try
		Dim StartNdx As Int = s.IndexOf("Z pos")
		ShowZinfo(s.SubString2(StartNdx,s.IndexOf2("]}",StartNdx)))
	Catch
		Log(LastException)
		Log("ParseZInfo ERR2: " & s)
		ShowZinfo("Parse Error:")
	End Try
End Sub

Private Sub btnStop_Click
	'--- stop the action
	ProcessStop_GUI
	guiHelpers.Show_toast2("Canceling... Disabling Steppers...",2500)
	#if klipper
	Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","ABORT"))) Complete (msg As String)
	mainObj.oMasterController.WSk.Send(krpc.GCODE.Replace("!G!","M18"))
	#else
	
	#end if
	ShowZinfo("Just hanging out and waiting...")
End Sub


Private Sub btnStart_Click

	Dim b As Button : b = Sender
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	'mInProbeMode = False
	
	btn1.RequestFocus
	'btnPreheat.Visible = False
	
	If b.Text = "START" Then
		#if klipper
		ShowZinfo("Preparing bed and tool...")
		Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","G28"))) Complete (msg As String)
		If pMode = "mblw" Then
			guiHelpers.Show_toast2("Starting manual mesh Z probe...",1500)
			Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","BED_MESH_CALIBRATE  METHOD=manual"))) Complete (msg As String)
		Else
			guiHelpers.Show_toast2("Setting up for Z Offset...",1500)
			Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","G1 X100 Y100"))) Complete (msg As String)
			Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","MANUAL_PROBE"))) Complete (msg As String)
		End If
		#if debug
		Log("WT: " & msg)
		#end if
		#else
		
		#End If
	
	else If b.Text = "ACCEPT" Or  b.Text = "DONE" Then
		#if klipper
		Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","ACCEPT"))) Complete (msg As String)		
		If msg.Contains("Manual probe failed") Then ''--- mostly happens when just hitting ACCEPT and not moving nozzle 1st
			Probe_failed
		Else
			#if debug
			Log("accept msg: " & msg)
			#end if
		End If
		#else
		
		#End If
	End If
	
End Sub

Public Sub Rec_Text(txt As String)
	#if klipper
	
	If pMode = "mblw" Then '--- manual bed level wiz
			
		If txt.Contains("y in a manual Z probe") Then
			'--- just started probe mode but are already in it so cancel and restart
			'mInProbeMode = False
			guiHelpers.Show_toast2("Already in a manual Z probe: Restarting...",6500)
			Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","ABORT"))) Complete (msg As String)
			Sleep(1000)
			Log("AB:" & msg)
			Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","BED_MESH_CALIBRATE  METHOD=manual"))) Complete (msg As String)
			Sleep(1000)
			Return
		End If
		
		If txt.Contains("g manual Z probe") Then
			'mInProbeMode = True
			If pMode = "mblw" Then '--- manual bed level wiz
				btn1.Text = "ACCEPT"
			Else
				btn1.Text = "DONE"
			End If
			btn2.Visible = True
			btnClose.Visible = False
			btnPreheat.Visible = False
			Return
		End If
		
		If txt.Contains("Z pos") Then 
			ParseZInfo(txt) : Return
		End If
		
		If txt.Contains("Manual probe failed") Then '--- mostly happens when just hitting ACCEPT and not moving nozzle 1st
			Probe_failed : Return
		End If
		
		If txt.Contains("has been saved") Then
			ShowZinfo("Mesh build complete")
			ProcessMeshComplete
			Return
		End If
	Else
		
		'--- Z offset
		If txt.Contains("g manual Z probe") Then
			'mInProbeMode = True
			btn1.Text = "DONE"
			btn2.Visible = True
			btnClose.Visible = False
			btnPreheat.Visible = False
			Return
		End If
		
		If txt.Contains("Z pos") Then
			ParseZInfo(txt) : Return
		End If
			
	End If
	
	#else 
	'--- Marlin time!
	
	#end if
	
	#if debug
	Log("RT: Not processed: " & txt)
	#end if
	
End Sub

Private Sub Probe_failed
	ShowZinfo("probe failed...")
	ProcessStop_GUI
End Sub



'Private Sub InCalMode() As ResumableSub
'	'# This is only here because klipper doesn't provide a method to detect if it's calibrating
'	Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","TESTZ Z=0.001"))) Complete (msg As String)
'End Sub


Private Sub ProcessMeshComplete'ignore
	
	#if klipper
	Dim m As StringBuilder : 	m.Initialize
	m.Append("Bed Mesh state has been saved to profile [default] for the ")
	m.Append("current session. Touch SAVE to update the printer config ")
	m.Append("File And restart the printer or CLOSE to just use the current mesh")
	Dim w,h As Float
	If guiHelpers.gIsLandScape Then
		w = guiHelpers.gWidth * .7 : h = 220dip
	Else
		w = guiHelpers.gWidth * .8 : h = 310dip
	End If
	Dim mb2 As dlgMsgBox2 : 	mb2.Initialize(mainObj.Root,"Question", w, h,False)
	mb2.NewTextSize = 24
	Wait For (mb2.Show(m.ToString,gblConst.MB_ICON_QUESTION, "SAVE","","CLOSE")) Complete (res As Int)
	If res = xui.DialogResponse_Positive Then
		mainObj.oMasterController.WSk.Send(krpc.GCODE.Replace("!G!","SAVE_CONFIG"))
		guiHelpers.Show_toast2("Saving CONFIG and restarting printer",5200)
		Main.tmrTimerCallSub.CallSubDelayedPlus(B4XPages.MainPage.oMasterController,"tmrMain_Tick",800)
	Else
		guiHelpers.Show_toast2("Using Mesh for current session, homing printer",3000)
		mainObj.oMasterController.WSk.Send(krpc.GCODE.Replace("!G!","G28"))
	End If
	#end if
	Close_Me
	Return
End Sub

