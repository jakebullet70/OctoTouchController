B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/23/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgSonoffCtrl"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	
	Private pnlMain As B4XView
	Private mDialog As B4XDialog
	
	Private btnOff,btnOn As B4XView
	Public mIPaddr As String
	Public mShowOnScreen As Boolean
	
End Sub

'--- Dual class, GUI and command

Public Sub Initialize(mobj As B4XMainPage, title As String)
	
	mMainObj = mobj
	mTitle = title
	
End Sub


Public Sub Show
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	Dim h As Float
	If guiHelpers.gScreenSizeAprox > 7 Then
		h = 280dip
	Else
		h = 240dip
	End If
	p.SetLayoutAnimated(0, 0, 0, 260dip,h)
	p.LoadLayout("viewSonoffCtrl")
	
	Build_GUI 

	guiHelpers.ThemeDialogForm(mDialog, mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	ReadSettingsFile

	Wait For (rs) Complete (Result As Int)
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
	
End Sub



private Sub Build_GUI
	
	pnlMain.Color = clrTheme.BackgroundMenu
	guiHelpers.SetEnableDisableColor(Array As B4XView(btnOff,btnOn))
	
	btnOff.Text= "Off"
	btnOn.Text = "On"
	
End Sub


Public Sub ReadSettingsFile

	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE)
	mIPaddr = Data.Get(gblConst.SONOFF_IP)
	mShowOnScreen = Data.Get(gblConst.SONOFF_ON).As(Boolean)

End Sub


Private Sub btnCtrl_Click
	
	Dim o As B4XView 
	o = Sender
	Wait For (SendCmd(o.Tag)) Complete(s As String)
	mDialog.Close(-1) '--- close it, exit dialog
	
End Sub


Public Sub SendCmd(cmd As String)As ResumableSub'ignore
	
	Dim sm As HttpDownloadStr
	sm.Initialize
	guiHelpers.Show_toast($"Sending Power ${cmd.ToUpperCase} command, Please wait..."$,3000)
	Wait For (sm.SendRequest($"http://${mIPaddr}/cm?cmnd=Power%20${cmd}"$)) Complete(s As String)
	
End Sub





