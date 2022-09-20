B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	July/9/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgPowerOptions"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mPowerDlg As sadPreferencesDialog
	
End Sub


Public Sub Initialize(mobj As B4XMainPage)
	mainObj = mobj
End Sub


public Sub CreateDefaultFile

	If File.Exists(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE, _
						CreateMap("TakePwr": "true", "NotPrintingScrnOff": "true","NotPrintingMinTill":90, _
												"PrintingScrnOff": "false","PrintingMinTill":20))
	End If

End Sub


Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE)

	Dim h As Float
	If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
		h = 55%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		h = 42%y
	Else '--- 4 to 5.9 inch
		h = 80%y
	End If
	
	mPowerDlg.Initialize(mainObj.root, "Power Option", 360dip, h)
	mPowerDlg.Clear
	mPowerDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgPower.json"))
	mPowerDlg.SetEventsListener(Me,"dlgPower")

	guiHelpers.ThemePrefDialogForm(mPowerDlg)
	mPowerDlg.PutAtTop = False
	Dim RS As ResumableSub = mPowerDlg.ShowDialog(Data, "OK", "Cancel")
	guiHelpers.ThemeInputDialogBtnsResize(mPowerDlg.Dialog)
	Sleep(0)
		
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		
		guiHelpers.Show_toast("Power Data Saved",1500)
		File.WriteMap(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE,Data)
		config.ReadPowerCFG
		fnc.ProcessPowerFlags
		
	End If
	
End Sub


Private Sub dlgPower_IsValid (TempData As Map) As Boolean 'ignore
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


Private Sub dlgPower_BeforeDialogDisplayed (Template As Object)

	'--- NOT USED BUT HERE IF NEEDED
	
'	Dim pref As PreferencesDialog = Template
'	Dim dlg As B4XDialog = pref.Dialog
'	dlg.PutAtTop = False
'	mPowerDlg.Dialog.BackgroundColor = xui.Color_Cyan
'	mPowerDlg.Dialog.PutAtTop = False
'	Log(mPowerDlg.Dialog.PutAtTop)
'	Sleep(50)
	
	'mPowerDlg.CustomListView1.sv.Height = mPowerDlg.CustomListView1.sv.ScrollViewInnerPanel.Height + 10dip
	'mPowerDlg.CustomListView1.GetPanel(0).GetView(0).Color = xui.Color_Transparent
	'mPowerDlg.CustomListView1.sv.ScrollViewInnerPanel.Color = xui.Color_Transparent
	
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



