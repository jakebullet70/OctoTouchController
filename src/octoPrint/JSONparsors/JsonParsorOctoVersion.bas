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
	Private Const mModule As String = "JsonParsorOctoVersion" 'ignore
End Sub


Public Sub Initialize
End Sub


Public Sub ServerOctoVersion(s As String)

	Try
		
		Dim m As Map,  jp As JSONParser
		jp.Initialize(s)
		m = jp.NextObject
		oc.OctoVersion = m.Get("version")
		oc.isConnected = True
		
	Catch
		
		logMe.LogIt2(LastException,mModule,"ServerOctoVersion")
		
	End Try
	
End Sub

