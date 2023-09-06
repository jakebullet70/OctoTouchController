B4A=true
Group=GENERIC
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/6/2023
' Seeds optional GCODE - On/Off files on 1st install
#End Region

Sub Class_Globals
	Private m As Map
	Private s As StringBuilder
End Sub

Public Sub Initialize
End Sub


#if klipper

Public Sub SeedBedLevelKlipper() As Map
	m.Initialize
		
	m = CreateMap("desc": "Level Bed Macro", "prompt":"true", _
			      "gcode": "@G29",  "wmenu": "false",  "rmenu":"false")
	Return m
End Sub

#else


Public Sub SeedBedLevelMarlin() As Map
	s.Initialize
	m.Initialize
	
	s.Append("M140 S60").Append(CRLF).Append("M117 Homing all").Append(CRLF)
	s.Append("G28").Append(CRLF)
	s.Append("M420 S0").Append(CRLF)
	s.Append("M117 Heating the bed").Append(CRLF)
	s.Append("M190 S60").Append(CRLF)
	s.Append("M300 S1000 P500").Append(CRLF)
	s.Append("G29 T").Append(CRLF)
	s.Append("M140 S0").Append(CRLF)
	s.Append("M500").Append(CRLF)
	s.Append("M300 S440 P200").Append(CRLF).Append("M300 S660 P250").Append(CRLF).Append("M300 S880 P300").Append(CRLF)
	s.Append("G28").Append(CRLF)
	s.Append("M117 Bed leveling done!").Append(CRLF)
	
	
	m = CreateMap("desc": "Level Bed (G29 - Heated 60c)", "prompt":"true", _
			      "gcode": s.ToString,  "wmenu": "false",  "rmenu":"false")
	Return m
End Sub


#end if
