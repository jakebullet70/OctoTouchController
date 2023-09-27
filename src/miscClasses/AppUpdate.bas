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
	Dim PrevVer As Int = Main.kvs.Get("version_code").As(Int) 'ignore
	
	
	
	'--- V2 is a complete RE-INSTALL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	'--- V2 is a complete RE-INSTALL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	'--- V2 is a complete RE-INSTALL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	
	
'	#if klipper
'	
'	'--- nothing here yet
'	
'	#else
'	
'	'=============================================================================================
'	
'	If PrevVer <= 15 Then '--- V1.2.2
'		
'		If Not (Main.kvs.ContainsKey(gblConst.SELECTED_CLR_THEME)) Then
'			
'			'--- moved theme from general options  into KVS
'			Dim m As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
'			Dim k As String = m.Get(gblConst.SELECTED_CLR_THEME)
'			Main.kvs.Put(gblConst.SELECTED_CLR_THEME,k)
'			
'			'--- write back out the general options file without the clr theme
'			m.Remove(gblConst.SELECTED_CLR_THEME)
'			File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,m)
'			
'		End If
'	End If
'	
'	'=============================================================================================
'	
'	If PrevVer <= 19 Then '--- V1.2.7
'		'--- add new sys command option
'		Dim mSys1 As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
'		mSys1.Put("syscmds","false")
'		fileHelpers.SafeKill(gblConst.GENERAL_OPTIONS_FILE)
'		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,mSys1)
'	End If
'
'	'=============================================================================================
'	
'	If PrevVer <= 21 Then '--- V1.2.9
'		'--- add inverted options to general dialog
'		Dim mSys2 As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
'		mSys2.Put("axesx","false")
'		mSys2.Put("axesy","false")
'		mSys2.Put("axesz","false")
'		fileHelpers.SafeKill(gblConst.GENERAL_OPTIONS_FILE)
'		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,mSys2)
'	End If
'	
'	If PrevVer <= 22 Then '--- V1.3.0
'		'--- add start at boot to general dialog
'		Dim mSys2 As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
'		mSys2.Put("sboot","false")
'		fileHelpers.SafeKill(gblConst.GENERAL_OPTIONS_FILE)
'		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,mSys2)
'	End If
'
'	#End If
'	
	
	'=============================================================================================
	'--- update the version
	Main.kvs.Put("version_code",Application.VersionCode)
	
End Sub


