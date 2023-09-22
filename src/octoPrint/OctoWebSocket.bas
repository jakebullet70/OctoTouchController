B4A=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
Sub Class_Globals
	Private Const mModule As String = "OctoWebSocket" 'ignore
	Private mCallbackModule As Object 'ignore
	Private mCallbackBase As String 'ignore
	Private mCallBackRecTxt As String'ignore
	
	Public pCallbackModule2 As Object = Null'ignore
	Public pCallbackSub2 As String = ""  'ignore
	
	Private mIP As String 'ignore
	Private mPort As String 'ignore
	Private mKey As String
	Public wSocket As WebSocket
	Public mErrorSecProvider As Boolean = False
	Public mClosedReason As String
	Public mConnected As Boolean = False
	
	Public IsInit As Boolean = False
	Public mIgnoreMasterOctoEvent As Boolean = True
	'Private mTestingConnection As Boolean = False
End Sub

#Event: RecievedText
#Event: Closed
#Event: Connected

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(callbackModule As Object, callbackBase As String,ip As String, port As String, key As String)
	mCallbackModule = callbackModule
	mCallbackBase = callbackBase
	mPort = IIf(strHelpers.IsNullOrEmpty(port),"80",port) '--- TODO if port is null then should popup connect dialog, should never happen but did! LOL
	mIP = ip
	mKey = key
	mCallBackRecTxt = mCallbackBase & "_RecievedText"
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
	Log("wb start")
	Dim Const thisSub As String	= "Connect"
	Try
		If wSocket.Connected Then Return ""
	Catch
		'Log(LastException)
	End Try'ignore

	logMe.LogIt2("WS connecting...",mModule,thisSub)
	
	mConnected = False
	'--- Init the socket
	wSocket.Initialize("ws")
	wSocket.Connect($"ws://${mIP}:${mPort}/sockjs/websocket?apikey=${mKey}"$)
	Wait For ws_Connected
	logMe.LogIt2("WS connected...",mModule,thisSub)
	mConnected = True
	Wait For ws_TextMessage (Message As String)
	Log("wb init end")
	
	
	
'	'--- set subscriptions
'	Dim subscribe As String = $"{"subscribe": {
'    "state": {"logs": true,"messages": false},"events": true,"plugins": true}
'	}"$
'	Wait For (SendAndWait(subscribe)) Complete (msg As String)
'	Log("subscribe: " & msg)

	
	'--- Set the AUTH and start the events
	'--- (we can tell if Klipper is running from here, need to remove the klippy check code)
	Wait For (B4XPages.MainPage.oMasterController.CN.PostRequest($"/api/login!!{ "passive": "true" }"$)) Complete (r As String)
	Dim parser As JSONParser : parser.Initialize(r) : Dim root As Map = parser.NextObject
	Wait For (SendAndWait($"{"auth": "${root.Get("name")}:${root.Get("session")}"}"$)) Complete (msg As String)
	Log("AUTH end")
	
	'--- A value of 2 will set the rate limit to maximally one message every 1s, 3 to maximally one message every 1.5s and so on.
	Send($"{"throttle": 9}"$)
	
	Return Message '--- this is the connected message
	
End Sub



'--- master msg event method
Private Sub ws_TextMessage(Message As String)
	
	
	Dim KlippyMsg As String = $"{"plugin": "klipper""$
	If Message.Contains(KlippyMsg) Then
		Log(Message)
		Return
	End If
	
		Log(Message)
	
'	If  (mIgnoreMasterOctoEvent And Message.Contains("notify_proc_stat_update")) Then
'		'--- {"jsonrpc": "2.0", "method": "notify_proc_stat_update", "params": [{"moonraker_stats": {"time": 1682259505.1849313, "cpu_usage": 1.93, "memory": 42916, "mem_units": "kB"}, "cpu_temp": 39.545, "network": {"lo": {"rx_bytes": 1013712283, "tx_bytes": 1013712283, "rx_packets": 785249, "tx_packets": 785249, "rx_errs": 0, "tx_errs": 0, "rx_drop": 0, "tx_drop": 0, "bandwidth": 0.0}, "eth0": {"rx_bytes": 108377478, "tx_bytes": 1008089809, "rx_packets": 1501935, "tx_packets": 915902, "rx_errs": 0, "tx_errs": 3, "rx_drop": 0, "tx_drop": 0, "bandwidth": 1127.61}}, "system_cpu_usage": {"cpu": 0.51, "cpu0": 0.0, "cpu1": 0.0, "cpu2": 0.0, "cpu3": 1.0}, "system_memory": {"total": 999584, "available": 742260, "used": 257324}, "websocket_connections": 1}]}
'		Return
'	End If
	
'	Dim klippyMethod As String = GetKlippyMethod(Message)
'	If Not (strHelpers.IsNullOrEmpty(klippyMethod)) And SubExists(mCallbackModule,klippyMethod) Then
'		CallSubDelayed2(mCallbackModule,klippyMethod,Message)
'	Else if SubExists(mCallbackModule,mCallBackRecTxt) Then
'		CallSubDelayed2(mCallbackModule,mCallBackRecTxt,Message)
'	End If
	
'	If SubExists(pCallbackModule2,pCallbackSub2) Then
'		CallSubDelayed2(pCallbackModule2,pCallbackSub2,Message)
'	End If
	
End Sub

'Private Sub GetKlippyMethod(s As String) As String
'	Try
'		Dim parser As JSONParser : parser.Initialize(s)
'		Dim root As Map = parser.NextObject
'		Dim m As String =  root.Get("method").As(String).Replace(".","_")
'		Return m
'	Catch
'		'Log(LastException)
'	End Try'ignore
'	Return ""
'End Sub

Private Sub ws_Closed (Reason As String)
	'--- socket is closed!
	mConnected = False
	If strHelpers.IsNullOrEmpty(Reason) Then Reason = "User closed"
	mClosedReason = Reason
	Log("ws close reason: " & Reason)
	If SubExists(mCallbackModule,mCallbackBase & "_Closed") Then
		CallSubDelayed2(mCallbackModule,mCallbackBase  & "_Closed",Reason)
	End If
End Sub


Public Sub Send(cmd As String) 
	If mConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"Send")
		Wait For (Connect) Complete (msg As String)
	End If
	wSocket.SendText(cmd)
'	Log("klippy send!")
End Sub


Public Sub SendAndWait(cmd As String) As ResumableSub
	If mConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"SendAndWait")
		Wait For (Connect) Complete (msg As String)
	End If
	
	wSocket.SendText(cmd)
 	Wait For ws_TextMessage (Message As String)
	Return Message
End Sub


'======================================================================================================
'======================================================================================================
'======================================================================================================

