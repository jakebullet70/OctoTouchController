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
	Private prefHelper As sadPreferencesDialogHelper
	
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

	Dim h,w As Float
	If guiHelpers.gIsLandScape Then
		If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
			h = 55%y
		Else If guiHelpers.gScreenSizeAprox >= 8 Then
			h = 42%y
		Else '--- 4 to 5.9 inch
			h = 80%y
		End If	
		w = 360dip
	Else
		h = 330dip	
		w = guiHelpers.gWidth * .92
	End If
	
	mPowerDlg.Initialize(mainObj.root, "Android Power Settings", w, h)
	prefHelper.Initialize(mPowerDlg)
	mPowerDlg.Clear
	mPowerDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgPower.json"))
	mPowerDlg.SetEventsListener(Me,"dlgPower")

	prefHelper.ThemePrefDialogForm
	mPowerDlg.PutAtTop = False
	Dim RS As ResumableSub = mPowerDlg.ShowDialog(Data, "OK", "CANCEL")
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
		
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		
		guiHelpers.Show_toast("Power Data Saved",1500)
		File.WriteMap(xui.DefaultFolder,gblConst.ANDROID_POWER_OPTIONS_FILE,Data)
		config.ReadPowerCFG
		fnc.ProcessPowerFlags
		
	End If
	
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
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
	prefHelper.SkinDialog(Template)
End Sub



