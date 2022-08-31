B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  Forum / sadLogic
#Region VERSIONS 
' V. 1.1 	Aug/22/2022
'			Added Async version
' V. 1.0	Unknown
#End Region

Sub Class_Globals
	Private emptyList As List
End Sub

Public Sub Initialize
	emptyList.Initialize
End Sub


Private Sub Filter(FilesFound As List,WildCards As String, Sorted As Boolean, Ascending As Boolean) As List
	
	Dim GetCards() As String = Regex.Split(",", WildCards)
	Dim FilteredFiles As List : FilteredFiles.Initialize
	
	For i = 0 To FilesFound.Size - 1
		For l = 0 To GetCards.Length - 1
				
			Dim TestItem As String = FilesFound.Get(i)
			Dim mask As String = GetCards(l).Trim
			Dim pattern As String = "^" & mask.Replace(".","\.").Replace("*",".+").Replace("?",".") & "$"
				
			If Regex.IsMatch(pattern,TestItem) = True Then
				FilteredFiles.Add(TestItem.Trim)
			End If
				
		Next
	Next
		
	If Sorted Then
		FilteredFiles.SortCaseInsensitive(Ascending)
	End If
		
	Return FilteredFiles
	
End Sub



public Sub GetFiles(FilesPath As String, WildCards As String, Sorted As Boolean, Ascending As Boolean) As List

	If File.IsDirectory("", FilesPath) Then
		
		Return Filter(File.ListFiles(FilesPath),WildCards,Sorted,Ascending)
		
	Else
		
		Return emptyList
		
	End If
	
End Sub



Public Sub GetFilesAsync(FilesPath As String, WildCards As String, Sorted As Boolean, Ascending As Boolean)As ResumableSub
	
	If File.IsDirectory("", FilesPath) Then
		
		Wait For (File.ListFilesAsync(FilesPath)) Complete (Success As Boolean, FilesFound As List)
		If Success = False Then Return emptyList
		
		Return Filter(FilesFound,WildCards,Sorted,Ascending)
		
	Else
		
		Return emptyList
		
	End If
	
End Sub

