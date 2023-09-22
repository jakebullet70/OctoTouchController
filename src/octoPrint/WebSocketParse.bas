B4A=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/21/2023
#End Region

#Region EVENTS' DECLARATIONS 
'#Event: Complete (result As object, success as object)
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "WebSocketParse" 'ignore
	
End Sub


Public Sub Initialize
End Sub

'===========================================================================================
'===========================================================================================
'===========================================================================================


Public Sub Klippy_Parse(msg As String)
	
	'{"plugin": {"plugin": "klipper", "data": {"time": "07:03:25", "type": "log", "subtype": "info", "title": " Klipper state: Ready\n", 
	'"payload": " Klipper state: Ready\n"}}}
	If msg.Contains("Move out of ") Then
		'{"plugin": {"plugin": "klipper", "data": {"time": "12:37:32", "type": "log", "subtype": "error", "title": " Move out of range: -3.000 0.000 0.000 [0.000]\n", "payload": " Move out of range: -3.000 0.000 0.000 [0.000]\n"}}}
		guiHelpers.Show_toast2("Movement out of range",3800)
		Return
	End If

	If msg.Contains("Must home ") Then
		'{"plugin": {"plugin": "klipper", "data": {"time": "12:51:47", "type": "log", "subtype": "error", "title": " Must home axis first: -2.000 0.000 1.000 [0.000]\n", "payload": " Must home axis first: -2.000 0.000 1.000 [0.000]\n"}}}
		guiHelpers.Show_toast2("Home printer first",3800)
		Return
	End If
	'klippy pligin msg: {"plugin": {"plugin": "klipper", "data": {"time": "12:42:22", "type": "log", "subtype": "info", "title": " Unknown command:\"PROBE\"\n", "payload": " Unknown command:\"PROBE\"\n"}}}
End Sub
