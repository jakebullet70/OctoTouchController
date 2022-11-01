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
	
	'=============================================================================================
	
	If PrevVer <= 15 Then '--- V1.2.2
		
		If Not (Starter.kvs.ContainsKey(gblConst.CLR_THEME_KEY)) Then
			
			'--- moved theme from general options  into KVS
			Dim m As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
			Dim k As String = m.Get(gblConst.CLR_THEME_KEY)
			Starter.kvs.Put(gblConst.CLR_THEME_KEY,k)
			
			'--- write back out the general options file without the clr theme
			m.Remove(gblConst.CLR_THEME_KEY)
			File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,m)
			
		End If
	End If
	
	'=============================================================================================
	
	'--- update the version
	Starter.kvs.Put("version_code",Application.VersionCode)
	
End Sub


