B4J=true
Group=CUSTOM_CONTROLS
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
' lmB4XImageView

#Region VERSIONS 
'	2.1.4		11/03/2022   - sadLogic, Kherson Ukraine
'				Changed setBitmap to Public
'	2.1.3		08/05/2022   - sadLogic, Kherson Ukraine
'				Changed Click_Animation to CreateHaloEffect
'   2.1.2		08/02/2022   - sadLogic, Kherson Ukraine
'				Added Tag2 property
'   2.1.1		07/11/2022    - sadLogic, Kherson Ukraine
'				Trapped Android pre V5 error
'   2.1.0		07/05/2022   - sadLogic, Kherson Ukraine
'				Added click event animation, needs work
'	2.0.0		04/10/2021
'				Removed B4A Touch event; it prevented the Click event from being triggered.
'				Added LongClick event (not in B4J).
'	1.2.0		02/28/2021
'				Added Touch event.
'	1.0.1		02/28/2021
'				Fixed bug pnlOver color.
'	1.0.0		02/28/2021
'				My version based on Erel's version in XUI Views v2.44.
'				Added 
#End Region

#Region DESIGNER PROPERTIES 

#DesignerProperty: Key: ResizeMode, DisplayName: Resize Mode, FieldType: String, List: FIT|FILL|FILL_NO_DISTORTIONS|FILL_WIDTH|FILL_HEIGHT|NONE, DefaultValue: FIT
#DesignerProperty: Key: Round, DisplayName: Round, FieldType: Boolean, DefaultValue: False
#DesignerProperty: Key: CornersRadius, DisplayName: Corners Radius, FieldType: Int, DefaultValue: 0
#DesignerProperty: Key: BackgroundColor, DisplayName: Background Color, FieldType: Color, DefaultValue: 0xFFAAAAAA
#DesignerProperty: Key: ClickAnimation, DisplayName: Click Animation, FieldType: Boolean, DefaultValue: False
#DesignerProperty: Key: Tag2, DisplayName: Tag2, FieldType: String, DefaultValue: 

#End Region

#Region CLASS EVENTS 

'#Event: Touch (Action As Int, arrXY() As Float)

#If B4J
	#Event: MouseClicked(EventData As MouseEvent)
#Else If B4A
	#Event: Click
	#Event: LongClick
#End If

#End Region

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView
	
	#If B4J
		Private pnlOver As Pane
	#Else
		Private pnlOver As Panel
	#End If
	Private xpnlOver As B4XView
	
	Private xui As XUI 'ignore
	Public Tag As Object
	Private iv As B4XView
	Private mResizeMode As String
	Private mRound As Boolean
	Private mBitmap As B4XBitmap
	Public mBackgroundColor As Int
	Private mCornersRadius As Int
	Private mClickAnimation As Boolean
	Private mTag2 As String = ""
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
    Tag = mBase.Tag
    mBase.Tag = Me 
	Dim iiv As ImageView
	iiv.Initialize("iv")
	iv = iiv
	mClickAnimation=Props.Get("ClickAnimation")
	mRound =Props.Get("Round")
	mResizeMode = Props.Get("ResizeMode")
	mBackgroundColor = xui.PaintOrColorToColor(Props.Get("BackgroundColor"))
	mCornersRadius = DipToCurrent(Props.GetDefault("CornersRadius", 0))
	mBase.AddView(iv, 0, 0, mBase.Width, mBase.Height)
	xpnlOver = xui.CreatePanel("pnlOver")
	xpnlOver.SetLayoutAnimated(0, 0, 0, mBase.Width, mBase.Height)
	xpnlOver.Color = xui.Color_Transparent
	pnlOver = xpnlOver
	mBase.AddView(pnlOver, 0, 0, mBase.Width, mBase.Height)
	Update
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
	Update
End Sub

#Region PROPERTIES 

'Gets or sets Tag2 property
Public Sub getTag2 As String
	Return mTag2
End Sub
Public Sub setTag2 (s As String)
	mTag2 = s
End Sub

'Gets or sets whether to show some type of action when clicked
Public Sub getClickAnimation As Boolean
	Return mClickAnimation
End Sub
Public Sub setClickAnimation (b As Boolean)
	mClickAnimation = b
End Sub

'Gets or sets whether to make the image rounded.
Public Sub getRoundedImage As Boolean
	Return mRound
End Sub
Public Sub setRoundedImage (b As Boolean)
	If b = mRound Then Return
	mRound = b
	UpdateClip
End Sub

'Gets or sets whether to make the image rounded.
Public Sub getCornersRadius As Int
	Return mCornersRadius
End Sub
Public Sub setCornersRadius (i As Int)
	mCornersRadius = i
	UpdateClip
End Sub

'Gets or sets the resize mode. One of the following values: FIT, FILL, FILL_NO_DISTORTIONS, FILL_WIDTH, FILL_HEIGHT, NONE
'All modes except of FILL respect the image ratio. In most cases it is better not to use FILL.
Public Sub getResizeMode As String
	Return mResizeMode
End Sub
Public Sub setResizeMode(s As String)
	If s = mResizeMode Then Return
	mResizeMode = s
	Update
End Sub

Public Sub setBitmap(Bmp As B4XBitmap)
	mBitmap = Bmp
	SetBitmapAndFill(iv, Bmp)
	Update
End Sub

Public Sub getBitmap As B4XBitmap
	Return mBitmap
End Sub

Public Sub setLeft(Left As Double)
	mBase.Left = Left
	Update
End Sub
Public Sub getLeft As Double
	Return mBase.Left
End Sub

Public Sub setTop(Top As Double)
	mBase.Top = Top
	Update
End Sub
Public Sub getTop As Double
	Return mBase.Top
End Sub

Public Sub setWidth(Width As Double)
	mBase.Width = Width
	Update
End Sub
Public Sub getWidth As Double
	Return mBase.Width
End Sub

Public Sub setHeight(Height As Double)
	mBase.Height = Height
	Update
End Sub
Public Sub getHeight As Double
	Return mBase.Height
End Sub

#End Region

#Region PUBLIC METHODS 

Public Sub Update
	If mBitmap.IsInitialized = False Then Return
	UpdateClip
	Dim ImageViewWidth, ImageViewHeight As Float
	Dim bmpRatio As Float = mBitmap.Width / mBitmap.Height
	Select mResizeMode
		Case "FILL"
			ImageViewWidth = mBase.Width
			ImageViewHeight = mBase.Height
		Case "FIT"
			Dim r As Float = Min(mBase.Width / mBitmap.Width, mBase.Height / mBitmap.Height)
			ImageViewWidth = mBitmap.Width * r
			ImageViewHeight = mBitmap.Height * r		
		Case "FILL_WIDTH"
			ImageViewWidth = mBase.Width
			ImageViewHeight = ImageViewWidth / bmpRatio
		Case "FILL_HEIGHT"
			ImageViewHeight = mBase.Height
			ImageViewWidth = ImageViewHeight * bmpRatio
		Case "FILL_NO_DISTORTIONS"
			Dim r As Float = Max(mBase.Width / mBitmap.Width, mBase.Height / mBitmap.Height)
			ImageViewWidth = mBitmap.Width * r
			ImageViewHeight = mBitmap.Height * r
		Case "NONE"
			ImageViewWidth = mBitmap.Width
			ImageViewHeight = mBitmap.Height
		Case Else
			Log("Invalid resize mode: "  & mResizeMode)
	End Select
	iv.SetLayoutAnimated(0, Round(mBase.Width / 2 - ImageViewWidth / 2), Round(mBase.Height / 2 - ImageViewHeight / 2), Round(ImageViewWidth), Round(ImageViewHeight))
	pnlOver.SetLayoutAnimated(0, iv.Left, iv.Top, iv.Width, iv.Height)
End Sub

'Loads a bitmap. It uses LoadBitmapSample in B4A to avoid loading larger than necessary images.
Public Sub Load (Dir As String, FileName As String)
	#if B4A
	setBitmap(LoadBitmapSample(Dir, FileName, mBase.Width, mBase.Height))
	#Else
	setBitmap(xui.LoadBitmap(Dir, FileName))
	#End If
End Sub

'Removes the bitmap.
Public Sub Clear
	mBitmap = Null
	iv.SetBitmap(Null)
End Sub

#End Region

#Region PRIVATE METHODS 

'Sets a bitmap and sets the gravity to Fill.
Private Sub SetBitmapAndFill (ImageView As B4XView, Bmp As B4XBitmap)
	ImageView.SetBitmap(Bmp)
	Dim iiv As ImageView = ImageView
	#if B4A
	iiv.Gravity = Gravity.FILL
	#Else If B4J
	iiv.PreserveRatio = False
	#else if B4i
	iiv.ContentMode = iiv.MODE_FILL
	#End If
End Sub

Private Sub UpdateClip
	If mRound Then
		mBase.SetColorAndBorder(mBackgroundColor, 0, 0, Min(mBase.Width / 2, mBase.Height / 2))
		xpnlOver.SetColorAndBorder(xui.Color_Transparent, 0, 0, Min(mBase.Width / 2, mBase.Height / 2))
	Else
		mBase.SetColorAndBorder(mBackgroundColor, 0, 0, mCornersRadius)
		xpnlOver.SetColorAndBorder(xui.Color_Transparent, 0, 0, mCornersRadius)
	End If
#if B4J
	Dim jo As JavaObject = mBase
	Dim shape As JavaObject
	If mRound Then
		Dim radius As Double = Min(mBase.Width / 2, mBase.Height / 2)
		Dim cx As Double = mBase.Width / 2
		Dim cy As Double = mBase.Height / 2
		shape.InitializeNewInstance("javafx.scene.shape.Circle", Array(cx, cy, radius))
	Else
		Dim cx As Double = mBase.Width
		Dim cy As Double = mBase.Height
		shape.InitializeNewInstance("javafx.scene.shape.Rectangle", Array(cx, cy))
		If mCornersRadius > 0 Then
			Dim d As Double = mCornersRadius
			shape.RunMethod("setArcHeight", Array(d))
			shape.RunMethod("setArcWidth", Array(d))
		End If
	End If
	jo.RunMethod("setClip", Array(shape))
#else if B4A
	Try
		Dim jo As JavaObject = mBase
		jo.RunMethod("setClipToOutline", Array(mRound Or mCornersRadius > 0))
	Catch
		'Log("Only supported on Android 5 and above")
	End Try'ignore
#end if
End Sub

#End Region

#Region VIEWS' EVENTS 

#If B4J
	Private Sub pnlOver_MouseClicked (EventData As MouseEvent)
		If mClickAnimation Then Click_Animation
		Dim SubFullName As String = mEventName & "_MouseClicked"
		If SubExists(mCallBack, SubFullName) Then
			CallSub2(mCallBack, SubFullName, EventData)
		End If
	End Sub
#Else
	Private Sub pnlOver_Click
		Dim SubFullName As String = mEventName & "_Click"
		If SubExists(mCallBack, SubFullName) Then
			If mClickAnimation Then Click_Animation
			CallSub(mCallBack, SubFullName)
		End If
   End Sub

	Private Sub pnlOver_LongClick
		Dim SubFullName As String = mEventName & "_LongClick"
		If SubExists(mCallBack, SubFullName) Then
			If mClickAnimation Then Click_Animation
			CallSub(mCallBack, SubFullName)
		End If
	End Sub

#End If


private Sub Click_Animation
	'--- just dim the view, need to be replaced with something better
'	pnlOver.Color = xui.Color_ARGB(127,196,165,165)
'	Sleep(400)
'	pnlOver.Color = xui.Color_Transparent
	'--- try this
	CreateHaloEffect(pnlOver,xui.Color_ARGB(152,255,255,255))
End Sub

Private Sub CreateHaloEffect (Parent As B4XView,clr As Int)
	Dim cvs As B4XCanvas
	Dim p As B4XView = xui.CreatePanel("")
	Dim radius As Int = 220dip
	p.SetLayoutAnimated(0, 0, 0, radius * 2, radius * 2)
	cvs.Initialize(p)
	cvs.DrawCircle(cvs.TargetRect.CenterX, cvs.TargetRect.CenterY, cvs.TargetRect.Width / 2, clr, True, 0)
	Dim bmp As B4XBitmap = cvs.CreateBitmap
	
	CreateHaloEffectHelper(Parent,bmp, radius)

End Sub

Private Sub CreateHaloEffectHelper (Parent As B4XView,bmp As B4XBitmap, radius As Int)
	Dim x As Float = Parent.Width/2
	Dim y As Float = Parent.Height/2
	Dim iv1 As ImageView
	iv1.Initialize("")
	Dim p As B4XView = iv1
	p.SetBitmap(bmp)
	Parent.AddView(p, x, y, 0, 0)
	Dim duration As Int = 660
	p.SetLayoutAnimated(duration, x - radius, y - radius, 2 * radius, 2 * radius)
	p.SetVisibleAnimated(duration, False)
	Sleep(duration)
	p.RemoveViewFromParent
End Sub


#End Region

