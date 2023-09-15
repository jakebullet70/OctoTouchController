B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/5/2023
' ----------------------------------------------
' inspired / copied / stolen / borrowed from...
' https://github.com/jneilliii/OctoPrint-BLTouch
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgBLTouchSetup"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mBlCrTouch As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper
	
End Sub

Public Sub Initialize() As Object
	
	mainObj = B4XPages.MainPage
	Return Me
	
End Sub

Public Sub Close_Me
	mBlCrTouch.Dialog.Close(xui.DialogResponse_Cancel)
End Sub

public Sub CreateDefaultFile
	
	If File.Exists(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE,  _
						CreateMap( gblConst.probeShow: "false", gblConst.probeBed: "G28" & CRLF & "M420 S0" & "G29 T", _
						  gblConst.probeDN : "M280 P0 S10", gblConst.probeRelAlarm: "M280 P0 S160", _
						  gblConst.probeSave: "M500",gblConst.probeTest: "M280 P0 S120",  _
						  gblConst.probeUP: "M280 S0 S90"))					 
	End If
End Sub


Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE)
	
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
	
	mBlCrTouch.Initialize(mainObj.root, "BL/CR Touch Settings", w, h)
	mBlCrTouch.LoadFromJson(File.ReadString(File.DirAssets, "dlgbltouch.json"))
	mBlCrTouch.SetEventsListener(Me,"dlgGeneral")
	
	
	prefHelper.Initialize(mBlCrTouch)
	prefHelper.ThemePrefDialogForm
	mBlCrTouch.PutAtTop = False
	Dim RS As ResumableSub = mBlCrTouch.ShowDialog(Data, "OK", "CANCEL")
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast(gblConst.DATA_SAVED,1500)
		File.WriteMap(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE,Data)
		CallSub(mainObj.oPageCurrent,"Set_focus")
	End If
	
	
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	mainObj.pObjCurrentDlg2 = Null
	
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


