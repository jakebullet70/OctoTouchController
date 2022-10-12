B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0	Oct/11/2022
'			1st version. 
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "ftp_support" 'ignore
	Private xui As XUI
	Private mCntr As Int
	
	Private mCallbackMod As Object
	Private mCallbackEvent As String
	Private mCallbackEventProgress As String
	
	Public FTP As FTP
	Public DownloadDir As String
	
End Sub

Public Sub Initialize(callback_mod As Object,callback_event_ok As String, _
						callback_event_progress As String, _
						host As String, port As Int, user As String, pw As String)
	
	mCallbackEvent = callback_event_ok
	mCallbackMod   = callback_mod
	mCallbackEventProgress = callback_event_progress
	
	FTP.UseSSL = False
	FTP.PassiveMode = False
	'FTP.UseSSLExplicit = False
	FTP.TimeoutMs = 20000 '--- 20 seconds
	FTP.Initialize("ftp",host,port,user,pw)
		
End Sub

Public Sub CleanUpApkDownload
	
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_NAME)
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_FILE_INFO)
	fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.APK_NAME)
	fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.APK_FILE_INFO)
	
End Sub

Public Sub Download(file2dload As String,dLoadServerPath As String,isAscII As Boolean) As ResumableSub
	
	Dim dLoadMe As String = File.Combine(dLoadServerPath,file2dload)
	DownloadDir = Starter.Provider.SharedFolder
	Log("dload start-1st folder: " & DownloadDir)
	FTP.UseSSL = False
	FTP.PassiveMode = False
	'FTP.UseSSLExplicit = False
	FTP.TimeoutMs = 20000 '--- 20 seconds
	
	Dim TryMeAgain As Boolean = True
	Do While True
		
		Dim sf As Object = FTP.DownloadFile(dLoadMe, isAscII, DownloadDir,file2dload)
		Wait For (sf) ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
		Log(LastException.Message)
		If LastException.Message.Contains("EACCES") And TryMeAgain = True Then
			
			DownloadDir = xui.DefaultFolder
			TryMeAgain = False
			Continue 'Do
			
		End If
		Exit 'Do
	Loop
	
	Log("download dir: " & DownloadDir)
	
	Dim m As Map : m.Initialize
	Dim errMsg As String
	m.Put("ok",Success)
	m.Put("file",file2dload)
	If LastException.Message.Contains("ETIMEDOUT") Then
		errMsg = "Connection timed out"
	Else
		errMsg = LastException.Message
	End If
	m.Put("err",errMsg)
	CallSubDelayed2(mCallbackMod,mCallbackEvent,m)
	
	Log("dload end: " & Success)
	
	FTP.Close
	Return Null
	
End Sub

Private Sub ftp_DownloadProgress(ServerPath As String, TotalDownloaded As Long, Total As Long)
	
	#if release
	mCntr = mCntr + 1
	If ((mCntr Mod 250) = 0) Then
		CallSub2(mCallbackMod,mCallbackEventProgress,TotalDownloaded)
	End If
	#end if
	
End Sub





