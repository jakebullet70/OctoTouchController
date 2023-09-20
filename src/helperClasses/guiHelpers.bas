B4J=true
Group=HELPERS
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/02/2022
#End Region
'Static code module
Sub Process_Globals
	Private xui As XUI
	Private Const mModule As String = "guiHelpers" 'ignore
	
	Public gScreenSizeAprox As Double = 7 '--- asume a small tablet
	Public gScreenSizeDPI As Int = 0
	Public gIsLandScape As Boolean 
	Public gFscale As Float
	Public gWidth As Float
	Public gHeight As Float
	
	
End Sub



'=====================================================================================
'  Generic GUI helper methods
'=====================================================================================

'Public Sub FontAwesomeToBitmap(Text As String, FontSize As Float) As B4XBitmap
'	Dim xui As XUI
'	Dim p As Panel = xui.CreatePanel("")
'	p.SetLayoutAnimated(0, 0, 0, 32dip, 32dip)
'	Dim cvs1 As B4XCanvas
'	cvs1.Initialize(p)
'	Dim fnt As B4XFont = xui.CreateFontAwesome(FontSize)
'	Dim r As B4XRect = cvs1.MeasureText(Text, fnt)
'	Dim BaseLine As Int = cvs1.TargetRect.CenterY - r.Height / 2 - r.Top
'	cvs1.DrawText(Text, cvs1.TargetRect.CenterX, BaseLine, fnt, xui.Color_White, "CENTER")
'	Dim b As B4XBitmap = cvs1.CreateBitmap
'	cvs1.Release
'	Return b
'End Sub



'---  change color of bitmap
'--- https://www.b4x.com/android/forum/threads/b4x-bitmapcreator-change-color-of-bitmap.95518/#post-603416
Public Sub ChangeColorBasedOnAlphaLevel(bmp As B4XBitmap, NewColor As Int) As B4XBitmap
	Dim bc As BitmapCreator
	bc.Initialize(bmp.Width, bmp.Height)
	bc.CopyPixelsFromBitmap(bmp)
	Dim a1, a2 As ARGBColor
	bc.ColorToARGB(NewColor, a1)
	For y = 0 To bc.mHeight - 1
		For x = 0 To bc.mWidth - 1
			bc.GetARGB(x, y, a2)
			If a2.a > 0 Then
				a2.r = a1.r
				a2.g = a1.g
				a2.b = a1.b
				bc.SetARGB(x, y, a2)
			End If
		Next
	Next
	Return bc.Bitmap
End Sub

Public Sub SetVisible(btnArr() As B4XView,Visible As Boolean)
	For Each v As B4XView In btnArr
		v.Visible = Visible
	Next
End Sub
'Public Sub SetVisible2(btnArr() As Button,Visible As Boolean)
'	For Each v As B4XView In btnArr
'		v.Visible = Visible
'	Next
'End Sub

'--- just an easy wat to Toast!!!!
Public Sub Show_toast(msg As String, ms As Int)
	CallSub3(B4XPages.MainPage,"Show_Toast", msg, ms)
End Sub
Public Sub Show_toast2(msg As String, ms As Int)
	CallSubDelayed3(B4XPages.MainPage,"Show_Toast", msg, ms)
End Sub

public Sub HidePageParentObjs(obj() As B4XView)
	For Each o As B4XView In obj
		o.Visible = False
		o.Color = xui.Color_Transparent
	Next
End Sub


Public Sub ReSkinB4XComboBox(cbo() As B4XComboBox)
	
	For Each cb As B4XComboBox In cbo
		Try
			
			cb.cmbBox.TextColor = clrTheme.txtNormal
			cb.cmbBox.Color = clrTheme.BackgroundHeader
			cb.cmbBox.DropdownBackgroundColor = clrTheme.BackgroundHeader
			cb.cmbBox.DropdownTextColor = clrTheme.txtNormal
		Catch
			Log(LastException)
		End Try
	Next
End Sub


Public Sub SetTextColorB4XFloatTextField(views() As B4XFloatTextField)
	
	For Each o As B4XFloatTextField In views
		o.TextField.TextColor = clrTheme.txtNormal
		o.NonFocusedHintColor = clrTheme.txtAccent
		o.HintColor = clrTheme.txtAccent
		o.Update
	Next
	
End Sub


Public Sub SetTextColor(obj() As B4XView)
	For Each o As B4XView In obj
		o.TextColor = clrTheme.txtNormal
	Next
End Sub
Public Sub SetTextColor2(obj() As B4XView)
	For Each o As B4XView In obj
		o.TextColor = clrTheme.txtAccent
	Next
End Sub

Public Sub SetTextSize(obj() As Button,size As Float)
	For Each o As Button In obj
		o.TextSize = size
	Next
End Sub

'========================================================================
Public Sub SkinButton_Pugin(obj() As Button)
	Dim clrNormal ,clrPressed As Int
	clrNormal = clrTheme.txtNormal
	clrPressed = ChangeColorVisible(clrTheme.txtNormal)
	For Each b As Button In obj
		SetColorTextStateList(b,clrPressed,clrNormal,clrTheme.btnDisableText)
		
		Dim DefaultDrawable, PressedDrawable As ColorDrawable
		DefaultDrawable.Initialize(xui.Color_Transparent,8dip)
		PressedDrawable.Initialize2(clrPressed,8dip,2dip,clrNormal)
		Dim sld1 As StateListDrawable :sld1.Initialize
		sld1.AddState(sld1.State_Pressed, PressedDrawable)
		sld1.AddCatchAllState(DefaultDrawable)
		b.Background = sld1
	Next
End Sub
Public Sub SkinButton(obj() As Button)
	'--- sets the bg and frame color
	Dim clrAccent, clrNormal ,clrPressed As Int
	clrNormal = clrTheme.txtNormal
	clrAccent = clrTheme.txtAccent
	
	clrPressed = ChangeColorVisible(clrTheme.txtNormal)
	For Each btn As Button In obj
		SetColorTextStateList(btn,clrPressed,clrNormal,clrTheme.btnDisableText)
		
		Dim DefaultDrawable, PressedDrawable,DisabledDrawable As ColorDrawable
		DefaultDrawable.Initialize2(xui.Color_Transparent, 8dip,2dip,clrAccent)
		PressedDrawable.Initialize2(clrPressed,8dip,2dip,clrNormal)
		DisabledDrawable.Initialize2(xui.Color_Transparent,8dip,2dip,clrTheme.btnDisableText)
		
		Dim sld1 As StateListDrawable : sld1.Initialize
		sld1.AddState(sld1.State_Pressed, PressedDrawable)
		sld1.AddState(sld1.State_Disabled, DisabledDrawable)
		sld1.AddCatchAllState(DefaultDrawable)
		btn.Background = sld1
	Next
End Sub

Private Sub SetColorTextStateList(Btn As Button,Pressed As Int,Enabled As Int,Disabled As Int)
	'--- sets the text color
	Dim States(3,1) As Int
	States(0,0) = 16842919    'Pressed
	States(1,0) = 16842910    'Enabled
	States(2,0) = -16842910 'Disabled

	Dim Color(3) As Int = Array As Int(Pressed,Enabled,Disabled)

	Dim CSL As JavaObject
	CSL.InitializeNewInstance("android.content.res.ColorStateList",Array As Object(States,Color))
	Dim B1 As JavaObject = Btn
	B1.RunMethod("setTextColor",Array As Object(CSL))
End Sub
Private Sub ChangeColorVisible(clr As Int) As Int
	Dim argb() As Int = clrTheme.Int2ARGB(clr)
	Return xui.Color_ARGB(90,argb(1),argb(2),argb(3))
End Sub
'========================================================================


Public Sub SetEnableDisableColor(btnArr() As B4XView)
	For Each btn As B4XView In btnArr
		If btn.enabled Then
			btn.TextColor = clrTheme.txtNormal
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		Else
			btn.TextColor = clrTheme.btnDisableText
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.btnDisableText,8dip)
		End If
	Next
End Sub

Public Sub EnableDisableViews(btnArr() As B4XView,EnableDisable As Boolean)
	For Each btn As B4XView In btnArr
		btn.enabled = EnableDisable
	Next
	SetEnableDisableColor(btnArr)
End Sub

Public Sub EnableDisableBtns2(btnArr() As Button,EnableDisable As Boolean)
	For Each btn As Button In btnArr
		btn.enabled = EnableDisable
	Next
End Sub

'Change the size and color of a Checkbox graphic. Set the tick character and color, as well as the box size and color
'and padding (distance from the box to the edge of the graphic) and a disabled fill color
'Pass "Fill" as the TickChar to fill the box with TickColor when selected.
Public Sub SetCBDrawable(CB As CheckBox,BoxColor As Int,BoxWidth As Int, _
			TickColor As Int,TickChar As String,DisabledColor As Int,Size As Int,Padding As Int)
			
	Dim SLD As StateListDrawable
	SLD.Initialize

	Dim BMEnabled,BMChecked,BMDisabled As Bitmap
	BMEnabled.InitializeMutable(Size,Size)
	BMChecked.InitializeMutable(Size,Size)
	BMDisabled.InitializeMutable(Size,Size)
	'Draw Enabled State
	Dim CNV As Canvas
	CNV.Initialize2(BMEnabled)
	Dim Rect1 As Rect
	Rect1.Initialize(Padding ,Padding ,Size - Padding ,Size - Padding)
	CNV.DrawRect(Rect1,BoxColor,False,BoxWidth)
	Dim Enabled,Checked,Disabled As BitmapDrawable
	Enabled.Initialize(BMEnabled)
	'Draw Selected state
	Dim CNV1 As Canvas
	CNV1.Initialize2(BMChecked)
	If TickChar = "Fill" Then
		CNV1.DrawRect(Rect1,TickColor,True,BoxWidth)
		CNV1.DrawRect(Rect1,BoxColor,False,BoxWidth)
	Else
		CNV1.DrawRect(Rect1,BoxColor,False,BoxWidth)
		'Start small and find the largest font that allows the tick to fit in the box
		Dim FontSize As Int = 6
		Do While CNV.MeasureStringHeight(TickChar,Typeface.DEFAULT,FontSize) < Size - (BoxWidth * 2) - (Padding * 2)
			FontSize = FontSize + 1
		Loop
		FontSize = FontSize - 1
		'Draw the TickChar centered in the box
		CNV1.DrawText(TickChar,Size/2,(Size + CNV.MeasureStringHeight(TickChar,Typeface.DEFAULT,FontSize))/2,Typeface.DEFAULT,FontSize,TickColor,"CENTER")
	End If
	Checked.Initialize(BMChecked)
	'Draw disabled State
	Dim CNV2 As Canvas
	CNV2.Initialize2(BMDisabled)
	CNV2.DrawRect(Rect1,DisabledColor,True,BoxWidth)
	CNV2.DrawRect(Rect1,BoxColor,False,BoxWidth)
	Disabled.Initialize(BMDisabled)

	'Add to the StateList Drawable
	SLD.AddState(SLD.State_Disabled,Disabled)
	SLD.AddState(SLD.State_Checked,Checked)
	SLD.AddState(SLD.State_Enabled,Enabled)
	SLD.AddCatchAllState(Enabled)
	'Add SLD to the Checkbox
	Dim JO As JavaObject = CB
	JO.RunMethod("setButtonDrawable",Array As Object(SLD))
End Sub

'-----------------------------------------------------------------------------

Public Sub ResizeText(value As Object, lbl As B4XView) 
	''Sleep(0)
	lbl.Text = value
	Dim multipleLines As Boolean = lbl.Text.Contains(CRLF)
	Dim size As Float
	For size = 5 To 72
		If CheckSize(size, multipleLines,lbl) Then Exit
	Next
	size = size - 0.5
	If CheckSize(size, multipleLines,lbl) Then size = size - 0.5
	'Sleep(0)
	lbl.TextSize = size
	'Return size
	
End Sub

'returns true if the size is too large
Private Sub CheckSize(size As Float, multipleLines As Boolean, lbl As B4XView) As Boolean
	lbl.TextSize = size
	If multipleLines Then
		Dim su As StringUtils
		Return su.MeasureMultilineTextHeight(lbl,lbl.Text) > lbl.Height
	Else
		Dim stuti As StringUtils
		Return MeasureTextWidth(lbl.Text,lbl.Font) > lbl.Width Or stuti.MeasureMultilineTextHeight(lbl,lbl.Text) > lbl.Height
	End If
	
End Sub
Private Sub MeasureTextWidth(Text As String, Font1 As B4XFont) As Int
	'https://www.b4x.com/android/forum/threads/b4x-xui-add-measuretextwidth-and-measuretextheight-to-b4xcanvas.91865/#content
	Private bmp As Bitmap
	bmp.InitializeMutable(1, 1)'ignore
	Private cvs As Canvas
	cvs.Initialize2(bmp)
	Return cvs.MeasureStringWidth(Text, Font1.ToNativeFont, Font1.Size)
End Sub
'-----------------------------------------------------------------------------


Public Sub MaxVerticalHeight_Landscape() As Float
	Return gHeight*.8
End Sub







