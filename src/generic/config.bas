B4J=true
Group=GENERIC
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/13/2022
#End Region
'Static code module


Sub Process_Globals
	Private xui As XUI
	Private Const mModule As String = "config" 'ignore
	Private Const LICENSE_FILE As String = "LICENSE.txt"
	Public IsInit As Boolean = False
	
	
	Public empw As String = "b4x!sadLogic512" '--- mail password for the moment
	
	Public LastConnectedClient As String
	Public pTurnOnDebugTabFLAG As Boolean
	
	'--- android power dlg
	Public AndroidTakeOverSleepFLAG As Boolean = False
	Public AndroidNotPrintingScrnOffFLAG As Boolean = False
	Public AndroidNotPrintingMinTill As Int
	Public AndroidPrintingScrnOffFLAG As Boolean = False
	Public AndroidPrintingMinTill As Int
	
	'--- general dlg
	Public logPOWER_EVENTS As Boolean = False 
	Public logFILE_EVENTS As Boolean = False
	Public logREQUEST_OCTO_KEY As Boolean = False
	Public logREST_API As Boolean = False
	
	
	Public logTIMER_EVENTS As Boolean = False '--- not in the general setup
	'------------
	
	'Public ShowBedLevel_MeshFLAG As Boolean = True
	'Public ShowZ_Offset_WizFLAG As Boolean = True
	
End Sub

Public Sub Init

	oc.Klippy = Main.kvs.GetDefault(gblConst.IS_OCTO_KLIPPY,False)
	LoadCfgs
	IsInit = True
	
	If File.Exists(xui.DefaultFolder,LICENSE_FILE) = False Then	File.Copy(File.DirAssets,LICENSE_FILE,xui.DefaultFolder,LICENSE_FILE)
	
End Sub

Private Sub LoadCfgs()
	
	If Main.kvs.ContainsKey(gblConst.SELECTED_CLR_THEME) = False Then
		Main.kvs.Put(gblConst.SELECTED_CLR_THEME,"Prusa")
	End If
	
	If Main.kvs.ContainsKey(gblConst.Z_OFFSET_FLAG) = False Then
		Main.kvs.Put(gblConst.Z_OFFSET_FLAG,False)
	End If
	
	'======================================================================
	
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE) = False Then
		Dim o3 As dlgGeneralOptions
		o3.initialize
		o3.createdefaultfile
	End If
	ReadGeneralCFG
	
	'======================================================================
	
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE) = False Then
		Dim o2 As dlgAndroidPowerOptions
		o2.Initialize
		o2.CreateDefaultFile
	End If
	ReadAndroidPowerCFG
	
	'======================================================================

	'Main.kvs.Remove(gblConst.PWR_CTRL_ON) '--- Dev
	If Main.kvs.ContainsKey(gblConst.PWR_CTRL_ON) = False Then	
		Dim o1 As dlgOctoPsuSetup
		o1.Initialize("")
		o1.CreateDefaultOctoPowerCfg
	End If
	
	'======================================================================

	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE) = False Then
		Dim oiz As dlgFilamentSetup
		oiz.Initialize
		oiz.CreateDefaultFile
	End If
	
	'======================================================================

	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.BED_MANUAL_LEVEL_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.BED_MANUAL_LEVEL_FILE) = False Then
		Dim oiy As dlgBedLevelSetup
		oiy.Initialize
		oiy.CreateDefaultFile
	End If
	
	'======================================================================
	
	'--- dev
'	For jj = 1 To 8
'		fileHelpers.SafeKill2(xui.DefaultFolder,jj & gblConst.HTTP_ONOFF_SETUP_FILE)
'	Next
	If File.Exists(xui.DefaultFolder,"1" & gblConst.HTTP_ONOFF_SETUP_FILE) = False Then
		Dim oiw As dlgIpOnOffSetup
		oiw.Initialize(Null,Null)
		For jj = 1 To 8
			oiw.CreateDefaultDataFile(jj & gblConst.HTTP_ONOFF_SETUP_FILE) '--- generic HTTP commands
		Next
	End If


	'======================================================================
		
	'--- dev -----------
'	For jj = 0 To 7
'		fileHelpers.SafeKill2(xui.DefaultFolder,jj & gblConst.GCODE_CUSTOM_SETUP_FILE)
'	Next
'	Main.kvs.Put(key,False)
	'-------------------
	If File.Exists(xui.DefaultFolder,"7" & gblConst.GCODE_CUSTOM_SETUP_FILE) = False Then
		Dim oi7 As dlgGCodeCustSetup
		oi7.Initialize(Null,Null)
		For jj = 0 To 7
			If File.Exists(xui.DefaultFolder,jj & gblConst.GCODE_CUSTOM_SETUP_FILE) = True Then
				Continue
			End If
			oi7.CreateDefaultDataFile(jj & gblConst.GCODE_CUSTOM_SETUP_FILE) '--- generic GCODE commands
		Next
	End If
	'======================================================================
	

	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE) = False Then
		Dim oid As dlgBLTouchSetup
		oid.Initialize
		oid.CreateDefaultFile
	End If
	
End Sub

'=========================================================================

'Public Sub ReadPrinterCFG
'--- this will be done on connection init
'	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE)
'End Sub

Public Sub ReadBLCRtouchFLAG() As Boolean
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE)
	Return Data.Get(gblConst.probeShow).As(Boolean)
End Sub

Public Sub ReadManualBedScrewLevelFLAG As Boolean
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.BED_MANUAL_LEVEL_FILE)
	Return Data.Get(gblConst.bedManualShow).As(Boolean)
End Sub

Public Sub ReadWizardFilamentChangeFLAG As Boolean
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE)
	Return Data.Get(gblConst.filShow).As(Boolean)
End Sub

Public Sub ReadPwrCfgFLAG As Boolean
	Return Main.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean)
End Sub

Public Sub ReadZOffsetFLAG As Boolean
	Return Main.kvs.Get(gblConst.Z_OFFSET_FLAG).As(Boolean)
End Sub


Public Sub ReadGeneralCFG
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
	'--- these used to come from Octoprint but now we get them locally as the camera view 
	'--- in Octoprint might be different from your eyeball view in front of your printer
	oc.PrinterProfileInvertedX = Data.GetDefault("axesx",False)
	oc.PrinterProfileInvertedY = Data.GetDefault("axesy",False)
	oc.PrinterProfileInvertedZ = Data.GetDefault("axesz",False)
		
	If Data.Get("logall").As(Boolean) Then
		logPOWER_EVENTS = True
		logFILE_EVENTS = True
		logREQUEST_OCTO_KEY = True
		logREST_API = True
	Else
		logPOWER_EVENTS = Data.Get("logpwr").As(Boolean)
		logFILE_EVENTS = Data.Get("logfiles").As(Boolean)
		logREQUEST_OCTO_KEY = Data.Get("logoctokey").As(Boolean)
		logREST_API = Data.Get("logrest").As(Boolean)
	End If
	
End Sub

Public Sub ReadAndroidPowerCFG
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE)
	
	AndroidTakeOverSleepFLAG = Data.Get("TakePwr")
	AndroidNotPrintingScrnOffFLAG = Data.Get("NotPrintingScrnOff")
	AndroidNotPrintingMinTill  = Data.Get("NotPrintingMinTill")
	AndroidPrintingScrnOffFLAG  = Data.Get("PrintingScrnOff")
	AndroidPrintingMinTill  = Data.Get("PrintingMinTill")

End Sub




