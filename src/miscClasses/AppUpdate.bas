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
	
	'--- testing 'working' branch
	' --- have to click 'RAW' to get the file link
	'Private Const VERSION_URL As String = "https://raw.githubusercontent.com/jakebullet70/OctoTouchController/working/AutoUpdate"
	'Private Const VERSION_FILE As String = "versions.txt" 'ignore
	
	'Public Const APP_APK As String = "OctoTouchController.apk" 'ignore
	'Private NewVerURL As String 'ignore
	
End Sub

Public Sub Initialize
End Sub

Public Sub RunPrgUpdate
	
	'--- runs on app startup when a new version has been installed
	'--- runs on app startup when a new version has been installed
	
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


'===========================================================================================
'--- code below is incomplete and Parked, not sure if we are going to provide Autoupdate
'--- code below is incomplete and Parked, not sure if we are going to provide Autoupdate
'--- code below is incomplete and Parked, not sure if we are going to provide Autoupdate
'---
'--- releated code is in the AppUpdate branch --
'--- releated code is in the AppUpdate branch --
'===========================================================================================


'Public Sub Check4Update As ResumableSub
'	
'	Try
'		
'		fileHelpers.SafeKill2(Starter.Provider.SharedFolder,VERSION_FILE)
'		Dim dload As HttpDownloadStr : dload.Initialize
'		
'		Dim jj As String = "https://raw.githubusercontent.com/jakebullet70/OctoTouchController/working/AutoUpdate/versions.txt"
'		
'		'Wait For (dload.SendRequest(File.Combine(VERSION_URL,VERSION_FILE))) Complete (retStr As String)
'		Wait For (dload.SendRequest(jj)) Complete (retStr As String)
'		If retStr = "" Then 
'			Return "err"
'		End If
'		
'		If ParseIsUpdate(retStr) = False Then 
'			Return "no"
'		End If
'		
'		Return "ok"
'		
'	Catch
'		Log(LastException)
'		Return "err"
'	End Try
'	
'End Sub
'
'Private Sub ParseIsUpdate(s As String) As Boolean
'	
'	Try
'		
'		Dim ver As String = Regex.Split(CRLF,s)(0)
'		ver = Regex.Split("=",ver)(1).As(Int)
'		
'		If ver <= Application.VersionCode Then
'			Return False '--- version is good, no update
'		End If
'		
'		'--- get the download URL of the new file
'		Dim NewVerURL As String = Regex.Split(CRLF,s)(1)
'		NewVerURL = File.Combine( Regex.Split("=",NewVerURL)(1).As(Int) , APP_APK )
'		
'		Return True
'		
'	Catch
'		Log(LastException)
'		Return False
'	End Try
'	
'End Sub
'
'
'Public Sub DownloadAndInstallUpdate 
'	
'	Try
'		
'	Catch
'		Log(LastException)
'	End Try
'	
'End Sub
'
