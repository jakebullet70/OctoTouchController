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
	Private Const mModule As String = "strHelper" 'ignore
End Sub

public Sub ConvertLinuxLineEndings2Windows(s As String) As String
	Return s.Replace(Chr(10),Chr(13) & Chr(10))
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






