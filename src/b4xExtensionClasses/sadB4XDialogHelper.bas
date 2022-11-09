B4J=true
Group=B4X_EXT_CLASSES
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
' Helper class for B4XDialog V11.8
#Region VERSIONS 
' V1.0  Nov/8/2022	1st run.
#End Region

Sub Class_Globals
	Private xui As XUI
	Private dlg As B4XDialog
	Private Scale As Float
End Sub

Public Sub Initialize(oDlg As B4XDialog)  As sadB4XDialogHelper
	dlg = oDlg
	Dim ac As Accessibility
	Scale = ac.GetUserFontScale
	Return Me
End Sub


Public Sub ThemeInputDialogBtnsResize()
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnCancel As B4XView = dlg.GetButton(xui.DialogResponse_Cancel)
		btnCancel.Font = xui.CreateDefaultFont(NumberFormat2(btnCancel.Font.Size / Scale,1,0,0,False))
		btnCancel.Width = btnCancel.Width + 20dip
		btnCancel.Left = btnCancel.Left - 28dip
		btnCancel.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		'SkinButton(Array As Button(btnCancel))
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnOk As B4XView = dlg.GetButton(xui.DialogResponse_Positive)
		btnOk.Font = xui.CreateDefaultFont(NumberFormat2(btnOk.Font.Size / Scale,1,0,0,False))
		btnOk.Width = btnOk.Width + 20dip
		btnOk.Left = btnOk.Left - 48dip
		btnOk.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		'SkinButton(Array As Button(btnOk))
	Catch
		'Log(LastException)
	End Try 'ignore
	
'	Try '--- reskin button, if it does not exist then skip the error
'		Dim btnNo As B4XView = dlg.GetButton(xui.DialogResponse_Negative)
'		btnNo.Font = xui.CreateDefaultFont(NumberFormat2(btnNo.Font.Size / gFscale,1,0,0,False))
'		btnNo.Width = btnOk.Width + 20dip
'		btnNo.Left = btnOk.Left - 48dip
'		btnNo.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,8dip)
'	Catch
'		'Log(LastException)
'	End Try 'ignore
		
End Sub



Public Sub ThemeDialogForm(title As Object)
	Dim size As Float = IIf(guiHelpers.gScreenSizeAprox > 6,25,22)
	ThemeDialogForm2(title,size)
End Sub


Public Sub ThemeDialogForm2(title As Object,txtSize As Int)
	
	Try
		dlg.Title = title
		'dlg.TitleBarHeight=6%y
	Catch
		'--- errors sometimes, I think... something to do with the title not showing on smaller screens
		'--- b4xdialog.PutAtTop = False  <----   this!
		'Log("ThemeDialogForm-set title: " & LastException)
	End Try 'ignore
	
	dlg.TitleBarFont = xui.CreateDefaultFont(NumberFormat2(txtSize / guiHelpers.gFscale,1,0,0,False))
	dlg.TitleBarColor = clrTheme.BackgroundHeader
	dlg.TitleBarTextColor = clrTheme.txtNormal
	dlg.ButtonsTextColor = clrTheme.txtNormal
	dlg.BorderColor = clrTheme.txtNormal
	dlg.BackgroundColor = clrTheme.Background2
	dlg.ButtonsFont = xui.CreateDefaultFont(txtSize)
	dlg.ButtonsHeight = 60dip
	dlg.BorderCornersRadius = 4dip
	'dlg.BorderWidth=4dip
	
	
End Sub
