B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.1 	Aug/7/2022  - Kherson Ukraine
'			Added code to bal file for larger screen size
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "pageMovement" 'ignore
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private mMainObj As B4XMainPage

	Private cboMovementSize As B4XComboBox
	Private MoveJogSize As String
	
	Private pnlJogMovement As B4XView
	Private pnlGeneral As B4XView
	
	Private btnMOff As Button
End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageMovement")
	
	Build_GUI
	
End Sub

public Sub Set_focus()
	mPnlMain.Visible = True
End Sub

public Sub Lost_focus()
	mPnlMain.Visible = False
End Sub


Private Sub Build_GUI
	
	'--- movement / jog sizes
	Dim options As List : options.initialize2(Array As String("0.1mm","1.0mm","10mm","100mm"))
	cboMovementSize.setitems(options)
	cboMovementSize.SelectedIndex = 1
	cboMovementSize.cmbBox.TextColor = clrTheme.txtNormal
	cboMovementSize.cmbBox.Color = clrTheme.BackgroundHeader
	cboMovementSize.cmbBox.DropdownBackgroundColor = clrTheme.BackgroundHeader
	cboMovementSize.cmbBox.DropdownTextColor = clrTheme.txtNormal
	MoveJogSize = "1.0"
	
End Sub


public Sub Update_Printer_Btns
	'--- sets enable, disable
	' if is printing then disable the panels
	
End Sub



Private Sub btnGeneral_Click
	
	If oc.JobPrintState <> "Operational" Then
		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
		Return
	End If
	
	Dim o As B4XView : o = Sender
	Select Case o.Tag
		Case "moff"
		Case "fon"
		Case "foff"
	End Select
End Sub



Private Sub btnXYZ_Click
	
	If oc.JobPrintState <> "Operational" Then
		guiHelpers.Show_toast(oc.cPRINTER_BUSY_MSG,2000)
		Return
	End If
	
	Dim btn As B4XView : btn = Sender
	Select Case btn.Tag
		
		Case "Zhome"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_Z_HOME)
		Case "XYhome"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XY_HOME)
		Case "Zup"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedZ,"-","")}"$ & MoveJogSize).Replace("!DIR!","z"))
		Case "Zdown"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!",$"${IIf(oc.PrinterProfileInvertedZ,"","-")}"$ & MoveJogSize).Replace("!DIR!","z"))
		Case "XYleft"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","-" & MoveJogSize).Replace("!DIR!","x")) 'TODO, add inverted check code
		Case "XYright"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","" & MoveJogSize).Replace("!DIR!","x"))
		Case "XYforward"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","-" & MoveJogSize).Replace("!DIR!","y"))
		Case "XYback"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cJOG_XYZ_MOVE.Replace("!SIZE!","" & MoveJogSize).Replace("!DIR!","y"))
	
	End Select

End Sub


Private Sub cboMovementSize_SelectedIndexChanged (Index As Int)
	MoveJogSize = cboMovementSize.SelectedItem.Replace("mm","")
End Sub


