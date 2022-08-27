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
	Public gFscale As Double
	
End Sub


'=====================================================================================
'  Generic GUI helper methods
'=====================================================================================


Public Sub SetEnableDisableColor(btnArr() As B4XView)
	For Each btn As B4XView In btnArr
		If btn.enabled Then
			btn.TextColor = clrTheme.txtNormal
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		Else
			btn.TextColor = clrTheme.btnDisableText
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_Gray,8dip)
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
		btn.TextColor = clrTheme.ConnectionYes
	Else
		btn.TextColor = clrTheme.ConnectionNo
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


Public Sub RestoreImersiveIfNeeded
	CallSub2(Main,"Activity_WindowFocusChanged",True)
End Sub


public Sub SetTextColorB4XFloatTextField(views() As B4XFloatTextField)
	
	For Each o As B4XFloatTextField In views
		o.TextField.TextColor = clrTheme.txtNormal
		o.HintColor = clrTheme.txtAccent
		o.Update
	Next
	
End Sub


Public Sub ThemeInputDialogBtnsResize(dlg As B4XDialog)
	
	Dim IsBtnCancel,IsBtnYes As Boolean = False
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnCancel As B4XView = dlg.GetButton(xui.DialogResponse_Cancel)
		If btnCancel.IsInitialized Then
			btnCancel.Font = xui.CreateDefaultFont(NumberFormat2(btnCancel.Font.Size / gFscale,1,0,0,False))
			btnCancel.Width = btnCancel.Width + 20dip
			btnCancel.Left = btnCancel.Left - 28dip
			btnCancel.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,8dip)
			IsBtnCancel = True
		End If
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnYes As B4XView = dlg.GetButton(xui.DialogResponse_Positive)
		If btnYes.IsInitialized Then
			btnYes.Font = xui.CreateDefaultFont(NumberFormat2(btnYes.Font.Size / gFscale,1,0,0,False))
			btnYes.Width = btnYes.Width + 20dip
			If IsBtnCancel Then
				btnYes.Left = btnYes.Left - btnCancel.Width + 2dip
			Else
				btnYes.Left = btnYes.Left - 10dip
			End If
			'btnYes.Left = btnYes.Left - 48dip
			btnYes.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,8dip)
			IsBtnYes = True
		End If
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnNo As B4XView = dlg.GetButton(xui.DialogResponse_Negative)
		If btnNo.IsInitialized Then
			btnNo.Font = xui.CreateDefaultFont(NumberFormat2(btnNo.Font.Size / gFscale,1,0,0,False))
			btnNo.Width = btnYes.Width + 20dip
			btnNo.Left = btnNo.Left - 48dip
			btnNo.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,8dip)
		End If
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
		logMe.LogIt2(LastException,mModule,"ThemePrefDialogForm")
	End Try
	

End Sub


Public Sub ThemeDialogForm(dlg As B4XDialog,title As String)
	ThemeDialogForm2(dlg,title,22)
End Sub


Public Sub ThemeDialogForm2(dlg As B4XDialog,title As String,txtSize As Int)
	
	Try
		dlg.Title = title
	Catch
		'--- errors sometimes, I think... something to do with the title not showing on smaller screens
		'--- b4xdialog.PutAtTop = False  <----   this!
		'Log("ThemeDialogForm-set title: " & LastException)
	End Try 'ignore
	
	dlg.TitleBarFont = xui.CreateDefaultFont(NumberFormat2(22 / gFscale,1,0,0,False))
	dlg.TitleBarColor = clrTheme.BackgroundHeader
	dlg.ButtonsTextColor = clrTheme.txtNormal
	dlg.BorderColor = clrTheme.txtNormal
	dlg.BackgroundColor = clrTheme.BackgroundMenu
	dlg.ButtonsFont = xui.CreateDefaultFont(txtSize)
	dlg.ButtonsHeight = 60dip
	
	
End Sub


public Sub SetTextColor(obj() As B4XView)
	For Each o As B4XView In obj
		o.TextColor = clrTheme.txtNormal
	Next
End Sub

