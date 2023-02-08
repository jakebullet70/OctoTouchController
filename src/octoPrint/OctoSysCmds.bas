Group=OCTOPRINT
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
	Private XUI As XUI
	
	Public mapShutdown As Map
	Public mapRestart As Map
	Public mapReboot As Map
	
End Sub

Public Sub Initialize(cn As HttpOctoRestAPI)
	oCN = cn
	GetSysCmds
End Sub

'===========================================================================


'===========================================================================

'Public Sub IsSysCmdsAvail() As Boolean
'	Try
'		Return mapShutdown.Size.As(Boolean)
'	Catch
'		'Log(LastException)
'	End Try 'ignore
'	Return False
'End Sub


Public Sub GetSysCmds 'ignore

	mapReboot.Initialize
	mapShutdown.Initialize
	mapRestart.Initialize
	
	Dim rs As ResumableSub =  oCN.SendRequestGetInfo("/api/system/commands/core")
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
		ParseMe(Result)
	End If
	
End Sub

Private Sub ParseMe(txt As String)
	
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
				logMe.LogIt2(LastException.Message,mModule,"ParseMe")
			End Try
			
		Next
	

End Sub

