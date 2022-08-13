B4A=true
Group=DIALOGS_POPUPS
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
	Private mTitle As String
	Private mCallback As Object
	Private mEventName As String
	Private mDataMap As Map
	Private mTag As Object = Null 'ignore
	
End Sub

Public Sub setTag(v As Object)
	mTag = v
End Sub

Public Sub Initialize(mobj As B4XMainPage, title As String, Callback As Object, EventName As String)
	
	mMainObj = mobj
	mTitle = title
	mCallback = Callback
	mEventName = EventName
	
End Sub


Public Sub Show(height As Float, width As Float, data As Map)
	
	'--- init
	mMainObj.Dialog.Initialize(mMainObj.Root)
	Dim ListTemplate As B4XListTemplate : ListTemplate.Initialize
	mDataMap = data
	
	'--- make it pretty
	ListTemplate.CustomListView1.DefaultTextBackgroundColor = clrTheme.BackgroundMenu

	'--- setup control
	ListTemplate.Resize(width, height)
	ListTemplate.CustomListView1.AsView.width = width
	ListTemplate.CustomListView1.AsView.Height = height
	ListTemplate.options = fnc.Map2List(mDataMap,True)
	Dim l As B4XView = ListTemplate.CustomListView1.DesignerLabel
	l.Font =xui.CreateDefaultFont(26)
	
	guiHelpers.ThemeDialogForm(mMainObj.Dialog, mTitle)
	Dim rs As ResumableSub = mMainObj.Dialog.ShowTemplate(ListTemplate, "", "", "Cancel")
	guiHelpers.ThemeInputDialogBtnsResize(mMainObj.Dialog)
	
	'--- display dialog
	Wait For(rs)complete(intResult As Int)
	If intResult = xui.DialogResponse_Positive Then
		CallSub3(mCallback,mEventName,mDataMap.Get(ListTemplate.SelectedItem),mTag)
	Else
		CallSub3(mCallback,mEventName,"","")
	End If

End Sub







