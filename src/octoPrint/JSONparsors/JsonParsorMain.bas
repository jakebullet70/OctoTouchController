B4J=true
Group=OCTOPRINT\PARSORS
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
Sub Class_Globals
	Private xui As XUI
	Private Const mModule As String = "JsonParserMain" 'ignore
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
End Sub


public Sub ServerOctoVersion(s As String) 

	Try
		
		Dim m As Map,  jp As JSONParser
		jp.Initialize(s)
		m = jp.NextObject
		oc.OctoVersion = m.Get("version")
		oc.isConnected = True
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
End Sub


public Sub TempStatus(s As String)
	Dim m, mTemp, mBed, mTool1, mTool2 As Map
	Dim jp As JSONParser
	
	Try
		
		oc.isHeating = False
		Dim TargetBedCheck As Int
		Dim TargetToolCheck As Int
	
		'--- populate vars from json
		jp.Initialize(s)
		m = jp.NextObject
		mTemp = m.Get("temperature").As(Map)
		
		mBed = mTemp.Get("bed").As(Map)
		TargetBedCheck = mBed.Get("target")
		oc.BedActual = mBed.Get("actual") & gblConst.DEGREE_SYMBOL & "C"
		oc.BedTarget = TargetBedCheck.As(String)  & gblConst.DEGREE_SYMBOL & "C"
		
		mTool1 = mTemp.Get("tool0").As(Map)
		TargetToolCheck = mTool1.Get("target")
		oc.Tool1Actual = mTool1.Get("actual") & gblConst.DEGREE_SYMBOL & "C"
		oc.Tool1Target = TargetToolCheck.As(String) & gblConst.DEGREE_SYMBOL & "C"
			
		'---  is there a tool 2
		mTool2 = mTemp.Get("tool1").As(Map)
		If mTool2.IsInitialized = True Then
			oc.Tool2Actual = mTool2.Get("actual") & gblConst.DEGREE_SYMBOL & "C"
			oc.Tool2Target = mTool2.Get("target") & gblConst.DEGREE_SYMBOL & "C"
		End If
		
		If TargetBedCheck <> 0 Or TargetToolCheck <> 0 Then
			
			'--- bed / tool is set to heat
			Dim bedCheckOffset As Int = 2
			Dim toolCheckOffset As Int = 5
			Dim bedActual As Int = mBed.Get("actual")
			Dim toolActual As Int = mTool1.Get("actual")
			If (bedActual + bedCheckOffset <= TargetBedCheck) Or (toolActual + toolCheckOffset <= TargetToolCheck) Then
				oc.isHeating = True
			Else
				oc.isHeating = False
			End If
	
		End If
		
			
	Catch
		
		logMe.LogIt(LastException,mModule)
		oc.ResetTempVars
		
	End Try
	
End Sub


public Sub  JobStatus(s As String)
	
	Dim m, mProgress, mJob, mFile As Map
	Dim jp As JSONParser
	
	Try
		
		jp.Initialize(s)
		m = jp.NextObject
		
		'--- reset status of printer -------------
		oc.isCanceling = False
		oc.isPrinting = False
		oc.isPaused2 = False

		'---- get status		
		oc.JobPrintState = m.Get("state")
		Select Case oc.JobPrintState
			Case "Printing"     : oc.isPrinting = True
			Case "Cancelling" : oc.isCanceling = True
			Case "Paused"      : oc.isPaused2 = True
		End Select
		
		'--- populate vars from json 
		mJob = m.Get("job").As(Map)
		mFile = mJob.Get("file").As(Map)
		mProgress = m.Get("progress").As(Map)
	
		oc.JobFileName = mFile.Get("name")
		If oc.JobFileName = "null" Then oc.JobFileName = ""
		
		oc.isFileLoaded = (oc.JobFileName.Length <> 0)
		
		oc.JobFileOrigin = mFile.Get("origin")
		oc.JobFileSize = mFile.Get("size")
	
		oc.JobEstPrintTime = IIf(mJob.Get("estimatedPrintTime") = "",mJob.Get("estimatedPrintTime"),"N/A")
		
		oc.JobCompletion = mProgress.Get("completion")
		oc.JobFilePos = mProgress.Get("filepos")
		oc.JobPrintTime = mProgress.Get("printTime")
		oc.JobPrintTimeLeft = mProgress.Get("printTimeLeft")
		
		If oc.isHeating = True And oc.isPrinting = True Then
			oc.JobPrintState = "Heating/Printing"
		End If
		
		If oc.lastJobPrintState <> oc.JobPrintState Then
			'--- updated master buttons as soon as STATE changes
			CallSubDelayed(B4XPages.MainPage,"Update_Printer_Btns")
		End If
		oc.lastJobPrintState = oc.JobPrintState
		'------------------------------------
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		oc.ResetJobVars
		
	End Try
	
End Sub


public Sub ConnectionStatus(s As String) 
	
	Dim m, mm As Map
	Dim jp As JSONParser
	Try
	
		jp.Initialize(s)
	
		'--- populate json maps
		m = jp.NextObject
		mm = m.Get("current").As(Map)
	
		oc.PrinterBaud = mm.Get("baudrate")
		oc.PrinterPort = mm.Get("port")
		oc.PrinterState = mm.Get("state")
		oc.PrinterProfile = mm.Get("printerProfile") '--- this is NOT the name of the printer! See 'cPRINTER_PROFILES'
		oc.isConnected = True
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		oc.ResetStateVars
		
	End Try
	
End Sub

public Sub FileInfo(s As String)'pic As B4XImageView)
	
'	
'	''''gbl.WriteTxt2Disk(s,xui.DefaultFolder,"tmpJSON.json")
'	
'	
	Dim parser As JSONParser
	parser.Initialize(s)
	Dim root As Map = parser.NextObject
'	Dim date As Int = root.Get("date")
	
	Try
		
		oc.JobPrintThumbnailSrc = root.Get("thumbnail_src")
		oc.JobPrintThumbnail = root.Get("thumbnail")
		
	Catch
		'--- no thumbnail info found
		oc.JobPrintThumbnailSrc = ""
		oc.JobPrintThumbnail = ""
	End Try
	
'	Dim display As String = root.Get("display")
'	Dim origin As String = root.Get("origin")
'	Dim Type As String = root.Get("type")
'	Dim prints As Map = root.Get("prints")
'	Dim last As Map = prints.Get("last")
'	'Dim date As Double = last.Get("date")
'	Dim success As String = last.Get("success")
'	Dim failure As Int = prints.Get("failure")
'	'Dim success As Int = prints.Get("success")
'	Dim path As String = root.Get("path")
'	Dim typePath As List = root.Get("typePath")
'	For Each coltypePath As String In typePath
'	Next
'
'	Dim size As Int = root.Get("size")
	Dim refs As Map = root.Get("refs")
	Dim download As String = refs.Get("download") 'ignore
	Dim resource As String = refs.Get("resource") 'ignore
'
'	Dim name As String = root.Get("name")
'	Dim gcodeAnalysis As Map = root.Get("gcodeAnalysis")
'	Dim estimatedPrintTime As Double = gcodeAnalysis.Get("estimatedPrintTime")
'	Dim filament As Map = gcodeAnalysis.Get("filament")
'
'	Dim tool0 As Map = filament.Get("tool0")
'	Dim volume As Double = tool0.Get("volume")
'	Dim length As Double = tool0.Get("length")
'	Dim dimensions As Map = gcodeAnalysis.Get("dimensions")
'	Dim depth As Double = dimensions.Get("depth")
'	Dim width As Double = dimensions.Get("width")
'	Dim height As Double = dimensions.Get("height")
'
'	Dim printingArea As Map = gcodeAnalysis.Get("printingArea")
'	Dim minY As Double = printingArea.Get("minY")
'	Dim maxZ As Double = printingArea.Get("maxZ")
'	Dim minX As Double = printingArea.Get("minX")
'	Dim maxY As Double = printingArea.Get("maxY")
'	Dim maxX As Double = printingArea.Get("maxX")
'	Dim minZ As Double = printingArea.Get("minZ")
'
'	Dim hash As String = root.Get("hash")
'	Dim statistics As Map = root.Get("statistics")
'	Dim lastPrintTime As Map = statistics.Get("lastPrintTime")
'	Dim averagePrintTime As Map = statistics.Get("averagePrintTime")
'
'		
'	Catch
'		
'		Log(LastException)
'	
'	End Try
	
End Sub



