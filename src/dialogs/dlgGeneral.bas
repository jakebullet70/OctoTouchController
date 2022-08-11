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
	
	Private const mModule As String = "dlgGeneral"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mGeneralDlg As PreferencesDialog
	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	
	mainObj = mobj
	
End Sub

public Sub CreateDefaultFile

'	If File.Exists(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE) = False Then
'		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE, _
'						CreateMap("TakePwr": "false", "NotPrintingScrnOff": "false","NotPrintingMinTill":30, _
'												"PrintingScrnOff": "false","PrintingMinTill":5))
'	End If

End Sub

Public Sub Show
	
	CreateDefaultFile
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.POWER_OPTIONS_FILE)
	
	mGeneralDlg.Initialize(mainObj.root, "General Option", 360dip, mainObj.Root.Height - 50dip)
	mGeneralDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgGeneral.json"))
	mGeneralDlg.SetEventsListener(Me,"dlgGeneral")
	'm_dlgGeneral.Dialog.OverlayColor = xui.Color_ARGB(128, 0, 10, 40)
	'm_dlgGeneral.Dialog.TitleBarHeight = 50dip
	
	Wait For (mGeneralDlg.ShowDialog(Data, "OK", "CANCEL")) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast("General Data Saved",1500)
		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,Data)
	End If
	
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



