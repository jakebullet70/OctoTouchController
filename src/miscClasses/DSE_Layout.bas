B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  epiCode
#Region VERSIONS 
' V. 1.0	Nov 27, 2022
'			https://www.b4x.com/android/forum/threads/b4x-dse_layout-align-and-spread-controls.144438/
'
'			--- Code called from the designer!!!!
'
#End Region

Sub Class_Globals
	Private mNumOfViews As Int = 0, i As Int = 0
End Sub

Public Sub Initialize
End Sub


Private Sub GetNumOfViews(pnl As B4XView) As Int 'ignore
	
	'--- get num of views, does not include views set to invisible
	'--- get num of views, does not include views set to invisible
	'--- get num of views, does not include views set to invisible
	
	Dim newNumOfViews As Int = 0 '--- added,sadLogic
	For i = 0 To pnl.NumberOfViews -1
		Dim v As B4XView = pnl.GetView(i)
		If v.Visible = False Then Continue 
		newNumOfViews = newNumOfViews + 1 
	Next
	Return newNumOfViews
	
End Sub



Public Sub SpreadHorizontally (DesignerArgs As DesignerArgs )
	Dim pnl As B4XView = DesignerArgs.GetViewFromArgs(0)
	Dim Maxsize As Int = DesignerArgs.Arguments.Get(1)
	Dim MinGap  As Int = DesignerArgs.Arguments.Get(2)
	Dim align  As String  = DesignerArgs.Arguments.Get(3)
	SpreadHorizontally2(pnl,Maxsize,MinGap,align)
End Sub

'Spreads the controls horizontally.
'Parameters: pnl, max, gap, align
'#0 Panel with controls in it 
'#1 Maximum size of each control (0 for no maximum, -1 to retain size),
'#2 Minimum gap between controls
'#3 Align with first control ( "top", "bottom", "center")
Public Sub SpreadHorizontally2(pnl As B4XView, Maxsize As Int,MinGap  As Int,align  As String )
'	Dim pnl As B4XView = DesignerArgs.GetViewFromArgs(0)
'	Dim Maxsize As Int = DesignerArgs.Arguments.Get(1)
'	Dim MinGap  As Int = DesignerArgs.Arguments.Get(2)
'	Dim  = DesignerArgs.Arguments.Get(3)
	Dim Change As Boolean = Maxsize >= 0
	
	If pnl.IsInitialized = False Then Return
	If Maxsize = 0 Then Maxsize = 0x7fffffff
	mNumOfViews = GetNumOfViews(pnl)
	
	Dim AllWidth As Int = pnl.Width
	Dim AllItemsWidth As Int
	If Change Then
'		Dim itemwidth As Int = Min(AllWidth / pnl.NumberOfViews - MinGap, Maxsize)
'		Dim gap As Int = (AllWidth - pnl.NumberOfViews * itemwidth) / pnl.NumberOfViews
		Dim itemwidth As Int = Min(AllWidth / mNumOfViews - MinGap, Maxsize)
		Dim gap As Int = (AllWidth - mNumOfViews * itemwidth) / mNumOfViews
	Else
		For qq = 0 To pnl.NumberOfViews -1
			Dim v As B4XView = pnl.GetView(qq)
			If v.Visible = False Then Continue '--- added,sadLogic
			AllItemsWidth = AllItemsWidth + v.Width
			If AllItemsWidth > AllWidth Then Return ' If total width of all controls is greater than panel width then do nothing
		Next
		'Dim gap As Int = (AllWidth - AllItemsWidth) / (pnl.NumberOfViews + 1)
		Dim gap As Int = (AllWidth - AllItemsWidth) / (mNumOfViews + 1)
	End If
	
	Dim lastright As Int = gap
	Dim alignposition As Int = -1
	i = 0
	For qq = 0 To pnl.NumberOfViews - 1
		Dim v As B4XView = pnl.GetView(qq)
		If v.Visible = False Then Continue '--- added,sadLogic
		If Change Then
			v.SetLayoutAnimated(0, (i + 0.5) * gap + i * itemwidth, v.Top, itemwidth, v.Height)
			Select align.Trim.ToLowerCase
				Case "top"
					If alignposition = -1 Then alignposition = v.top
					v.top = alignposition
				Case "bottom"
					If alignposition = -1 Then alignposition = v.top+v.Height
					v.top = alignposition - v.Height
				Case "center","centre"
					If alignposition = -1 Then alignposition = v.top+(v.Height/2)
					v.top = alignposition - (v.Height/2)
				Case Else
			End Select
		Else
			v.SetLayoutAnimated(0, lastright, v.Top, v.Width, v.Height)
			lastright =  gap + v.Left + v.Width
			Select align.Trim.ToLowerCase
				Case "top"
					If alignposition = -1 Then alignposition = v.top
					v.top = alignposition
				Case "bottom"
					If alignposition = -1 Then alignposition = v.top+v.Height
					v.top = alignposition - v.Height
				Case "center","centre"
					If alignposition = -1 Then alignposition = v.top+(v.Height/2)
					v.top = alignposition - (v.Height/2)
				Case Else
			End Select
		End If
		i = i + 1
	Next
End Sub


'=================================================================================



Public Sub SpreadVertically (DesignerArgs As DesignerArgs )
	Dim pnl As B4XView = DesignerArgs.GetViewFromArgs(0)
	Dim Maxsize As Int = DesignerArgs.Arguments.Get(1)
	Dim MinGap  As Int = DesignerArgs.Arguments.Get(2)
	Dim align  As String  = DesignerArgs.Arguments.Get(3)
	SpreadVertically2(pnl,Maxsize,MinGap,align)
End Sub

'Spreads the controls Vertically.
'Parameters: pnl, max, gap, align
'#0 Panel with controls in it 
'#1 Maximum size of each control (0 for no maximum, -1 to retain size),
'#2 Minimum gap between controls
'#3 Align with first control ( "left", "right", "center")
Public Sub SpreadVertically2 (pnl As B4XView, Maxsize As Int,MinGap  As Int,align  As String )
'	Dim pnl As B4XView = DesignerArgs.GetViewFromArgs(0)
'	Dim Maxsize As Int = DesignerArgs.Arguments.Get(1)
'	Dim MinGap  As Int = DesignerArgs.Arguments.Get(2)
'	Dim align  As String  = DesignerArgs.Arguments.Get(3)
	Dim Change As Boolean = Maxsize >= 0
	
	If pnl.IsInitialized = False Then Return
	If Maxsize = 0 Then Maxsize = 0x7fffffff
	Dim AllHeight As Int = pnl.Height
	Dim AllItemsHeight As Int
	
	mNumOfViews = GetNumOfViews(pnl)
	
	If Change Then
'		Dim itemHeight As Int = Min(AllHeight / pnl.NumberOfViews - MinGap, Maxsize)
'		Dim gap As Int = (AllHeight - pnl.NumberOfViews * itemHeight) / pnl.NumberOfViews
		Dim itemHeight As Int = Min(AllHeight / mNumOfViews - MinGap, Maxsize)
		Dim gap As Int = (AllHeight - mNumOfViews * itemHeight) / mNumOfViews
	Else
		For qq = 0 To pnl.NumberOfViews - 1
			Dim v As B4XView = pnl.GetView(qq)
			If v.Visible = False Then Continue '--- added,sadLogic
			AllItemsHeight = AllItemsHeight + v.Height
			If AllItemsHeight > AllHeight Then Return ' If total Height of all controls is greater than panel Height then do nothing
		Next
		Dim gap As Int = (AllHeight - AllItemsHeight) / (mNumOfViews +1)
		'Dim gap As Int = (AllHeight - AllItemsHeight) / (pnl.NumberOfViews +1)
	End If
	
	Dim lasttop As Int = gap
	Dim alignposition As Int = -1
	
	i = 0
	For qq = 0 To pnl.NumberOfViews - 1
		Dim v As B4XView = pnl.GetView(qq)
		If v.Visible = False Then Continue '--- added, sadLogic
		If Change Then
			v.SetLayoutAnimated(0, v.Left, (i + 0.5) * gap + i * itemHeight, v.Width, itemHeight)
			Select align.Trim.ToLowerCase
				Case "left"
					If alignposition = -1 Then alignposition = v.Left
					v.Left = alignposition
				Case "right"
					If alignposition = -1 Then alignposition = v.Left+v.Width
					v.Left = alignposition
				Case "center"
					If alignposition = -1 Then 
						alignposition = v.Left+(v.Width/2)
					End If
					v.Left = alignposition - (v.Width/2)
				Case Else
			End Select
		Else
			v.SetLayoutAnimated(0, v.Left, lasttop, v.Width, v.Height)
			lasttop = v.Top + v.Height + gap
			Select align.Trim.ToLowerCase
				Case "left"
					If alignposition = -1 Then alignposition = v.Left
					v.Left = alignposition
				Case "right"
					If alignposition = -1 Then alignposition = v.Left+v.Width
					v.Left = alignposition
				Case "center"
					If alignposition = -1 Then 
						alignposition = v.Left+(v.Width/2)
					End If
					v.Left = alignposition - (v.Width/2)
				Case Else
			End Select
		End If
		i = i + 1
	Next
End Sub

