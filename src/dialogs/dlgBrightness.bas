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
	
	Private const mModule As String = "dlgBrightness"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	Private mCallback As Object
	Private mEventName As String
	
	Private sadRoundSlider1 As sadRoundSlider
	Private mDialog As B4XDialog
	Private pnlMain As B4XView
	
End Sub

Public Sub Close_Me
	mDialog.Close(-1)
End Sub

Public Sub Initialize( title As String, Callback As Object, EventName As String) As Object
	
	mMainObj = B4XPages.MainPage
	mTitle = title
	mCallback = Callback
	mEventName = EventName
	Return Me
	
End Sub


'defaultValue 0 to 100
Public Sub Show(defaultValue As Int)
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	
	Dim p As B4XView = xui.CreatePanel("")
	Dim h As Float = 280dip
	If guiHelpers.gIsLandScape And guiHelpers.gScreenSizeAprox < 5.1 Then h = guiHelpers.MaxVerticalHeight_Landscape
	p.SetLayoutAnimated(0, 0, 0, 280dip,h)
	p.LoadLayout("viewRoundSlider")
	
	pnlMain.Color = clrTheme.Background
	sadRoundSlider1.Value = defaultValue
	sadRoundSlider1.xlbl.TextColor = clrTheme.BackgroundHeader
	sadRoundSlider1.xlbl.Font = xui.CreateDefaultFont(52)
	sadRoundSlider1.ValueColor = clrTheme.Background2
	sadRoundSlider1.SetCircleColor(clrTheme.BackgroundHeader,clrTheme.txtNormal)
	sadRoundSlider1.SetThumbColor(clrTheme.BackgroundHeader,clrTheme.txtNormal)
	sadRoundSlider1.Draw

	dlgHelper.ThemeDialogForm(mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "OK", "", "CANCEL")
	dlgHelper.ThemeInputDialogBtnsResize
	
	Wait For (rs) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		CallSub2(mCallback,mEventName,sadRoundSlider1.Value.As(Float))
	End If
	mMainObj.pObjCurrentDlg1 = Null
	
End Sub


'Private Sub sadRoundSlider1_ValueChanged (Value As Int)
'	'Log(Value)
'End Sub



