B4A=true
Group=CUSTOM_CONTROLS
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
#Region VERSIONS 
'	2.2.0		08/26/2002 - sadLogic, Kherson Ukraine
'				Added click event
'	2.1.1		08/13/2002 - sadLogic, Kherson Ukraine
'				Added Color Full / Empty properties, code cleanup
'				Added getMainLabel to allow changing of text property
'	2.1.0		10/22/2017 - DV
'				fixed radius, label position and dimension, Added visible property
'				Added ValueUnit property to set a text after the value (i.e. %, ms)		
'				Added a reset method to immediately clear the circular progressbar
'	2.0.0		06/17/2017
'				Original Version: 2.00 by Erel
#End Region

#DesignerProperty: Key: ColorFull, DisplayName: Color Full, FieldType: Color, DefaultValue: 0xFF06F96B, Description:
#DesignerProperty: Key: ColorEmpty, DisplayName: Color Empty, FieldType: Color, DefaultValue: 0xFF868686, Description:
#DesignerProperty: Key: StrokeWidth, DisplayName: Stroke Width, FieldType: Int, DefaultValue: 10, Description:
#DesignerProperty: Key: Duration, DisplayName: Duration From 0 To 100, FieldType: Int, DefaultValue: 3000, Description: Milliseconds

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private cvs As B4XCanvas
	Private xui As XUI
	Private mLbl As B4XView
	Private cx, cy, radius As Float
	Private stroke As Float
	Private clrFull, clrEmpty As Int
	Private mBase As B4XView
	Private currentValue As Float = 0
	Private DurationFromZeroTo100 As Int
	Private mUnit As String = ""
End Sub

#Region "PROPERTIES"
public Sub setVisible(Visible As Boolean)
	mBase.Visible=Visible
End Sub
public Sub getVisible As Boolean
	Return mBase.Visible
End Sub
public Sub setValueUnit (Unit As String)
	mUnit = Unit 	'--- Set the value measure unit as string (use short names like %, mV, A)
	DrawValue(currentValue)
End Sub
Public Sub getMainLabel() As B4XView
	Return mLbl
End Sub
Public Sub setColorFull(clr As Int)
	clrFull = clr
End Sub
Public Sub getColorFull() As Int
	Return clrFull
End Sub
Public Sub setColorEmpty(clr As Int)
	clrEmpty = clr
End Sub
Public Sub getColorEmpty() As Int
	Return clrEmpty
End Sub
Public Sub setValue(NewValue As Float)
	AnimateValueTo(NewValue)
End Sub
Public Sub getValue As Float
	Return currentValue
End Sub
#end region


Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	mBase.SetLayoutAnimated(0, mBase.Left, mBase.Top,  Min(mBase.Width, mBase.Height), Min(mBase.Width, mBase.Height))
	clrFull = xui.PaintOrColorToColor(Props.Get("ColorFull"))
	clrEmpty = xui.PaintOrColorToColor(Props.Get("ColorEmpty"))
	stroke = DipToCurrent(Props.Get("StrokeWidth"))
	DurationFromZeroTo100 = Props.Get("Duration")
	Lbl.Initialize("lbl")
	mLbl = Lbl
	cx = mBase.Width / 2
	cy = mBase.Height / 2
	
	'--- 2017/10/22 radius is based on stroke width
	radius = cx-stroke / 2
	cvs.Initialize(mBase)
	mLbl.SetTextAlignment("CENTER", "CENTER")
	
	'--- 2017/10/22 center text
	mBase.AddView(mLbl, stroke, stroke, mBase.Width-2 * stroke,mBase.Height-2 * stroke)
	
	cvs.Initialize(mBase)
	DrawValue(currentValue)
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
	cx = Width / 2
	cy = Height / 2
	radius = cx - 10dip
	mBase.SetLayoutAnimated(0, mBase.Left, mBase.Top,  Min(Width,Height), Min(Width, Height))
	cvs.Resize(Width, Height)
	mLbl.SetLayoutAnimated(0, 0, cy - 20dip, Width, 40dip)
	DrawValue(currentValue)
End Sub


public Sub Reset
	'--- reset the circular progressbar
	currentValue = 0
	DrawValue(currentValue)
End Sub

Private Sub AnimateValueTo(NewValue As Float)
	Dim n As Long = DateTime.Now
	Dim duration As Int = Abs(currentValue - NewValue) / 100 * DurationFromZeroTo100 + 1000
	Dim start As Float = currentValue
	currentValue = NewValue
	Dim tempValue As Float
	Do While DateTime.Now < n + duration
		tempValue = ValueFromTimeEaseInOut(DateTime.Now - n, start, NewValue - start, duration)
		DrawValue(tempValue)
		Sleep(10)
		If NewValue <> currentValue Then Return 'will happen if another update has started
	Loop
	DrawValue(currentValue)
End Sub

'quartic easing in/out from http://gizma.com/easing/
Private Sub ValueFromTimeEaseInOut(Time As Float, Start As Float, ChangeInValue As Float, Duration As Int) As Float
	Time = Time / (Duration / 2)
	If Time < 1 Then
		Return ChangeInValue / 2 * Time * Time * Time * Time + Start
	Else
		Time = Time - 2
		Return -ChangeInValue / 2 * (Time * Time * Time * Time - 2) + Start
	End If
End Sub


Private Sub DrawValue(Value As Float)
		
	cvs.ClearRect(cvs.TargetRect)
	cvs.DrawCircle(cx, cy, radius, clrEmpty, False, stroke)
	mLbl.Text = $"$1.0{Value}"$ & mUnit
	Dim startAngle = -90, sweepAngle = Value / 100 * 360 As Float

	If Value < 100 Then
		Dim p As B4XPath
		p.InitializeArc(cx, cy, radius + stroke + 1dip, startAngle, sweepAngle)
		cvs.ClipPath(p)
		cvs.DrawCircle(cx, cy, radius - 0.5dip, clrFull, False, stroke + 1dip)
		cvs.RemoveClip
	Else
		cvs.DrawCircle(cx, cy, radius - 0.5dip, clrFull, False, stroke + 1dip)
	End If
	cvs.Invalidate
	
End Sub

Private Sub lbl_Click
	Dim SubFullName As String = mEventName & "_Click"
	If SubExists(mCallBack, SubFullName) Then
		CallSub(mCallBack, SubFullName)
	End If
End Sub
