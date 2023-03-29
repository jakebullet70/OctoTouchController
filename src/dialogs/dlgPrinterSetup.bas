B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Mar/29/2023
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgPrinterSetup"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mPrefDlg As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper
	Private btn1 As Button
	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	mainObj = mobj
End Sub

Public Sub CreateDefaultFile
'	
'	Public Const psetupPRINTER_DESC As String = "desc"
'	Public Const psetupPRINTER_IP As String = "ip"
'	Public Const psetupPRINTER_PORT As String = "port"
'	Public Const psetupPRINTER_X As String = "bx"
'	Public Const psetupPRINTER_Y As String = "by"
'	
	
	If File.Exists(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE, _
						CreateMap(gblConst.psetupPRINTER_DESC: "default", _
						 gblConst.psetupPRINTER_IP: "",  gblConst.psetupPRINTER_PORT: "80", _
						 gblConst.psetupPRINTER_X: "220", gblConst.psetupPRINTER_Y: "220"))
						 
	End If

End Sub

Public Sub Show(firstRun As Boolean)
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE)
	Dim ToTop As Boolean = False
	
	Dim h,w As Float
	If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
		h = 62%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		h = 52%y
	Else '--- 4 to 5.9 inch
		h = 60%y
	End If
	
	If guiHelpers.gIsLandScape = False Then
		w = 90%x
	Else
		w = guiHelpers.gWidth - 90dip
	End If
	
	 ' guiHelpers.gWidth * guiHelpers.gScreenSizeDPI
	mPrefDlg.Initialize(mainObj.root, "Printer Settings", w, h)
	mPrefDlg.LoadFromJson(File.ReadString(File.DirAssets,"dlgprintersetup.json"))
	mPrefDlg.SetEventsListener(Me,"dlgEvent")
	
	prefHelper.Initialize(mPrefDlg)
	
	prefHelper.ThemePrefDialogForm
	mPrefDlg.PutAtTop = ToTop
	Dim RS As ResumableSub = mPrefDlg.ShowDialog(Data, "SAVE", "CLOSE")
	prefHelper.dlgHelper.NoCloseOn2ndDialog
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	mPrefDlg.Dialog.GetButton(xui.DialogResponse_Positive).Visible = False
	BuildBtn
	
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast("Printer Config Saved",1500)
		File.WriteMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE,Data)
		
		'config.ReadPrinter
		
		CallSub(mainObj.oPageCurrent,"Set_focus")
	End If
	
End Sub


Private Sub BuildBtn

	btn1.Initialize("ActionBtn1") : btn1.Text = "Validate"
	btn1.TextSize = mPrefDlg.Dialog.GetButton(xui.DialogResponse_Cancel).TextSize
	
	Dim t,w,h As Float
	w = mPrefDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Width + 4dip
	h = mPrefDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Height
	t = mPrefDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Top
	mPrefDlg.Dialog.Base.AddView(btn1, 8dip, t, w,h)
	guiHelpers.SkinButton(Array As Button(btn1))
	
	
End Sub

Private Sub ActionBtn1_Click

	Dim data As Map = mPrefDlg.PeekEditedData
	If data.Get(gblConst.psetupPRINTER_IP) = "" Then
	
	End If
	
End Sub



'Private Sub ShowInfoLoad_Click
'	
'	Dim s As String= $"Marlin firmware uses the EXTRUDE_MAXLENGTH setting to stop extruding large amounts.
'To ensure that that you don't hit the limit, divide the extrude length into segments.
'For example, if your printer has a path of 500mm, set it up like this, each segment
'length less then the EXTRUDE_MAXLENGTH:
'
'Extrude Length: `160,160,150,30` (total is 500mm)
'Extrude Speed: `2500,60` (last segment is extruded at 60mm/s)
'
'Note: Unload works in reverse."$
'	
'
'	Dim msgDlg As dlgMsgBox
'	Dim w,h As Float
'	
'	If guiHelpers.gScreenSizeAprox < 5.8 Then
'		w = guiHelpers.gWidth-40dip
'		h = guiHelpers.gHeight-110dip
'	Else
'		w = IIf(guiHelpers.gIsLandScape,660dip,guiHelpers.gWidth-40dip)
'		h=290dip
'	End If
'	
'	msgDlg.Initialize(mainObj.root,"About Setting Up Load/UnLoad",w, h,False)
'	Wait For (msgDlg.Show(s, gblConst.MB_ICON_INFO,"","","OK")) Complete (res As Int)
'	
'End Sub


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



