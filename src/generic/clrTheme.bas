B4J=true
Group=GENERIC
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
'Static code module
Sub Process_Globals
	Private xui As XUI
	Private Const mModule As String = "clrTheme" 'ignore
	
'	Public PanelBorderThick As Int
'	Public PanelBorderThin As Int
'	Public PanelBG As Int
'	Public PanelTabBG As Int
'	Public TabSelected As Int
	
	Public PopupMenuBG As Int
	Public txtBright As Int,txtBrightBBlbl As String
	Public txtNormal As Int,txtNormalBBlbl As String
	Public Background As Int
	Public BackgroundHeader,BackgroundMenu As Int
	
	Public txtAccent As Int
	Public btnDisableText As Int
	'Public btnText As Int
	Public DividerColor As Int
	
	Public ItemsBackgroundColor As Int
	'Public SeparatorBackgroundColor = 0xFFD0D0D0
	'SeparatorTextColor = 0xFF4E4F50
	Public DialogBG  As Int
	Public DialogButtonsColor  As Int
	Public DialogBorderColor  As Int
	Public DialogButtonsTextColor  As Int
	
	Public Go As Int
	Public NoGo As Int
	
	Public clvSelectedColor As Int
	
	
End Sub

'--- TODO, move all out to config files an add a color picker, theme builder  (LONG TERM)

Public Sub Init
	
	Go = 0xFF81F266
	NoGo = 0xFFE14349

	txtBright = xui.Color_Cyan
	txtNormal = xui.Color_White
	btnDisableText = 0xFFADD8E6
	
	Background =  0xFF222651
	BackgroundHeader = 0xFF22263D
	BackgroundMenu = 0xFF222633
	
	'PopupMenuBG = xui.Color_Gray
	
	DividerColor = xui.Color_LightGray
	'DividerColor = 0xFF464646
	'TabSelected = 0xFF746FD5
	txtAccent = 0xFF746FD5
	
	'btnText = xui.Color_White

	DialogBG = 0xFF555555
	DialogButtonsColor = 0xFF555555
	DialogBorderColor = 0xff000000
	DialogButtonsTextColor = 0xFF89D5FF

	ItemsBackgroundColor = 0xFF626262
	
	'--- converted for BBLabel
	txtNormalBBlbl = ColorToHex4BBLabel(txtNormal)
	txtBrightBBlbl = ColorToHex4BBLabel(txtBright)
	
End Sub


public Sub ColorToHex4BBLabel(clr As Int) As String
	Return "0x" & ColorToHex(clr)
End Sub

public Sub ColorToHex(clr As Int) As String
	Dim bc As ByteConverter
	Return bc.HexFromBytes(bc.IntsToBytes(Array As Int(clr)))
End Sub

public Sub HexToColor(Hex As String) As Int
	Dim bc As ByteConverter
	If Hex.StartsWith("#") Then
		Hex = Hex.SubString(1)
	Else If Hex.StartsWith("0x") Then
		Hex = Hex.SubString(2)
	End If
	Dim ints() As Int = bc.IntsFromBytes(bc.HexToBytes(Hex))
	Return ints(0)
End Sub


