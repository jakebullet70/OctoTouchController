B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
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

	Private btn1,btn2 As Button, mData As Map
	Private current_point As Int  = 0
	Private point1(),point2(),point3(),point4() As Int
	Private min_x, max_x,  min_y,max_y As Int 'ignore
	Private endGCode, startGCode As String
	Private zSpeed, xySpeed As Int
	Private gcodeSendLevelingPoint As String
	Private gcode2send,moveText As String
	
	#if klipper
	Private printerW,printerL As Int
	#end if

	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	mainObj = mobj
	#if klipper
	Dim m As Map = File.ReadMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE)
	printerW = m.Get( gblConst.psetupPRINTER_X)
	printerL  = m.Get( gblConst.psetupPRINTER_Y)
	#end if
End Sub


Public Sub Show
	
	Dim prefSavedData As Map = File.ReadMap(xui.DefaultFolder,gblConst.BED_LEVEL_FILE)
	endGCode   = prefSavedData.Get(gblConst.bedEndGCode)
	startGCode = prefSavedData.Get(gblConst.bedStartGcode)
	
	moveText = "You are at the !P! leveling position. Adjust your bed and press Next.'"
	
	Dim h,w As Float '--- TODO - needs refactor
	w = 50%x
	If guiHelpers.gIsLandScape Then
		If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
			h = 62%y
		Else If guiHelpers.gScreenSizeAprox >= 8 Then
			h = 55%y
		Else '--- 4 to 5.9 inch
			h = 80%y
		End If
		w = 320dip
	Else
		h = 354dip
		w = guiHelpers.gWidth * .8
	End If
	
	
	mWizDlg.Initialize(mainObj.root, "Bed Level Wizard", w, h)
	mWizDlg.LoadFromJson(File.ReadString(File.DirAssets, "wizbedlevel.json"))
	mWizDlg.SetEventsListener(Me,"dlgGeneral")
	
	
	prefHelper.Initialize(mWizDlg)
	prefHelper.ThemePrefDialogForm
	mWizDlg.PutAtTop = False
	Dim RS As ResumableSub = mWizDlg.ShowDialog(prefSavedData, "", "CLOSE")
	prefHelper.dlgHelper.NoCloseOn2ndDialog
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	BuildWizBtns
	
	Wait For (RS) Complete (Result As Int)
	
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
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

Private Sub BuildWizBtns
	btn1.Initialize("ActionBtn1") : btn1.Text = "START"
	btn2.Initialize("ActionBtn2") : btn2.Text = "STOP"
	btn1.TextSize = mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).TextSize
	btn2.TextSize = btn1.TextSize
	
	
	'--- add steps info label
	lblMsgSteps.Initialize("")
	lblMsgSteps.Color = xui.Color_Transparent
	lblMsgSteps.Visible = False
	lblMsgSteps.TextColor = clrTheme.txtAccent
	lblMsgSteps.SetTextSizeAnimated(300,22)
	lblMsgSteps.SingleLine = False
	lblMsgSteps.Gravity = Bit.Or(Gravity.CENTER_VERTICAL, Gravity.CENTER_HORIZONTAL)
	lblMsgSteps.Text = "Bed Leveling Wizard"
	mWizDlg.mBase.AddView(lblMsgSteps, 2dip,  50dip,  _
				mWizDlg.CustomListView1.GetBase.GetView(0).Width-2dip,160dip)
	
	'--- add new buttons to dialog bottom
	Dim t,w,h As Float
	w = mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Width
	h = mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Height
	t = mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Top
	mWizDlg.Dialog.Base.AddView(btn1, 8dip, t, w,h)
	mWizDlg.Dialog.Base.AddView(btn2,  mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Left, t, w,h)
	btn2.Visible = False
	
	'--- build pre-heat button
	btnPreheat.Initialize("PreHeat")
	btnPreheat.Text = "Pre-Heat Menu"
	btnPreheat.TextSize = btn2.TextSize 
	Dim w2 As Int = (w * 2) - 8dip '--- make btn a little wide'eeeer!
	mWizDlg.Dialog.Base.AddView(btnPreheat, (lblMsgSteps.Width / 2) - (w2/2) ,  lblMsgSteps.Height +lblMsgSteps.top, w2,h)
	btnPreheat.Visible = False
	
	guiHelpers.SkinButton(Array As Button(btn1,btn2,btnPreheat))
	
End Sub

Private Sub PreHeat_Click
	CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
End Sub

Private Sub ActionBtn1_Click
	Dim b As Button : b = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	btn1.RequestFocus
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
		mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Visible = False
		mWizDlg.CustomListView1.GetBase.GetView(0).Visible = False
		lblMsgSteps.Visible = True
		ProcessSteps
		Return
		
	End If
	
	If b.Text = "NEXT" Then
		current_point = current_point + 1
		ProcessSteps
	End If
	'xDialog.Close(xui.DialogResponse_Positive)
End Sub

Private Sub ActionBtn2_Click
	'--- stop the action
	btn2.Visible = False
	btnPreheat.Visible = False
	btn1.Text = "START"
	mWizDlg.CustomListView1.GetBase.GetView(0).Visible = True
	mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Visible = True
	lblMsgSteps.Visible = False
	mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).RequestFocus '--- not working
	'btn1.RequestFocus '--- not working
End Sub

Private Sub ProcessSteps
	
	Dim txtHelp As Object 
	'Dim moveText As String = "You are at the !P! leveling position. Adjust your bed and press NEXT.'"
	mData = mWizDlg.PeekEditedData
	gcodeSendLevelingPoint = $"G1 Z${mData.Get(gblConst.bedLevelHeight)} F${zSpeed}"$
	logMe.LogDebug2("Point: " & current_point,"ProcessSteps")
	btnPreheat.Visible = False
	
	
	Select Case current_point
		Case 0
			BeepMe(1)
			btnPreheat.Visible = True
			lblMsgSteps.Text = "Starting GCode sent... Touch NEXT when complete to start the leveling sequence."
			SendMGcode(startGCode) : Wait For SendMGcode
			
		Case 1,2,3,4,5,6
			SendMGcode("G90") : Sleep(100) '--- absolute position
			
			Try

				'--- set travel height and speed				
				gcode2send = $"G1 Z${mData.Get(gblConst.bedTravelHeight)} F${zSpeed}"$
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
				ActionBtn2_Click
				Return
				
			End Try
			
		Case 7 '--- all done!
			CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Bed Leveling Complete... Sending end gcode.", 3500)
			SendMGcode(endGCode) : Sleep(200)
			BeepMe(1)
			ActionBtn2_Click
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
		zSpeed   = mData.Get(gblConst.bedZspeed)   * 60
		xySpeed = mData.Get(gblConst.bedXYspeed) * 60
	Catch
		logMe.LogIt2(LastException.Message, mModule,"SetMinMaxAndSpeeds")
		Return False
	End Try
	
	Return True
		
End Sub


Private Sub SetPoints() As Boolean

	Try
		
		#if klipper
		point1 = Array As Int(CalcRelitive(min_x  + mData.Get(gblConst.bedXYoffset),"L"), CalcRelitive(min_y  + mData.Get(gblConst.bedXYoffset),"W"))
		point2 = Array As Int(CalcRelitive(min_x  - mData.Get(gblConst.bedXYoffset),"L"), CalcRelitive(min_y  - mData.Get(gblConst.bedXYoffset),"W"))
		point3 = Array As Int(CalcRelitive(min_x  - mData.Get(gblConst.bedXYoffset),"L"), CalcRelitive(min_y  + mData.Get(gblConst.bedXYoffset),"W"))
		point4 = Array As Int(CalcRelitive(min_x  + mData.Get(gblConst.bedXYoffset),"L"), CalcRelitive(min_y  - mData.Get(gblConst.bedXYoffset),"W"))
		#else
		point1 = Array As Int(min_x  + mData.Get(gblConst.bedXYoffset), min_y  + mData.Get(gblConst.bedXYoffset))
		point2 = Array As Int(max_x - mData.Get(gblConst.bedXYoffset), max_y - mData.Get(gblConst.bedXYoffset))
		point3 = Array As Int(max_x - mData.Get(gblConst.bedXYoffset), min_y  + mData.Get(gblConst.bedXYoffset))
		point4 = Array As Int(min_x  + mData.Get(gblConst.bedXYoffset), max_y - mData.Get(gblConst.bedXYoffset))
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
		n = mData.Get(gblConst.bedXYoffset)
	Else
		If LorW = "L" Then
			n = printerL - Abs(mData.Get(gblConst.bedXYoffset))
		Else
			n = printerW - Abs(mData.Get(gblConst.bedXYoffset))
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


