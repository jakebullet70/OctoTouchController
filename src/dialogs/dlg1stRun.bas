B4J=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
' Author:  sadLogic/JakeBullet
#Region VERSIONS 
' May/2025 - Brought over from HomeCentral to conform to FOSS like stuff...
' V. 1.0 	Dec/21/2023
#End Region


Sub Class_Globals
	Private XUI As XUI
	Private dlg As B4XDialog
	Private dlgHelper As sadB4XDialogHelper
	Private chkBox As CheckBox
	Private txtNever As AutoTextSizeLabel
	Private txt1stRun As B4XView
End Sub


Public Sub Initialize() As Object
	Return Me
End Sub
Public Sub Close_Me
	dlg.Close(XUI.DialogResponse_Cancel)
End Sub


Public Sub Show()
		
	dlg.Initialize((B4XPages.MainPage.Root))
	dlgHelper.Initialize(dlg)
		
	Dim p As B4XView = XUI.CreatePanel("")
	'p.SetLayoutAnimated(0, 0, 0,540dip,420dip)
	
	Dim w, h As Float
	If guiHelpers.gScreenSizeAprox < 7 Then
		w = 92%x
		h = IIf(guiHelpers.gIsLandScape,64%y,70%y)
	Else
		w = 74%x : h = 70%y
	End If
	Log("w="&w)
	Log("h="&h)
	
	p.SetLayoutAnimated(0, 0, 0, w,h)
	p.LoadLayout("dlg1stRun")
	
	
	dlgHelper.ThemeDialogForm( "App Update Checking")
	Dim rs As ResumableSub = dlg.ShowCustom(p, "", "", "OK")
	'dlgHelper.ThemeDialogBtnsResize
	dlgHelper.ThemeInputDialogBtnsResize
		
	'--- interesting text goes here
	guiHelpers.SetTextColor3(Array As B4XView(txt1stRun,txtNever.BaseLabel),clrTheme.txtNormal)
	txtNever.Text = "Remember, updates will *NEVER* be downloaded automaticly"
	txt1stRun.Text = File.GetText(File.DirAssets,"1stRun.txt")
	If guiHelpers.gIsLandScape = False Then
		txt1stRun.TextSize = txt1stRun.TextSize + 3
	End If
	BuildChkbox
	
	Wait For (rs) Complete (Result As Int)
		
	config.Change_AppUpdateCheck(chkBox.Checked)
	Close_Me
	
End Sub



Private Sub BuildChkbox
	chkBox.Initialize("chkCheckUpdate")
	chkBox.Text = " Check for updates"
	chkBox.TextColor = clrTheme.txtNormal
	chkBox.TextSize = 18
	guiHelpers.SetCBDrawable(chkBox, clrTheme.txtNormal, 1,clrTheme.txtNormal, Chr(8730), Colors.LightGray, 32dip, 2dip)
	dlg.Base.AddView(chkBox,10dip,dlg.Base.Height - 50dip, _
		(dlg.Base.Width - dlg.GetButton(XUI.DialogResponse_Cancel).Width - 16dip),36dip)
	
End Sub

Private Sub chkCheckUpdate_CheckedChange(Checked As Boolean)
	' save?
	'Main.kvs.Put(FIL_WIZ_TURN_OFF_ON_HEAT,Checked)
End Sub



