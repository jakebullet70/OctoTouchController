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
	
	'Public MQTTserverOnFLAG As Boolean = False
	'Public MQTTclientOnFLAG As Boolean = False
	
	Public LastConnectedClient As String
	Public pTurnOnDebugTabFLAG As Boolean
	
	'--- power dlg
	Public AndroidTakeOverSleepFLAG As Boolean = False
	Public AndroidNotPrintingScrnOffFLAG As Boolean = False
	Public AndroidNotPrintingMinTill As Int
	Public AndroidPrintingScrnOffFLAG As Boolean = False
	Public AndroidPrintingMinTill As Int
	
	'--- general dlg
	Public ChangeBrightnessSettingsFLAG As Boolean = True 
	Public ShowScreenOffFLAG As Boolean = True 
	Public ColorTheme As String 
	Public logPOWER_EVENTS As Boolean = False 
	Public logFILE_EVENTS As Boolean = False
	Public logREQUEST_OCTO_KEY As Boolean = False
	Public logREST_API As Boolean = False
	
	
	Public logTIMER_EVENTS As Boolean = False '--- not in the general setup
	'------------
	
	Public IsInit As Boolean = False
	
	'--- Printer power - sonoff
	Public ShowPwrCtrlFLAG As Boolean = False
	'--- Printer zled flag
	Public ShowZLEDCtrlFLAG As Boolean = False

End Sub


Public Sub Init
	LoadCfgs
	IsInit = True
End Sub


Private Sub LoadCfgs()
	
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE) = False Then
		Dim o3 As dlgGeneralOptions
		o3.initialize(Null)
		o3.createdefaultfile
	End If
	ReadGeneralCFG
	
	'======================================================================
	
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE) = False Then
		Dim o2 As dlgPowerOptions
		o2.Initialize(Null)  
		o2.CreateDefaultFile
	End If
	ReadPowerCFG
	
	'======================================================================

	If Starter.kvs.ContainsKey(gblConst.PWR_CTRL_ON) = False Then	
		Dim o1 As dlgPsuSetup
		o1.Initialize(Null,"")
		o1.CreateDefaultCfg
	End If
	ReadPwrCFG
	
	'======================================================================

'	If Starter.kvs.ContainsKey(gblConst.ZLED_CTRL_ON) = False Then
'		Dim ox As dlgZLEDSetup
'		ox.Initialize(Null,"")
'		ox.CreateDefaultCfg
'	End If
'	ReadZLED_CFG
	
End Sub


Public Sub ReadPwrCFG
	ShowPwrCtrlFLAG = Starter.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean)
End Sub

'Public Sub ReadZLED_CFG
'	ShowZLEDCtrlFLAG = Starter.kvs.Get(gblConst.PWR_CTRL_ON).As(Boolean)
'End Sub



Public Sub ReadGeneralCFG
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
	ColorTheme = Data.Get("themeclr").As(String).ToLowerCase
	ChangeBrightnessSettingsFLAG = Data.Get("chgBrightness").As(Boolean)
	ShowScreenOffFLAG = Data.Get("scrnoff").As(Boolean)
	
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


public Sub ReadPowerCFG
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE)
	
	AndroidTakeOverSleepFLAG = Data.Get("TakePwr")
	AndroidNotPrintingScrnOffFLAG = Data.Get("NotPrintingScrnOff")
	AndroidNotPrintingMinTill  = Data.Get("NotPrintingMinTill")
	AndroidPrintingScrnOffFLAG  = Data.Get("PrintingScrnOff")
	AndroidPrintingMinTill  = Data.Get("PrintingMinTill")

End Sub




