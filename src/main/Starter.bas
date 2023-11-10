B4A=true
Group=MAIN
ModulesStructureVersion=1
Type=Service
Version=9.85
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	Private xui As XUI
	Private logcat As LogCat
End Sub


Sub Service_Create '--- This is the program entry point.
	
	Log("Service_Create - starter")

	#if Release
	logcat.LogCatStart(Array As String("-v","raw","*:F","B4A:v"), "logcat")
	#end if
	
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	Log("Service_TaskRemoved")
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	#if debug
	Return True
	#else
	ProcessCrash(Error,StackTrace)
	Try
		B4XPages.MainPage.oMasterController.oWS.wSocket.Close
	Catch
	End Try	'ignore
	CallSub3("Main", "Show_Unhandled_Error", Error, StackTrace) 
	'CallSub(Main,"Restart_App") '--- this code is there but seems to fail
	Return False
	#end if
End Sub


#if release
Private Sub ProcessCrash(Error As Exception, StackTrace As String)

	Dim Const WIN_CRLF As String = Chr(10) & Chr(13)
	
	'--- wait for 500ms to allow the logs to be updated.
	Sleep(500)
	Dim logs As StringBuilder : logs.Initialize
	Dim spacer As String = $"${WIN_CRLF}${WIN_CRLF}${WIN_CRLF}"$
	logcat.LogCatStop
	logs.Append(Error.Message).Append(WIN_CRLF).Append(StackTrace)
	
	Dim tmp As StringBuilder : tmp.Initialize
	tmp.Append(logs.ToString.Replace(Chr(10),WIN_CRLF)).Append(spacer)
	
	'--- write to crash file
	File.WriteString(xui.DefaultFolder, DateTime.now & ".crash",tmp.ToString)
		
	'logMe.Write2Disk(tmp) '--- append to normal logs too
	Sleep(200)
	
End Sub
#end if

Sub Service_Destroy
	Log("Service_Destroy")
End Sub


' -----  EMPTY STARTER SERVICE TEMPLATE
' -----  EMPTY STARTER SERVICE TEMPLATE
' -----  EMPTY STARTER SERVICE TEMPLATE
' -----  EMPTY STARTER SERVICE TEMPLATE


'Sub Service_Create
'	'This is the program entry point.
'	'This is a good place to load resources that are not specific to a single activity.
'
'End Sub
'
'Sub Service_Start (StartingIntent As Intent)
'	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
'End Sub
'
'Sub Service_TaskRemoved
'	'This event will be raised when the user removes the app from the recent apps list.
'End Sub
'
''Return true to allow the OS default exceptions handler to handle the uncaught exception.
'Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
'	Return True
'End Sub
'
'Sub Service_Destroy
'
'End Sub

