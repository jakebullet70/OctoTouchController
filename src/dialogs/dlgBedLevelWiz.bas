B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Mar/11/2023
'			This is UGLY! But it works but...  (BOOM! ) stupid Muscovy (written under daily shelling)
' copied / stolen / borrowed from...
' https://github.com/jneilliii/OctoPrint-BedLevelingWizard
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "dlgBedLevelWiz"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mWizDlg As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper
	Private msgSteps As Label

	Private btn1,btn2 As Button, mData As Map
	Private current_point As Int  = 0
	Private point1(),point2(),point3(),point4() As Int
	Private min_x, max_x,  min_y,max_y As Int
	Private endGCode, startGCode As String
	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	mainObj = mobj
End Sub


Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.BED_LEVEL_FILE)
	endGCode   = Data.Get(gblConst.bedEndGCode)
	startGCode = Data.Get(gblConst.bedStartGcode)
	
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
	Dim RS As ResumableSub = mWizDlg.ShowDialog(Data, "", "CLOSE")
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	BuildWizBtns
	
	Wait For (RS) Complete (Result As Int)
	
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
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
	guiHelpers.SkinButton(Array As Button(btn1,btn2))
	
	'--- add steps info label
	msgSteps.Initialize("")
	msgSteps.Color = xui.Color_Blue
	msgSteps.Visible = False
	mWizDlg.mBase.AddView(msgSteps, 18dip, 50dip, 60dip,60dip)
	
	'--- add new buttons
	Dim t,w,h As Float
	w = mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Width
	h = mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Height
	t = mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Top
	mWizDlg.Dialog.Base.AddView(btn1, 8dip, t, w,h)
	mWizDlg.Dialog.Base.AddView(btn2,  mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Left, t, w,h)
	btn2.Visible = False
	
End Sub

Private Sub ActionBtn1_Click
	Dim b As Button : b = Sender
		
	btn1.RequestFocus
	If b.Text = "START" Then

		'--- read data used to move head
		mData = mWizDlg.PeekEditedData
		SetMinMax
		If SetPoints = False Then
			CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "STOP! Error parsing offsets / speeds" & current_point, 3500)
			Return
		End If
		
		current_point = 0
		b.Text = "NEXT"
		btn2.Visible = True
		mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Visible = False
		mWizDlg.CustomListView1.GetBase.GetView(0).Visible = False
		msgSteps.Visible = True
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
	btn1.Text = "START"
	mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Visible = True
	mWizDlg.CustomListView1.GetBase.GetView(0).Visible = True
	msgSteps.Visible = False
End Sub

Private Sub ProcessSteps
	
	Dim Const myMethod As String = "ProcessSteps"
	Dim tmp As String
	mData = mWizDlg.PeekEditedData
	Log(current_point)
	
	Select Case current_point
		Case 0
			CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Homing Nozzle...", 2500)
			SendMGcode(startGCode) : Wait For SendMGcode
			
		Case 1,2,3,4,5,6
			CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Moving To Point " & current_point, 2500)
			SendMGcode("G90") : Sleep(100)
			
			Try
				
				'If current_point = 1 Then
					'self.gcode_cmds.push('G1 Z'+self.offset_z_travel()+' F'+self.travel_speed_probe());
					tmp = $"G1 Z${mData.Get(gblConst.bedTravelHeight} F${mData.Get(gblConst.bedZspeed}"$))
					SendMGcode(tmp) : Sleep(100)
				'End If
				
				Select Case current_point
					Case 1,5
'					self.gcode_cmds.push('G1 X'+self.point_a()[0]+' Y'+self.point_a()[1]+' F'+self.travel_speed());
'					self.gcode_cmds.push('G1 Z'+self.offset_z()+' F'+self.travel_speed_probe());
'					var options = {text: 'You are at the first leveling position.  Adjust the bed to be a height of "0" and press Next.'};
						tmp = $"G1 X${point1(0)} Y${point1(1)} F${mData.Get(gblConst.bedXYspeed)}"$
						SendMGcode(tmp) : Sleep(100)
					Case 2,6
						tmp = $"G1 X${point2(0)} Y${point2(1)} F${mData.Get(gblConst.bedXYspeed)}"$
						SendMGcode(tmp) : Sleep(100)
					Case 3
						tmp = $"G1 X${point3(0)} Y${point3(1)} F${mData.Get(gblConst.bedXYspeed)}"$
						SendMGcode(tmp) : Sleep(100)
					Case 4
						tmp = $"G1 X${point4(0)} Y${point4(1)} F${mData.Get(gblConst.bedXYspeed)}"$
						SendMGcode(tmp) : Sleep(100)
						
					Case Else '--- all done
						CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Bed Leveling Complete...", 3500)
						btn2.Visible = False
						btn1.Text = "START"
						mWizDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Visible = True
						current_point = -1
						SendMGcode(endGCode) : Sleep(200)
						
				End Select
				
				tmp = $"G1 Z${mData.Get(gblConst.bedTravelHeight)} F${mData.Get(gblConst.bedZspeed)}"$
				SendMGcode(tmp) : Sleep(100)
				
			Catch
				CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Something went wrong...", 2500)
				logMe.LogIt2(LastException.Message, mModule,myMethod)
			End Try
			
	End Select
	
	'xDialog.Close(xui.DialogResponse_Positive)
End Sub


'=================================================================

Private Sub SendMGcode(code As String)
	If code = "" Then Return
	Log(code)
	Return
	'TODO, check for CRLF
	mainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE_COMMAND.Replace("!CMD!",code))
End Sub


Private Sub SetMinMax
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
End Sub

Private Sub SetPoints() As Boolean
	Try
		'--- self.point_a([min_x + parseInt(self.offset_xy()),min_y + parseInt(self.offset_xy())]);
		point1 = Array As Int(min_x + mData.Get(gblConst.bedXYoffset), min_y + mData.Get(gblConst.bedXYoffset))
		'--- self.point_b([max_x - parseInt(self.offset_xy()),max_y - parseInt(self.offset_xy())]);
		point2 = Array As Int(max_x - mData.Get(gblConst.bedXYoffset), max_y - mData.Get(gblConst.bedXYoffset))
		'--- self.point_c([max_x - parseInt(self.offset_xy()),min_y + parseInt(self.offset_xy())]);
		point3 = Array As Int(max_x - mData.Get(gblConst.bedXYoffset), min_y + mData.Get(gblConst.bedXYoffset))
		'--- self.point_d([min_x + parseInt(self.offset_xy()),max_y - parseInt(self.offset_xy())]);
		point4 = Array As Int(min_x + mData.Get(gblConst.bedXYoffset), max_y - mData.Get(gblConst.bedXYoffset))
		Return True
	Catch
		Log(LastException)
	End Try
	Return False
	
End Sub


'Private Sub BeepMe
'	
'	Dim b As Beeper : 
'	b.Initialize(120,500)
'	For xx = 1 To 5
'		b.Beep : Sleep(200)
'	Next
'	
'End Sub

