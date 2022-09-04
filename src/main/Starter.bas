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
	Public tmrTimerCallSub As CallSubUtils
	Public FirstRun As Boolean = True
	
	Private xui As XUI
	Private logcat As LogCat
End Sub

Sub Service_Create '--- This is the program entry point.
	tmrTimerCallSub.Initialize
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
	CallSub(Main,"Restart_App") '--- this code is there but seems to fail
	Return False
	#end if
End Sub


#if release
Private Sub ProcessCrash(Error As Exception, StackTrace As String)
	
	'--- wait for 500ms to allow the logs to be updated.
	Sleep(500)
	Dim logs As StringBuilder : logs.Initialize
	Dim spacer As String = $"${gblConst.WIN_CRLF}${gblConst.WIN_CRLF}${gblConst.WIN_CRLF}"$
	logcat.LogCatStop
	logs.Append(Error.Message).Append(gblConst.WIN_CRLF).Append(StackTrace)
	
	'--- TODO - make pretty as a HTML file
	Dim tmp As StringBuilder : tmp.Initialize
	tmp.Append(strHelpers.ConvertLinuxLineEndings2Windows(logs.ToString)).Append(spacer)
	'tmp.Append("").Append(spacer).Append(g.GetInfoStr2Display_HTML).Append(spacer)
	'tmp.Append("").Append(spacer).Append(g.GetProfilesIn_HTML).Append("--- END ---")
	
	'--- write to crash file
	Dim TW As TextWriter
	TW.Initialize(File.OpenOutput(xui.DefaultFolder, DateTime.now & ".crash", False))
	TW.Write(tmp.ToString)
	TW.Flush
	TW.Close
	
	logMe.Write2Disk(tmp) '--- append to normal logs too
	Sleep(200)
	
End Sub
#end if

Sub Service_Destroy
	Log("Service_Destroy")
End Sub

'===========================================================================

Public Sub Clean_OldLogs
	logMe.DeleteOldFiles("*.log")
	'---check every X hours for old logs / crash files
	Dim hrs As Int = 12
	tmrTimerCallSub.CallSubDelayedPlus(Me,"Clean_OldLogs",60000 * 60 * hrs)
End Sub
Public Sub Clean_OldCrash
	logMe.DeleteOldFiles("*.crash")
	'---check every X hours for old logs / crash files
	Dim hrs As Int = 12
	tmrTimerCallSub.CallSubDelayedPlus(Me,"Clean_OldCrash",60000 * 60 * hrs)
End Sub


Public Sub InitLogCleanup
	'--- in about 15 minutes check for old logs, crash files (3 days old) and delete them
	tmrTimerCallSub.CallSubDelayedPlus(Me,"Clean_OldLogs",60000 * 13)
	tmrTimerCallSub.CallSubDelayedPlus(Me,"Clean_OldCrash",60000 * 17)
End Sub


