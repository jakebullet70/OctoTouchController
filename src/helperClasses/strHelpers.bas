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
	'Private xui As XUI
	Private Const mModule As String = "strHelper" 'ignore
End Sub

public Sub ConvertLinuxLineEndings2Windows(s As String) As String
	Return s.Replace(Chr(10),Chr(13) & Chr(10))
End Sub

Public Sub ProperCase(s As String) As String
	s = s.ToLowerCase
	Dim m As Matcher = Regex.Matcher("\b(\w)", s)
	Do While m.Find
		Dim i As Int = m.GetStart(1)
		s = s.SubString2(0, i) & s.SubString2(i, i + 1).ToUpperCase & s.SubString(i + 1)
	Loop
	Return s
End Sub


public Sub Join(sepChar As String, Strings As List) As String
	
	Dim sb As StringBuilder
	sb.Initialize
	
	For Each s As String In Strings
		sb.Append(s).Append(sepChar)
	Next
	
	If sb.Length > 0 Then 
		sb.Remove(sb.Length - sepChar.Length, sb.Length)
	End If
	
	Return sb.ToString
	
End Sub


public Sub TrimLast(s As String, trimchar As String) As String
	
	If s.EndsWith(trimchar) Then
		Return s.SubString2(0,s.Length - 1)
	Else
		Return s
	End If
	
End Sub


public Sub Str2Bool(txt As String) As Boolean
	
	Try
		Dim tmp As String = txt.ToLowerCase.Trim
		If  tmp = "true" Or tmp <> "0"  Then
			Return True
		End If
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Return False
	
End Sub


'---------------------------------------------------------------------------------------------------
Public Sub WordWrap(txt As String, lineLen As Int) As String
	Dim wordList As List : wordList.Initialize
	wordList = CleanupPuncChar(Regex.Split("\b", txt))
	
	Dim sb As StringBuilder :  sb.Initialize
	Dim word As String, CurrLineSize = 0 As Int
	Dim wordListLen As Int = wordList.size - 1
	
	For wordPtr = 0 To wordListLen
		
		word = wordList.Get(wordPtr).As(String).Trim
		If word.Length = 0 Then Continue
		If sb.Length = 0 Then 
			sb.Append(word).Append(" ")
			Continue
		End If

		If wordPtr < wordListLen  Then
			If CurrLineSize + wordList.Get(wordPtr + 1).As(String).Length < lineLen Then
				sb.Append(word).Append(" ")
				CurrLineSize = CurrLineSize + word.Length + 1 
			Else
				sb.Append(word).Append(CRLF)
				CurrLineSize = 0
			End If
		End If
		
	Next
	Return sb.ToString
	
End Sub
Private Sub CleanupPuncChar(lst As List) As List
	'--- regex espression above with the /bissuppose
	'--- to include puctuation chars - its does not
	'--- so this is a cludge to clean that up -- TODO
	'--- when the bombs stop falling and you get internet again 
	'--- figure out why this is not working as it should
	Try
		For x = 0 To lst.Size - 1
			For Each ch As String In Array As String(".",",",":",";","?","!")
				If lst.Get(x) = ch Then
					Dim a1 As String = lst.Get(x-1)
					lst.Set(x-1,a1 & ch)
					lst.Set(x,"")
				End If
			Next
		Next	
	Catch
		Log(LastException)
	End Try
	Return lst
End Sub
'---------------------------------------------------------------------------------------------------


Public Sub StripHTML(txt As String) As String
	Dim parts() As String = Regex.Split(">",txt)
	txt = ""
	For x = 0 To parts.Length -1
		If parts(x).IndexOf("<")>-1 Then
			txt = txt & parts(x).SubString2(0,parts(x).IndexOf("<"))
		Else
			txt = txt & parts(x)
		End If
	Next
	Return txt
End Sub

