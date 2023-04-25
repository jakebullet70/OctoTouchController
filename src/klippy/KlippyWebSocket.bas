B4A=true
Group=KLIPPY
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
Sub Class_Globals
	Private Const mModule As String = "KlippyWebSocket" 'ignore
	Private mCallbackModule As Object 'ignore
	Private mCallbackBase As String 'ignore
	Private mCallBackRecTxt As String
	Private mIP As String 'ignore
	Private mPort As String 'ignore
	Public wSocket As WebSocket
	Public mErrorSecProvider As Boolean = False
	Public mClosedReason As String
	Public mConnected As Boolean = False
	
	Public IsInit As Boolean = False
	Public mIgnoreMasterKlippyEvent As Boolean = True
	'Private mTestingConnection As Boolean = False
End Sub

#Event: RecievedText
#Event: Closed
#Event: Connected

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(callbackModule As Object, callbackBase As String,ip As String, port As String)
	mCallbackModule = callbackModule
	mCallbackBase = callbackBase
	mPort = port
	mIP = ip
	mCallBackRecTxt = mCallbackBase & "_RecievedText"
	IsInit = True
End Sub

#if klipper
Private Sub DisableStrictMode
	Dim jo As JavaObject
	jo.InitializeStatic("android.os.Build.VERSION")
	If jo.GetField("SDK_INT") > 9 Then
		Dim policy As JavaObject
		policy = policy.InitializeNewInstance("android.os.StrictMode.ThreadPolicy.Builder", Null)
		policy = policy.RunMethodJO("permitAll", Null).RunMethodJO("build", Null)
		Dim sm As JavaObject
		sm.InitializeStatic("android.os.StrictMode").RunMethod("setThreadPolicy", Array(policy))
	End If
End Sub

Public Sub ProviderInstall() As ResumableSub
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
		Log("Provider installed successfully")
	Else
		Log("Error installing provider: " & Args(0))
		mErrorSecProvider = True
	End If
	Return mErrorSecProvider
	
End Sub

'=========================================================================
'=========================================================================
'=========================================================================
'Public Sub ConnectionTest
'
'	mTestingConnection = True
'	wSocket.Initialize("ws")
'	wSocket.Connect($"ws://${mIP}:${mPort}/websocket"$)
'	
'End Sub
'Private Sub ws_Connected
'	If mTestingConnection = False Then Return
'	mConnected = True
'	mTestingConnection = False
'End Sub



Public Sub Connect() As ResumableSub
	Dim Const thisSub As String	= "Connect"
	Try
		If wSocket.Connected Then Return ""
	Catch
		'Log(LastException)
	End Try'ignore

	logMe.LogIt2("WS connecting...",mModule,thisSub)
	wSocket.Initialize("ws")
	wSocket.Connect($"ws://${mIP}:${mPort}/websocket"$)
	Wait For ws_Connected
	logMe.LogIt2("WS connected...",mModule,thisSub)
	mConnected = True
	'If mRaiseMsgEvent = False Then
	Wait For ws_TextMessage (Message As String)
	Return Message
	'End If
	
End Sub


'--- master msg event method
Private Sub ws_TextMessage(Message As String)
	
	If mIgnoreMasterKlippyEvent And Message.Contains("notify_proc_stat_update") Then
		'--- {"jsonrpc": "2.0", "method": "notify_proc_stat_update", "params": [{"moonraker_stats": {"time": 1682259505.1849313, "cpu_usage": 1.93, "memory": 42916, "mem_units": "kB"}, "cpu_temp": 39.545, "network": {"lo": {"rx_bytes": 1013712283, "tx_bytes": 1013712283, "rx_packets": 785249, "tx_packets": 785249, "rx_errs": 0, "tx_errs": 0, "rx_drop": 0, "tx_drop": 0, "bandwidth": 0.0}, "eth0": {"rx_bytes": 108377478, "tx_bytes": 1008089809, "rx_packets": 1501935, "tx_packets": 915902, "rx_errs": 0, "tx_errs": 3, "rx_drop": 0, "tx_drop": 0, "bandwidth": 1127.61}}, "system_cpu_usage": {"cpu": 0.51, "cpu0": 0.0, "cpu1": 0.0, "cpu2": 0.0, "cpu3": 1.0}, "system_memory": {"total": 999584, "available": 742260, "used": 257324}, "websocket_connections": 1}]}
		Return
	End If
	
	Dim klippyMethod As String = GetKlippyMethod(Message)
	If Not (strHelpers.IsNullOrEmpty(klippyMethod)) And SubExists(mCallbackModule,klippyMethod) Then
		CallSubDelayed2(mCallbackModule,klippyMethod,Message)
	Else If SubExists(mCallbackModule,mCallBackRecTxt) Then
		CallSubDelayed2(mCallbackModule,mCallBackRecTxt,Message)
	End If
	
End Sub

Private Sub GetKlippyMethod(s As String) As String
	Try
		Dim parser As JSONParser : parser.Initialize(s)
		Dim root As Map = parser.NextObject
		Dim m As String =  root.Get("method").As(String).Replace(".","_")
		Return m
	Catch
		'Log(LastException)
	End Try'ignore
	Return ""
End Sub

Private Sub ws_Closed (Reason As String)
	'--- socket is closed!
	mConnected = False
	mClosedReason = Reason
	Log("ws close reason: " & Reason)
	If SubExists(mCallbackModule,mCallbackBase & "_Closed") Then
		CallSubDelayed2(mCallbackModule,mCallbackBase  & "_Closed",Reason)
	End If
End Sub


Public	 Sub Send(cmd As String) 
	If mConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"Send")
		Wait For (Connect) Complete (msg As String)
	End If
	wSocket.SendText(cmd)
	Log("klippy send!")
End Sub


Public	 Sub SendAndWait(cmd As String) As ResumableSub
	If mConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"SendAndWait")
		Wait For (Connect) Complete (msg As String)
	End If
	wSocket.SendText(cmd)
	Wait For ws_TextMessage (Message As String)
	Return Message
End Sub

#End If

'======================================================================================================
'======================================================================================================
'======================================================================================================

