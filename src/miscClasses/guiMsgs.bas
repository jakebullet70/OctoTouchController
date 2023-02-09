B4A=true
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
End Sub

Public Sub Initialize
End Sub


Public Sub GetConnectFailedMsg() As String
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("Connection Failed.").Append(CRLF)
	msg.Append("Is Octoprint turned on?").Append(CRLF).Append("Are Your IP And Port correct?").Append(CRLF)
	Return msg.ToString
End Sub



Public Sub GetConnectionText(connectedButError As Boolean) As String
	
	Dim Msg As StringBuilder : Msg.Initialize
	
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
	
	Dim Msg As StringBuilder : Msg.Initialize
	Msg.Append("When setting up a connection here to an Octoprint ")
	Msg.Append("plugin make sure it is working in Octoprint first ")
	Msg.Append("before you complete the setup here.").Append(CRLF)
	
	Return Msg.ToString
	
End Sub


Public Sub GetOctoSysCmdsWarningTxt() As String
	
	Dim Msg As StringBuilder : Msg.Initialize
	Msg.Append("To have access to Octoprint System commands ")
	Msg.Append("you first need to grant the 'SYSTEM' permission ")
	Msg.Append("in Octoprint to the current user. Please see the ")
	Msg.Append("(Wiki in GitHub for instuctions.)").Append(CRLF)
	
	Return Msg.ToString
	
End Sub

Public Sub BuildOptionsMenu(NoOctoConnection As Boolean) As Map
	
	Dim cs As CSBuilder 
	Dim m As Map : 	m.Initialize
	
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE30B)). _
				 Typeface(Typeface.DEFAULT).Append("   General Settings").PopAll,"gn")				 
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE859)). _
				 Typeface(Typeface.DEFAULT).Append("   Power Settings").PopAll,"pw")
				 	
	If NoOctoConnection = False Then
		cs.Initialize
		m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE308)). _
				 	 Typeface(Typeface.DEFAULT).Append("   Octoprint Connection").PopAll,"oc")	
	End If
	
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
				 Typeface(Typeface.DEFAULT).Append("   Functions Menu").PopAll,"fn")
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE8C1)). _
				 Typeface(Typeface.DEFAULT).Append("   Plugins Menu").PopAll,"plg")				 
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE3B7)). _
				 Typeface(Typeface.DEFAULT).Append("   Color Theme").PopAll,"thm1")				 
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24D)). _
				 Typeface(Typeface.DEFAULT).Append("   Read Log File").PopAll,"rt")
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE864)). _
				 Typeface(Typeface.DEFAULT).Append("   Check For Update").PopAll,"cup")
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE85A)). _
				 Typeface(Typeface.DEFAULT).Append("   About Me!").PopAll,"ab")
	
	Return m
	
End Sub


