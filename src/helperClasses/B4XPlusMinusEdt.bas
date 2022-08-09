B4A=true
Group=CLASSES
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  LucaMS
#Region VERSIONS 
' V. 1.1 	Aug/07/2022 - Jakebullet70
'			Added support for Vertical and Horizonal formation, misc bug fixes
' V. 1.0 	Jun/27/2022 
'			Proof Of Concept - 1st working version
#End Region


Sub Class_Globals
	Private xui As XUI
	Private mPlusMinus As B4XPlusMinus
	
	#IF B4A
	Private IME1 As IME
	Private mPnlOver As Panel
	Private mEditText As EditText
	#ELSE IF B4J
	Private mPnlOver As Pane
	Private mEditText As TextField
	#End If
	
End Sub


Public Sub Initialize(PlusMinus As B4XPlusMinus)
	mPlusMinus = PlusMinus
	mPnlOver.Initialize("pnlOver")
	
	'--- Initilize cannot be a resumable, so...
	CallSubDelayed2(Me, "Init2", PlusMinus)
End Sub


Private Sub Init2(PlusMinus As B4XPlusMinus)
	
	If PlusMinus.Formation = "Vertical" Then
		PlusMinus.mBase.AddView(mPnlOver, PlusMinus.MainLabel.Left,  _
				PlusMinus.pnlMinus.Height + (PlusMinus.ArrowsSize / 3) , _
				PlusMinus.MainLabel.Width, PlusMinus.pnlMinus.Height * 2 )
				
	Else if PlusMinus.Formation = "Horizontal" Then
		PlusMinus.mBase.AddView(mPnlOver, PlusMinus.pnlMinus.Width * 2, 0, _
				PlusMinus.mBase.Width - PlusMinus.pnlMinus.Width * 4, _
				PlusMinus.MainLabel.Height)
	Else
		PlusMinus.mBase.AddView(mPnlOver, _
				PlusMinus.MainLabel.Left , 0,	PlusMinus.MainLabel.Width , _
				PlusMinus.pnlMinus.Height * 3 )
	End If
	
	'--- LucaMS, Not sure what this does ---
	Do Until mPnlOver.Width > 50
		Sleep(1)
	Loop
	'-------------------------------------------
	
	mPnlOver.As(B4XView).Color = xui.Color_Transparent
	'mPnlOver.As(B4XView).Color = xui.Color_Cyan
	mEditText.Initialize("mEditText")
	mEditText.SingleLine = True
	mEditText.As(B4XView).TextSize = PlusMinus.MainLabel.TextSize
	mEditText.As(B4XView).TextColor = mPlusMinus.MainLabel.TextColor

	#IF B4A
	IME1.Initialize("IME1")
	mPnlOver.AddView(mEditText, 0,0, mPnlOver.Width, mPnlOver.Height)
	mEditText.InputType = mEditText.INPUT_TYPE_NUMBERS
	IME1.AddHandleActionEvent(mEditText)
	#ELSE IF B4J
	mEditText.Initialize("mEditText")
	mPnlOver.AddNode(mEditText, 0, 0, mPnlOver.Width, mPnlOver.Height)
	#End If
	mEditText.Text = PlusMinus.MainLabel.Text
	mEditText.Visible = False
	
End Sub


#IF B4A
Private Sub pnlOver_Click
#ELSE IF B4J
	'--- Don't care about the error message in the log window, it doesn't matter.
Private Sub pnlOver_MouseClicked(EventData As MouseEvent)
#End If

	mEditText.SelectAll
	mPlusMinus.MainLabel.Visible = False
	mEditText.Text = mPlusMinus.MainLabel.Text
	mEditText.Visible = True
	mEditText.RequestFocus
	#IF B4A
	IME1.ShowKeyboard(mEditText)
	#End If
	
End Sub


Private Sub mEditText_FocusChanged (HasFocus As Boolean)

	If Not(HasFocus) Then
		mPlusMinus.SelectedValue = "0" & mEditText.Text
		mEditText.Visible = False
		mPlusMinus.MainLabel.Visible = True
	End If
	
End Sub


#IF B4A
Private Sub mEditText_EnterPressed
	mEditText_FocusChanged (False)
End Sub

#ELSE IF B4J

'--- Only numbers allowed.
Private Sub mEditText_TextChanged (Old As String, New As String)
	If Not(IsNumber(New)) Then
		mEditText.Text = Old
	End If
End Sub

Private Sub mEditText_Action ' Enter pressed
	mEditText_FocusChanged(False)
End Sub

#End If
