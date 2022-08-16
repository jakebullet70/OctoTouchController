B4J=true
Group=HELPERS
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/11/2022
#End Region
'Static code module
Sub Process_Globals
	Private xui As XUI
	Private Const mModule As String = "guiHelpers" 'ignore
	
	Public gScreenSizeAprox As Double = 7 '--- asume a small tablet
	Public gScreenSizeDPI As Int = 0
	Public gScreenSizeOriatation As String = ""  '---  P or L
	
	'Private su As StringUtils
	
End Sub

Public Sub SetEnableDisableColor(btnArr() As B4XView)
	For Each btn As B4XView In btnArr
		If btn.enabled Then
			btn.TextColor = clrTheme.txtNormal
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,2dip)
		Else
			btn.TextColor = xui.Color_Gray
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_Gray,2dip)
		End If
	Next
End Sub

Public Sub EnableDisableBtns(btnArr() As B4XView,EnableDisable As Boolean)
	For Each btn As B4XView In btnArr
		btn.enabled = EnableDisable
	Next
	SetEnableDisableColor(btnArr)
End Sub

Public Sub GetAboutText() As String
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("OctoTouchController " & gblConst.VERSION).Append(CRLF)
	msg.Append("A dedicated touch screen controller").Append(CRLF).Append("for Octoprint using older Android devices").Append(CRLF)
	msg.Append(CRLF).Append("(c)sadLogic 2022 - Open Source - Freeware").Append(CRLF)
	Return msg.ToString
	
End Sub

'--- just an easy wat to Toast!!!!
public Sub Show_toast(msg As String, ms As Int)
	CallSub3(B4XPages.MainPage,"Show_Toast", msg, ms)
End Sub

public Sub HidePageParentObjs(obj() As B4XView)
	For Each o As B4XView In obj
		o.Visible = False
		o.Color = xui.Color_Transparent
	Next
End Sub


Public Sub SetActionBtnColorIsConnected(btn As B4XView)
	If oc.isConnected Then
		btn.TextColor = clrTheme.Go
	Else
		btn.TextColor = clrTheme.NoGo
	End If
End Sub


'public Sub ReSkinB4XComboBox(cb() As B4XComboBox)
'	
'	For Each v As B4XComboBox In cb
'		Try
'			'v.mBase.Color = clrTheme.DialogButtonsColor '---this is the arrow
'			'v.cmbBox.Color = clrTheme.PanelBG '--- NOPE
'			''
'			''			v.cmbBox.DropdownBackgroundColor=clrTheme.PanelBG
'			''			v.cmbBox.DropdownTextColor= clrTheme.txtNormal
'			''			v.cmbBox.TextColor = clrTheme.txtNormal
'			''			v.cmbBox.Prompt = "PROMT!" '--- NOTHING
'			''
'			''	'			Dim bb As B4XView
'			''	'			bb = v.mBase.GetView(0)
'			''			'Dim oo As B4XFont = xui.CreateDefaultFont(22)
'			''			v.cmbBox.TextSize = 22
'			''	'			'bb.TextColor = xui.Color_Green
'			''			'--- TODO - HOW TO CHANGE SIZE-COLOR OF CBO - SPINNER ARROW
'			''
'			'v.mBase.GetView(0).TextColor
'		Catch
'			Log(LastException)
'		End Try
'	Next
'End Sub

'public Sub SetTextColor(views() As B4XView, txtColor As Int)
'	
'	For Each o As B4XView In views
'		o.TextColor = txtColor
'	Next
'	
'End Sub



public Sub SetTextColorB4XFloatTextField(views() As B4XFloatTextField)
	
	For Each o As B4XFloatTextField In views
'		o.TextField.TextColor = txtColor
'		o.HintColor = hintColor
		o.TextField.TextColor = xui.Color_White
		o.HintColor = xui.Color_Yellow
		o.Update
	Next
	
End Sub

Public Sub ThemeInputDialogBtnsResize(dlg As B4XDialog)
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnCancel As B4XView = dlg.GetButton(xui.DialogResponse_Cancel)
		btnCancel.Width = btnCancel.Width + 20dip
		btnCancel.Left = btnCancel.Left - 28dip
		btnCancel.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,5dip)
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnOk As B4XView = dlg.GetButton(xui.DialogResponse_Positive)
		btnOk.Width = btnOk.Width + 20dip
		btnOk.Left = btnOk.Left - 48dip
		btnOk.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,5dip)
	Catch
		'Log(LastException)
	End Try 'ignore
		
End Sub


Public Sub ThemePrefDialogForm(prefdlg As sadPreferencesDialog)
	
	Try
		
		prefdlg.ItemsBackgroundColor = clrTheme.BackgroundMenu
		prefdlg.SeparatorBackgroundColor = clrTheme.BackgroundHeader
		prefdlg.SeparatorTextColor = xui.Color_LightGray
		prefdlg.TextColor = clrTheme.txtNormal
		
		
		'prefdlg.CustomListView1.sv.SetColorAndBorder(xui.Color_Transparent,1dip,xui.Color_blue,0dip)
		'prefdlg.mBase.SetColorAndBorder(xui.Color_Blue,2dip,xui.Color_White,5dip)
		'prefdlg.mBase.Color = clrTheme.BackgroundMenu
		'prefdlg.Dialog.BackgroundColor = xui.Color_Transparent
		'prefdlg.CustomListView1.AsView.Color = clrTheme.BackgroundMenu
		'prefdlg.CustomListView1.GetBase.Color = clrTheme.BackgroundMenu
		'prefdlg.CustomListView1. = clrTheme.BackgroundMenu
		
		
		ThemeDialogForm(prefdlg.Dialog,prefdlg.Title.As(String))
	Catch
		Log(LastException)
	End Try
	

End Sub


Public Sub ThemeDialogForm(dlg As B4XDialog,title As String)
	
	Try
		dlg.Title = title
	Catch
		'--- errors sometimes, I think...
		Log("ThemeDialogForm-set title: " & LastException)
	End Try 'ignore
	
	dlg.TitleBarFont = xui.CreateDefaultFont(22)
	dlg.TitleBarColor = clrTheme.BackgroundHeader
	dlg.ButtonsTextColor = clrTheme.txtNormal
	dlg.BorderColor = clrTheme.txtNormal
	dlg.BackgroundColor = clrTheme.BackgroundMenu
	dlg.ButtonsFont = xui.CreateDefaultFont(22)
	dlg.ButtonsHeight = 60dip
	
End Sub




