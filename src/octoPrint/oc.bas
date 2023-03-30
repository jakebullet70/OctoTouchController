B4J=true
Group=OCTOPRINT
ModulesStructureVersion=1
Type=StaticCode
Version=8.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
'Static code module
Sub Process_Globals
	Private Const mModule As String = "oc" 'ignore

	Public cPRINTER_BUSY_MSG As String = "Problem, Printer is busy"
	
	Public IsConnectionValid As Boolean = False
	
	Public OctoKey, OctoIp ,OctoPort As String
	
	Public FormatedTemps As String 
	Public FormatedStatus As String = "No Connection"
	Public FormatedJobPct As String
		
	Public isConnected As Boolean = False
	Public isPrinting As Boolean = False
	Public isCanceling As Boolean = False
	#if klipper
	Public isKlipperCanceling As Boolean = False
	#End If
	Public IsPaused2 As Boolean = False
	Public isHeating As Boolean = False
	Public isFileLoaded As Boolean = False
	Public lastJobPrintState As String = ""
	
	Public FilesB4Xmap As Map
	
	'==================================	
	
	Public OctoVersion As String = "N/A"
	Public BedTarget As String 
	Public BedActual As String
	Public Tool1Target As String, Tool1TargetReal As Float
	Public Tool1Actual As String, Tool1ActualReal As Float
	Public Tool2Target As String
	Public Tool2Actual As String, Tool2ActualReal As Float
	
	Public PrinterState As String
	Public PrinterBaud As String
	Public PrinterPort As String
	Public PrinterProfile As String '--- need the profile 1st to get the name, desc, inverted stuff
	
	Public PrinterProfileName As String
	Public PrinterProfileModel As String
	Public PrinterProfileInvertedZ As Boolean
	Public PrinterProfileInvertedX As Boolean
	Public PrinterProfileInvertedY As Boolean
	Public PrinterProfileNozzleCount As Int
	
	Public PrinterWidth,PrinterDepth As Double
	Public PrinterCustomBoundingBox As Boolean
		
	Public JobFileName As String
	Public JobFileOrigin As String
	Public JobFileSize As String
	Public JobEstPrintTime As String
	Public JobCompletion As String
	Public JobFilePos As String
	Public JobPrintTime As String
	Public JobPrintTimeLeft As String
	Public JobPrintState As String
	
	Public JobPrintThumbnail As String
	Public JobPrintThumbnailSrc As String

	#if klipper
	Public KlipperFileSrcPath As String = ""
	Public Const gcodeRelPos As String = "G91"
	#End If
	
		
	'======================================================================
	'======================================================================
	'======================================================================
	'======================================================================
	
	
	
	'https://github.com/kantlivelong/OctoPrint-PSUControl/wiki/API
	Public Const cPSU_CONTROL_K As String = $"/api/plugin/psucontrol!!{"command":"turnPSU!ONOFF!"}"$ '--- POST
	
	'---
	Public Const cAPI_KEY_PROBE As String = "/plugin/appkeys/probe" '--- GET
	Public Const cAPI_KEY_REQUEST As String = $"/plugin/appkeys/request!!{"app": "!APP!"}"$ '--- POST
	Public Const cAPI_KEY_PROBE_WAIT As String = "/plugin/appkeys/request/!APP_TOKEN!" '--- GET
	
	#if klipper
	Public const cPOST_GCODE As String = "/printer/gcode/script?script=!G!"
	#else
	'--- has a split char for the API and the JSON payload, char is '!!'
	Private const cPOST_GCODE As String = "/api/printer/command"
	Public const cPOST_GCODE_COMMAND As String = $"${cPOST_GCODE}!!{"command": "!CMD!"}"$
	Public const cPOST_GCODE_COMMANDS As String = $"${cPOST_GCODE}!!{"commands": ["!CMDS!"]}"$
	'---                                                      {"commands": ["M18","M106 S0"]}
	#End If
	
		
	
	
	#if klipper
	Public Const cFILES As String = "/server/files/list"
	#else
	Public Const cFILES As String = "/api/files"
	Public Const cFILES_ALL As String = "/api/files?recursive=true" '----  NOT WORKING ------------   PERMISSION ERROR  
	#End If
	
	
	Private const cPOST_FILES As String = "/api/files/!LOC!/!PATH!" '--- !LOC! = local or sdcard
	Public const cPOST_FILES_PRINT As String = $"${cPOST_FILES}!!{"command": "select","print": true}"$
	Public const cPOST_FILES_SELECT As String = $"${cPOST_FILES}!!{"command": "select","print": false}"$
	Public const cDELETE_FILES_DELETE As String = $"${cPOST_FILES}"$
	
	
	
	
	#if klipper
	Public const cCMD_PRINT As String =  $"/printer/print/start?filename=!FN!"$
	Public const cCMD_CANCEL As String = "/printer/print/cancel"
	Public const cCMD_PAUSE As String = "/printer/print/pause"
	Public const cCMD_RESUME As String = "/printer/print/resume"
	
	
	#else
	'--- has a split char for the API and the JSON payload, char is '!!'
	'--- has a split char for the API and the JSON payload, char is '!!'
	'--- has a split char for the API and the JSON payload, char is '!!'
	Private const cPOST_JOB As String = "/api/job"
	'Public const cCMD_RESTART As String = $"${cPOST_JOB}!!{ "command": "restart" }"$
	Public const cCMD_PRINT As String =  $"${cPOST_JOB}!!{ "command": "start" }"$
	Public const cCMD_CANCEL As String = $"${cPOST_JOB}!!{ "command": "cancel" }"$
	Public const cCMD_PAUSE As String = $"${cPOST_JOB}!!{ "command": "pause","action": "pause" }"$
	Public const cCMD_RESUME As String = $"${cPOST_JOB}!!{ "command": "pause","action": "resume" }"$
	#End If
	
	
	Private const cPOST_JOG As String = "/api/printer/printhead"
	Public const cJOG_XY_HOME As String = $"${cPOST_JOG}!!{"command": "home", "axes": ["x", "y"]}"$
	Public const cJOG_Z_HOME As String = $"${cPOST_JOG}!!{"command": "home", "axes": ["z"]}"$
	Public const cJOG_XYZ_MOVE As String = $"${cPOST_JOG}!!{"command": "jog","!DIR!": !SIZE!}"$
	
	'--- has a split char for the API and the JSON payload, char is '!!'
	'--- has a split char for the API and the JSON payload, char is '!!'
	Private const cPOST_PRINTER_TOOL As String = "/api/printer/tool"
	'--- you can change the selected tool head by replacing 'tool0' with 'tool1' to select the 2nd print head
	Public const cCMD_TOOL_SELECT As String = $"${cPOST_PRINTER_TOOL}!!{"command": "select", "tool":"tool0""$
	Public const cCMD_TOOL_EXTRUDE_RETRACT As String = $"${cPOST_PRINTER_TOOL}!!{"command": "extrude", "amount":!LEN!}"$
	
	Public const cCMD_SET_BED_TEMP As String = $"/api/printer/bed!!{"command": "target","target": !VAL!}"$
	Public const cCMD_SET_TOOL_TEMP2 As String = $"${cPOST_PRINTER_TOOL}!!{"command": "target","targets": {"tool0": !VAL0!,	"tool1": !VAL1!}}"$
	Public const cCMD_SET_TOOL_TEMP As String = $"${cPOST_PRINTER_TOOL}!!{"command": "target","targets": {"tool0": !VAL0!}}"$
	
	'======================================================================
	#if klipper
	'Public Const cCONNECTION_INFO As String = "/printer/objects/list"
	#else
	Public Const cCONNECTION_INFO As String = "/api/connection"
	Public Const cCMD_AUTO_CONNECT_STARTUP As String = $"${cCONNECTION_INFO}!!{ "command": "connect" }"$
	#End If
	
	'--- location – The location of the file for which to retrieve the information, either local or sdcard.
	Public const cFILE_INFO As String = "/api/files/!LOCATION!/!FNAME!"   
		'	{"name": "whistle_v2.gcode",
		'	"size": 1468987,
		'	"date": 1378847754,
		'	"origin": "local",
		'	"refs": {
		'	"resource": "http://example.com/api/files/local/whistle_v2.gcode",
		'	"download": "http://example.com/downloads/files/local/whistle_v2.gcode"
		'	},
		'	"gcodeAnalysis": {
		'	"estimatedPrintTime": 1188,
		'	"filament": {
		'	"length": 810,
		'	"volume": 5.36
		'	}
		'	},
		'	"print": {
		'	"failure": 4,
		'	"success": 23,
		'	"last": {
		'	"date": 1387144346,
		'	"success": True 	}	}	}
			
	
	Public const cPRINTER_PROFILES As String = "/api/printerprofiles" 
	'	{
	'	"profiles": {
	'	"_default": {
	'	"id": "_default",
	'	"name": "Default",
	'	"color": "default",
	'	"model": "Generic RepRap Printer",
	'	"default": True,
	'	"current": True,
	'	"resource": "http://example.com/api/printerprofiles/_default",
	'	"volume": {
	'	"formFactor": "rectangular",
	'	"origin": "lowerleft",
	'	"width": 200,
	'	"depth": 200,
	'	"height": 200
	'	},
	'	"heatedBed": True,
	'	"heatedChamber": False,
	'	"axes": {
	'	"x": {
	'	"speed": 6000,
	'	"inverted": False
	'	},
	'	"y": {
	'	"speed": 6000,
	'	"inverted": False
	'	},
	'	"z": {
	'	"speed": 200,
	'	"inverted": False
	'	},
	'	"e": {
	'	"speed": 300,
	'	"inverted": False
	'	}	},
	'	"extruder": {
	'	"count": 1,
	'	"offsets": [
	'	{"x": 0.0, "y": 0.0}
	'	]	}	},
	'	"my_profile": {
	'	"id": "my_profile",
	'	"name": "My Profile",
	'	"color": "default",
	'	"model": "My Custom Printer",
	'	"default": False,
	'	"current": False,
	'	"resource": "http://example.com/api/printerprofiles/my_profile",
	'	"volume": {
	'	"formFactor": "rectangular",
	'	"origin": "lowerleft",
	'	"width": 200,
	'	"depth": 200,
	'	"height": 200
	'	},
	'	"heatedBed": True,
	'	"heatedChamber": True,
	'	"axes": {
	'	"x": {
	'	"speed": 6000,
	'	"inverted": False
	'	},
	'	"y": {
	'	"speed": 6000,
	'	"inverted": False
	'	},
	'	"z": {
	'	"speed": 200,
	'	"inverted": False
	'	},
	'	"e": {
	'	"speed": 300,
	'	"inverted": False 	}	},
	'	"extruder": {
	'	"count": 1,
	'	"offsets": [
	'	{"x": 0.0, "y": 0.0}
	'	]	}	},	}	}
	'	
	
'	
'	
'	Public const cJOB_INFO As String = "/api/job"
'	'{
'	'	"job": {
'	'	"file": {
'	'	"name": "whistle_v2.gcode",
'	'	"origin": "local",
'	'	"size": 1468987,
'	'	"date": 1378847754
'	'	},
'	'	"estimatedPrintTime": 8811,
'	'	"filament": {
'	'	"tool0": {
'	'	"length": 810,
'	'	"volume": 5.36
'	'	}	}	},
'	'	"progress": {
'	'	"completion": 0.2298468264184775,
'	'	"filepos": 337942,
'	'	"printTime": 276,
'	'	"printTimeLeft": 912
'	'	},
'	'	"state": "Printing"
'	'	}

	
	Public const cSERVER As String = "/api/server"
	'https://docs.octoprint.org/en/master/api/server.html
	'{"safemode":null,"version":"1.5.2"}
		
	Public const cVERSION As String = "/api/version"
	'https://docs.octoprint.org/en/master/api/version.html
	'{"api":"0.1","server":"1.5.2","text":"OctoPrint 1.5.2"}
			
	Public const cCURRENT_USER As String = "/api/currentuser"
	'{"groups":["admins","users"],"name":"_api","permissions":
	'["ADMIN","STATUS","CONNECTION","WEBCAM","SYSTEM","FILES_LIST","FILES_UPLOAD","FILES_DOWNLOAD","FILES_DELETE","FILES_SELECT","PRINT","GCODE_VIEWER","MONITOR_TERMINAL","CONTROL","SLICE","TIMELAPSE_LIST","TIMELAPSE_DOWNLOAD","TIMELAPSE_DELETE","TIMELAPSE_ADMIN","SETTINGS_READ","SETTINGS","PLUGIN_ACTION_COMMAND_NOTIFICATION_SHOW","PLUGIN_ACTION_COMMAND_NOTIFICATION_CLEAR","PLUGIN_ACTION_COMMAND_PROMPT_INTERACT","PLUGIN_ANNOUNCEMENTS_READ","PLUGIN_ANNOUNCEMENTS_MANAGE","PLUGIN_APPKEYS_ADMIN","PLUGIN_BACKUP_ACCESS","PLUGIN_FIRMWARE_CHECK_DISPLAY","PLUGIN_LOGGING_MANAGE","PLUGIN_PI_SUPPORT_STATUS","PLUGIN_PLUGINMANAGER_MANAGE","PLUGIN_PLUGINMANAGER_INSTALL","PLUGIN_SOFTWAREUPDATE_CHECK","PLUGIN_SOFTWAREUPDATE_UPDATE","PLUGIN_SOFTWAREUPDATE_CONFIGURE"]}
	
	Public const cPRINTER_MASTER_STATE As String = "/api/printer"
	'	{
	'	"temperature": {
	'	"tool0": {
	'	"actual": 214.8821,
	'	"target": 220.0,
	'	"offset": 0
	'	},
	'	"tool1": {
	'	"actual": 25.3,
	'	"target": Null,
	'	"offset": 0
	'	},
	'	"bed": {
	'	"actual": 50.221,
	'	"target": 70.0,
	'	"offset": 5
	'	},
	'	"history": [
	'	{
	'	"time": 1395651928,
	'	"tool0": {
	'	"actual": 214.8821,
	'	"target": 220.0
	'	},
	'	"tool1": {
	'	"actual": 25.3,
	'	"target": Null
	'	},
	'	"bed": {
	'	"actual": 50.221,
	'	"target": 70.0
	'	}	},
	'	{
	'	"time": 1395651926,
	'	"tool0": {
	'	"actual": 212.32,
	'	"target": 220.0
	'	},
	'	"tool1": {
	'	"actual": 25.1,
	'	"target": Null
	'	},
	'	"bed": {
	'	"actual": 49.1123,
	'	"target": 70.0
	'	} } ] },
	'	"sd": {
	'	"ready": True
	'	},
	'	"state": {
	'	"text": "Operational",
	'	"flags": {
	'	"operational": True,
	'	"paused": False,
	'	"printing": False,
	'	"cancelling": False,
	'	"pausing": False,
	'	"sdReady": True,
	'	"error": False,
	'	"ready": True,
	'	"closedOrError": False
	'	}	}	}

''''''''	'----  NOT WORKING ------------   PERMISSION ERROR  exclude issue?????
''''''''	'----  NOT WORKING ------------   PERMISSION ERROR  exclude issue?????
''''''''	Public const cPRINTER_HEATER As String = "/api/printer?exclude=sd,state"
''''''''	'	{
''''''''	'	"temperature": {
''''''''	'	"tool0": {
''''''''	'	"actual": 214.8821,
''''''''	'	"target": 220.0,
''''''''	'	"offset": 0
''''''''	'	},
''''''''	'	"tool1": {
''''''''	'	"actual": 25.3,
''''''''	'	"target": Null,
''''''''	'	"offset": 0
''''''''	'	},
''''''''	'	"bed": {
''''''''	'	"actual": 50.221,
''''''''	'	"target": 70.0,
''''''''	'	"offset": 5
''''''''	'	}, }

''''''''	'----  NOT WORKING ------------   PERMISSION ERROR exclude issue?????
''''''''	'----  NOT WORKING ------------   PERMISSION ERROR   exclude issue?????
''''''''	Public const cPRINTER_OPERATION_STATUS As String = "/api/printer?exclude=temperature,sd"
''''''''	'	{
''''''''	'	"state": {
''''''''	'	"text": "Operational",
''''''''	'	"flags": {
''''''''	'	"operational": True,
''''''''	'	"paused": False,
''''''''	'	"printing": False,
''''''''	'	"cancelling": False,
''''''''	'	"pausing": False,
''''''''	'	"sdReady": True,
''''''''	'	"error": False,
''''''''	'	"ready": True,
''''''''	'	"closedOrError": False
''''''''	'	}	}	}
	
	
	Public const cPRINTER_TEMPLATES As String = "/api/settings/templates"
	
	
End Sub




public Sub ResetAllOctoVars
		
	isConnected  = False
	isPrinting = False
	isFileLoaded = False
	isCanceling = False
	IsPaused2 = False
	isHeating = False
	OctoVersion   = "N/A"
	#if klipper
	KlipperFileSrcPath = ""
	isKlipperCanceling = False
	#End If
	
	FilesB4Xmap.Initialize
		
	ResetStateVars
	ResetJobVars
	ResetTempVars
	RestPrinterProfileVars
	
End Sub

Public Sub ResetTempVars
	
	BedTarget    = "Off"
	BedActual     = "0.0" & gblConst.DEGREE_SYMBOL & "C"
	Tool1Target  = "Off"
	Tool1Actual   = "0.0" & gblConst.DEGREE_SYMBOL & "C"
	Tool2Target  =  "0.0" & gblConst.DEGREE_SYMBOL & "C"
	Tool2Actual   = "0.0" & gblConst.DEGREE_SYMBOL & "C"
	Tool1ActualReal = 0.0
	Tool2ActualReal = 0.0
	Tool1TargetReal = 0.0
	isHeating = False
	
End Sub

public Sub ResetJobVars
	
	JobFileName = ""
	JobFileOrigin = ""
	JobFileSize = "-"
	JobEstPrintTime = "-"
	JobCompletion = "0"
	JobFilePos = "0"
	JobPrintTime = "-"
	JobPrintTimeLeft = "-"
	JobPrintState = "Operational"
	lastJobPrintState = JobPrintState
	
End Sub

Public Sub RestPrinterProfileVars

	PrinterProfileName = ""
	PrinterProfileModel  = ""
	PrinterProfileInvertedZ = False
	PrinterProfileInvertedX = False
	PrinterProfileInvertedY = False
	PrinterProfileNozzleCount = 0
	
End Sub

Public Sub ResetStateVars
	
	PrinterBaud = ""
	PrinterPort = ""
	PrinterState = "Disconnected"
	PrinterProfile = ""
	
End Sub

		
	
	
	
