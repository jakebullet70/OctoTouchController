B4A=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/21/2023
#End Region

#Region EVENTS' DECLARATIONS 
'#Event: Complete (result As object, success as object)
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "WebSocketParse" 'ignore
	
End Sub


Public Sub Initialize
End Sub

'===========================================================================================
'===========================================================================================
'===========================================================================================


Private Sub server_info(s As String)
	Log("server_info:" & s)
End Sub

Private Sub notify_klippy_ready(s As String)
	Log("notify_klippy_ready")
	''B4XPages.MainPage.oMasterController.Start
End Sub

Private Sub notify_klippy_disconnected(s As String)
	Log("notify_klippy_disconnected")
	'B4XPages.MainPage.Switch_Pages(gblConst.PAGE_MENU)
End Sub

