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
	
	Public mAPIkey As String
	Public gPort As String
	Public gIP As String
	Public gWSocketPort As String
	
End Sub


Public Sub Initialize(octoIP As String, octoPort As String, octoAPIkey As String)
	
	gIP = octoIP
	mAPIkey = octoAPIkey
	gPort = octoPort
	
End Sub


Private Sub ProcessErrMsg(msg As String)
	
	logMe.logit("(ProcessErrMsg)RestAPI ERR --> " & msg,mModule) '--- always log these
	msg = msg.ToLowerCase
	
	If msg.Contains("ed to connect t") Or msg.Contains("ockettimeou") Or msg.Contains("lid or inco") Then
		'--- ResponseError. Reason: java.net.ConnectException: Failed to connect to /192.168.1.236:5003, Response:
		'--- java.net.SocketTimeoutException: failed to connect to /192.168.1.207 (port 80) after 30000ms
		'--- java.net.SocketTimeoutException
		'--- the server returned an invalid or incomplete response.
		oc.ResetAllOctoVars
		CallSubDelayed2(B4XPages.MainPage,"CallSetupErrorConnecting",False)
	else If msg.Contains("is not oper") Then
		'--- ResponseError. Reason: CONFLICT, Response: {"error":"Printer is not operational"}
		oc.ResetAllOctoVars
		CallSubDelayed2(B4XPages.MainPage,"CallSetupErrorConnecting",True)
	End If
	
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


public Sub SendRequestGetInfo(octConst As String) As ResumableSub

	Dim inSub As String = "SendRequestGetInfo"
	Dim sAPI As String = $"http://${gIP}:${gPort}${octConst}?apikey=${mAPIkey}"$
	#if klipper
	sAPI = $"http://${gIP}:${gPort}${octConst}"$
	#End If
	
	
	Dim j As HttpJob: j.Initialize("", Me)
	Dim retStr As String = ""
	
	If config.logREST_API Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.LogIt2($"${UniqueStr}:-->${sAPI}"$,mModule,inSub)
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
		logMe.LogIt2($"${UniqueStr}:-->${sAPI}"$,mModule,inSub)
	End If
	
	Return retStr
		
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


Public Sub PostRequest(PostApiCmd As String) As ResumableSub
	
	#if klipper
	Dim EndPoint As String = $"http://${gIP}:${gPort}${PostApiCmd}"$
	Wait For (PostRequest2(EndPoint,"")) Complete(r As String)
	#else
	Dim restAPI, JsonDataMsg As String
	restAPI = Regex.Split("!!",PostApiCmd)(0)
	JsonDataMsg = Regex.Split("!!",PostApiCmd)(1)
	Dim EndPoint As String = $"http://${gIP}:${gPort}${restAPI}?apikey=${mAPIkey}"$
	Wait For (PostRequest2(EndPoint,JsonDataMsg)) Complete(r As String)
	#End If
	Return r
	
End Sub


Public Sub PostRequest2(EndPoint As String,JsonDataMsg As String) As ResumableSub

	Dim job As HttpJob : job.Initialize("", Me)
	Dim retStr As String = ""
	
	If config.logREST_API  Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.LogIt($"${UniqueStr}:-->${EndPoint & CRLF & JsonDataMsg & "<--:"}"$,mModule)
	End If
	
	job.PostString(EndPoint,JsonDataMsg)
	If JsonDataMsg = "" Then
		job.GetRequest.SetContentType("text/plain")
	Else
		job.GetRequest.SetContentType("application/json")
	End If
		
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
	
	If EndPoint.Contains(oc.cCMD_PRINT) Or EndPoint.Contains(oc.cCMD_CANCEL) Then
		'--- reset the power / screen on-off (diff timeout when printing)
		Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Set_ScreenTmr",10000)
	End If
	
	Return retStr
	
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


'--- pass in an empty filename string to NOT write out a file
Public Sub DownloadThumbnailAndShow(Link As String, iv As B4XImageView, fileName As String)'ignore
	
	Dim InSub As String = "DownloadThumbnailAndShow"
	'--- downloads and optionally writes out the file
	'--- pass "" in filename for NO file
	
	If Link.Length = 0 Then
		If config.logFILE_EVENTS Then logMe.LogIt("Thumbnail path is empty",mModule)
		Return
	End If
	
	If fileName.Length <> 0 Then fileHelpers.SafeKill(fileName)
		
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
				Log("DownloadThumbnailAndShow-dloading: " & fileName)
				
			End If
		End If
		
	Catch
		
		If config.logFILE_EVENTS Then logMe.LogIt2(LastException,mModule,InSub)
		
	End Try
	
	j.Release
	
End Sub


Public Sub Download_AndSaveFile(Link As String, fileName As String) As ResumableSub

	Dim InSub As String = "Download_AndSaveFile"
	
	If Link.Length = 0 Then
		If config.logFILE_EVENTS Then logMe.LogIt("Thumbnail path is empty",mModule) 	'--- no thumbnail
		Return Null
	End If
	
	If fileName.Length <> 0 Then fileHelpers.SafeKill(fileName)
	
	Dim j As HttpJob :	j.Initialize("", Me)
	Try
		
		#if klipper
		'--- TODO, nned  to parse exact file paths for gcode / files storage
		j.Download(Link.Replace(".thumbs","server/files/gcodes/.thumbs"))
		#else
		j.Download(Link)
		'j.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
		#End If
		
	Catch
		If config.logFILE_EVENTS Then logMe.LogIt2(LastException,mModule,InSub)
	End Try
	
	Wait For (j) JobDone(j As HttpJob)
	
	Try
		
		If j.Success Then
			
			Dim oo As B4XBitmap = j.GetBitmap
			'j.GetBitmapResize(200,200,True)
			Dim Out As OutputStream '--- write it out
			Out = File.OpenOutput(xui.DefaultFolder, fileName, False)
			oo.WriteToStream(Out, 100, "PNG")
			Out.Close
			'Log("Download_AndSaveFile-dloading: " & fileName)
		Else
			Log("failed to dload thumbnail")
		End If
		
	Catch
		If config.logFILE_EVENTS Then logMe.LogIt2(LastException,mModule,InSub)
		
	End Try
	
	j.Release
	Return Null
	
End Sub



'===================================================================================
'===================================================================================
'===================================================================================


public Sub DeleteRequest(DeleteApiCmd As String) As ResumableSub

	Dim InSub As String = "DeleteRequest"
	Dim sAPI As String = $"http://${gIP}:${gPort}${DeleteApiCmd}?apikey=${mAPIkey}"$
	#if klipper
	sAPI = $"http://${gIP}:${gPort}${DeleteApiCmd}"$
	#End If
	
	Dim job As HttpJob : job.Initialize("", Me)
	Dim retStr As String = ""
	
	If config.logREST_API Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.LogIt2($"${UniqueStr}:-->${sAPI}<--:"}"$,mModule,InSub)
	End If

	job.Delete(sAPI)
	'job.GetRequest.SetContentType("application/json")

	Wait For (job) JobDone(job As HttpJob)
	If job.Success Then
		retStr = job.GetString
	Else
		ProcessErrMsg(sAPI & CRLF &  job.ErrorMessage)
	End If
	
	job.Release '--- free up resources
		
	If config.logREST_API Then
		logMe.LogIt2( $"${UniqueStr}:-->${sAPI}"$,mModule,InSub)
	End If
	
	Return retStr
		
End Sub

