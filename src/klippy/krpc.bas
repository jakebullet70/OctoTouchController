B4J=true
Group=KLIPPY
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Apr/26/2023
'			Klippy RPC commands
#End Region
'Static code module
Sub Process_Globals

	Public GCODE As String = $"{"jsonrpc": "2.0","method": "printer.gcode.script","params": {"script": "!G!"},"id": 7466}"$
	
End Sub
