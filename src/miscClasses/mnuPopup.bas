﻿B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic --- Kherson Ukraine
' Wrapper for ASPopupMenu by Alexander Stolte
#Region VERSIONS 
' V. 1.0 	July/8/2022
#End Region
#Event: Closed (index as int, tag as object)

Sub Class_Globals
	
	Private Const mModule As String = "mnuPopup"' 'ignore
	Private aspm_main As ASPopupMenu
	
	Private mainObj As B4XMainPage
	Private mCallback As Object
	Private mEventName As String
	Private xui As XUI
	Private mCallingView As B4XView
	Private mTitle As String
	Private mapMenuItems As Map
	Private mMenuWidth As Int = 100dip
	
End Sub

'--- properties
Public Sub setMenuWidth(value As Int)
	mMenuWidth = value
End Sub

Public Sub setItemHeight(value As Int)
	aspm_main.item_height = value
End Sub

Public Sub getMenuObj() As ASPopupMenu
	Return aspm_main
End Sub
'-------------------------


Public Sub Initialize(Callback As Object, EventName As String, mObj As B4XMainPage, mnuMap As Map, _
								callingView As B4XView, title As String)
	
	mCallback = Callback
	mEventName = EventName
	mainObj = mObj
	mCallingView = callingView
	mTitle = title
	mapMenuItems = mnuMap
	
	BuildGUI

End Sub


Public Sub Show()
	aspm_main.OpenMenu(mCallingView, mMenuWidth) '--- show the menu
End Sub

Public Sub Show2()
	aspm_main.OpenMenu2(mCallingView, mMenuWidth) '--- show the menu
End Sub


private Sub BuildGUI
	
	aspm_main.Initialize(mainObj.root,Me, "PopupMenu")
	aspm_main.ActivityHasActionBar = True
	
	aspm_main.MenuViewGap = aspm_main.TriangleProperties.Height + 2dip
	aspm_main.ShowTriangle = False
	'aspm_main.TriangleProperties.Left = mMenuWidth/2 - aspm_main.TriangleProperties.Width/2
	
	aspm_main.OrientationVertical = aspm_main.OrientationVertical_BOTTOM
	aspm_main.OrientationHorizontal = aspm_main.OrientationHorizontal_MIDDLE
		
	aspm_main.ItemLabelProperties.BackgroundColor =  xui.Color_ARGB(152,0,0,0)' --- dims background color
	aspm_main.ItemLabelProperties.xFont = xui.CreateDefaultFont(NumberFormat2(26 / guiHelpers.gFscale,1,0,0,False))'xui.CreateDefaultFont(26)
	
	'aspm_main.ItemLabelProperties.BackgroundColor =  clrTheme.DialogBG'  xui.Color_ARGB(152,0,0,0)'black
	
	aspm_main.DividerEnabled = True
	aspm_main.DividerHeight = 4dip
	aspm_main.DividerColor =  clrTheme.DividerColor'  xui.Color_White
	
	aspm_main.TitleLabelProperties.BackgroundColor = clrTheme.BackgroundHeader'xui.Color_White
	aspm_main.TitleLabelProperties.TextColor =  clrTheme.txtNormal'  xui.Color_Black
	aspm_main.TitleLabelProperties.xFont = xui.CreateDefaultFont(32)
	aspm_main.AddTitle(mTitle,60dip)
	
	aspm_main.MenuCornerRadius = 6dip
	
	aspm_main.ItemLabelProperties.ItemBackgroundColor =   clrTheme.BackgroundMenu'    xui.Color_Black'xui.Color_ARGB(255,Rnd(1,256), Rnd(1,256), Rnd(1,256))
	
	'--- build menus
	For Each mnuItem As String In mapMenuItems.Keys
		aspm_main.AddMenuItem(mnuItem,mapMenuItems.Get(mnuItem))
	Next
	
End Sub



Private Sub PopupMenu_ItemClicked(Index As Int,Tag As Object)

	'--- this just passes data back to calling parent
	Dim listRet As List : listRet.Initialize2(Array As Object(Index,Tag)) 
	RaiseEvent("Closed", listRet)
	
End Sub



Private Sub RaiseEvent(EvName As String, Params As List) 'ignore
	Dim FullRoutineName As String
	FullRoutineName = mEventName & "_" & EvName
	If SubExists(mCallback, FullRoutineName) Then
		If Not(Params.IsInitialized) Or Params.Size = 0 Then
			CallSubDelayed(mCallback, FullRoutineName)
		Else
			Select Params.Size
				Case 1
					CallSubDelayed2(mCallback, FullRoutineName, Params.Get(0))
				Case 2
					CallSubDelayed3(mCallback, FullRoutineName, Params.Get(0), Params.Get(1))
			End Select
		End If
	End If
End Sub





