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
	'------------
	
	Public IsInit As Boolean = False
	
	'--- sonoff dlg
	Public SonoffFLAG As Boolean = False
	Public SonoffIP As String = ""

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
	
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.POWER_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.POWER_OPTIONS_FILE) = False Then
		Dim o2 As dlgPowerOptions
		o2.Initialize(Null)  
		o2.CreateDefaultFile
	End If
	ReadPowerCFG
	
	'======================================================================
	
	'fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE) '--- Dev
	If File.Exists(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE) = False Then
		Dim o1 As dlgSonoffSetup
		o1.Initialize(Null,"")
		o1.CreateDefaultFile
	End If
	ReadSonoffCFG
	
End Sub


Public Sub ReadSonoffCFG
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.SONOFF_OPTIONS_FILE)
	
	SonoffIP = Data.Get(gblConst.SONOFF_IP)
	SonoffFLAG = Data.Get(gblConst.SONOFF_ON).As(Boolean)
	
End Sub


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
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.POWER_OPTIONS_FILE)
	
	AndroidTakeOverSleepFLAG = Data.Get("TakePwr")
	AndroidNotPrintingScrnOffFLAG = Data.Get("NotPrintingScrnOff")
	AndroidNotPrintingMinTill  = Data.Get("NotPrintingMinTill")
	AndroidPrintingScrnOffFLAG  = Data.Get("PrintingScrnOff")
	AndroidPrintingMinTill  = Data.Get("PrintingMinTill")

End Sub




