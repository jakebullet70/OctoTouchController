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
	
	mainObj.pPrinterCfgDlgShowingFLAG = True
	
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
		w = 92%x
	Else
		w = 380dip
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
		guiHelpers.Show_toast(gblConst.DATA_SAVED,1500)
		File.WriteMap(xui.DefaultFolder,gblConst.PRINTER_SETUP_FILE,Data)
		oc.IsConnectionValid = True
		CallSubDelayed(mainObj,"PrinterSetup_Closed")
		CallSubDelayed(mainObj.oPageCurrent,"Set_focus")
	End If
	
	mainObj.pPrinterCfgDlgShowingFLAG = False
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub


Private Sub BuildBtn

	btn1.Initialize("ActionBtn1") : btn1.Text = "TEST"
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
	Dim ip As String = data.Get(gblConst.psetupPRINTER_IP)
	Dim port As String = data.Get(gblConst.psetupPRINTER_PORT)
	
	If  (fnc.IsValidIPv4Address(ip) = False And fnc.IsValidIPv6Address(ip) = False) Or IsNumber(port) = False   Then
		Dim mb As dlgMsgBox : mb.Initialize(mainObj.Root,"Problem",320dip, 160dip,False)
		Wait For (mb.Show("Check if your IP and Port are set", gblConst.MB_ICON_WARNING,"","","OK")) Complete (res As Int)
		Return
	End If
	
	mPrefDlg.Dialog.GetButton(xui.DialogResponse_Positive).Visible = False
	mPrefDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Visible  = False
	btn1.Visible = False
	
	'--- now test connection.
	Dim sAPI As String = $"http://${ip}:${port}${oc.cSERVER}"$
	Dim j As HttpJob: j.Initialize("", Me)
	j.Download(sAPI)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		If j.GetString.Contains("server") Then
			mPrefDlg.Dialog.GetButton(xui.DialogResponse_Positive).Visible = True
			guiHelpers.Show_toast2("Connection OK!",2000)
		End If
	Else
		Dim mb As dlgMsgBox : mb.Initialize(mainObj.Root,"Problem",320dip, 160dip,False)
		Wait For (mb.Show("Connection failure.", gblConst.MB_ICON_WARNING,"","","OK")) Complete (res As Int)
	End If
	
	j.Release '--- free up resources
	mPrefDlg.Dialog.GetButton(xui.DialogResponse_Cancel).Visible = True
	btn1.Visible = True
	
End Sub


Private Sub Rebuild_GUI
	'--- needed when using dlgEvent_IsValid
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	BuildBtn
End Sub

Private Sub dlgEvent_IsValid (TempData As Map) As Boolean 'ignore
	
	Dim retval As Boolean = True
	Do While True

		'--- force a printer description		
		If  strHelpers.IsNullOrEmpty( TempData.Get(gblConst.psetupPRINTER_DESC) ) Then
			mPrefDlg.ScrollToItemWithError(gblConst.psetupPRINTER_DESC)
			retval =  False
			Exit 'Do
		End If
		
		Exit 'Do	
	Loop
	
	Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"Rebuild_GUI",50) '--- needed when using dlgEvent_IsValid
	Return retval '--- all is good!

End Sub


Private Sub dlgEvent_BeforeDialogDisplayed (Template As Object)
	prefHelper.SkinDialog(Template)
End Sub



