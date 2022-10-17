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
	
	Private const mModule As String = "dlgOnOffCtrl"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mTitle As String
	
	Private pnlMain As B4XView
	Private mDialog As B4XDialog
	
	Private btnOff,btnOn As B4XView
	Public mIPaddr As String
	
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
	p.LoadLayout("viewPsuCtrl") '--- use this one
	
	pnlMain.Color = clrTheme.Background
	guiHelpers.SetEnableDisableColor(Array As B4XView(btnOff,btnOn))
	btnOff.Text= "Off"
	btnOn.Text = "On"

	guiHelpers.ThemeDialogForm(mDialog, mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	Wait For (rs) Complete (Result As Int)
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
	'--- timer might be off, make sure it is on
	'CallSub2(Main,"TurnOnOff_MainTmr",True)
	
	
End Sub



Private Sub btnCtrl_Click
	
	Dim o As B4XView : o = Sender
	Wait For (SendCmd(o.Tag)) Complete(s As String)
	mDialog.Close(-1) '--- close it, exit dialog
	
End Sub

Public Sub SendCmd(cmd As String)As ResumableSub'ignore
	
	Dim Data As Map
	Dim template As String = $"!ep!!!{"command":"!of!"}"$ '--- POST
	
	Select Case True
			
		Case mTitle.ToLowerCase.Contains("zle")
			Data = File.ReadMap(xui.DefaultFolder,gblConst.ZLED_OPTIONS_FILE)
			
		Case mTitle.ToLowerCase.Contains("ws2")
			Data = File.ReadMap(xui.DefaultFolder,gblConst.WS281_OPTIONS_FILE)
			
	End Select
	
	template = template.Replace("!ep!",Data.Get(gblConst.ZLED_ENDPOINT)). _
						Replace("!of!", _
						IIf(cmd = "on",Data.Get(gblConst.ZLED_cmd_on),Data.Get(gblConst.ZLED_CMD_OFF)))
						
	LogColor(template,xui.Color_Green)
	mMainObj.oMasterController.cn.PostRequest(template)

End Sub



'Private Sub PSUcmd(cmd As String)
'
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
'		
'End Sub
