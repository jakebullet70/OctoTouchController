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
	Public gScreenSizeDesktop As Boolean = True
	Public gScreenSizeOriatation As String = ""  '---  P or L
	
	'Private su As StringUtils
	
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
'	
'	For Each v As B4XComboBox In cb
'	Try
'			'v.mBase.Color = clrTheme.DialogButtonsColor '--- his is the arrow
'			'v.cmbBox.Color = clrTheme.PanelBG '--- NOPE
'''			
'''			v.cmbBox.DropdownBackgroundColor=clrTheme.PanelBG
'''			v.cmbBox.DropdownTextColor= clrTheme.txtNormal
'''			v.cmbBox.TextColor = clrTheme.txtNormal
'''			v.cmbBox.Prompt = "PROMT!" '--- NOTHING
'''			
'''	'			Dim bb As B4XView
'''	'			bb = v.mBase.GetView(0)
'''			'Dim oo As B4XFont = xui.CreateDefaultFont(22)
'''			v.cmbBox.TextSize = 22
'''	'			'bb.TextColor = xui.Color_Green
'''			'--- TODO - HOW TO CHANGE SIZE-COLOR OF CBO - SPINNER ARROW			
'''			
'			'v.mBase.GetView(0).TextColor
'	Catch
'		Log(LastException)
'	End Try
'		
'		
'	Next
'	
'	
'End Sub



'public Sub ReSkinPlusMinusControl(pm As B4XPlusMinus)
'	
'	Try
'
'	#if b4j
'
'		pm.ArrowsSize = 50
'		pm.Base_Resize(pm.mBase.Width, pm.mBase.Height)
'		pm.lblPlus.TextSize = 50
'		pm.lblMinus.TextSize = 50
'		
'		pm.MainLabel.As(Label).Style = ""
'		pm.MainLabel.Font = xui.CreateDefaultFont(20)
'		
'	
'	#else
'	
''		pm.ArrowsSize = 22
''		pm.Base_Resize(pm.mBase.Width, pm.mBase.Height)
''		pm.lblPlus.TextSize = 22
''		pm.lblMinus.TextSize = 22
'		
'		'pm.MainLabel.As(Label).Style = ""
'		'pm.MainLabel.As(Label).sty
'		pm.MainLabel.Font = xui.CreateDefaultFont(18)
'		
'	#end if
'	
'		pm.lblMinus.Color = xui.Color_Transparent
'		pm.lblPlus.Color = xui.Color_Transparent
'		
'		pm.lblMinus.textColor = clrTheme.DialogButtonstextColor
'		pm.lblPlus.textColor = clrTheme.DialogButtonstextColor
'		pm.MainLabel.Color = xui.Color_Transparent
'		pm.MainLabel.textColor = clrTheme.txtNormal
'		
'		pm.Base_Resize(pm.mBase.Width, pm.mBase.Height)
'	
'	
'	Catch
'		
'		logMe.LogIt(LastException,mModule)
'		
'	End Try
'	
'End Sub



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




