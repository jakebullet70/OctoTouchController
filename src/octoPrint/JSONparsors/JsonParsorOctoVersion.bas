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


public Sub ServerOctoVersion(s As String)

	Dim InSub As String = "ServerOctoVersion"
	Try
		
		Dim m As Map,  jp As JSONParser
		jp.Initialize(s)
		m = jp.NextObject
		oc.OctoVersion = m.Get("version")
		oc.isConnected = True
		
	Catch
		
		logMe.LogIt2(LastException,mModule,InSub)
		
	End Try
	
End Sub