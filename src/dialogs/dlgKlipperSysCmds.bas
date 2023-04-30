B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Apr/15/2023
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgKlipperSysCmds"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private pnlMain As B4XView
	Private mDialog As B4XDialog
	
	Private btnOff,btnOn As Button
	Public mIPaddr As String
	
End Sub

Public Sub Initialize(mobj As B4XMainPage) As Object
	
	If mobj = Null Then Return Null
	mMainObj = mobj
	Return Me
	
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
	p.LoadLayout("viewPsuCtrl") '--- use this, its just 2 btns
	
	BuildGUI

	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	dlgHelper.ThemeDialogForm("Host Control")
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
	guiHelpers.SkinButton(Array As Button(btnOff,btnOn))

	Dim cs As CSBuilder
	
	btnOff.Text = cs.Initialize.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Size(36).Append(Chr(0xF1DA)). _
											 Typeface(Typeface.DEFAULT).Size(28).Append("     Reboot").PopAll
	btnOn.Text  = cs.Initialize.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Size(34).Append(Chr(0xF011)). _
											 Typeface(Typeface.DEFAULT).Size(28).Append("    Shutdown").PopAll
	
	guiHelpers.SetTextSize(Array As Button(btnOff,btnOn),18)
					
	
End Sub


Private Sub btnCtrl_Click
	
	Dim o As B4XView : o = Sender
	If o.Text.SubString2(0,1) = "R" Then
		mMainObj.oMasterController.cn.PostRequest("/machine/reboot")
		guiHelpers.Show_toast("Sending Reboot Command",1500)
	Else
		mMainObj.oMasterController.cn.PostRequest("/machine/shutdown")
		guiHelpers.Show_toast("Sending Shutdown Command",1500)
	End If
	
End Sub





