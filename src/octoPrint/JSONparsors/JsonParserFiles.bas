B4J=true
Group=OCTOPRINT\PARSORS
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/27/2022
#End Region

Sub Class_Globals

	Private Const mModule As String = "JsonParserFiles" 'ignore
	
	Public gMapFiles As Map
	
	Type typOctoFileInfo( Name As String, Size As String, Date As Int,Thumbnail As String, _
						Origin As String, Path As String,Thumbnail_src As String,Volume As Double,  _
						Length As Double, Depth As Double, Width As Double, Height As Double, _
						myThumbnail_filename_disk As String,Thumbnail_original As String)
						
	Private mDownloadThumbnails As Boolean
End Sub


Public Sub Initialize(DownloadThumbnails As Boolean)
	mDownloadThumbnails = DownloadThumbnails
End Sub


#Region "CHECK_FOR_SOME_CHANGES"
Public Sub CheckIfChanged(jsonTXT As String, originalMap As Map) As Boolean
	
	'--- just tell them something has changed
	Return ParseCompareCheck(jsonTXT,originalMap)
	
End Sub


private Sub ParseCompareCheck(jsonTXT As String,oldMap As Map) As Boolean
	
	Dim parser As JSONParser
	parser.Initialize(jsonTXT)
	
	Dim root As Map = parser.NextObject
	Dim files As List = root.Get("files")
	Dim fileDate As Int, fileName As String
	Dim totalFiles As Int = 0
	
	For Each colfiles As Map In files
		
		fileDate = colfiles.Get("date")
		fileName =  colfiles.Get("display")

		'--- see if we have this file in the original map
		Dim ff As typOctoFileInfo
		ff = oldMap.Get(fileName)

		If ff = Null Then
			'--- we did Not find this file so lets tell them something changed (file was added)
			Log("file added")
			Return True
			
		Else
			
			If ff.Date <> fileDate Then
				'--- file is there but date changed, tell them (same file name, new date)
				Log("same file name, new date")
				Return True
			End If
			
		End If
		totalFiles = totalFiles + 1
	Next
	
	If oldMap.Size <> totalFiles Then
		Log("files have been removed or added")
		Return True '--- files have been removed
	Else
		Return False '--- nothing has changed
	End If
	
	
End Sub
#end region





Public Sub GetAllFiles(jsonTXT As String) As Map
	
	gMapFiles.Initialize
	Parse(jsonTXT)
	Return gMapFiles
	
End Sub


private Sub Parse(jsonTXT As String)
	
	Dim parser As JSONParser
	parser.Initialize(jsonTXT)
	
	Dim root As Map = parser.NextObject
	'Dim total As String = root.Get("total")
	Dim files As List = root.Get("files")
	For Each colfiles As Map In files

		Dim ff As typOctoFileInfo
		
		Try
			ff.Date = colfiles.Get("date")
			ff.Thumbnail_src = colfiles.Get("thumbnail_src")
			ff.Thumbnail = colfiles.Get("thumbnail")
			ff.Thumbnail_original = ff.Thumbnail '--- has date code appended to name
			ff.Name = colfiles.Get("display")
			ff.origin = colfiles.Get("origin")
			
			If ff.Thumbnail.Length <> 0 Then
				ff.Thumbnail =  ff.Thumbnail.SubString2(0,ff.Thumbnail.IndexOf("?"))
				ff.myThumbnail_filename_disk = fnc.BuildThumbnailTempFilename(fnc.GetFilenameFromHTTP(ff.Thumbnail))
			End If
			
			'Dim Type As String = colfiles.Get("type")
'		Dim prints As Map = colfiles.Get("prints")
'		Dim last As Map = prints.Get("last")
'		Dim date As Double = last.Get("date")
'		Dim success As String = last.Get("success")
'		Dim failure As Int = prints.Get("failure")
'		Dim success As Int = prints.Get("success")
			ff.Path = colfiles.Get("path")
			'Dim typePath As List = colfiles.Get("typePath")
			'For Each coltypePath As String In typePath
			'Next
			ff.Size = colfiles.Get("size")
			'Dim refs As Map = colfiles.Get("refs")
			'Dim download As String = refs.Get("download")
			'Dim resource As String = refs.Get("resource")
			'Dim name As String = colfiles.Get("name")
			Try
				Dim gcodeAnalysis As Map = colfiles.Get("gcodeAnalysis")
				'Dim estimatedPrintTime As Double = gcodeAnalysis.Get("estimatedPrintTime")
				Dim filament As Map = gcodeAnalysis.Get("filament")
				Dim tool0 As Map = filament.Get("tool0")
				ff.Volume = tool0.Get("volume")
				ff.Length = tool0.Get("length")
		
				Dim dimensions As Map = gcodeAnalysis.Get("dimensions")
				ff.Depth = dimensions.Get("depth")
				ff.Width = dimensions.Get("width")
				ff.Height = dimensions.Get("height")
			Catch
				'--- thinking if we error out here - octoprint has notfinished parsing the newly
				'--- added file so its incomplete
				Log("ParseFile 1: " & LastException)
			End Try
				
'		Dim printingArea As Map = gcodeAnalysis.Get("printingArea")
'		Dim minY As Double = printingArea.Get("minY")
'		Dim maxZ As Double = printingArea.Get("maxZ")
'		Dim minX As Double = printingArea.Get("minX")
'		Dim maxY As Double = printingArea.Get("maxY")
'		Dim maxX As Double = printingArea.Get("maxX")
'		Dim minZ As Double = printingArea.Get("minZ")
'		Dim hash As String = colfiles.Get("hash")
'		Dim statistics As Map = colfiles.Get("statistics")
'		Dim lastPrintTime As Map = statistics.Get("lastPrintTime")
'		Dim _default As Double = lastPrintTime.Get("_default")
'		Dim averagePrintTime As Map = statistics.Get("averagePrintTime")
'		Dim _default As Double = averagePrintTime.Get("_default")
	
		Catch
			Log("ParseFile 2: " & LastException)
		End Try
		
		If mDownloadThumbnails And  ff.Thumbnail.Length <> 0 Then
			CallSub3(B4XPages.MainPage.MasterCtrlr,"Download_ThumbnailAndCache2File",ff.Thumbnail,ff.myThumbnail_filename_disk)
		End If
		
		'--- stash results to map
		gMapFiles.Put(ff.Name,ff)
		
	Next
	'Dim free As String = root.Get("free")

End Sub


