B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.2		Apr/21/2023
'			Conveterd to full screen panel
' V. 1.1		Apr/10/2023
'			Refactored  for klipper
' V. 1.0 	Mar/11/2023
'			BOOM! stupid Muscovy (written while listening to an artillery dual)
' inspired / copied / stolen / borrowed from...
' https://github.com/jneilliii/OctoPrint-BedLevelingWizard
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "dlgBedLevelWiz"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mWizDlg As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper
	Private lblMsgSteps As Label, btnPreheat As Button

	Private mData As Map
	Private current_point As Int  = 0
	Private point1(),point2(),point3(),point4() As Int
	Private min_x, max_x,  min_y,max_y As Int 'ignore
	Private endGCode, startGCode As String
	Private zSpeed, xySpeed As Int
	Private gcodeSendLevelingPoint As String
	Private gcode2send,moveText As String
	Private parent As Panel
	
	#if klipper
	Private printerW,printerL As Int
	#end if
	
	Private pnlSteps,pnlBG,pnlHost As Panel
	
	Private btnClose,btn1,btn2 As Button
	Private alblHeader,alblMenu As AutoTextSizeLabel
	Private lblHeaterBed,lblHeaterTool As Label
	
	Private tmrHeaterOnOff As Timer
	
End Sub


'---
'--- Used for both Octoprint and Klipper
'---


Public Sub Initialize(p As Panel) As Object
	
	mainObj = B4XPages.MainPage
	p.RemoveAllViews
	parent = p
	
	#if klipper
	Dim m As Map = File.ReadMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE)
	printerW = m.Get( gblConst.psetupPRINTER_X)
	printerL  = m.Get( gblConst.psetupPRINTER_Y)
	#end if
	
	Return Me
	
End Sub

Private Sub BuildGUI
	pnlBG.Color = clrTheme.Background
	guiHelpers.SetTextColor(Array As B4XView(alblHeader.BaseLabel,alblMenu.BaseLabel,lblHeaterBed,lblHeaterTool))
	If guiHelpers.gIsLandScape = False Then  alblMenu.BaseLabel.Visible = False
	alblHeader.Text = "Manual Bed Leveling Wizard"
	parent.Visible = True
	pnlSteps.Color =clrTheme.Background
	guiHelpers.SkinButton(Array As Button(btnClose,btnPreheat,btn1,btn2))
End Sub

Public Sub Show
	
	Dim prefSavedData As Map = File.ReadMap(xui.DefaultFolder,gblConst.BED_MANUAL_LEVEL_FILE)
	endGCode   = prefSavedData.Get(gblConst.bedManualEndGCode)
	startGCode = prefSavedData.Get(gblConst.bedManualStartGcode)
	
	moveText = "You are at the !P! leveling position. Adjust your bed and press Next.'"
	
	parent.SetLayoutAnimated(0, 0, 0, parent.Width, parent.Height)
	parent.LoadLayout("wizManualBedLevel")
	BuildGUI
	
	mWizDlg.Initialize(pnlHost, "",pnlHost.Width , pnlHost.Height)
	mWizDlg.LoadFromJson(File.ReadString(File.DirAssets, "wizbedlevel.json"))
	mWizDlg.SetEventsListener(Me,"dlgGeneral")
	
	prefHelper.Initialize(mWizDlg)
	prefHelper.ThemePrefDialogForm
	Dim RS As ResumableSub = mWizDlg.ShowDialog(prefSavedData, "", "")
	prefHelper.dlgHelper.NoCloseOn2ndDialog
	'prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	
	BuildWizBtns

	tmrHeaterOnOff.Initialize("tmrHeater",1500)
	tmrHeater_Tick
	tmrHeaterOnOff.Enabled = True
	
	Wait For (RS) Complete (Result As Int)
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	tmrHeaterOnOff.Enabled = False
	tmrHeaterOnOff = Null
	
End Sub

Private Sub tmrHeater_Tick
	lblHeaterTool.Text ="Tool: " & CRLF & oc.Tool1Actual.Replace("C","")
	lblHeaterBed.Text = "Bed: " & CRLF & oc.BedActual.Replace("C","")
End Sub


Private Sub BuildWizBtns
	guiHelpers.ResizeText("Tool: " & CRLF & "200",lblHeaterTool)
	guiHelpers.ResizeText("Bed: " &CRLF & "100",	lblHeaterBed)
	btn1.Text = "START"
	btn2.Text = "STOP"
	btn1.TextSize =  20'mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).TextSize
	btn2.TextSize = btn1.TextSize
	
	'--- add steps info label
	lblMsgSteps.Initialize("")
	lblMsgSteps.Color = clrTheme.Background
	lblMsgSteps.TextColor = clrTheme.txtAccent
	lblMsgSteps.SetTextSizeAnimated(300,22)
	lblMsgSteps.SingleLine = False
	lblMsgSteps.Gravity = Bit.Or(Gravity.CENTER_VERTICAL, Gravity.CENTER_HORIZONTAL)
	lblMsgSteps.Text = "Bed Leveling Wizard"
	
	pnlSteps.AddView(lblMsgSteps, 2dip,  50dip,  _
				mWizDlg.CustomListView1.GetBase.GetView(0).Width-2dip,160dip)
	
	
	'--- add new buttons to dialog bottom
	btn2.Visible = False

	
End Sub

Private Sub btnStart_Click
	Dim b As Button : b = Sender
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	btn1.RequestFocus
	'btnPreheat.Visible = False
	
	If b.Text = "START" Then
		
		'--- read data used to move head
		mData = mWizDlg.PeekEditedData
		If SetMinMaxAndSpeeds = False Or SetPoints = False Then
			CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "STOP! Error parsing offsets / speeds:  " & current_point, 3500)
			Return
		End If
		
		current_point = 0
		b.Text = "NEXT"
		btn2.Visible = True
		btnClose.Visible = False
		'mWizDlg.CustomListView1.GetBase.GetView(0).Visible = False
		'mWizDlg.CustomListView1.GetBase.Visible = False
		'mWizDlg.mBase.Visible = False
		pnlSteps.Visible = True
		ProcessSteps
		Return
		
	End If
	
	'----------------------------
	
	If b.Text = "NEXT" Then
		current_point = current_point + 1
		ProcessSteps
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
End Sub

Private Sub ProcessSteps
	
	Dim txtHelp As Object 
	'Dim moveText As String = "You are at the !P! leveling position. Adjust your bed and press NEXT.'"
	mData = mWizDlg.PeekEditedData
	gcodeSendLevelingPoint = $"G1 Z${mData.Get(gblConst.bedManualLevelHeight)} F${zSpeed}"$
	logMe.LogDebug2("Point: " & current_point,"ProcessSteps")
	'btnPreheat.Visible = False
	
	
	Select Case current_point
		Case 0
			BeepMe(1)
			'btnPreheat.Visible = True
			lblMsgSteps.Text = "Starting GCode sent... Touch NEXT when complete to start the leveling sequence."
			SendMGcode(startGCode) : Wait For SendMGcode
			
		Case 1,2,3,4,5,6
			SendMGcode("G90") : Sleep(100) '--- absolute position
			
			Try

				'--- set travel height and speed				
				gcode2send = $"G1 Z${mData.Get(gblConst.bedManualTravelHeight)} F${zSpeed}"$
				SendMGcode(gcode2send) : Sleep(100)
				
				'--- sending movement
				Select Case current_point
					Case 1,5
						gcode2send = $"G1 X${point1(0)} Y${point1(1)} F${xySpeed}"$
						If current_point = 1 Then
							txtHelp = BuildHelpTextHighlight("first",moveText)
						Else
							txtHelp = BuildHelpTextHighlight("fifth",moveText)
						End If
						SendMGcode(gcode2send) : Sleep(100) '--- move to point
						
					Case 2,6
						If current_point = 2 Then
							txtHelp = BuildHelpTextHighlight("second",moveText)
						Else
							txtHelp = BuildHelpTextHighlight("sixth and final",moveText)
						End If
						gcode2send = $"G1 X${point2(0)} Y${point2(1)} F${xySpeed}"$
						SendMGcode(gcode2send) : Sleep(100) '--- move to point
						
					Case 3
						gcode2send = $"G1 X${point3(0)} Y${point3(1)} F${xySpeed}"$
						txtHelp = BuildHelpTextHighlight("third",moveText)
						SendMGcode(gcode2send) : Sleep(100) '--- move to point
						
					Case 4
						gcode2send = $"G1 X${point4(0)} Y${point4(1)} F${xySpeed}"$
						txtHelp = BuildHelpTextHighlight("forth",moveText)
						SendMGcode(gcode2send) : Sleep(100) '--- move to point
						
				End Select

				'--- lowers head so user can udjust				
				SendMGcode(gcodeSendLevelingPoint) : Sleep(100)
				
			Catch
				CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Something went wrong...", 3500)
				logMe.LogIt2(LastException.Message, mModule,"ProcessSteps")
				BeepMe(3)
				btnStop_Click
				Return
				
			End Try
			
		Case 7 '--- all done!
			CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Bed Leveling Complete... Sending end gcode.", 3500)
			SendMGcode(endGCode) : Sleep(200)
			BeepMe(1)
			btnStop_Click
			Return
			
	End Select
	
	lblMsgSteps.Text = txtHelp
	'xDialog.Close(xui.DialogResponse_Positive)
	
End Sub


'=================================================================

Private Sub SendMGcode(code As String)
	If code = "" Then Return
	
'	#if debug
	'Log(code)
'	Return
'	#End If
	
	If code.Contains(CRLF) Then
		Dim cd() As String = Regex.Split(CRLF, code)
		For Each s As String In cd
			#if klipper
			mainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!",s))
			#else
			mainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",s))
			#End If
			Sleep(50)
		Next
	Else
		#if klipper
		mainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!",code))
		#else
		mainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",code))
		#end if
	End If
	
	Return
	
End Sub



'======================================================================


Private Sub SetMinMaxAndSpeeds() As Boolean
	If oc.PrinterCustomBoundingBox = True Then
		'--- TODO
'		var min_x = parseInt(volume.custom_box.x_min());
'		var max_x = parseInt(volume.custom_box.x_max());
'		var min_y = parseInt(volume.custom_box.y_min());
'		var max_y = parseInt(volume.custom_box.y_max());
	Else
		min_x = 0 : min_y = 0
		max_x = oc.PrinterWidth
		max_y = oc.PrinterDepth
	End If
	
	Try
		zSpeed   = mData.Get(gblConst.bedManualZspeed)   * 60
		xySpeed = mData.Get(gblConst.bedManualXYspeed) * 60
	Catch
		logMe.LogIt2(LastException.Message, mModule,"SetMinMaxAndSpeeds")
		Return False
	End Try
	
	Return True
		
End Sub


Private Sub SetPoints() As Boolean

	Try
		
		#if klipper
		point1 = Array As Int(CalcRelitive(min_x  + mData.Get(gblConst.bedManualXYoffset),"L"), CalcRelitive(min_y  + mData.Get(gblConst.bedManualXYoffset),"W"))
		point2 = Array As Int(CalcRelitive(min_x  - mData.Get(gblConst.bedManualXYoffset),"L"), CalcRelitive(min_y  - mData.Get(gblConst.bedManualXYoffset),"W"))
		point3 = Array As Int(CalcRelitive(min_x  - mData.Get(gblConst.bedManualXYoffset),"L"), CalcRelitive(min_y  + mData.Get(gblConst.bedManualXYoffset),"W"))
		point4 = Array As Int(CalcRelitive(min_x  + mData.Get(gblConst.bedManualXYoffset),"L"), CalcRelitive(min_y  - mData.Get(gblConst.bedManualXYoffset),"W"))
		#else
		point1 = Array As Int(min_x  + mData.Get(gblConst.bedManualXYoffset), min_y  + mData.Get(gblConst.bedManualXYoffset))
		point2 = Array As Int(max_x - mData.Get(gblConst.bedManualXYoffset), max_y - mData.Get(gblConst.bedManualXYoffset))
		point3 = Array As Int(max_x - mData.Get(gblConst.bedManualXYoffset), min_y  + mData.Get(gblConst.bedManualXYoffset))
		point4 = Array As Int(min_x  + mData.Get(gblConst.bedManualXYoffset), max_y - mData.Get(gblConst.bedManualXYoffset))
		#End If
		Return True
	Catch
		logMe.LogIt2(LastException.Message, mModule,"SetPoints")
	End Try
	
	Return False
	
End Sub


#if klipper
Private Sub CalcRelitive(n As Int, LorW As String) As Int	
	If n >= 0 Then
		n = mData.Get(gblConst.bedManualXYoffset)
	Else
		If LorW = "L" Then
			n = printerL - Abs(mData.Get(gblConst.bedManualXYoffset))
		Else
			n = printerW - Abs(mData.Get(gblConst.bedManualXYoffset))
		End If
	End If
	Return n
End Sub
#End If


'======================================================================


Private Sub BuildHelpTextHighlight(txt2hiLight As String, maintxt As String) As Object
	
	Dim m1 As String = Regex.Split("!P!",maintxt)(0)
	Dim m2 As String = Regex.Split("!P!",maintxt)(1)
	
	Dim cs As CSBuilder : cs.Initialize
	Return cs.Color(clrTheme.txtAccent).Append(m1).Color(clrTheme.txtNormal).Append(txt2hiLight). _
					Color(clrTheme.txtAccent).Append(m2).PopAll
	
End Sub

Private Sub BeepMe(num As Int	)
	
	Dim b As Beeper :
	b.Initialize(120,500)
	For xx = 1 To num
		b.Beep : Sleep(200)
	Next
	
End Sub


Private Sub pnlBG_Click
	'--- needed to eat clicks when embeding a pref dialog into
	'--- another panel. Stupid java.
End Sub


'Private Sub dlgGeneral_IsValid (TempData As Map) As Boolean 'ignore
'	Return True '--- all is good!
'	'--- NOT USED BUT HERE IF NEEDED
'	
''	Try
''		Dim number As Int = TempData.GetDefault("days", 1)
''		If number < 1 Or number > 14 Then
''			guiHelpers.Show_toast("Days must be between 1 and 14",1200)
''			pdlgLogging.ScrollToItemWithError("days")
''			Return False
''		End If
''		Return True
''	Catch
''		Log(LastException)
''	End Try
''	Return False
'
'End Sub

'Private Sub dlgGeneral_BeforeDialogDisplayed (Template As Object)
'	prefHelper.SkinDialog(Template)
'End Sub

Private Sub btnClose_Click
	Close_Me
End Sub

Public Sub Close_Me
	parent.SetVisibleAnimated(500,False)
	mWizDlg.BackKeyPressed
	parent.RemoveAllViews
End Sub

Private Sub btnPreHeat_Click
	CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
End Sub