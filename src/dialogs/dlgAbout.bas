B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Oct/02/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgAbout"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private pnlMain As B4XView
	Private mDialog As B4XDialog
	
	Private lmB4XImageViewX1 As lmB4XImageViewX
	Private lblTxt As AutoTextSizeLabel
	Private MadeWithLove1 As MadeWithLove
	Private lblCheck4NewVer As Label
	
End Sub

Public Sub Initialize(mobj As B4XMainPage)
	mMainObj = mobj
End Sub


Public Sub Show
	
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	Dim w,h As Float 
	If guiHelpers.gIsLandScape Then
		w = IIf(guiHelpers.gScreenSizeAprox < 6,460dip,640dip)
		h = 300dip
	Else
	 	w = IIf(guiHelpers.gScreenSizeAprox < 6,guiHelpers.gWidth - 40dip,520dip)
		h = 280dip
	End If
	
	p.SetLayoutAnimated(0, 0, 0, w,h)
		
		
	p.LoadLayout("viewAbout")
	BuildGUI
	
	guiHelpers.ThemeDialogForm(mDialog, "About")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "OK", "", "")
	BuildAboutLabel
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	Wait For (rs) Complete (Result As Int)
	
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
	
End Sub

Private Sub BuildGUI
	pnlMain.Color = clrTheme.Background
	lmB4XImageViewX1.Load(File.DirAssets, "splash.png")
	lblTxt.Text = GetAboutText
	guiHelpers.SetTextColor(Array As B4XView(lblTxt.BaseLabel))
End Sub


Private Sub BuildAboutLabel
	lblCheck4NewVer.Initialize("Check4NewVer")
	lblCheck4NewVer.Text = "Check for new version"
	lblCheck4NewVer.TextColor = Colors.White
	lblCheck4NewVer.TextSize = 20
	mDialog.Base.AddView(lblCheck4NewVer,14dip,mDialog.Base.Height - 47dip,280dip,36dip)
	
	lblCheck4NewVer.Visible = False '--- just disable for the moment
	
End Sub

Private Sub Check4NewVer_Click
'	mDialog.Close(-1) '--- close it, exit dialog	
	
End Sub


Private Sub GetAboutText() As String
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("OctoTouchController™ " & gblConst.VERSION).Append(CRLF)
	msg.Append("A dedicated touch screen controller for Octoprint using older Android devices").Append(CRLF).Append(CRLF)
	msg.Append("(©)sadLogic 2022").Append(CRLF)
	msg.Append("Kherson Ukraine!").Append(CRLF)
	msg.Append("AGPL-3.0 license")
	Return msg.ToString
End Sub


