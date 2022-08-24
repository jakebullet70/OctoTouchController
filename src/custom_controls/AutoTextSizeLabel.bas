B4A=true
Group=CUSTOM_CONTROLS
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
' Author:  B4X, sadLogic - Kherson, Ukraine
#Region VERSIONS 
' V. 1.2 	Aug/24/2022
'			Added tag to return me
' V. 1.1 	Aug/12/2022
'			Added TextColor properties
' V. 1.3 	Unknown
' https://www.b4x.com/android/forum/threads/slightly-modified-autotextsizelabel.138544/#content
#End Region
#IF B4A or B4I
#Event: Click
#Event: LongClick
#End If

#DesignerProperty: Key: maxSize, DisplayName: Max Text Size, FieldType: Int, DefaultValue: 20
#DesignerProperty: Key: minSize, DisplayName: Min Text Size, FieldType: Int, DefaultValue: 5
#DesignerProperty: Key: ignoreUserFontScale, DisplayName: Ignore User Font Scale, FieldType: Boolean, DefaultValue: True

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As B4XView 'ignore
	Private mlbl As B4XView
	Private xui As XUI
	Private mautopnl As B4XView
	Private maxSize As Int = 20
	Private minSize As Int = 5
	Private ac As Accessibility
	Private scaler As Float
	Public Tag As Object
End Sub


Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	mlbl = Lbl
	Tag = mBase.Tag
	mBase.Tag = Me

	mautopnl = xui.CreatePanel("")

	Dim parent As B4XView = mBase.Parent	
	parent.AddView(mlbl, mBase.Left, mBase.Top, mBase.Width, mBase.Height)
	parent.AddView(mautopnl,0,0,mBase.Width,mBase.Height)
	mBase.RemoveAllViews
	
	#If B4A 
	Base_Resize(mBase.width,mBase.height)
	#End If
	
	scaler = IIf(Props.Get("ignoreUserFontScale").As(Boolean), ac.GetUserFontScale, 1)
	maxSize = Props.Get("maxSize")/scaler
	minSize = Props.Get("minSize")/scaler
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
	mBase.Width = Width
	mBase.Height = Height
	mlbl.Width = Width
	mlbl.Height = Height
	mautopnl.Width = Width
	mautopnl.Height = Height
	
	setText(mlbl.Text)
End Sub

Public Sub setText(value As Object)
	'Sleep(0)
	mlbl.Text = value
	Dim multipleLines As Boolean = mlbl.Text.Contains(CRLF)
	Dim size As Float
	For size = minSize To maxSize
		If CheckSize(size, multipleLines) Then Exit
	Next
	size = size - 0.5
	If CheckSize(size, multipleLines) Then size = size - 0.5
	Sleep(0)
	mlbl.TextSize = size
	
'	If mlbl.TextSize <= 5 Then
'		mlbl.Text = $"${mlbl.Text.SubString2(0, Round(mlbl.Text.Length/2))}${CRLF}${mlbl.Text.SubString2(Round(mlbl.Text.Length/2), mlbl.Text.Length)}"$
'		Log(mlbl.Text)
'		RefreshView
'	End If
	
	'Log(size)
	'Log(mlbl.TextSize)
End Sub

#Region "PROPERTIES"
Public Sub getText As Object
	Return mlbl.Text
End Sub
Public Sub getBaseLabel As B4XView
	Return mlbl
End Sub

Public Sub setTextColor(clr As Int)
	mlbl.TextColor = clr
End Sub
Public Sub getTextColor() As Int
	Return mlbl.TextColor
End Sub
#end region


'Refresh the View
Public Sub RefreshView
	setText(mlbl.Text)
End Sub

'returns true if the size is too large
Private Sub CheckSize(size As Float, multipleLines As Boolean) As Boolean
	mlbl.TextSize = size
	If multipleLines Then
		#If B4A
		Dim su As StringUtils
		Return su.MeasureMultilineTextHeight(mlbl,mlbl.Text) > mlbl.Height
		
		#Else if B4I
		Dim tmplbl As Label = mlbl
		tmplbl.Multiline = True
		mlbl = tmplbl
		'Return MeasureTextHeight(mlbl.Text,mlbl.Font) > mlbl.Height
		Return getTextHeight(mlbl.Text,mlbl.Font,mlbl.Width) > mlbl.Height
		#Else B4J
		Return MeasureMultilineTextHeight(mlbl.Font,mlbl.Width,mlbl.Text)
		#End If
		
	Else
	
		#if b4A
		Dim stuti As StringUtils
		Return MeasureTextWidth(mlbl.Text,mlbl.Font) > mlbl.Width Or stuti.MeasureMultilineTextHeight(mlbl,mlbl.Text) > mlbl.Height 
		#Else
		Return MeasureTextWidth(mlbl.Text,mlbl.Font) > mlbl.Width Or MeasureTextHeight(mlbl.Text,mlbl.Font) > mlbl.Height 
		#End If
		
	End If
	
End Sub

#Region Click


Private Sub mautopnl_Click
	mautopnl_click_handler(Sender)
End Sub

Private Sub mautopnl_LongClick
	mautopnl_longclick_handler(Sender)
End Sub



private Sub mautopnl_click_handler(SenderPanel As B4XView)
	If xui.SubExists(mCallBack, mEventName & "_Click",0) Then
		CallSub(mCallBack, mEventName & "_Click")
	End If
End Sub

private Sub mautopnl_longclick_handler(SenderPanel As B4XView)
	If xui.SubExists(mCallBack, mEventName & "_LongClick",0) Then
		CallSub(mCallBack, mEventName & "_LongClick")
	End If
End Sub

#End Region

#Region Functions
'https://www.b4x.com/android/forum/threads/b4x-xui-add-measuretextwidth-and-measuretextheight-to-b4xcanvas.91865/#content
Private Sub MeasureTextWidth(Text As String, Font1 As B4XFont) As Int
	#If B4A
	Private bmp As Bitmap
	bmp.InitializeMutable(1, 1)'ignore
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

'https://www.b4x.com/android/forum/threads/b4x-xui-add-measuretextwidth-and-measuretextheight-to-b4xcanvas.91865/#content
Private Sub MeasureTextHeight(Text As String, Font1 As B4XFont) As Int'Ignore
	#If B4A     
	Private bmp As Bitmap
	bmp.InitializeMutable(1, 1)'ignore
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


#If B4I
'https://www.b4x.com/android/forum/threads/measuremultilinetextheight-in-ios.65556/#post-531390
Private Sub getTextHeight(Text As String,fo As Font,LbWidth As Float) As Float
  
	Dim tmpString As String = "大"
	Dim str() As String = Regex.Split(Chr(10),Text)
	Dim height As Float
	Dim number As Int
	Dim fontHeight As Float = tmpString.MeasureHeight(fo)
	For Each s As String In str
		number = s.MeasureWidth(fo)/LbWidth + 1
		height = height + number*fontHeight
	Next
	Return height + fontHeight
End Sub

#Else If B4J
'https://www.b4x.com/android/forum/threads/measure-multiline-text-height.84331/#content
Sub MeasureMultilineTextHeight (Font As Font, Width As Double, Text As String) As Double
   Dim jo As JavaObject = Me
   Return jo.RunMethod("MeasureMultilineTextHeight", Array(Font, Text, Width))
End Sub

#if Java
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import javafx.scene.text.Font;
import javafx.scene.text.TextBoundsType;
public static double MeasureMultilineTextHeight(Font f, String text, double width) throws Exception {
  Method m = Class.forName("com.sun.javafx.scene.control.skin.Utils").getDeclaredMethod("computeTextHeight",
  Font.class, String.class, double.class, TextBoundsType.class);
  m.setAccessible(true);
  return (Double)m.invoke(null, f, text, width, TextBoundsType.LOGICAL);
  }
#End If

#End if

#End Region