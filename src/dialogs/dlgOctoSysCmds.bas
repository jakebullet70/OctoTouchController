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
	
	Private popUpMnu As Map
	
	Private oOctoCmds As OctoSysCmds
End Sub


Public Sub Initialize(cn As HttpOctoRestAPI) As Object
	mMainObj = B4XPages.MainPage
	oOctoCmds.Initialize(cn)
	Return Me
End Sub


Public Sub Show
	
	'--- grab avail the octo sys commands
	Wait For (oOctoCmds.GetSysCmds) Complete() 'ignore
	
	'--- show info about setting up octoprint permissions
	If Main.kvs.GetDefault("sysWarning",False).As(Boolean) = False Then
		Dim mb As dlgMsgBox
		mb.Initialize(mMainObj.root,"Information",IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth-40dip),260dip,False)
		mb.SetAsOptionalMsgBox("sysWarning")
		Dim gui As guiMsgs : gui.Initialize
		Wait For (mb.Show(gui.GetOctoSysCmdsWarningTxt, _
						gblConst.MB_ICON_INFO,"","","OK")) Complete (Result As Int)
	End If
	
	If BuildMenu = 0 Then
		Dim mb As dlgMsgBox
		Dim h,w As Float
		Dim txt As String = "System commands are not configured " & CRLF & "or system is turned off."
		h = 200dip
		If guiHelpers.gIsLandScape Then
			w = 500dip
		Else
			txt = strHelpers.WordWrap(txt,24) ' TODO - this word wrap seesm to have an issue and needs revisiting
			w = guiHelpers.gWidth-40dip
		End If
		mb.Initialize(mMainObj.root,"Warning",w,h,False)
		Wait For (mb.Show(txt, gblConst.MB_ICON_INFO,"","","OK")) Complete (Result As Int)
		Return
	End If
	
	Dim o1 As dlgListbox
	mMainObj.pObjCurrentDlg2 = o1.Initialize("System Menu",Me,"SysMenu_Event",mMainObj.pObjCurrentDlg2)
	o1.IsMenu = True
	If guiHelpers.gIsLandScape Then '- TODO needs refactor for sizes
		o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,320dip,280dip),280dip,popUpMnu)
	Else
		o1.Show(IIf(guiHelpers.gScreenSizeAprox > 6.5,436dip,340dip),280dip,popUpMnu)
	End If
	
End Sub


Private Sub SysMenu_Event(value As String, tag As Object)
	
	If value.Length = 0 Then Return
	
	Select Case value
			
		Case "ro"  '--- restart octo
			Wait For (AskThem(oOctoCmds.mapRestart.Get("confirm"),"RESTART","restart Octoprint")) Complete (ret As Int)
			If ret <> xui.DialogResponse_Cancel Then oOctoCmds.Restart
			
		Case "sd" '--- shutdown
			Wait For (AskThem(oOctoCmds.mapShutdown.Get("confirm"),"SHUTDOWN","shutdown the computer")) Complete (ret As Int)
			If ret <> xui.DialogResponse_Cancel Then oOctoCmds.Shutdown
			
		Case "rb" '--- reboot
			Wait For (AskThem(oOctoCmds.mapReboot.Get("confirm"),"REBOOT","reboot the computer")) Complete (ret As Int)
			If ret <> xui.DialogResponse_Cancel Then oOctoCmds.Reboot
			
	End Select
	
End Sub


Private Sub BuildMenu() As Int
	
	popUpMnu.Initialize
	
	If oOctoCmds.mapRestart.Size 		<> 0 Then popUpMnu.Put("Restart Octoprint","ro")
	If oOctoCmds.mapReboot.Size 		<> 0 Then popUpMnu.Put("Reboot System","rb")
	If oOctoCmds.mapShutdown.Size 	<> 0 Then popUpMnu.Put("Shutdown System","sd")
	
	'--- PLUGIN NOT WORKING IN DOCKER ----   TODO, Search for 'USER_SYS_CMDS'
'	If oOctoCmds.mapUserSys.Size <> 0 Then 
'		If oOctoCmds.mapReboot.Size <> 0 Or oOctoCmds.mapRestart.Size <> 0 Or oOctoCmds.mapShutdown.Size <> 0 Then
'			popUpMnu.Put(" ------------------------- ","")
'		End If
'		For xx = 0 To oOctoCmds.mapUserSys.Size - 1
'			popUpMnu.Put("Shutdown System","custom-" & oOctoCmds.mapUserSys.GetKeyAt(xx))
'		Next
'	End If
	
	Return popUpMnu.Size
	
End Sub
	
Private Sub AskThem(txt As String,btnText As String, promptTxt As String) As ResumableSub
	Dim s As StringBuilder : 	s.Initialize
	s.Append($"You are about to ${promptTxt}."$)
	s.Append("This action may disrupt any print jobs ")
	s.Append("that are currently running. Do you wish to continue?")
	txt = s.ToString '--- not using the octoprint prompt text at this moment - its BIG
	Dim mb As dlgMsgBox
	Dim w,h As Float
	If guiHelpers.gIsLandScape Then
		w = 80%x : h = 80%y
		txt = strHelpers.WordWrap(txt,42)
	Else
		w = 96%x : h = 56%y
		txt = strHelpers.WordWrap(txt,32)
	End If
	mb.Initialize(mMainObj.Root,"Question", w, h,False)
	Wait For (mb.Show(txt, gblConst.MB_ICON_WARNING,"",btnText,"CANCEL")) Complete (res As Int)
	Return res
	
End Sub


'#if (klipper)
'
'Public Sub ServerRestart
'	mMainObj.oMasterController.cn.PostRequest(oc.cPOST_GCODE.Replace("!G!","G28 X Y"))
'End Sub
'
'
'
'#End If