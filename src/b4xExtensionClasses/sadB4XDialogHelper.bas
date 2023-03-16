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

Public Sub Initialize(oDlg As B4XDialog) 
	dlg = oDlg
	'dlg.VisibleAnimationDuration = 300
	'dlg.BlurBackground = False
	Dim ac As Accessibility
	Scale = ac.GetUserFontScale
End Sub


Public Sub ThemeInputDialogBtnsResize()
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnCancel As B4XView = dlg.GetButton(xui.DialogResponse_Cancel)
		btnCancel.Font = xui.CreateDefaultFont(NumberFormat2(btnCancel.Font.Size / Scale,1,0,0,False))
		btnCancel.Width = btnCancel.Width + 20dip
		btnCancel.Left = btnCancel.Left - 28dip
		btnCancel.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		btnCancel.Height = btnCancel.Height - 4dip '--- resize height just a hair
		btnCancel.Top = btnCancel.Top + 4dip
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnOk As B4XView = dlg.GetButton(xui.DialogResponse_Positive)
		btnOk.Font = xui.CreateDefaultFont(NumberFormat2(btnOk.Font.Size / Scale,1,0,0,False))
		btnOk.Width = btnOk.Width + 20dip
		btnOk.Left = btnOk.Left - 48dip
		btnOk.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		btnOk.Height = btnOk.Height - 4dip '--- resize height just a hair
		btnOk.Top = btnOk.Top + 4dip
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
		If guiHelpers.gScreenSizeAprox > 5.5 Then
			dlg.TitleBarHeight=6%y
		End If
	Catch
		'--- errors sometimes, I think... something to do with the title not showing on smaller screens
		'--- b4xdialog.PutAtTop = False  <----   this!
		'Log("ThemeDialogForm-set title: " & LastException)
	End Try 'ignore
	
	dlg.TitleBarFont = xui.CreateDefaultFont(NumberFormat2(txtSize / Scale,1,0,0,False))
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


Public Sub AnimateDialog (FromEdge As String)
	Dim base As B4XView = dlg.Base
	Dim top As Int = base.Top
	Dim left As Int = base.Left
	Select FromEdge.ToLowerCase
		Case "bottom"
			base.Top = base.Parent.Height
		Case "top"
			base.Top = -base.Height
		Case "left"
			base.Left = -base.Width
		Case "right"
			base.Left = base.Parent.Width
	End Select
	base.SetLayoutAnimated(220, left, top, base.Width, base.Height)
End Sub


Public Sub NoCloseOn2ndDialog
	'dlg.Dialog.Base.Parent.Tag = "" 'this will prevent the dialog from closing when the second dialog appears.
	dlg.Base.Parent.Tag = "" 'this will prevent the dialog from closing when the second dialog appears.
End Sub
