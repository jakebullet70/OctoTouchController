B4J=true
Group=HELPERS
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/11/2022
#End Region
'Static code module
Sub Process_Globals
	Private xui As XUI
	Private Const mModule As String = "guiHelpers" 'ignore
	
	Public gScreenSizeAprox As Double = 7 '--- asume a small tablet
	Public gScreenSizeDPI As Int = 0
	Public gScreenSizeOriatation As String = ""  '---  P or L
	
	'Private su As StringUtils
	
End Sub

public Sub SetShadow(btn As View,OnOrOff As Boolean)
	'Old code, use to work in b4a 6.x
	Try
		Dim pnl As Panel = btn
		Dim lbl As Label, v As B4XView
		For i = 0 To pnl.NumberOfViews - 1
			v = pnl.GetView(i)
			If v Is Label Then
				lbl = v
				Dim x As Int
				If OnOrOff Then x = 3 Else x = 0
				SetTextShadow(lbl,x,3,3,Colors.DarkGray)
			End If
		Next
		
	Catch
		Log(LastException)
	End Try
	
End Sub
Public Sub SetTextShadow(pView As View, pRadius As Float, pDx As Float, pDy As Float, pColor As Int)
	Dim ref As Reflector
	Try
		ref.Target = pView
		ref.RunMethod4("setShadowLayer", Array As Object(pRadius, pDx, pDy, pColor), Array As String("java.lang.float", "java.lang.float", "java.lang.float", "java.lang.int"))
	Catch
		Log(LastException)
	End Try
	
End Sub

Public Sub GetAboutText() As String
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("OctoTouchController " & Main.Version).Append(CRLF)
	msg.Append("A dedicated touch screen controller").Append(CRLF).Append("for Octoprint using older Android devices").Append(CRLF)
	msg.Append(CRLF).Append("(c)sadLogic 2022 - Open Source - Freeware").Append(CRLF)
	Return msg.ToString
End Sub

'--- just an easy wat to Toast!!!!
public Sub Show_toast(msg As String, ms As Int)
	CallSub3(B4XPages.MainPage,"Show_Toast", msg, ms)
End Sub

public Sub HidePageParentObjs(obj() As B4XView)
	For Each o As B4XView In obj
		o.Visible = False
		o.Color = xui.Color_Transparent
	Next
End Sub


Public Sub SetActionBtnColorIsConnected(btn As B4XView)
	If oc.isConnected Then
		btn.TextColor = clrTheme.Go
	Else
		btn.TextColor = clrTheme.NoGo
	End If
End Sub


'public Sub ReSkinB4XComboBox(cb() As B4XComboBox)
'	
'	For Each v As B4XComboBox In cb
'		Try
'			'v.mBase.Color = clrTheme.DialogButtonsColor '---this is the arrow
'			'v.cmbBox.Color = clrTheme.PanelBG '--- NOPE
'			''
'			''			v.cmbBox.DropdownBackgroundColor=clrTheme.PanelBG
'			''			v.cmbBox.DropdownTextColor= clrTheme.txtNormal
'			''			v.cmbBox.TextColor = clrTheme.txtNormal
'			''			v.cmbBox.Prompt = "PROMT!" '--- NOTHING
'			''
'			''	'			Dim bb As B4XView
'			''	'			bb = v.mBase.GetView(0)
'			''			'Dim oo As B4XFont = xui.CreateDefaultFont(22)
'			''			v.cmbBox.TextSize = 22
'			''	'			'bb.TextColor = xui.Color_Green
'			''			'--- TODO - HOW TO CHANGE SIZE-COLOR OF CBO - SPINNER ARROW
'			''
'			'v.mBase.GetView(0).TextColor
'		Catch
'			Log(LastException)
'		End Try
'	Next
'End Sub



public Sub ReSkinPlusMinusControl(pm As B4XPlusMinus)
	
	Try
	
		'pm.ArrowsSize = 22
		'pm.Base_Resize(pm.mBase.Width, pm.mBase.Height)
		pm.lblPlus.TextSize = 42
		pm.lblMinus.TextSize = 42
		pm.lblMinus.Top = pm.lblMinus.Top - 12dip
		'pm.MainLabel.As(Label).Style = ""
		'pm.MainLabel.As(Label).sty
		pm.MainLabel.Font = xui.CreateDefaultFont(32)
	
		pm.lblMinus.Color = xui.Color_Transparent
		pm.lblPlus.Color = xui.Color_Transparent
		
		pm.lblMinus.textColor = clrTheme.txtNormal
		pm.lblPlus.textColor = clrTheme.txtNormal
		pm.MainLabel.Color = xui.Color_Transparent
		pm.MainLabel.textColor = clrTheme.txtNormal
		
		'pm.Base_Resize(pm.mBase.Width, pm.mBase.Height)
	
	Catch
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
End Sub



'public Sub SetTextColor(views() As B4XView, txtColor As Int)
'	
'	For Each o As B4XView In views
'		o.TextColor = txtColor
'	Next
'	
'End Sub



public Sub SetTextColorB4XFloatTextField(views() As B4XFloatTextField)
	
	For Each o As B4XFloatTextField In views
'		o.TextField.TextColor = txtColor
'		o.HintColor = hintColor
		o.TextField.TextColor = xui.Color_White
		o.HintColor = xui.Color_Yellow
		o.Update
	Next
	
End Sub





Public Sub ThemeInputDialogBtnsResize(dlg As B4XDialog)

	'--- resize buttons
	Dim btnCancel As B4XView = dlg.GetButton(xui.DialogResponse_Cancel)
	btnCancel.Width = btnCancel.Width + 20dip
	btnCancel.Left = btnCancel.Left - 28dip
	btnCancel.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,5dip)

	Dim btnOk As B4XView = dlg.GetButton(xui.DialogResponse_Positive)
	btnOk.Width = btnOk.Width + 20dip
	btnOk.Left = btnOk.Left - 48dip
	btnOk.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,5dip)
	
End Sub

Public Sub ThemeInputDialogForm(dlg As B4XDialog,intmp As B4XInputTemplate, et As EditText)
	
	et.TextSize = 18
		
	et.TextColor = clrTheme.txtNormal
	et.Gravity = Gravity.CENTER
		
	intmp.mBase.Color = clrTheme.BackgroundMenu
				
	dlg.ButtonsTextColor = clrTheme.txtNormal
	dlg.BorderColor = clrTheme.txtNormal
	dlg.BackgroundColor = clrTheme.BackgroundMenu
	dlg.ButtonsFont = xui.CreateDefaultFont(22)
	dlg.ButtonsHeight = 60dip
	
	intmp.lblTitle.Font = xui.CreateDefaultFont(22)

End Sub




