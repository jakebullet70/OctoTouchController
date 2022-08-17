B4J=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	July/2/2022
#End Region

#Region EVENTS' DECLARATIONS 
#Event: RequestComplete (result As object, Success as object)
#End Region

Sub Class_Globals
	Private Const mModule As String = "RequestApiKey" 'ignore

	Private mCallback As Object
	Private mEventName As String
	Private mAppTitle As String
	Private mIP As String
	Private mPort As String
	
End Sub

Public Sub Initialize(Callback As Object, EventName As String, AppName As String, ip As String, port As String)

	mCallback = Callback
	mEventName = EventName
	mAppTitle = AppName
	mIP = ip
	mPort = port
	
End Sub


#Region PUBLIC METHODS 
Public Sub RequestAvailable()

	Dim sAPI As String = $"http://${mIP}:${mPort}${oc.cAPI_KEY_PROBE}"$
	
	Dim j As HttpJob: j.Initialize("", Me)
	Dim resultStr As String = ""
	Dim AllGood As Boolean = False
	
	Dim UniqueStr As String = Rnd(100000,999999).As(String)
	If config.logREQUEST_OCTO_KEY Then logMe.LogIt($"KeyRequestAvail: ${UniqueStr}:-->${sAPI}"$,mModule)

	j.Download(sAPI)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		If j.Response.StatusCode = 204 Then '--- this is GOOD!
			AllGood = True
			If config.logREQUEST_OCTO_KEY Then logMe.LogIt($"KeyRequestAvail: ${UniqueStr}:--> Yeah!"$,mModule)
		Else
			resultStr = "Request failed - Octoprint key request service is not working"
			If config.logREQUEST_OCTO_KEY Then logMe.LogIt($"KeyRequestAvail: ${UniqueStr}:--> Failure"$,mModule)
		End If
	Else
		'--- we did not even get a connection
		Dim msg As StringBuilder : msg.Initialize
		msg.Append("Connection Failed.").Append(CRLF).Append("A couple of things to think about").Append(CRLF)
		msg.Append("Is Octoprint turned on?").Append(CRLF).Append("Are Your IP And Port correct?").Append(CRLF)
		resultStr = msg.ToString
	End If
	
	j.Release '--- free up resources
	
	If AllGood Then 
		Prompt4Key
	Else
		'--- request for avail octo get API key has failed
		Dim retList As List : retList.Initialize2(Array As String(resultStr,(AllGood.As(String))))
		RaiseEvent("RequestComplete",retList)
		Return
	End If
	
End Sub


private Sub Prompt4Key()

	Try

		Dim allOK As Boolean = False '--- assume BAD!
		Dim sAPImain As String = $"http://${mIP}:${mPort}${oc.cAPI_KEY_REQUEST}"$
		Dim sAPI As String = Regex.Split("!!",sAPImain)(0)
		Dim sData As String = Regex.Split("!!",sAPImain)(1).Replace("!APP!",mAppTitle)
	
		Dim job As HttpJob : job.Initialize("", Me)
		Dim retStr As String = ""
		
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.LogIt($"${UniqueStr}:-->${sAPI & CRLF & sData & "<--:"}"$,mModule)

		job.PostString(sAPI,sData)
		job.GetRequest.SetContentType("application/json")

		Wait For (job) JobDone(job As HttpJob)
		If job.Success And job.Response.StatusCode = 201 Then  '---   good
			allOK = True
			retStr =  job.Response.GetHeaders.Get("location") '---API location to pole
			retStr = retStr.Replace("[","").Replace("]","")
			Log(retStr)
		Else
			retStr = "Octoprint key prompt request failed"
			logMe.LogIt($"${UniqueStr}:-->${retStr}"$,mModule)
		End If
		
	Catch
		If config.logREQUEST_OCTO_KEY Then logMe.LogIt(LastException,mModule)
	End Try

	job.Release '--- free up resources
	
	If allOK Then
		Wait4Key(retStr) '--- retStr has the location to be polled
	Else
		Dim retList As List : retList.Initialize2(Array As String(retStr,(allOK.as(String))))
		RaiseEvent("RequestComplete",retList)
		Return
	End If
	
End Sub



private Sub Wait4Key(poleLocation As String)

	Dim loopNum As Int = 0
	Dim const MaxLoop As Int = 90 '--- about 2 minutes
	Dim AllGood As Boolean = False
	Dim KeyDenied As Boolean = False
	Dim mapOut As Map
	Dim resultStr As String = ""
	Dim AllGood As Boolean = False
	Dim ErrMsgDeniedOrTimeout As String = "Octoprint Key Wait Error: Request Denied Or Timed Out"
	
	Do While (loopNum < MaxLoop) Or KeyDenied Or AllGood

		'[http://192.168.1.236:5003/plugin/appkeys/request/C557F0FBF26F487C82F8A0917E80EAE2
		
		Dim j As HttpJob : j.Initialize("", Me)
		
		Dim UniqueStr As String = Rnd(100000,999999).As(String) 'ignore
		If config.logREQUEST_OCTO_KEY Then logMe.LogIt($"KeyWait: ${UniqueStr}:-->${poleLocation}"$,mModule)

		j.Download(poleLocation)
		Wait For (j) JobDone(j As HttpJob)

		If j.Success Then

			Select Case j.Response.StatusCode
				
				Case 202 '--- continue polling
				Case 404 '--- access denied
					KeyDenied = True
					resultStr = "" '--- msg set below
					
				Case 200 '--- all is good
					mapOut = j.GetString.As(JSON).ToMap 'ignore
					AllGood = True
					
				Case Else
					If config.logREQUEST_OCTO_KEY Then logMe.LogIt("case else - " & j.Response.StatusCode,mModule)
					
			End Select

		Else
			
			resultStr = ErrMsgDeniedOrTimeout
			If config.logREQUEST_OCTO_KEY Then logMe.LogIt($"KeyWait: ${UniqueStr}:--> Failure: ${j.ErrorMessage}"$,mModule)
			Exit
				
		End If
		
		j.Release '--- free up resources

		Sleep(1500)
		loopNum = loopNum + 1
	
	Loop 
	
	'--- just in case...
	If j.IsInitialized Then j.Release
	
	Dim retList As List
	If AllGood Then
		retList.Initialize2(Array As String(mapOut.Get("api_key"),(AllGood.As(String))))
	Else
		'--- request for avail octo get API key has failed
		If resultStr.Length = 0 Then resultStr = ErrMsgDeniedOrTimeout
		 retList.Initialize2(Array As String(resultStr,(AllGood.As(String))))
	End If

	RaiseEvent("RequestComplete",retList)

End Sub

#End Region

#Region PRIVATE METHODS 

Private Sub RaiseEvent(EvName As String, Params As List)'ignore
	Dim FullRoutineName As String
	FullRoutineName = mEventName & "_" & EvName
	If SubExists(mCallback, FullRoutineName) Then
		If Not(Params.IsInitialized) Or Params.Size = 0 Then
			CallSubDelayed(mCallback, FullRoutineName)
		Else
			Select Params.Size
				Case 1
					CallSubDelayed2(mCallback, FullRoutineName, Params.Get(0))
				Case 2
					CallSubDelayed3(mCallback, FullRoutineName, Params.Get(0), Params.Get(1))
			End Select
		End If
	End If
End Sub

#End Region



