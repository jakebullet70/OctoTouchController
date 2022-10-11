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
	
	Private mCallbackMod As Object
	Private mCallbackEvent As String
	
	Public FTP As FTP
	
End Sub

Public Sub Initialize(callback_mod As Object,callback_event As String, _
				host As String, port As Int, user As String, pw As String)
	
	mCallbackEvent = callback_event
	mCallbackMod   = callback_mod
	
	FTP.Initialize("ftp",host,port,user,pw)
		
End Sub

Public Sub CleanUpApkDownload
	
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_NAME)
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_FILE_INFO)
	
End Sub

Public Sub Download(file2dload As String,dLoadServerPath As String,isAscII As Boolean) As ResumableSub
	
	Dim dLoadMe As String = File.Combine(dLoadServerPath,file2dload)
	Log("dload start")
	FTP.UseSSL = False
	FTP.PassiveMode = False
	FTP.TimeoutMs = 20000 '--- 20 seconds
	
	Dim sf As Object = FTP.DownloadFile(dLoadMe, isAscII, Starter.Provider.SharedFolder,file2dload)
	Wait For (sf) ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
	
	CallSubDelayed3(mCallbackMod,mCallbackEvent,Success,file2dload)
	
	Log("dload end")
	
	FTP.Close
	
End Sub

Private Sub ftp_DownloadProgress (ServerPath As String, TotalDownloaded As Long, Total As Long)
	Log("progress")
End Sub





