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
	Public pSubscriptionMain As String

	Private mSesionName As String = ""
	Private mSessionKey As String = ""	
	Private mPassiveLoginIsBusy As Boolean = False
	Private mSocketTries As Int = 0
		
	Private isConnecting As Boolean = False
	Public mlastMsg As String
	Public bLastMessage As Boolean = False
	
End Sub

'#Event: RecievedText
'#Event: Closed
'#Event: Connected

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize() As OctoWebSocket
	pParserWO.Initialize
	
	pSubscriptionMain  = $"{"subscribe": {
				  "state": {
			      "logs": false,
			      "messages": true},
			      "events": true,
				  "plugins": ["OctoKlipper","klipper"]
				  }}"$
				  
	IsInit = True
	Return Me
End Sub

'--- Android 4
#if not (FOSS)
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
#End If

'=========================================================================
'=========================================================================
'=========================================================================

'ws://192.168.1.193:80/websocket?apikey=D009C78831ED4A25A9E48D2EC3538261

Public Sub SetSubscription(s As String)
	Send(s)
End Sub

Public Sub Connect_Socket() As ResumableSub
	'--- we wont ever run this code if the REST API fails
	Dim Const inSub As String	= "Connect"
	Dim txt As String

	Log("WS start: " & mSocketTries)
	mSocketTries = mSocketTries + 1
	
	If isConnecting = True Then 
		txt = "WS already trying to connect"
		logMe.logit2(txt,mModule,inSub)
		Return txt
	End If
	isConnecting = True
	
	Try
		If wSocket.Connected Then 
			isConnecting = False
			txt = "WS is already connected"
			logMe.logit2(txt,mModule,inSub)
			Return txt
		End If
	Catch
		'Log(LastException)
	End Try'ignore

	logMe.LogIt2("WS connecting...",mModule,inSub)
	pConnected = False '--- assume bad
	
	'--- Init the socket
	wSocket.Initialize("ws")
	wSocket.Connect($"ws://${oc.OctoIp}:${oc.OctoPort}/sockjs/websocket?apikey=${oc.OctoKey}"$)
	Wait For ws_Connected
	logMe.LogIt2("WS connected...",mModule,inSub)
	pConnected = True
	Wait For ws_TextMessage (Message As String)
	
	SetSubscription(pSubscriptionMain)
	
'	--- Set the AUTH And start socket events
	Dim allGood As Boolean = False, ct As Int = 0
	Do While ct < 4
		
		ct = ct + 1
		Log("calling passive login: " & ct)
		Wait For (Passive_Login) Complete(i As Boolean)
		allGood = i
		Log("Passive login OK=" & i.As(String))
		If i Then
			Message = "WS socket passive login: OK"
			Exit
		End If
		If mSocketTries > 3 Then
			Message = "WS socket failed with passive login"
			Exit '--- failure
		End If
		Sleep(1200)
		
	Loop
	
		
	'--- A value of 2 will set the rate limit to maximally one message every 1s, 3 to maximally one message every 1.5s and so on.
	setThrottle("90") '--- this is very inacurate
	isConnecting = False
	pConnected = allGood
	Log("wb init end: " & Message)
	Return Message '--- this is the connected message
	
End Sub


Public Sub Passive_Login() As ResumableSub
	Dim Const inSub As String = "Passive_Login"
	Dim sendMe As String
	
	If mPassiveLoginIsBusy Then 
		logMe.LogIt2("mPassiveLoginIsBusy=true",mModule,inSub)
		Return False
	End If
	mPassiveLoginIsBusy = True
	
	'--- called when REST commands are fully working from MasterController
	'--- this might need to be called again if 'reauthRequired' is recieved
	logMe.logit2("Passive_Login start",mModule,inSub)
	
	'--- do we already have a session?
	If mSessionKey.Length <> 0 Then
		Log("**********RE-USE************")
		Log("name:" & mSesionName)
		Log("session:" & mSessionKey)
		Log("****************************")
		sendMe = $"{"auth": "${mSesionName}:${mSessionKey}"}"$
		Wait For (SendAndWait(sendMe)) Complete (r As String)
		Log("Passive_Login ret val1: " & r)
		mPassiveLoginIsBusy = False
		If r.Contains("reauthReq") Then '--- this has happened twice now.
			guiHelpers.Show_toast2("Auth Err! Restatrt App",15000)
			mPassiveLoginIsBusy = False
			Return False
		End If
		If r.Contains("no connection") Then
			mSesionName = "" : mSessionKey = ""
			mPassiveLoginIsBusy = False
			Return False
		End If
		If oc.Klippy And r.StartsWith($"{"plugin"$) Then ws_TextMessage(r)
		mSocketTries = 0
		mPassiveLoginIsBusy = False
		Return True
	End If
		
	'--- get pasive logon - session info
	Wait For (B4XPages.MainPage.oMasterController.CN.PostRequest($"/api/login!!{ "passive": "true" }"$)) Complete (r As String)
	If strHelpers.IsNullOrEmpty(r) Then
		mPassiveLoginIsBusy = False
		logMe.logit2("/api/login is empty",mModule,inSub)
		Return False
	End If
	
	Dim parser As JSONParser : parser.Initialize(r) : Dim root As Map = parser.NextObject
	mSesionName = root.Get("name") 
	mSessionKey = root.Get("session")
	sendMe = $"{"auth": "${mSessionKey}:${mSessionKey}"}"$
	Log("*************NEW************")
	Log("name:" & mSesionName)
	Log("session:" & mSessionKey)
	Log("****************************")
	Wait For (SendAndWait(sendMe)) Complete (r As String)
	logMe.logit2("Passive_Login ret val2: " & r,mModule,inSub)
	
	logMe.logit2("Passive_Login Auth end",mModule,inSub)
	mPassiveLoginIsBusy = False
	If r.Contains("reauthReq") Then 
		logMe.logit2("reauthReq=true",mModule,inSub)
		'Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Passive_Login",500)
		mPassiveLoginIsBusy = False
		Return False
	End If
	mSocketTries = 0
	mPassiveLoginIsBusy = False
	Return True
End Sub


Public Sub setThrottle(num As String)
	Send($"{"throttle": ${num}}"$)
	If config.logREST_API Then logMe.logit2("WebSocket throttle: " & num ,mModule,"setThrottle")
End Sub

'--- master msg event method
Private Sub ws_TextMessage(Message As String)
	
	#if debug
'	If bLastMessage Then
'		mlastMsg = mlastMsg & Message & CRLF
'	End If
	'Log("~"&Message)
	#end if
		
	If Message.StartsWith($"{"event": {""$) Then
		CallSub2(pParserWO,"Event_Parse",Message)
		Return
	End If
	
	If oc.Klippy And Message.StartsWith($"{"plugin": {"plugin": "klipper""$) Then
		CallSub2(pParserWO,"Klippy_Parse",Message)
		Return
	End If
	
	If Message.StartsWith($"{"plugin": {""$) Then
		'--- do not care of any other plugins
		Return
	End If
	
	If pParserWO.pMsgs2Monitor.Size <> 0 Then '--- msg returned from the terminal
		CallSub2(pParserWO,"Msgs_Parse",Message)
		Return
	End If
		
	If Message.StartsWith($"{"reauthRequired""$) Then
		logMe.LogIt("reauthRequired type: " & Message,mModule)
		Passive_Login
		Return
	End If
	
End Sub


Private Sub ws_Closed (Reason As String)
	'--- socket is closed!
	Dim InSub As String = "ws_Closed"
	Dim msg As String = ""
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
		logMe.LogIt2("reconnecting - WS lost: "  & Reason,mModule,InSub)
		guiHelpers.Show_toast2("(Re)Connecting WebSocket...",2000)
		Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Connect_socket",800)
		
	Else If Reason = "WebSockets protocol violation" Then
		'--- general reason has been logged above already ---
		wSocket.Close
		If mSocketTries > 3 Then
			msg = "WebSockets protocol violation. Restart Octoprint and App"
			logMe.LogIt2(msg,mModule,InSub)
			guiHelpers.Show_toast2(msg,15000)
		Else
			Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Connect_socket",800)
		End If
		
	Else
		If Main.isAppClosing Or Reason = "Sys closed" Then Return
		msg ="Restart Octoprint: Error: " & pClosedReason
		guiHelpers.Show_toast2(msg ,15000)
		Log("WS error: " & msg)
		CallSubDelayed2(B4XPages.MainPage,"CallSetupErrorConnecting",False)
	End If
	
End Sub


Public Sub Send(cmd As String) 
	If pConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"Send")
		Wait For (Connect_Socket) Complete (msg As String)
		If pConnected = False Then Return
	End If
	wSocket.SendText(cmd)
End Sub


Public Sub SendAndWait(cmd As String) As ResumableSub
	If pConnected = False Then
		logMe.LogIt2("no web socket connection - reconnecting",mModule,"SendAndWait")
		Wait For (Connect_Socket) Complete (msg As String)
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

