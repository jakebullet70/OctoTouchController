B4J=true
Group=OCTOPRINT\PARSORS-RestAPI
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


Public Sub ConnectionStatus(s As String) 
	
	'--- TODO V2 should be replace with another methoid that returns less data
	
	Dim m As Map 'ignore
	Dim InSub As String = "ConnectionStatus"
	Dim jp As JSONParser
	Try
	
		jp.Initialize(s)
	
		'--- populate json maps
		m = jp.NextObject
		'mm = m.Get("current").As(Map)
	
'		oc.PrinterBaud = mm.Get("baudrate")
'		oc.PrinterPort = mm.Get("port")
'		oc.PrinterState = mm.Get("state")
'		oc.PrinterProfile = mm.Get("printerProfile") '--- this is NOT the name of the printer! See 'cPRINTER_PROFILES'
		oc.isConnected = True
		
	Catch
		
		logMe.LogIt2(LastException,mModule,InSub)
		oc.ResetStateVars
		
	End Try
	
End Sub


#if klipper
Public Sub ConnectionStatusKlipper(s As String) 
	
	Dim m, flags As Map, InSub As String = "ConnectionStatusKlipper"
	Dim jp As JSONParser
	Try
	
		jp.Initialize(s)
	'Log(s)
		'--- populate json maps
		m = jp.NextObject
		Dim state As Map = m.Get("state")
		Dim flags As Map = state.Get("flags")
		Dim error As Boolean = flags.Get("error")
		Dim closedOrError As Boolean = flags.Get("closedOrError")
		Dim op As Boolean =  flags.Get("operational")
		Dim ready As Boolean = flags.Get("ready")
		'oc.isConnected = ((Not (error)) Or closedOrError) 'And op
		oc.isConnected = (ready Or op) And ((Not (error)) Or closedOrError)
		If oc.isConnected = False Then oc.ResetTempVars
	
'		oc.PrinterBaud = mm.Get("baudrate")
'		oc.PrinterPort = mm.Get("port")
		'oc.PrinterProfile = mm.Get("printerProfile") '--- this is NOT the name of the printer! See 'cPRINTER_PROFILES'
		
	Catch
		
		logMe.LogIt2(LastException,mModule,InSub)
		oc.ResetStateVars
		
	End Try
	
End Sub
#End If

'Dim parser As JSONParser
'parser.Initialize(<text>)
'Dim root As Map = parser.NextObject
'Dim temperature As Map = root.Get("temperature")
'Dim bed As Map = temperature.Get("bed")
'Dim actual As Double = bed.Get("actual")
'Dim offset As Int = bed.Get("offset")
'Dim target As Double = bed.Get("target")
'Dim tool0 As Map = temperature.Get("tool0")
'Dim actual As Double = tool0.Get("actual")
'Dim offset As Int = tool0.Get("offset")
'Dim target As Double = tool0.Get("target")
'Dim state As Map = root.Get("state")
'Dim flags As Map = state.Get("flags")
'Dim paused As String = flags.Get("paused")
'Dim pausing As String = flags.Get("pausing")
'Dim ready As String = flags.Get("ready")
'Dim operational As String = flags.Get("operational")
'Dim closedOrError As String = flags.Get("closedOrError")
'Dim error As String = flags.Get("error")
'Dim cancelling As String = flags.Get("cancelling")
'Dim printing As String = flags.Get("printing")
'Dim text As String = state.Get("text")
