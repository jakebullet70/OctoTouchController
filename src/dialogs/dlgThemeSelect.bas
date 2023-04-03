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
	Private mMain As B4XMainPage
	
	'--- color select stuff -----------------
	Private lblText2,lblText1,lblText As B4XView
	Private lblTextAcc As B4XView
	Private lblCustom As B4XView
	Private lblDisabled As B4XView
	Private pnlThemeMenu,pnlThemeHeader,pnlThemeBG As B4XView
	Private Spinner1 As Spinner
	Private ColorTemplate As sadB4XColorTemplate
	Private dgClr As B4XDialog
	Private Const CUSTOM_SELECTION As String = "Custom"
	Private spnPicker As Spinner
	'-----------------------------------------
	
	
End Sub

Public Sub Initialize
End Sub

Public Sub Show(mobj As B4XMainPage)
	
	'--- init
	mMain = mobj
	Dialog.Initialize(mobj.Root)
	Dim  dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(Dialog)
		
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

	dlgHelper.ThemeDialogForm( "Themes")
	Dim rs As ResumableSub = Dialog.ShowCustom(p, "SAVE", "", "CLOSE")
	Dialog.Base.Parent.Tag = "" 'this will prevent the dialog from closing when the second dialog appears.
	dlgHelper.ThemeInputDialogBtnsResize

	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)
	Wait For (rs) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		Main.kvs.Put(gblConst.SELECTED_CLR_THEME,Spinner1.SelectedItem)
		If Spinner1.SelectedItem = CUSTOM_SELECTION Then
			SaveCustomClrs
		End If
		guiHelpers.Show_toast2("Restart App To Change Theme",2200)
	End If
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub

Private Sub BuildGUI

	pnlBG.Color = clrTheme.Background

	'--- theme
	Dim DefaultColor As String = Main.kvs.Get(gblConst.SELECTED_CLR_THEME)
	Spinner1.AddAll(Array As String("Green","Blue","Red","Dark","Dark-Blue","Dark-Green","Gray","Prusa","Rose",CUSTOM_SELECTION))
	Spinner1.Prompt = "Theme"
	Spinner1.SelectedIndex = Spinner1.IndexOf(DefaultColor)
	Spinner1.DropdownTextColor = clrTheme.txtNormal
	Spinner1.TextColor = clrTheme.txtNormal
	Spinner1.DropdownBackgroundColor = clrTheme.Background2
	
	lblCustom.Visible = (Spinner1.SelectedItem = CUSTOM_SELECTION)
	
	'--- theme builder
	pnlThemeMenu.Tag = "BGround 2" : pnlThemeBG.Tag = "BGround"
	pnlThemeHeader.Tag = "BGround Header"
	lblText1.Tag = "Text Main" : lblText.Tag = lblText1.Tag : 	lblText2.Tag = lblText1.Tag
	lblTextAcc.Tag = "Text 2"
	lblDisabled.Tag = "Disabled"
	
	ThemeMe(DefaultColor)
	
End Sub

Private Sub Spinner1_ItemClick (Position As Int, Value As Object)
	ThemeMe(Value.As(String))
	lblCustom.Visible = (Value = "Custom").As(Boolean)
End Sub

Private Sub ThemeMe(clr As String)
	
	'--- save original
	Dim txtNormalTmp As Int = clrTheme.txtNormal
	Dim txtAccentTmp As Int = clrTheme.txtAccent
	Dim btnDisableTextTmp As Int = clrTheme.btnDisableText
	Dim DividerColorTmp As Int = clrTheme.DividerColor
	Dim BackgroundTmp As Int = clrTheme.Background
	Dim BackgroundHeaderTmp As Int = clrTheme.BackgroundHeader
	Dim Background2Tmp As Int = clrTheme.Background2
	
	clrTheme.InitTheme(clr) '--- one place for setting colors, so set them and restore later

	guiHelpers.SetTextColor(Array As B4XView(lblText,lblText1,lblText2,lblCustom))
	lblTextAcc.TextColor = clrTheme.txtAccent
	pnlThemeMenu.Color = clrTheme.Background2
	pnlThemeHeader.Color = clrTheme.BackgroundHeader
	pnlThemeBG.Color = clrTheme.Background
	lblDisabled.TextColor = clrTheme.btnDisableText
		
	'--- restore
	clrTheme.txtNormal = txtNormalTmp
	clrTheme.txtAccent = txtAccentTmp
	clrTheme.btnDisableText = btnDisableTextTmp
	clrTheme.DividerColor = DividerColorTmp
	clrTheme.Background = BackgroundTmp
	clrTheme.BackgroundHeader = BackgroundHeaderTmp
	clrTheme.Background2 = Background2Tmp
	
End Sub

Private Sub SaveCustomClrs
	
	clrTheme.CustomColors.Initialize
	clrTheme.CustomColors.bg = pnlThemeBG.Color
	clrTheme.CustomColors.bgHeader = pnlThemeHeader.Color
	clrTheme.CustomColors.bgMenu = pnlThemeMenu.Color
	clrTheme.CustomColors.txtNormal = lblText1.TextColor
	clrTheme.CustomColors.txtAcc = lblTextAcc.TextColor
	clrTheme.CustomColors.Disabled = lblDisabled.TextColor 
	clrTheme.CustomColors.Divider = clrTheme.DividerColor '--- no GUI yet
	
	Main.kvs.Put(gblConst.CUSTOM_THEME_COLORS,clrTheme.CustomColors)
	Log("Saved custom colors")
	
End Sub

'=================================================================

#region "CUSTOM GUI"

Private Sub ShowColorPicker(callerClr As Int,clrName As String) As ResumableSub
	dgClr.Initialize(mMain.Root)
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(dgClr)
	
	ColorTemplate.Initialize
	ColorTemplate.SelectedColor = callerClr
	
	dlgHelper.ThemeDialogForm("Select Color: " & clrName)
	Dim obj As ResumableSub = dgClr.ShowTemplate(ColorTemplate, "OK", "", "CANCEL")
	dlgHelper.ThemeInputDialogBtnsResize
	
	CreateCboColorSelector(clrName)
	
	Wait For (obj) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		Log(ColorTemplate.SelectedColor)
		Return  ColorTemplate.SelectedColor
	End If
	Return 0
	
End Sub

Private Sub CreateCboColorSelector(selected As String)
	spnPicker.Initialize("clrSelected")
	spnPicker.AddAll(Array As String( _
					pnlThemeBG.Tag,pnlThemeMenu.Tag,pnlThemeHeader.Tag,lblText.Tag,lblTextAcc.Tag,lblDisabled.Tag))
	spnPicker.Prompt = "Load Color"
	spnPicker.DropdownTextColor = clrTheme.txtNormal
	spnPicker.TextColor = clrTheme.txtNormal
	spnPicker.DropdownBackgroundColor = clrTheme.Background2
	spnPicker.SelectedIndex = spnPicker.IndexOf(selected)
	'Dim bw As Button	 = dgClr.GetButton(-1).Width
	dgClr.Base.AddView(spnPicker,4dip,dgClr.Base.Height - 50dip, _
								dgClr.Base.Width - (dgClr.GetButton(xui.DialogResponse_Positive).Width * 2) - 24dip, 36dip)
End Sub

Private Sub clrSelected_ItemClick (Position As Int, Value As Object)
	Select Case Value
		Case pnlThemeBG.Tag 		:	ColorTemplate.SelectedColor = pnlThemeBG.Color
		Case pnlThemeMenu.Tag 	: 	ColorTemplate.SelectedColor = pnlThemeMenu.Color
		Case pnlThemeHeader.Tag 	: 	ColorTemplate.SelectedColor = pnlThemeHeader.color
		Case lblText.Tag		 		: 	ColorTemplate.SelectedColor = lblText1.TextColor
		Case lblTextAcc.Tag			: 	ColorTemplate.SelectedColor = lblTextAcc.TextColor
		Case lblDisabled.Tag 			: 	ColorTemplate.SelectedColor = lblDisabled.TextColor
	End Select
End Sub

Private Sub lblText_Click
'	#if release 
'	If (Spinner1.SelectedItem <> CUSTOM_SELECTION) Then Return
'	#end if
	Dim lbl As B4XView : lbl = Sender
	Wait For (ShowColorPicker(lbl.TextColor,lbl.Tag)) Complete (i As Int)
	If i <> 0 Then
		lblText1.TextColor = i
		lblText2.TextColor = i
		lblText.TextColor = i
	End If
End Sub

Private Sub lblTextAcc_Click
'	#if release 
'	If (Spinner1.SelectedItem <> CUSTOM_SELECTION) Then Return
'	#end if
	Dim lbl As B4XView : lbl = Sender
	Wait For (ShowColorPicker(lbl.TextColor,lbl.tag)) Complete (i As Int)
	If i <> 0 Then lblTextAcc.TextColor = i
End Sub


Private Sub lblDisabled_Click
'	#if release 
'	If (Spinner1.SelectedItem <> CUSTOM_SELECTION) Then Return
'	#end if
	Dim lbl As B4XView : lbl = Sender
	Wait For (ShowColorPicker(lbl.TextColor,lbl.tag)) Complete (i As Int)
	If i <> 0 Then lblDisabled.TextColor = i
End Sub

Private Sub pnlBGrounds_Click
'	#if release 
'	If (Spinner1.SelectedItem <> CUSTOM_SELECTION) Then Return
'	#end if
	Dim pnl As B4XView : pnl = Sender
	Wait For (ShowColorPicker(pnl.Color,pnl.tag)) Complete (i As Int)
	If i <> 0 Then pnl.Color = i
End Sub

#end region




