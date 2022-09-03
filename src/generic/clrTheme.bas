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
	
	Public Background,BackgroundHeader,BackgroundMenu As Int
	
	Public txtNormal As Int
	Public txtAccent As Int
	Public btnDisableText As Int
	Public DividerColor As Int
	
	Public ItemsBackgroundColor As Int
	
	Public ConnectionNo,ConnectionYes As Int
	
End Sub


Public Sub Init(theme As String)
	
	ConnectionYes = 0xFF81F266
	ConnectionNo = 0xFFE14349

	txtNormal = xui.Color_white
	txtAccent = xui.Color_LightGray
	btnDisableText = xui.Color_LightGray
	DividerColor = xui.Color_LightGray
	
	InitTheme(theme)
			
End Sub



Public Sub InitTheme(theme As String)
	
	Select Case theme.ToLowerCase
		
		Case "red"
			Background = xui.Color_ARGB(255,131, 21, 25)
			BackgroundHeader = xui.Color_ARGB(255,124, 14, 18)
			BackgroundMenu = xui.Color_ARGB(255,162, 30, 25)
			
		Case "green"
			Background = xui.Color_ARGB(255,19, 62, 11)
			BackgroundHeader = xui.Color_ARGB(255,10, 51, 6)
			BackgroundMenu = xui.Color_ARGB(255,10, 53, 2)
	
		Case "gray"
			Background = xui.Color_ARGB(255,90, 90, 90)
			BackgroundHeader = xui.Color_ARGB(255,73, 73, 73)
			BackgroundMenu = xui.Color_ARGB(255,60, 60, 60)
			
		Case "dark"
			Background = xui.Color_ARGB(255,18, 18, 18)
			BackgroundHeader = xui.Color_ARGB(255,11, 11, 11)
			BackgroundMenu = xui.Color_ARGB(255,43, 43, 43)
			
		Case "prusa"
			Background = xui.Color_ARGB(255,18, 18, 18)
			BackgroundHeader = xui.Color_ARGB(255,11, 11, 11)
			BackgroundMenu = xui.Color_ARGB(255,43, 43, 43)
			
			'--- overide base white color
			txtNormal = xui.Color_ARGB(255,216, 91, 48)
			txtAccent = xui.Color_LightGray
			btnDisableText = xui.Color_ARGB(50,192,192,192)
		
		Case Else ' --- "blue"
			Background = xui.Color_ARGB(255,53, 69, 85)
			BackgroundHeader = xui.Color_ARGB(255,41, 57, 73)
			BackgroundMenu = xui.Color_ARGB(255,45, 62, 78)
				
	End Select
End Sub


public Sub ColorToHex4BBLabel(clr As Int) As String 'ignore
	Return "0x" & ColorToHex(clr)
End Sub

public Sub ColorToHex(clr As Int) As String
	Dim bc As ByteConverter
	Return bc.HexFromBytes(bc.IntsToBytes(Array As Int(clr))) 'ignore
End Sub

public Sub HexToColor(Hex As String) As Int 'ignore
	Dim bc As ByteConverter
	If Hex.StartsWith("#") Then
		Hex = Hex.SubString(1)
	Else If Hex.StartsWith("0x") Then
		Hex = Hex.SubString(2)
	End If
	Dim ints() As Int = bc.IntsFromBytes(bc.HexToBytes(Hex))
	Return ints(0)
End Sub


