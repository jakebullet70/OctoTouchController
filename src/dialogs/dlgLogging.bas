B4J=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	July/6/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgLogging"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mLoggingDlg As sadPreferencesDialog
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(mobj As B4XMainPage)
	
	mainObj = mobj
	
End Sub

public Sub CreateDefaultFile
	
	If File.Exists(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE,CreateMap("fulllog": "false", "days": 2,"dbgtab": "false"))
	End If

End Sub

Public Sub Show
	
	CreateDefaultFile
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE)
	
	mLoggingDlg.Initialize(mainObj.root, "Logging", 360dip, 290dip)
	mLoggingDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgLogging.json"))
	mLoggingDlg.SetEventsListener(Me,"dlgLogging")
	'pdlgLogging.Dialog.OverlayColor = xui.Color_ARGB(128, 0, 10, 40)
	'pdlgLogging.Dialog.TitleBarHeight = 50dip
	
	Wait For (mLoggingDlg.ShowDialog(Data, "OK", "CANCEL")) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast("Logging Data Saved",1500)
		File.WriteMap(xui.DefaultFolder,gblConst.LOGGING_OPTIONS_FILE,Data)
		
''''		logMe.gDaysOfOldLogsBeforeDelete = Data.Get("days")  TODO
''''		'--- LogMe is a static mod, needs a delagate in B4A, fine in B4J
''''		'CallSubDelayed(mainObj,"Clean_OldLogs_Delagate") 
''''		logMe.Clean_OldLogs
	End If
	
	
End Sub


Private Sub dlgLogging_IsValid (TempData As Map) As Boolean 'ignore
	Return True '--- all is good!
	'--- NOT USED BUT HERE IF NEEDED
	
'	Try
'		Dim number As Int = TempData.GetDefault("days", 1)
'		If number < 1 Or number > 14 Then
'			guiHelpers.Show_toast("Days must be between 1 and 14",1200)
'			pdlgLogging.ScrollToItemWithError("days")
'			Return False
'		End If
'		Return True
'	Catch
'		Log(LastException)
'	End Try
'	Return False

End Sub



Private Sub dlgLogging_BeforeDialogDisplayed (Template As Object)
	'--- NOT USED BUT HERE IF NEEDED
	
'	Dim btnCancel As B4XView = PrefDialog1.Dialog.GetButton(xui.DialogResponse_Cancel)
'	btnCancel.Width = btnCancel.Width + 60dip
'	btnCancel.Left = btnCancel.Left - 60dip
'	btnCancel.TextColor = xui.Color_Red
'	Dim btnOk As B4XView = PrefDialog1.Dialog.GetButton(xui.DialogResponse_Positive)
'	If btnOk.IsInitialized Then
'		btnOk.Width = btnOk.Width + 20dip
'		btnOk.Left = btnCancel.Left - btnOk.Width
'	End If
End Sub



