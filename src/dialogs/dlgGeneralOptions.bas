B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/11/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgGeneralOptions"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mGeneralDlg As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper
	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	
	mainObj = mobj
	
End Sub

public Sub CreateDefaultFile
	
	If File.Exists(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE, _
						CreateMap( "chgBrightness": "true", "scrnoff": "true", "logall": "false", _
						 	"logpwr": "false",  "logfiles": "false", "logoctokey": "false", "logrest": "false","syscmds": "false", _
							"axesx": "false",  "axesy": "false", "axesz": "false"))					 
	End If
End Sub


Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
	Dim h,w As Float '--- TODO - needs refactor
	If guiHelpers.gIsLandScape Then
		If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
			h = 62%y
		Else If guiHelpers.gScreenSizeAprox >= 8 Then
			h = 55%y
		Else '--- 4 to 5.9 inch
			h = 80%y
		End If
		w = 360dip
	Else
		h = 440dip
		w = guiHelpers.gWidth * .92
	End If
	
	mGeneralDlg.Initialize(mainObj.root, "General Settings", w, h)
	mGeneralDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgGeneral.json"))
	mGeneralDlg.SetEventsListener(Me,"dlgGeneral")
	
	
	prefHelper.Initialize(mGeneralDlg)
	prefHelper.ThemePrefDialogForm
	mGeneralDlg.PutAtTop = False
	Dim RS As ResumableSub = mGeneralDlg.ShowDialog(Data, "OK", "CANCEL")
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast("General Data Saved",1500)
		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,Data)
		config.ReadGeneralCFG
		CallSub(mainObj.oPageCurrent,"Set_focus")
	End If
	
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
End Sub


Private Sub dlgGeneral_IsValid (TempData As Map) As Boolean 'ignore
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



Private Sub dlgGeneral_BeforeDialogDisplayed (Template As Object)
	prefHelper.SkinDialog(Template)
End Sub



