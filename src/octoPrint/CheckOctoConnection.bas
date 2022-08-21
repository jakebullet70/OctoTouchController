B4A=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/30/2022
#End Region

#Region EVENTS' DECLARATIONS 
#Event: Complete (result As object, success as object)
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "CheckOctoConnection" 'ignore
	Private mCallback As Object
	Private mEventName As String
	
End Sub


Public Sub Initialize(Callback As Object, EventName As String)
	
	mCallback = Callback
	mEventName = EventName
	
End Sub


Private Sub RaiseEvent(EvName As String, Params As List) 'ignore
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


public Sub Check(ip As String,port As String,octo_key As String) 

	Dim InSub As String = "Check"
	Dim sAPI As String = $"http://${ip}:${port}${oc.cSERVER}?apikey=${octo_key}"$
	
	Dim j As HttpJob: j.Initialize("", Me)
	Dim resultStr As String = ""
	Dim boolStr As String = False.As(String)
	
	If config.logREST_API Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.logit2($"ConnectCheck: ${UniqueStr}:-->${sAPI}"$,mModule,InSub)
	End If

	j.Download(sAPI)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		resultStr = j.GetString
		boolStr = True.As(String)
	End If
	
	j.Release '--- free up resources
	
	If config.logREST_API Then
		logMe.logit2($"ConnectCheck: ${UniqueStr}:-->${sAPI}"$,mModule,InSub)
	End If
	
	Dim retList As List : retList.Initialize2(Array As String(resultStr,boolStr))
	RaiseEvent("Complete",retList)
	
End Sub


