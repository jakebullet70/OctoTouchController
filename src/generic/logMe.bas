B4J=true
Group=GENERIC
ModulesStructureVersion=1
Type=StaticCode
Version=8.9
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
Sub Process_Globals
	Private xui As XUI
	
	Public pDaysOfOldLogsBeforeDelete As Int = 2
	
	Private mLogFilePath As String
	Private mLogFileNameBase As String
	Private mLogFileName As String
	Private mLogFileExt As String
	
	Public pLogFull  As Boolean = False '--- log EVERYTHING to disk , get in options page
	
	Public pLog2DebugWindowRestAPI As Boolean = False
	Public pLog2DebugWindow As Boolean = False
	
'	Public cFILES_EVENTS = 1, cMAIN_TIMER_EVENTS = 2 As Int
'	Type typLogStyle (FILES_EVENTS As Int)
'	Public LogStype As typLogStyle
	
End Sub


'Initializes the object. You can add parameters to this method if needed.
Public Sub Init(folder As String, fname As String,ext As String)
	
	mLogFileNameBase = fname
	mLogFilePath = folder
	mLogFileExt = ext
	BuildLogFileName
	'RedirectOutputStart '--- only works in release mode
	
	'Clean_OldLogs
	
	'--- will be set in config class ---
	'	If File.Exists(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE) = True Then
	'		Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE)
	'		pLogFull =  Data.Get("fulllog").As(Boolean)
	'		gDaysOfOldLogsBeforeDelete =  Data.Get("days")
	'	End If
	
	
End Sub



Public Sub LogDebug2(txt As String, callingModule As String)
	#if b4j
	LogDebug(callingModule & " <--> " & txt) '--- TODO log it
	#else
		#If DEBUG
		Log(callingModule & " <--> " & txt)
		#End If
	#End if
End Sub



Public Sub LogIt(txt As String,callingModule As String)
	
	CheckIfNeedNewLogFile

	#if release
	'--- will log ALL to disk
	If pLogFull  Then
		Log("**  " & GetDateTime4LogMsg &  "  :--> " &  callingModule & " <--> " & txt)
	End If
	#Else
	If pLogFull = False Then
		#if release
			Log((callingModule & " <--> " & txt))
		#else
			Write2Disk(callingModule & " <--> " & txt)
		#end if
	Else
		Write2Disk(callingModule & " <--> " & txt)
	End If
	#End If

End Sub


Public Sub Log_DebuggerRestAPI(txt As String)
	#if release
	'--- will log to disk
	Log("**  " & GetDateTime4LogMsg &  "  :--> " &  txt)
	#Else
	If pLog2DebugWindowRestAPI And pLogFull = False Then 
		LogDebug2(txt,"")
	Else
		Write2DiskRestApi(txt)
	End If
	#End If

End Sub


'==============  Log routines ========================================
'==============  Log routines ========================================
'==============  Log routines ========================================


private Sub GetDateTime4LogMsg() As String
	
	DateTime.DateFormat= "yyyy-MM-dd"
	DateTime.TimeFormat = "HH:mm:ss.SSS"
	Return DateTime.Date(DateTime.Now) & " " & DateTime.Time(DateTime.TicksPerDay)
	
End Sub


private Sub Write2Disk2(strToLog As String,filename As String)
	
	Dim TextWriter1 As TextWriter
	strToLog = "********  " & GetDateTime4LogMsg &  "  ********" & CRLF & strToLog
	TextWriter1.Initialize(File.OpenOutput( mLogFilePath, filename, True))
	TextWriter1.WriteLine(strToLog)
	Log("*" & strToLog) '--- in debug mode will log to debug window
	TextWriter1.Close
	
End Sub


Private Sub Write2DiskRestApi(strToLog As String) 'ignore
	
	'--- writes just  API responses to different file.. 
	Write2Disk2(strToLog,mLogFileName & ".resp.api.log")
	
End Sub


public Sub Write2Disk(strToLog As String)
	
	Write2Disk2(strToLog,mLogFileName)
	
End Sub


public Sub Clean_OldLogs() 'ignore 

	Log("Clean_OldLogs")
	
	Dim flist As List
	flist = fileHelpers.WildCardFilesList(xui.DefaultFolder,"*.logs",False,False)
	For Each fname In flist
		
		Dim fDate As Long = File.LastModified(xui.DefaultFolder, fname)
		Dim numDays As Int = DaysBetweenDated(fDate,DateTime.Now)
		If  numDays > pDaysOfOldLogsBeforeDelete Then
			fileHelpers.SafeKill(fname)
			Log("deleting log file: " &  fname)
		End If
	Next
	
End Sub


Private Sub DaysBetweenDated(date1 As Long, date2 As Long) As Int
	Dim p As Period = DateUtils.PeriodBetweenInDays(date1, date2)
    Return p.Days
End Sub


Private Sub CheckIfNeedNewLogFile

	'TODO - this could be faster, refactor
	Dim tt As String = GetDay
	If mLogFileName.StartsWith(tt) = False Then
		BuildLogFileName
	End If
	
End Sub


private Sub BuildLogFileName() 
	
	'--- format a file name
	mLogFileName = GetDay & mLogFileNameBase  & "." & mLogFileExt
	
End Sub

Private Sub GetDay() As String
	
	DateTime.DateFormat = "yyyy-MM-dd_"
	Return DateTime.Date(DateTime.Now)
	
End Sub


''https://www.b4x.com/android/forum/threads/redirect-the-output-to-a-file.65165/
'private Sub RedirectOutputStart()
'   
''   #if RELEASE
''   Dim out As OutputStream = File.OpenOutput(mLogFilePath, "FULL-" & mLogFileName, False) 'Set to True to append the logs
''   Dim ps As JavaObject
''   ps.InitializeNewInstance("java.io.PrintStream", Array(out, True, "utf8"))
''   Dim jo As JavaObject
''   jo.InitializeStatic("java.langbl.System")
''   jo.RunMethod("setOut", Array(ps))
''   jo.RunMethod("setErr", Array(ps))
''   #end if
'   
'End Sub
'
'
'private Sub RedirectOutputEnd() 'ignore
'	
'	#if RELEASE
'	Dim out As OutputStream = File.OpenOutput(mLogFilePath, "FULL-" &  mLogFileName, False) 'Set to True to append the logs
'	Dim ps As JavaObject
'	ps.InitializeNewInstance("java.io.PrintStream", Array(out, True, "utf8"))
'	Dim fd As JavaObject
'	fd.InitializeStatic("java.io.FileDescriptor")
'	Dim jout As JavaObject
'	jout.InitializeNewInstance("java.io.FileOutputStream", Array(fd.GetField("out")))
'	ps.InitializeNewInstance("java.io.PrintStream", Array(jout, True, "utf8"))
'	#end if
'	
'End Sub




