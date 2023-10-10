B4A=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
Sub Class_Globals
	Private Const mModule As String = "OctoWebSocket" 'ignore
	
'	Private mIP As String 'ignore
'	Private mPort As String 'ignore
'	Private mKey As String
	
	Public wSocket As WebSocket
	Public mErrorSecProvider As Boolean = False
	Public pClosedReason As String
	Public pConnected As Boolean = False
	
	Public IsInit As Boolean = False
	Public mIgnoreMasterOctoEvent As Boolean = True
	Public pParserWO As WebSocketParse
	Public subscribe As String = $"{"subscribe": {"plugins": ["klipper"]  }}"$
	
	Private isConnecting As Boolean = False
	Public mlastMsg As String
	Public bLastMessage As Boolean = False
	
End Sub

'#Event: RecievedText
'#Event: Closed
'#Event: Connected

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
'	mPort = oc.OctoPort = IIf(strHelpers.IsNullOrEmpty(oc.OctoPort),"80",port) '--- TODO if port is null then should popup connect dialog, should never happen but did! LOL
'	mIP = ip
'	mKey = key
	pParserWO.Initialize
	IsInit = True
End Sub

Private Sub DisableStrictMode
	Dim InSub As String = "DisableStrictMode"
	logMe.LogIt2("Start",mModule,InSub)
	Dim jo As JavaObject
	jo.InitializeStatic("android.os.Build.VERSION")
	If jo.GetField("SDK_INT") > 9 Then
		Dim policy As JavaObject
		policy = policy.InitializeNewInstance("android.os.StrictMode.ThreadPolicy.Builder", Null)
		policy = policy.RunMethodJO("permitAll", Null).RunMethodJO("build", Null)
		Dim sm As JavaObject
		sm.InitializeStatic("android.os.StrictMode").RunMethod("setThreadPolicy", Array(policy))
		logMe.LogIt2("Done",mModule,InSub)
	Else
		logMe.LogIt2("Skipped < Android 9",mModule,InSub)
	End If
End Sub

Public Sub ProviderInstall() As ResumableSub
	Dim InSub As String = "ProviderInstall"
	logMe.LogIt2("Start",mModule,InSub)
	'--- Android 4.x SSL stuff
	'https://www.b4x.com/android/forum/threads/websocket-client-library.40221/#content
	'https://www.b4x.com/android/forum/threads/ssl-websocket-client.88472/
	Dim jo As JavaObject
	jo.InitializeStatic("com.google.android.gms.security.ProviderInstaller")
	Dim context As JavaObject
	context.InitializeContext
	DisableStrictMode
	Dim listener As Object = _
		jo.CreateEventFromUI("com.google.android.gms.security.ProviderInstaller.ProviderInstallListener", "listener", Null)
	Log("Installing security provider if needed...")
	jo.RunMethod("installIfNeededAsync", Array(context, listener))
	Wait For listener_Event (MethodName As String, Args() As Object)
	If MethodName = "onProviderInstalled" Then
		logMe.LogIt2("Provider installed successfully",mModule,InSub)
	Else
		logMe.LogIt2("Error installing provider: " & Args(0),mModule,InSub)
		mErrorSecProvider = True
	End If
	Return mErrorSecProvider
	
End Sub

'=========================================================================
'=========================================================================
'=========================================================================

'ws://192.168.1.193:80/websocket?apikey=D009C78831ED4A25A9E48D2EC3538261

Public Sub Connect() As ResumableSub
	'--- we wont ever run this code if the REST API fails
	Dim inSub As String = "Connect"
	Log("wb start")
	If isConnecting = True Then 
		Log("WS already trying to connect")
		Return ""
	End If
	isConnecting = True
	
	Dim Const thisSub As String	= "Connect"
	Try
		If wSocket.Connected Then 
			If config.logREST_API Then logMe.logit2("wSocket is already connected",mModule,inSub)
			Return ""
		End If
	Catch
		'Log(LastException)
	End Try'ignore

	logMe.LogIt2("WS connecting...",mModule,thisSub)
	pConnected = False '--- assume bad
	
	'--- Init the socket
	wSocket.Initialize("ws")
	wSocket.Connect($"ws://${oc.OctoIp}:${oc.OctoPort}/sockjs/websocket?apikey=${oc.OctoKey}"$)
	Wait For ws_Connected
	logMe.LogIt2("WS connected...",mModule,thisSub)
	Wait For ws_TextMessage (Message As String)
	pConnected = True
	Log("wb init end")
	
	'--- set subscriptions
	Dim subscribe As String = $"{"subscribe": {
				  "state": {
			      "logs": false,
			      "messages": true},
			      "events": true,
				  "plugins": ["OctoKlipper","klipper"]
				  }}"$
	
	
	
	'Log(subscribe.Replace(CRLF," "))
	Send(subscribe)
	
'	--- Set the AUTH And start socket events
	Wait For (Passive_Login) Complete(i As Boolean)
	Log("Passive login:" & i.As(String))
		
	'--- A value of 2 will set the rate limit to maximally one message every 1s, 3 to maximally one message every 1.5s and so on.
	setThrottle("90") '--- this is very inacurate
	isConnecting = False
	Return Message '--- this is the connected message
	
End Sub


Public Sub Passive_Login() As ResumableSub
	Dim inSub As String = "Passive_Login"
	'--- called when REST commands are fulling working from MasterController
	'--- this might need to be called again if 'reauthRequired' is recieved
	If config.logREST_API Then logMe.logit2("Passive_Login start",mModule,inSub)
	Wait For (B4XPages.MainPage.oMasterController.CN.PostRequest($"/api/login!!{ "passive": "true" }"$)) Complete (r As String)
	If strHelpers.IsNullOrEmpty(r) Then
		Return False
	End If
	Dim parser As JSONParser : parser.Initialize(r) : Dim root As Map = parser.NextObject
	Send($"{"auth": "${root.Get("name")}:${root.Get("session")}"}"$)
	If config.logREST_API Then logMe.logit2("Passive_Login Auth end",mModule,inSub)
	Return True
End Sub


Public Sub setThrottle(num As String)
	Send($"{"throttle": ${num}}"$)
	If config.logREST_API Then logMe.logit2("WebSocket throttle: " & num ,mModule,"setThrottle")
End Sub

'--- master msg event method
Private Sub ws_TextMessage(Message As String)
	
	#if debug
	If bLastMessage Then
		mlastMsg = mlastMsg & Message & CRLF
	End If
	'Log("~"&Message)
	#end if
	
	If oc.Klippy And Message.StartsWith($"{"plugin": {"plugin": "klipper""$) Then
		CallSub2(pParserWO,"Klippy_Parse",Message)
		Return
	End If
	
	If Message.StartsWith($"{"plugin": {""$) Then
		'--- do not care of any plugins
		Return
	End If
	
	If Message.StartsWith($"{"event": {""$) Then
		CallSub2(pParserWO,"Event_Parse",Message)
		Return
	End If
	
	If Message.StartsWith($"{"reauthRequired""$) Then
		logMe.LogIt("reauthRequired type: " & Message,mModule)
		Passive_Login
		Return
	End If
	
	If pParserWO.pMsgs2Monitor.Size <> 0 Then '--- msg returned from the terminal
		CallSub2(pParserWO,"Msgs_Parse",Message)
	End If
	
End Sub


Private Sub ws_Closed (Reason As String)
	'--- socket is closed!
	Dim InSub As String = "ws_Closed"
	pConnected = False
	pClosedReason = ""
	If strHelpers.IsNullOrEmpty(Reason) Then 
		Reason = "Sys closed"
	Else
		logMe.LogIt2("ws close reason: " & Reason,mModule,InSub)
	End If
	pClosedReason = Reason
	
	'--- Reason = "WebSockets protocol violation" 
	If Reason = "WebSockets connection lost" Then 
		logMe.LogIt2("no web socket connection - reconnecting",mModule,InSub)
'		Wait For (Connect) Complete (msg As String)
'		If mConnected = False Then 
'			Return
'		End If
		guiHelpers.Show_toast2("Web Socket Lost: " & Reason,2000)
		Connect
	Else If Reason = "WebSockets protocol violation" Then
		'--- general reason has been logged above already ---
		logMe.LogIt2("!!!WebSockets protocol violation -- Octoprint needs to be restarted!!!",mModule,InSub)
		guiHelpers.Show_toast2("WebSockets protocol violation. Restart Octoprint",15000)
		CallSubDelayed2(B4XPages.MainPage,"CallSetupErrorConnecting",False)
		wSocket.Close
		
	Else
		If Main.isAppClosing Then Return
		Log("Socket Connect err???: " & pClosedReason)
		guiHelpers.Show_toast2("Restart Octoprint: Odd error: " & pClosedReason ,15000)
		CallSubDelayed2(B4XPages.MainPage,"CallSetupErrorConnecting",False)
	End If
	
End Sub


Public Sub Send(cmd As String) 
	If pConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"Send")
		Wait For (Connect) Complete (msg As String)
		If pConnected = False Then Return
	End If
	wSocket.SendText(cmd)
End Sub


Public Sub SendAndWait(cmd As String) As ResumableSub
	If pConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"SendAndWait")
		Wait For (Connect) Complete (msg As String)
		If pConnected = False Then Return "no connection"
	End If
	'Log(cmd)
	wSocket.SendText(cmd)
 	Wait For ws_TextMessage (Message As String)
	Return Message
End Sub


'======================================================================================================
'======================================================================================================
'======================================================================================================

