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
	
	Private lblPSUinfo,lblSwitch,lblSonoffInfo As B4XView
	
	Private txtPrinterIP As B4XFloatTextField
	Private pnlMain As B4XView
	
	Private mDialog As B4XDialog
	
	Private swPSUocto,swPsuCtrlOnOff,swSonoff As B4XSwitch
	
End Sub



Public Sub Initialize(mobj As B4XMainPage, title As String)
	
	mMainObj = mobj
	mTitle = title
	
End Sub


Public Sub Show

	If Starter.kvs.GetDefault("psuWarning",False).As(Boolean) = False Then
		Dim mb As dlgMsgBox
		mb.Initialize(mMainObj.root,"Information",IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth-40dip),260dip,False)
		mb.SetAsOptionalMsgBox("psuWarning")
		Wait For (mb.Show(guiHelpers.GetOctoPluginWarningTxt, _
					gblConst.MB_ICON_INFO,"","","OK")) Complete (Result As Int)
	End If
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	
	Dim w,h As Float
	If guiHelpers.gScreenSizeAprox > 6.5 Then
		w = 540dip : h = 310dip
	Else
		If guiHelpers.gIsLandScape Then
			w = 420dip
		Else
			w = 360dip
		End If
		h = 280dip
	End If
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, w, h)
	p.LoadLayout("viewPsuSetup")
	
	BuildGUI 

	guiHelpers.ThemeDialogForm(mDialog, mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "SAVE", "", "CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)
	guiHelpers.SetTextColor(Array As B4XView(lblSonoffInfo,lblSwitch,lblPSUinfo))

	ReadSettingsFile
	InvalidateConnection
	
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON)

	Wait For (rs) Complete (Result As Int)
	
	If Result = xui.DialogResponse_Positive Then
		Save_settings
		config.ReadPwrCFG
		CallSub(B4XPages.MainPage,"ShowNoShow_PowerBtn")
		CallSub(mMainObj.oPageCurrent,"Set_focus")
	End If
	
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub


Private Sub BuildGUI
	
	pnlMain.Color = clrTheme.Background
	guiHelpers.SetTextColorB4XFloatTextField(Array As B4XFloatTextField(txtPrinterIP))
	
	txtPrinterIP.HintText = "Tasmota IP"
	swPSUocto.Value = True
	
End Sub

Public Sub CreateDefaultCfg
	
	Starter.kvs.Put(gblConst.PWR_CTRL_ON,False)
	Starter.kvs.Put(gblConst.PWR_PSU_PLUGIN,True)
	Starter.kvs.Put(gblConst.PWR_SONOFF_PLUGIN,False)
	Starter.kvs.Put(gblConst.PWR_SONOFF_IP,"")
	
End Sub


Private Sub Save_settings
	
	guiHelpers.Show_toast("Saved",2500)
	Starter.kvs.Put(gblConst.PWR_CTRL_ON,swPsuCtrlOnOff.Value)
	Starter.kvs.Put(gblConst.PWR_PSU_PLUGIN,swPSUocto.Value)
	Starter.kvs.Put(gblConst.PWR_SONOFF_PLUGIN,swSonoff.Value)
	Starter.kvs.Put(gblConst.PWR_SONOFF_IP,txtPrinterIP.Text & "")
	
End Sub


#Region "TEXT FIELD EVENTS"
Private Sub txtPrinterIP_TextChanged (Old As String, New As String)
	If swPSUocto.Value = True Then 
		InvalidateConnection
	End If
End Sub
Private Sub txtPrinterIP_FocusChanged (HasFocus As Boolean)
	If HasFocus Then 
		txtPrinterIP.RequestFocusAndShowKeyboard
	Else
		'--- hide KB?
	End If
End Sub
#End Region


Private Sub ReadSettingsFile

	txtPrinterIP.Text = Starter.kvs.GetDefault(gblConst.PWR_SONOFF_IP,"")
	swSonoff.Value = Starter.kvs.Get(gblConst.PWR_SONOFF_PLUGIN).As(Boolean)
	swPSUocto.Value = Starter.kvs.Get(gblConst.PWR_PSU_PLUGIN).As(Boolean)
	swPsuCtrlOnOff.Value = Starter.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean)

End Sub

Private Sub InvalidateConnection
	txtPrinterIP.mBase.Visible = Not (swPSUocto.Value)
End Sub

'--- only can pick Sonoff or PSU control ---
Private Sub swSonoff_ValueChanged (Value As Boolean)
	swPSUocto.Value = Not (Value)
	InvalidateConnection
End Sub
Private Sub swPSUocto_ValueChanged (Value As Boolean)
	swSonoff.Value = Not (Value)
	InvalidateConnection
End Sub
'--------------------------------------

