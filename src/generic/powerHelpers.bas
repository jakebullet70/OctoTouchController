B4J=true
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
End Sub


Public Sub ScreenON(takeOverPower As Boolean)
	
	pws.ReleasePartialLock
	pws.ReleaseKeepAlive
	If takeOverPower Then 
		pws.KeepAlive(True)
	End If
	
End Sub


Public Sub ScreenOff
	
	pws.ReleaseKeepAlive
	pws.PartialLock
	ActionBar_Off
	
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







