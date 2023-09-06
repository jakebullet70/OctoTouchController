B4A=true
Group=DIALOGS_GENERIC
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/13/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgListbox"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As Object
	Private mCallback As Object
	Private mEventName As String
	Private mTag As Object = Null 'ignore
	
	Private mDialog As B4XDialog
	
	Public IsMenu As Boolean = False
	
	Private backBtnRef As Object
	
End Sub

Public Sub Close_Me '--- class method, called from android back btn
	mDialog.Close(xui.DialogResponse_Cancel)
	CallSubDelayed2(Main,"SetObj_Null",backBtnRef)
End Sub

Public Sub setTag(v As Object)
	mTag = v
End Sub

Public Sub Initialize( title As Object, Callback As Object, EventName As String,ref As Object) As Object
	
	mMainObj = B4XPages.MainPage
	mTitle = title
	mCallback = Callback
	mEventName = EventName
	backBtnRef = ref
	Return Me
	
End Sub


Public Sub Show(height As Float, width As Float, data As Map)
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	Dim ListTemplate As B4XListTemplate : ListTemplate.Initialize
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	
	'--- make it pretty
	ListTemplate.CustomListView1.DefaultTextBackgroundColor = clrTheme.Background

	'--- setup control
	ListTemplate.Resize(width, height)
	ListTemplate.CustomListView1.AsView.width = width
	ListTemplate.CustomListView1.AsView.Height = height
	ListTemplate.CustomListView1.PressedColor = clrTheme.BackgroundHeader
	ListTemplate.CustomListView1.DefaultTextColor = clrTheme.txtNormal
	ListTemplate.options = objHelpers.Map2List(data,True)
	
	
	Dim l As B4XView = ListTemplate.CustomListView1.DesignerLabel
	l.Font = xui.CreateDefaultFont(NumberFormat2(20 / guiHelpers.gFscale,1,0,0,False))
	
	If guiHelpers.gIsLandScape = False Then
		If guiHelpers.gScreenSizeAprox > 6.2 Then
			l.Font = xui.CreateDefaultFont(NumberFormat2(26 / guiHelpers.gFscale,1,0,0,False))
		End If
	End If
	
	dlgHelper.ThemeDialogForm( mTitle)
	Dim rs As ResumableSub = mDialog.ShowTemplate(ListTemplate, "", "",IIf(IsMenu,"CLOSE","CANCEL"))
	dlgHelper.ThemeInputDialogBtnsResize
	
	'--- display dialog
	Wait For(rs) complete(i As Int)
	If i = xui.DialogResponse_Positive Then
		CallSub3(mCallback,mEventName,GetTagFromMap(ListTemplate.SelectedItem,data),mTag)
	Else
		CallSub3(mCallback,mEventName,"","")
	End If
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	CallSubDelayed2(Main,"SetObj_Null",backBtnRef)
	
	
End Sub


Private Sub GetTagFromMap(item As String,d As Map) As String
	'---  item is a string built with csbuilder, needs to
	'--- found this way
	For xx = 0 To d.Size - 1
		If d.GetKeyAt(xx).As(String).Contains(item) Then
			Return d.GetValueAt(xx)
		End If
	Next
	Return ""
End Sub




