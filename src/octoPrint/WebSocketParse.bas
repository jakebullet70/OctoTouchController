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
	Public RaiseEventMod As Object = Null
	Public RaiseEventEvent As String = ""
	Public pEvents2Monitor As Map
	Type tOctoEvents(CallbackObj As Object, CallbackSub As String)
	
	
End Sub



Public Sub Initialize
	pEvents2Monitor.Initialize
End Sub

Public Sub EventRemove(name As String)
	If pEvents2Monitor.ContainsKey(name) Then
		pEvents2Monitor.Remove(name)
	End If
End Sub
Public Sub EventAdd(name As String,CallbackObj As Object, CallbackSub As String)
	Dim o As tOctoEvents : o.Initialize
	o.CallbackObj = CallbackObj
	o.CallbackSub = CallbackSub
	EventRemove(name)
	pEvents2Monitor.Put(name,o)	
End Sub


'===========================================================================================
'===========================================================================================
'===========================================================================================

Public Sub ResetRaiseEvent
	RaiseEventEvent = ""
	RaiseEventMod = Null
End Sub


Public Sub Event_Parse(msg As String)
	Log(msg)
	
	Dim parser As JSONParser : parser.Initialize(msg)
	
	Dim root As Map = parser.NextObject
	Dim Event As Map = root.Get("event")
	Dim payload As Map = Event.Get("payload")
	Dim evType As String = Event.Get("type")
	
	If pEvents2Monitor.ContainsKey(evType) = False Then
		#if debug
		Log("*** pEvents2Monitor.ContainsKey(evType) = False")
		Log("*** " & msg)
		#end if
		Return
	End If
	
	Dim o As tOctoEvents = pEvents2Monitor.Get(evType) 'ignore
	
	
	Dim outMsg As Object = Null 'ignore
	Select Case evType
		Case "ZChange"
			'{"event": {"type": "ZChange", "payload": {"new": 5.0, "old": null}}}
			Dim new As Double = payload.Get("new")
			Dim old As String = payload.Get("old")
			new = Round2(new,3)
			If IsNumber(old) Then
				old = Round2(old,3)
			Else
				old = "???"
			End If
			
			outMsg = $"* Old Z=${old} / New Z=${new} *"$
			
			
	End Select
	
	If SubExists(o.CallbackObj,o.CallbackSub) Then
		CallSubDelayed2(o.CallbackObj,o.CallbackSub,outMsg)
	End If

	
End Sub



Public Sub Klippy_Parse(msg As String)
	If config.logREST_API Then logMe.logit2("Klipper msg",mModule,"Klippy_Parse")
	
	'guiHelpers.Show_toast2("[stuff]",3500)
	
'	If msg.Contains("Move out of ") Then
'		'{"plugin": {"plugin": "klipper", "data": {"time": "12:37:32", "type": "log", "subtype": "error", "title": " Move out of range: -3.000 0.000 0.000 [0.000]\n", "payload": " Move out of range: -3.000 0.000 0.000 [0.000]\n"}}}
'		guiHelpers.Show_toast2("Movement out of range",3800)
'		Return
'	End If

'	If msg.Contains("Must home ") Then
'		'{"plugin": {"plugin": "klipper", "data": {"time": "12:51:47", "type": "log", "subtype": "error", "title": " Must home axis first: -2.000 0.000 1.000 [0.000]\n", "payload": " Must home axis first: -2.000 0.000 1.000 [0.000]\n"}}}
'		guiHelpers.Show_toast2("Home printer first",3800)
'		Return
'	End If
	
	Dim parser As JSONParser : parser.Initialize(msg)
	Dim root As Map = parser.NextObject
	Dim plugin As Map = root.Get("plugin")
	'Dim pluginType As String = plugin.Get("plugin")
	Dim data As Map = plugin.Get("data")
	Dim subtype As String = data.Get("subtype")
	Dim payload As String = data.Get("payload").As(String)
	'Dim time As String = data.Get("time")
	Dim msgType As String = data.Get("type") 'ignore
	'Dim title As String = data.Get("title")
	
	'--- live callback for klippy built in interaction commands
	'--- this will process ALL klippy events if event callback is set
	If RaiseEventMod <> Null Then
		If msgType = "log" Then
			If SubExists(RaiseEventMod,RaiseEventEvent) Then
				CallSubDelayed2(RaiseEventMod,RaiseEventEvent,payload) 'ignore
				Return
			End If
		Else
			Return
		End If
	End If
	
	'--- no event callback set so process
	Dim payloadU As String = payload.ToUpperCase
	Select Case True
		
		Case payloadU.Contains("SHUTDO") '--- printer off or klipper diconnected?
			If B4XPages.MainPage.oPageCurrent <> B4XPages.MainPage.oPageMenu Then
				'--- back to main page if page is anything else
				CallSub(B4XPages.MainPage,"btnPageAction_Click") 
				guiHelpers.Show_toast2("Klipper disconnect... Check printer",3500)
			End If
			
			Case payloadU.Contains("E: READY")
				guiHelpers.Show_toast2("Klipper ready",3500)
				
			Case Else
				Try
					If msgType = "status" Or subtype = "error" Then
						'--- brackets are blowing up the toast msg : [] are used as a parse for a list
						'--- https://www.b4x.com/android/forum/threads/b4x-bctextengine-bbcodeview-text-engine-bbcode-parser-rich-text-view.106207/
						guiHelpers.Show_toast2(payload.Replace(CRLF,"").Replace("[","{").Replace("]","}"),3500)
					End If
				Catch
					Log(LastException)
				End Try
	End Select

		
End Sub
