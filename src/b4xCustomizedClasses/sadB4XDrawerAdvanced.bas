B4A=true
Group=B4X_CUSTOM_CLASSES
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
' Author:  Erel and modified by Alexander Stolte, sadLogic
#Region VERSIONS 
' V  1.56		Apr/02/2023	- stripped out b4i code
' V. 1.55		Oct/15/2022
#End Region


#If Documentation
'--- https://www.b4x.com/android/forum/threads/b4x-b4xdraweradvanced-sliding-drawer-left-and-right-panel.143543/
'--- Writen by Erel and modified by Alexander Stolte and me!
'version 1.55 Modified
Updates:
	V1.55
		-Release
		-New StateChanged (Open As Boolean) event.
		-Right Panel support for B4I and B4A
	V1.56
		-BugFixes
	V1.57
		-BugFixes
	V1.58
		-Add SetSideWidth - Change the Side width at runtime
			-Smooth or Instant
	V1.59
		-BugFixes
		-Add SetSideWidth - Sets the Width of both panels (Left and Right)
		-Add SetSideWidth_Left - Sets the Width of the Left Panel
		-Add SetSideWidth_Right - Sets the Width of the Right Panel
#End If

#Event: StateChanged (Open As Boolean)
Sub Class_Globals
	Public ExtraWidth As Int = 30dip
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private xui As XUI 'ignore
	Private mSideWidth_Left,mSideWidth_Right As Int
	Private mLeftPanel As B4XView
	Private mRightPanel As B4XView
	Private mDarkPanel As B4XView
	Private mBasePanel As B4XView
	Private mCenterPanel As B4XView
	Private TouchXStart, TouchYStart As Float 'ignore
	Private IsOpenLeft As Boolean
	Private IsOpenRight As Boolean
	Private HandlingLSwipe As Boolean
	Private HandlingRSwipe As Boolean
	Private StartAtScrimLeft,StartAtScrimRight As Boolean 'ignore
	Private mEnabled As Boolean = True
	Private mRightPanelEnabled As Boolean = False
	Private mLeftPanelEnabled As Boolean = True
	'Private btnSTOP As Button
End Sub

Public Sub Initialize (Callback As Object, EventName As String, Parent As B4XView, SideWidth As Int)
	mEventName = EventName
	mCallBack = Callback
	mSideWidth_Left = SideWidth
	mSideWidth_Right = SideWidth
	
	Dim creator As TouchPanelCreator
	mBasePanel = creator.CreateTouchPanel("base")
	
	Parent.AddView(mBasePanel, 0, 0, Parent.Width, Parent.Height)
	mCenterPanel = xui.CreatePanel("")
	mBasePanel.AddView(mCenterPanel, 0, 0, mBasePanel.Width, mBasePanel.Height)
	mDarkPanel = xui.CreatePanel("dark")
	mBasePanel.AddView(mDarkPanel, 0, 0, mBasePanel.Width, mBasePanel.Height)
	mLeftPanel = xui.CreatePanel("LeftPanel")
	mBasePanel.AddView(mLeftPanel, -SideWidth, 0, SideWidth, mBasePanel.Height)
	mRightPanel = xui.CreatePanel("RightPanel")
	mBasePanel.AddView(mRightPanel, mBasePanel.Width, 0, SideWidth, mBasePanel.Height)
	
	Dim pL As Panel = mLeftPanel
	pL.Elevation = 4dip
	Dim pR As Panel = mRightPanel
	pR.Elevation = 4dip
	
End Sub

Private Sub LeftPanel_Click
	
End Sub



Private Sub Base_OnTouchEvent (Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
	If mEnabled = False Then Return False
	
	If x <= ExtraWidth And Not(IsOpenRight) And mLeftPanelEnabled = False Then
		Return False
	End If
	
	If x > =  mBasePanel.Width - ExtraWidth And Not(IsOpenLeft) And mRightPanelEnabled = False Then
		Return False
	End If
	
	Dim LeftPanelRightSide As Int = mLeftPanel.Left + mLeftPanel.Width
	Dim RightPanelLeftSide As Int = mRightPanel.Left
	
	If HandlingLSwipe = False And HandlingRSwipe = False Then
		If LeftPanelRightSide < x And x < RightPanelLeftSide Then
			If IsOpenLeft Then
				TouchXStart = X
				If Action = mBasePanel.TOUCH_ACTION_UP Then setLeftOpen(False)
				Return True
			End If
			If IsOpenRight Then
				TouchXStart = X
				If Action = mBasePanel.TOUCH_ACTION_UP Then setRightOpen(False)
				Return True
			End If
			If IsOpenLeft = False And x > LeftPanelRightSide + ExtraWidth And IsOpenRight = False And x < RightPanelLeftSide - ExtraWidth Then
				Return False
			End If
		End If
	End If
	Select Action
		Case mBasePanel.TOUCH_ACTION_MOVE
			Dim dx As Float = x - TouchXStart
			TouchXStart = X
			If HandlingLSwipe Or ( x <= ExtraWidth And Abs(dx) > 3dip And Not(IsOpenRight) ) Then
				HandlingLSwipe = True
				LeftChangeOffset(mLeftPanel.Left + dx, True, False)
			End If
			If HandlingRSwipe Or ( x >= mBasePanel.Width - ExtraWidth And Abs(dx) > 3dip And Not(IsOpenLeft) ) Then
				HandlingRSwipe = True
				RightChangeOffset(mRightPanel.Left + dx, True, False)
			Else if IsOpenRight Then
				HandlingRSwipe = True
				RightChangeOffset(mRightPanel.Left + dx, True, False)
			End If
		Case mBasePanel.TOUCH_ACTION_UP
			If HandlingLSwipe Then
				LeftChangeOffset(mLeftPanel.Left, False, False)
			End If
			If HandlingRSwipe Then
				RightChangeOffset(mRightPanel.Left, False, False)
			End If
			HandlingLSwipe = False
			HandlingRSwipe = False
	End Select

	Return True
End Sub

'Return True to "steal" the event from the child views
Private Sub Base_OnInterceptTouchEvent (Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
	If mEnabled = False Then Return False
	If IsOpenLeft = False And IsOpenRight = False And mLeftPanel.Left + mLeftPanel.Width + ExtraWidth < x And x < mRightPanel.Left - ExtraWidth Then
		HandlingLSwipe = False
		HandlingRSwipe = False
		Return False
	End If
	If IsOpenLeft And x > mLeftPanel.Left + mLeftPanel.Width Then
		'handle all touch events right of the opened side menu
		Return True
	End If
	If IsOpenRight And x < mRightPanel.Left Then
		'handle all touch events left of the opened side menu
		Return True
	End If
	If HandlingLSwipe Or HandlingRSwipe Then Return True
	Select Action
		Case mBasePanel.TOUCH_ACTION_DOWN
			TouchXStart = X
			TouchYStart = Y
			HandlingLSwipe = False
			HandlingRSwipe = False
		Case mBasePanel.TOUCH_ACTION_MOVE
			Dim dx As Float = Abs(x - TouchXStart)
			Dim dy As Float = Abs(y - TouchYStart)
			If dy < 20dip And dx > 10dip Then
				If (( x <= ExtraWidth And IsOpenRight = False ) Or IsOpenLeft ) Then
					HandlingLSwipe = True
				End If
				If (( x >= mBasePanel.Width - ExtraWidth And IsOpenLeft = False ) Or IsOpenRight ) Then
					HandlingRSwipe = True
				End If
			End If
	End Select
	Return HandlingLSwipe Or HandlingRSwipe
End Sub



Private Sub LeftChangeOffset (x As Float, CurrentlyTouching As Boolean, NoAnimation As Boolean)
	If mLeftPanelEnabled Then
		x = Max(-mSideWidth_Left, Min(0, x))
		Dim VisibleOffset As Int = mSideWidth_Left + x

		If CurrentlyTouching = False Then
			If (IsOpenLeft And VisibleOffset < 0.8 * mSideWidth_Left) Or (IsOpenLeft = False And VisibleOffset < 0.2 * mSideWidth_Left) Then
				x = -mSideWidth_Left
				IsOpenLeft = False
				SetIsOpen(False)
			Else
				x = 0
				IsOpenLeft = True
				SetIsOpen(True)
			End If
			VisibleOffset = mSideWidth_Left + x
			Dim dx As Int = Abs(mLeftPanel.Left - x)
			Dim duration As Int = Max(0, 200 * dx / mSideWidth_Left)
			If NoAnimation Then duration = 0
			mLeftPanel.SetLayoutAnimated(duration, x, 0, mLeftPanel.Width, mLeftPanel.Height)
			mDarkPanel.SetColorAnimated(duration, mDarkPanel.Color, OffsetToColor(VisibleOffset,True))

		Else
			mDarkPanel.Color = OffsetToColor(VisibleOffset,True)
			mLeftPanel.Left = x
		End If
	End If
End Sub

Private Sub RightChangeOffset (x As Float, CurrentlyTouching As Boolean, NoAnimation As Boolean)
	If mRightPanelEnabled Then
		x = Max(mBasePanel.Width-mSideWidth_Right, Min(mBasePanel.Width, x))
		Dim VisibleOffset As Int = mBasePanel.Width - x

		If CurrentlyTouching = False Then
			If (IsOpenRight And VisibleOffset < 0.8 * mSideWidth_Right) Or (IsOpenRight = False And VisibleOffset < 0.2 * mSideWidth_Right) Then
				x = mBasePanel.Width
				IsOpenRight = False
				SetIsOpen(False)
			Else
				x = mBasePanel.Width-mSideWidth_Right
				IsOpenRight = True
				SetIsOpen(True)
			End If
			VisibleOffset = mBasePanel.Width - x
			Dim dx As Int = Abs(mRightPanel.Left - x)
			Dim duration As Int = Max(0, 200 * dx / mSideWidth_Right)
			If NoAnimation Then duration = 0
			mRightPanel.SetLayoutAnimated(duration, x, 0, mRightPanel.Width, mRightPanel.Height)
			mDarkPanel.SetColorAnimated(duration, mDarkPanel.Color, OffsetToColor(VisibleOffset,False))

		Else
			mDarkPanel.Color = OffsetToColor(VisibleOffset,False)
			mRightPanel.Left = x
			'Log(mRightPanel.Left)
		End If
	End If
End Sub

Private Sub SetIsOpen (NewState As Boolean)
'	If IsOpenLeft = NewState Or IsOpenRight = NewState Then 
'		Return '--- With this code THIS NEVER FIRES!!!
'	End If
	If xui.SubExists(mCallBack, mEventName & "_StateChanged", 1) Then
		CallSubDelayed2(mCallBack,  mEventName & "_StateChanged", NewState)
	End If
End Sub

Private Sub OffsetToColor (x As Int,LeftPanel As Boolean) As Int
	Dim Visible As Float = x / IIf(LeftPanel,mSideWidth_Left,mSideWidth_Right)
	Return xui.Color_ARGB(100 * Visible, 0, 0, 0)
End Sub

Public Sub getLeftOpen As Boolean
	Return IsOpenLeft
End Sub

Public Sub setLeftOpen (b As Boolean)
	If mLeftPanelEnabled Then
	If b = IsOpenLeft Then Return
	If b Then setRightOpen(False)
	Dim x As Float
		If b Then x = 0 Else x = -mSideWidth_Left
	LeftChangeOffset(x, False, False)
	End If
End Sub

Public Sub getLeftPanel As B4XView
	Return mLeftPanel
End Sub

Public Sub getRightOpen As Boolean
	Return IsOpenRight
End Sub

Public Sub setRightOpen (b As Boolean)
	If mRightPanelEnabled Then
		If b = IsOpenRight Then Return
		If b Then setLeftOpen(False)
		Dim x As Float
		If b Then x = mBasePanel.Width-mSideWidth_Right Else x = mBasePanel.Width
		RightChangeOffset(x, False, False)
	End If
End Sub

Public Sub getRightPanel As B4XView
	Return mRightPanel
End Sub

Public Sub getCenterPanel As B4XView
	Return mCenterPanel
End Sub

Public Sub Resize(Width As Int, Height As Int)
	If IsOpenLeft Then LeftChangeOffset(-mSideWidth_Left, False, True)
	If IsOpenRight Then RightChangeOffset(Width, False, True)
	mBasePanel.SetLayoutAnimated(0, 0, 0, Width, Height)
	mLeftPanel.SetLayoutAnimated(0, mLeftPanel.Left, 0, mSideWidth_Left, mBasePanel.Height)
	mRightPanel.SetLayoutAnimated(0, mRightPanel.Left, 0, mSideWidth_Right, mBasePanel.Height)
	mDarkPanel.SetLayoutAnimated(0, 0, 0, Width, Height)
	mCenterPanel.SetLayoutAnimated(0, 0, 0, Width, Height)
End Sub
'Sets the Width of both panels (Left and Right)
Public Sub SetSideWidth(Width As Float,Smooth As Boolean)
	mSideWidth_Left = Width
	mSideWidth_Right = Width
	Dim Duration As Long = IIf(Smooth,250,0)

	If IsOpenLeft Then
		mLeftPanel.SetLayoutAnimated(Duration,mLeftPanel.Left,mLeftPanel.Top,mSideWidth_Left,mLeftPanel.Height)
	Else If IsOpenRight Then
		mRightPanel.SetLayoutAnimated(Duration,mBasePanel.Width - mSideWidth_Right,mRightPanel.Top,mSideWidth_Right,mRightPanel.Height)
	Else
		mLeftPanel.SetLayoutAnimated(0,-mSideWidth_Left,mLeftPanel.Top,mSideWidth_Left,mLeftPanel.Height)
		mRightPanel.SetLayoutAnimated(0,mBasePanel.Width,mRightPanel.Top,mSideWidth_Right,mRightPanel.Height)
	End If
End Sub
'Sets the Width of the Left Panel
Public Sub SetSideWidth_Left(Width As Float,Smooth As Boolean)
	mSideWidth_Left = Width
	Dim Duration As Long = IIf(Smooth,250,0)

	If IsOpenLeft Then
		mLeftPanel.SetLayoutAnimated(Duration,mLeftPanel.Left,mLeftPanel.Top,mSideWidth_Left,mLeftPanel.Height)
	Else
		mLeftPanel.SetLayoutAnimated(0,-mSideWidth_Left,mLeftPanel.Top,mSideWidth_Left,mLeftPanel.Height)
	End If
End Sub
'Sets the Width of the Right Panel
Public Sub SetSideWidth_Right(Width As Float,Smooth As Boolean)
	mSideWidth_Right = Width
	Dim Duration As Long = IIf(Smooth,250,0)

	If IsOpenRight Then
		mRightPanel.SetLayoutAnimated(Duration,mBasePanel.Width - mSideWidth_Right,mRightPanel.Top,mSideWidth_Right,mRightPanel.Height)
	Else
		mRightPanel.SetLayoutAnimated(0,mBasePanel.Width,mRightPanel.Top,mSideWidth_Right,mRightPanel.Height)
	End If
End Sub

Public Sub getGestureEnabled As Boolean
	Return mEnabled
End Sub

Public Sub setGestureEnabled (b As Boolean)
	mEnabled = b
End Sub

Public Sub getLeftPanelEnabled As Boolean
	Return mLeftPanelEnabled
End Sub

Public Sub setLeftPanelEnabled(b As Boolean)
	 mLeftPanelEnabled = b
End Sub

Public Sub getRightPanelEnabled As Boolean
	Return mRightPanelEnabled
End Sub

Public Sub setRightPanelEnabled(b As Boolean)
	mRightPanelEnabled = b
End Sub

'#if OBJC
'- (NSObject*) CreateRecognizer{
' 	 UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(action:)];
'    [rec setMinimumNumberOfTouches:1];
'    [rec setMaximumNumberOfTouches:1];
'	return rec;
'}
'-(void) action:(UIPanGestureRecognizer*)rec {
'	[self.bi raiseEvent:nil event:@"pan_event:" params:@[rec]];
'}
'#End If
'
'
