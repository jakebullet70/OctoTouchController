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
	Private mOBJ As B4XMainPage'ignore
	Private oWS As OctoWebSocket
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
	Private mInProbeMode As Boolean = False
	
	Private btnDn,btnUp As Button
	
	Public pMode As String 
	Public Const ppMANUAL_MESH As String = "mblw"
	
	Private alblZinfo As AutoTextSizeLabel
	Private oBeepMe As SoundsBeeps
	
	Private btnDst5,btnDst4,btnDst3,btnDst2,btnDst1 As B4XView
	
	
	Private mCurrentMarlinZ As Float = 0
	Private mOldMarlinZ As Float = -999
	
	
	
	
	
End Sub

Public Sub Initialize(p As Panel,mode As String) As Object
	
	mOBJ = B4XPages.MainPage
	p.RemoveAllViews
	parent = p
	pMode = mode
	oBeepMe.Initialize
	oWS = mOBJ.oMasterController.oWS
	Return Me

End Sub
Private Sub pnlBG_Click
	'--- eat the click
End Sub

Private Sub tmrHeater_Tick
	lblHeaterTool.Text ="Tool: " & CRLF & oc.Tool1Actual.Replace("C","")
	lblHeaterBed.Text = "Bed: " & CRLF & oc.BedActual.Replace("C","")
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
	
	If oc.Klippy Then
		mOBJ.oMasterController.oWS.pParserWO.RaiseEventMod = Me
		mOBJ.oMasterController.oWS.pParserWO.RaiseEventEvent = "rec_text"
	End If
	
End Sub



Private Sub btnClose_Click
	Close_Me
End Sub

Public Sub Close_Me  '--- class method, also called from android back btn
	'--- out of here!
	If oc.Klippy Then
		mOBJ.oMasterController.oWS.pParserWO.ResetRaiseEvent
		If mInProbeMode Then 
			mOBJ.Send_Gcode(oc.cKLIPPY_ABORT)
		End If
	Else '--- marlin
		
	End If
	parent.SetVisibleAnimated(500,False)
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	Try '--- blowing up when app ends. Why? 
		If tmrHeaterOnOff.IsInitialized Then
			tmrHeaterOnOff.Enabled = False
			tmrHeaterOnOff = Null
		End If
	Catch
		Log(LastException)
	End Try
	parent.RemoveAllViews
	'mOBJ.pObjWizards=Null
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
	mInProbeMode = False
	btn2.Visible = False
	btnPreheat.Visible = True
	btn1.Text = "START"
	btnClose.Visible = True
	btnClose.RequestFocus
End Sub



Private Sub DistanceBtnsLookReset
	guiHelpers.SkinButton(Array As Button(btnDst1,btnDst2,btnDst3,btnDst4,btnDst5))
End Sub


Private Sub btnDst_Click
	Dim b As Button : b = Sender
	btnDistance_Highlight(b.As(B4XView))
	mDIstance = b.Text
	CallSubDelayed(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	'oBeepMe.Beeps(300,500,1)
End Sub

Private Sub btnDistance_Highlight(b As B4XView)
	DistanceBtnsLookReset
	b.SetColorAndBorder(xui.Color_Transparent, 6dip,clrTheme.txtAccent,6dip)
End Sub


Private Sub ShowZinfo(info As String)
	If info = "" Then info = "Z Location ???"
	If oc.Klippy Then
		info = info.Replace("Z position: ","Z pos: ")
	End If
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
		mOBJ.Send_Gcode(oc.cKLIPPY_ABORT)
		mOBJ.Send_Gcode("M18") '--- disable steppers
	Else '--- Marlin
		oWS.pParserWO.EventRemove("ZChange")
		oWS.pParserWO.MsgsRemove("M851 ") '--- just in case the event msg is still there
		If mOldMarlinZ < -500 Then
			Log("invalid oldMarlinZ")
			mOBJ.Send_Gcode($"M501"$) '--- reset Z back to original
		Else
			Log("good oldMarlinZ")
			mOBJ.Send_Gcode($"M851 Z${Round2(mOldMarlinZ,2)}"$) '--- reset Z back to original
		End If
		mOBJ.Send_Gcode("M18") '--- disable steppers
		mOBJ.Send_Gcode("G90") '--- absolute position
		mOBJ.Send_Gcode("M211 S1") '--- turn on software end stops
	End If
	ShowZinfo("Just hanging out and waiting...")
	mInProbeMode = False
	
	
End Sub


Private Sub btnStart_Click

	Dim b As Button : b = Sender
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	'Dim msg As String = ""
	mInProbeMode = True
	
	btn1.RequestFocus
	'btnPreheat.Visible = False
	
	
	'--- Starting 
	If b.Text = "START" Then
		
		ShowZinfo("Preparing printer...")
		guiHelpers.Show_toast2("Homing printer",2500)
		
		
		#region "KLIPPY"	
		If oc.Klippy Then '--------------------Klipper firmware
			
			mOBJ.Send_Gcode("G28")
			Sleep(1000)
			
			'--- what are we doing?
			If pMode = ppMANUAL_MESH Then
				
				guiHelpers.Show_toast2("Starting manual mesh Z probe...",2500)
				mOBJ.Send_Gcode("BED_MESH_CALIBRATE  METHOD=manual")
				
			Else '--- Z OFFSET time!
				
				guiHelpers.Show_toast2("Setting up for Z Offset...",2500)
				mOBJ.Send_Gcode($"G1 Z5 X${oc.PrinterWidth / 2} Y${oc.PrinterDepth / 2} F4000"$)
				Sleep(500)
				mOBJ.Send_Gcode("MANUAL_PROBE")
				
			End If
			#end region
		Else '-------------------- Marlin firmware
			
			'--- what are we doing?
			If pMode = ppMANUAL_MESH Then
				'--- when I get a marlin printer WITHOUT auto bed leveling I will add this in, Hard to justify spending money in the middle of a war
				'--- when today might be my last day living. Kherson Ukraine, Sept - 2023
				
			Else '--- Z OFFSET time!
				
				If oc.PrinterWidth = 0 Then
					Log("oc.PrinterWidth = 0")
				End If
				
				'"^Recv:"
				
'				'--- set subscriptions
'				Dim subscribe As String = $"{"subscribe": {
'				    "state": {
'				      "logs": false,
'				      "messages": true,
'					  "resends": false,
'					  "job": false,
'					  "temps": false,
'					  "state": false,
'					  "progress": false,
'					  "flags": false},
'				    "events": true,
'				    "plugins": ["OctoKlipper","klipper"]}
'					}"$
'	
'	
'				'Log(subscribe.Replace(CRLF," "))
'				oWS.Send(subscribe)
'				Sleep(400)
				
				'https://www.3dprintbeast.com/marlin-z-offset/
				oWS.pParserWO.MsgsAdd("M851 ",Me,"parse_z_offset_msg")
				oWS.setThrottle("1") : Sleep(1500)
				'oWS.bLastMessage = True
				mOldMarlinZ = -999
				mOBJ.Send_Gcode("M851") : Sleep(1500)
				Do While mOldMarlinZ = -999
					Sleep(0)
				Loop
				
				oWS.setThrottle("90")
				
				
				'oWS.bLastMessage = False
				'fileHelpers.WriteTxt2SharedFolder("out.txt",mOBJ.oMasterController.oWS.mlastMsg)
					
								
				oWS.pParserWO.EventAdd("ZChange",Me,"rec_text")
				'mOldMarlinZ = 0.00
				mCurrentMarlinZ = 8.00
				
				mOBJ.Send_Gcode("G90") '--- absolute position
				mOBJ.Send_Gcode("M851 Z0.0") '--- reset Z
				Sleep(1000)
				mOBJ.Send_Gcode("G28")
				Sleep(1000)
				
				guiHelpers.Show_toast2("Setting up for Z Offset...",2900)
'				Wait For (GetMarlinZoffset) Complete (r As String)
'				If strHelpers.IsNullOrEmpty(r) Then
'					guiHelpers.Show_toast2("M851 - Invalid Z, Cannot continue.",5000)
'					Return
'				End If
				

				mOBJ.Send_Gcode("M211 S0") '--- turn off software end stops
				mOBJ.Send_Gcode($"G1 Z8 X${oc.PrinterWidth / 2} Y${oc.PrinterDepth / 2} F4000"$)
				'mOBJ.Send_Gcode("G91") '--- back to relitive position
				btn1.Text = "DONE"
				btn2.Visible = True
				btnClose.Visible = False
				btnPreheat.Visible = False
				'oWS.pParserWO.MsgsRemove("M851")
				
			End If
		End If
		
	
	else If b.Text = oc.cKLIPPY_ACCEPT Or b.Text = "DONE" Then
		
		If oc.Klippy Then
			
			'--- same for Z-Offset or Manual mesh
			mOBJ.Send_Gcode(oc.cKLIPPY_ACCEPT)
			
		Else '-------------------- Marlin firmware
			
			If pMode = ppMANUAL_MESH Then
				'--- when I get a marlin printer WITHOUT auto bed leveling I will add this in, Hard to justify spending money in the middle of a war
				'--- when today might be my last day living.
				
			Else '--- Z OFFSET time! - all done!
				
				'https://3dprinting.stackexchange.com/questions/9820/specifying-z-offset-in-marlin-firmware
				mOBJ.Send_Gcode($"M851 Z${mCurrentMarlinZ}"$)
				mOBJ.Send_Gcode("G91")  '--- absolute position
				ProcessMeshComplete
			
			End If
			
		End If
	
	End If
	
End Sub

Private Sub parse_z_offset_msg(txt As String)
	
	'--- called from 
	mOldMarlinZ = -998
	Try
		Dim z1 As Int = txt.IndexOf("Z")
		Dim z2 As Int = txt.IndexOf(";")
		Dim ret As String = txt.SubString2(z1 + 1,z2 - 1).Trim
		If IsNumber(ret) Then
			mOldMarlinZ = Round2(ret.As(Float),2)
		End If
	Catch
		Log(LastException)
	End Try
	oWS.pParserWO.MsgsRemove("M851 ") 

End Sub


Private Sub btnUpDown_Click
	Dim btn As Button = Sender
	If btn1.Text = "START" Or mInProbeMode = False Then
		Return
	End If
	
	'--- calc the move
	Dim nVal As String = Round2(mDIstance,3).As(String)
	If btn.Text.ToUpperCase.Contains("LO") Then
		If oc.Klippy Then
			nVal = "-" & nVal
		Else
			mCurrentMarlinZ = mCurrentMarlinZ - nVal
		End If
	Else
		If oc.Klippy Then
			'--- do nothing
		Else
			mCurrentMarlinZ = mCurrentMarlinZ + nVal
		End If
	End If
	
	'--- 
	If oc.Klippy Then
		mOBJ.Send_Gcode("TESTZ Z=" & nVal)
	Else '--- Marlin
		mCurrentMarlinZ = Round2(mCurrentMarlinZ,2)
		mOBJ.Send_Gcode("G1 Z" & Round2(mCurrentMarlinZ,2))
	End If
	'btn.RequestFocus
	'Log("btnUP-DN: " & msg)
End Sub


#Region "SOCKET EVENT CALLBACK"
'--- this is recieved as a callback from the octoprint socket
Public Sub Rec_Text(txt As String)
	If txt.Contains(CRLF) Then
		Dim cd() As String = Regex.Split(CRLF, txt)
		
		For Each s As String In cd
			Rec_Text2(s)
			Sleep(250) '--- 1/4 second between
		Next
	Else
		Rec_Text2(txt)
	End If
End Sub


Private Sub Rec_Text2(txt As String)

	logMe.LogDebug2("rec txt:" & txt,"")

	If oc.Klippy Then
		
		If pMode = ppMANUAL_MESH Then '--- manual bed level wiz
			
			Select Case True
				
				Case txt.Contains("y in a manual Z probe")
					'--- just started probe mode but are already in it so cancel and restart
					RestartAlreadyIn
					
				Case txt.Contains("g manual Z probe")
					
					If pMode = ppMANUAL_MESH Then '--- manual bed level wiz
						btn1.Text = oc.cKLIPPY_ACCEPT
					Else
						btn1.Text = "DONE"
					End If
					btnClose.Visible = False
					btnPreheat.Visible = False
					btn2.Visible = True
				
				Case txt.Contains("Z pos")
					ParseZInfo(txt)
					
				Case txt.Contains("Manual probe failed") '--- mostly happens when just hitting ACCEPT and not moving nozzle 1st
					Probe_failed_klippy
					
				Case txt.Contains("has been saved")
					ShowZinfo("Process complete")
					ProcessMeshComplete
					
			End Select
			
			
		Else
			
			'--- Z offset
			Select Case True
				
				Case txt.Contains("Already in a manual Z p")
					RestartAlreadyIn
					
				Case txt.Contains("g manual Z probe")
					btn1.Text = "DONE"
					btn2.Visible = True
					btnClose.Visible = False
					btnPreheat.Visible = False
				
				Case txt.Contains("Z position is")
					ProcessMeshComplete
					
				Case txt.Contains("Z pos")
					ParseZInfo(txt)
				Case Else
					Log("else:" & txt)
						
			End Select
				
		End If
		
	Else
		'--- Marlin time! ----------------------------
		'--- when I get a marlin printer WITHOUT auto bed leveling I will add this in, Hard to justify spending money in the middle of a war
		'--- and really, we might get killed and our home destroyed today.
		Log(txt)
		ProcessMarlinMoveMsg(txt)
		ShowZinfo(txt)
	End If
	
	#if debug
	'Log("RT: Not processed: " & txt)
	#end if
	
End Sub

Private Sub ProcessMarlinMoveMsg(msg As String)
	
	Try
		If msg.Contains("???") Then Return
		Dim sp As Int = msg.IndexOf("New Z=")
		Dim tmp As String = msg.SubString(sp).Replace("New Z=","").Replace("*","").Trim
		mCurrentMarlinZ = Round2(tmp,2)
		Log("G1 Z" & tmp)
	Catch
		Log(LastException)
	End Try
	
		
End Sub

Private Sub RestartAlreadyIn '--- Klippy ONLY
	guiHelpers.Show_toast2("Manual Z probe already started: Restarting...",6500)
	mOBJ.Send_Gcode(oc.cKLIPPY_ABORT)
	Sleep(2000)
	If pMode = ppMANUAL_MESH Then
		mOBJ.Send_Gcode("BED_MESH_CALIBRATE  METHOD=manual")
	Else
		mOBJ.Send_Gcode("MANUAL_PROBE")
	End If
	Sleep(2000)
	Return
End Sub


#end region


Private Sub Probe_failed_klippy
	'--- mostly happens when just hitting ACCEPT and not moving nozzle 1st - KLIPPY only
	ShowZinfo("probe failed...")
	ProcessStop_GUI
End Sub


Private Sub ProcessMeshComplete'ignore
	
	Dim m As StringBuilder: m.Initialize
	
	Select Case True
		Case oc.Klippy And pMode = ppMANUAL_MESH
			m.Append("Bed Mesh state has been saved to profile [default] for the ")
			m.Append("current session. Touch SAVE to update the printer config ")
			m.Append("File And restart the printer or CLOSE to just use the current mesh")
			Wait For (SavePrompt(m.ToString)) Complete (res As Int)
			
			If res = xui.DialogResponse_Positive Then
				mOBJ.Send_Gcode(oc.cKLIPPY_SAVE)
				guiHelpers.Show_toast2("Saving CONFIG and restarting printer",5200)
				Main.tmrTimerCallSub.CallSubDelayedPlus(mOBJ.oMasterController,"tmrMain_Tick",800)
			Else
				guiHelpers.Show_toast2("Using Mesh for current session, homing printer",3000)
				mOBJ.Send_Gcode("G28")
			End If
			
			
		Case oc.Klippy And pMode <> ppMANUAL_MESH '--- Z-Offset
			m.Append("New Z-Offset will be used for the current session.")
			m.Append("Touch SAVE to update the printer config file And ")
			m.Append("restart the printer or CLOSE to just use the current offset")
			Wait For (SavePrompt(m.ToString)) Complete (res As Int)
			
			'mOBJ.Send_Gcode(oc.cKLIPPY_ACCEPT)  '--- has already been sent
			
			If res = xui.DialogResponse_Positive Then
				mOBJ.Send_Gcode(oc.cKLIPPY_SAVE)
				guiHelpers.Show_toast2("Saving new Z-Offset and restarting printer",5200)
				Main.tmrTimerCallSub.CallSubDelayedPlus(mOBJ.oMasterController,"tmrMain_Tick",800)
			Else
				guiHelpers.Show_toast2("Using Z-Offset for current session, homing printer",4000)
				mOBJ.Send_Gcode("G28")
			End If

		Case oc.Klippy = False And pMode = ppMANUAL_MESH
			'--- when I get a marlin printer WITHOUT auto bed leveling I will add this in, Hard to justify spending money in the middle of a war
						
		Case oc.Klippy = False And pMode <> ppMANUAL_MESH '--- Z-Offset
			mOBJ.oMasterController.oWS.pParserWO.EventRemove("ZChange")
			m.Append("New Z-Offset will be used for the current session.")
			m.Append("Touch SAVE to update your printers the EEPROM ")
			m.Append("or CLOSE to just use the current offset.")
			Wait For (SavePrompt(m.ToString)) Complete (res As Int)
			
			If res = xui.DialogResponse_Positive Then
				mOBJ.Send_Gcode("M500")
				guiHelpers.Show_toast2("New Z-Offset saved to EEPROM",4000)
			Else
				guiHelpers.Show_toast2("Using Z-Offset for current session",4000)
			End If
			mOBJ.Send_Gcode("M211 S1") '--- turn on software end stops
			mOBJ.Send_Gcode("G28")
			
			
	End Select

	
	Close_Me '--- out of here, exit wizard
	Return
	
End Sub



Private Sub SavePrompt(msg As String) As ResumableSub

	Dim w,h As Float
	If guiHelpers.gIsLandScape Then
		w = guiHelpers.gWidth * .7
		h = guiHelpers.MaxVerticalHeight_Landscape
	Else
		w = guiHelpers.gWidth * .8 : h = 310dip
	End If
	Dim mb2 As dlgMsgBox2 : mb2.Initialize(mOBJ.Root,"Question", w, h,False)
	mb2.NewTextSize = 24
	Wait For (mb2.Show(msg,gblConst.MB_ICON_QUESTION, "SAVE","","CLOSE")) Complete (res As Int)
	Return res

	
End Sub








