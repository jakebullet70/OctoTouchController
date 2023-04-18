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
	Private mPrefDlg As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper
	Private lblAboutLoadUnload As  Label
	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	
	mainObj = mobj
	
End Sub

public Sub CreateDefaultFile
	

	If File.Exists(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE, _
						CreateMap(gblConst.filShow: "false", _
						 gblConst.filPauseBeforePark: "true", _
						 gblConst.filRetractBeforePark: "true", _
						 gblConst.filHomeBeforePark: "true", _
						 gblConst.filXPark: "0",gblConst.filYPark: "0", _
						 gblConst.filZLiftRel: "30", gblConst.filParkSpeed: "6000", _
						 gblConst.filUnloadLen:"30,150,150,150", gblConst.filUnloadSpeed:"60,2600", _
						 gblConst.filLoadLen:"150,150,150,30",gblConst.filLoadSpeed:"2600,60", _
						 gblConst.filSmallExtBeforeUload:"true"))
						 
	End If

End Sub

Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE)
	Dim ToTop As Boolean = False
	
	Dim h,w As Float
	If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
		h = 62%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		h = 55%y
	Else '--- 4 to 5.9 inch
		h = 80%y
		ToTop = True
	End If
	
	'Log("width: " & guiHelpers.gWidth)
	'Log("height: " & guiHelpers.gHeight)
	'Log("scale: " & guiHelpers.gFscale)
	If guiHelpers.gIsLandScape = False Then
		w = 94%x
	Else
		w = guiHelpers.gWidth - 90dip
	End If
	
	 ' guiHelpers.gWidth * guiHelpers.gScreenSizeDPI
	mPrefDlg.Initialize(mainObj.root, "Filament Change Settings", w, h)
	mPrefDlg.LoadFromJson(File.ReadString(File.DirAssets,"dlgFilamentCtrl.json"))
	mPrefDlg.SetEventsListener(Me,"dlgEvent")
	
	
	prefHelper.Initialize(mPrefDlg)
	
	prefHelper.ThemePrefDialogForm
	mPrefDlg.PutAtTop = ToTop
	Dim RS As ResumableSub = mPrefDlg.ShowDialog(Data, "OK", "CANCEL")
	prefHelper.dlgHelper.NoCloseOn2ndDialog
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	BuildHelpLabel
	
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast(gblConst.DATA_SAVED,1500)
		File.WriteMap(xui.DefaultFolder,gblConst.FILAMENT_CHANGE_FILE,Data)
		config.ReadWizardFilamentChangeCFG
		CallSub(mainObj.oPageCurrent,"Set_focus")
	End If
	
End Sub


Private Sub BuildHelpLabel
	lblAboutLoadUnload.Initialize("ShowInfoLoad")
	Dim cs As CSBuilder
	lblAboutLoadUnload.Text = cs.Initialize.Underline.Color(clrTheme.txtNormal).Append("Help").PopAll
	lblAboutLoadUnload.TextSize = 20
	mPrefDlg.Dialog.Base.AddView(lblAboutLoadUnload,14dip,mPrefDlg.Dialog.Base.Height - 47dip,80dip,36dip)
End Sub


Private Sub ShowInfoLoad_Click
	
	Dim s As String= $"Marlin firmware uses the EXTRUDE_MAXLENGTH setting to stop extruding large amounts.
To ensure that that you don't hit the limit, divide the extrude length into segments.
For example, if your printer has a path of 500mm, set it up like this, each segment
length less then the EXTRUDE_MAXLENGTH:

Extrude Length: `160,160,150,30` (total is 500mm)
Extrude Speed: `2500,60` (last segment is extruded at 60mm/s)

Note: Unload works in reverse."$
	

	Dim msgDlg As dlgMsgBox
	Dim w,h As Float
	
	If guiHelpers.gScreenSizeAprox < 5.8 Then
		w = guiHelpers.gWidth-40dip
		h = guiHelpers.gHeight-110dip
	Else
		w = IIf(guiHelpers.gIsLandScape,660dip,guiHelpers.gWidth-40dip)
		h=290dip
	End If
	
	msgDlg.Initialize(mainObj.root,"About Setting Up Load/UnLoad",w, h,False)
	Wait For (msgDlg.Show(s, gblConst.MB_ICON_INFO,"","","OK")) Complete (res As Int)
	
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
	prefHelper.SkinDialog(Template)
End Sub



