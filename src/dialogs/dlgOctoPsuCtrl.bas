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
	
	Private const mModule As String = "dlgOctoPsuCtrl"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private pnlMain As B4XView
	Private mDialog As B4XDialog
	
	Private mPSU_Type As String = ""
	
	Private btnOff,btnOn As Button
	Public mIPaddr As String
	
End Sub

'--- Dual class, GUI and command

Public Sub Initialize(mobj As B4XMainPage)
	
	If mobj = Null Then Return
	mMainObj = mobj
	ReadSettingsCfg
	
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
	p.LoadLayout("viewPsuCtrl")
	
	BuildGUI

	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	dlgHelper.ThemeDialogForm("Power Control")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CLOSE")
	dlgHelper.ThemeInputDialogBtnsResize
	
	If oc.Tool1ActualReal > 50 Then
		CallSubDelayed3(B4XPages.MainPage,"Show_Toast", "Warning! Tool Temperature Is Hot", 4300)
	End If

	Wait For (rs) Complete (Result As Int)
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
	'--- timer might be off, make sure it is on
	'CallSub2(Main,"TurnOnOff_MainTmr",True)
	
	
End Sub



Private Sub BuildGUI
	
	pnlMain.Color = clrTheme.Background
	'guiHelpers.SetEnableDisableColor(Array As B4XView(btnOff,btnOn))
	guiHelpers.SkinButton(Array As Button(btnOff,btnOn))

	Dim cs As CSBuilder
	cs.Initialize
	btnOff.Text = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(3dip).Append(Chr(0xF204)). _
											 Typeface(Typeface.DEFAULT).Append("    Off").PopAll
	cs.Initialize
	btnOn.Text  = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(3dip).Append(Chr(0xF205)). _
											 Typeface(Typeface.DEFAULT).Append("    On").PopAll
	
	guiHelpers.SetTextSize(Array As Button(btnOff,btnOn), _
					NumberFormat2(btnOff.TextSize / guiHelpers.gFscale,1,0,0,False) - IIf(guiHelpers.gFscale > 1,2,0))
	
End Sub


Public Sub ReadSettingsCfg

	mIPaddr = Main.kvs.GetDefault(gblConst.PWR_SONOFF_IP,"")
	If Main.kvs.Get(gblConst.PWR_SONOFF_PLUGIN).As(Boolean) = True Then
		mPSU_Type = "sonoff"
	Else
		mPSU_Type = "octo_k"
	End If

End Sub


Private Sub btnCtrl_Click
	
	Dim o As B4XView : o = Sender
	Wait For (SendCmd(o.Tag)) Complete(s As String)
	mDialog.Close(-1) '--- close it, exit dialog
	
End Sub


Public Sub SendCmd(cmd As String)As ResumableSub'ignore

	Dim msg As String = $"Sending Power '${cmd.ToUpperCase}' Command"$
	
	Select Case mPSU_Type
		Case "sonoff"
			If mIPaddr = "" Then 
				guiHelpers.Show_toast("Missing SonOff IP address",2000)
				Return 'ignore
			End If
			Dim sm As HttpDownloadStr : sm.Initialize
			Wait For (sm.SendRequest($"http://${mIPaddr}/cm?cmnd=Power%20${cmd}"$)) Complete(s As String)
			
		Case "octo_k"
			If oc.isConnected Then
				mMainObj.oMasterController.cn.PostRequest( _
					oc.cPSU_CONTROL_K.Replace("!ONOFF!",IIf(cmd.ToLowerCase ="on","On","Off")))
			Else
				guiHelpers.Show_toast2("Octoprint not connected", 2000)
			End If
		
		Case Else
			msg = "PSU control config problem"
			
	End Select
	
	If cmd.ToLowerCase = "off" Then
		'---printer off, back to main menu
		If mMainObj.oPageCurrent <> mMainObj.oPageMenu Then
			CallSub2(mMainObj,"Switch_Pages",gblConst.PAGE_MENU)
		End If
	End If
	
	guiHelpers.Show_toast(msg,1500)
	
End Sub





