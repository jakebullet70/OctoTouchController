B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "pageMovement" 'ignore
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private  mMainObj As B4XMainPage'ignore
	

End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.LoadLayout("pageMovement")
	
	CallSubDelayed(Me,"Build_GUI")
	
End Sub

public Sub Set_focus()
	mPnlMain.Visible = True
End Sub

public Sub Lost_focus()
	mPnlMain.Visible = False
End Sub


Private Sub Build_GUI
	
End Sub
'	CallSub2(mMainObj,mCallBackEvent,oo.Tag2)


public Sub Update_Printer_Btns
	'--- sets enable, disable
	
End Sub

