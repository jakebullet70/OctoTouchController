B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/24/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgFilamentSetup"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mDlg As sadPreferencesDialog
	
	'-------------------------------------------------------------
	
	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	
	mainObj = mobj
	
End Sub

public Sub CreateDefaultFile
	

	If File.Exists(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE, _
						CreateMap(gblConst.filShow: "true", _
						 gblConst.filPauseBeforePark: "true", _
						 gblConst.filRetractBeforePark: "true", _
						 gblConst.filHomeBeforePark: "true", _
						 gblConst.filXPark: "0",gblConst.filYPark: "0", _
						 gblConst.filZLiftRel: "30", gblConst.filParkSpeed: "6000", _
						 gblConst.filUnloadLen:"500", gblConst.filUnloadSpeed:"1600", _
						 gblConst.filLoadLen:"50",gblConst.filLoadSpeed:"60"))
						 
	End If

End Sub

Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE)
	
	Dim h As Float
	If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
		h = 62%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		h = 55%y
	Else '--- 4 to 5.9 inch
		h = 80%y
	End If
	
	mDlg.Initialize(mainObj.root, "Filament Change Settings", 360dip, h)
	mDlg.LoadFromJson(File.ReadString(File.DirAssets,"dlgFilamentCtrl.json"))
	mDlg.SetEventsListener(Me,"dlgEvent")
	
	guiHelpers.ThemePrefDialogForm(mDlg)
	mDlg.PutAtTop = False
	Dim RS As ResumableSub = mDlg.ShowDialog(Data, "OK", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mDlg.Dialog)
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast("Filament Change Data Saved",1500)
		File.WriteMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE,Data)
		config.ReadFilamentChangeCFG
		CallSub(mainObj.oPageCurrent,"Set_focus")
	End If
	
End Sub


Private Sub dlgEvent_IsValid (TempData As Map) As Boolean 'ignore
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



Private Sub dlgEvent_BeforeDialogDisplayed (Template As Object)
	guiHelpers.pref_BeforeDialogDisplayed(mDlg,Template)
End Sub



