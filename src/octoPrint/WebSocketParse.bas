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
	Public pMsgs2Monitor As Map
	Type tOctoEvents(CallbackObj As Object, CallbackSub As String)
	
		
End Sub



Public Sub Initialize
	pEvents2Monitor.Initialize
	pMsgs2Monitor.Initialize
	
End Sub


'---------------------------------------------------------------------------------------
'--- tracks octo events
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

Public Sub Event_Parse(msg As String)
	Log(msg)
	
	Dim parser As JSONParser : parser.Initialize(msg)
	
	Dim root As Map = parser.NextObject
	Dim Event As Map = root.Get("event")
	Dim payload As Map = Event.Get("payload")
	Dim evType As String = Event.Get("type")
	
	If pEvents2Monitor.ContainsKey(evType) = False Then
		#if debug
		'Log("*** pEvents2Monitor.ContainsKey(evType) = False")
		'Log("*** " & msg)
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
			
		Case "MetadataAnalysisFinished"
			'fileHelpers.WriteTxt2SharedFolder("newfile.txt",msg)
			outMsg = msg	
				
		Case "FilamentChange"
			outMsg = "" '{"event": {"type": "FilamentChange", "payload": null}}
		
		Case "PrintStarted","PrintFailed","FileRemoved"
			outMsg = msg
		
	End Select
	
	If SubExists(o.CallbackObj,o.CallbackSub) Then
		CallSubDelayed2(o.CallbackObj,o.CallbackSub,outMsg)
	End If

	
End Sub

'---------------------------------------------------------------------------------------



'--- tracks returns of M GCode commands
Public Sub MsgsRemove(name As String)
	If pMsgs2Monitor.ContainsKey(name) Then
		pMsgs2Monitor.Remove(name)
	End If
End Sub
Public Sub MsgsAdd(name As String,CallbackObj As Object, CallbackSub As String)
	Dim o As tOctoEvents : o.Initialize
	o.CallbackObj = CallbackObj
	o.CallbackSub = CallbackSub
	MsgsRemove(name)
	pMsgs2Monitor.Put(name,o)
End Sub

Public Sub Msgs_Parse(msg As String)
	
	'Log(msg)
	
	Dim parser As JSONParser : parser.Initialize(msg)
	Dim root As Map = parser.NextObject
	Dim current As Map = root.Get("current")
	Dim messages As List = current.Get("messages")
	
	For Each msgkey As String In pMsgs2Monitor.keys
		For Each colmessages As String In messages
			If colmessages.Contains(msgkey) Then
				Dim o As tOctoEvents = pMsgs2Monitor.Get(msgkey)
				If SubExists(o.CallbackObj,o.CallbackSub) Then
					CallSubDelayed2(o.CallbackObj,o.CallbackSub,colmessages)
				End If
			End If
		Next
	Next
	
End Sub
'---------------------------------------------------------------------------------------




'===========================================================================================
'===========================================================================================
'===========================================================================================

'--- Generic event handler
Public Sub ResetRaiseEvent
	RaiseEventEvent = ""
	RaiseEventMod = Null
End Sub







Public Sub Klippy_Parse(msg As String)
	If config.logREST_API Then logMe.logit2("Klipper msg",mModule,"Klippy_Parse")
	
	
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






'Private Sub ReturnMsg(txt As String) As String
'	Dim parser As JSONParser : parser.Initialize(txt)
'	Dim root As Map = parser.NextObject
'	Dim current As Map = root.Get("current")
'''	Dim busyFiles As List = current.Get("busyFiles")
'''	Dim markings As List = current.Get("markings")
'''	Dim offsets As Map = current.Get("offsets")
'''	Dim progress As Map = current.Get("progress")
'''	Dim printTimeLeft As String = progress.Get("printTimeLeft")
'''	Dim completion As String = progress.Get("completion")
'''	Dim filepos As String = progress.Get("filepos")
'''	Dim printTimeOrigin As String = progress.Get("printTimeOrigin")
'''	Dim printTime As String = progress.Get("printTime")
'	Dim messages As List = current.Get("messages")
'	Return strHelpers.Join("!!!",messages)
''	For Each colmessages As String In messages
''	Next
''	Dim currentZ As String = current.Get("currentZ")
''	Dim serverTime As Double = current.Get("serverTime")
''	Dim state As Map = current.Get("state")
''	Dim flags As Map = state.Get("flags")
''	Dim finishing As String = flags.Get("finishing")
''	Dim paused As String = flags.Get("paused")
''	Dim pausing As String = flags.Get("pausing")
''	Dim resuming As String = flags.Get("resuming")
''	Dim ready As String = flags.Get("ready")
''	Dim sdReady As String = flags.Get("sdReady")
''	Dim operational As String = flags.Get("operational")
''	Dim closedOrError As String = flags.Get("closedOrError")
''	Dim error As String = flags.Get("error")
''	Dim cancelling As String = flags.Get("cancelling")
''	Dim printing As String = flags.Get("printing")
''	Dim text As String = state.Get("text")
''	Dim error As String = state.Get("error")
''	Dim resends As Map = current.Get("resends")
''	Dim count As Int = resends.Get("count")
''	Dim transmitted As Int = resends.Get("transmitted")
''	Dim ratio As Int = resends.Get("ratio")
''	Dim job As Map = current.Get("job")
''	Dim File As Map = job.Get("file")
''	Dim date As String = File.Get("date")
''	Dim path As String = File.Get("path")
''	Dim size As String = File.Get("size")
''	Dim origin As String = File.Get("origin")
''	Dim name As String = File.Get("name")
''	Dim lastPrintTime As String = job.Get("lastPrintTime")
''	Dim estimatedPrintTime As String = job.Get("estimatedPrintTime")
''	Dim filament As Map = job.Get("filament")
''	Dim volume As String = filament.Get("volume")
''	Dim length As String = filament.Get("length")
''	Dim user As String = job.Get("user")
''	Dim temps As List = current.Get("temps")
''	Dim logs As List = current.Get("logs")
'
'End Sub
