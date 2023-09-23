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
	Private XUI As XUI
	Private Const key1stInit As String = "1stRunCopyDefGCode"
End Sub

Public Sub Initialize
End Sub

Public Sub IsOctoKlipper() As ResumableSub
	
	'--- check if OctoKlipper plug in is installed
	Dim rs As ResumableSub =  B4XPages.MainPage.oMasterController.CN.SendRequestGetInfo("/plugin/pluginmanager/plugins")
	Wait For(rs) Complete (Result As String)
	'fileHelpers.WriteTxt2SharedFolder("isklippy.txt",Result)
	If Result.Length <> 0 Then
		
		Dim o As JsonParsorPlugins  : o.Initialize
		If o.IsOctoKlipperRunning(Result) = True Then
			oc.Klippy = True
		End If
		
	End If
	'---------------------------------------
	
	Main.kvs.Put(gblConst.IS_OCTO_KLIPPY,oc.Klippy)
	Return oc.Klippy
	
End Sub


'=========================================================================== V2 TODO move this code
Public Sub CreateDefGCodeFiles_Force
	Main.kvs.Remove(key1stInit)
	CreateDefGCodeFiles
End Sub

Public Sub CreateDefGCodeFiles
	
	'--- called from b4xMainPage connection
	
	If Main.kvs.GetDefault(key1stInit,False) = False Then
		
		Dim oSeed As OptionsCfgSeed : oSeed.Initialize
		
		'--- START - 1st GCode slot - G29
		fileHelpers.SafeKill("0" & gblConst.GCODE_CUSTOM_SETUP_FILE) '--- 1st GCode slot, make sure its gone
		'--- default custom gcode included
		File.WriteMap(XUI.DefaultFolder,"0" & gblConst.GCODE_CUSTOM_SETUP_FILE,oSeed.SeedGCode1StRun) '--- G29, klipper or marlin
		'--- END - 1st GCode slot
		
		Main.kvs.Put(key1stInit,True) '--- lets never do this again!
	End If
	
End Sub


