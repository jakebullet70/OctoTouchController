B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'Class module: cl_appupdate
'Version: 1.30
'Author: UDG
'Last Modified: 07.08.2016
'Location: Di Gioia Consulting - Lugano (CH)
Private Sub Class_Globals
	'Status Codes
	Public ERR_NOPKG = -1	As Int				'missing package name
	Public ERR_NOTXT = -2 As Int				'missing webserver's info txt-type file full path
	Public ERR_NOAPK = -3 As Int				'missing webserver's new apk file full path
	Public ERR_TXTROW = -4 As Int				'wrong row format in txt file
	Public ERR_HTTP = -100 As Int				'HttpUtils error
	Public OK_INIT = 0 As Int
	Public OK_CURVER = 1 As Int					'curver has valid value
	Public OK_WEBVER = 2 As Int
	Public NO_NEWERAPK = 3 As Int				'apk version on webserver is the same as current one
	Public OK_NEWERAPK = 4 As Int				'current apk has a newer version ready to download on the webserver
	Public OK_DOWNLOAD = 5 As Int				'newer apk correctly downloaded from webserver
	Public OK_INSTALL = 6 As Int				'user asked to install newer apk
	
	'Private variables
	Private Callback As Object
	Private Event As String
	Private sPackageName As String      'ex: com.test.myapp
	Private sNewVerTxt As String        'ex: http://umbetest.web44.net/p_apk/myapp.txt
	Private sNewVerApk  As String       'ex: http://umbetest.web44.net/p_apk/myapp.apk
	Private sStatusCode As Int          'negatives denote errors; 0 = lib initialized; positives show current status
	Private sUserName As String         'user name for password protected folders on the server
	Private sUPassword As String        'password related to username above
	Private curver, webver As String    'curver=current version number; webver=version number read from the webserver
	Private webclog As String						'webclog = optional changelog data from webserver
	Private sVerbose As Boolean					'TRUE=a lot of logs
	Private bmSplash As Bitmap
	Private BitImage As BitmapDrawable
	Private pnl1 As Panel
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(CallbackModule As Object, EventName As String)
	Callback = CallbackModule
	Event = EventName
	sPackageName = ""
	sNewVerTxt = ""
	sNewVerApk = ""
	sUserName = ""
	sUPassword = ""
	sStatusCode = OK_INIT
	curver = ""
	webver = ""
	sVerbose=False
End Sub

'Sets package name for this app. It should equal the value in menu "Project.Package Name"
'Example: com.test.myapp
Public Sub setPackageName(PN As String)
	sPackageName = PN
End Sub

'Gets back the package name set for this app. Used internally.
Public Sub getPackageName As String
	Return sPackageName
End Sub

'Complete path to the .txt file having a single line of text formatted as
'ver=x.xx where x.xx corresponds to the newest web-published app's version 
Public Sub setNewVerTxt(NVT As String)
	sNewVerTxt = NVT
End Sub

'Complete path to the new apk for your app, available for download
Public Sub setNewVerApk(NVA As String)
	sNewVerApk = NVA
End Sub

'Sets Username and Password to use when downloading from a protected website folder
Public Sub setCredentials(UserN As String, UserP As String)
	sUserName = UserN
	sUPassword = UserP
End Sub

'Sets verbose mode on/off
Public Sub setVerbose(Verbose As Boolean)
	sVerbose = Verbose
	newinst2.svcVerbose = Verbose
End Sub

'Returns current internal status. Negatives denote ERRORS/WARNINGS.
Public Sub getStatus As Int
	Return sStatusCode
End Sub

'Optional sub - superimposes a simple splash screen on the calling Activity. 
'To remove the splash screen, call StopSplashScreen from Activity (generally in the callback function. See "Initialize")
'CallingAct - Activity object whose layout will be superimposed with BM in a panel
'BM - Bitmap object to be shown while apk checking is in progress
Public Sub SetAndStartSplashScreen(CallingAct As Activity, BM As Bitmap)
	bmSplash = BM
	If bmSplash.IsInitialized Then
		pnl1.Initialize("pnl1")
		BitImage.Initialize(bmSplash)
		BitImage.Gravity = Gravity.FILL
		CallingAct.AddView(pnl1, 0, 0, CallingAct.Width, CallingAct.Height)
		pnl1.Background = BitImage
		pnl1.BringToFront
	End If
End Sub

'Stops and removes the superimposed splash screen
Public Sub StopSplashScreen
	If bmSplash.IsInitialized Then pnl1.RemoveView
End Sub

'Returns current version number value (as a string)  
'Valid only after calling ReadCurVN
Public Sub getCurVN As String
	Return curver
End Sub

'Returns the version number value (as a string) as read from the .txt file on the webserver. 
'Valid only after calling ReadWebVN
Public Sub getWebVN As String
	Return webver
End Sub

'Returns optional change log data (as a string) as read from the .txt file on the webserver  
'Valid only after calling ReadWebVN
Public Sub getWebChangeLog As String
	Return webclog
End Sub

'Reads current version number from running copy of apk (see #VersionName).
'Valid if StatusCode = OK_CURVER
Public Sub ReadCurVN
	
	Log("---- AppUpdating.ReadCurVN")
	'check whether PackageName was declared
	If sPackageName = "" Then
		sStatusCode = ERR_NOPKG
		If sVerbose Then Log(TAB & "missing package name for current version check")
		curver = ""
	Else
		Dim pm As PackageManager
		curver = pm.GetVersionName(sPackageName)
		sStatusCode = OK_CURVER 				'got current version from Project Attributes
		If sVerbose Then Log(TAB & "Current Version: " & curver)
	End If
	Finito
End Sub

'Reads version number as published in the .txt file on webserver
'Valid if StatusCode = OK_WEBVER
Public Sub ReadWebVN
	Log("---- AppUpdating.ReadWebVN")
	' check whether NewVerTxt file was declared
	If sNewVerTxt = "" Then
		sStatusCode = ERR_NOTXT
		If sVerbose Then Log(TAB & "missing txt file full path indication")
		webver = ""
		Finito
		Return
	End If
	Dim job1 As HttpJob
	'Send a GET request
	job1.Initialize("JobWebVNonly", Me)
	job1.Username = sUserName
	job1.Password = sUPassword
	job1.Download(sNewVerTxt)
End Sub

'Downloads newer apk from webserver
Public Sub DownloadApk

	Log("---- AppUpdating.DownloadApk")
	'check whether NewVerApk was declared
	If sNewVerApk = "" Then
		sStatusCode = ERR_NOAPK
		If sVerbose Then Log(TAB & "missing apk file full path indication")
		Finito
		Return
	End If
	Dim jobapk As HttpJob
	jobapk.Initialize("JobApkDownload", Me)
	jobapk.Username = sUserName
	jobapk.Password = sUPassword
	jobapk.Download(sNewVerApk) 'ex: jobapk.Download("http://umbetest.web44.net/p_apk/myapp.apk")
End Sub

'Installs an already downloaded apk
Public Sub InstallApk
	Log("---- AppUpdating.InstallApk")
	'intent to install
	Dim i As Intent
	i.Initialize(i.ACTION_VIEW, "file://" & File.Combine(File.DirDefaultExternal, "tmp.apk"))
	i.SetType("application/vnd.android.package-archive")
	StartActivity(i)
	sStatusCode = OK_INSTALL
	If sVerbose Then Log(TAB & "user asked to install newer apk")
	Finito
End Sub

'Check on website for a newer apk version and (if any exists) downloads it.
'We don't know if the user will then install it..
Public Sub UpdateApk
	
	
	Log("---- AppUpdating.UpdateApk")
	'check whether PackageName was declared
	
	If sPackageName = "" Then
		sStatusCode = ERR_NOPKG
		If sVerbose Then Log(TAB & "missing package name for current version check")
		curver = ""
		Finito
		Return
	End If
	Dim pm As PackageManager
	curver = pm.GetVersionName(sPackageName)   	'curver = pm.GetVersionName("com.test.myapp")
	sStatusCode = OK_CURVER                    	'read current version from package name
	If sVerbose Then Log(TAB & "Current Version: " & curver)
	'check whether NewVerTxt file was declared
	If sNewVerTxt = "" Then
		sStatusCode = ERR_NOTXT
		If sVerbose Then Log(TAB & "missing txt file full path indication")
		webver = ""
		Finito
		Return
	End If
	Dim job3 As HttpJob
	'Send a GET request
	job3.Initialize("JobWebVNcompare", Me)
	job3.Username = sUserName
	job3.Password = sUPassword
	job3.Download(sNewVerTxt) 									'ex: job3.Download("http://umbetest.web44.net/p_apk/myapp.txt")
End Sub

'Downloads newer apk and asks user to install it
Private Sub ApkUpdate
	Log(TAB & "-- ApkUpdate")
	'check whether NewVerApk was declared
	If sNewVerApk = "" Then
		sStatusCode = ERR_NOAPK
		If sVerbose Then Log(TAB & "missing apk file full path indication")
		Finito
		Return
	End If
	Dim jobapk As HttpJob
	jobapk.Initialize("JobApkUpdate", Me)
	jobapk.Username = sUserName
	jobapk.Password = sUPassword
	jobapk.Download(sNewVerApk) 'ex: jobapk.Download("http://umbetest.web44.net/p_apk/myapp.apk")
End Sub

' extract version number from the single row in sNewVerTxt text file
' expected row format: ver=x.xx where "ver" could be any term and x.xx is then version number
' Attn: no spaces allowed between equal sign and version number
Private Sub ExtractVN(TxtRow As String) As String
	Dim i As Int
	i=TxtRow.IndexOf("=")
	If i <> -1 Then
		Dim j As Int
		Dim s  As String
		j=TxtRow.IndexOf("<ChangeLog>")
		If j <> - 1 Then s=TxtRow.SubString2(i+1,j) Else s=TxtRow.SubString(i+1)
		s=s.Replace(CRLF,"")
		Return s
	Else
		Return ""
	End If
End Sub

'extract change log data from the sNewverTxt text file
'Info must be placed between <ChangeLog> and </ChangeLog> markers
Private Sub ExtractCL(TxtRow As String) As String
	Dim i As Int
	i=TxtRow.IndexOf("<ChangeLog>")
	If i <> -1 Then
		Dim j As Int
		j=TxtRow.IndexOf("</ChangeLog>")
		If j <> -1 Then Return TxtRow.SubString2(i+11,j) Else Return TxtRow.SubString(i+11)
	Else
		Return ""
	End If
End Sub

Private Sub JobDone (Job As HttpJob)
	Log("---- AppUpdating.JobDone --")
	If sVerbose Then Log(TAB & "JobName = " & Job.JobName & ", Success = " & Job.Success)
	If Job.Success = True Then
		Select Job.JobName
			Case "JobWebVNonly"
				If sVerbose Then Log(TAB & "Read while in JobWebVNonly: " & Job.GetString)
				webver=ExtractVN(Job.GetString)   'Job.GetString.SubString(4)
				webclog=ExtractCL(Job.GetString)  'optional changelog data
				If webver = "" Then
					sStatusCode = ERR_TXTROW
				Else
					sStatusCode = OK_WEBVER					'read apk's version number as published on webserver
					If sVerbose Then Log(TAB & "Web version number: " & webver)
				End If
				Finito
			Case "JobApkDownload"
				Log(TAB & "-- JobApkDownload")
				'copy from external to storage card
		
				
				Dim out As OutputStream
				out = File.OpenOutput(File.DirDefaultExternal,"tmp.apk",False)
				File.Copy2(Job.GetInputStream, out)
				out.Close
				
				sStatusCode = OK_DOWNLOAD
				If sVerbose Then Log(TAB & "new apk version downloaded and ready to install")
				Finito
			Case "JobWebVNcompare"
				Log(TAB & "-- JoWebVNcompare")
				If sVerbose Then Log(TAB & "Read while in webVNcompare: " & Job.GetString)
				webver=ExtractVN(Job.GetString)   'Job.GetString.SubString(4)
				webclog=ExtractCL(Job.GetString)  'optional changelog data
				If webver = "" Then
					sStatusCode = ERR_TXTROW
					Finito
				Else
					sStatusCode = OK_WEBVER					'read apk's version number as published on webserver
					If sVerbose Then Log(TAB & "Web version number: " & webver)
				End If
				If curver < webver Then
					sStatusCode = OK_NEWERAPK				'newer apk version available on webserver
					If sVerbose Then Log(TAB & "Newer version available. Now I try its downloading")
					ApkUpdate												'download and install
				Else
					sStatusCode = NO_NEWERAPK
					If sVerbose Then Log(TAB & "No newer version available on webserver.")
					Finito
				End If
				
			Case "JobApkUpdate"
				Log(TAB & "-- JobApkUpdate")
				
				Try
					'copy from external to storage card
					Dim out As OutputStream
				
					'*****Old Code
					'out = File.OpenOutput(File.DirDefaultExternal,"tmp.apk",False)
					'**************

					'****** New code
					out = File.OpenOutput(Starter.Provider.SharedFolder,"tmp.apk",False)
					'**************

					File.Copy2(Job.GetInputStream, out)
					out.Close
					sStatusCode = OK_DOWNLOAD
					If sVerbose Then Log(TAB & "new apk version downloaded and ready to install")

				Catch
					Msgbox(LastException,"copy fichier")
				End Try


				'*****Old Code
				'intent to install
				'				Dim i As Intent
				'				i.Initialize(i.ACTION_VIEW, "file://" & File.Combine(File.DirDefaultExternal, "tmp.apk"))
				'				i.SetType("application/vnd.android.package-archive")
				'				StartActivity(i)
				'**************

				'****** New code
				
				Wait For (CheckInstallationRequirements) Complete (Result As Boolean)
				If Result Then
					SendInstallIntent
				End If
				'**************
				
				sStatusCode = OK_INSTALL
				If sVerbose Then 
					Log(TAB & "user asked to install new apk")
				End If
				Finito
				
		End Select
	Else
		Log(TAB & "Error: " & Job.ErrorMessage)
		sStatusCode = ERR_HTTP
		If sVerbose Then Log(TAB & "error in httputils2")
		ToastMessageShow("Error: " & Job.ErrorMessage, True)
		Finito
	End If
	Job.Release
End Sub

Private Sub CheckInstallationRequirements As ResumableSub
	
	Dim Phone As Phone
		If File.ExternalWritable = False Then
		MsgboxAsync("Storage card not available. Make sure that your device is not connected in USB storage mode.", "")
		Return False
	Else If Phone.SdkVersion >= 26 And CanRequestPackageInstalls = False Then
		MsgboxAsync("Please allow me to install applications.", "")
		Wait For Msgbox_Result(Result As Int)
		Dim in As Intent
		in.Initialize("android.settings.MANAGE_UNKNOWN_APP_SOURCES", "package:" & Application.PackageName)
		StartActivity(in)
		Wait For Activity_Resume '<-- wait for Activity_Resume
		Return CanRequestPackageInstalls
	Else If CheckNonMarketAppsEnabled = False Then
		MsgboxAsync("Please enable installation of non-market applications." & CRLF & "Under Settings - Security - Unknown sources" _
			 & CRLF & "Or Settings - Applications - Unknown sources", "")
		Return False
	Else
		Return True
	End If
End Sub

Public Sub CanRequestPackageInstalls As Boolean
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim PackageManager As JavaObject = ctxt.RunMethod("getPackageManager", Null)
	Return  PackageManager.RunMethod("canRequestPackageInstalls", Null)
End Sub

Public Sub CheckNonMarketAppsEnabled As Boolean

	Dim Phone As Phone
	If Phone.sdkversion >= 26 Then Return True
	If Phone.sdkversion < 17 Or Phone.SdkVersion >= 21 Then
		Return Phone.GetSettings("install_non_market_apps") = "1"
	Else
		Dim context As JavaObject
		context.InitializeContext
		Dim resolver As JavaObject = context.RunMethod("getContentResolver", Null)
		Dim global As JavaObject
		global.InitializeStatic("android.provider.Settings.Global")
		Return global.RunMethod("getString", Array(resolver, "install_non_market_apps")) = "1"
	End If
	
End Sub

Private Sub SendInstallIntent

	Dim Phone As Phone
	Dim ApkName As String = "tmp.apk"

	Dim i As Intent
	If Phone.SdkVersion >= 24 Then
		i.Initialize("android.intent.action.INSTALL_PACKAGE", CreateFileProviderUri(Starter.Provider.SharedFolder, ApkName))
		i.Flags = Bit.Or(i.Flags, 1) 'FLAG_GRANT_READ_URI_PERMISSION
	Else
		i.Initialize(i.ACTION_VIEW, "file://" & File.Combine(Starter.Provider.SharedFolder, ApkName))
		i.SetType("application/vnd.android.package-archive")
	End If
	StartActivity(i)
	
End Sub

Sub CreateFileProviderUri (Dir As String, FileName As String) As Object

	Dim FileProvider1 As JavaObject
	Dim context As JavaObject
	context.InitializeContext
	FileProvider1.InitializeStatic("android.support.v4.content.FileProvider")
	Dim f As JavaObject
	f.InitializeNewInstance("java.io.File", Array(Dir, FileName))
	Return  FileProvider1.RunMethod("getUriForFile", Array(context, Application.PackageName & ".provider", f))

End Sub


'Action requested is over; it calls the callback function, if any exists
Private Sub Finito
	If SubExists(Callback,Event&"_UpdateComplete") Then
		CallSub(Callback,Event&"_UpdateComplete")
	End If
End Sub

'1) Holding the current version number in simple text file on your web server
'2) Download this file with HttpUtils.Download
'3) Read contents with HttpUtils.GetString
'4) Check against installed version
'5) If installed < current Then
'6) Download new 'apk' file with HttpUtils.Download
'7) Install
