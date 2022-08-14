B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/12/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgNumericInput"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mPrompt As String
	Private mTitle As String
	Private mCallback As Object
	Private mEventName As String
	
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String, prompt As String, Callback As Object, EventName As String)
	
	mMainObj = mobj
	mTitle = title
	mPrompt = prompt
	mCallback = Callback
	mEventName = EventName
	
End Sub


Public Sub Show
	
	'--- init
	mMainObj.Dialog.Initialize(mMainObj.Root)
	Dim inputTemplate As B4XInputTemplate
	inputTemplate.Initialize
	
	'--- setup edittext control
	Dim et As EditText = inputTemplate.TextField1
	et.InputType = et.INPUT_TYPE_NUMBERS
	inputTemplate.ConfigureForNumbers(False, False) 'AllowDecimals, AllowNegative
	et.TextSize = 18 : et.TextColor = clrTheme.txtNormal : et.Gravity = Gravity.CENTER
	
	'--- make it pretty
	inputTemplate.mBase.Color = clrTheme.BackgroundMenu
	inputTemplate.lblTitle.Text = mPrompt
	
	guiHelpers.ThemeDialogForm(mMainObj.Dialog, mTitle)
	Dim rs As ResumableSub = mMainObj.Dialog.ShowTemplate(inputTemplate, "Set", "", "Cancel")
	guiHelpers.ThemeInputDialogBtnsResize(mMainObj.Dialog)
	
	'--- display dialog
	Wait For(rs)complete(intResult As Int)
	If intResult = xui.DialogResponse_Positive Then
		
		CallSub2(mCallback,mEventName,inputTemplate.Text)
	Else
		CallSub2(mCallback,mEventName,"")
		
	End If

End Sub





