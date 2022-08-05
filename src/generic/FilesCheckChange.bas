B4A=true
Group=GENERIC
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
Sub Class_Globals
	Private  mainObj As B4XMainPage'ignore
	Private clvFiles As CustomListView
	Private IsBusy As Boolean = False
End Sub




Public Sub Initialize(CallingObj As B4XMainPage, listView As CustomListView)
	mainObj = CallingObj
	clvFiles = listView
End Sub



Public Sub CheckIfFilesChanged
	
	If IsBusy Then Return
	IsBusy = True
	

	'--- grab a list of files
	Dim rs As ResumableSub =  mainObj.cn.SendRequestGetInfo( oc.cFILES)
	Wait For(rs) Complete (Result As String)
	
	If Result.Length <> 0 Then
	
		'--- compre new list with old
		Dim o As JsonParserFiles  : o.Initialize
		Dim didChange As Boolean  = o.CheckIfChanged( Result,mainObj.gMapOctoFilesList)
		
		If didChange Then
			'--- ok, something changed
			mainObj.gMapOctoFilesList = o.GetAllFiles(Result)
			Log("refresh File list")
		End If
		
	End If
	
	IsBusy = False
	
End Sub



private Sub ProcessChanges(newFilesList As Map)
'	
'	'mainObj.gMapOctoFilesList = o.GetAllFiles(Result)
'	For Each o As typOctoFileInfo In newFilesList
'		
'		Try
'		
'			Dim fname As String = o.Name
'			Dim found As typOctoFileInfo
'			found = mainObj.gMapOctoFilesList.Get(fname)
'		
'			If found = Null Then
'				'--- file not found so lest add it
'				mainObj.gMapOctoFilesList
'			End If
'	
'			
'		Catch
'			Log(LastException)
'		End Try
'		
'		
'	Next
'	
	
End Sub



