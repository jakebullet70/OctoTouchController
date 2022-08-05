Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=3.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	July/3/2022
#End Region
'Class module
'#Event: Connected
'#Event: Closed (Reason As String)
Sub Class_Globals
	Private Const mModule As String = "WebSocketHandler" 'ignore
'	Public ws As WebSocketClient
'	Private CallBack As Object
'	Private EventName As String
End Sub
'
'Public Sub Initialize (vCallback As Object, vEventName As String)
'	CallBack = vCallback
'	EventName = vEventName
'	ws.Initialize("ws")
'End Sub
'
'Public Sub Connect(Url As String)
'	ws.Connect(Url)
'End Sub
'
'Public Sub Close
'	If ws.Connected Then ws.Close
'End Sub
'
''Raises an event on the server. The Event parameter must include an underscore
'Public Sub SendEventToServer(Event As String, Data As Map)
''	Dim m As Map
''	m.Initialize
''	m.Put("type", "event")
''	m.Put("event", Event)
''	m.Put("params", Data)
''	Dim jg As JSONGenerator
''	jg.Initialize(m)
''	ws.SendText(jg.ToString)
'End Sub
'
'Private Sub ws_TextMessage(msg As String)
''	Try
''		Dim jp As JSONParser
''		jp.Initialize(msg)
''		Dim m As Map = jp.NextObject
''		Dim etype As String = m.get("etype")
''		Dim params As List = m.get("value")
''		Dim event As String = m.get("prop")
''		If etype = "runFunction" Then
''			CallSub2(CallBack, EventName & "_" & event, params)
''		End If
''	Catch
''		Log("TextMessage Error: " & LastException)
''	End Try
'End Sub

'Private Sub ws_Connected
'	CallSub(CallBack,  EventName & "_Connected")
'End Sub
'
'Private Sub ws_Closed (Reason As String)
'	CallSub2(CallBack, EventName & "_Closed", Reason)
'End Sub