﻿Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=3.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Feb/08/2023
#End Region

Sub Class_Globals
	Private Const mModule As String = "OctoSysCmds" 'ignore
	Private oCN As HttpOctoRestAPI
	Private xui As XUI
	
	Public mapShutdown As Map
	Public mapRestart As Map
	Public mapReboot As Map
	'Public mapUserSys As Map
	
End Sub

Public Sub Initialize(cn As HttpOctoRestAPI)
	oCN = cn
End Sub

'===========================================================================

Public Sub GetSysCmds() As ResumableSub 'ignore

	mapReboot.Initialize
	mapShutdown.Initialize
	mapRestart.Initialize
	'mapUserSys.Initialize
	
	Dim rs As ResumableSub
	
	rs =  oCN.SendRequestGetInfo("/api/system/commands/core")
'	[{"action":"shutdown","confirm":"<strong>You are about to shutdown the system.
'	</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints run
'	directly from your printer's internal storage).","name":"Shutdown system","resource":"http://192.168.1.207/api/system/commands/core/shutdown","source":"core"},
'	{"action":"reboot","confirm":"<strong>You are about to reboot the system.
'	</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints
'	run directly from your printer's internal storage).","name":"Reboot system","resource":"http://192.168.1.207/api/system/commands/core/reboot","source":"core"},
'	{"action":"restart","confirm":"<strong>You are about to restart the OctoPrint server.
'	</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints run '
'	directly from your printer's internal storage).","name":"Restart OctoPrint","resource":"http://192.168.1.207/api/system/commands/core/restart","source":"core"},
'	{"action":"restart_safe","confirm":"<strong>You are about to restart the OctoPrint server in safe mode.
'	</strong></p><p>This action may disrupt any ongoing print jobs (depending on your printer's controller and general setup that might also apply to prints run '
'	directly from your printer's internal storage).","name":"Restart OctoPrint in safe mode","resource":"http://192.168.1.207/api/system/commands/core/restart_safe","source":"core"}]
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then
		ParseMeSys(Result)
	End If
	
'	'--- user sys commands --- 
 '--- PLUGIN NOT WORKING IN DOCKER ----   TODO, SEE 'USER_SYS_CMDS'
'	rs =  oCN.SendRequestGetInfo("/api/system/commands/custom")
'	Wait For(rs) Complete (Result As String)
'	If Result.Length <> 0 Then
'		ParseMeCustom(Result)
'	End If
	
End Sub


Private Sub ParseMeSys(txt As String)
	
	Dim parser As JSONParser
	parser.Initialize(txt)
	
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
			
		Try
			
			Dim m As Map : m.Initialize
			m.Put("confirm", strHelpers.StripHTML(colroot.Get("confirm")))
			m.put("resource",colroot.Get("resource"))
			m.Put("name",colroot.Get("name"))
			
			Dim action As String = colroot.Get("action")
			Select Case action
				Case "shutdown"   		: mapShutdown = objHelpers.CopyMap(m)
				Case "restart" 			: mapRestart    = objHelpers.CopyMap(m)
				Case "reboot" 			: mapReboot	   = objHelpers.CopyMap(m)
				Case "restart_safe"	: ' do nothing
				Case Else
					'--- should never get here but wondering about diff languages??
					logMe.LogIt2("case else: " & action,mModule,"ParseMe")
			End Select
			
			'	Dim action As String = colroot.Get("action")
			'	Dim name As String = colroot.Get("name")
			'	Dim confirm As String = colroot.Get("confirm")
			'	Dim resource As String = colroot.Get("resource")
			'	Dim source As String = colroot.Get("source")
				
			Catch
			logMe.LogIt2(LastException.Message,mModule,"ParseMeSys")
		End Try
			
	Next
	

End Sub


'Private Sub ParseMeCustom(txt As String)
'	
'	Dim parser As JSONParser
'	parser.Initialize(txt)
'	
'	Dim root As List = parser.NextArray
'	Dim m As Map
'	For Each colroot As Map In root
'			
'		Try
'			
'			If colroot.Get("action") = "divider" Then Continue
'			
'			m.Initialize
'			m.Put("confirm", strHelpers.StripHTML(colroot.Get("confirm")))
'			m.put("resource",colroot.Get("resource"))
'			m.Put("name",colroot.Get("name"))
'			m.Put("action",colroot.Get("action"))
'			
'			mapUserSys.Put(colroot.Get("name"),m)
'			
'			Catch
'				logMe.LogIt2(LastException.Message,mModule,"ParseMeCustom")
'			End Try
'			
'		Next
'	
'
'End Sub

'==========================================================

Public Sub Restart()
	oCN.PostRequest2($"${mapRestart.Get("resource") & $"?apikey=${oc.OctoKey}"$}"$,$"{"source": "core", "action": "restart"}"$)
	guiHelpers.Show_toast("Restarting Octoprint... ",3500)
	CallSub(B4XPages.MainPage.oMasterController,"tmrMain_Tick")
End Sub


Public Sub Shutdown()
	oCN.PostRequest2($"${mapShutdown.Get("resource") & $"?apikey=${oc.OctoKey}"$}"$,$"{"source": "core", "action": "shutdown"}"$)
	guiHelpers.Show_toast("Shutting down system... ",3500)
	CallSub(B4XPages.MainPage.oMasterController,"tmrMain_Tick")
End Sub


Public Sub Reboot()
	oCN.PostRequest2($"${mapReboot.Get("resource") & $"?apikey=${oc.OctoKey}"$}"$,$"{"source": "core", "action": "reboot"}"$)
	guiHelpers.Show_toast("Rebooting system... ",3500)
	CallSub(B4XPages.MainPage.oMasterController,"tmrMain_Tick")
End Sub


