﻿B4J=true
Group=HELPERS
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/15/2022
#End Region
'Static code module

'--- Generic code to turn on / off CPU - Screen
'--- Generic code to turn on / off CPU - Screen
'--- Generic code to turn on / off CPU - Screen

Sub Process_Globals
	Private Const mModule As String = "powerHelpers" 'ignore
	
	Public pws As PhoneWakeState
	Public ph As Phone
	
	Private screenBrightness As Float 'ignore
	Private const AUTO_BRIGHTNESS As Float = -1
	
End Sub


Public Sub Init
	SetScreenBrightness(0.5)
	screenBrightness = GetScreenBrightness
End Sub


Public Sub ScreenON(takeOverPower As Boolean)
	
	pws.ReleasePartialLock
	pws.ReleaseKeepAlive
	If takeOverPower Then 
		screenBrightness = GetScreenBrightness
		If logMe.logPOWER_EVENTS Then Log("pws.KeepAlive(True)")
		pws.KeepAlive(True)
	Else
		If logMe.logPOWER_EVENTS Then Log("KeepAlive - OFF")
	End If
	
'	If screenBrightness <> AUTO_BRIGHTNESS Then
'		SetScreenBrightness(screenBrightness)
'	End If
	
End Sub


Public Sub ScreenOff
	
	screenBrightness = GetScreenBrightness
	pws.ReleaseKeepAlive
	pws.PartialLock
	SetScreenBrightness(0)
	
End Sub


Public Sub ActionBar_Off
	'--- needs the activity obj so its in main - TODO
	If ph.SdkVersion >= 14 And ph.SdkVersion < 21 Then
		CallSub2(Main,"Dim_ActionBar",1)
	Else
		
	End If
End Sub

Public Sub ActionBar_On
	'--- needs the activity obj so its in main - TODO
	If ph.SdkVersion >= 14 And ph.SdkVersion < 21 Then
		CallSub2(Main,"Dim_ActionBar",0)
	Else
		
	End If
End Sub

Public Sub SetScreenBrightness(value As Float)
	Try
		If screenBrightness = AUTO_BRIGHTNESS Then
			If logMe.logPOWER_EVENTS Then Log("cannot set brightness, brightness is in automode")
			Return
		End If
		ph.SetScreenBrightness(value)
	Catch
		Log(LastException)
	End Try 'ignore
End Sub

' 0 to 1 so 0.7 is 70%
Public Sub GetScreenBrightness() As Float
	'--- returns -1 if set to auto
	' https://www.b4x.com/android/forum/threads/get-set-brightness.107899/#content
	' https://www.b4x.com/android/forum/threads/setscreenbrightness-not-working.31606/
	Dim ref As Reflector
    ref.Target = ref.GetActivity
    ref.Target = ref.RunMethod("getWindow")
    ref.Target = ref.RunMethod("getAttributes")
    Dim brightness As Float = ref.GetField("screenBrightness")
	If logMe.logPOWER_EVENTS Then Log("screen brightness: " & brightness)
	Return brightness
End Sub

'----------------------------------------------------------------------------------------
'----------------------------------------------------------------------------------------

'Private Sub ScreenFullOn
'	
'	Try
'		
'		Log("Public Sub ScreenFullOn")
'		If IsPaused(Main) Then StartActivity(Main)
'		Dim n As Float = 1.0
'		ph.SetScreenBrightness(n)
'		
'	Catch
'		Log("ScreenFullOn - " & LastException)
'	End Try
'	
'End Sub

'Public Sub DimTheScrnBySettingBrightness
'	Log("Public Sub DimTheScrnBySettingBrightness")
'	Dim f As Float = c.SCRN_DIM_PCT1
'	ph.SetScreenBrightness(f)
'End Sub




'Public Sub RemoveScreenPanel
'	If mScreenOff.IsInitialized = True Then
'		mScreenOff.SendToBack
'		mScreenOff.Visible=False '--- this is the WHOLE PANEL covering the screen
'	End If
'End Sub

'Public Sub TurnScreen_On
'	Try
'			
'		g.LogWrite("TurnScreen_On",g.ID_LOG_MSG)
'		RemoveScreenPanel
'		g.ScreenFullOn '--- calls the phone intent
'		CallSubDelayed(svrMain,"ResetScrn_SleepCounter")
'		
'		'--- if pframe then un-pause the pframe timer
'		If snapIn_PFrame.IsInitialized Then
'			If gCurrentPage = c.SNAPIN_MENU_PFRAME_NDX Then
'				snapIn_PFrame.tmrNextPic.Enabled = True
'			End If
'		End If
'		
'	Catch
'		g.LogException2(LastException,True,"TurnScreen_On")
'	End Try
'	
'End Sub

'Public Sub TurnScreen_Off
'
'	'--- turn scrn off
'	If Not (c.IS0SCREEN0OFF) Then g.LogWrite("TurnScreen_Off",g.ID_LOG_MSG)
'	g.DimTheScrnBySettingBrightness '--- calls the phone intent, make sure the scrn is dim'd
'	mScreenOff.Color=Colors.ARGB(255,0,0,0) '--- scrn is black
'	mScreenOff.BringToFront
'	mScreenOff.Visible = True
'	
'	'--- if pframe then pause the pframe timer
'	If snapIn_PFrame.IsInitialized Then
'		If gCurrentPage = c.SNAPIN_MENU_PFRAME_NDX Then
'			snapIn_PFrame.tmrNextPic.Enabled = False
'		End If
'	End If
'	
'	ICSscreen_Off
'
'End Sub

'Private Sub pnlScrnOff_Click
'	If g.WeatherData.IsInitialize Then
'		g.WeatherData.TryUpdate
'	End If
'	TurnScreen_On
'End Sub
'Public Sub TurnScreen_Dim
'	g.DimTheScrnBySettingBrightness '--- calls the phone intent
'	mScreenOff.Color = g.PanelBgColor
'	mScreenOff.BringToFront
'	mScreenOff.Visible = True
'End Sub

'Public Sub EnableDisableScreen(disable As Boolean)
'	'--- called for popups to freeze the background screen
'	If disable Then
'		mScreenBackGrnd.Visible = True
'		mScreenBackGrnd.BringToFront
'	Else
'		mScreenBackGrnd.SendToBack
'		mScreenBackGrnd.Visible = False
'	End If
'End Sub







