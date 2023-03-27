B4J=true
Group=OCTOPRINT\PARSORS
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic, Kherson Ukraine
#Region VERSIONS 
' V. 1.0 	June/27/2022
#End Region

Sub Class_Globals

	Private Const mModule As String = "JsonParserFiles" 
	
	Public gMapFiles As Map
	
	Type tOctoFileInfo(Name As String, Size As String, Date As String,Thumbnail As String, _
						Origin As String, Path As String,Thumbnail_src As String,Volume As Double,  _
						Length As Double, Depth As Double, Width As Double, Height As Double, _
						myThumbnail_filename_disk As String,Thumbnail_original As String, _
						missingData As Boolean,hash As String,filament_total As Double,total_layers As String)
						
	Private mDownloadThumbnails As Boolean 'ignore
	Public CacheTarget As Int = 4
	#if klipper
	Private klipperCacheTotal As Int = 0
	#end if
	
End Sub

Public Sub Initialize(DownloadThumbnails As Boolean)
	mDownloadThumbnails = DownloadThumbnails
End Sub

#if klipper
Public Sub StartParseAllFilesKlipper(jsonTXT As String) As ResumableSub
	gMapFiles.Initialize
	Wait For (ParseKlipper(jsonTXT)) Complete (b As Boolean)
	Return gMapFiles
End Sub
#Else
Public Sub StartParseAllFilesOcto(jsonTXT As String) As Map
	gMapFiles.Initialize
	ParseOcto(jsonTXT)
	Return gMapFiles
End Sub
#End If


'==========================================================================================

#Region "CHECK_FOR_SOME_CHANGES"

Public Sub CheckIfChanged(jsonTXT As String,oldMap As Map) As Boolean
	
	
	'--- just tell them something has changed
	'--- just tell them something has changed
	'--- just tell them something has changed
	'--- just tell them something has changed
	
	
	Dim InSub As String = "CheckIfChanged"
	Dim parser As JSONParser
	parser.Initialize(jsonTXT)
	Dim root As Map = parser.NextObject
	Dim totalFiles As Int = 0
	'Log(jsonTXT)
	
	
	#if klipper
	
	Dim result As List = root.Get("result")
	For Each colfiles As Map In result
		
		Try
			Dim fileDate, fileName As String
			fileDate = colfiles.Get("modified")
			fileName = colfiles.Get("path")
			'size = colfiles.Get("size")
		Catch
			logMe.LogIt2("Parse00: " & LastException,mModule,InSub)
		End Try
		
		'--- see if we have this file in the original map
		Dim ff As tOctoFileInfo
		ff = oldMap.Get(fileName)
		
		If ff = Null Then
			'--- we did Not find this file so lets tell them something changed (file was added)
			If config.logFILE_EVENTS Then logMe.LogIt2("file added",mModule,InSub)
			Return True '--- bail out, something changed
		Else
			If ff.Date <> fileDate Then
				'--- file is there but date changed, tell them (same file name, new date)
				If config.logFILE_EVENTS Then logMe.LogIt2("same file name, new date",mModule,InSub)
				Return True '--- bail out, something changed
			End If
		End If
			
		totalFiles = totalFiles + 1

	Next
	
	#else
	
	Dim files As List = root.Get("files")
	Dim fileDate As String, fileName As String, hash As String
	
	For Each colfiles As Map In files
		Try
			If colfiles.Get("type") = "folder" Then 
		  		'--- not supporting dir at the moment
				'--- this can fire if they add a dir
				Continue
			End If
			
			fileDate = colfiles.Get("date")
			fileName =  colfiles.Get("display")
			hash = colfiles.Get("hash")
			
		Catch
			logMe.LogIt2("ParseComp00: ",mModule,InSub)
		End Try
	'Log(fileName & fileDate)

		'--- see if we have this file in the original map
		Dim ff As tOctoFileInfo
		ff = oldMap.Get(fileName)

		If ff = Null Then
			'--- we did Not find this file so lets tell them something changed (file was added)
			If config.logFILE_EVENTS Then logMe.LogIt2("file added",mModule,InSub)
			Return True '--- bail out, something changed
			
		Else
			If ((hash <> "") And ff.hash <> hash) Or ff.Date <> fileDate Then
				'--- file is there but date changed, tell them (same file name, new date)
				If config.logFILE_EVENTS Then logMe.LogIt2("same file name, new hash/date",mModule,InSub)
				Return True '--- bail out, something changed
			End If
			
		End If
		totalFiles = totalFiles + 1
	Next
	#End If
	
	
	If oldMap.Size <> totalFiles Then
		Log("files have been removed or added")
		Return True '--- files have been removed, tell them!!!!
	Else
		Return False '--- nothing has changed, all good!
	End If
	
	
	
	
End Sub
#end region


#if klipper
'Dim parser As JSONParser
'parser.Initialize(<text>)
'Dim root As Map = parser.NextObject
'Dim result As List = root.Get("result")
'For Each colresult As Map In result
'	Dim path As String = colresult.Get("path")
'	Dim size As Int = colresult.Get("size")
'	Dim permissions As String = colresult.Get("permissions")
'	Dim modified As Double = colresult.Get("modified")
'Next
Private Sub ParseKlipper(jsonTXT As String) As ResumableSub 'ignore
	Dim Const InSub As String = "ParseKlipper"
	Dim parser As JSONParser
	parser.Initialize(jsonTXT)
	Dim root As Map = parser.NextObject
	Dim result As List = root.Get("result")
	For Each colfiles As Map In result
		
		Dim ff As tOctoFileInfo
		Try
			ff.Date = colfiles.Get("modified")
			ff.path = colfiles.Get("path")
			ff.Name = ff.path
			ff.myThumbnail_filename_disk = ""
			'ff.Thumbnail_original = ""

			ff.Size = colfiles.Get("size")
			'ff.hash = "" 'fnc.guid
			
			Log(ff.name)
			Wait For (GetExtendedFileInfo(ff)) Complete (b As Boolean)
			
			
		Catch
			logMe.LogIt2("Parse00: " & LastException,mModule,InSub)
		End Try
		
		'--- stash results to map
		gMapFiles.Put(ff.Name,ff)
	Next
	
	Return True

End Sub

#Else

Private Sub ParseOcto(jsonTXT As String)
	

	'jsonTXT = File.ReadString(File.DirAssets,"ftest.txt")
	
	Dim InSub As String = "Parse"
	Dim parser As JSONParser
	parser.Initialize(jsonTXT)
	Dim root As Map = parser.NextObject
	'Dim total As String = root.Get("total")
	Dim files As List = root.Get("files")
	
	Dim cacheTTL As Int = 0
	
	For Each colfiles As Map In files

		Dim ff As tOctoFileInfo
		
		Try
			
			If colfiles.Get("type") = "folder" Then
				Continue '--- its a folder
			End If
			
			Try
				ff.Date = colfiles.Get("date")
			Catch
				logMe.LogIt2("Parse00: " & LastException,mModule,InSub)
			End Try
			Try
				ff.Thumbnail = colfiles.Get("thumbnail")
				ff.Thumbnail_original = ff.Thumbnail '--- has date code appended to name
			Catch
				logMe.LogIt2("Parse03: " & LastException,mModule,InSub)
			End Try
			Try
				ff.Name = colfiles.Get("display")
			Catch
				logMe.LogIt2("Parse04: " & LastException,mModule,InSub)
			End Try
			Try
				ff.origin = colfiles.Get("origin")
			Catch
				logMe.LogIt2("Parse05: " & LastException,mModule,InSub)
			End Try

	'If ff.Name.StartsWith("3D") Then LogColor("starts with --> "&ff.Thumbnail,Colors.Green)
			Try
				If ff.Thumbnail.Length <> 0 And ff.Thumbnail <> "null" Then
					ff.Thumbnail =  ff.Thumbnail.SubString2(0,ff.Thumbnail.IndexOf("?"))
					ff.myThumbnail_filename_disk = fnc.BuildThumbnailTempFilename(fnc.GetFilenameFromHTTP(ff.Thumbnail))
				Else
					ff.Thumbnail = ""
					ff.myThumbnail_filename_disk = ""
				End If
			Catch
				logMe.LogIt2("ParseFile 3: " & LastException,mModule,InSub)
				ff.Thumbnail = ""
				ff.myThumbnail_filename_disk = ""
			End Try
			
'			Try
'				ff.Path = colfiles.Get("path")
'			Catch
'				logMe.LogIt2("Parse00x: " & LastException,mModule,InSub)
'			End Try
			Try
				ff.hash = colfiles.Get("hash")
			Catch
				logMe.LogIt2("Parse09x: " & LastException,mModule,InSub)
			End Try
			Try
				ff.Size = colfiles.Get("size")
			Catch
				logMe.LogIt2("Parse00y: " & LastException,mModule,InSub)
			End Try
			
			Try                                          'gcodeAnalysis
				
				Dim gcodeAnalysis As Map = colfiles.Get("gcodeAnalysis")
				'Dim estimatedPrintTime As Double = gcodeAnalysis.Get("estimatedPrintTime")
				Dim filament As Map = gcodeAnalysis.Get("filament")
				Dim tool0 As Map = filament.Get("tool0")
				ff.Volume = GetVolume(tool0.Get("volume"))
				ff.Length = GetLength(tool0.Get("length")) ' * .001
		
				Dim dimensions As Map = gcodeAnalysis.Get("dimensions")
				ff.Depth = dimensions.Get("depth")
				ff.Width = dimensions.Get("width")
				ff.Height = dimensions.Get("height")
			Catch
				'--- thinking if we error out here - octoprint has not finished parsing the newly
				'--- added file so the gcode analisys is incomplete
				ff.missingData = True
				logMe.LogIt2("ParseFile-missingData=True",mModule,InSub)
			End Try
			
		Catch
			logMe.LogIt2("ParseFile 2: " & LastException,mModule,InSub)
		End Try
		
		If mDownloadThumbnails And (ff.Thumbnail.Length <> 0 And ff.Thumbnail <> "null")  And cacheTTL < CacheTarget Then
							   
			'--- cache files (will be random because of the sort)
			'--- but if you only have a few files will not really matter
			
			cacheTTL = cacheTTL + 1
			CallSub3(B4XPages.MainPage.oMasterController,"Download_ThumbnailAndCache2File",ff.Thumbnail,ff.myThumbnail_filename_disk)
			
		End If
		
		'--- stash results to map
		gMapFiles.Put(ff.Name,ff)
		
	Next
	
'	If gMapFiles.IsInitialized = False Then
'		logMe.LogIt2("gMapFiles not init'd",mModule,InSub)
'	End If
'	If gMapFiles.Size = 0 Then
'		logMe.LogIt2("gMapFiles is 0 size",mModule,InSub)
'	End If
	
End Sub
#End If


#region "Octo sample JSON"

'====================================================================================
'   OCTOPRINT STUFF
'====================================================================================

'Dim parser As JSONParser
'parser.Initialize(<text>)
'Dim root As Map = parser.NextObject
'Dim total As String = root.Get("total")
'Dim files As List = root.Get("files")
'For Each colfiles As Map In files
'	Dim date As Int = colfiles.Get("date")
'	Dim thumbnail_src As String = colfiles.Get("thumbnail_src")
'	Dim thumbnail As String = colfiles.Get("thumbnail")
'	Dim arc_welder As String = colfiles.Get("arc_welder")
'	Dim display As String = colfiles.Get("display")
'	Dim origin As String = colfiles.Get("origin")
'	Dim arc_welder_statistics As Map = colfiles.Get("arc_welder_statistics")
'	Dim arcs_created As Int = arc_welder_statistics.Get("arcs_created")
'	Dim target_file_total_length As Double = arc_welder_statistics.Get("target_file_total_length")
'	Dim compression_percent As Double = arc_welder_statistics.Get("compression_percent")
'	Dim source_file_position As Int = arc_welder_statistics.Get("source_file_position")
'	Dim source_file_total_count As Int = arc_welder_statistics.Get("source_file_total_count")
'	Dim target_file_total_count As Int = arc_welder_statistics.Get("target_file_total_count")
'	Dim lines_processed As Int = arc_welder_statistics.Get("lines_processed")
'	Dim target_file_size As Int = arc_welder_statistics.Get("target_file_size")
'	Dim compression_ratio As Double = arc_welder_statistics.Get("compression_ratio")
'	Dim seconds_elapsed As Double = arc_welder_statistics.Get("seconds_elapsed")
'	Dim segment_statistics_text As String = arc_welder_statistics.Get("segment_statistics_text")
'	Dim source_file_total_length As Double = arc_welder_statistics.Get("source_file_total_length")
'	Dim preprocessing_job_guid As String = arc_welder_statistics.Get("preprocessing_job_guid")
'	Dim source_filename As String = arc_welder_statistics.Get("source_filename")
'	Dim target_filename As String = arc_welder_statistics.Get("target_filename")
'	Dim gcodes_processed As Int = arc_welder_statistics.Get("gcodes_processed")
'	Dim source_file_size As Int = arc_welder_statistics.Get("source_file_size")
'	Dim points_compressed As Int = arc_welder_statistics.Get("points_compressed")
'	Dim Type As String = colfiles.Get("type")
'	Dim prints As Map = colfiles.Get("prints")
'	Dim last As Map = prints.Get("last")
'	Dim date As Double = last.Get("date")
'	Dim success As String = last.Get("success")
'	Dim printTime As Double = last.Get("printTime")
'	Dim failure As Int = prints.Get("failure")
'	Dim success As Int = prints.Get("success")
'	Dim path As String = colfiles.Get("path")
'	Dim typePath As List = colfiles.Get("typePath")
'	For Each coltypePath As String In typePath
'	Next
'	Dim size As Int = colfiles.Get("size")
'	Dim refs As Map = colfiles.Get("refs")
'	Dim download As String = refs.Get("download")
'	Dim resource As String = refs.Get("resource")
'	Dim DisplayLayerProgress As Map = colfiles.Get("DisplayLayerProgress")
'	Dim totalLayerCountWithoutOffset As String = DisplayLayerProgress.Get("totalLayerCountWithoutOffset")
'	Dim name As String = colfiles.Get("name")
'	Dim gcodeAnalysis As Map = colfiles.Get("gcodeAnalysis")
'	Dim analysisLastFilamentPrintTime As Double = gcodeAnalysis.Get("analysisLastFilamentPrintTime")
'	Dim lastFilament As Double = gcodeAnalysis.Get("lastFilament")
'	Dim analysisPending As String = gcodeAnalysis.Get("analysisPending")
'	Dim analysisFirstFilamentPrintTime As Double = gcodeAnalysis.Get("analysisFirstFilamentPrintTime")
'	Dim analysisPrintTime As Double = gcodeAnalysis.Get("analysisPrintTime")
'	Dim estimatedPrintTime As Double = gcodeAnalysis.Get("estimatedPrintTime")
'	Dim firstFilament As Double = gcodeAnalysis.Get("firstFilament")
'	Dim progress As List = gcodeAnalysis.Get("progress")
'	For Each colprogress As List In progress
'		For Each colcolprogress As Int In colprogress
'		Next
'	Next
'	Dim compensatedPrintTime As Double = gcodeAnalysis.Get("compensatedPrintTime")
'	Dim filament As Map = gcodeAnalysis.Get("filament")
'	Dim tool0 As Map = filament.Get("tool0")
'	Dim volume As Double = tool0.Get("volume")
'	Dim length As Double = tool0.Get("length")
'	Dim dimensions As Map = gcodeAnalysis.Get("dimensions")
'	Dim depth As Double = dimensions.Get("depth")
'	Dim width As Double = dimensions.Get("width")
'	Dim height As Double = dimensions.Get("height")
'	Dim printingArea As Map = gcodeAnalysis.Get("printingArea")
'	Dim minY As Double = printingArea.Get("minY")
'	Dim maxZ As Double = printingArea.Get("maxZ")
'	Dim minX As Double = printingArea.Get("minX")
'	Dim maxY As Double = printingArea.Get("maxY")
'	Dim maxX As Double = printingArea.Get("maxX")
'	Dim minZ As Int = printingArea.Get("minZ")
'	Dim hash As String = colfiles.Get("hash")
'	Dim statistics As Map = colfiles.Get("statistics")
'	Dim lastPrintTime As Map = statistics.Get("lastPrintTime")
'	Dim _default As Double = lastPrintTime.Get("_default")
'	Dim averagePrintTime As Map = statistics.Get("averagePrintTime")
'	Dim _default As Double = averagePrintTime.Get("_default")
'Next
'Dim free As String = root.Get("free")
#end region

#region HELPER VAR PARSERS

#if klipper
Private Sub ParseDouble(v As String) As Double
	Return(GetLength(v))
End Sub
#end if


Private Sub GetLength(v As String) As Double 'ignore
	Try
		If (v <> Null And v <> "null" And v <> 0) Then
			Return Round2(v.As(Double) * .001,2)
		End If
	Catch
		'Log("GetLength:" & LastException)
	End Try 'ignore
	
	Return 0
End Sub

Private Sub GetVolume(v As String) As Double 'ignore
	Try
		If (v <> Null And v <> "null" And v <> 0) Then
			Return Round2(v.As(Double),2)		
		End If
	Catch
		'Log("GetVolume:" & LastException)
	End Try 'ignore
	
	Return 0
End Sub
#END REGION






#if klipper
'====================================================================================
'   KLIPPER - MOONRAKER STUFF
'====================================================================================

Public Sub GetKlipperFilePath() As ResumableSub
	Try
	
		Dim rs As ResumableSub =  B4XPages.MainPage.oMasterController.CN.SendRequestGetInfo("/server/files/roots")
		Wait For(rs) Complete (Result1 As String)
		If Result1.Length <> 0 Then
			Dim parser1 As JSONParser
			parser1.Initialize(Result1)
			Dim root As Map = parser1.NextObject
			Dim r As List = root.Get("result")
			For Each colresult As Map In r
				If colresult.Get("name") = "gcodes" Then
					Return colresult.Get("path")
					Exit 'For
				End If
			Next
		End If
		
	Catch
		logMe.LogIt2(LastException.Message,mModule,"GetKlipperFilePath")
	End Try
	Return ""
	
End Sub


Private Sub GetExtendedFileInfo(ff As tOctoFileInfo)As ResumableSub

	Dim ep As String = "/server/files/metadata?filename=" & ff.Path
	'Dim ep As String = "/server/files/metadata?filename=" & oc.KlipperFileSrcPath & "/" &  ff.Path
	Dim rs As ResumableSub =  B4XPages.MainPage.oMasterController.CN.SendRequestGetInfo(ep)
	Wait For(rs) Complete (RetVal As String)
	Try
	
		If RetVal.Length <> 0 Then
			Dim parser As JSONParser
			parser.Initialize(RetVal)
			Dim root As Map = parser.NextObject
			Dim Result As Map = root.Get("result")
			
			ff.Height = ParseDouble( Result.Get("object_height"))
			ff.filament_total = ParseDouble(Result.Get("filament_total"))
			
			Dim thumbnails As List = Result.Get("thumbnails")
			For Each colthumbnails As Map In thumbnails
				
				Dim width As Int = colthumbnails.Get("width")
				If width < 48 Then Continue
				
				Try
					ff.Thumbnail = colthumbnails.Get("relative_path")
					
					If ff.Thumbnail.Length <> 0 And ff.Thumbnail <> "null" Then
						Dim tmp As String = ff.Thumbnail.SubString(ff.Thumbnail.IndexOf("/")+1)
						ff.myThumbnail_filename_disk = fnc.BuildThumbnailTempFilename(fnc.GetFilenameFromHTTP(tmp))
						
						If klipperCacheTotal < CacheTarget And mDownloadThumbnails = True Then
							klipperCacheTotal = klipperCacheTotal + 1
							CallSub3(B4XPages.MainPage.oMasterController,"Download_ThumbnailAndCache2File",ff.Thumbnail,ff.myThumbnail_filename_disk)
						End If
						
					Else
						ff.Thumbnail = ""
						ff.myThumbnail_filename_disk = ""
					End If
				Catch
					'logMe.LogIt2("ParseFile 3: " & LastException,mModule,InSub)
					ff.Thumbnail = ""
					ff.myThumbnail_filename_disk = ""
				End Try
				
			Next
			
			Return True '--- all good
		End If
		
	Catch
		Log(LastException)
	End Try
	
	Return False '--- bad
	
End Sub

'Dim parser As JSONParser
'parser.Initialize(<text>)
'Dim root As Map = parser.NextObject
'Dim Result As Map = root.Get("result")
'Dim slicer As String = Result.Get("slicer")
'Dim first_layer_extr_temp As Double = Result.Get("first_layer_extr_temp")
'Dim gcode_end_byte As Int = Result.Get("gcode_end_byte")
'Dim object_height As Double = Result.Get("object_height")
'Dim first_layer_bed_temp As Double = Result.Get("first_layer_bed_temp")
'Dim filament_type As String = Result.Get("filament_type")
'Dim first_layer_height As Double = Result.Get("first_layer_height")
'Dim layer_height As Double = Result.Get("layer_height")
'Dim uuid As String = Result.Get("uuid")
'Dim nozzle_diameter As Double = Result.Get("nozzle_diameter")
'Dim filament_weight_total As Double = Result.Get("filament_weight_total")
'Dim filename As String = Result.Get("filename")
'Dim size As Int = Result.Get("size")
'Dim job_id As String = Result.Get("job_id")
'Dim slicer_version As String = Result.Get("slicer_version")
'Dim modified As Double = Result.Get("modified")
'Dim filament_total As Double = Result.Get("filament_total")
'Dim gcode_start_byte As Int = Result.Get("gcode_start_byte")
'Dim filament_name As String = Result.Get("filament_name")
'Dim thumbnails As List = Result.Get("thumbnails")
'For Each colthumbnails As Map In thumbnails
'	Dim size As Int = colthumbnails.Get("size")
'	Dim width As Int = colthumbnails.Get("width")
'	Dim relative_path As String = colthumbnails.Get("relative_path")
'	Dim height As Int = colthumbnails.Get("height")
'Next
'Dim estimated_time As Int = Result.Get("estimated_time")
'Dim print_start_time As Double = Result.Get("print_start_time")
'
#End If