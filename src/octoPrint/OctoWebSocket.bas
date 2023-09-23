B4A=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
Sub Class_Globals
	Private Const mModule As String = "OctoWebSocket" 'ignore
	
	Private mIP As String 'ignore
	Private mPort As String 'ignore
	Private mKey As String
	
	Public wSocket As WebSocket
	Public mErrorSecProvider As Boolean = False
	Public mClosedReason As String
	Public mConnected As Boolean = False
	
	Public IsInit As Boolean = False
	Public mIgnoreMasterOctoEvent As Boolean = True
	Public pParserWO As WebSocketParse
	
	
End Sub

'#Event: RecievedText
'#Event: Closed
'#Event: Connected

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(ip As String, port As String, key As String)
	mPort = IIf(strHelpers.IsNullOrEmpty(port),"80",port) '--- TODO if port is null then should popup connect dialog, should never happen but did! LOL
	mIP = ip
	mKey = key
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
	Log("wb start")
	
	Dim Const thisSub As String	= "Connect"
	Try
		If wSocket.Connected Then 
			Log("wSocket is already connected")
			Return ""
		End If
	Catch
		'Log(LastException)
	End Try'ignore

	logMe.LogIt2("WS connecting...",mModule,thisSub)
	mConnected = False '--- assume bad
	
	'--- Init the socket
	wSocket.Initialize("ws")
	wSocket.Connect($"ws://${mIP}:${mPort}/sockjs/websocket?apikey=${mKey}"$)
	Wait For ws_Connected
	logMe.LogIt2("WS connected...",mModule,thisSub)
	Wait For ws_TextMessage (Message As String)
	mConnected = True
	Log("wb init end")
	
	'--- set subscriptions
'	Dim subscribe As String = $"{"subscribe": {
'    "state": {
'      "logs": "^Recv: Cap",
'      "messages": false},
'    "events": true,
'    "plugins": ["klipper"]}
'	}"$
	
	
	Dim subscribe As String = $"{"subscribe": {"plugins": ["klipper"]  }}"$
	
	Log(subscribe.Replace(CRLF," "))
	Send(subscribe)
	
	'--- Set the AUTH and start socket events
	Wait For (Passive_Login) Complete(i As Int)
		
	'--- A value of 2 will set the rate limit to maximally one message every 1s, 3 to maximally one message every 1.5s and so on.
	setThrottle("90")
	
	
	Return Message '--- this is the connected message
	
End Sub


Public Sub Passive_Login() As ResumableSub
	'--- this might need to be called again if 'reauthRequired' is recieved
	Wait For (B4XPages.MainPage.oMasterController.CN.PostRequest($"/api/login!!{ "passive": "true" }"$)) Complete (r As String)
	Dim parser As JSONParser : parser.Initialize(r) : Dim root As Map = parser.NextObject
	Send($"{"auth": "${root.Get("name")}:${root.Get("session")}"}"$)
	Log("AUTH end")
	Return Null
End Sub

Public Sub setThrottle(num As String)
	Send($"{"throttle": ${num}}"$)
End Sub

'--- master msg event method
Private Sub ws_TextMessage(Message As String)
	
	If oc.Klippy And Message.StartsWith($"{"plugin": {"plugin": "klipper""$) Then
		CallSubDelayed2(pParserWO,"Klippy_Parse",Message)
		#if debug
		Log("klippy plugin msg: " & Message)
		#end if
		Return
	End If
	
	If Message.StartsWith($"{"reauthRequired""$) Then
		logMe.LogIt("reauthRequired type: " & Message,mModule)
		Passive_Login
		Return
	End If
	
	'Log(Message)
	
End Sub


Private Sub ws_Closed (Reason As String)
	'--- socket is closed!
	mConnected = False
	If strHelpers.IsNullOrEmpty(Reason) Then 
		Reason = "Sys closed"
	End If
	mClosedReason = Reason
	Log("ws close reason: " & Reason)	
	If Reason = "WebSockets connection lost" Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"ws_Closed")
'		Wait For (Connect) Complete (msg As String)
'		If mConnected = False Then 
'			Return
'		End If
		guiHelpers.Show_toast2(Reason,2000)
		Connect
	End If
End Sub


Public Sub Send(cmd As String) 
	If mConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"Send")
		Wait For (Connect) Complete (msg As String)
		If mConnected = False Then Return
	End If
	wSocket.SendText(cmd)
End Sub


Public Sub SendAndWait(cmd As String) As ResumableSub
	If mConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"SendAndWait")
		Wait For (Connect) Complete (msg As String)
		If mConnected = False Then Return "no connection"
	End If
	wSocket.SendText(cmd)
 	Wait For ws_TextMessage (Message As String)
	Return Message
End Sub


'======================================================================================================
'======================================================================================================
'======================================================================================================

