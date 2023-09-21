B4J=true
Group=OCTOPRINT\PARSORS-RestAPI
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
' Author:  sadLogic, Kherson Ukraine
#Region VERSIONS 
' V. 1.0 	Feb/23/2023
#End Region
Sub Class_Globals
	Private Const mModule As String = "JsonParsorPlugins" 'ignore
End Sub


Public Sub Initialize
End Sub

'--- code to parse plugins ----
'--- but at this time we only care about detecting if OctoKlipper is installed --
'----------------------------------------------------------------------------------------------


Public Sub IsOctoKlipperRunning(s As String) As Boolean

	If s.Contains("OctoKlipper") Then
		
		'--- lets see if its turned on
		Dim parser As JSONParser : 	parser.Initialize(s)
		Dim root As Map = parser.NextObject
		Dim plugins As List = root.Get("plugins")
		
		For Each colplugins As Map In plugins
			If colplugins.Get("name") = "OctoKlipper" Then
				Dim b As String = colplugins.Get("enabled")
				If b.ToLowerCase = "true" Then
					Return True
				End If
			End If
		Next
	End If

	Return False '--- not installed
	
End Sub


'============================================================================

'Dim parser As JSONParser
'parser.Initialize(<text>)
'Dim root As Map = parser.NextObject
'Dim supported_extensions As Map = root.Get("supported_extensions")
'Dim python As List = supported_extensions.Get("python")
'For Each colpython As String In python
'Next
'Dim archive As List = supported_extensions.Get("archive")
'For Each colarchive As String In archive
'Next
'Dim octoprint As String = root.Get("octoprint")
'Dim os As String = root.Get("os")
'Dim pip As Map = root.Get("pip")
'Dim virtual_env As String = pip.Get("virtual_env")
'Dim install_dir As String = pip.Get("install_dir")
'Dim python As String = pip.Get("python")
'Dim use_user As String = pip.Get("use_user")
'Dim available As String = pip.Get("available")
'Dim additional_args As String = pip.Get("additional_args")
'Dim version As String = pip.Get("version")
'Dim plugins As List = root.Get("plugins")
'For Each colplugins As Map In plugins
'	Dim safe_mode_victim As String = colplugins.Get("safe_mode_victim")
'	Dim pending_install As String = colplugins.Get("pending_install")
'	Dim pending_disable As String = colplugins.Get("pending_disable")
'	Dim pending_enable As String = colplugins.Get("pending_enable")
'	Dim python As String = colplugins.Get("python")
'	Dim bundled As String = colplugins.Get("bundled")
'	Dim disabling_discouraged As String = colplugins.Get("disabling_discouraged")
'	Dim author As String = colplugins.Get("author")
'	Dim origin As String = colplugins.Get("origin")
'	Dim description As String = colplugins.Get("description")
'	Dim version As String = colplugins.Get("version")
'	Dim enabled As String = colplugins.Get("enabled")
'	Dim url As String = colplugins.Get("url")
'	Dim pending_uninstall As String = colplugins.Get("pending_uninstall")
'	Dim incompatible As String = colplugins.Get("incompatible")
'	Dim license As String = colplugins.Get("license")
'	Dim blacklisted As String = colplugins.Get("blacklisted")
'	Dim name As String = colplugins.Get("name")
'	Dim forced_disabled As String = colplugins.Get("forced_disabled")
'	Dim managable As String = colplugins.Get("managable")
'	Dim key As String = colplugins.Get("key")
'	Dim notifications As String = colplugins.Get("notifications")
'Next
'Dim safe_mode As String = root.Get("safe_mode")
'Dim online As String = root.Get("online")

'====================================================================



