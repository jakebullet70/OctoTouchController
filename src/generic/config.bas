﻿B4J=true
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
	
	'Public MQTTserverOnFLAG As Boolean = False
	'Public MQTTclientOnFLAG As Boolean = False
	
	Public LastConnectedClient As String
	Public pTurnOnDebugTabFLAG As Boolean
	
	'--- android power dlg
	Public AndroidTakeOverSleepFLAG As Boolean = False
	Public AndroidNotPrintingScrnOffFLAG As Boolean = False
	Public AndroidNotPrintingMinTill As Int
	Public AndroidPrintingScrnOffFLAG As Boolean = False
	Public AndroidPrintingMinTill As Int
	
	'--- general dlg
'	Public ShowSysCmdsFLAG As Boolean = True
	Public logPOWER_EVENTS As Boolean = False 
	Public logFILE_EVENTS As Boolean = False
	Public logREQUEST_OCTO_KEY As Boolean = False
	Public logREST_API As Boolean = False
	
	
	Public logTIMER_EVENTS As Boolean = False '--- not in the general setup
	'------------
	
	'--- Printer power - sonoff
	Public ShowPwrCtrlFLAG As Boolean = False
	
	'--- Printer zled or ws281z  flag
	Public ShowZLEDCtrlFLAG As Boolean = False
	Public ShowWS281CtrlFLAG As Boolean = False
	
	'--- functions menu
	'Public ShowFilamentChangeFLAG As Boolean = False
	'Public ShowBedLevel_ManualFLAG As Boolean = False
	'Public ShowBLCRtouchMenuFLAG As Boolean = False
	
	Public ShowBedLevel_MeshFLAG As Boolean = True
	Public ShowZ_Offset_WizFLAG As Boolean = True
	
	'Public ExternalSharedDir As String = ""
	

End Sub

Public Sub Init
	
'	Dim rp As RuntimePermissions
'	ExternalSharedDir = rp.GetSafeDirDefaultExternal("") 
'	'--- we should get an external shared folder that can be seen by the desktop
'	If strHelpers.IsNullOrEmpty(ExternalSharedDir) Then 
'		logMe.LogIt("Getting external shared folder failed!","Init")
'		ExternalSharedDir = xui.DefaultFolder
'	End If
		
	LoadCfgs
	IsInit = True
	
	If File.Exists(xui.DefaultFolder,LICENSE_FILE) = False Then
		File.Copy(File.DirAssets,LICENSE_FILE,xui.DefaultFolder,LICENSE_FILE)
	End If
	
End Sub

Private Sub LoadCfgs()
	
	If Main.kvs.ContainsKey(gblConst.SELECTED_CLR_THEME) = False Then
		Main.kvs.Put(gblConst.SELECTED_CLR_THEME,"Prusa")
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

	#if not (klipper)
	If Main.kvs.ContainsKey(gblConst.PWR_CTRL_ON) = False Then	
		Dim o1 As dlgOctoPsuSetup
		o1.Initialize("")
		o1.CreateDefaultOctoPowerCfg
	End If
	ReadPwrCFG
	
	'======================================================================

	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.ZLED_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.ZLED_OPTIONS_FILE) = False Then
		Dim ox As dlgZLEDSetup
		ox.Initialize("",gblConst.ZLED_OPTIONS_FILE)
		ox.CreateDefaultFile
	End If
	ReadZLED_CFG
	
	'======================================================================

	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.WS281_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.WS281_OPTIONS_FILE) = False Then
		Dim oi As dlgZLEDSetup
		oi.Initialize("",gblConst.WS281_OPTIONS_FILE)
		oi.CreateDefaultFile
	End If
	ReadWS281_CFG

	#end if
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
	
	#if klipper
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE) = False Then
		Dim oiq As dlgPrinterSetup
		oiq.Initialize
		oiq.CreateDefaultFile
	End If
	'ReadPrinterCFG '--- this will be done on connection init
	
	'======================================================================
	
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.PSU_KLIPPER_SETUP_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.PSU_KLIPPER_SETUP_FILE) = False Then
		Dim oiw As dlgIpOnOffSetup
		oiw.Initialize(Null,Null)
		oiw.CreateDefaultDataFile(gblConst.PSU_KLIPPER_SETUP_FILE) 
	End If

	#end if
	
	'======================================================================
	
	'--- dev
'	For jj = 1 To 4
'		fileHelpers.SafeKill2(xui.DefaultFolder,jj & gblConst.HTTP_ONOFF_SETUP_FILE)
'	Next
	If File.Exists(xui.DefaultFolder,"1" & gblConst.HTTP_ONOFF_SETUP_FILE) = False Then
		Dim oiw As dlgIpOnOffSetup
		oiw.Initialize(Null,Null)
		For jj = 1 To 4
			oiw.CreateDefaultDataFile(jj & gblConst.HTTP_ONOFF_SETUP_FILE) '--- generic HTTP commands
		Next
	End If


	'======================================================================
	Dim key As String = "1stRunCopyDefGCode"
	
	'--- dev -----------
'	For jj = 0 To 7
'		fileHelpers.SafeKill2(xui.DefaultFolder,jj & gblConst.GCODE_CUSTOM_SETUP_FILE)
'	Next
'	Main.kvs.Put(key,False)
	'-------------------
	
	If Main.kvs.GetDefault(key,False) = False Then
		Dim oSeed As OptionsCfgSeed : oSeed.Initialize
		'fileHelpers.SafeKill("0" & gblConst.GCODE_CUSTOM_SETUP_FILE) '--- 1st GCode slot, make sure its gone
		#if klipper
		'--- need to do a klipper version?
		'--- if GCODE starts with @ its a macro?
		File.WriteMap(xui.DefaultFolder,"0" & gblConst.GCODE_CUSTOM_SETUP_FILE,oSeed.SeedBedLevelKlipper) '--- V2, needs testing!!!!!!!!!!!!
		#else
		'--- 1 default custom gcode included
		File.WriteMap(xui.DefaultFolder,"0" & gblConst.GCODE_CUSTOM_SETUP_FILE,oSeed.SeedBedLevelMarlin) '--- G29 Heated
		#end if
		Main.kvs.Put(key,True) '--- lets never do this again!
	End If
	
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

Public Sub ReadManualBedLevelFLAG As Boolean
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.BED_MANUAL_LEVEL_FILE)
	Return Data.Get(gblConst.bedManualShow).As(Boolean)
End Sub

Public Sub ReadWizardFilamentChangeFLAG As Boolean
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE)
	Return Data.Get(gblConst.filShow).As(Boolean)
End Sub

Public Sub ReadZLED_CFG As Boolean
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.ZLED_OPTIONS_FILE)
	ShowZLEDCtrlFLAG = Data.Get(gblConst.ZLED_CTRL_ON).As(Boolean)
	Return Data.Get(gblConst.ZLED_CTRL_ON).As(Boolean)
End Sub

Public Sub ReadWS281_CFG As Boolean
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.WS281_OPTIONS_FILE)
	ShowWS281CtrlFLAG = Data.Get(gblConst.ZLED_CTRL_ON).As(Boolean) '--- this is correct
	Return Data.Get(gblConst.ZLED_CTRL_ON).As(Boolean) '--- this is correct
End Sub

Public Sub ReadPwrCFG As Boolean
	ShowPwrCtrlFLAG = Main.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean)
	Return Main.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean)
End Sub

Public Sub ReadGeneralCFG
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
	'ChangeBrightnessSettingsFLAG = Data.Get("chgBrightness").As(Boolean)
'	ShowScreenOffFLAG = Data.Get("scrnoff").As(Boolean)
'	ShowSysCmdsFLAG = Data.Get("syscmds").As(Boolean)
	
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




