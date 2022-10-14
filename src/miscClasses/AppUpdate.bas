B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/22/2022
#End Region

Sub Class_Globals
	Private Const mModule As String = "AppUpdate" 'ignore
	Private xui As XUI
End Sub

Public Sub Initialize
End Sub

Public Sub RunPrgUpdate
	
	'--- runs on app startup when a new version has been installed
	'--- runs on app startup when a new version has been installed
	
	Log("RunPrgUpdate")
	fileHelpers.DeleteFiles(xui.DefaultFolder,"*.log")
	fileHelpers.DeleteFiles(xui.DefaultFolder,"*.crash")
	fileHelpers.DeleteFiles(xui.DefaultFolder,"sad_*.png") '--- thumbnails
	
	''''#if release
	Dim PrevVer As Int = Starter.kvs.Get("version_code").As(Int)
	
	If PrevVer <= 3 Then  '--- V1.0.0 Beta 2
		fileHelpers.SafeKill("sonoff_options.map") '--- not used anymore, moved code to use kvs
	End If
	
	'--- update the version
	#if release
	Starter.kvs.Put("version_code",Application.VersionCode)
	#end if
	
End Sub


