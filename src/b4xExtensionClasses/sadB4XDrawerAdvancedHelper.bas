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
	Private btnSTOP,btnFRESTART,btnRESTART As Button
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
	Dim msg As String = "Restarting... Please wait a few moments..."
	Dim dl As Int = 8000
	Select Case b.Tag.As(String)
		#if klipper
		Case "s" '--- emergency stop  
			B4XPages.MainPage.oMasterController.WSk.Send($"{"jsonrpc": "2.0",	"method": "printer.emergency_stop",	"id": 4564}"$)
			'B4XPages.MainPage.oMasterController.cn.PostRequest("/printer/emergency_stop")
			msg = "EMERGENCY STOP!"
			dl = 3000
		Case "fr" '--- restart firmware	
			B4XPages.MainPage.oMasterController.cn.PostRequest("/printer/firmware_restart")
			'B4XPages.MainPage.oMasterController.WSk.Send($"{  "jsonrpc": "2.0",   "method": "printer.firmware_restart",   "id": 8463}"$)
			'Main.tmrTimerCallSub.CallSubPlus(B4XPages.MainPage.oMasterController, "Start",10000)
			
		Case "r" '---  restart
			B4XPages.MainPage.oMasterController.cn.PostRequest("/printer/firmware_restart")
			'--- this is failing and i have no idea why ------ printer.restart
			'B4XPages.MainPage.oMasterController.cn.PostRequest("printer/restart")
			'B4XPages.MainPage.oMasterController.WSk.Send($"{ "jsonrpc": "2.0", "method": "printer.restart",  "id": 4894}"$)
			'Main.tmrTimerCallSub.CallSubPlus(B4XPages.MainPage.oMasterController, "Start",10000)
		#end if
	End Select
	guiHelpers.Show_toast2(msg,dl)
	Sleep(200)
	CloseRightMenu
	
End Sub

Public Sub SkinMe(b() As Button, p As B4XView,pb As B4XView)
	guiHelpers.SkinButton(b)
	btnSTOP = b(0)
	btnFRESTART = b(1)
	btnRESTART = b(2)
	pnlBtnsDrawer = pb
	p.SetColorAndBorder(clrTheme.Background,2dip, clrTheme.txtNormal,2dip)
End Sub

Public Sub Display_Btns
	If oc.isConnected = False And btnFRESTART.Visible = True Then Return
	If oc.isConnected = False Then
		btnFRESTART.Visible = True
		btnRESTART.Visible = True
		btnSTOP.Visible = False
	Else
		btnFRESTART.Visible = False
		btnRESTART.Visible = False
		btnSTOP.Visible = True
	End If
	Dim j As DSE_Layout : j.Initialize
	j.SpreadHorizontally2(pnlBtnsDrawer,140dip,6dip,"center")
End Sub

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

