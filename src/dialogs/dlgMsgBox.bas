B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
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
	Public lblTxt As B4XView
	
	Private BasePnl As B4XView
	Private Dialog As B4XDialog
	
End Sub



Public Sub Initialize(mobj As B4XView, title As String, width As Float, height As Float)
	
	mMainObj = mobj
	mTitle = title
	mHeight = height
	mWidth = width
	
	BasePnl = xui.CreatePanel("")
	BasePnl.SetLayoutAnimated(0, 0, 0, mWidth, mHeight)
	BasePnl.LoadLayout("viewMsgBox")
	
	lblTxt.TextColor = clrTheme.txtNormal
	
End Sub


'icon = "INFO","QUES","STOP"
Public Sub Show(txt  As String, icon As String, _
				btn1 As String, btn2 As String, btn3 As String)As ResumableSub
	
	'--- init
	Dialog.Initialize(mMainObj)
	
	Dim icon_file As String
	Select Case icon
		Case gblConst.MB_ICON_QUESTION : icon_file = "mb_question.png"
		Case gblConst.MB_ICON_WARNING  : icon_file = "mb_stop.png"
		Case Else
			icon_file = "mb_info.png"
	End Select
	
	lblTxt.Text = txt
	lblPic.SetBitmap(LoadBitmapSample(File.DirAssets, icon_file, lblPic.Width, lblPic.Height))

	guiHelpers.ThemeDialogForm(Dialog, mTitle)
	Dim rs As ResumableSub = Dialog.ShowCustom(BasePnl,btn1,btn2,btn3)
	guiHelpers.ThemeInputDialogBtnsResize(Dialog)
	
	Wait For (rs) Complete (Result As Int)
	Return Result
	
End Sub




