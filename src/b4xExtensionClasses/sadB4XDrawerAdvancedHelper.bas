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
	Private mDrawer As sadB4XDrawerAdvanced 'ignore
	Public IsOpen As Boolean 'ignore
	Private xui As XUI
	Private btnSTOP,btnFRESTART,btnRESTART As Button
	Private pnlBtnsDrawer As B4XView
	'Private mLastOpenStatus As Boolean = False
End Sub


Public Sub Initialize(d As sadB4XDrawerAdvanced)
	mDrawer = d
End Sub


Private Sub mnuPanel_StateChanged (Open As Boolean)
	'If mLastOpenStatus = Open Then Return
	IsOpen = Open
	'mLastOpenStatus = Open
	If Open Then Display_Btns
End Sub


Public Sub BtnPressed(b As Button)
	Log(b.Tag)
	
	Select Case b.Tag.As(String)
		Case "s" '--- emergency stop  
			B4XPages.MainPage.oMasterController.cn.PostRequest("/printer/emergency_stop")
		Case "fr" '--- restart firmware	
			B4XPages.MainPage.oMasterController.cn.PostRequest("/printer/firmware_restart")
		Case "r" '---  restart
			B4XPages.MainPage.oMasterController.cn.PostRequest("/printer/firmware_restart")
			'B4XPages.MainPage.oMasterController.cn.PostRequest("printer/restart") --- this is failing and i have no idea why
	End Select
	guiHelpers.Show_toast2("Command Sent",3000)
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


