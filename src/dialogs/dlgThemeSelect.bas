B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Nov/1/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgThemeSelect"' 'ignore
	Private pnlBG As B4XView
	Private xui As XUI
	Private Dialog As B4XDialog
	
	Private lblText2,lblText1,lblText As B4XView
	Private lblTextAcc As B4XView
	Private pnlThemeMenu,pnlThemeHeader,pnlThemeBG As B4XView
	Private Spinner1 As Spinner
	
End Sub


Public Sub Initialize
End Sub


Public Sub Show(mobj As B4XMainPage)
	
	'--- init
	Dialog.Initialize(mobj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	Dim w, h As Float
	
	If guiHelpers.gScreenSizeAprox < 8 Then
		w = 80%x
		h = IIf(guiHelpers.gIsLandScape,74%y,65%y)
	Else
		w = 74%x : h = 70%y
	End If
	
	p.SetLayoutAnimated(0, 0, 0, w, h)
	p.LoadLayout("dlgThemeSelect")
	
	BuildGUI 

	guiHelpers.ThemeDialogForm(Dialog, "Themes")
	Dim rs As ResumableSub = Dialog.ShowCustom(p, "SAVE", "", "CLOSE")
	'Dialog.Base.Parent.Tag = "" 'this will prevent the dialog from closing when the second dialog appears.
	guiHelpers.ThemeInputDialogBtnsResize(Dialog)
	'guiHelpers.EnableDisableBtns(Array As B4XView(btnCheckConnection,btnGetOctoKey),True)

	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)
	Wait For (rs) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		Starter.kvs.Put(gblConst.CLR_THEME_KEY,Spinner1.SelectedItem)
		guiHelpers.Show_toast2("Restart App To Change Theme",2200)
	End If
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub

Private Sub BuildGUI

	pnlBG.Color = clrTheme.Background

	Dim DefaultColor As String = Starter.kvs.Get(gblConst.CLR_THEME_KEY)
	Spinner1.AddAll(Array As String("Green","Blue","Dark","Dark-Blue","Dark-Green","Red","Gray","Prusa"))
	Spinner1.Prompt = "Theme"
	Spinner1.SelectedIndex = Spinner1.IndexOf(DefaultColor)
	Spinner1.DropdownBackgroundColor = clrTheme.BackgroundMenu
	Spinner1.DropdownTextColor = clrTheme.txtNormal
	Spinner1.TextColor = clrTheme.txtNormal
	
	ThemeMe(DefaultColor)
	
End Sub


Private Sub Spinner1_ItemClick (Position As Int, Value As Object)
	ThemeMe(Value.As(String))
End Sub

Private Sub ThemeMe(clr As String)
	
	'--- save original
	Dim txtNormalTmp As Int = clrTheme.txtNormal
	Dim txtAccentTmp As Int = clrTheme.txtAccent
	Dim btnDisableTextTmp As Int = clrTheme.btnDisableText
	Dim DividerColorTmp As Int = clrTheme.DividerColor
	Dim BackgroundTmp As Int = clrTheme.Background
	Dim BackgroundHeaderTmp As Int = clrTheme.BackgroundHeader
	Dim BackgroundMenuTmp As Int = clrTheme.BackgroundMenu
	
	clrTheme.InitTheme(clr) '--- one place for setting colors, so set them and restore later

	guiHelpers.SetTextColor(Array As B4XView(lblText,lblText1,lblText2))
	lblTextAcc.TextColor = clrTheme.txtAccent
	pnlThemeMenu.Color = clrTheme.BackgroundMenu
	pnlThemeHeader.Color = clrTheme.BackgroundHeader
	pnlThemeBG.Color = clrTheme.Background
		
	'--- restore
	clrTheme.txtNormal = txtNormalTmp
	clrTheme.txtAccent = txtAccentTmp
	clrTheme.btnDisableText = btnDisableTextTmp
	clrTheme.DividerColor = DividerColorTmp
	clrTheme.Background = BackgroundTmp
	clrTheme.BackgroundHeader = BackgroundHeaderTmp
	clrTheme.BackgroundMenu = BackgroundMenuTmp
	
End Sub





