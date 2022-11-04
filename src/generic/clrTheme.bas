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
	
	Type tThemeColors (bg, bgHeader, bgMenu, txtNormal, txtAcc,Disabled,Divider As Int)
	Public CustomColors As tThemeColors
	
	Public Background,BackgroundHeader,BackgroundMenu As Int
	
	Public txtAccent,txtNormal As Int
	Public btnDisableText As Int
	Public DividerColor As Int
	
	Public ItemsBackgroundColor As Int '--- used in sadPrefDialogs
	
End Sub


Public Sub Init(theme As String)
	
	If Starter.kvs.ContainsKey(gblConst.CUSTOM_THEME_COLORS) = False Then SeedCustomClrs
	CustomColors = Starter.kvs.Get(gblConst.CUSTOM_THEME_COLORS)
	InitTheme(theme)
	
End Sub

Public Sub InitTheme(theme As String)
	
	txtNormal = xui.Color_white
	txtAccent = xui.Color_LightGray
	btnDisableText = xui.Color_ARGB(50,192,192,192)
	DividerColor = xui.Color_LightGray
	
	Select Case theme.ToLowerCase
		
		Case "custom"
			Background = CustomColors.bg
			BackgroundHeader = CustomColors.bgHeader
			BackgroundMenu = CustomColors.bgMenu
			txtNormal = CustomColors.txtNormal
			txtAccent = CustomColors.txtAcc
			btnDisableText = CustomColors.Disabled
			DividerColor = CustomColors.Divider
			
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
			Background = xui.Color_ARGB(255,2, 2, 2)
			BackgroundHeader = xui.Color_ARGB(255,30, 30, 30)
			BackgroundMenu = xui.Color_ARGB(255,43, 43, 43)
			
		Case "dark-blue"
			Background = xui.Color_ARGB(255,2,2,2)
			BackgroundHeader = xui.Color_ARGB(255,30, 30, 30)
			BackgroundMenu = xui.Color_ARGB(255,43, 43, 43)
			'--- overide base white color
			txtNormal = -16739073
			txtAccent = 	0xFF4FB0B7
			
		Case "dark-green"
			Background = xui.Color_ARGB(255,2,2,2)
			BackgroundHeader = xui.Color_ARGB(255,30, 30, 30)
			BackgroundMenu = xui.Color_ARGB(255,43, 43, 43)
			'--- overide base white color
			txtNormal = -11276022
			txtAccent = 0xFFB1E89A
			
		Case "prusa"
			Background = xui.Color_ARGB(255,18, 18, 18)
			BackgroundHeader = xui.Color_ARGB(255,11, 11, 11)
			BackgroundMenu = xui.Color_ARGB(255,43, 43, 43)
			
			'--- overide base white color
			txtNormal = xui.Color_ARGB(255,216, 91, 48)
			txtAccent = 0xFFD77762' xui.Color_LightGray
			btnDisableText = xui.Color_ARGB(50,192,192,192)
			DividerColor = xui.Color_Black
		
		Case Else ' --- "blue"
			Background = xui.Color_ARGB(255,53, 69, 85)
			BackgroundHeader = xui.Color_ARGB(255,41, 57, 73)
			BackgroundMenu = xui.Color_ARGB(255,45, 62, 78)
				
	End Select
End Sub


Private Sub SeedCustomClrs
	
	Log("Seed clrs")
	CustomColors.Initialize
	'--- seed a basic black / white
	CustomColors.bg = xui.Color_ARGB(255,2, 2, 2)
	CustomColors.bgHeader = xui.Color_ARGB(255,30, 30, 30)
	CustomColors.bgMenu = xui.Color_ARGB(255,43, 43, 43)
	CustomColors.txtNormal = xui.Color_white
	CustomColors.txtAcc = xui.Color_LightGray
	CustomColors.Disabled = xui.Color_ARGB(50,192,192,192)
	CustomColors.Divider = xui.Color_LightGray
	Starter.kvs.Put(gblConst.CUSTOM_THEME_COLORS,CustomColors)
	
End Sub

'=====================================================================

Public Sub ColorToHex4BBLabel(clr As Int) As String 'ignore
	Return "0x" & ColorToHex(clr)
End Sub

Public Sub ColorToHex(clr As Int) As String
	Dim bc As ByteConverter
	Return bc.HexFromBytes(bc.IntsToBytes(Array As Int(clr))) 'ignore
End Sub

Public Sub HexToColor(Hex As String) As Int 'ignore
	Dim bc As ByteConverter
	If Hex.StartsWith("#") Then
		Hex = Hex.SubString(1)
	Else If Hex.StartsWith("0x") Then
		Hex = Hex.SubString(2)
	End If
	Dim ints() As Int = bc.IntsFromBytes(bc.HexToBytes(Hex))
	Return ints(0)
End Sub


