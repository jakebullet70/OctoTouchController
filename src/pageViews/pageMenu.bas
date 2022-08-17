﻿B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region

Sub Class_Globals
	Private Const mModule As String = "pageMenu" 'ignore
	Private xui As XUI
	Private mPnlMain As B4XView
	Private mCallBackEvent As String
	Private mMainObj As B4XMainPage'ignore
	
	'--- menus
	Private mnuFiles As B4XView
	Private mnuMovement As B4XView
	Private mnuPrinting As B4XView
	
	Public Dialog As B4XDialog
	
	Private btnBrightness As B4XView
End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String) 
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageMenu")
	
	Build_GUI
	
End Sub

public Sub Set_focus()
	mPnlMain.Visible = True
	
	'TODO needs to move to an event when general cfg changes
	btnBrightness.Visible = config.ChangeBrightnessSettingsFLAG 
	
End Sub

public Sub Lost_focus()
	mPnlMain.Visible = False
End Sub

Private Sub Build_GUI
	
	btnBrightness.Visible = config.ChangeBrightnessSettingsFLAG
	
	'--- build the main menu screen
	BuildMenuCard(mnuMovement,"menuMovement.png","Move",gblConst.PAGE_MOVEMENT)
	BuildMenuCard(mnuFiles,"menuFiles.png","Files",gblConst.PAGE_FILES)
	BuildMenuCard(mnuPrinting,"menuPrint.png","Printing",gblConst.PAGE_PRINTING)
	
End Sub

Private Sub BuildMenuCard(mnuPanel As Panel,imgFile As String, Text As String, mnuAction As String)
	
	'mnuPanel.SetLayoutAnimated(0,0,0,mnuPanel.Width,mnuPanel.Height)
	mnuPanel.LoadLayout("menuCard")
	For Each v As View In mnuPanel.GetAllViewsRecursive
		
		If v.Tag <> Null Then
			If v.Tag Is lmB4XImageViewX Then
				Dim o1 As lmB4XImageViewX = v.Tag
				o1.Load(File.DirAssets,imgFile)
				o1.Tag2 = mnuAction '--- set menu action
				
			Else If v.Tag = "lbl" Then
				Dim o2 As Label = v
				o2.Text = Text
				
			End If
		End If
		
	Next
	
End Sub

Private Sub mnuCardImg_Click
	
	'--- pass the menu selection back to main page
	Dim oo As lmB4XImageViewX : oo = Sender
	Sleep(50)
	CallSub2(mMainObj,mCallBackEvent,oo.Tag2)
	
End Sub


#Region "BRIGHTNESS BTN"
Private Sub btnBrightness_Click
	
	Dim o1 As dlgRoundSlider
	o1.Initialize(mMainObj,"Screen Brightness",Me,"Brightness_Change")
	o1.Show(powerHelpers.pScreenBrightness * 100)
	
End Sub
Private Sub Brightness_Change(value As Float)
	
	'--- callback for btnBrightness_Click
	Dim v As Float = value / 100
	powerHelpers.SetScreenBrightnessAndSave(v,True) 
	powerHelpers.pScreenBrightness = v
	
End Sub
#end region


