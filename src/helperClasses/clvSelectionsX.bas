B4J=true
Group=CLASSES
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  B4X, sadLogic
#Region VERSIONS 
' V1.1  Jun/4/2022	Original, will un-select a prev selected row if it is the current row, 
'					we ALWAYS want one row selected
' V1.0 	No Idea
#End Region

Sub Class_Globals
	Public MODE_SINGLE_ITEM_TEMP = 1, MODE_SINGLE_ITEM_PERMANENT = 2, MODE_MULTIPLE_ITEMS = 3 As Int
	Private mCurrentMode As Int
	Public SelectedItems As B4XSet
	Public SelectionColor As Int
	Private mCLV As CustomListView
	Private xui As XUI
	Private UnselectedColor As Int = xui.Color_Transparent
	Private SingleMode As Boolean
End Sub

Public Sub Initialize (CLV As CustomListView)
	mCLV = CLV
	SelectionColor = CLV.PressedColor
	SelectedItems = B4XCollections.CreateSet
	mCurrentMode = MODE_SINGLE_ITEM_TEMP
End Sub

Public Sub ItemClicked (Index As Int)
	If mCurrentMode = MODE_SINGLE_ITEM_TEMP Then Return
	'Log(Index)
	'--- Original, will un-select a prev selected row if it is the current row, we ALWAYS want one row selected
	'If SelectedItems.Contains(Index)  Then 
	
	If SelectedItems.Contains(Index) And mCurrentMode <> MODE_SINGLE_ITEM_PERMANENT Then
		SelectedItems.Remove(Index)
		mCLV.GetPanel(Index).Color = UnselectedColor
	Else
		If SingleMode And SelectedItems.Size > 0 Then
			Clear
		End If
		mCLV.GetPanel(Index).Color = SelectionColor
		SelectedItems.Add(Index)
	End If
End Sub




Public Sub Refresh
	VisibleRangeChanged(0, mCLV.Size - 1)
End Sub

Public Sub VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	For i = Max(0, FirstIndex - 5) To Min(mCLV.Size - 1, LastIndex + 5)
		Dim p As B4XView = mCLV.GetPanel(i)
		If SelectedItems.Contains(i) Then
			p.Color = SelectionColor
		Else
			p.Color = UnselectedColor
		End If
	Next
End Sub

Public Sub getMode As Int
	Return mCurrentMode
End Sub

Public Sub setMode (m As Int)
	mCurrentMode = m
	Clear
	If mCurrentMode = MODE_SINGLE_ITEM_TEMP Then
		mCLV.PressedColor = SelectionColor
	Else
		mCLV.PressedColor = xui.Color_Transparent
	End If
	Select mCurrentMode
		Case MODE_SINGLE_ITEM_PERMANENT
			SingleMode = True
		Case MODE_MULTIPLE_ITEMS
			SingleMode = False
	End Select
	Refresh
End Sub

Public Sub Clear
	If SelectedItems.Size = 0 Then Return
	For Each i As Int In SelectedItems.AsList
		mCLV.GetPanel(i).Color = UnselectedColor
	Next
	SelectedItems.Clear
End Sub

Public Sub SelectAndMakeVisible (Index As Int)
	Dim Target As Int = Max(0, Index - (mCLV.LastVisibleIndex - mCLV.FirstVisibleIndex - 1) / 2)
	If mCurrentMode = MODE_SINGLE_ITEM_TEMP Then
		If mCLV.FirstVisibleIndex > Index Or mCLV.LastVisibleIndex < Index Then
			mCLV.JumpToItem(Target)
		End If
		Dim p As B4XView = mCLV.GetPanel(Index)
		p.SetColorAnimated(50, UnselectedColor, SelectionColor)
		Sleep(200)
		p.SetColorAnimated(200, SelectionColor, UnselectedColor)
	Else
		If SelectedItems.Contains(Index) = False Then
			ItemClicked(Index)
		End If
		If mCLV.FirstVisibleIndex > Index Or mCLV.LastVisibleIndex < Index Then
			mCLV.ScrollToItem(Target)
		End If
	End If
End Sub


