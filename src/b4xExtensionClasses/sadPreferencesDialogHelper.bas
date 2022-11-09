B4J=true
Group=B4X_EXT_CLASSES
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
' Helper class for sadB4XPrefDialog V11.8
#Region VERSIONS 
' V1.0  Nov/9/2022	1st run.
#End Region

Sub Class_Globals
	Private xui As XUI
	Private prefdlg As sadPreferencesDialog
	Public dlgHelper As sadB4XDialogHelper
	Private dlg As B4XDialog
End Sub

Public Sub Initialize(oPrefDlg As sadPreferencesDialog)  
	prefdlg = oPrefDlg
	dlg = prefdlg.Dialog
	dlgHelper.Initialize(dlg)
End Sub


Public Sub ThemePrefDialogForm
	
	Try
		
		prefdlg.ItemsBackgroundColor = clrTheme.Background
		prefdlg.SeparatorBackgroundColor = clrTheme.BackgroundHeader
		prefdlg.SeparatorTextColor = clrTheme.txtAccent
		prefdlg.TextColor = clrTheme.txtNormal
		
		'prefdlg.Dialog.BackgroundColor = clrTheme.Background2
		'prefdlg.mBase.Color = clrTheme.Background2
		
		'prefdlg.Dialog.Base.Color = clrTheme.Background2
		'prefdlg.CustomListView1.sv.SetColorAndBorder(xui.Color_Transparent,1dip,xui.Color_blue,0dip)
		'prefdlg.mBase.SetColorAndBorder(xui.Color_Blue,2dip,xui.Color_White,5dip)
		
		'prefdlg.CustomListView1.AsView.Color = clrTheme.Background2
		'prefdlg.CustomListView1.GetBase.Color = clrTheme.Background2
		'prefdlg.CustomListView1. = clrTheme.Background2
		
		dlgHelper.ThemeDialogForm(prefdlg.Title.As(String))
		
	Catch
		Log(LastException)
	End Try
	

End Sub



