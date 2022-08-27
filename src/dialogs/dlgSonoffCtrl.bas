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
	Private IPaddr As String
	
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String)
	
	mMainObj = mobj
	mTitle = title
	
End Sub


Public Sub Show
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 240dip, 280dip)
	p.LoadLayout("dlgSonoffCtrl")
	
	Build_GUI 

	guiHelpers.ThemeDialogForm(mDialog, mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	ReadSettingsFile

	Wait For (rs) Complete (Result As Int)
	guiHelpers.RestoreImersiveIfNeeded
	
	
End Sub



private Sub Build_GUI
	
	pnlMain.Color = clrTheme.Background
	guiHelpers.SetEnableDisableColor(Array As B4XView(btnOff,btnOn))
	
	btnOff.Text= "Off"
	btnOn.Text = "On"
	
End Sub


private Sub ReadSettingsFile

	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE)
	IPaddr = Data.Get(gblConst.SONOFF_IP)

End Sub


Private Sub btnCtrl_Click
	
	Dim o As B4XView : o = Sender
	Dim sm As HttpDownloadStr 
	sm.Initialize
	Wait For (sm.SendRequest($"http://${IPaddr}/cm?cmnd=Power%20${o.Tag}"$)) Complete(s As String)
	
	mDialog.Close(-1) '--- close it, exit dialog
	
End Sub





