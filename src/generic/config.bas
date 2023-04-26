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
	Public ShowFilamentChangeFLAG As Boolean = False
	Public ShowBedLevel_ManualFLAG As Boolean = False
	Public ShowBedLevel_MeshFLAG As Boolean = True
	Public ShowZ_Offset_WizFLAG As Boolean = True
	

End Sub

Public Sub Init
	
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
	ReadWizardFilamentChangeCFG
	
	'======================================================================

	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.BED_LEVEL_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.BED_MANUAL_LEVEL_FILE) = False Then
		Dim oiy As dlgBedLevelSetup
		oiy.Initialize
		oiy.CreateDefaultFile
	End If
	ReadManualBedLevelCFG
	
	
	
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
		oiw.Initialize(Null,Null,Null)
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
		oiw.Initialize(Null,Null,Null)
		For jj = 1 To 4
			oiw.CreateDefaultDataFile(jj & gblConst.HTTP_ONOFF_SETUP_FILE) '--- generic HTTP commands
		Next
	End If
	
End Sub

'=========================================================================

'Public Sub ReadPrinterCFG
'--- this will be done on connection init
'	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE)
'End Sub


Public Sub ReadManualBedLevelCFG
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.BED_MANUAL_LEVEL_FILE)
	ShowBedLevel_ManualFLAG = Data.Get(gblConst.bedManualShow).As(Boolean)
End Sub

Public Sub ReadWizardFilamentChangeCFG
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE)
	ShowFilamentChangeFLAG = Data.Get(gblConst.filShow).As(Boolean)
End Sub

Public Sub ReadZLED_CFG
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.ZLED_OPTIONS_FILE)
	ShowZLEDCtrlFLAG = Data.Get(gblConst.ZLED_CTRL_ON).As(Boolean)
End Sub

Public Sub ReadWS281_CFG
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.WS281_OPTIONS_FILE)
	ShowWS281CtrlFLAG = Data.Get(gblConst.ZLED_CTRL_ON).As(Boolean) '--- this is correct
End Sub

Public Sub ReadPwrCFG
	ShowPwrCtrlFLAG = Main.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean)
End Sub

Public Sub ReadGeneralCFG
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
	'ChangeBrightnessSettingsFLAG = Data.Get("chgBrightness").As(Boolean)
'	ShowScreenOffFLAG = Data.Get("scrnoff").As(Boolean)
'	ShowSysCmdsFLAG = Data.Get("syscmds").As(Boolean)
	
	oc.PrinterProfileInvertedX = Data.Get("axesx").As(Boolean)
	oc.PrinterProfileInvertedY = Data.Get("axesy").As(Boolean)
	oc.PrinterProfileInvertedZ = Data.Get("axesz").As(Boolean)
		
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




