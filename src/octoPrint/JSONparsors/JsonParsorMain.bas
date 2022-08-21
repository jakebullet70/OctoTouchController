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
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
End Sub


public Sub TempStatus(s As String)
	Dim CallingSub As String = "TempStatus"
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
		TargetBedCheck = CheckNull0(mBed.Get("target"))
		oc.BedActual = CheckNull0(mBed.Get("actual")) & gblConst.DEGREE_SYMBOL & "C"
		oc.BedTarget = TargetBedCheck.As(String)  & gblConst.DEGREE_SYMBOL & "C"
		
		mTool1 = mTemp.Get("tool0").As(Map)
		TargetToolCheck = CheckNull0(mTool1.Get("target"))
		oc.Tool1ActualReal = CheckNull0(mTool1.Get("actual"))
		oc.Tool1Actual = CheckNull0(mTool1.Get("actual")) & gblConst.DEGREE_SYMBOL & "C"
		oc.Tool1Target = TargetToolCheck.As(String) & gblConst.DEGREE_SYMBOL & "C"
			
		'---  is there a tool 2
		mTool2 = mTemp.Get("tool1").As(Map)
		If mTool2.IsInitialized = True Then
			oc.Tool2ActualReal = mTool2.Get("actual")
			oc.Tool2Actual = mTool2.Get("actual") & gblConst.DEGREE_SYMBOL & "C"
			oc.Tool2Target = mTool2.Get("target") & gblConst.DEGREE_SYMBOL & "C"
		End If
		
		If TargetBedCheck <> 0 Or TargetToolCheck <> 0 Then
			
			'--- bed / tool is set to heat
			Dim bedCheckOffset As Int = 2
			Dim toolCheckOffset As Int = 5
			
			Dim bedActual As Int = CheckNull0(mBed.Get("actual"))
'			If mBed.Get("actual") = Null Then
'				bedActual = 0
'			Else
'				bedActual = mBed.Get("actual")
'			End If
			
			Dim toolActual As Int = CheckNull0(mTool1.Get("actual"))
'			If mTool1.Get("actual") = Null Then
'				toolActual = 0
'			Else
'				toolActual = mTool1.Get("actual")
'			End If
			
			If (bedActual + bedCheckOffset <= TargetBedCheck) Or (toolActual + toolCheckOffset <= TargetToolCheck) Then
				oc.isHeating = True
			Else
				oc.isHeating = False
			End If
	
		End If
		
			
	Catch
		
		logMe.LogIt2(LastException,mModule,CallingSub)
		oc.ResetTempVars
		
	End Try
	
End Sub


public Sub  JobStatus(s As String)
	Dim CallingSub As String = "JobStatus"
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
		End If
		oc.lastJobPrintState = oc.JobPrintState
		'------------------------------------
		
	Catch
		
		logMe.LogIt2(LastException,mModule,CallingSub)
		oc.ResetJobVars
		
	End Try
	
End Sub



'================================================================================
'    These checks where added for the Klipper addin for octoprint
'    Issues found when octoprint is running but the Klipper host is not
'================================================================================


private Sub CheckNull(v As String) As String
	Try
		Return IIf(v = Null Or v = "null","",v)
	Catch
		Return ""
	End Try
End Sub


private Sub CheckNull0(v As String) As String
	Try
		Return IIf(v = Null Or v = "null","0",v)
	Catch
		Return "0"
	End Try
End Sub

private Sub CheckNullDash(v As String) As String
	Try
		Return IIf(v = Null Or v = "null","-",v)
	Catch
		Return "-"
	End Try
End Sub

'================================================================================
