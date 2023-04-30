B4A=true
Group=DIALOGS_GENERIC
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/12/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgViewText"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	Private mDialog As B4XDialog
	
	Private EditText1 As EditText
End Sub



Public Sub Initialize(title As String)
	
	mMainObj = B4XPages.MainPage
	mTitle = title
	
End Sub

Public Sub Close_Me
	mDialog.Close(-1)
End Sub

Public Sub Show(fname As String)
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 90%x, 88%y)
	p.LoadLayout("dlgViewText.bal")
	
	dlgHelper.ThemeDialogForm(mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CLOSE")
	dlgHelper.ThemeInputDialogBtnsResize

	EditText1.TextColor = clrTheme.txtNormal	
	EditText1.Text = File.ReadString(xui.DefaultFolder,fname)
	
	Wait For (rs) Complete (Result As Int)
	mMainObj.pObjCurrentDlg1 = Null
	
End Sub



