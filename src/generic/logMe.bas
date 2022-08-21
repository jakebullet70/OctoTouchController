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

End Sub


'Initializes the object. You can add parameters to this method if needed.
Public Sub Init(folder As String, fname As String,ext As String)
	
	mLogFileNameBase = fname
	mLogFilePath = folder
	mLogFileExt = ext
	BuildLogFileName
	
End Sub



Public Sub LogDebug2(txt As String, callingModule As String)
	#If DEBUG
	Log(callingModule & " <--> " & txt)
	#end if
End Sub



Public Sub LogIt(txt As String, callingModule As String)
	
	CheckIfNeedNewLogFile

	#if release
	Write2Disk2("** " & GetDateTime4LogMsg &  " :--> " &  callingModule & " <--> " & txt,mLogFileName)
	#Else
	Log("**  " & GetDateTime4LogMsg &  "  :--> " &  callingModule & " <--> " & txt)
	#End If

End Sub
Public Sub LogIt2(txt As String, callingModule As String,callingSub As String)
	
	CheckIfNeedNewLogFile

	#if release
	Write2Disk2("** " & GetDateTime4LogMsg &  " :--> " &  callingModule & ":" & callingSub & " <--> " & txt,mLogFileName)
	#Else
	Log("**  " & GetDateTime4LogMsg &  "  :--> " &  callingModule & ":" & callingSub & " <--> " & txt)
	#End If

End Sub

'==============  Log routines ========================================
'==============  Log routines ========================================
'==============  Log routines ========================================


private Sub GetDateTime4LogMsg() As String
	
	DateTime.DateFormat= "yyyy-MM-dd"
	DateTime.TimeFormat = "HH:mm:ss.SS"
	Return DateTime.Date(DateTime.Now) & " " & DateTime.Time(DateTime.TicksPerDay)
	
End Sub


private Sub Write2Disk2(strToLog As String,filename As String)
	Dim Const FILE_APPEND As Boolean = True
	Dim TextWriter1 As TextWriter
	strToLog = "********  " & GetDateTime4LogMsg &  "  ********" & CRLF & strToLog
	TextWriter1.Initialize(File.OpenOutput(mLogFilePath, filename, FILE_APPEND))
	TextWriter1.WriteLine(strToLog)
	TextWriter1.Flush
	TextWriter1.Close
End Sub


public Sub Write2Disk(strToLog As String)
	If strToLog.Length = 0 Then strToLog = "empty"
	Write2Disk2(strToLog,mLogFileName)
End Sub


Public Sub DeleteOldFiles(fspec As String)
	Dim flist As List
	flist = fileHelpers.WildCardFilesList(xui.DefaultFolder,fspec,False,False)
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



