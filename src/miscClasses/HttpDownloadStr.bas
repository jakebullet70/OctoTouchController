B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0	Aug/27/2022
'			1st version. Generic HTTP download, can be used for other things to
#End Region

Sub Class_Globals
	Private Const mModule As String = "HttpDownloadStr" 
End Sub

Public Sub Initialize
End Sub



Public Sub SendRequest(target As String)As ResumableSub
	
	Dim insub As String = "SendRequest"
	Dim j As HttpJob: j.Initialize("", Me)
	Dim retStr As String = ""
	
	If config.logREST_API Then
		logMe.logit2(target,mModule,insub)
	End If

	j.Download(target)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		retStr = j.GetString		
	Else
		If config.logREST_API Then
			logMe.logit2("ERROR: " & j.ErrorMessage,mModule,insub)
		End If
	End If
	
	j.Release '--- free up resources
	
	Return retStr
	
End Sub

