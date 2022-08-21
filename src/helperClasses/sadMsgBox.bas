B4A=true
Group=CLASSES
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
Sub Class_Globals
	Private mMainObj As B4XMainPage 'ignore
	Private xui As XUI
End Sub


Public Sub Initialize(mObj As B4XMainPage)
	mMainObj = mObj
End Sub


'icon = "INFO","QUES","STOP"
public Sub Show(headerTXT As String, bodyTXT As String, icon As String, _
					btn1 As String, btn2 As String,btn3 As String, _
					width As Float, height As Float, Asmb As ASMsgBox) As ResumableSub
	
	Dim icon_file As String = ""
	Dim ASMsgBox1 As ASMsgBox
	ASMsgBox1.Initialize(mMainObj,"ASMsgBox1")
	ASMsgBox1.InitializeWithoutDesigner(mMainObj.Root,clrTheme.BackgroundMenu,True,True,False,460dip,300dip)
	ASMsgBox1.InitializeBottom(btn1,btn2,btn3)
	ASMsgBox1.HeaderColor = clrTheme.BackgroundHeader
	ASMsgBox1.BottomColor = clrTheme.BackgroundHeader
	ASMsgBox1.Header_Text = headerTXT
	ASMsgBox1.Header_Font_Size = 28
	ASMsgBox1.Icon_direction = "LEFT"
	ASMsgBox1.Button3.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,5dip)
	ASMsgBox1.Button2.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,5dip)
	ASMsgBox1.Button1.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,5dip)
	
	Select Case icon
		Case "INFO" : icon_file = "mb_info.png"
		Case "QUES" : icon_file = "mb_question.png"
		Case "STOP" : icon_file = "mb_stop.png"
	End Select
	
	ASMsgBox1.icon_set_icon(xui.LoadBitmap(File.DirAssets,icon_file))
	ASMsgBox1.CenterDialog(mMainObj.Root)
	ASMsgBox1.ShowWithText(bodyTXT,True)
	
	Wait For ASMsgBox1_result(res As Int)
	'Wait For (ASMsgBox1.Close(True)) Complete (Closed As Boolean)
	Return res
	
End Sub
