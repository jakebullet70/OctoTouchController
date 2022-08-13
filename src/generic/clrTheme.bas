﻿B4J=true
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
	
	Public PopupMenuBG As Int
	Public txtNormal As Int
	Public Background,BackgroundHeader,BackgroundMenu As Int
	
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


Public Sub Init(theme As String)
	
	Go = 0xFF81F266
	NoGo = 0xFFE14349

	txtNormal = xui.Color_White
	btnDisableText = xui.Color_LightGray
	
	InitTheme(theme)
	
	DividerColor = xui.Color_LightGray
	
	'btnText = xui.Color_White

	DialogBG = 0xFF555555
	DialogButtonsColor = 0xFF555555
	DialogBorderColor = 0xff000000
	DialogButtonsTextColor = 0xFF89D5FF

	ItemsBackgroundColor = 0xFF626262
			
End Sub



Public Sub InitTheme(theme As String)
	
	Select Case theme.ToLowerCase
		
		Case "blue"
			Background = xui.Color_ARGB(255,53, 69, 85)
			BackgroundHeader = xui.Color_ARGB(255,41, 57, 73)
			BackgroundMenu = xui.Color_ARGB(255,135, 25, 29)
			
		Case "red"
			Background = xui.Color_ARGB(255,131, 21, 25)
			BackgroundHeader = xui.Color_ARGB(255,124, 14, 18)
			BackgroundMenu = xui.Color_ARGB(255,162, 30, 25)
			
		Case "green"
			Background = xui.Color_ARGB(255,19, 62, 11)
			BackgroundHeader = xui.Color_ARGB(255,14, 57, 6)
			BackgroundMenu = xui.Color_ARGB(255,24, 67, 16)
	
		Case "gray"
			Background = xui.Color_ARGB(255,90, 90, 90)
			BackgroundHeader = xui.Color_ARGB(255,73, 73, 73)
			BackgroundMenu = xui.Color_ARGB(255,90, 90, 90)
			
		Case "dark"
			Background = xui.Color_ARGB(255,18, 18, 18)
			BackgroundHeader = xui.Color_ARGB(255,11, 11, 11)
			BackgroundMenu = xui.Color_ARGB(255,22, 22, 22)
			
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


