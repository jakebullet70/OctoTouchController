B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic - Kherson, Ukraine
#Region VERSIONS 
' V. 1.1 	Aug/21/2022
'			Made lblTxt public
' V. 1.0 	Aug/12/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgMsgBox"' 'ignore
	Private mMainObj As B4XView
	Private xui As XUI
	Private mTitle As String
	Private mHeight As Float
	Private mWidth As Float
	
	Private lblPic As B4XView
	Public lblTxt As AutoTextSizeLabel
	
	Private BasePnl As B4XView
	Private Dialog As B4XDialog
	
End Sub



Public Sub Initialize(parentObj As B4XView, title As String, width As Float, height As Float)
	
	mMainObj = parentObj
	mTitle   = title
	mHeight  = height
	mWidth   = width
	
	BasePnl = xui.CreatePanel("")
	BasePnl.SetLayoutAnimated(0, 0, 0, mWidth, mHeight)
	BasePnl.LoadLayout("viewMsgBox")
	
	lblTxt.TextColor = clrTheme.txtNormal
	
End Sub


Public Sub Show(txt  As String, icon_file As String, _
				btn1 As String, btn2 As String, btn3 As String)As ResumableSub
	
	'--- init
	Dialog.Initialize(mMainObj)
	
	lblTxt.Text = txt
	lblPic.SetBitmap(LoadBitmapSample(File.DirAssets, icon_file, lblPic.Width, lblPic.Height))

	guiHelpers.ThemeDialogForm(Dialog, mTitle)
	Dim rs As ResumableSub = Dialog.ShowCustom(BasePnl,btn1,btn2,btn3)
	guiHelpers.ThemeInputDialogBtnsResize(Dialog)
	
	Wait For (rs) Complete (Result As Int)
	Return Result
	
End Sub




