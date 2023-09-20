B4J=true
Group=B4X_EXT_CLASSES
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
' Helper class for 
#Region VERSIONS 
' V1.0  Apr/02/2023	1st run.
#End Region

Sub Class_Globals
	Private mModule As String = "sadB4XDrawerAdvancedHelper" 'ignore
	Public Drawer As sadB4XDrawerAdvanced 'ignore
	Public IsOpen As Boolean 'ignore
	Private xui As XUI
	Private btnSTOP,btnFRESTART,btnRESTART As Button 'ignore
	Private btnBrightness_F, btnScrnOff_R As Button 'ignore
	Private pnlBtnsDrawer As B4XView
End Sub


Public Sub Initialize(d As sadB4XDrawerAdvanced)
	Drawer = d
End Sub


Private Sub mnuPanel_StateChanged (Open As Boolean)
	IsOpen = Open
	If Open Then Display_Btns
End Sub


Public Sub BtnPressed(b As Button)
	
	Dim msg As String = ""
	Dim dl As Int = 12000
	
	Select Case b.Tag.As(String)
		Case "s" '--- emergency stop  
			B4XPages.MainPage.Send_Gcode("M112")
			msg = "EMERGENCY STOP!"

		Case "fr" '--- restart firmware	
			B4XPages.MainPage.Send_Gcode("FIRMWARE_RESTART")
			msg = "Firmware Restarting... Please wait a few moments..."
			oc.isConnected = False
			Main.tmrTimerCallSub.CallSubPlus(B4XPages.MainPage.oMasterController, "Start",10000)
			
		Case "r" '---  restart
			B4XPages.MainPage.Send_Gcode("RESTART")
			msg = "Host Restarting... Please wait a few moments..."
			oc.isConnected = False
			Main.tmrTimerCallSub.CallSubPlus(B4XPages.MainPage.oMasterController, "Start",10000)
			
		Case "br" '--- btnBrightness
			DoBrightnessDlg
			
		Case "soff"  '--- btnScreenOff
			CallSub2(Main,"TurnOnOff_ScreenTmr",False)
			fnc.BlankScreen
	End Select
	
	If msg.Length <> 0 Then '--- do we have a msg to show?
		guiHelpers.Show_toast2(msg,dl)
		Sleep(200)
	End If
	
	CloseRightMenu
	
End Sub




Public Sub SkinMe(b() As Button, p As B4XView,pb As B4XView)
	guiHelpers.SkinButton(b)
	'guiHelpers.SetVisible2(b,False)
	btnSTOP = b(0)
	btnFRESTART = b(1)
	btnRESTART = b(2)
	pnlBtnsDrawer = pb
	p.SetColorAndBorder(clrTheme.Background,2dip, clrTheme.txtNormal,2dip)
	
	If Not (oc.Klippy) Then
		btnBrightness_F = btnFRESTART '--- pointer
		btnScrnOff_R = btnRESTART '--- pointer
		Dim cs As CSBuilder, txt As Object
		txt = cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(4dip).Append(Chr(0xE327)). _
		Typeface(Typeface.DEFAULT).Append(CRLF & "Screen Off").PopAll
		btnScrnOff_R.Text = txt : btnScrnOff_R.Tag = "soff"
		txt = cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(4dip).Append(Chr(0xE430)). _
		Typeface(Typeface.DEFAULT).Append(CRLF & "Brightness").PopAll
		btnBrightness_F.Text = txt : btnBrightness_F.Tag = "br"
	Else
		btnFRESTART.Text = "RESTART FIRMWARE"
		btnFRESTART.Tag = "fr"
		btnRESTART.Text = "RESTART HOST"
		btnRESTART.Tag = "r"
	End If
		
End Sub

Public Sub Display_Btns
	
	If oc.Klippy Then
		If oc.IsKlippyConnected = False Then
			btnFRESTART.Visible = True
			btnRESTART.Visible = True
			btnSTOP.Visible = False
		Else
			btnFRESTART.Visible = False
			btnRESTART.Visible = False
			btnSTOP.Visible = True
		End If
	Else '--- no octoklipper
'		btnBrightness_F.Visible = True '--- pointer to btnFRESTART
'		btnScrnOff_R.Visible = True '--- pointer to btnRESTART
'		btnSTOP.Visible = False			
		btnBrightness_F.Visible = False '--- pointer to btnFRESTART
		btnScrnOff_R.Visible = False '--- pointer to btnRESTART
		btnSTOP.Visible = True
	End If
	
'	
'	#if klipper
'	If oc.isConnected = False And btnFRESTART.Visible = True Then Return
'	If oc.isConnected = False Then
'		btnFRESTART.Visible = True
'		btnRESTART.Visible = True
'		btnSTOP.Visible = False
'	Else
'		btnFRESTART.Visible = False
'		btnRESTART.Visible = False
'		btnSTOP.Visible = True
'	End If
'	#Else
''	btnBrightness_F.Visible = True '--- pointer to btnFRESTART
''	btnScrnOff_R.Visible = True '--- pointer to btnRESTART
''	btnSTOP.Visible = False
'	#End If
'	
	
	Dim j As DSE_Layout : j.Initialize
	j.SpreadHorizontally2(pnlBtnsDrawer,140dip,6dip,"center")
	If oc.Klippy Then 
		CallSubDelayed(B4XPages.MainPage ,"Build_RightSideMenu")
	End If
	
End Sub

#Region MENU_OPEN_CLOSE
Public Sub CloseRightMenu
	Drawer.setRightOpen(False)
End Sub
Public Sub OpenRightMenu
	Drawer.setRightOpen(True)
End Sub
Public Sub OpenLeftMenu
	Drawer.setLeftOpen(True)
End Sub
Public Sub CloseLeftMenu
	Drawer.setLeftOpen(False)
End Sub
#END REGION

#Region "BRIGHTNESS BTN SUPPORT"
Public Sub DoBrightnessDlg
	
	Dim o1 As dlgBrightness
	B4XPages.MainPage.pObjCurrentDlg1 = o1.Initialize("Screen Brightness",Me,"Brightness_Change")
	o1.Show(IIf(powerHelpers.pScreenBrightness < 0.05,0.1,powerHelpers.pScreenBrightness) * 100)
	
End Sub
Private Sub Brightness_Change(value As Float)
	
	'--- callback for btnBrightness_Click
	Dim v As Float = value / 100
	powerHelpers.SetScreenBrightnessAndSave(v,True)
	powerHelpers.pScreenBrightness = v
	
End Sub

#end region