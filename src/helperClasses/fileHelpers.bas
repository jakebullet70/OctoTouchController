B4J=true
Group=HELPERS
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
'Static code module
Sub Process_Globals
	Private xui As XUI
	Private Const mModule As String = "fileHelpers" 'ignore
End Sub


'===========================================================================
'reads a single string value 
Public Sub Read_ReturnSingleValue(filename As String) As String
	If File.Exists(xui.DefaultFolder,filename) Then
		Dim lst As List = File.ReadList(xui.DefaultFolder,filename)
		Return lst.Get(0)
	End If
	Return ""
End Sub
'saves a single string value as a list obj to disk
Public Sub Write_SingleValue(filename As String, value As String)
	SafeKill(filename)
	Dim lst As List : lst.Initialize2(Array As String(value))
	File.WriteList(xui.DefaultFolder,filename,lst)
End Sub
'===========================================================================


public Sub CheckAndCleanFileName(StringToCheck As String) As String

	'=======================================================================
	'purpose: Eliminate characters that are not allowed in file/folder name
	'=======================================================================
	Dim sIllegal As String = "\`/`:`*`?`" & Chr(34) & "`<`>`|"
	Dim arIllegal() As String = Regex.Split( "`",sIllegal)
	Dim sReturn As String

	sReturn = StringToCheck

	For i = 0 To arIllegal.Length - 1
	    sReturn = sReturn.Replace(arIllegal(i), "_")
	Next

	Return sReturn
 
End Sub
	


Public Sub SafeKill(fname As String)
	
	SafeKill2(xui.DefaultFolder, fname) 
	
End Sub

Public Sub SafeKill2(folder As String, fname As String)
	
	If File.Exists(folder, fname) Then
		File.Delete(folder, fname)
	End If
	
End Sub


public Sub RemoveExtFromeFileName(fname As String) As String
	
	Try
		Return fname.SubString2(0,fname.LastIndexOf(".")).trim
	Catch
		Return fname
	End Try
	
End Sub


Public Sub GetFilenameFromPath(pathAndfname As String) As String
	
	Dim PathSepChar As String  = "/"
	
	Try
		Dim tt As Int = pathAndfname.LastIndexOf(PathSepChar)
		Return pathAndfname.SubString2(tt + 1,pathAndfname.Length)
	Catch
		Return pathAndfname
	End Try
	
	
End Sub



Public Sub BytesToReadableString(Bytes As String) As String
		
	If IsNumber(Bytes) = False Then Return "-"
	Dim Bytes1 As Double = Bytes

	Dim count As Int = 0
	Dim factor As Int = 1024 '--- could be 1000 for HD calc
	Dim Workingnum As Double = Bytes1
	Dim  Suffix As List = Array("Bytes", "KB", "MB", "GB", "TB", "PB")

	Do While Workingnum > factor And count < 5
		Workingnum = Workingnum / factor
		count = count + 1
	Loop
	
	Return $"${NumberFormat(Workingnum,1,2)}${Suffix.Get(count)}"$
	
End Sub



'Sub RenameFile(SrcDir As String, SrcFilename As String, DestDir As String, DestFilename As String) As Boolean
'	Dim R As Reflector, NewObj As Object, New As String , Old As String
'	If SrcFilename=Null Or DestFilename=Null Or SrcDir=Null Or DestDir=Null Then Return False
'	If File.Exists(SrcDir,SrcFilename) And Not(File.Exists(DestDir,DestFilename)) Then
'		New=File.Combine(DestDir,DestFilename)
'		Old=File.Combine(SrcDir,SrcFilename)
'		If Not(New = Old) Then
'			NewObj=R.CreateObject2("java.io.File",Array As Object(New),Array As String("java.lang.String"))
'			R.Target=R.CreateObject2("java.io.File",Array As Object(Old),Array As String("java.lang.String"))
'			Return R.RunMethod4("renameTo",Array As Object(NewObj),Array As String("java.io.File"))
'		End If
'	End If
'	Return False
'End Sub


' Inserts a CRLF at every N'th postition
' txt     = string of charactors
' lineLen = what position to insert the CRLF
'Public Sub WordWrap(txt As String, lineLen As Int) As String
'
'	Dim ss As StringBuilder : ss.Initialize
'	Dim pointer As Int = 0
'	
'	Do While pointer < txt.Length
'		If pointer + lineLen > txt.Length Then
'			ss.Append(txt.SubString2(pointer,txt.Length))
'		Else
'			ss.Append(txt.SubString2(pointer,pointer+lineLen)).Append(CRLF).Append(" ")
'		End If
'		pointer = pointer + lineLen
'	Loop
'
'	Return ss.ToString
'
'End Sub


'--- DEBUGGER code, use when needed
Public Sub DeleteFiles(folder As String, fileSpec As String)

	Dim o1 As WildCardFilesList : o1.Initialize
	Dim lstFolder As List = o1.GetFiles(folder,fileSpec,False,False)
	
	For Each filename As String In lstFolder
		If File.IsDirectory(folder, filename) Then
			Continue
		End If
		File.Delete(folder,filename)
	Next
	
End Sub



public Sub WriteTxt2Disk(str As String,folder As String, filename As String) 'ignore
	
	'---- Simple, just write out a TXT file, use in debugging long JSON files
	'--- TODO  see File.OpenOutput
	
	Dim TextWriter1 As TextWriter
	TextWriter1.Initialize(File.OpenOutput( folder, filename, True))
	TextWriter1.WriteLine(str)
	TextWriter1.Close
	
End Sub
