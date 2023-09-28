B4A=true
Group=MISC_CLASSES
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
' ###############################################
' (C) TechDoc G. Becker - http://gbecker.de
' ###############################################
' Custom View:    BeeperDeLuxe
' Language:        B4A
' Designer:        No
' Version:        1/2020
' Used Libs:    Audio, Core, fiddlearound
'                Phone,XUI
' ###############################################
' Usage is Roayalty free for Private and commercial
' use only for B4X-Anywhere Board Members.
' ###############################################
Sub Class_Globals
    Dim tiD,tiI As Timer
End Sub

Public Sub Initialize
End Sub

Public Sub Beeps(DurationMS As Long,FreqHZ As Long, Times As Int)
	Dim b As Beeper
	b.Initialize(DurationMS, FreqHZ) '--- sample - 300 milliseconds, 500 hz
	For x = 1 To Times
		b.Beep
		Beep(DurationMS,FreqHZ)
		Sleep(200)
	Next
End Sub


Public Sub Beep(DurationMS As Long,FreqHz As Long)
    Dim b As Beeper
    b.Initialize(DurationMS, FreqHz) '--- sample - 300 milliseconds, 500 hz
    b.Beep
End Sub


'--- Not needed in this program
'============================================================
'Public Sub Vibrate(DurationMilliseconds As Long)
'    If DurationMilliseconds <> 90 Then
'        Dim p As PhoneVibrate
'        p.Vibrate(DurationMilliseconds)
'    End If
'End Sub

'Public Sub beepAndVibrate(DurationMilliseconds As Long)
'    beep(DurationMilliseconds)
'    Vibrate(DurationMilliseconds)
'End Sub
'============================================================



'============================================================
Public Sub Alarm(DurationMilliseconds As Long)
    tiD.Initialize("tiD",DurationMilliseconds)
    tiI.Initialize("tiI",250)
    tiD.Enabled=True
    tiI.Enabled=True
End Sub

Private Sub tiD_tick
    tiI.enabled=False
    tiD.Enabled=False
End Sub

Private Sub tiI_tick
    Beep(250,500)
End Sub
'============================================================