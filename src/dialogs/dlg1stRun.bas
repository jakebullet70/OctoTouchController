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
	Private lblAboutTop As Label
	Private dlgHelper As sadB4XDialogHelper
	Private iv As lmB4XImageViewX
	Private chkBox As CheckBox
	Private txt1stRun,txtNever As AutoTextSizeLabel
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
	p.SetLayoutAnimated(0, 0, 0,540dip,420dip)
	p.LoadLayout("dlg1stRun")
	
	iv.Bitmap = XUI.LoadBitmap(File.DirAssets,"logo02.png")
	
	
	dlgHelper.ThemeDialogForm( "App Update Checking")
	Dim rs As ResumableSub = dlg.ShowCustom(p, "", "", "OK")
	'dlgHelper.ThemeDialogBtnsResize
	dlgHelper.ThemeInputDialogBtnsResize
		
	'--- interesting text goes here
	lblAboutTop.TextSize = 18
	'txtNever.BaseLabel
	guiHelpers.SetTextColor3(Array As B4XView(lblAboutTop,txt1stRun.BaseLabel,txtNever.BaseLabel),clrTheme.txtNormal)
	txtNever.Text = "Remember, updates will *NEVER* be downloaded automaticly"
	txt1stRun.Text = File.GetText(File.DirAssets,"1stRun.txt")
	BuildChkbox
	
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("(©)sadLogic 2015-25").Append(CRLF)
	msg.Append("Kherson Ukraine!").Append(CRLF)
	msg.Append("AGPL-3.0 license")
	lblAboutTop.Text = msg.ToString
	
	Wait For (rs) Complete (Result As Int)
	
	'CallSubDelayed(B4XPages.MainPage,"ResetScrn_SleepCounter")
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
	'chkBox.Checked = Main.kvs.GetDefault(FIL_WIZ_TURN_OFF_ON_HEAT,False)
End Sub

Private Sub chkCheckUpdate_CheckedChange(Checked As Boolean)
	' save?
	'Main.kvs.Put(FIL_WIZ_TURN_OFF_ON_HEAT,Checked)
End Sub



