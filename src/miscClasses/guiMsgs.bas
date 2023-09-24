﻿B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0	Sept/27/2022
#End Region

Sub Class_Globals
	Private Const mModule As String = "guiMsgs" 'ignore
	'--- just seldom used strings in a class
	Dim Msg As StringBuilder 
	Dim xui As XUI
End Sub

Public Sub Initialize
End Sub


'Private Sub ReplaceOcto2KlipperTxt(s As String) As String
'	#if klipper
'	Return s.Replace("Octoprint","Klipper")
'	#else
'	Return s
'	#End If
'	
'End Sub

Public Sub GetConnectFailedMsg() As String
	Msg.Initialize
	Msg.Append("Connection Failed.").Append(CRLF)
	Msg.Append("Is Octoprint turned on?").Append(CRLF).Append("Are Your IP And Port correct?").Append(CRLF)
	Return Msg.ToString
End Sub



Public Sub GetConnectionText(connectedButError As Boolean) As String
	
	Msg.Initialize
	
	If connectedButError Then
		Msg.Append("Connected to Octoprint but there is an error.").Append(CRLF)
		Msg.Append("Check that Octoprint is connected to the printer?").Append(CRLF)
		Msg.Append("Make sure you can print from the Octoprint UI.")
	Else
		Msg.Append("No connection to Octoprint. Is Octoprint turned on?")
		Msg.Append(CRLF).Append("Connected to the printer?")
	End If
	
	Return Msg.ToString
End Sub

Public Sub GetOctoPluginWarningTxt() As String
	
	Msg.Initialize
	Msg.Append("When setting up a connection here to an Octoprint ")
	Msg.Append("plugin make sure it is working in Octoprint first ")
	Msg.Append("before you complete the setup here.").Append(CRLF)
	
	Return Msg.ToString
	
End Sub


'Public Sub GetOctoSysCmdsWarningTxt() As String
'	
'	Msg.Initialize
'	Msg.Append("To have access to Octoprint System commands ")
'	Msg.Append("you first need to grant the 'SYSTEM' permission ")
'	Msg.Append("in Octoprint to the current user.  ").Append(CRLF)
'	'Msg.Append("").Append(CRLF)
'	Msg.Append("(See the Wiki in GitHub for hints)").Append(CRLF)
'	
'	Return ReplaceOcto2KlipperTxt(Msg.ToString)
'	
'End Sub

Public Sub BuildOptionsMenu(NoOctoConnection As Boolean) As Map
	
	Dim cs As CSBuilder 
	Dim m As Map : m.Initialize
	
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE30B)). _
				 Typeface(Typeface.DEFAULT).Append("   General Settings").PopAll,"gn")				 
	
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE859)). _
				 Typeface(Typeface.DEFAULT).Append("   Power Settings").PopAll,"pw")

	#if klipper
	'------------------------------  TODO !!!!!!!!!!!!!!!!!
'	cs.Initialize
'	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
'				 Typeface(Typeface.DEFAULT).Append("   Macro's Menu").PopAll,"mac")
				 
'	cs.Initialize
'	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
'				 Typeface(Typeface.DEFAULT).Append("   Presets Menu").PopAll,"prs")
	'cs.Initialize
'	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE308)). _
'				 Typeface(Typeface.DEFAULT).Append("   Firmware MCU Menu").PopAll,"fmw")
'	cs.Initialize
	'------------------------------  TODO !!!!!!!!!!!!!!!!!
	#end if
	
	#if not (klipper)
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE8C1)). _
				 Typeface(Typeface.DEFAULT).Append("   Side Plugins Menu").PopAll,"plg")				 
	
	#ELSE
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE8C1)). _
				 Typeface(Typeface.DEFAULT).Append("   External Control Menu").PopAll,"plg")				 
	#end if
	
	
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
				 Typeface(Typeface.DEFAULT).Append("   Movement Functions Menu").PopAll,"fn")
		
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE3B7)). _
				 Typeface(Typeface.DEFAULT).Append("   Color Themes").PopAll,"thm1")				 
				 
	If NoOctoConnection = False Then
		m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE308)). _
				 	 Typeface(Typeface.DEFAULT).Append("   Printer Connection").PopAll,"oc")	
	End If
	
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24D)). _
				 Typeface(Typeface.DEFAULT).Append("   Read Internal Log File").PopAll,"rt")
	
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE864)). _
				 Typeface(Typeface.DEFAULT).Append("   Check For Update").PopAll,"cup")
	
	m.Put(cs.Initialize.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE85A)). _
				 Typeface(Typeface.DEFAULT).Append("   About Me (Yes, Me!)").PopAll,"ab")
	
	Return m
	
End Sub

Public Sub BuildCoolingFanMnu() As Map
	Dim cs As CSBuilder
	Dim po As Map : po.Initialize
	
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan Off").PopAll,"0")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 100%").PopAll,"100")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 77%").PopAll,"75")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 50%").PopAll,"50")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 25%").PopAll,"25")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 33%").PopAll,"33")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 40%").PopAll,"40")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 60%").PopAll,"60")
	po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(" Fan 85%").PopAll,"85")
	
	Return po
	
End Sub


Public Sub BuildFunctionSetupMenu() As Map
	
	Dim txt As String
	Dim cs As CSBuilder
	Dim po As Map : po.Initialize
	
	'----------------------------------------------------------------
	txt = " Change Filament Wizard"
	If config.ReadWizardFilamentChangeFLAG  Then
		po.Put(cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(2dip).Append(Chr(0xE5CA)). _
										Typeface(Typeface.DEFAULT).Append(txt).PopAll,"fl")
	Else
		po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(txt.Trim).PopAll,"fl")
	End If
	
	
	'----------------------------------------------------------------
	If oc.Klippy Then
		txt = " Screw Bed Leveling Wizard"
	Else
		txt = " Manual Bed Leveling Wizard"
	End If
	If config.ReadManualBedScrewLevelFLAG  Then
		po.Put(cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(2dip).Append(Chr(0xE5CA)). _
										Typeface(Typeface.DEFAULT).Append(txt).PopAll,"bl")
	Else
		po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(txt.Trim).PopAll,"bl")
	End If
	
	
'	'----------------------------------------------------------------
'	txt = " Manual Mesh Wizard"
'	txt = " Auto Bed Leveling Wizard"
'   txt = " Set Z Offset Wizard"
'	Else
'		po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(txt.Trim).PopAll,"bl") ' this should work
'	End If
	
	
	
	'----------------------------------------------------------------
	txt = " BL/CR Touch Test Settings"
	If config.ReadBLCRtouchFLAG  Then
		po.Put(cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(2dip).Append(Chr(0xE5CA)). _
										Typeface(Typeface.DEFAULT).Append(txt).PopAll,"blcr")
	Else
		po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(txt.Trim).PopAll,"blcr")
	End If
	
	
	
	Dim data As Map, fname As String
	For xx = 0 To 7
		fname = xx & gblConst.GCODE_CUSTOM_SETUP_FILE
		If File.Exists(xui.DefaultFolder,fname) Then
			data = File.ReadMap(xui.DefaultFolder,fname)
			txt = " " & data.Get("desc")
			Dim rOn As Boolean = data.GetDefault("rmenu",False)
			Dim wOn As Boolean = data.GetDefault("wmenu",False)
			If rOn Or wOn Then
				po.Put(cs.Initialize.Typeface(Typeface.MATERIALICONS).VerticalAlign(2dip).Append(Chr(0xE5CA)). _
											Typeface(Typeface.DEFAULT).Append(txt).PopAll,"g" & xx)
			Else
				po.Put(cs.Initialize.Typeface(Typeface.DEFAULT).Append(txt.Trim).PopAll,"g" & xx)
			End If
		End If
	Next
	
	Return po
End Sub

'Public Sub GetIpSetupText() As String
'	Msg.Initialize
'	Msg.Append("SonOff With Tasmota Firmware Example").Append(CRLF)
'	Msg.Append("http://192.168.1.XXX/cm?cmnd=Power On").Append(CRLF)
'	Msg.Append("http://192.168.1.XXX/cm?cmnd=Power Off").Append(CRLF).Append(CRLF)
'	Msg.Append("You can really use any HTTP capible device.").Append(CRLF)
'	Msg.Append("Test it first in your local browser to make sure it works.").Append(CRLF)
'	Return Msg.ToString
'End Sub



Public Sub BuildPluginOptionsMenu() As Map
'	#if klipper
'	Dim popUpMemuItems As Map = CreateMap("Power Supply HTTP Control":"psu")
'	#else
	'Dim popUpMemuItems As Map = CreateMap("PSU Control":"psu","ZLED Setup":"led","ws281x Setup":"ws2")
	Dim popUpMemuItems As Map = CreateMap("PSU Control":"psu")
	'#End If
	
	For xx = 1 To 8
		Dim fname As String = xx & gblConst.HTTP_ONOFF_SETUP_FILE
		Dim Data As Map = File.ReadMap(xui.DefaultFolder,fname)
		Dim desc As String = Data.GetDefault("desc","Generic HTTP Control " & xx)
		popUpMemuItems.Put(desc,xx)
	Next
	
	Return popUpMemuItems
	
End Sub