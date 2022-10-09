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
	
	Private mDialog As B4XDialog
	
	Public IsMenu As Boolean = False
	
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
	mDialog.Initialize(mMainObj.Root)
	Dim ListTemplate As B4XListTemplate : ListTemplate.Initialize
	mDataMap = data
	
	'--- make it pretty
	ListTemplate.CustomListView1.DefaultTextBackgroundColor = clrTheme.Background

	'--- setup control
	ListTemplate.Resize(width, height)
	ListTemplate.CustomListView1.AsView.width = width
	ListTemplate.CustomListView1.AsView.Height = height
	ListTemplate.CustomListView1.PressedColor = clrTheme.BackgroundHeader
	ListTemplate.CustomListView1.DefaultTextColor = clrTheme.txtNormal
	ListTemplate.options = objHelpers.Map2List(mDataMap,True)
	
	
	Dim l As B4XView = ListTemplate.CustomListView1.DesignerLabel
	If guiHelpers.gIsLandScape Then
		l.Font = xui.CreateDefaultFont(NumberFormat2(26 / guiHelpers.gFscale,1,0,0,False))
	Else
		l.Font = xui.CreateDefaultFont(NumberFormat2(22 / guiHelpers.gFscale,1,0,0,False))
	End If
	
	
	guiHelpers.ThemeDialogForm(mDialog, mTitle)
	Dim rs As ResumableSub = mDialog.ShowTemplate(ListTemplate, "", "",IIf(IsMenu,"CLOSE","CANCEL"))
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)
	
	'--- display dialog
	Wait For(rs) complete(intResult As Int)
	If intResult = xui.DialogResponse_Positive Then
		CallSub3(mCallback,mEventName,mDataMap.Get(ListTemplate.SelectedItem),mTag)
	Else
		CallSub3(mCallback,mEventName,"","")
	End If

End Sub







