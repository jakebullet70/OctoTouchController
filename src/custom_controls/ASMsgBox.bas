B4J=true
Group=CUSTOM_CONTROLS
ModulesStructureVersion=1
Type=Class
Version=6.3
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region
'Version: 1.1
'Author: Alexander Stolte
'Update: 08.11.2018

#If DOCUMENTATION
Features:
-Fully Customizable
-Top and Bottom bar can be hidden
-A Close Button can be visible
-Show an Icon (Left , Middle or Right to text)
-Set Title
-You can Create your own dialog if you hide the top and bottom bar 
-LoadLayout from Layoutfile or with code
-Customize the Bottom Buttons
-Dragable
-asynchronous with wait for
-show the dialog with text (no layout required)

Updates:
Version 1.0 08.11.2018
-Release

Version 1.1 13.11.2018
-Bug Fixes
-you can now set the height and width, if you "InitializeWithoutDesigner"

#End If

#DesignerProperty: Key: Back_Color, DisplayName: MSG Back Color, FieldType: Color, DefaultValue: 0xFFCFDCDC, Description: You can use the built-in color picker to find the color values.
#DesignerProperty: Key: show_header, DisplayName: Show Header, FieldType: Boolean, DefaultValue: True, Description: Example of a boolean property.
#DesignerProperty: Key: show_bottom, DisplayName: Show Bottom, FieldType: Boolean, DefaultValue: True, Description: Example of a boolean property.
#DesignerProperty: Key: Show_X, DisplayName: Show Close Button, FieldType: Boolean, DefaultValue: False, Description: Example of a boolean property.
#DesignerProperty: Key: Header_CLR, DisplayName: Header Color, FieldType: Color, DefaultValue: 0xFF8E44AD, Description: You can use the built-in color picker to find the color values.
#DesignerProperty: Key: Bottom_CLR, DisplayName: Bottom Color, FieldType: Color, DefaultValue: 0xFF16A085, Description: You can use the built-in color picker to find the color values.
#DesignerProperty: Key: Icon_visible, DisplayName: Icon Visible, FieldType: Boolean, DefaultValue: True, Description: Example of a boolean property.
#DesignerProperty: Key: Icon_direction, DisplayName: Icon Direction, FieldType: String, DefaultValue: LEFT, List: LEFT|MIDDLE|RIGHT
#DesignerProperty: Key: BorderWidth, DisplayName: Border Width, FieldType: Int, DefaultValue: 0, MinRange: 0, MaxRange: 5, Description: Border Width from the Icon
#DesignerProperty: Key: header_font_size, DisplayName: Header Font Size, FieldType: Int, DefaultValue: 20, MinRange: 1, MaxRange: 100, Description: Note that MinRange and MaxRange are optional.
#DesignerProperty: Key: Header_Text, DisplayName: Header Text, FieldType: String, DefaultValue: Anywhere B4X

#Event: result(res As Int)
#Event: IconClick
#Event: IconLongClick

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As B4XView 'ignore
	Private xui As XUI 'ignore
	
	'DesignerPropertys
	
	Private back_color As Int 
	Private showX As Boolean
	Private header_clr As Int
	Private bottom_crl As Int
	
	Private iconVisible As Boolean
	Private iconDirection As String
	Private border_width As Int
	
	Private showHeader As Boolean
	Private showBottom As Boolean
	
	Private headerFontSize As Int
	Private headerText As String
	
	Private xpnl_close As B4XView
	
	Private xline_1,xline_2 As B4XView
	
	Private xIconFont As B4XFont
	
	'Views
	Private lbl_header As Label
	Private xlbl_header As B4XView
	Private xpnl_header As B4XView
	Private xpnl_bottom As B4XView
	Private xiv_icon As B4XView
	Private xpnl_content As B4XView
	Private xlbl_action_1,xlbl_action_2,xlbl_action_3 As B4XView
	Private xpnl_actionground As B4XView
	Private xlbl_text As B4XView
	
	'variables
	Private dragable As Int = 0
	Private donwx As Int
	Private downy As Int
	
	Private BottomHeight As Float = 50dip ' not really working

End Sub


'is only needed, if you not use the designer to show this dialog
'dont forget to set the header and bottom properties if you show the header or bottom
Public Sub InitializeWithoutDesigner(parent As B4XView,backgroundcolor As Int, _
				show_header As Boolean,show_bottom As Boolean,show_close_button As Boolean, _
				width As Int, height As Int)
	
	
	Dim tmp_base As B4XView
	tmp_base = xui.CreatePanel(mEventName)
	
	parent.AddView(tmp_base, 0 + parent.Width/2 - tmp_base.Width/2,0 + parent.Height/2 - tmp_base.Height/2,width,height)

	Dim props As Map
	props.Initialize
	props.Put("Back_Color",backgroundcolor)
	props.Put("show_header",show_header)
	props.Put("show_bottom",show_bottom)
	props.Put("Show_X",show_close_button)
	props.Put("Header_CLR",0xFF2F343A)
	props.Put("Bottom_CLR",0xFF2F343A)
	
	If show_header = True Then
		props.Put("Icon_visible",True)
		props.Put("Icon_direction","LEFT")
	Else
		props.Put("Icon_visible",False)
		props.Put("Icon_direction","LEFT")
	End If
	
	props.Put("BorderWidth",0)
	
	props.Put("header_font_size",20)
	props.Put("Header_Text","Anywhere B4X")
	
	Dim lbl As Label : lbl.Initialize("")
	
	DesignerCreateView(tmp_base,lbl,props)
	
	mBase.Visible = False
	
	Base_Resize(mBase.Width,mBase.Height)
	

End Sub


'button1 = negative button2 = close button3 = positive
Public Sub InitializeBottom(button1 As String,button2 As String,button3 As String)
	
	If button1 = "" Then
		xlbl_action_1.Text = ""
		xlbl_action_1.Visible = False
	Else
		xlbl_action_1.Text = button1
		xlbl_action_1.Visible = True
	End If
	
	If button2 = "" Then
		xlbl_action_2.Text = ""
		xlbl_action_2.Visible = False
	Else
		xlbl_action_2.Text = button2
		xlbl_action_2.Visible = True
	End If
	
	If button3 = "" Then
		xlbl_action_3.Text = ""
		xlbl_action_3.Visible = False
	Else
		xlbl_action_3.Text = button3
		xlbl_action_3.Visible = True
	End If
	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

'gets the base
Public Sub getBase As B4XView
	Return mBase
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, lbl As Label, Props As Map)
	mBase = Base
  
  	back_color = xui.PaintOrColorToColor(Props.Get("Back_Color"))
	showX = Props.Get("Show_X")
	header_clr = xui.PaintOrColorToColor(Props.Get("Header_CLR"))
	bottom_crl = xui.PaintOrColorToColor(Props.Get("Bottom_CLR"))

	iconVisible = Props.Get("Icon_visible")
	iconDirection = Props.Get("Icon_direction")
	border_width = DipToCurrent(Props.Get("BorderWidth"))

	showHeader = Props.Get("show_header")
	showBottom = Props.Get("show_bottom")
	
	headerFontSize = Props.Get("header_font_size")

	headerText = Props.Get("Header_Text")

	create_top
	create_bottom
	
	xpnl_content = xui.CreatePanel("xpnl_content")
	mBase.AddView(xpnl_content,0,xpnl_header.Height,mBase.Width,xpnl_bottom.Top - xpnl_header.Height)
	xpnl_content.Color = xui.Color_Transparent

	Private r As Reflector
	r.Target = xpnl_content
	r.SetOnTouchListener("xpnl_content_Touch2")

	Dim lbl_text As Label 
	lbl_text.Initialize("")
	
	xlbl_text = lbl_text
	xlbl_text.TextColor = clrTheme.txtNormal
	xlbl_text.Font = xui.CreateDefaultBoldFont(22)
	xlbl_text.SetTextAlignment("CENTER","CENTER")
	
	mBase.AddView(xlbl_text,0,xpnl_header.Height,mBase.Width,xpnl_bottom.Top - xpnl_header.Height)

	xlbl_text.Visible = False

	Base_Resize(mBase.width,mBase.height)

End Sub

'show the dialog with centered text instead of a panel or layout.
Public Sub ShowWithText(text As String,animated As Boolean)
	
	xlbl_text.BringToFront
	xlbl_text.Visible = True
	If animated = True Then
		mBase.Visible = True
	'	mBase.SetVisibleAnimated(300,True)
		'ShakeView(mBase,1000)
		AnimateView(mBase,500,mBase.Left,mBase.Top,mBase.Width,mBase.Height)
	Else If animated = False Then
		mBase.Visible = True
	End If
	
	xlbl_text.Text = text
	
End Sub

Sub ShakeView (View As B4XView, Duration As Int)'ignore 'comes wih the next update
	Dim Left As Int = View.Left
	Dim Delta As Int = 20dip
	For i = 1 To 4
		View.SetLayoutAnimated(Duration / 5, Left + Delta, View.Top, View.Width, View.Height)
		Delta = -Delta
		Sleep(Duration / 5)
	Next
	View.SetLayoutAnimated(Duration/5, Left, View.Top, View.Width, View.Height)
End Sub

Sub AnimateView(View As B4XView, Duration As Int, Left As Int, Top As Int, Width As Int, Height As Int)
	Dim cx As Int = Left + Width / 2
	Dim cy As Int = Top + Height / 2
	View.SetLayoutAnimated(0, cx, cy, 0, 0)
	Dim start As Long = DateTime.Now
	Do While DateTime.Now < start + Duration
		Dim p As Float = (DateTime.Now - start) / Duration
		Dim f As Float = 1 - Cos(p * 3 * cPI) * (1 - p)
		Dim w As Int = Width * f
		Dim h As Int = Height * f
		View.SetLayoutAnimated(0, cx - w / 2, cy - h / 2, w, h)
		Sleep(16)
	Loop
	View.SetLayoutAnimated(0, Left, Top, Width, Height)
End Sub


Public Sub Show(animated As Boolean)
	
	If animated = True Then
		mBase.SetVisibleAnimated(300,True)
	Else If animated = False Then
		mBase.Visible = True
	End If
	
End Sub

Public Sub Close(animated As Boolean) As ResumableSub
	
	If mBase.IsInitialized And mBase.Parent.IsInitialized Then
		If animated = True Then
			mBase.SetVisibleAnimated(300,False)
			Else If animated = False Then
				mBase.Visible = False
			
		End If
		Return True
	End If
	Return False
	
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
  
	mBase.SetColorAndBorder(back_color,2dip,clrTheme.txtNormal,5dip)
  	
	xpnl_header.Visible = showHeader
	xpnl_bottom.Visible = showBottom
	xpnl_close.Visible  = showX
  
  	If showHeader = True Then
  	
		xpnl_header.Width = mBase.Width
		xline_1.Width = mBase.Width
		xpnl_header.Color = header_clr
		xlbl_header.Height = MeasureTextHeight(xlbl_header.Text, xlbl_header.Font) + 8dip
		xpnl_content.Top = xpnl_header.Height
		
	  
		If iconVisible = True Then
			If iconDirection = "LEFT" Then
				
				xiv_icon.Width = 40dip
				xiv_icon.Height = 40dip
				
				xlbl_header.Top = xpnl_header.Top + xpnl_header.Height/2 - xlbl_header.Height/2
				xlbl_header.Width =	MeasureTextWidth(xlbl_header.Text,xlbl_header.Font) + 1dip
				xlbl_header.Left = xpnl_header.Width/2 - xlbl_header.Width/2
				xiv_icon.Left = xlbl_header.Left - xiv_icon.Width - 5dip
				xiv_icon.Top = xpnl_header.Top + xpnl_header.Height/2 - xiv_icon.Height/2
				
			Else If iconDirection = "MIDDLE" Then
				
				xiv_icon.Width = 30dip
				xiv_icon.Height = 30dip
				
				xiv_icon.Top = 4dip
				xiv_icon.Left = xpnl_header.Width/2 - xiv_icon.Width/2
				
				xlbl_header.Top = xiv_icon.Top + xiv_icon.Height - 4dip' xpnl_header.Top + xpnl_header.Height/2 - xlbl_header.Height/2
				xlbl_header.Width =	MeasureTextWidth(xlbl_header.Text,xlbl_header.Font) + 1dip
				xlbl_header.Left = xpnl_header.Width/2 - xlbl_header.Width/2
			
				
			Else If iconDirection = "RIGHT" Then
				
				xlbl_header.Top = xpnl_header.Top + xpnl_header.Height/2 - xlbl_header.Height/2
				xlbl_header.Width =	MeasureTextWidth(xlbl_header.Text,xlbl_header.Font) + 1dip
				xlbl_header.Left = xpnl_header.Width/2 - xlbl_header.Width/2
				xiv_icon.Left = xlbl_header.Left + xlbl_header.Width + 5dip
				xiv_icon.Top = xpnl_header.Top + xpnl_header.Height/2 - xiv_icon.Height/2
				
			End If
			
		Else
				
			xiv_icon.Width = 40dip
			xiv_icon.Height = 40dip
				
			xlbl_header.Top = xpnl_header.Top + xpnl_header.Height/2 - xlbl_header.Height/2
			xlbl_header.Left = xpnl_header.Left + 5dip
			xlbl_header.Width = xpnl_header.Width - 5dip
			
		End If
	  
  	Else
  	
		xpnl_content.Top = 0
  
	End If
  
 	If showBottom = True Then
  	
		xpnl_bottom.Color = bottom_crl
		xpnl_bottom.Top = mBase.Height - BottomHeight
		xpnl_bottom.Width = mBase.Width
		xline_2.Width = mBase.Width
	
		'xpnl_bottom.AddView(xpnl_actionground,10dip,5dip,xpnl_bottom.Width - 20dip,xpnl_bottom.Height - 10dip)
	
		xpnl_actionground.Width = xpnl_bottom.Width - 10dip
		xpnl_content.Height = mBase.Height - xpnl_content.Top - xpnl_bottom.Height
	
	Else
	
		xpnl_content.Height = mBase.Height - xpnl_content.Top
	
	End If

	xlbl_action_1.Left = 0
	xlbl_action_1.Width = xpnl_actionground.Width/3 -5dip
	
	xlbl_action_2.Left = xlbl_action_1.Left + xlbl_action_1.Width +5dip
	xlbl_action_2.Width = xpnl_actionground.Width/3 '-5dip
	
	xlbl_action_3.Left = xlbl_action_2.Left + xlbl_action_2.Width +5dip
	xlbl_action_3.Width = xpnl_actionground.Width/3 -5dip
	
End Sub


#Region CreateView

Private Sub create_top
	
	'Header
	xpnl_header = xui.CreatePanel("xpnl_header")
	mBase.AddView(xpnl_header,0,0,mBase.Width,60dip)
	xpnl_header.Color = xui.Color_White
	xpnl_header.SetColorAndBorder(xui.Color_Red,2dip,xui.Color_Transparent,5dip)

	Private r As Reflector
	r.Target = xpnl_header
	r.SetOnTouchListener("xpnl_header_Touch2")
	
	'line 1
	xline_1 = xui.CreatePanel("")
	xpnl_header.AddView(xline_1,0dip,xpnl_header.Height - 2dip,xpnl_header.Width,2dip)
	xline_1.Color = xui.Color_White
	MakeViewBackgroundTransparent(xline_1,100)
	
	'Close Button
	Private lbl_close As Label
	lbl_close.Initialize("xpnl_close")
	xpnl_close = lbl_close
	mBase.AddView(xpnl_close, mBase.Width - 5dip - 20dip,2dip,20dip,20dip)
  
	xIconFont = xui.CreateFont(Typeface.CreateNew(Typeface.FONTAWESOME, Typeface.STYLE_NORMAL), 26) 
	
	xpnl_close.Font = xIconFont
	xpnl_close.TextColor = xui.Color_White
	xpnl_close.Text = Chr(0xF00D)
  	

'Icon
	Private iv_icon As ImageView
	iv_icon.Initialize("xiv_icon")
	'später noch click event hinzufügen
	xiv_icon = iv_icon
	xpnl_header.AddView(xiv_icon,5dip,0,40dip,40dip)
	

	'head
	lbl_header.Initialize("")
	xlbl_header = lbl_header
	
	xpnl_header.AddView(xlbl_header,5dip,5dip,xpnl_header.Width - 5dip,20dip)
	xlbl_header.TextColor = xui.Color_White
	xlbl_header.Font = xui.CreateDefaultBoldFont(headerFontSize)
	xlbl_header.SetTextAlignment("CENTER","CENTER")
	xlbl_header.Text = headerText

End Sub

Private Sub create_bottom
	
	'Bottom
	xpnl_bottom = xui.CreatePanel("")
	mBase.AddView(xpnl_bottom,0,mBase.Height - BottomHeight,mBase.Width, BottomHeight)
	xpnl_bottom.Color = xui.Color_Red
	xpnl_bottom.SetColorAndBorder(xui.Color_white, 2dip,xui.Color_Transparent,5dip)
	
	'line 2
	xline_2 = xui.CreatePanel("")
	xpnl_bottom.AddView(xline_2,0dip,0dip,xpnl_bottom.Width,2dip)
	xline_2.Color = xui.Color_White
	MakeViewBackgroundTransparent(xline_2,100)
	
	
	'action buttons
	xpnl_actionground = xui.CreatePanel("")
	xpnl_bottom.AddView(xpnl_actionground,5dip,5dip,xpnl_bottom.Width - 5dip,xpnl_bottom.Height - 10dip)
	
	'xpnl_actionground.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,0)
	
	Dim lbl_action_1,lbl_action_2,lbl_action_3 As Label
	lbl_action_1.Initialize("xlbl_action_1")
	lbl_action_2.Initialize("xlbl_action_2")
	lbl_action_3.Initialize("xlbl_action_3")

	xlbl_action_1 = lbl_action_1
	xlbl_action_2 = lbl_action_2
	xlbl_action_3 = lbl_action_3
	
	xlbl_action_1.Tag = getCANCEL
	xlbl_action_2.Tag = getNEGATIVE
	xlbl_action_3.Tag = getPOSITIVE
	
	xpnl_actionground.AddView(xlbl_action_1,0,0,0 ,xpnl_actionground.Height)
	xpnl_actionground.AddView(xlbl_action_2,xlbl_action_1.Left + xlbl_action_1.Width + 5dip,0,0,xpnl_actionground.Height)
	xpnl_actionground.AddView(xlbl_action_3,xlbl_action_2.Left + xlbl_action_2.Width + 5dip,0,0,xpnl_actionground.Height)

	xlbl_action_1.Font = xui.CreateDefaultBoldFont(20)
	xlbl_action_2.Font = xui.CreateDefaultBoldFont(20)
	xlbl_action_3.Font = xui.CreateDefaultBoldFont(20)
	
	xlbl_action_1.TextColor = xui.Color_White
	xlbl_action_2.TextColor = xui.Color_White
	xlbl_action_3.TextColor = xui.Color_White
	
	xlbl_action_1.SetTextAlignment("CENTER","CENTER")
	xlbl_action_2.SetTextAlignment("CENTER","CENTER")
	xlbl_action_3.SetTextAlignment("CENTER","CENTER")
	
End Sub

#End Region

#Region Header

Private Sub xiv_icon_Click
	icon_click_handler
End Sub


Private Sub xiv_icon_LongClick
	icon_longclick_handler
End Sub

Private Sub icon_click_handler
	
	If xui.SubExists(mCallBack, mEventName & "_IconClick",0) Then
		CallSub(mCallBack, mEventName & "_IconClick")
	End If
	
End Sub

Private Sub icon_longclick_handler
	
	If xui.SubExists(mCallBack, mEventName & "_IconLongClick",0) Then
		CallSub(mCallBack, mEventName & "_IconLongClick")
	End If
	
End Sub

'--- gets or sets the header text
Public Sub getHeader_Text As String
	Return headerText
End Sub
Public Sub setHeader_Text(text As String)
	headerText = text
	xlbl_header.Text = headerText
	Base_Resize(mBase.Width,mBase.Height)
End Sub

'--- gets or set the Header Font Size
Public Sub getHeader_Font_Size As Int
	Return headerFontSize
End Sub
Public Sub setHeader_Font_Size(fontsize As Int)
	headerFontSize = fontsize
	xlbl_header.Font = xui.CreateDefaultBoldFont(headerFontSize)
	Base_Resize(mBase.Width,mBase.Height)
End Sub

'gets or sets the icon direction
'Possible: LEFT, RIGHT and MIDDLE
Public Sub setIcon_direction(direction As String)
	
	If direction = "LEFT" Or direction = "RIGHT" Or direction = "MIDDLE" Then
		iconDirection = direction
		Base_Resize(mBase.Width,mBase.Height)
	Else
		Return 
	End If
	
End Sub

'gets or sets the icon direction
'Possible: LEFT, RIGHT and MIDDLE
Public Sub getIcon_direction As String
	Return iconDirection
End Sub

Public Sub icon_visible(visible As Boolean)
	iconVisible = visible
	Base_Resize(mBase.Width,mBase.Height)
End Sub

'possible: 0-5
Public Sub icon_border_width(border As Int)
	
	If border > -1 And border < 6 Then
		border_width = border
		'Base_Resize(mBase.Width,mBase.Height)
		'funktioniert noch nicht
	Else
		Return
	End If
	
End Sub



Private Sub xpnl_header_Touch2 (o As Object, ACTION As Int, x As Float, y As Float, motion As Object) As Boolean
	If dragable = 1 Then
		If ACTION = xpnl_bottom.TOUCH_ACTION_DOWN Then
			donwx  = X
			downy  = y
		Else if ACTION = xpnl_bottom.TOUCH_ACTION_MOVE Then
			mBase.Top = mBase.Top + y - downy
			mBase.Left = mBase.Left + x - donwx
		End If
	End If
	Return True
End Sub


Private Sub xpnl_content_Touch2 (o As Object, ACTION As Int, x As Float, y As Float, motion As Object) As Boolean
	If dragable = 2 Then
		If ACTION = xpnl_bottom.TOUCH_ACTION_DOWN Then
			donwx  = X
			downy  = y
		Else if ACTION = xpnl_bottom.TOUCH_ACTION_MOVE Then
			mBase.Top = mBase.Top + y - downy
			mBase.Left = mBase.Left + x - donwx
		End If
	End If
	Return True
End Sub


Public Sub setEnableDrag(enable As Int)
	dragable = enable
End Sub
Public Sub getEnableDrag As Int
	Return dragable
End Sub

Public Sub getDragableTop As Int
	Return 1
End Sub

Public Sub getDragableContent As Int
	Return 2
End Sub

Public Sub getDragableDisable As Int
	Return 0
End Sub

Public Sub icon_set_icon(icon As B4XBitmap)
	If border_width > 0 Then
		xiv_icon.SetBitmap(CreateRoundBitmap(icon,xiv_icon.Width))
	Else
		xiv_icon.SetBitmap(icon.Resize(xiv_icon.Width,xiv_icon.Height,True))
	End If
End Sub

'gets or sets close button visible state
Public Sub setCloseButtonVisible(visible As Boolean)
	showX = visible
	Base_Resize(mBase.Width,mBase.Height)
End Sub

'gets or sets close button visible state
Public Sub getCloseButtonVisible As Boolean
	Return showX
End Sub

#End Region

'gets the Bottom of the header
Public Sub getHeaderBottom As Int
	Return xpnl_header.Height
End Sub

'gets the Bottom of the header
Public Sub getBottomTop As Int
	Return xpnl_bottom.Top
End Sub

'gets the height of the content area
Public Sub getContentHeight As Int
	Return xpnl_content.Height
End Sub

Public Sub CenterDialog(Parent As B4XView)
	mBase.Left = Parent.Width/2 - mBase.Width/2
	mBase.Top = 0 + Parent.Height/2  - mBase.Height/2
End Sub

'Gets the Action Button1 to modify the visual part
Public Sub getButton1 As B4XView
	Return xlbl_action_1
End Sub

'Gets the Action Button2 to modify the visual part
Public Sub getButton2 As B4XView
	Return xlbl_action_2
End Sub

'Gets the Action Button3 to modify the visual part
Public Sub getButton3 As B4XView
	Return xlbl_action_3
End Sub

'set the layout for designer
Public Sub LoadLayout(layout As String)
	xpnl_content.LoadLayout(layout)
End Sub

'set a panel as layout
Public Sub LoadLayout2(p As B4XView)
	xpnl_content = p
End Sub

'Public Sub getHeaderColor As Int
'	Return xpnl_header.Color
'End Sub
'
'Public Sub getBottomColor As Int
'	Return xpnl_bottom.Color
'End Sub

Public Sub setHeaderColor(color As Int)
	header_clr = color
	xpnl_header.Color = color
End Sub

Public Sub setBottomColor(color As Int)
	bottom_crl = color
	xpnl_bottom.Color = color
End Sub

#Region CloseButton

Private Sub xpnl_close_Click
	closebutton_handler(Sender)
End Sub


Private Sub closebutton_handler(SenderPanel As B4XView)
	mBase.Visible = False
End Sub

#End Region

#Region results

'button3 right
Public Sub getPOSITIVE As Int
	Return 3
End Sub

'button2 middle
Public Sub getNEGATIVE As Int
	Return 2
End Sub

'button1 left
Public Sub getCANCEL As Int
	Return 1
End Sub


Private Sub xlbl_action_1_Click
	result(xlbl_action_1.Tag)
End Sub

Private Sub xlbl_action_2_Click
	result(xlbl_action_2.Tag)
End Sub

Private Sub xlbl_action_3_Click
	result(xlbl_action_3.Tag)
End Sub


Private Sub result(res As Int)
	If xui.SubExists(mCallBack, mEventName & "_result",0) Then
		CallSub2(mCallBack, mEventName & "_result",res)
	End If
End Sub

#End Region

#Region Functions from the Forum

'Functions used from the Forum

'https://www.b4x.com/android/forum/threads/b4x-change-the-background-alpha-level.96257/#content
Private Sub MakeViewBackgroundTransparent(View As B4XView, Alpha As Int)
	Dim clr As Int = View.Color
	If clr = 0 Then
		Log("Cannot get background color.")
		Return
	End If
	View.Color = Bit.Or(Bit.And(0x00ffffff, clr), Bit.ShiftLeft(Alpha, 24))
End Sub

'https://www.b4x.com/android/forum/threads/b4x-xui-add-measuretextwidth-and-measuretextheight-to-b4xcanvas.91865/#post-580637
Private Sub MeasureTextHeight(Text As String, Font1 As B4XFont) As Int
#If B4A     
    Private bmp As Bitmap
    bmp.InitializeMutable(2dip, 2dip)
    Private cvs As Canvas
    cvs.Initialize2(bmp)
    Return cvs.MeasureStringHeight(Text, Font1.ToNativeFont, Font1.Size)
#Else If B4i
    Return Text.MeasureHeight(Font1.ToNativeFont)
#Else If B4J
	Dim jo As JavaObject
	jo.InitializeNewInstance("javafx.scene.text.Text", Array(Text))
	jo.RunMethod("setFont",Array(Font1.ToNativeFont))
	jo.RunMethod("setLineSpacing",Array(0.0))
	jo.RunMethod("setWrappingWidth",Array(0.0))
	Dim Bounds As JavaObject = jo.RunMethod("getLayoutBounds",Null)
	Return Bounds.RunMethod("getHeight",Null)
#End If
End Sub

Private Sub MeasureTextWidth(Text As String, Font1 As B4XFont) As Int
#If B4A
    Private bmp As Bitmap
    bmp.InitializeMutable(2dip, 2dip)
    Private cvs As Canvas
    cvs.Initialize2(bmp)
    Return cvs.MeasureStringWidth(Text, Font1.ToNativeFont, Font1.Size)
#Else If B4i
    Return Text.MeasureWidth(Font1.ToNativeFont)
#Else If B4J
	Dim jo As JavaObject
	jo.InitializeNewInstance("javafx.scene.text.Text", Array(Text))
	jo.RunMethod("setFont",Array(Font1.ToNativeFont))
	jo.RunMethod("setLineSpacing",Array(0.0))
	jo.RunMethod("setWrappingWidth",Array(0.0))
	Dim Bounds As JavaObject = jo.RunMethod("getLayoutBounds",Null)
	Return Bounds.RunMethod("getWidth",Null)
#End If
End Sub

'https://www.b4x.com/android/forum/threads/b4x-xui-create-a-round-image.85102/#content
Sub CreateRoundBitmap (Input As B4XBitmap, Size As Int) As B4XBitmap
	
	If Input.Width <> Input.Height Then
		'if the image is not square then we crop it to be a square.
		Dim l As Int = Min(Input.Width, Input.Height)
		Input = Input.Crop(Input.Width / 2 - l / 2, Input.Height / 2 - l / 2, l, l)
	End If
	Dim c As B4XCanvas
	Dim xview As B4XView = xui.CreatePanel("")
	xview.SetLayoutAnimated(0, 0, 0, Size, Size)
	c.Initialize(xview)
	Dim path As B4XPath
	path.InitializeOval(c.TargetRect)
	c.ClipPath(path)
	c.DrawBitmap(Input.Resize(Size, Size, False), c.TargetRect)
	c.RemoveClip
	
	If border_width > 0 Then
	c.DrawCircle(c.TargetRect.CenterX, c.TargetRect.CenterY, c.TargetRect.Width / 2 - 2dip, xui.Color_White, False, border_width) 'comment this line to remove the border
	End If
	c.Invalidate
	Dim res As B4XBitmap = c.CreateBitmap
	c.Release
	Return res
End Sub

#End Region




