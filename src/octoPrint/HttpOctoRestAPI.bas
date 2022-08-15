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
	
	'ResponseError. Reason: java.net.ConnectException: Failed to connect to /192.168.1.236:5003, Response:
'	If msg.Contains("Failed to connect to") Then
'
'		If B4XPages.MainPage.pnlNoConnection.Visible = False Then
'
'			oc.ResetAllOctoVars
'			CallSubDelayed(mainObj,"Show_ConnectingScreen")
'			CallSubDelayed(mainObj,"Start_ConnectTimer")
'			
'		End If
'		Return
'		
'	End If


	
	'logMe.pLog2DebugWindowRestAPI = False
	'--- if TRUE will log to debug window, FALSE logs to disk
	'--- in RELEASE always logs to disk, this is for testing, debugging
	#if b4j
	'CallSubDelayed2(logMe,"Log_DebuggerRestAPI", msg)
	#else
	logMe.Log_DebuggerRestAPI( msg)
	
	#end if
	
	
	'--- logs ONLY in the programming envirement
	logMe.LogDebug2("RestAPI ERR --> " & msg,mModule) '--- TODO, in DEBUG do we want to always log REST API errors?
	
	'--- will be called if ShowTabDebugInfoFLAG flag is set to true (view in DEBUG tab)
'	If config.pTurnOnDebugTabFLAG Then
'		'CallSubDelayed2( B4XPages.MainPage.oTabHome.oSubTab.oDebug,"ShowDebugVarsJSON",msg)  TODO!!!!
'	End If
				
	
	'If msg.Contains("CONFLICT") Then
	'End If
	
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


public Sub SendRequestGetInfo(octConst As String) As ResumableSub

	Dim sAPI As String = $"http://${gIP}:${gPort}${octConst}?apikey=${mAPIkey}"$
	
	Dim j As HttpJob: j.Initialize("", Me)
	Dim retStr As String = ""
	
	If logMe.pLog2DebugWindowRestAPI  Or logMe.pLogFull Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.Log_DebuggerRestAPI($"${UniqueStr}:-->${sAPI}"$)
	End If

	j.Download(sAPI)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		retStr = j.GetString
	Else
		ProcessErrMsg( sAPI &  CRLF &  j.ErrorMessage)
	End If
	
	j.Release '--- free up resources
	
	If logMe.pLog2DebugWindowRestAPI  Or logMe.pLogFull Then
		logMe.Log_DebuggerRestAPI($"${UniqueStr}:-->${sAPI}"$)
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
	
	If logMe.pLog2DebugWindowRestAPI Or logMe.pLogFull  Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.Log_DebuggerRestAPI($"${UniqueStr}:-->${EndPoint & CRLF & JsonDataMsg & "<--:"}"$)
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
	
	If logMe.pLog2DebugWindowRestAPI Or logMe.pLogFull Then
		logMe.Log_DebuggerRestAPI( $"${UniqueStr}:-->${EndPoint}"$)
	End If
	
	If PostApiCmd = oc.cCMD_PRINT Or PostApiCmd = oc.cCMD_CANCEL Then
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

	'--- downloads and optionally writes out the file
	'--- pass "" in filename for NO file
	
	If Link.Length = 0 Then
		logMe.LogIt("Thumbnail path is empty",mModule)
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
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
	j.Release
	
End Sub


Public Sub Download_AndSaveFile(Link As String, fileName As String)

	If Link.Length = 0 Then
		logMe.LogIt("Thumbnail path is empty",mModule) 	'--- no thumbnail
		Return
	End If
	
	If fileName.Length <> 0 Then 	fileHelpers.SafeKill(fileName)
		
	Try
		Dim j As HttpJob :	j.Initialize("", Me)
		j.Download(Link)
		'j.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
		
	Catch
		Log(LastException)
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
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
	j.Release
	
End Sub


'===================================================================================
'===================================================================================
'===================================================================================


public Sub DeleteRequest(DeleteApiCmd As String) As ResumableSub

	'Dim restAPI  As String
		
	Dim EndPoint As String = $"http://${gIP}:${gPort}${DeleteApiCmd}?apikey=${mAPIkey}"$
	
	Dim rs As ResumableSub =  DeleteRequest2Server(EndPoint)
	Wait For(rs) Complete (Result As String)
	Return Result
		
End Sub



private Sub DeleteRequest2Server(sAPI As String) As ResumableSub
	
	Dim job As HttpJob : job.Initialize("", Me)
	Dim retStr As String = ""
		
	If logMe.pLog2DebugWindowRestAPI Or logMe.pLogFull  Then
		Dim UniqueStr As String = Rnd(100000,999999).As(String)
		logMe.Log_DebuggerRestAPI($"${UniqueStr}:-->${sAPI}<--:"}"$)
	End If

	job.Delete(sAPI)
	Log(sAPI)
	'job.GetRequest.SetContentType("application/json")

	Wait For (job) JobDone(job As HttpJob)
	If job.Success Then
		retStr = job.GetString
	Else
		ProcessErrMsg( sAPI & CRLF &  job.ErrorMessage)
	End If
	
	job.Release '--- free up resources
		
	If logMe.pLog2DebugWindowRestAPI Or logMe.pLogFull Then
		logMe.Log_DebuggerRestAPI( $"${UniqueStr}:-->${sAPI}"$)
	End If
	
	Return retStr

End Sub

