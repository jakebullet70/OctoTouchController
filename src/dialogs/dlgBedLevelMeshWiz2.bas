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
	
	Private btnDn,btnUp As Button
	
	Public pMode As String 
	Public Const ppMANUAL_MESH As String = "mblw"
	
	Private alblZinfo As AutoTextSizeLabel
	
	Private btnDst1 As B4XView
	Private btnDst2 As B4XView
	Private btnDst3 As B4XView
	Private btnDst4 As B4XView
	Private btnDst5 As B4XView
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
'	Dim ns As String = "Mesh bed leveling is not supported in the firmware."
'	#if klipper
'	#else
'	#End If
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
	
	B4XPages.MainPage.oMasterController.oWS.pParserWO.RaiseEventMod = Me
	B4XPages.MainPage.oMasterController.oWS.pParserWO.RaiseEventEvent = "rec_text"
	
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
	If oc.Klippy Then
		B4XPages.MainPage.oMasterController.oWS.pParserWO.ResetRaiseEvent
	End If
	parent.SetVisibleAnimated(500,False)
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	tmrHeaterOnOff.Enabled = False
	tmrHeaterOnOff = Null
	parent.RemoveAllViews
	'B4XPages.MainPage.pObjWizards=Null
End Sub

Private Sub btnPreHeat_Click
	CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
End Sub

Private Sub BuildGUI(headerTxt As String)
	pnlBG.Color = clrTheme.Background
	pnlSpacer1.SetColorAndBorder(clrTheme.txtNormal,2dip,clrTheme.txtNormal,8dip)
	pnlSpacer2.SetColorAndBorder(clrTheme.txtNormal,2dip,clrTheme.txtNormal,8dip)
	guiHelpers.SetTextColor(Array As B4XView(alblZinfo.BaseLabel,alblHeader.BaseLabel,alblMenu.BaseLabel,lblHeaterBed,lblHeaterTool))
	If guiHelpers.gIsLandScape = False Then  
		alblMenu.BaseLabel.Visible = False
	End If
	alblHeader.Text = headerTxt
	pnlSteps.Color =clrTheme.Background
	guiHelpers.SkinButton(Array As Button(btnClose,btnPreheat,btn1,btn2,btnDn,btnUp))
	DistanceBtnsLookReset
	guiHelpers.ResizeText("Tool: " & CRLF & "200",lblHeaterTool)
	guiHelpers.ResizeText("Bed: " &CRLF & "100",	lblHeaterBed)
	btn1.Text = "START" : btn2.Text = "STOP"
	btn1.TextSize =  20   : btn2.TextSize = btn1.TextSize
	btnDistance_Highlight(btnDst1)
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
	If btn1.Text = "START" Then 
		Return
	End If
	Dim nVal As String = Round2(mDIstance,3).As(String)
	If btn.Text.ToUpperCase.Contains("LO") Then
		nVal = "-" & nVal 
	End If
	If oc.Klippy Then
		mainObj.Send_Gcode("TESTZ Z=" & nVal)
	Else '--- Marlin
	
	End If
	btn.RequestFocus
	'Log("btnUP-DN: " & msg)
End Sub

Private Sub DistanceBtnsLookReset
	guiHelpers.SkinButton(Array As Button(btnDst1,btnDst2,btnDst3,btnDst4,btnDst5))
End Sub


Private Sub btnDst_Click
	Dim b As Button : b = Sender
	Log(b.text)
	btnDistance_Highlight(b.As(B4XView))
	mDIstance = b.Text
	CallSubDelayed(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
End Sub

Private Sub btnDistance_Highlight(b As B4XView)
	DistanceBtnsLookReset
	b.SetColorAndBorder(xui.Color_Transparent, 6dip,clrTheme.txtAccent,6dip)
End Sub


Private Sub ShowZinfo(info As String)
	If info = "" Then info = "Z Location ???"
	info = info.Replace("Z position: ","Z pos: ")
	alblZinfo.Text = info
End Sub
Private Sub ParseZInfo(s As String)'ignore
	If s.IndexOf("Z pos") = -1 Then Return
	Try
		Dim StartNdx As Int = s.IndexOf("Z pos")
		'ShowZinfo(s.SubString2(StartNdx,s.IndexOf2("]}",StartNdx)))
		ShowZinfo(s.SubString2(StartNdx,s.Length))
	Catch
		Log(LastException)
		Log("ParseZInfo ERR2: " & s)
		ShowZinfo("Parse Error:")
	End Try
End Sub


Private Sub btnStop_Click
	'--- stop the action
	ProcessStop_GUI
	guiHelpers.Show_toast2("Canceling... Disabling Steppers...",3000)
	
	If oc.Klippy Then
		mainObj.Send_Gcode("ABORT")
		mainObj.Send_Gcode("M18") '--- disable steppers
	Else '--- Marlin
		
	End If
	ShowZinfo("Just hanging out and waiting...")
	
End Sub


Private Sub btnStart_Click

	Dim b As Button : b = Sender
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	Dim msg As String = ""
	'mInProbeMode = False
	
	btn1.RequestFocus
	'btnPreheat.Visible = False
	
	If b.Text = "START" Then
		
		If oc.Klippy Then '--------------------Klipper firmware
			ShowZinfo("Preparing bed and tool...")
			guiHelpers.Show_toast2("Homing printer",1500)
			mainObj.Send_Gcode("G28")
			Sleep(1000)
			If pMode = ppMANUAL_MESH Then
				guiHelpers.Show_toast2("Starting manual mesh Z probe...",1500)
				B4XPages.MainPage.Send_Gcode("BED_MESH_CALIBRATE  METHOD=manual")
			Else '--- Z OFFSET time!
				guiHelpers.Show_toast2("Setting up for Z Offset...",1500)
				B4XPages.MainPage.Send_Gcode("G1 X100 Y100")
				B4XPages.MainPage.Send_Gcode("MANUAL_PROBE")
			End If
			#if debug
			'Log("WT: " & msg)
			#end if
		Else '-------------------- Marlin firmware
		
		End If
		
	
	else If b.Text = "ACCEPT" Or  b.Text = "DONE" Then
		If oc.Klippy Then
			'Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","ACCEPT"))) Complete (msg As String)		
			mainObj.Send_Gcode("ACCEPT")
			
		Else '-------------------- Marlin firmware
		
		End If
	
	End If
	
End Sub


'--- this is recieved as a callback from the octoprint socket

Public Sub Rec_Text(txt As String)
	If txt.Contains(CRLF) Then
		Dim cd() As String = Regex.Split(CRLF, txt)
		
		For Each s As String In cd
			Rec_Text2(s)
			Sleep(250) '--- 1/4 second between
		Next
	Else
		Rec_Text2(s)
	End If
End Sub


Private Sub Rec_Text2(txt As String)
	
	If oc.Klippy Then
		
		If pMode = ppMANUAL_MESH Then '--- manual bed level wiz
			
			Select Case True
				
				Case txt.Contains("y in a manual Z probe")
					'--- just started probe mode but are already in it so cancel and restart
					'mInProbeMode = False
					guiHelpers.Show_toast2("Already in a manual Z probe: Restarting...",6500)
					mainObj.Send_Gcode("ABORT")
					Sleep(2000)
					mainObj.Send_Gcode("BED_MESH_CALIBRATE  METHOD=manual")
					Sleep(2000)
					
				Case txt.Contains("g manual Z probe")
					'mInProbeMode = True
					If pMode = ppMANUAL_MESH Then '--- manual bed level wiz
						btn1.Text = "ACCEPT"
					Else
						btn1.Text = "DONE"
					End If
					btnClose.Visible = False
					btnPreheat.Visible = False
					btn2.Visible = True
				
				Case txt.Contains("Z pos")
					ParseZInfo(txt)
					
				Case txt.Contains("Manual probe failed") '--- mostly happens when just hitting ACCEPT and not moving nozzle 1st
					Probe_failed
					
				Case txt.Contains("has been saved")
					ShowZinfo("Process complete")
					ProcessMeshComplete
					
			End Select
			
			
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
		
	Else
		'--- Marlin time! ----------------------------
	
	End If
	
	#if debug
	'Log("RT: Not processed: " & txt)
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
	
	If oc.Klippy Then
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
			'mainObj.oMasterController.WSk.Send(krpc.GCODE.Replace("!G!","SAVE_CONFIG"))
			mainObj.Send_Gcode("SAVE_CONFIG")
			guiHelpers.Show_toast2("Saving CONFIG and restarting printer",5200)
			Main.tmrTimerCallSub.CallSubDelayedPlus(B4XPages.MainPage.oMasterController,"tmrMain_Tick",800)
		Else
			guiHelpers.Show_toast2("Using Mesh for current session, homing printer",3000)
			mainObj.Send_Gcode("G28")
			'mainObj.oMasterController.WSk.Send(krpc.GCODE.Replace("!G!","G28"))
		End If
	End If
	
	Close_Me
	Return
	
End Sub

Private Sub pnlBG_Click
	'--- eat the click
End Sub