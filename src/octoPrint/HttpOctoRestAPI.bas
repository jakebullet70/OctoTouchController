B4J=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V1.1	Aug/3/2022		Code cleanup
' V1.0 	June/7/2022
#End Region
Sub Class_Globals

	Private xui As XUI
	Private Const mModule As String = "HttpOctoRestAPI" 'ignore
	
	Private mAPIkey As String
	Public gPort As String
	Public gIP As String
	
End Sub


Public Sub Initialize(octoIP As String, octoPort As String, octoAPIkey As String)
	
	gIP = octoIP
	mAPIkey = octoAPIkey
	gPort = octoPort
	
End Sub


Private Sub ProcessErrMsg(msg As String)
	
	
	If msg.Contains("Failed to connect to") Then
		'--- ResponseError. Reason: java.net.ConnectException: Failed to connect to /192.168.1.236:5003, Response:
		oc.ResetAllOctoVars
		CallSubDelayed2(B4XPages.MainPage,"CallSetupErrorConnecting",False)
		Return
	else If msg.Contains("Printer is not operational") Then
		'--- ResponseError. Reason: CONFLICT, Response: {"error":"Printer is not operational"}
		oc.ResetAllOctoVars
		CallSubDelayed2(B4XPages.MainPage,"CallSetupErrorConnecting",True)
		Return
	End If
	
	logMe.logit("RestAPI ERR --> " & msg,mModule) '--- always log these
	
	
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


public Sub SendRequestGetInfo(octConst As String) As ResumableSub

	Dim sAPI As String = $"http://${gIP}:${gPort}${octConst}?apikey=${mAPIkey}"$
	
	Dim j As HttpJob: j.Initialize("", Me)
	Dim retStr As String = ""
	
	If config.logREST_API Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.LogIt($"${UniqueStr}:-->${sAPI}"$,mModule)
	End If

	j.Download(sAPI)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		retStr = j.GetString
	Else
		ProcessErrMsg( sAPI &  CRLF &  j.ErrorMessage)
	End If
	
	j.Release '--- free up resources
	
	If config.logREST_API Then
		logMe.LogIt($"${UniqueStr}:-->${sAPI}"$,mModule)
	End If
	
	Return retStr
		
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


public Sub PostRequest(PostApiCmd As String) As ResumableSub

	Dim restAPI, JsonDataMsg As String
	restAPI = Regex.Split("!!",PostApiCmd)(0)
	JsonDataMsg = Regex.Split("!!",PostApiCmd)(1)
			
	Dim EndPoint As String = $"http://${gIP}:${gPort}${restAPI}?apikey=${mAPIkey}"$


	Dim job As HttpJob : job.Initialize("", Me)
	Dim retStr As String = ""
	
	If config.logREST_API  Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.LogIt($"${UniqueStr}:-->${EndPoint & CRLF & JsonDataMsg & "<--:"}"$,mModule)
	End If
	
	job.PostString(EndPoint,JsonDataMsg)
	job.GetRequest.SetContentType("application/json")
	
	Wait For (job) JobDone(job As HttpJob)
	If job.Success Then
		retStr = job.GetString
	Else
		ProcessErrMsg( EndPoint & CRLF & JsonDataMsg & CRLF &  job.ErrorMessage)
	End If
	
	job.Release '--- free up resources
	
	If config.logREST_API Then
		logMe.LogIt( $"${UniqueStr}:-->${EndPoint}"$,mModule)
	End If
	
	If PostApiCmd = oc.cCMD_PRINT Or PostApiCmd = oc.cCMD_CANCEL Then
		'--- reset the power / screen on-off (diff timeout when printing)
		Starter.tmrTimerCallSub.CallSubDelayedPlus(Main,"Set_ScreenTmr",10000)
	End If
	
	Return retStr
	
End Sub



'===================================================================================
'===================================================================================
'===================================================================================


'--- pass in an empty filename string to NOT write out a file
Public Sub DownloadThumbnailAndShow(Link As String, iv As B4XImageView, fileName As String)'ignore

	'--- downloads and optionally writes out the file
	'--- pass "" in filename for NO file
	
	If Link.Length = 0 Then
		If config.logFILE_EVENTS Then logMe.LogIt("Thumbnail path is empty",mModule)
		Return
	End If
	
	If fileName.Length <> 0 Then 	fileHelpers.SafeKill(fileName)
		
	Dim j As HttpJob :	j.Initialize("", Me)
	j.Download(Link)
	'j.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
	
	Wait For (j) JobDone(j As HttpJob)
	
	Try
		
		If j.Success Then
			
			iv.Bitmap =  j.GetBitmap
			If fileName.Length <> 0 Then '--- write out file
				
				Dim Out As OutputStream '--- write it out
				Out = File.OpenOutput(xui.DefaultFolder, fileName, False)
				iv.Bitmap.WriteToStream(Out, 100, "PNG")
				Out.Close
				
			End If
		End If
		
	Catch
		
		If config.logFILE_EVENTS Then logMe.LogIt(LastException,mModule)
		
	End Try
	
	j.Release
	
End Sub


Public Sub Download_AndSaveFile(Link As String, fileName As String)

	If Link.Length = 0 Then
		If config.logFILE_EVENTS Then logMe.LogIt("Thumbnail path is empty",mModule) 	'--- no thumbnail
		Return
	End If
	
	If fileName.Length <> 0 Then fileHelpers.SafeKill(fileName)
		
	Try
		Dim j As HttpJob :	j.Initialize("", Me)
		j.Download(Link)
		'j.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
		
	Catch
		If config.logFILE_EVENTS Then logMe.LogIt(LastException,mModule)
	End Try
	
	Wait For (j) JobDone(j As HttpJob)
	
	Try
		
		If j.Success Then
			
			Dim oo As B4XBitmap = j.GetBitmap
			Dim Out As OutputStream '--- write it out
			Out = File.OpenOutput(xui.DefaultFolder, fileName, False)
			oo.WriteToStream(Out, 100, "PNG")
			Out.Close
			
		End If
		
	Catch
		
		If config.logFILE_EVENTS Then logMe.LogIt(LastException,mModule)
		
	End Try
	
	j.Release
	
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


public Sub DeleteRequest(DeleteApiCmd As String) As ResumableSub

	Dim sAPI As String = $"http://${gIP}:${gPort}${DeleteApiCmd}?apikey=${mAPIkey}"$
	
	Dim job As HttpJob : job.Initialize("", Me)
	Dim retStr As String = ""
	
	If config.logREST_API Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.LogIt($"${UniqueStr}:-->${sAPI}<--:"}"$,mModule)
	End If

	job.Delete(sAPI)
	Log(sAPI)
	'job.GetRequest.SetContentType("application/json")

	Wait For (job) JobDone(job As HttpJob)
	If job.Success Then
		retStr = job.GetString
	Else
		ProcessErrMsg(sAPI & CRLF &  job.ErrorMessage)
	End If
	
	job.Release '--- free up resources
		
	If config.logREST_API Then
		logMe.LogIt( $"${UniqueStr}:-->${sAPI}"$,mModule)
	End If
	
	Return retStr

	
	'Dim rs As ResumableSub =  DeleteRequest2Server(EndPoint)
	'Wait For(rs) Complete (Result As String)
	'Return Result
		
End Sub


'
'private Sub DeleteRequest2Server(sAPI As String) As ResumableSub
'	
'	Dim job As HttpJob : job.Initialize("", Me)
'	Dim retStr As String = ""
'		
'	If config.logREST_API Then
'		Dim UniqueStr As String = Rnd(100000,999999).As(String)
'		logMe.LogIt($"${UniqueStr}:-->${sAPI}<--:"}"$,mModule)
'	End If
'
'	job.Delete(sAPI)
'	Log(sAPI)
'	'job.GetRequest.SetContentType("application/json")
'
'	Wait For (job) JobDone(job As HttpJob)
'	If job.Success Then
'		retStr = job.GetString
'	Else
'		ProcessErrMsg( sAPI & CRLF &  job.ErrorMessage)
'	End If
'	
'	job.Release '--- free up resources
'		
'	If config.logREST_API Then
'		logMe.LogIt( $"${UniqueStr}:-->${sAPI}"$,mModule)
'	End If
'	
'	Return retStr
'
'End Sub
'
