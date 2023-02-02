B4J=true
Group=B4X_CUSTOM_CLASSES
ModulesStructureVersion=1
Type=Class
Version=6.01
@EndOfDesignText@
' Author:  B4X, sadLogic
#Region VERSIONS 
' V. 1.0	Nov/05/2022	Copied from original, changed the base size to fit
'									the spinner control that is added in the calling
'									parent dlgThemeSelect class, See 'tweaked'
' V1.0 	No Idea, from b4x 11.8
#End Region
Sub Class_Globals
	Public mBase As B4XView 'ignore
	Private xui As XUI 'ignore
	Private SelectedAlpha As Int = 255
	Private bcColors As BitmapCreator
	Private selectedH = 60, selectedS = 0.5, selectedV = 0.5 As Float
	Private DeviceScale, ColorScale As Float
	Private tempBC As BitmapCreator
	Private const DONT_CHANGE As Int = -999999999
	'--- Tweaked - renamed
	Type ColorPickerPart1 (cvs As B4XCanvas, pnl As B4XView, iv As B4XView, checkersCanvas As B4XCanvas, DrawCheckers As Boolean)
	'---
	Private HueBar, ColorPicker, AlphaBar As ColorPickerPart1
	Private BordersColor As Int
	Private xDialog As B4XDialog
	Private InitialColor() As Object
End Sub

Public Sub Initialize
	tempBC.Initialize(1, 1)
	DeviceScale = 100dip / 100
	mBase = xui.CreatePanel("")
	'--- Tweaked - larger size
	Dim w As Float
	If guiHelpers.gIsLandScape Then
		w = 390dip
	Else
		w = guiHelpers.gWidth * .96
	End If
	mBase.SetLayoutAnimated(0, 0, 0, w,300dip)
	'mBase.SetLayoutAnimated(0, 0, 0, 300dip, 250dip)
	'---
	BordersColor = xui.Color_Black
	mBase.SetColorAndBorder(BordersColor, 1dip, BordersColor, 2dip)
	HueBar = CreatePanelForBitmapCreator("hueBar", False)
	ColorPicker = CreatePanelForBitmapCreator("colors", True)
	AlphaBar = CreatePanelForBitmapCreator("alpha", True)
	Base_Resize(mBase.Width, mBase.Height)
End Sub

Private Sub CreatePanelForBitmapCreator (EventName As String, WithCheckers As Boolean) As ColorPickerPart1
	Dim cpp As ColorPickerPart1
	cpp.Initialize
	cpp.pnl = xui.CreatePanel("")
	cpp.pnl.SetColorAndBorder(BordersColor, 1dip, BordersColor, 0)
	cpp.pnl.SetLayoutAnimated(0, 1dip, 1dip, 1dip, 1dip)
	If WithCheckers Then
		cpp.checkersCanvas.Initialize(cpp.pnl)
		cpp.DrawCheckers = True
	End If
	Dim iv As ImageView
	iv.Initialize("")
	cpp.iv = iv
	Dim overlay As B4XView = xui.CreatePanel(EventName)
	cpp.pnl.AddView(iv, 0, 0, 0, 0)
	cpp.pnl.AddView(overlay, 1dip, 1dip, 1dip, 1dip)
	cpp.cvs.Initialize(overlay)
	mBase.AddView(cpp.pnl, 0, 0, 0, 0)
	Return cpp
End Sub




Private Sub Base_Resize (Width As Double, Height As Double)
	'color scale is used to decrease the surface size and improve the performance
	ColorScale = Max(1, Max(Width, Height) / 100 / DeviceScale)
	HueBar.pnl.SetLayoutAnimated(0, 1dip, 1dip, 30dip, Height - 2dip)
	Dim r As Int = HueBar.pnl.Width + HueBar.pnl.Left + 1dip
	Dim w As Int = Width - r - 1dip
	If xui.IsB4i Then
		r = r - 1
		w = w + 1
	End If
	AlphaBar.pnl.SetLayoutAnimated(0, r, Height - 31dip,w, 30dip)
	ColorPicker.pnl.SetLayoutAnimated(0, r, 1dip, w, Height - 3dip - AlphaBar.pnl.Height)
	bcColors.Initialize(ColorPicker.pnl.Width / ColorScale, ColorPicker.pnl.Height / ColorScale)
	For Each cpp As ColorPickerPart1 In Array(HueBar, ColorPicker, AlphaBar)
		For i = 0 To cpp.pnl.NumberOfViews - 1
			cpp.pnl.GetView(i).SetLayoutAnimated(0, 0, 0, cpp.pnl.Width, cpp.pnl.Height)
		Next
		cpp.cvs.Resize(cpp.pnl.Width, cpp.pnl.Height)
		If cpp.DrawCheckers Then
			DrawCheckers(cpp)
		End If
	Next
	DrawHueBar
	DrawAlphaBar
	HueBarSelectedChanged (selectedH / 360 * HueBar.pnl.Height)
	AlphaBarSelectedChange (SelectedAlpha / 255 * AlphaBar.pnl.Width)
End Sub

Private Sub DrawCheckers (cpp As ColorPickerPart1)
	cpp.checkersCanvas.Resize(cpp.pnl.Width, cpp.pnl.Height)
	cpp.checkersCanvas.ClearRect(cpp.checkersCanvas.TargetRect)
	Dim size As Int = 10dip
	Dim clrs() As Int = Array As Int(0xFFC0C0C0, 0xFF757575)
	Dim clr As Int = 0
	Dim r As B4XRect
	For x = 0 To cpp.checkersCanvas.TargetRect.Right - 1dip Step size
		Dim xx As Int = x / size
		clr = xx Mod 2
		For y = 0 To cpp.checkersCanvas.TargetRect.Bottom - 1dip Step size
			clr = (clr + 1) Mod 2
			r.Initialize(x, y, x + size, y + size)
			cpp.checkersCanvas.DrawRect(r, clrs(clr), True, 0)
		Next
	Next
	cpp.checkersCanvas.Invalidate
End Sub

Private Sub DrawHueBar
	Dim bcHue As BitmapCreator
	bcHue.Initialize(HueBar.pnl.Width / DeviceScale, HueBar.pnl.Height / DeviceScale)
	For y = 0 To bcHue.mHeight - 1
		For x = 0 To bcHue.mWidth - 1
			bcHue.SetHSV(x, y, 255, 360 / bcHue.mHeight * y, 1, 1)
		Next
	Next
	HueBar.iv.SetBitmap(bcHue.Bitmap)
End Sub

Private Sub DrawAlphaBar
	Dim bc As BitmapCreator
	bc.Initialize(AlphaBar.pnl.Width / DeviceScale, AlphaBar.pnl.Height / DeviceScale)
	Dim argb As ARGBColor
	argb.r = 0xcc
	argb.g = 0xcc
	argb.b = 0xcc
	
	For y = 0 To bc.mHeight - 1
		For x = 0 To bc.mWidth - 1
			argb.a = x / bc.mWidth * 255
			bc.SetARGB(x, y, argb)
		Next
	Next
	AlphaBar.iv.SetBitmap(bc.Bitmap)
End Sub

Private Sub DrawColors
	For x = 0 To bcColors.mWidth - 1
		For y = 0 To bcColors.mHeight - 1
			bcColors.SetHSV(x, y, SelectedAlpha, selectedH, x / bcColors.mWidth, (bcColors.mHeight - y) / bcColors.mHeight)
		Next
	Next
	ColorPicker.iv.SetBitmap(bcColors.Bitmap.Resize(ColorPicker.iv.Width, ColorPicker.iv.Height, False))
End Sub

Private Sub HueBarSelectedChanged (y As Float)
	selectedH = Max(0, Min(360, 360 * y / HueBar.pnl.Height))
	y = selectedH * HueBar.pnl.Height / 360
	HueBar.cvs.ClearRect(HueBar.cvs.TargetRect)
	Dim r As B4XRect
	r.Initialize(0, y - 3dip, HueBar.cvs.TargetRect.Right, y + 3dip)
	HueBar.cvs.DrawRect(r, xui.Color_White, False, 2dip)
	HueBar.cvs.Invalidate
	Update
End Sub

Private Sub AlphaBarSelectedChange(x As Float)
	SelectedAlpha = 255 * Max(0, Min(1, x / AlphaBar.pnl.Width))
	x = SelectedAlpha / 255 * AlphaBar.pnl.Width
	AlphaBar.cvs.ClearRect(AlphaBar.cvs.TargetRect)
	Dim r As B4XRect
	r.Initialize(x - 3dip, 1dip, x + 3dip, AlphaBar.cvs.TargetRect.Bottom - 1dip)
	AlphaBar.cvs.DrawRect(r, xui.Color_Black, True, 2dip)
	AlphaBar.cvs.Invalidate
	Update
End Sub

Private Sub Update
	DrawColors
	HandleSelectedColorChanged(DONT_CHANGE, DONT_CHANGE)
End Sub

Private Sub HandleSelectedColorChanged (x As Int, y As Int)
	If x <> DONT_CHANGE Then
		selectedS = Max(0, Min(1, x / ColorPicker.pnl.Width))
		selectedV = Max(0, Min(1, (ColorPicker.pnl.Height - y) / ColorPicker.pnl.Height))
	End If
	ColorPicker.cvs.ClearRect(ColorPicker.cvs.TargetRect)
	ColorPicker.cvs.DrawCircle(selectedS * ColorPicker.pnl.Width, ColorPicker.pnl.Height - selectedV * ColorPicker.pnl.Height, _
		 10dip, xui.Color_White, False, 2dip)
	ColorPicker.cvs.Invalidate
	UpdateBarColor
End Sub

Public Sub getSelectedColor As Int
	Dim hsv() As Object = getSelectedHSVColor
	tempBC.SetHSV(0, 0, SelectedAlpha, hsv(0), hsv(1), hsv(2))
	Return tempBC.GetColor(0, 0)
End Sub

Public Sub setSelectedColor(i As Int)
	setSelectedHSVColor(ColorToHSV(i))
End Sub

'Gets or sets the selected color. The value is an array with: H, S, V and Alpha.
Public Sub getSelectedHSVColor As Object()
	Return Array (selectedH, selectedS, selectedV, SelectedAlpha)
End Sub

Public Sub setSelectedHSVColor (HSV() As Object)
	selectedH = HSV(0)
	selectedS = HSV(1)
	selectedV = HSV(2)
	SelectedAlpha = HSV(3)
	HueBarSelectedChanged(selectedH / 360 * HueBar.pnl.Height)
	AlphaBarSelectedChange(SelectedAlpha / 255 * AlphaBar.pnl.Width)
End Sub

Public Sub ColorToHSV(clr As Int) As Object()
	Dim a As Int = Bit.And(0xff, Bit.UnsignedShiftRight(clr, 24))
	Dim r As Int = Bit.And(0xff, Bit.UnsignedShiftRight(clr, 16)) 
	Dim g As Int = Bit.And(0xff, Bit.UnsignedShiftRight(clr, 8))
	Dim b As Int = Bit.And(0xff, Bit.UnsignedShiftRight(clr, 0)) 
	Dim h, s, v As Float
	Dim cmax As Int = Max(Max(r, g), b)
	Dim cmin As Int = Min(Min(r, g), b)
	v = cmax / 255
	If cmax <> 0 Then
		s = (cmax - cmin) / cmax
	End If
	If s = 0 Then
		h = 0
	Else
		Dim rc As Float = (cmax - r) / (cmax - cmin)
		Dim gc As Float = (cmax - g) / (cmax - cmin)
		Dim bc As Float = (cmax - b) / (cmax - cmin)
		If r = cmax Then
			h = bc - gc
		Else If g = cmax Then
			h = 2 + rc - bc
		Else
			h = 4 + gc - rc
		End If
		h = h / 6
		If h < 0 Then h = h + 1
	End If
	Return Array (h * 360, s, v, a)		
End Sub

Public Sub GetPanel (Dialog As B4XDialog) As B4XView
	Return mBase
End Sub

Private Sub Show (Dialog As B4XDialog)
	InitialColor = getSelectedHSVColor
	xDialog = Dialog
	Sleep(0)
	UpdateBarColor
End Sub

Private Sub DialogClosed(Result As Int)
	If Result <> xui.DialogResponse_Positive Then
		setSelectedHSVColor(InitialColor)	
	End If
End Sub

Private Sub UpdateBarColor
	If xDialog.IsInitialized And xDialog.TitleBar.IsInitialized Then
		xDialog.TitleBar.Color = getSelectedColor
	End If
End Sub

Private Sub Colors_Touch (Action As Int, X As Float, Y As Float)
	If Action = mBase.TOUCH_ACTION_MOVE_NOTOUCH Then Return
	HandleSelectedColorChanged(X, Y)
End Sub

Private Sub HueBar_Touch (Action As Int, X As Float, Y As Float)
	If Action = mBase.TOUCH_ACTION_MOVE_NOTOUCH Then Return
	HueBarSelectedChanged(Y)
End Sub

Private Sub Alpha_Touch (Action As Int, X As Float, Y As Float)
	If Action = mBase.TOUCH_ACTION_MOVE_NOTOUCH Then Return
	AlphaBarSelectedChange(x)
End Sub
