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
	Private mainObj As B4XMainPage
	Private xui As XUI
	
	
	
	'	Private current_point As Int  = 0
	'	Private endGCode, startGCode As String
	'	Private gcodeSendLevelingPoint As String
	'	Private gcode2send,moveText As String
	
	Private parent As Panel
	
	Private pnlSteps,pnlBG As Panel
	Private btnClose,btn1,btn2,btnPreheat As Button
	Private alblHeader,alblMenu As AutoTextSizeLabel
	Private lblHeaterBed,lblHeaterTool As Label
	
	Private tmrHeaterOnOff As Timer
	
	
	Private Button5,Button4 ,Button3,Button2,Button1 As Button
	Private lblZinfo As Label
	Private btnDn,btnUp As Button
	
End Sub

Public Sub Initialize(p As Panel)
	
	mainObj = B4XPages.MainPage
	p.RemoveAllViews
	parent = p

End Sub

Private Sub Check4MeshSupport() As ResumableSub
	
	Dim ns As String = "Mesh bed leveling is not supported in the firmware."
	#if klipper
	
	#else
	
	#End If
	
	Return True
End Sub



Public Sub Show(headerTxt As String)
	
	Wait For (Check4MeshSupport) Complete (b As Boolean)
	If b = False Then Return
	
	parent.SetLayoutAnimated(0, 0, 0, parent.Width, parent.Height)
	parent.LoadLayout("wizManualMeshBedLevel")
	BuildGUI(headerTxt)

	tmrHeaterOnOff.Initialize("tmrHeater",1500)
	tmrHeater_Tick
	tmrHeaterOnOff.Enabled = True
	
	
	
End Sub

Private Sub tmrHeater_Tick
	lblHeaterTool.Text ="Tool: " & CRLF & oc.Tool1Actual.Replace("C","")
	lblHeaterBed.Text = "Bed: " & CRLF & oc.BedActual.Replace("C","")
End Sub

Private Sub btnStart_Click

	Dim b As Button : b = Sender
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	btn1.RequestFocus
	'btnPreheat.Visible = False
	
	If b.Text = "START" Then
		#if klipper
		'Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","G28"))) Complete (msg As String)
		
		'Wait For (mainObj.oMasterController.WSk.SendAndWait(krpc.GCODE.Replace("!G!","BED_MESH_CALIBRATE  METHOD=manual"))) Complete (msg As String)
'		If msg.Contains("level bed") Then
'			Dim mb2 As dlgMsgBox2 : 	mb2.Initialize(mainObj.Root,"Question",280dip, 150dip,False)
'			mb2.NewTextSize = 32
'			Wait For (mb2.Show("Start print job?",gblConst.MB_ICON_QUESTION, "PRINT","","CANCEL")) Complete (res As Int)
'			If res = xui.DialogResponse_Cancel Then Return
'		Else if 1 =1  Then
'			
'		Else
'			Return
'		End If
		#else
		
		#End If
	End If
	
	'----------------------------
	
	If b.Text = "NEXT" Then
		#if klipper
		
		#else
		
		#End If
	End If
	
End Sub

Private Sub btnStop_Click
	'--- stop the action
	btn2.Visible = False
	'btnPreheat.Visible = True
	btn1.Text = "START"
	btnClose.Visible = True
	pnlSteps.Visible = False
	btnClose.RequestFocus
	guiHelpers.Show_toast2("Canceling... Disabling Steppers...",2500)
	mainObj.oMasterController.WSk.Send(krpc.GCODE.Replace("!G!","M18"))
End Sub


''=================================================================

Private Sub BeepMe(num As Int	)'ignore
	
	Dim b As Beeper :
	b.Initialize(120,500)
	For xx = 1 To num
		b.Beep : Sleep(200)
	Next
	
End Sub

Private Sub btnClose_Click
	'--- out of here!
	parent.Visible = False
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
	guiHelpers.SetTextColor(Array As B4XView(alblHeader.BaseLabel,alblMenu.BaseLabel,lblHeaterBed,lblHeaterTool))
	If guiHelpers.gIsLandScape = False Then  alblMenu.BaseLabel.Visible = False
	alblHeader.Text = headerTxt
	pnlSteps.Color =clrTheme.Background
	guiHelpers.SkinButton(Array As Button(btnClose,btnPreheat,btn1,btn2))
	guiHelpers.ResizeText("Tool: " & CRLF & "200",lblHeaterTool)
	guiHelpers.ResizeText("Bed: " &CRLF & "100",	lblHeaterBed)
	btn1.Text = "START" : btn2.Text = "STOP"
	btn1.TextSize =  20   : btn2.TextSize = btn1.TextSize
	guiHelpers.SkinButton_Pugin(Array As Button(btnDn,btnUp))
	parent.Visible = True
End Sub


Private Sub btnUpDown_Click
	Dim btn As Button = Sender
	If btn.Text.ToUpperCase.Contains("UP") Then
	Else
	End If
End Sub