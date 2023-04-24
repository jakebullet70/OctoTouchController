B4J=true
Group=KLIPPY
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V1.0 	Apr/24/2023
#End Region
Sub Class_Globals

	Private xui As XUI
	Private Const mModule As String = "KlippySocketParser" 'ignore
	
End Sub

Public Sub Initialize
End Sub



Private Sub wsocket_RecievedText(msg As String)
	Log(msg)
End Sub


'===========================================================================================
'===========================================================================================
'===========================================================================================


Private Sub server_info(s As String)
	Log(s)
End Sub
