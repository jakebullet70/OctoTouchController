B4J=true
Group=MAIN
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/17/2022
#End Region
'Static code module

Sub Process_Globals
	Private Const mModule As String = "Updater" 'ignore
	
	'----------------------------------------------------
	'--- code for when app version changes
	'----------------------------------------------------
	
End Sub


Public Sub Run
	
	'#if release
	Dim PrevVer As Int = Starter.kvs.Get("version_code").As(Int)
	
	If PrevVer <= 3 Then  '--- V1.0.0 Beta 2
		fileHelpers.SafeKill("sonoff_options.map") '--- not used anymore, moved code to use kvs
	End If
	
	'--- update the version
	'#if release
	Starter.kvs.Put("version_code",Application.VersionCode)
	'#end if
	
End Sub

