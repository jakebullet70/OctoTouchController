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
	'--- generic socket rec text
	'Log("Generic wsocket_RecievedText: " & msg)
End Sub


'===========================================================================================
'===========================================================================================
'===========================================================================================


Private Sub server_info(s As String)
	Log("server_info:" & s)
End Sub

Private Sub notify_klippy_ready(s As String)
	Log("notify_klippy_ready")
	B4XPages.MainPage.oMasterController.Start
End Sub

Private Sub notify_klippy_disconnected(s As String)
	Log("notify_klippy_disconnected")
End Sub

Private Sub notify_klippy_shutdown(s As String)
	Log("notify_klippy_shutdown")
End Sub



