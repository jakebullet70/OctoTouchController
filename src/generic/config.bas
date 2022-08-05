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
	
	Public colorTheme As String 
	'Public MQTTserverOnFLAG As Boolean = False
	'Public MQTTclientOnFLAG As Boolean = False
	
	Public LastConnectedClient As String
	Public pTurnOnDebugTabFLAG As Boolean

	Public AndroidTakeOverSleepFLAG As Boolean = False  
	Public AndroidNotPrintingScrnOffFLAG As Boolean = False 
	Public AndroidNotPrintingMinTill As Int
	Public AndroidPrintingScrnOffFLAG As Boolean = False
	Public AndroidPrintingMinTill As Int
	
	'--- also turn of screen after X minutes after print is done
	
End Sub


public Sub Load()
	
	'--- get theme from config file -- TODO
	'colorTheme = "system light" '--- not used
	
	Dim Data As Map '--- temp var
	
	If File.Exists(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE) = False Then
		Dim o1 As dlgLogging
		o1.initialize(Null)
		o1.createdefaultfile
	End If
	
	Try
'  TODO		
'		Data = File.ReadMap(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE)
'		logMe.pLogFull =  Data.Get("fulllog").As(Boolean)
'		logMe.gDaysOfOldLogsBeforeDelete =  Data.Get("days")
'		pTurnOnDebugTabFLAG = Data.Get("dbgtab").As(Boolean)
	
		
	Catch
		Log(LastException)
	End Try
	
	'======================================================================
	
	If File.Exists(xui.DefaultFolder,gblConst.POWER_OPTIONS_FILE) = False Then
		Dim o2 As dlgPower
		o2.Initialize(Null)  
		o2.CreateDefaultFile
	End If
		
	Data = File.ReadMap(xui.DefaultFolder,gblConst.POWER_OPTIONS_FILE)
	
	AndroidTakeOverSleepFLAG = Data.Get("TakePwr")
	AndroidNotPrintingScrnOffFLAG = Data.Get("NotPrintingScrnOff")
	AndroidNotPrintingMinTill  = Data.Get("NotPrintingMinTill")
	AndroidPrintingScrnOffFLAG  = Data.Get("PrintingScrnOff")
	AndroidPrintingMinTill  = Data.Get("PrintingMinTill")

	'TODO!!!!!!!!!!!!!!!!    write the code to do power crap!
	
End Sub


