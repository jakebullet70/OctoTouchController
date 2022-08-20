B4J=true
Group=OCTOPRINT\PARSORS
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
' Author:  sadLogic, Kherson Ukraine
#Region VERSIONS 
' V. 1.0 	Aug/20/2022
#End Region
Sub Class_Globals
	Private Const mModule As String = "JsonParserConnectionStatus" 'ignore
End Sub


Public Sub Initialize
End Sub


public Sub ConnectionStatus(s As String) 
	
	Dim m, mm As Map
	Dim jp As JSONParser
	Try
	
		jp.Initialize(s)
	
		'--- populate json maps
		m = jp.NextObject
		mm = m.Get("current").As(Map)
	
		oc.PrinterBaud = mm.Get("baudrate")
		oc.PrinterPort = mm.Get("port")
		oc.PrinterState = mm.Get("state")
		oc.PrinterProfile = mm.Get("printerProfile") '--- this is NOT the name of the printer! See 'cPRINTER_PROFILES'
		oc.isConnected = True
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		oc.ResetStateVars
		
	End Try
	
End Sub

