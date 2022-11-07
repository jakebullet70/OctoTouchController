B4J=true
Group=B4X_CUSTOM_CLASSES
ModulesStructureVersion=1
Type=Class
Version=6.98
@EndOfDesignText@
' Tweaker:  sadLogic-JakeBullet70
#Region VERSIONS 
' My tweaks... (see TWEAKS comments)
' V. 1.0 	Nov/05/2022 - Yeah, still a war on - city occupied
'			Added enable / disable of OK btn frame
' V. Whatever, from B4x 11.8  - Pulled from B4Xlib and added as internal class
#End Region
Sub Class_Globals
	Private xui As XUI
	Public mBase As B4XView
	Public Text As String
	Private xDialog As B4XDialog
	Public RegexPattern As String
	Public TextField1 As B4XView
	Public lblTitle As B4XView
	Private IME As IME
	Private mAllowDecimals As Boolean 'ignore
	Private BorderColor = xui.Color_White, BorderColorInvalid = xui.Color_Red As Int
End Sub

Public Sub Initialize
	mBase = xui.CreatePanel("mBase")
	mBase.SetLayoutAnimated(0, 0, 0, 300dip, 80dip)
	mBase.LoadLayout("B4XInputTemplate")
	TextField1.TextColor = xui.Color_White
	#if B4A
	IME.Initialize("")
	Dim jo As JavaObject = TextField1
	jo.RunMethod("setImeOptions", Array(Bit.Or(33554432, 6))) 'IME_FLAG_NO_FULLSCREEN | IME_ACTION_DONE
	#if DEBUG
	Dim jo As JavaObject = Me
	jo.RunMethod("RemoveWarning", Null)
	#End If
	#End If
	SetBorder(BorderColor)
End Sub

'Sets the border color for the valid and invalid states.
Public Sub SetBorderColor(Valid As Int, Invalid As Int)
	BorderColor = Valid
	BorderColorInvalid = Invalid
	SetBorder(BorderColor)
End Sub

Public Sub ConfigureForNumbers (AllowDecimals As Boolean, AllowNegative As Boolean)
	Dim et As EditText = TextField1
	If AllowDecimals Or AllowNegative Then 
		et.InputType = et.INPUT_TYPE_DECIMAL_NUMBERS 
	Else 
		et.InputType = et.INPUT_TYPE_NUMBERS
	End If
	'https://stackoverflow.com/a/39399503/971547
	If AllowDecimals And AllowNegative Then
		RegexPattern = "^-?(0|[1-9]\d*)?(\.\d+)?(?<=\d)$"
	Else If AllowDecimals And AllowNegative = False Then
		RegexPattern = "^(0|[1-9]\d*)?(\.\d+)?(?<=\d)$"
	Else If AllowDecimals = False And AllowNegative = True Then
		RegexPattern = "^-?(0|[1-9]\d*)$"
	Else If AllowDecimals = False And AllowNegative = False Then
		RegexPattern = "^(0|[1-9]\d*)$"
	End If
	mAllowDecimals = AllowDecimals
End Sub

Private Sub TextField1_TextChanged (Old As String, New As String)
	Validate (New)
End Sub

Private Sub Validate (New As String)
	Dim bc As Int = BorderColor
	Dim enabled As Boolean = True
	If IsValid(New) = False Then
		If New.Length > 0 Then
			bc = BorderColorInvalid
		End If
		enabled = False
	End If
	xDialog.SetButtonState(xui.DialogResponse_Positive, enabled)
	'--- TWEAKS V1.0
	guiHelpers.EnableDisableViews(Array As B4XView(xDialog.GetButton(xui.DialogResponse_Positive)),enabled)
	'---
	SetBorder(bc)
End Sub

Private Sub SetBorder(bc As Int)
	TextField1.SetColorAndBorder(xui.Color_Transparent, 1dip, bc, 2dip)
End Sub

Private Sub IsValid(New As String) As Boolean
	Return RegexPattern = "" Or Regex.IsMatch(RegexPattern, New)
End Sub

Private Sub TextField1_Action
	TextField1_EnterPressed
End Sub

Private Sub TextField1_EnterPressed
	If IsValid(TextField1.Text) Then xDialog.Close(xui.DialogResponse_Positive)
End Sub


Public Sub GetPanel (Dialog As B4XDialog) As B4XView
	Return mBase
End Sub

Private Sub Show (Dialog As B4XDialog)
	xDialog = Dialog
	xDialog.PutAtTop = xui.IsB4A Or xui.IsB4i
	Sleep(20)
	TextField1.Text = Text
	Validate(Text)
	TextField1.RequestFocus
	Dim tf As EditText = TextField1
	tf.SelectAll
	IME.ShowKeyboard(TextField1)
End Sub

Private Sub DialogClosed(Result As Int)
	If Result = xui.DialogResponse_Positive Then
		Text = TextField1.Text
	End If
End Sub

#if DEBUG
#if JAVA
public void RemoveWarning() throws Exception{
	anywheresoftware.b4a.shell.Shell s = anywheresoftware.b4a.shell.Shell.INSTANCE;
	java.lang.reflect.Field f = s.getClass().getDeclaredField("errorMessagesForSyncEvents");
	f.setAccessible(true);
	java.util.HashSet<String> h = (java.util.HashSet<String>)f.get(s);
	if (h == null) {
		h = new java.util.HashSet<String>();
		f.set(s, h);
	}
	h.add("textfield1_textchanged");
}
#End If
#End If

