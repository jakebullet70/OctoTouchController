B4J=true
Group=OCTOPRINT\PARSORS
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
' Author:  sadLogic
' Author:  sadLogic, Kherson Ukraine
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
Sub Class_Globals
	Private Const mModule As String = "jsonParserMain" 'ignore
	Private xui As XUI
End Sub

Public Sub Initialize
End Sub


Public Sub TempStatus(s As String)
	Dim CallingSub As String = "TempStatus"
	Dim m, mTemp, mBed, mTool1 As Map
	Dim jp As JSONParser
	Dim tmpTool, tmpBed As Int '--- tmp vars to stip the decimals
	's = File.ReadString(File.DirAssets,"ptest.txt")
	
	Try
		
		oc.isHeating = False
		Dim TargetBedCheck,TargetToolCheck As Int
	
		'--- populate vars from json
		
		#if klipper
		
		#End If
		
		Try
			jp.Initialize(s)
			m = jp.NextObject
			mTemp = m.Get("temperature").As(Map)
		Catch
			logMe.LogIt2("temp 0:"$ & LastException,mModule,CallingSub)
		End Try

		'-----------------------------------------------------		
		Try
			mBed = mTemp.Get("bed").As(Map)
		Catch
			logMe.LogIt2("temp 1:"$ & LastException,mModule,CallingSub)
		End Try
		Try	
			TargetBedCheck = CheckNull0(mBed.Get("target"))
			tmpBed = CheckNull0(mBed.Get("actual"))
			oc.BedActual   = tmpBed & gblConst.DEGREE_SYMBOL & "C"
			oc.BedTarget   = TargetBedCheck.As(String)  & gblConst.DEGREE_SYMBOL & "C"
		Catch
			logMe.LogIt2("temp 11:"$ & LastException,mModule,CallingSub)
		End Try
		
		'-----------------------------------------------------
		Try
			mTool1 = mTemp.Get("tool0").As(Map)
		Catch
			logMe.LogIt2("temp 2:"$ & LastException,mModule,CallingSub)
		End Try
		Try	
			TargetToolCheck = CheckNull0(mTool1.Get("target"))
			oc.Tool1TargetReal = CheckNull0(mTool1.Get("target"))
			oc.Tool1ActualReal = CheckNull0(mTool1.Get("actual"))
			tmpTool = CheckNull0(mTool1.Get("actual"))
			oc.Tool1Actual = tmpTool & gblConst.DEGREE_SYMBOL & "C"
			oc.Tool1Target = TargetToolCheck.As(String) & gblConst.DEGREE_SYMBOL & "C"
		Catch
			logMe.LogIt2("temp 22:"$ & LastException,mModule,CallingSub)
		End Try
		
		'-----------------------------------------------------
		Try
			'--- bed / tool is set to heat
			If TargetBedCheck <> 0 Or TargetToolCheck <> 0 Then
				Dim bedCheckOffset As Int = 2
				Dim toolCheckOffset As Int = 5
				Dim bedActual As Int = CheckNull0(mBed.Get("actual"))
				Dim toolActual As Int = CheckNull0(mTool1.Get("actual"))
				If (bedActual + bedCheckOffset <= TargetBedCheck) Or (toolActual + toolCheckOffset <= TargetToolCheck) Then
					oc.isHeating = True
				Else
					oc.isHeating = False
				End If
			End If
		Catch
			logMe.LogIt2("temp 33:"$ & LastException,mModule,CallingSub)
		End Try
			
	Catch
		logMe.LogIt2(LastException,mModule,CallingSub)
		oc.ResetTempVars
	End Try
	
End Sub


Public Sub  JobStatus(s As String)
	Dim CallingSub As String = "JobStatus"
	
	Dim jp As JSONParser
	'Log(s)
	Try
		
		jp.Initialize(s)
		'Log(s)
		
		'--- reset status of printer -------------
		oc.isCanceling = False
		oc.isPrinting = False
		oc.isPaused2 = False

		#if klipper
		Dim root As Map = jp.NextObject
		Dim result As Map = root.Get("result")
		Dim status As Map = result.Get("status")
		Dim print_stats As Map = status.Get("print_stats")
		Dim virtual_sdcard As Map = status.Get("virtual_sdcard")
		
		'---- get status
		oc.JobPrintState = print_stats.Get("state")
		'Dim is_active As String = virtual_sdcard.Get("is_active") if true does it mean its printing?
		'Log( oc.JobPrintState.ToLowerCase)
		Select Case oc.JobPrintState.ToLowerCase
			Case "printing"        : oc.isPrinting = True
			Case "cancelling"   : oc.isKlipperCanceling = True
			Case "paused"       : oc.isPaused2 = True
			Case "standby"
				If  oc.isConnected = False Then 
					
				End If
			Case Else
				#if debug
				'Log("case else: " & oc.JobPrintState)
				#end if
		End Select
		
		oc.JobFileName = print_stats.Get("filename")
		oc.isFileLoaded  = (oc.JobFileName.Length <> 0)
		oc.JobFileSize  = virtual_sdcard.Get("file_size")
		oc.JobFilePos   = virtual_sdcard.Get("file_position")
		
		oc.JobCompletion = (Round2(virtual_sdcard.Get("progress"),2) * 100)
		oc.JobPrintTime = print_stats.Get("total_duration")
		oc.JobEstPrintTime = print_stats.Get("print_duration")
'		Dim td,pd As Double
'		td = print_stats.Get("total_duration")
'		pd = print_stats.Get("print_duration")
''		Log(td)
''		Log(pd)
'		oc.JobPrintTimeLeft =	oc.JobEstPrintTime
		
'		Dim eventtime As Double = result.Get("eventtime")
'		Log(eventtime)
		''Dim status As Map = result.Get("status")
		''Dim print_stats As Map = status.Get("print_stats")
		''Dim filename As String = print_stats.Get("filename")
		''Dim total_duration As Double = print_stats.Get("total_duration")
		
		'Dim print_duration As Double = print_stats.Get("print_duration")
		'Dim state As String = print_stats.Get("state")
		'Dim message As String = print_stats.Get("message") '--- blank when printing
		'Dim filament_used As Double = print_stats.Get("filament_used")
		
		'Dim info As Map = print_stats.Get("info")
		'Dim current_layer As String = info.Get("current_layer")
		'Dim total_layer As String = info.Get("total_layer")
		
		Dim webhooks As Map = status.Get("webhooks") 
		Dim state As String = webhooks.Get("state") 
		If state = "shutdown" Then
			oc.isConnected = False
		End If
		'Dim state_message As String = webhooks.Get("state_message")
		
		'Dim virtual_sdcard As Map = status.Get("virtual_sdcard")
		'Dim file_path As String = virtual_sdcard.Get("file_path")
		'Dim file_position As Int = virtual_sdcard.Get("file_position")
		'Dim is_active As String = virtual_sdcard.Get("is_active")
		'Dim progress As Double = virtual_sdcard.Get("progress")
		'Dim file_size As Int = virtual_sdcard.Get("file_size")
		
		#else
		
		Dim m, mProgress As Map
		Dim mJob, mFile As Map	
		m = jp.NextObject
		
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
	
		oc.JobFileName = CheckNull(mFile.Get("name"))
		
		oc.isFileLoaded = (oc.JobFileName.Length <> 0)
		oc.JobFileOrigin = CheckNull(mFile.Get("origin"))
		oc.JobFileSize = CheckNull(mFile.Get("size"))
	
		oc.JobEstPrintTime = IIf(CheckNull(mJob.Get("estimatedPrintTime")) <> "", _
						mJob.Get("estimatedPrintTime"),"N/A")
		
		oc.JobCompletion = CheckNull0(mProgress.Get("completion"))
		oc.JobFilePos = CheckNull0(mProgress.Get("filepos"))
		oc.JobPrintTime = CheckNullDash(mProgress.Get("printTime"))
		oc.JobPrintTimeLeft = CheckNullDash(mProgress.Get("printTimeLeft"))
		
		If oc.isHeating = True And oc.isPrinting = True Then
			oc.JobPrintState = "Heating/Printing"
		End If
		
		If oc.lastJobPrintState <> oc.JobPrintState Then
		'--- updated master buttons as soon as STATE changes
			CallSubDelayed(B4XPages.MainPage,"Update_Printer_Btns")
			'If oc.lastJobPrintState = gblConst.NOT_CONNECTED Or oc.JobPrintState = gblConst.NOT_CONNECTED Then
			'	CallSubDelayed(B4XPages.MainPage,"Build_RightSideMenu")
			'End If
			
		End If
		oc.lastJobPrintState = oc.JobPrintState
		'------------------------------------
		#End If
		
	Catch
		
		logMe.LogIt2(LastException,mModule,CallingSub)
		oc.ResetJobVars
		
	End Try
	
End Sub



'================================================================================
'    These checks where added for the Klipper addin for octoprint
'    Issues found when octoprint is running but the Klipper host is not
'================================================================================

#if not (klipper)
Private Sub CheckNull(v As String) As String
	Try
		Return IIf(v = Null Or v = "null" Or v = "","",v)
	Catch
		Return ""
	End Try
End Sub
#end if


Private Sub CheckNull0(v As String) As String
	Try
		Return IIf(v = Null Or v = "null" Or v = "" Or v = "0.0","0",v)
	Catch
		Return "0"
	End Try
End Sub

#if not (klipper)
Private Sub CheckNullDash(v As String) As String
	Try
		Return IIf(v = Null Or v = "null" Or v = "","-",v)
	Catch
		Return "-"
	End Try
End Sub
#end if
'================================================================================
