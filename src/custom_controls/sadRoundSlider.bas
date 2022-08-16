B4J=true
Group=CUSTOM_CONTROLS
ModulesStructureVersion=1
Type=Class
Version=6.47
@EndOfDesignText@
#Region VERSIONS 
'	1.0.0		Aug/16/2022 - sadLogic
'				My version based on Erel's version from XUI Views v2.55
'				Changed ValueColor to Public
#End Region

#Region DESIGNER PROPERTIES 
#DesignerProperty: Key: ValueColor, DisplayName: Value Color, FieldType: Color, DefaultValue: 0xFF0061FF
#DesignerProperty: Key: Min, DisplayName: Minimum, FieldType: Int, DefaultValue: 0
#DesignerProperty: Key: Max, DisplayName: Maximum, FieldType: Int, DefaultValue: 100
#DesignerProperty: Key: RollOver, DisplayName: Roll Over, FieldType: Boolean, DefaultValue: False, Description: If checked then it is possible to drag from the max value to the min value. 
#Event: ValueChanged (Value As Int)
#end region


Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView 'ignore
	Private xui As XUI 'ignore
	Private cvs As B4XCanvas
	Private mValue As Int = 75
	Private mMin, mMax As Int
	Private thumb As B4XBitmap
	Private pnl As B4XView
	Public xlbl As B4XView
	Private CircleRect As B4XRect
	Public ValueColor As Int
	Private stroke As Int
	Private ThumbSize As Int
	Public Tag As Object
	Private mThumbBorderColor As Int = 0xFF5B5B5B
	Private mThumbInnerColor As Int = xui.Color_White
	Private mCircleFillColor As Int = xui.Color_White
	Private mCircleNonValueColor As Int = 0xFFB6B6B6
	Private mRollOver As Boolean
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	Tag = mBase.Tag : mBase.Tag = Me
	cvs.Initialize(mBase)
	mMin = Props.Get("Min")
	mMax = Props.Get("Max")
	mValue = mMin
	pnl = xui.CreatePanel("pnl")
	xlbl = Lbl
	xlbl.Visible = True
	mBase.AddView(xlbl, 0, 0, 0, 0)
	mBase.AddView(pnl, 0, 0, 0, 0)
	ValueColor = xui.PaintOrColorToColor(Props.Get("ValueColor"))
	mRollOver = Props.GetDefault("RollOver", False)
	If xui.IsB4A Or xui.IsB4i Then
		stroke = 8dip
	Else If xui.IsB4J Then
		stroke = 6dip
	End If
	Base_Resize(mBase.Width, mBase.Height)
End Sub

Public Sub SetThumbColor(BorderColor As Int, InnerColor As Int)
	mThumbBorderColor = BorderColor
	mThumbInnerColor = InnerColor
	CreateThumb
	Draw
End Sub

Public Sub SetCircleColor (NonValueColor As Int, InnerColor As Int)
	mCircleNonValueColor = NonValueColor
	mCircleFillColor = InnerColor
	Draw
End Sub

Private Sub CreateThumb
	Dim p As BCPath
	Dim r As Int = 80dip
	Dim g As Int = 8dip
	Dim l As Int = 28dip
	Dim bc As BitmapCreator
	bc.Initialize(2 * r + g + 3dip, 2 * r + l + g)
	p.Initialize(r - l + g, 2 * r - 2dip + g)
	p.LineTo(r + l + g, 2 * r - 2dip + g)
	p.LineTo(r + g, 2 * r + l + g)
	p.LineTo(r - l + g, 2 * r - 2dip + g)
	bc.DrawPath(p, mThumbBorderColor, True, 0)
	bc.DrawCircle(r + g, r + g, r, mThumbInnerColor, True, 0)
	bc.DrawCircle(r + g, r + g, r, mThumbBorderColor, False, 10dip)
	thumb = bc.Bitmap
	ThumbSize = thumb.Height / 4
	xlbl.SetTextAlignment("CENTER", "CENTER")
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
	cvs.Resize(Width, Height)
	pnl.SetLayoutAnimated(0, 0, 0, Width, Height)
	If thumb.IsInitialized = False Then CreateThumb
	CircleRect.Initialize(ThumbSize + stroke, ThumbSize + stroke, Width - ThumbSize - stroke, Height - ThumbSize - stroke)
	xlbl.SetLayoutAnimated(0, CircleRect.Left, CircleRect.Top, CircleRect.Width, CircleRect.Height)
	Draw
End Sub

Public Sub Draw
	cvs.ClearRect(cvs.TargetRect)
	Dim radius As Int = CircleRect.Width / 2
	cvs.DrawCircle(CircleRect.CenterX, CircleRect.CenterY, radius, mCircleNonValueColor , False, stroke)
	Dim p As B4XPath
	Dim angle As Int = (mValue - mMin) / (mMax - mMin) * 360
	Dim B4JStrokeOffset As Int
	If xui.IsB4J Then B4JStrokeOffset = stroke / 2
	If mValue = mMax Then
		cvs.DrawCircle(CircleRect.CenterX, CircleRect.CenterY, radius, ValueColor , False, stroke)
	Else
		p.InitializeArc(CircleRect.CenterX, CircleRect.CenterY, radius + B4JStrokeOffset, -90, angle)
		cvs.DrawPath(p, ValueColor, False, stroke)
	End If
	cvs.DrawCircle(CircleRect.CenterX, CircleRect.CenterY, radius - B4JStrokeOffset, mCircleFillColor, True, 0)
	Dim dest As B4XRect
	Dim r As Int = radius + ThumbSize / 2 + stroke / 2
	Dim cx As Int = CircleRect.CenterX + r * CosD(angle-90)
	Dim cy As Int = CircleRect.CenterY + r * SinD(angle-90)
	dest.Initialize(cx - thumb.Width / 8, cy - ThumbSize / 2, cx + thumb.Width / 8, cy + ThumbSize / 2)
	cvs.DrawBitmapRotated(thumb, dest, angle)
	cvs.Invalidate
	xlbl.Text = mValue
End Sub

Private Sub pnl_Touch (Action As Int, X As Float, Y As Float)
	If Action = pnl.TOUCH_ACTION_MOVE_NOTOUCH Then Return
	Dim dx As Int = x - CircleRect.CenterX
	Dim dy As Int = y - CircleRect.CenterY
	Dim dist As Float = Sqrt(Power(dx, 2) + Power(dy, 2))
	If dist > CircleRect.Width / 2 Then
		Dim angle As Int = Round(ATan2D(dy, dx))
		angle = angle + 90
		angle = (angle + 360) Mod 360
		Dim NewValue As Int = mMin + angle / 360 * (mMax - mMin)
		NewValue = Max(mMin, Min(mMax, NewValue))
		If NewValue <> mValue Then
			If mRollOver = False Then
				If Abs(NewValue - mValue) > (mMax - mMin) / 2 Then
					If mValue >= (mMax + mMin) / 2 Then
						mValue = mMax
					Else
						mValue = mMin
					End If
				Else
					mValue = NewValue
				End If
			Else
				mValue = NewValue
			End If
			If xui.SubExists(mCallBack, mEventName & "_ValueChanged", 1) Then
				CallSub2(mCallBack, mEventName & "_ValueChanged", mValue)
			End If
		End If
		Draw
	End If
End Sub

#if B4J
Private Sub pnl_MousePressed (EventData As MouseEvent)
	EventData.Consume
End Sub

Private Sub pnl_MouseClicked(EventData As MouseEvent)
	EventData.Consume
End Sub

Private Sub pnl_MouseReleased(EventData As MouseEvent)
	EventData.Consume
End Sub
#End If

Public Sub setValue (v As Int)
	mValue = Max(mMin, Min(mMax, v))
	Draw
End Sub

Public Sub getValue As Int
	Return mValue
End Sub