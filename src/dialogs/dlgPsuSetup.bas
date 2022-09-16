B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.1	Sept/16/2022
' 			Added suport for kantlivelong PSU octo plugin
' V. 1.0 	Aug/23/2022
'			PSU control for SonOff - Tasmota firmware
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgPsuSetup"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	
	Private lblSwitch,lblSonoffInfo As B4XView
	
	Private txtPrinterIP As B4XFloatTextField
	Private pnlMain As B4XView
	
	Private mValidConnection As Boolean = False
	Private mDialog As B4XDialog
	
	Private swPSUocto,swPsuCtrlOnOff,swSonoff As B4XSwitch
	
	Private lblPSUinfo As B4XView
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String)
	
	mMainObj = mobj
	mTitle = title
	
End Sub


Public Sub Show
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 420dip, 270dip)
	p.LoadLayout("viewPsuSetup")
	
	Build_GUI 

	guiHelpers.ThemeDialogForm(mDialog, mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "SAVE", "", "CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)
	guiHelpers.SetTextColor(Array As B4XView(lblSonoffInfo,lblSwitch,lblPSUinfo))

	ReadSettingsFile
	InvalidateConnection
	
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)

	Wait For (rs) Complete (Result As Int)
	
	If Result = xui.DialogResponse_Positive Then
		Save_settings
		config.ReadSonoffCFG
		CallSub(mMainObj.oPageCurrent,"Set_focus")
	End If
	
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub


private Sub Build_GUI
	
	pnlMain.Color = clrTheme.BackgroundMenu
	guiHelpers.SetTextColorB4XFloatTextField(Array As B4XFloatTextField(txtPrinterIP))
	
	txtPrinterIP.HintText = "Tasmota IP"
	swPSUocto.Value = True
	
End Sub

Public Sub CreateDefaultFile

	File.WriteMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE, _
		CreateMap(gblConst.SONOFF_IP : "", gblConst.SONOFF_ON : "false"))
	
End Sub


private Sub Save_settings
	
	Dim outMap As Map = CreateMap( _
						gblConst.SONOFF_IP : txtPrinterIP.text, gblConst.SONOFF_ON : swPsuCtrlOnOff.Value.As(String))


	guiHelpers.Show_toast("Saved",2500)							
	fileHelpers.SafeKill(gblConst.SONOFF_OPTIONS_FILE)
	File.WriteMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE,outMap)
	
End Sub


#Region "TEXT FIELD EVENTS"
Private Sub txtPrinterIP_TextChanged (Old As String, New As String)
	If swPSUocto.Value = True Then 
		InvalidateConnection
	End If
End Sub
Private Sub txtPrinterIP_FocusChanged (HasFocus As Boolean)
	txtPrinterIP.RequestFocusAndShowKeyboard
End Sub
#End Region


private Sub ReadSettingsFile

	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE)
	txtPrinterIP.Text = Data.Get(gblConst.SONOFF_IP)
	swPsuCtrlOnOff.Value = Data.Get(gblConst.SONOFF_ON).As(Boolean)

End Sub

Private Sub InvalidateConnection
	txtPrinterIP.mBase.Visible = Not (swPSUocto.Value)
	mValidConnection = False
End Sub

'--- only Sonoff or PSU control ---
Private Sub swSonoff_ValueChanged (Value As Boolean)
	swPSUocto.Value = Not (Value)
	InvalidateConnection
End Sub
Private Sub swPSUocto_ValueChanged (Value As Boolean)
	swSonoff.Value = Not (Value)
	InvalidateConnection
End Sub
'--------------------------------------

