﻿B4A=true
Group=DIALOGS_GENERIC
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic - Kherson, Ukraine
#Region VERSIONS 
' V. 1.0 	Mar/31/2023
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgMsgBox2"' 'ignore
	Private mMainObj As B4XView
	Private xui As XUI
	Private mTitle As String
	Private mHeight As Float
	Private mWidth As Float
	Private mPutNegativeBtn2Left As Boolean 
	
	Public lblTxt As Label
	
	Private BasePnl As B4XView
	Private mDialog As B4XDialog
	
	Private lmB4XImageViewX1 As lmB4XImageViewX
	Private mKvStr As String
	
	Private pnlBG As B4XView
	Public NewTextSize As Float = 0
	
End Sub

Public Sub getVisible() As Boolean
	Try
		Return mDialog.Visible
	Catch
		Return False
	End Try
End Sub

Public Sub Close_Me
	mDialog.Close(xui.DialogResponse_Cancel)
End Sub


Public Sub Initialize(parentObj As B4XView, title As String, width As Float, height As Float,PutNegativeBtn2Left As Boolean)
	mMainObj = parentObj
	mTitle   = title
	mHeight  = height
	mWidth   = width
	mPutNegativeBtn2Left = PutNegativeBtn2Left
	
	BasePnl = xui.CreatePanel("")
	BasePnl.SetLayoutAnimated(0, 0, 0, mWidth, mHeight)
	BasePnl.LoadLayout("viewMsgBox2.bal")
	
	lblTxt.TextColor = clrTheme.txtNormal
	pnlBG.Color = clrTheme.Background
	
End Sub

Public Sub SetAsOptionalMsgBox(kvKey As String)
	mKvStr = kvKey
	Main.kvs.Put(mKvStr,False.As(String))
End Sub


Public Sub Show(txt  As String, icon_file As String, _
				btn1 As String, btn2 As String, btn3 As String)As ResumableSub
	
	'--- init
	mDialog.Initialize(mMainObj)
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	
	'guiHelpers.ResizeText(txt,lblTxt)
	lblTxt.Text =   txt
	If NewTextSize <> 0 Then
		lblTxt.TextSize = NewTextSize
	End If
	
	lmB4XImageViewX1.Load(File.DirAssets, icon_file)
	lmB4XImageViewX1.SetBitmap(guiHelpers.ChangeColorBasedOnAlphaLevel(lmB4XImageViewX1.Bitmap,clrTheme.txtNormal))

	dlgHelper.ThemeDialogForm(mTitle)
	Dim rs As ResumableSub = mDialog.ShowCustom(BasePnl,btn1,btn2,btn3)
	ThemeInputDialogBtnsResize2(mDialog,mWidth)
	dlgHelper.AnimateDialog("top")
	
	If mKvStr <> "" Then CreateDoNotShowCheckbox
	
	Wait For (rs) Complete (Result As Int)
	Return Result
	
End Sub

Private Sub CreateDoNotShowCheckbox
	Dim chk As CheckBox : chk.Initialize("DoNotShow")
	chk.Text = " Do not show again"
	chk.TextColor = clrTheme.txtNormal
	chk.TextSize = 18
	guiHelpers.SetCBDrawable(chk, clrTheme.txtNormal, 1,clrTheme.txtNormal, Chr(8730), Colors.LightGray, 32dip, 2dip)
	mDialog.Base.AddView(chk,10dip,mDialog.Base.Height - 50dip, _
		 (mDialog.Base.Width - mDialog.GetButton(xui.DialogResponse_Cancel).Width - 6dip),36dip)
	
End Sub
Private Sub DoNotShow_CheckedChange(Checked As Boolean)
	Main.kvs.Put(mKvStr,Checked.As(String))
End Sub


Private Sub ThemeInputDialogBtnsResize2(dlg As B4XDialog, w As Float)
	
	Dim numOfBtns As Int = 0
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnCancel As B4XView = dlg.GetButton(xui.DialogResponse_Cancel)
		If btnCancel <> Null Then
			numOfBtns = numOfBtns + 1
			btnCancel.Font = xui.CreateDefaultFont(NumberFormat2(btnCancel.Font.Size / guiHelpers.gFscale,1,0,0,False))
			btnCancel.Width = btnCancel.Width + 20dip
			btnCancel.Left = w - btnCancel.Width - 5dip
			btnCancel.Height = btnCancel.Height - 4dip '--- resize height just a hair
			btnCancel.Top = btnCancel.Top + 4dip
			btnCancel.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		End If
	Catch
		'Log(LastException)
	End Try 'ignore
	
	'======================================================================

	Try '--- reskin button, if it does not exist then skip the error
		Dim btnYes As B4XView = dlg.GetButton(xui.DialogResponse_Positive)
		
		If btnYes <> Null Then
			numOfBtns = numOfBtns + 1
			btnYes.Font = xui.CreateDefaultFont(NumberFormat2(btnYes.Font.Size / guiHelpers.gFscale,1,0,0,False))
			btnYes.Width = btnYes.Width + 20dip
			btnYes.Left = w - (btnYes.width * numOfBtns) - (5dip  * numOfBtns)
			btnYes.Height = btnYes.Height - 4dip '--- resize height just a hair
			btnYes.Top = btnYes.Top + 4dip
			btnYes.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		End If
	Catch
		'Log(LastException)
	End Try 'ignore

	'======================================================================

	Try '--- reskin button, if it does not exist then skip the error
		Dim btnNo As B4XView = dlg.GetButton(xui.DialogResponse_Negative)
		
		If btnNo <> Null Then
			numOfBtns = numOfBtns + 1
			btnNo.Font = xui.CreateDefaultFont(NumberFormat2(btnNo.Font.Size / guiHelpers.gFscale,1,0,0,False))
			btnNo.Width = btnNo.Width + 20dip
			btnNo.Height = btnNo.Height - 4dip '--- resize height just a hair
			btnNo.Top = btnNo.Top + 4dip
			If mPutNegativeBtn2Left Then
				btnNo.Left = 10dip
			Else
				btnNo.Left = w - (btnNo.width * numOfBtns) - (5dip  * numOfBtns)
			End If
			btnNo.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		End If
		
	Catch
		'Log(LastException)
	End Try 'ignore
	
End Sub






