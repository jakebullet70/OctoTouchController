B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/24/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgFilamentCtrl"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private mDialog As B4XDialog
	
	
	Private fUnloadLen As Int
	Private fUnloadSpeed As Int
	Private fLoadLen As Int
	Private fLoadSpeed As Int
	Private fPauseBeforePark As Boolean
	Private fRetractBeforePark As Boolean
	Private fHomeBeforePark As Boolean
	Private fXPark As Int
	Private fYPark As Int
	Private fZLift As Boolean
	Private fParkSpeed As Int
	
	Private pnlMain As B4XView
End Sub


Public Sub Initialize(mobj As B4XMainPage)
	
	mMainObj = mobj
	ReadSettingsCfg
	
End Sub


Public Sub Show(LoadUnload As String)
	
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
	p.LoadLayout("viewFilamentCtrl")
	Build_GUI 

	guiHelpers.ThemeDialogForm(mDialog, LoadUnload & " Filament")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	Wait For (rs) Complete (Result As Int)
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
	'--- timer might be off, make sure it is on
	'CallSub2(Main,"TurnOnOff_MainTmr",True)
	
	
End Sub



private Sub Build_GUI
	
	pnlMain.Color = clrTheme.BackgroundMenu
	'guiHelpers.SetEnableDisableColor(Array As B4XView(btnOff,btnOn))
	
	
End Sub


Public Sub ReadSettingsCfg

'	mIPaddr = Starter.kvs.GetDefault(gblConst.PWR_SONOFF_IP,"")
'	If Starter.kvs.Get(gblConst.PWR_SONOFF_PLUGIN).As(Boolean) = True Then
'		mPSU_Type = "sonoff"
'	Else
'		mPSU_Type = "octo_k"
'	End If

End Sub


Private Sub btnCtrl_Click
	
	Dim o As B4XView : o = Sender
	Wait For (SendCmd(o.Tag)) Complete(s As String)
	mDialog.Close(-1) '--- close it, exit dialog
	
End Sub


Public Sub SendCmd(cmd As String)As ResumableSub'ignore

'	Dim msg As String = $"Sending Power '${cmd.ToUpperCase}' Command"$
'	
'	Select Case mPSU_Type
'		Case "sonoff"
'			If mIPaddr = "" Then 
'				guiHelpers.Show_toast("Missing SonOff IP address",2000)
'				Return 'ignore
'			End If
'			Dim sm As HttpDownloadStr : sm.Initialize
'			Wait For (sm.SendRequest($"http://${mIPaddr}/cm?cmnd=Power%20${cmd}"$)) Complete(s As String)
'			
'		Case "octo_k"
'			mMainObj.oMasterController.cn.PostRequest( _
'				oc.cPSU_CONTROL_K.Replace("!ONOFF!",IIf(cmd.ToLowerCase ="on","On","Off")))
'		
'		Case Else
'			msg = "PSU control config problem"
'			
'	End Select
'	
'	If cmd.ToLowerCase = "off" Then
'		'---printer off, back to main menu
'		If mMainObj.oPageCurrent <> mMainObj.oPageMenu Then
'			CallSub2(mMainObj,"Switch_Pages",gblConst.PAGE_MENU)
'		End If
'	End If
'	
'	guiHelpers.Show_toast(msg,1500)
	
End Sub





