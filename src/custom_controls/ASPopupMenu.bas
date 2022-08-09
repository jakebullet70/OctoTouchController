B4A=true
Group=CUSTOM_CONTROLS
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
#If Documentation
Alexander Stolte
V1.00
	-Release
V1.01
	-Adds background_color global variable - the background color of the parent view during the menu is open
	-Adds setItemBackgroundColor - change the items background color
	-Better Handling in "Nested Layouts"
	-Add ActivityHasActionBar - set to true if you have a ActionBar enabled
	-Add IsInSpecialContainer - set it true if the target is on a listview or as a child on a panel where the left and top values differ from the form
	-Add setOrientationVertical
	-Add setOrientationHorizontal
	-Adds "Enums" for Orientations -TOP,BOTTOM -LEFT,MIDDLE,RIGHT
V1.02
	-Add Clear - clear all
	-Add getBase - gets the base view to customize it
	-Add getLabelProperties - customize it if you want, before you add a new menu item
	-Remove background_color and itembackground_color
		-Added to getLabelProperties
	-Add GetMenuItemAt_Label
	-Add GetMenuItemAt_Background
	-Add getSize
	-Add setMenuCornerRadius - sets the corner radius for the menu
V1.03
	-Add LeftRightPadding to ASPM_LabelProperties - label padding to have more space left and right for example HorizontalCenter = LEFT
	-OpenMenu the background is now smoother on show
	-setMenuCornerRadius is now available on B4J
V1.04
	-getLabelProperties is renamed to getItemLabelProperties
	-Add AddTitle - you can now add a title to the menu
		-Add TitleLabelProperties - you can change the title properties with it
	-Add RemoveTitle - Removes the title if exists
	-Add AutoHideMs
	-Add DividerEnabled - you can now shot dividers between the items
		-Add DividerHeight - the height of the dividers
		-Add DividerColor - the color of the dividers
V1.05
	-OpenMenu Show Animation with the background is now animated
	-BugFixes
V1.06
	-BugFix
V1.07
	-Add get isOpen - checks if the menu is open
	-BugFix - if you called OpenMenu several times without closing the menu, then the menu was added several times
	-Add set CloseAfterItemClick - closes the menu automatically after clicking on an item
		-standard is True
	-Add set and get CloseDurationMs - the duration it takes for the menu to be completely closed
	-Add set and get OpenDurationMs - the duration it takes for the menu to be fully visible
V1.08
	-Intern Function IIF renamed to iif2
V1.09
	-Add set MenuViewGap - sets the gap between the menu and the attached view
	-Add get TriangleProperties 
	-Add set ShowTriangle - only visible if you open the menu with OpenMenu
		-Default: False
V1.10
	-BugFix
V1.11
	-Add OpenMenuAdvanced - You can set the Left, Top and Width value to show the menu on the parent
	-Add MenuHeight - gets the MenuHeight even if the menu is not yet visible
	-BugFixes
#End If

#Event: ItemClicked(Index as Int,Tag as Object)

Sub Class_Globals
	Private xui As XUI
	Private mCallBack As Object
	Private mEventName As String
	
	Type ASPM_ItemLabelProperties(TextColor As Int,xFont As B4XFont,TextAlignment_Vertical As String,TextAlignment_Horizontal As String,BackgroundColor As Int,ItemBackgroundColor As Int,LeftRightPadding As Float)
	Type ASPM_TitleLabelProperties(TextColor As Int,xFont As B4XFont,TextAlignment_Vertical As String,TextAlignment_Horizontal As String,BackgroundColor As Int,ItemBackgroundColor As Int,LeftRightPadding As Float,Height As Float)
	Type ASPM_TriangleProperties(Color As Int,Width As Float,Height As Float,Left As Float,Top As Float)
	Private g_ItemLabelProperties As ASPM_ItemLabelProperties
	Private g_TitleLabelProperties As ASPM_TitleLabelProperties
	Private g_TriangleProperties As ASPM_TriangleProperties
	
	Private xpnl_background As B4XView
	Private background As B4XView
	Private xpnl_Triangle As B4XView
	
	Public item_height As Float = 40dip
	Private max_x,max_y As Float
	Private max_endlessloop As Int = 0
	
	Private LeftTop_Root() As Int
	
	Public AutoHideMs As Int
	Public CloseDurationMs As Int = 500
	Public OpenDurationMs As Int = 250
	
	Private g_OrientationVertical As String
	Private g_OrientationHorizontal As String
	Private g_IsInSpecialContainer As Boolean = False
	Private actHasActionBar As Boolean = False
	Private HasTitle As Boolean = False
	Private HasDividers As Boolean = False
	Private g_item_count As Int = 0
	Private g_DividerHeight As Int
	Private g_DividerEnabled As Boolean = False
	Private g_DividerColor As Int
	Private g_isOpen As Boolean = False
	Private g_CloseAfterItemClick As Boolean = True
	Private m_MenuViewGap As Float = 0
	Private m_ShowTriangle As Boolean = False
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Parent As B4XView,CallBack As Object,EventName As String)
	mCallBack = CallBack
	mEventName = EventName
	
	g_OrientationVertical = getOrientationVertical_TOP
	g_OrientationHorizontal = getOrientationHorizontal_MIDDLE
	
	max_x = Parent.Width
	max_y = Parent.Height
	LeftTop_Root = ViewScreenPosition(Parent)
	
	xpnl_background = xui.CreatePanel("")
	xpnl_background.Color = xui.Color_Transparent
	Parent.AddView(xpnl_background,0,0,0,0)
	xpnl_background.Visible = False

	
	g_ItemLabelProperties = CreateASPM_ItemLabelProperties(xui.Color_White,xui.CreateDefaultFont(16),"CENTER","CENTER",xui.Color_ARGB(152,255,255,255),xui.Color_ARGB(255,32, 33, 37),5dip)
	g_TitleLabelProperties = CreateASPM_TitleLabelProperties(xui.Color_White,xui.CreateDefaultBoldFont(18),"CENTER","CENTER",xui.Color_ARGB(152,255,255,255),xui.Color_ARGB(255,32, 33, 37),5dip,60dip)
	g_TriangleProperties = CreateASPM_TriangleProperties(xui.Color_White,20dip,10dip,-1,-1)
End Sub

Public Sub Resize(parent_width As Float,parent_height As Float)
	max_x = parent_width
	max_y = parent_height
End Sub

Public Sub AddMenuItem(text As String,tag As Object)
	
	Dim xpnl_item_background As B4XView = xui.CreatePanel("item")
	xpnl_item_background.Tag = "item"
	xpnl_item_background.Color = g_ItemLabelProperties.ItemBackgroundColor
	Dim xlbl_text As B4XView = CreateLabel("")
	xlbl_text.Tag = tag
	xlbl_text.TextColor = g_ItemLabelProperties.TextColor
	xlbl_text.Font = g_ItemLabelProperties.xFont
	xlbl_text.Text = text
	xlbl_text.SetTextAlignment(g_ItemLabelProperties.TextAlignment_Vertical,g_ItemLabelProperties.TextAlignment_Horizontal)
	xpnl_item_background.AddView(xlbl_text,0,0,0,0)
	
	xpnl_background.AddView(xpnl_item_background,0,0,0,0)
	g_item_count = g_item_count +1
End Sub

Public Sub AddTitle(Text As String, height As Float)
	
	Dim xpnl_item_background As B4XView = xui.CreatePanel("item")
	xpnl_item_background.Tag = "title"
	xpnl_item_background.Color = g_TitleLabelProperties.ItemBackgroundColor
	Dim xlbl_text As B4XView = CreateLabel("")
	xlbl_text.TextColor = g_TitleLabelProperties.TextColor
	xlbl_text.Font = g_TitleLabelProperties.xFont
	xlbl_text.Text = Text
	xlbl_text.SetTextAlignment(g_TitleLabelProperties.TextAlignment_Vertical,g_TitleLabelProperties.TextAlignment_Horizontal)
	xlbl_text.Color = g_TitleLabelProperties.BackgroundColor
	xpnl_item_background.Color = g_TitleLabelProperties.BackgroundColor
	xpnl_item_background.AddView(xlbl_text,0,0,0,0)
	g_TitleLabelProperties.Height = height
	xpnl_background.AddView(xpnl_item_background,0,0,0,0)
	HasTitle = True
End Sub
'Removes the title if exists
Public Sub RemoveTitle
	HasTitle = False
	For i = 0 To xpnl_background.NumberOfViews -1
		Dim xpnl_item_background As B4XView = xpnl_background.GetView(i)
		If xpnl_item_background.Tag = "title" Then
			xpnl_item_background.RemoveViewFromParent
			Return
		End If
	Next
End Sub

Private Sub AddDivider
	
	RemoveDividers
	
	If g_DividerEnabled = True Then
		
		For i = 1 To xpnl_background.NumberOfViews -1
			Dim xpnl_divider As B4XView = xui.CreatePanel("")
			xpnl_divider.Tag = "divider"
			xpnl_divider.Color = g_DividerColor
			xpnl_background.AddView(xpnl_divider,0,0,xpnl_background.Width,g_DividerHeight)
		Next
		HasDividers = True
	End If
	
End Sub

Private Sub RemoveAllDividers As Boolean
	For i = 0 To xpnl_background.NumberOfViews -1
		If xpnl_background.GetView(i).Tag = "divider" Then
			xpnl_background.GetView(i).RemoveViewFromParent
			Return True
		End If
	Next
	Return False
End Sub

Private Sub RemoveDividers
	Dim all_removed As Boolean = True
	Do While all_removed = True
		all_removed = RemoveAllDividers
	Loop
	
	HasDividers = False
End Sub
'checks if the menu is open
Public Sub getisOpen As Boolean
	Return g_isOpen
End Sub
'closes the menu automatically after clicking on an item
'standard is True
Public Sub setCloseAfterItemClick(enabled As Boolean)
	g_CloseAfterItemClick = enabled
End Sub
'Adds or Removes the dividers
Public Sub setDividerEnabled(enable As Boolean)
	g_DividerEnabled = enable
	If enable = False Then
		RemoveDividers
	End If
End Sub
'the height of the dividers
Public Sub setDividerHeight(height As Float)
	g_DividerHeight = height
End Sub
'the color of the dividers
Public Sub setDividerColor(color As Int)
	g_DividerColor = color
End Sub

Private Sub UpdateViews(width As Float)
	
	Dim tmp_divider_padding As Float = 0
	If g_DividerEnabled Then
		tmp_divider_padding = g_DividerHeight
	End If
	
	Dim tmp_item_padding As Float = 0
	Dim tmp_index_padding As Int = 0
	If HasTitle Then
		tmp_item_padding = g_TitleLabelProperties.Height
		tmp_index_padding = 1
	End If
	
	For i = 0 To xpnl_background.NumberOfViews -1
		Dim xpnl_item_background As B4XView = xpnl_background.GetView(i)
		If xpnl_item_background.Tag = "item" Then
			Dim xlbl_text As B4XView = xpnl_item_background.GetView(0)
			
			xpnl_item_background.SetLayoutAnimated(0,0,tmp_item_padding + _
						IIF2(HasTitle = False,0,tmp_divider_padding) + (i - tmp_index_padding) * (item_height + tmp_divider_padding),width,item_height)
'			If (i - tmp_index_padding) = 0 And g_DividerEnabled Then
'				xpnl_item_background.Top = xpnl_item_background.Top + tmp_divider_padding
'			End If
			xlbl_text.SetLayoutAnimated(0,0 + g_ItemLabelProperties.LeftRightPadding,0,xpnl_item_background.Width - (g_ItemLabelProperties.LeftRightPadding*2),xpnl_item_background.Height)
		Else if xpnl_item_background.Tag = "title" Then
			Dim xlbl_text As B4XView = xpnl_item_background.GetView(0)
			xpnl_item_background.SetLayoutAnimated(0,0,0,width,g_TitleLabelProperties.Height)
			xlbl_text.SetLayoutAnimated(0,0 + g_ItemLabelProperties.LeftRightPadding,0,xpnl_item_background.Width - (g_ItemLabelProperties.LeftRightPadding*2),xpnl_item_background.Height)
		Else if xpnl_item_background.Tag = "divider" Then
			xpnl_item_background.SetLayoutAnimated(0,0,0,width,g_DividerHeight)
			
		End If
	Next
		
	For i = 0 To xpnl_background.NumberOfViews -1
		
		Dim xpnl_item_background As B4XView = xpnl_background.GetView(i)

		If (xpnl_item_background.Tag = "item" Or xpnl_item_background.Tag = "title") And HasDividers Then

	

			If (g_item_count + tmp_index_padding + i) <> xpnl_background.NumberOfViews Then
				Dim xpnl_divider As B4XView = xpnl_background.GetView(g_item_count + tmp_index_padding + i)
				If xpnl_divider.Tag = "divider" Then

					xpnl_divider.SetLayoutAnimated(0,0,xpnl_item_background.Top + xpnl_item_background.Height,width,g_DividerHeight)
				End If
			End If
		End If
	Next
	
End Sub

Private Sub GetTopLeft(top As Float,left As Float,width As Float,view As B4XView)
	
	If top < 0 Then
		top = view.Top + view.Height
	Else If (top + xpnl_background.Height) > max_y Then
		top = view.Top - xpnl_background.Height
	Else If left < 0 Then
		left = 0
	Else If (left + width) > max_x Then
		left = max_x - width
	Else
		CallSubDelayed3(Me,"lol",left,top)
		Return
	End If
	If max_endlessloop = 10 Then 
		CallSubDelayed3(Me,"lol",left,top)
		Return
	End If
	max_endlessloop = max_endlessloop +1
	GetTopLeft(top,left,width,view)
End Sub

'Opens the menu on a view
Public Sub OpenMenu(view As B4XView,width As Float)
	If g_isOpen = False Then
		g_isOpen = True
		AddDivider
		UpdateViews(width)

		Dim total_height As Float = 0
		For i = 0 To xpnl_background.NumberOfViews -1
			total_height = total_height + xpnl_background.GetView(i).Height
		Next

	
		'xpnl_background.SetLayoutAnimated(0,0,view.Top - 50dip,width,tmp_item_padding + g_item_count*item_height)
		xpnl_background.SetLayoutAnimated(0,0,view.Top - 50dip,width,total_height)
		

		Dim ff() As Int = ViewScreenPosition(view)

		If g_IsInSpecialContainer = True Then
			Dim top As Float = ff(1) - LeftTop_Root(1)'+ view.Height 'xpnl_background.Height
			Dim left As Float = ff(0) - LeftTop_Root(0)'+ view.Width/2 - xpnl_background.Width/2
		Else
			Dim top As Float = view.top
			Dim left As Float = view.Left
		End If
		If actHasActionBar = True And g_IsInSpecialContainer = True Then
		#If B4A
			Dim j As JavaObject : j.InitializeContext
			top = top - j.RunMethodJO("getActionBar",Null).RunMethod("getHeight",Null)
			#Else IF B4I
		Dim NO As NativeObject = Main.NavControl
		top = top - NO.ArrayFromRect(NO.GetField("navigationBar").GetField("frame").RunMethod("CGRectValue", Null))(3)
		#End If
		End If
	
		If g_OrientationVertical = getOrientationVertical_TOP Then
			top = top - m_MenuViewGap
		Else
			top = top + view.Height + m_MenuViewGap
		End If
	
		'Log(view.Top)
		'Log(top)
		If g_OrientationVertical = getOrientationVertical_TOP Then
			top = top '- xpnl_background.Height
		Else
			top = top + view.Height
		End If
	
		If g_OrientationHorizontal = getOrientationHorizontal_LEFT Then
	
		else If g_OrientationHorizontal = getOrientationHorizontal_MIDDLE Then
			left = left + view.Width/2 - width/2
		Else
			left = left + view.Width - width
		End If
	
		max_endlessloop = 0
		GetTopLeft(top,left,width,view)
		Wait For lol (left As Float,top As Float)
	
		xpnl_background.Left = left
		xpnl_background.Top = top

		background = xui.CreatePanel("xpnl_touch")
		background.SetColorAnimated(OpenDurationMs,xui.Color_Transparent, g_ItemLabelProperties.BackgroundColor) 'color animation
	
		xpnl_background.Parent.AddView(background,0,0,xpnl_background.Parent.Width,xpnl_background.Parent.Height)
		xpnl_background.BringToFront
		xpnl_background.SetVisibleAnimated(OpenDurationMs,True)

		If m_ShowTriangle = True Then
			xpnl_Triangle = xui.CreatePanel("")
			xpnl_Triangle.Color = xui.Color_Transparent
			background.AddView(xpnl_Triangle,xpnl_background.Left + g_TriangleProperties.Width,xpnl_background.Top - g_TriangleProperties.Height,g_TriangleProperties.Width,g_TriangleProperties.Height)

			Dim xCV As B4XCanvas
			xCV.Initialize(xpnl_Triangle)
		
			xCV.ClearRect(xCV.TargetRect)
			Dim p As B4XPath
			Select g_OrientationVertical
				Case getOrientationVertical_TOP
					p.Initialize(0, 0).LineTo(xpnl_Triangle.Width, 0).LineTo(xpnl_Triangle.Width / 2, xpnl_Triangle.Height).LineTo(0, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Left
				Case getOrientationVertical_BOTTOM
					p.Initialize(xpnl_Triangle.Width / 2, 0).LineTo(xpnl_Triangle.Width, xpnl_Triangle.Height).LineTo(0, xpnl_Triangle.Height).LineTo(xpnl_Triangle.Width / 2, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Left
				Case getOrientationHorizontal_RIGHT
					p.Initialize(xpnl_Triangle.Width, 0).LineTo(xpnl_Triangle.Width, xpnl_Triangle.Height).LineTo(0, xpnl_Triangle.Height / 2).LineTo(xpnl_Triangle.Width, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Top
				Case getOrientationHorizontal_LEFT
					p.Initialize(0, 0).LineTo(xpnl_Triangle.Width, xpnl_Triangle.Height / 2).LineTo(0, xpnl_Triangle.Height).LineTo(0, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Top
			End Select
	
			xCV.DrawPath(p, g_TriangleProperties.Color, True, 0)
			xCV.Invalidate

		End If

	#If B4J
		setMenuCornerRadius(0)
	#End if
		If AutoHideMs > 0 Then
			Sleep(AutoHideMs)
			CloseMenu
		End If
	End If
End Sub

'Open the menu on center of parent/view
Public Sub OpenMenu2(parent As B4XView,width As Float)
	If g_isOpen = False Then
		g_isOpen = True
		AddDivider
		UpdateViews(width)

		Dim total_height As Float = 0
		For i = 0 To xpnl_background.NumberOfViews -1
			total_height = total_height + xpnl_background.GetView(i).Height
		Next
		xpnl_background.SetLayoutAnimated(0,parent.Left + parent.Width/2 - width/2,parent.Top + parent.Height/2 - total_height,width,total_height)
	
		background = xui.CreatePanel("xpnl_touch")
		background.SetColorAnimated(OpenDurationMs,xui.Color_Transparent,g_ItemLabelProperties.BackgroundColor)
	
		xpnl_background.Parent.AddView(background,0,0,xpnl_background.Parent.Width,xpnl_background.Parent.Height)
		xpnl_background.BringToFront
		xpnl_background.SetVisibleAnimated(OpenDurationMs,True)
	
	#If B4J
	setMenuCornerRadius(0)
	#End if
	
		If AutoHideMs > 0 Then
			Sleep(AutoHideMs)
			CloseMenu
		End If
	End If
End Sub

Public Sub OpenMenuAdvanced(Left As Float,Top As Float,Width As Float)
	
	If g_isOpen = False Then
		g_isOpen = True
		AddDivider
		UpdateViews(Width)

		Dim total_height As Float = 0
		For i = 0 To xpnl_background.NumberOfViews -1
			total_height = total_height + xpnl_background.GetView(i).Height
		Next
		xpnl_background.SetLayoutAnimated(0,Left,Top,Width,total_height)
	
		background = xui.CreatePanel("xpnl_touch")
		background.SetColorAnimated(OpenDurationMs,xui.Color_Transparent,g_ItemLabelProperties.BackgroundColor)
	
		xpnl_background.Parent.AddView(background,0,0,xpnl_background.Parent.Width,xpnl_background.Parent.Height)
		xpnl_background.BringToFront
		xpnl_background.SetVisibleAnimated(OpenDurationMs,True)
	
		If m_ShowTriangle = True Then
			xpnl_Triangle = xui.CreatePanel("")
			xpnl_Triangle.Color = xui.Color_Transparent
			background.AddView(xpnl_Triangle,xpnl_background.Left + g_TriangleProperties.Width,IIf(g_TriangleProperties.Top = -1,xpnl_background.Top,g_TriangleProperties.Top) - g_TriangleProperties.Height,g_TriangleProperties.Width,g_TriangleProperties.Height)

			Dim xCV As B4XCanvas
			xCV.Initialize(xpnl_Triangle)
		
			xCV.ClearRect(xCV.TargetRect)
			Dim p As B4XPath
			Select g_OrientationVertical
				Case getOrientationVertical_TOP
					p.Initialize(0, 0).LineTo(xpnl_Triangle.Width, 0).LineTo(xpnl_Triangle.Width / 2, xpnl_Triangle.Height).LineTo(0, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Left
				Case getOrientationVertical_BOTTOM
					p.Initialize(xpnl_Triangle.Width / 2, 0).LineTo(xpnl_Triangle.Width, xpnl_Triangle.Height).LineTo(0, xpnl_Triangle.Height).LineTo(xpnl_Triangle.Width / 2, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Left
				Case getOrientationHorizontal_RIGHT
					p.Initialize(xpnl_Triangle.Width, 0).LineTo(xpnl_Triangle.Width, xpnl_Triangle.Height).LineTo(0, xpnl_Triangle.Height / 2).LineTo(xpnl_Triangle.Width, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Top
				Case getOrientationHorizontal_LEFT
					p.Initialize(0, 0).LineTo(xpnl_Triangle.Width, xpnl_Triangle.Height / 2).LineTo(0, xpnl_Triangle.Height).LineTo(0, 0)
					xpnl_Triangle.Left = xpnl_background.Left + g_TriangleProperties.Top
			End Select
	
			xCV.DrawPath(p, g_TriangleProperties.Color, True, 0)
			xCV.Invalidate

		End If
	
	#If B4J
		setMenuCornerRadius(0)
	#End if
	
		If AutoHideMs > 0 Then
			Sleep(AutoHideMs)
			CloseMenu
		End If
	End If
	
End Sub

Public Sub getMenuHeight As Float
	
	If g_isOpen = False Then
		AddDivider
		UpdateViews(150dip)
	End If
	
	Dim total_height As Float = 0
	For i = 0 To xpnl_background.NumberOfViews -1
		total_height = total_height + xpnl_background.GetView(i).Height
	Next
	Return total_height
End Sub

#If B4J
Private Sub xpnl_touch_MouseClicked (EventData As MouseEvent)
	CloseMenu
End Sub
#Else
Private Sub xpnl_touch_Click
	CloseMenu
End Sub
#End If



Public Sub setMenuCornerRadius(radius As Int)
	xpnl_background.SetColorAndBorder(xpnl_background.Color,0,0,radius)
	SetCircleClip(xpnl_background,radius)
End Sub
'gets a menu item background (parent of label)
Public Sub GetMenuItemAt_Background(index As Int) As B4XView
	If HasTitle Then
		Return xpnl_background.GetView(index +1)
	Else
		Return xpnl_background.GetView(index)
	End If
End Sub
'gets a menu item label - the label with the text
Public Sub GetMenuItemAt_Label(index As Int) As B4XView
	If HasTitle Then
		Return xpnl_background.GetView(index +1).GetView(0)
	Else
		Return xpnl_background.GetView(index).GetView(0)
	End If
End Sub
'gets the list size
Public Sub getSize As Int
	Return xpnl_background.NumberOfViews
End Sub
'clears the list
Public Sub Clear
	xpnl_background.RemoveAllViews
	g_item_count = 0
End Sub

'change the label properties, call it before you add items
'<code>ASScrollingTags1.LabelProperties.xFont = xui.CreateDefaultBoldFont(15)</code>
Public Sub getItemLabelProperties As ASPM_ItemLabelProperties
	Return g_ItemLabelProperties
End Sub
'change the label properties, call it before you add the title
'<code>ASScrollingTags1.TitleLabelProperties.xFont = xui.CreateDefaultBoldFont(20)</code>
Public Sub getTitleLabelProperties As ASPM_TitleLabelProperties
	Return g_TitleLabelProperties
End Sub
'change the label properties, call it before you show the menu
'<code>ASScrollingTags1.TriangleProperties.Color = xui.Color_White</code>
Public Sub getTriangleProperties As ASPM_TriangleProperties
	Return g_TriangleProperties
End Sub
Public Sub getBase As B4XView
	Return xpnl_background
End Sub

'sets the gap between the menu and the attached view
'only affected if you open the menu with OpenMenu
Public Sub setMenuViewGap(Gap As Float)
	m_MenuViewGap = Gap
End Sub
'only affected if you open the menu with OpenMenu
Public Sub setShowTriangle(Show As Boolean)
	m_ShowTriangle = Show
End Sub
'set it true if the target is on a listview or as a child on a panel where the left and top values differ from the form
Public Sub setIsInSpecialContainer(value As Boolean)
	g_IsInSpecialContainer = value
End Sub

Public Sub CloseMenu
	xpnl_background.SetVisibleAnimated(CloseDurationMs,False)
	If xpnl_Triangle.IsInitialized = True Then xpnl_Triangle.Visible = False
	background.RemoveViewFromParent
	g_isOpen = False
End Sub

Private Sub CreateLabel(EventName As String) As B4XView
	Dim tmp_lbl As Label
	tmp_lbl.Initialize(EventName)
	#If B4I
	tmp_lbl.Multiline = True
	#End If
	Return tmp_lbl
End Sub

#If B4J
Private Sub item_MouseClicked (EventData As MouseEvent)
	ClickItem(Sender)
End Sub
#Else
Private Sub item_Click
	ClickItem(Sender)
End Sub
#End If

Private Sub ClickItem(xpnl_item_background As B4XView)
	
	If xpnl_item_background.Tag = "item" Then
		CreateHaloEffect(xpnl_item_background,xui.Color_ARGB(152,255,255,255))
		
		For i = 0 To xpnl_background.NumberOfViews -1
			If xpnl_background.GetView(i) = xpnl_item_background Then
				
				If HasTitle Then
					ItemClicked(i -1,xpnl_item_background.GetView(0).Tag)
				Else
					ItemClicked(i,xpnl_item_background.GetView(0).Tag)
				End If
				If g_CloseAfterItemClick = True Then CloseMenu
			End If
		Next
		
	End If
	
End Sub

'sets the item background color for all items
Public Sub setItemBackgroundColor(crl As Int)
	g_ItemLabelProperties.ItemBackgroundColor = crl
	For i = 0 To xpnl_background.NumberOfViews -1
	Dim xpnl_item_background As B4XView = xpnl_background.GetView(i)
		xpnl_item_background.Color = crl
	Next
End Sub

Public Sub setOrientationVertical(orientation As String)
	If orientation = getOrientationVertical_BOTTOM Then
		g_OrientationVertical = orientation
		Else
		g_OrientationVertical = getOrientationVertical_TOP
	End If
End Sub

Public Sub setOrientationHorizontal(orientation As String)
	If orientation = getOrientationHorizontal_LEFT Or orientation = getOrientationHorizontal_RIGHT Then
		g_OrientationHorizontal = orientation
		Else
		g_OrientationHorizontal = getOrientationHorizontal_MIDDLE
	End If
End Sub

Public Sub setActivityHasActionBar(value As Boolean)
	actHasActionBar = value
End Sub

#Region Enums
'Vertical = Top,Bottom
'Horizontal = Left,Middle,Right
Public Sub getOrientationVertical_TOP As String
	Return "TOP"
End Sub

Public Sub getOrientationVertical_BOTTOM As String
	Return "BOTTOM"
End Sub

Public Sub getOrientationHorizontal_LEFT As String
	Return "LEFT"
End Sub

Public Sub getOrientationHorizontal_MIDDLE As String
	Return "MIDDLE"
End Sub

Public Sub getOrientationHorizontal_RIGHT As String
	Return "RIGHT"
End Sub

#End Region

#Region Functions
Private Sub SetCircleClip (pnl As B4XView,radius As Int)'ignore
#if B4J
Dim jo As JavaObject = pnl
Dim shape As JavaObject
Dim cx As Double = pnl.Width
Dim cy As Double = pnl.Height
shape.InitializeNewInstance("javafx.scene.shape.Rectangle", Array(cx, cy))
If radius > 0 Then
	Dim d As Double = radius
	shape.RunMethod("setArcHeight", Array(d))
	shape.RunMethod("setArcWidth", Array(d))
End If
jo.RunMethod("setClip", Array(shape))
#else if B4A
	Try
		'--- fails in Android pre V5
		Dim jo As JavaObject = pnl
		jo.RunMethod("setClipToOutline", Array(True))
	Catch
		'Log(LastException)
	End Try'ignore
#end if
End Sub

Private Sub CreateHaloEffect (Parent As B4XView,clr As Int)
	Dim cvs As B4XCanvas
	Dim p As B4XView = xui.CreatePanel("")
	Dim radius As Int = 150dip
	p.SetLayoutAnimated(0, 0, 0, radius * 2, radius * 2)
	cvs.Initialize(p)
	cvs.DrawCircle(cvs.TargetRect.CenterX, cvs.TargetRect.CenterY, cvs.TargetRect.Width / 2, clr, True, 0)
	Dim bmp As B4XBitmap = cvs.CreateBitmap
	
	CreateHaloEffectHelper(Parent,bmp, radius)

End Sub

Private Sub CreateHaloEffectHelper (Parent As B4XView,bmp As B4XBitmap, radius As Int)
	Dim x As Float = Parent.Width/2
	Dim y As Float = Parent.Height/2
	Dim iv As ImageView
	iv.Initialize("")
	Dim p As B4XView = iv
	p.SetBitmap(bmp)
	Parent.AddView(p, x, y, 0, 0)
	Dim duration As Int = 500
	p.SetLayoutAnimated(duration, x - radius, y - radius, 2 * radius, 2 * radius)
	p.SetVisibleAnimated(duration, False)
	Sleep(duration)
	p.RemoveViewFromParent
End Sub

Sub ViewScreenPosition (view As B4XView) As Int()
	
	Dim leftTop(2) As Int
	#IF B4A
	Dim JO As JavaObject = view
	JO.RunMethod("getLocationOnScreen", Array As Object(leftTop))
	#Else If B4I
	'https://www.b4x.com/android/forum/threads/absolute-position-of-view.56821/#content
	Dim parent As B4XView = view
	Do While GetType(parent) <> "B4IMainView"
		Dim no As NativeObject = parent
		leftTop(0) = leftTop(0) + parent.Left
		leftTop(1) = leftTop(1) + parent.Top
		parent = no.GetField("superview")
   Loop
	#Else
	Dim parent As B4XView = view
   Do While parent.IsInitialized
       leftTop(0) = leftTop(0) + parent.Left
       leftTop(1) = leftTop(1) + parent.Top
       parent = parent.Parent
   Loop
	#End If

	Return Array As Int(leftTop(0), leftTop(1))
End Sub

#End Region

Private Sub ItemClicked(index As Int,tag As Object)
	If xui.SubExists(mCallBack,mEventName & "_ItemClicked",2) Then
		CallSub3(mCallBack,mEventName & "_ItemClicked",index,tag)
	End If
End Sub

Public Sub CreateASPM_ItemLabelProperties (TextColor As Int, xFont As B4XFont, TextAlignment_Vertical As String, _
																	TextAlignment_Horizontal As String, BackgroundColor As Int, _
																	ItemBackgroundColor As Int, LeftRightPadding As Float) As ASPM_ItemLabelProperties
																	
	Dim t1 As ASPM_ItemLabelProperties
	t1.Initialize
	t1.TextColor = TextColor
	t1.xFont = xFont
	t1.TextAlignment_Vertical = TextAlignment_Vertical
	t1.TextAlignment_Horizontal = TextAlignment_Horizontal
	t1.BackgroundColor = BackgroundColor
	t1.ItemBackgroundColor = ItemBackgroundColor
	t1.LeftRightPadding = LeftRightPadding
	Return t1
End Sub

Public Sub CreateASPM_TitleLabelProperties (TextColor As Int, xFont As B4XFont, TextAlignment_Vertical As String, _
																	TextAlignment_Horizontal As String, BackgroundColor As Int, _
																	 ItemBackgroundColor As Int, LeftRightPadding As Float, Height As Float) As ASPM_TitleLabelProperties
																	 
	Dim t1 As ASPM_TitleLabelProperties
	t1.Initialize
	t1.TextColor = TextColor
	t1.xFont = xFont
	t1.TextAlignment_Vertical = TextAlignment_Vertical
	t1.TextAlignment_Horizontal = TextAlignment_Horizontal
	t1.BackgroundColor = BackgroundColor
	t1.ItemBackgroundColor = ItemBackgroundColor
	t1.LeftRightPadding = LeftRightPadding
	t1.Height = Height
	Return t1
End Sub

Private Sub IIF2(c As Boolean, TrueRes As Object, FalseRes As Object) As Object
	If c Then Return TrueRes Else Return FalseRes
End Sub

Public Sub CreateASPM_TriangleProperties (Color As Int, Width As Float, Height As Float, Left As Float, Top As Float) As ASPM_TriangleProperties
	Dim t1 As ASPM_TriangleProperties
	t1.Initialize
	t1.Color = Color
	t1.Width = Width
	t1.Height = Height
	t1.Left = Left
	t1.Top = Top
	Return t1
End Sub

