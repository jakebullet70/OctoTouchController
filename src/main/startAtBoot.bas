B4A=true
Group=MAIN
ModulesStructureVersion=1
Type=Service
Version=11.8
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: True	
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	'---
	Private AutoStartBeenChecked As Boolean = False
	Private xui As XUI
End Sub


' for newer version of Android. v12+
' SEE ---> https://www.b4x.com/android/forum/threads/receivers-and-services-in-2023.145370/#content
' SEE ---> https://www.b4x.com/android/forum/threads/problem-using-start-at-boot-with-android-10.16

Sub Service_Create
End Sub

Sub Service_Start (StartingIntent As Intent)
	Log("Service_Start - startAtBoot")
	If AutoStartBeenChecked = False Then
		AutoStartBeenChecked = True
		If ( File.Exists(xui.DefaultFolder,"autostart.bin") ) Then
			StartApp
		End If
	End If
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
	StopService(Me) '--- above line replaces this
End Sub

Sub Service_Destroy
End Sub


Private Sub StartApp()
	Dim Intent1 As Intent
	Dim pm As PackageManager
	#if klipper
	Intent1 = pm.GetApplicationIntent("sadLogic.KlipperTouchController")
	#else
	Intent1 = pm.GetApplicationIntent("sadLogic.OctoTouchController")
	#End If
	StartActivity(Intent1)
End Sub
