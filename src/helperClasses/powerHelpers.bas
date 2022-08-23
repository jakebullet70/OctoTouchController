B4J=true
Group=HELPER_CLASSES
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/15/2022
#End Region
'Static code module

'--- Code to turn on / off CPU - Screen - brightness
'--- Code to turn on / off CPU - Screen - brightness
'--- Code to turn on / off CPU - Screen - brightness

Sub Process_Globals
	Private Const mModule As String = "powerHelpers" 'ignore
	Private xui As XUI
	
	Private pws As PhoneWakeState
	Private ph As Phone
	
	Public pScreenBrightness As Float = -1
	Private Const AUTO_BRIGHTNESS As Float = -1
	Private Const SCREEN_BRIGHTNESS_FILE As String = "scrn_brightness.lst"
	
End Sub

Public Sub Init(takeOverPower As Boolean)
	
	
	'TODO  brightness needs to be seperated from takeoverpower
	If config.ChangeBrightnessSettingsFLAG = False Then Return
	
	If takeOverPower = False Then Return
	
	If LoadBrightnesFromfile = False Then
		pScreenBrightness = GetScreenBrightness
		If pScreenBrightness = AUTO_BRIGHTNESS Then
			pScreenBrightness = 0.5
			SetScreenBrightnessAndSave(pScreenBrightness,True)
			Return
		End If
	End If
	SetScreenBrightnessAndSave(pScreenBrightness,False)
	
End Sub


Public Sub ScreenON(takeOverPower As Boolean)
	
	ReleaseLocks
	
	If takeOverPower Then 
		If config.logPOWER_EVENTS Then Log("KeepAlive - ON")
		pws.KeepAlive(True)
	Else
		If config.logPOWER_EVENTS Then Log("KeepAlive - OFF")
	End If
	
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_ON) 
	
End Sub


Public Sub ScreenOff
	
	pws.ReleaseKeepAlive
	pws.PartialLock
	ph.SetScreenBrightness(0)
	
End Sub

Public Sub ReleaseLocks
	pws.ReleasePartialLock
	pws.ReleaseKeepAlive
End Sub


'Public Sub ActionBar_Off
'	'--- needs the activity obj so its in main 
'	If ph.SdkVersion >= 14 And ph.SdkVersion < 20 Then
'		CallSub2(Main,"Dim_ActionBar",1)
'	End If
'End Sub
'
'Public Sub ActionBar_On
'	'--- needs the activity obj so its in main 
'	If ph.SdkVersion >= 14 And ph.SdkVersion < 20 Then
'		CallSub2(Main,"Dim_ActionBar",0)
'	End If
'End Sub


'=================================================================================
'=================================================================================


' 0 to 1 - so 0.5 is valid
Public Sub SetScreenBrightnessAndSave(value As Float, Save2File As Boolean)
	
	If config.ChangeBrightnessSettingsFLAG = False Then Return
	
	Try
		If pScreenBrightness = AUTO_BRIGHTNESS Then
			If config.logPOWER_EVENTS Then Log("cannot set brightness, brightness is in automode")
			Return
		End If
		If config.logPOWER_EVENTS Then Log("setting brightness to: " & value)
		ph.SetScreenBrightness(value)
		If Save2File Then 
			fileHelpers.Write_SingleValue(SCREEN_BRIGHTNESS_FILE,value.As(String))
		End If
		
	Catch
		logMe.LogIt2(LastException,mModule,"SetScreenBrightnessAndSave")
	End Try 
	
End Sub

Public Sub SetScreenBrightness2
	
	If config.ChangeBrightnessSettingsFLAG = False Then Return
	SetScreenBrightnessAndSave(pScreenBrightness,False)
	
End Sub


Private Sub LoadBrightnesFromfile() As Boolean
	
	Dim v As String = fileHelpers.Read_ReturnSingleValue(SCREEN_BRIGHTNESS_FILE)
	If v = "" Then Return False
	pScreenBrightness = v.As(Float)
	Return True
	
End Sub


' 0 to 1  - so 0.5 is valid
Public Sub GetScreenBrightness() As Float
	'--- returns -1 if set to auto
	' https://www.b4x.com/android/forum/threads/get-set-brightness.107899/#content
	' https://www.b4x.com/android/forum/threads/setscreenbrightness-not-working.31606/
	Dim ref As Reflector
    ref.Target = ref.GetActivity
    ref.Target = ref.RunMethod("getWindow")
    ref.Target = ref.RunMethod("getAttributes")
    Dim brightness As Float = ref.GetField("screenBrightness")
	If config.logPOWER_EVENTS Then Log("screen brightness is: " & brightness)
	Return brightness
End Sub



'Public Sub SetBrightnessToNormalMode
'	'--- NEEDS TESTING, SEE BELOW
'	'  https://www.b4x.com/android/forum/threads/permission-write_settings.94311/#post-597465
'	Dim jo As JavaObject
'	jo.InitializeContext
'	Dim System As JavaObject
'	System.InitializeStatic("android.provider.Settings.System")
'	System.RunMethod("putInt", Array( _
'       jo.RunMethod("getContentResolver", Null), _
'       System.GetField("SCREEN_BRIGHTNESS_MODE"), _
'       System.GetField("SCREEN_BRIGHTNESS_MODE_MANUAL")))
'End Sub

