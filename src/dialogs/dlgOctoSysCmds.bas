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
	
	Private const mModule As String = "dlgOctoSysCmds"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private pnlMain As B4XView
	Private mDialog As B4XDialog
	
	Private btn1,btn2,btn3 As Button
	Private oOctoCmds As OctoSysCmds
	
End Sub


Public Sub Initialize(mobj As B4XMainPage,cn As HttpOctoRestAPI)
	mMainObj = mobj
	oOctoCmds.Initialize(cn)
End Sub


Public Sub Show
	
	'--- show info about setting octoprint plugins first TODO, same code as in dlgPsuSetup
	If Starter.kvs.GetDefault("sysWarning",False).As(Boolean) = False Then
		Dim mb As dlgMsgBox
		mb.Initialize(mMainObj.root,"Information",IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth-40dip),260dip,False)
		mb.SetAsOptionalMsgBox("sysWarning")
		Dim gui As guiMsgs : gui.Initialize
		Wait For (mb.Show(gui.GetOctoSysCmdsWarningTxt, _
		gblConst.MB_ICON_INFO,"","","OK")) Complete (Result As Int)
	End If
	
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
	p.LoadLayout("viewOctoSysCmds")
	
	BuildGUI

	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	dlgHelper.ThemeDialogForm("System Commands")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CLOSE")
	dlgHelper.ThemeInputDialogBtnsResize
	
	Wait For (rs) Complete (Result As Int)
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub



Private Sub BuildGUI
	
	pnlMain.Color = clrTheme.Background
	guiHelpers.SkinButton(Array As Button(btn1,btn2,btn3))

	Dim cs As CSBuilder
	cs.Initialize
	btn1.Text = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(2dip).Append(Chr(0xF085)). _
											 Typeface(Typeface.DEFAULT).Append("    Restart Octoprint").PopAll
	cs.Initialize
	btn2.Text  = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(2dip).Append(Chr(0xF144)). _
											 Typeface(Typeface.DEFAULT).Append("     Reboot System").PopAll
	cs.Initialize
	btn3.Text  = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(2dip).Append(Chr(0xF1E6)). _
											 Typeface(Typeface.DEFAULT).Append("  Shutdown System").PopAll
	
'	guiHelpers.SetTextSize(Array As Button(btn1,btn2,btn3), _
'					NumberFormat2(btn1.TextSize / guiHelpers.gFscale,1,0,0,False) - IIf(guiHelpers.gFscale > 1,2,0))
'	
End Sub


Private Sub btnCtrl_Click
	
	Dim o As B4XView : o = Sender
	Dim ret As Int
	
	Select Case True
		Case o.Text.Contains("estart") '--- restart
			If oOctoCmds.mapRestart.Size <> 0 Then 
				Wait For (AskThem(oOctoCmds.mapRestart.Get("confirm"),"RESTART")) Complete (ret As Int)
				If ret <> xui.DialogResponse_Cancel Then 
					oOctoCmds.Restart
				End If
			End If
			
		Case o.Text.Contains("hutdo") 	'--- shutdown
			If oOctoCmds.mapRestart.Size <> 0 Then
				Wait For (AskThem(oOctoCmds.mapShutdown.Get("confirm"),"SHUTDOWN")) Complete (ret As Int)
				If ret <> xui.DialogResponse_Cancel Then
					oOctoCmds.Shutdown
				End If
			End If
			
		Case o.Text.Contains("eboot") '--- reboot
			If oOctoCmds.mapRestart.Size <> 0 Then
				Wait For (AskThem(oOctoCmds.mapReboot.Get("confirm"),"REBOOT")) Complete (ret As Int)
				If ret <> xui.DialogResponse_Cancel Then
					oOctoCmds.Reboot
				End If
			End If
			
	End Select
	
	mDialog.Close(-1) '--- close it, exit dialog
	
End Sub


	
	
Private Sub AskThem(txt As String,btnText As String) As ResumableSub
	Dim formatedTxt As String
	Dim mb As dlgMsgBox
	Dim w,h As Float
	If guiHelpers.gIsLandScape Then
		w = 80%x : h = 80%y
		formatedTxt = strHelpers.InsertCRLF(txt,90)
	Else
		w = 94%x : h = 60%y
		formatedTxt = strHelpers.InsertCRLF(txt,70)
	End If
	mb.Initialize(mMainObj.Root,"Question", w, h,False)
	Wait For (mb.Show(formatedTxt, gblConst.MB_ICON_WARNING,"",btnText,"CANCEL")) Complete (res As Int)
	Return res
	
End Sub


