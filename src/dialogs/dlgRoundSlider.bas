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
	
	Private const mModule As String = "dlgRoundSlider"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	Private mCallback As Object
	Private mEventName As String
	
	Private sadRoundSlider1 As sadRoundSlider
	
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String, Callback As Object, EventName As String)
	
	mMainObj = mobj
	mTitle = title
	mCallback = Callback
	mEventName = EventName
	
End Sub


'defaultValue 0 to 100
Public Sub Show(defaultValue As Int)
	
	'--- init
	mMainObj.Dialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 300dip, 300dip)
	p.LoadLayout("viewRoundSlider")
	mMainObj.Dialog.Initialize(mMainObj.Root)
	
	sadRoundSlider1.Value = defaultValue
	sadRoundSlider1.xlbl.TextColor = clrTheme.BackgroundHeader
	sadRoundSlider1.xlbl.Font = xui.CreateDefaultFont(52)
	sadRoundSlider1.ValueColor = clrTheme.BackgroundMenu
	sadRoundSlider1.SetCircleColor(clrTheme.BackgroundHeader,clrTheme.txtNormal)
	sadRoundSlider1.SetThumbColor(clrTheme.BackgroundHeader,clrTheme.txtNormal)
	sadRoundSlider1.Draw

	guiHelpers.ThemeDialogForm(mMainObj.Dialog, mTitle)
	Dim rs As ResumableSub = mMainObj.Dialog.ShowCustom(p, "OK", "", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mMainObj.Dialog)
	
	Wait For (rs) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		CallSub2(mCallback,mEventName,sadRoundSlider1.Value.As(Float))
	End If
	
End Sub


'Private Sub sadRoundSlider1_ValueChanged (Value As Int)
'	'Log(Value)
'End Sub



