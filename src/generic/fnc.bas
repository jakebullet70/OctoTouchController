B4J=true
Group=GENERIC
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/27/2022
#End Region
'Static code module
Sub Process_Globals
	Private xui As XUI
End Sub


public Sub ReadConnectionFile(cn As HttpOctoRestAPI) As Boolean
	
	oc.IsOctoConnectionVarsValid = False '--- assume bad
	
	Dim m As Map = LoadPrinterConnectionSettings
	If m.IsInitialized = False Then
		Return False
	End If
	
	oc.OctoIp = m.Get( gblConst.PRINTER_IP)
	oc.OctoKey = m.Get( gblConst.PRINTER_OCTO_KEY)
	oc.OctoPort = m.Get( gblConst.PRINTER_PORT)
	
	'--- Baby Hypercube
	'gbl.cn.Initialize("192.168.1.207","80","C2F4DA9C48494DB3BE4AD241158E96D5")
	'---- VIRT test
	'cn.Initialize("192.168.1.236","5003","255A0F82BEFB49689062A3290C125F10") 'octoAPIkey (sub key) has permission issues
	
	'cn.Initialize("192.168.1.236","5003","D09FA63DCB9940109FDCB1750304A067",B4XPages.MainPage) 'octoAPIkey (MAIN GLOBAL key)
	cn.Initialize(oc.OctoIp ,oc.OctoPort,oc.OctoKey) 'octoAPIkey (MAIN GLOBAL key)
	
	oc.IsOctoConnectionVarsValid = True
	Return True
	
End Sub



Public Sub LoadPrinterConnectionSettings() As Map
	
	'--- get the settings connection file
	Dim fname As String
	Dim flist As List
	
	'--- Should only be 1 settings file at this point
	flist = fileHelpers.WildCardFilesList(xui.DefaultFolder,"*.psettings",False,False)
	If flist.Size = 0 Then
		Return Null
	Else
		If flist.Size = 1 Then
			fname = flist.Get(0)
		Else
			Log("TODO - we have to many .psetting config files, time for a popup selection!")
			Return Null
		End If
	End If
	
	Dim inMap As Map = File.ReadMap(xui.DefaultFolder,fname)
	Return inMap
	
End Sub



'================================= misc functions - methods ====================================
'================================= misc functions - methods ====================================
'================================= misc functions - methods ====================================
'================================= misc functions - methods ====================================

public Sub GetPrinterProfileConnectionFileName(UserProfileDescription As String) As String
	
	'--- returns a valid printer settings filename based off of the user entered description
	'--- all files ending in '.psettings' will be valid primter connectikon setting in a map format
	'	FORMAT CreateMap( _
	'						gblConst.PRINTER_DESC : txtPrinterDesc.text, gblConst.PRINTER_IP: txtPrinterIP.Text, _
	'						gblConst.PRINTER_PORT : txtPrinterPort.Text, gblConst.PRINTER_OCTO_KEY : txtOctoKey.Text)
	
	Return fileHelpers.CheckAndCleanFileName(UserProfileDescription) &  "__" & _
						gblConst.PRINTER_SETTING_BASE_FILE_NAME & ".psettings"
	

End Sub



'Public Sub IsValidIPv4Address(IPAddress As String) As Boolean
'	'Tests given string if it looks like an ipv4 address
'	Return Regex.IsMatch("^(([01]?\d\d?|2[0-4]\d|25[0-5])\.){3}([01]?\d\d?|2[0-4]\d|25[0-5])$", IPAddress)
'End Sub
'
'
'Public Sub IsValidIPv6Address(IPAddress As String) As Boolean
'	'Tests given string if it looks like an ipv6 address
'	Return Regex.IsMatch("^([0-9a-f]{1,4}:){7}([0-9a-f]){1,4}$", IPAddress)
'End Sub


Public Sub CleanOldThumbnailFiles
	
	Log("CleanOldThumbnailFiles")
	
	Dim flist As List
	flist = fileHelpers.WildCardFilesList(xui.DefaultFolder,"sad__*",False,False)
	For Each fname In flist
		fileHelpers.SafeKill(fname)
	Next
	
End Sub


public Sub BuildThumbnailTempFilename(fname As String) As String
	'--- adding a pre-fix to the thumnail filename so we
	'--- can mass delete them if neded
	Return "sad__" & fname
End Sub


public Sub GetFilenameFromHTTP(URL As String) As String
	
	'--- used by the thumbnail URL, just returns the filename
	Try
		Return URL.SubString2(URL.LastIndexOf("/") + 1,URL.Length)
	Catch
		Return URL
	End Try
	
End Sub


Private Sub ConvertSecondsToComponents(S As Long) As Int()    'days, hours, minutes, seconds

	'--- used by 'ConvertSecondsToString'
	
	Dim NumDays As Int = S / 86400
	S = S - NumDays * 86400

	Dim NumHours As Int = S / 3600
	S = S - NumHours * 3600

	Dim NumMinutes As Int = S / 60
	S = S - NumMinutes * 60

	Dim NumSeconds As Int = S
	Return Array As Int(NumDays, NumHours, NumMinutes, NumSeconds)
   
End Sub



Public Sub ConvertSecondsToString(str As String) As String    'D:HH:MM:SS

	If IsNumber(str) = False Then
		If str = "null" Then Return "-"
		Return str
	End If
	
	Dim s As Long = str

	Dim TC() As Int = ConvertSecondsToComponents(S)
	Dim sb As StringBuilder : 	sb.Initialize
	
	If TC(0) <> 0 Then 	'----  only add day if it is there
		sb.Append($"${TC(0)}"$)
	End If
	If TC(1) <> 0 Then
		sb.Append($"${NumberFormat(TC(1),2,0)}:"$)
	Else
		sb.Append("00:")
	End If
	If TC(2) <> 0 Then
		sb.Append($"${NumberFormat(TC(2),2,0)}:"$)
	Else
		sb.Append("00:")
	End If
	If TC(3) <> 0 Then
		sb.Append($"${NumberFormat(TC(3),2,0)}"$)
	Else
		sb.Append("00")
	End If

	Return strHelpers.TrimLast(sb.ToString,":")

End Sub

'
'public Sub ConvertSecondsToString2(S As Long) As String    'D:HH:MM:SS
'
'	Dim TC() As Int = ConvertSecondsToComponents(S)
'	Dim sb As StringBuilder : sb.Initialize
'	If TC(0) <> 0 Then
'		sb.Append($"${TC(0)} Days "$)
'	End If
'	If TC(1) <> 0 Then
'		sb.Append($"${TC(1)} Hrs "$)
'	End If
'	If TC(2) <> 0 Then
'		sb.Append($"${TC(2)} Mins "$)
'	End If
'	Return sb.ToString
'
'End Sub


Public Sub RoundJobPct(n As String) As String
	
	If IsNumber(n) Then
		Return Round2(n,1).As(String) & "%"
	Else
		Return "-"
	End If
	
End Sub

Public Sub RoundJobPctNoDecimals(n As String) As String
	
	If IsNumber(n) Then
		Return Round2(n,0).As(String) & "%"
	Else
		Return "-"
	End If
	
End Sub




public Sub WriteTxt2Disk(str As String,folder As String, filename As String) 'ignore
	
	'---- Simple, just write out a TXT file, use in debugging long JSON files
	'--- TODO  see File.OpenOutput
	
	Dim TextWriter1 As TextWriter
	TextWriter1.Initialize(File.OpenOutput( folder, filename, True))
	TextWriter1.WriteLine(str)
	TextWriter1.Close
	
End Sub


Public Sub CheckTempRange(what As String, value As Int) As Boolean
	
	If what = "bed" Then
		If value > 130 Then
			Return False			
		End If
	Else
		If value > 300 Then
			Return False
		End If
	End If
	
	Return True
	
End Sub







