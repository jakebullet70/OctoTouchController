Group=OCTOPRINT
ModulesStructureVersion=1
Type=Class
Version=3.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/13/2023
#End Region

Sub Class_Globals
	Private Const mModule As String = "OctoKlippyMisc" 'ignore
	
End Sub

Public Sub Initialize
End Sub

Public Sub IsOctoKlipper() As ResumableSub
	
	'--- check if OctoKlipper plug in is installed
	Dim rs As ResumableSub =  B4XPages.MainPage.oMasterController.CN.SendRequestGetInfo("/plugin/pluginmanager/plugins")
	Wait For(rs) Complete (Result As String)
	If Result.Length <> 0 Then

		Dim o As JsonParsorPlugins  : o.Initialize
		If o.IsOctoKlipperRunning(Result) = True Then
			oc.Klippy = True
		End If
		
	End If
	'---------------------------------------
	
	Main.kvs.Put("OctoKlippy",oc.Klippy)
	Return oc.Klippy
	
End Sub


'===========================================================================
