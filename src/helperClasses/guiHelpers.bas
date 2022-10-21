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
	Public gIsLandScape As Boolean 
	Public gFscale As Double
	Public gWidth As Float
	Public gHeight As Float
	
	
End Sub


'=====================================================================================
'  Generic GUI helper methods
'=====================================================================================

'Public Sub FontAwesomeToBitmap(Text As String, FontSize As Float) As B4XBitmap
'	Dim xui As XUI
'	Dim p As Panel = xui.CreatePanel("")
'	p.SetLayoutAnimated(0, 0, 0, 32dip, 32dip)
'	Dim cvs1 As B4XCanvas
'	cvs1.Initialize(p)
'	Dim fnt As B4XFont = xui.CreateFontAwesome(FontSize)
'	Dim r As B4XRect = cvs1.MeasureText(Text, fnt)
'	Dim BaseLine As Int = cvs1.TargetRect.CenterY - r.Height / 2 - r.Top
'	cvs1.DrawText(Text, cvs1.TargetRect.CenterX, BaseLine, fnt, xui.Color_White, "CENTER")
'	Dim b As B4XBitmap = cvs1.CreateBitmap
'	cvs1.Release
'	Return b
'End Sub

Public Sub GetConnectFailedMsg() As String
	Dim msg As StringBuilder : msg.Initialize
	msg.Append("Connection Failed.").Append(CRLF)
	msg.Append("Is Octoprint turned on?").Append(CRLF).Append("Are Your IP And Port correct?").Append(CRLF)
	Return msg.ToString
End Sub

Public Sub SetVisible(btnArr() As B4XView,Visible As Boolean)
	For Each v As B4XView In btnArr
		v.Visible = Visible
	Next
End Sub

Public Sub SetEnableDisableColor(btnArr() As B4XView)
	For Each btn As B4XView In btnArr
		If btn.enabled Then
			btn.TextColor = clrTheme.txtNormal
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
		Else
			btn.TextColor = clrTheme.btnDisableText
			btn.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.btnDisableText,8dip)
		End If
	Next
End Sub

Public Sub EnableDisableBtns(btnArr() As B4XView,EnableDisable As Boolean)
	For Each btn As B4XView In btnArr
		btn.enabled = EnableDisable
	Next
	SetEnableDisableColor(btnArr)
End Sub


Public Sub GetConnectionText(connectedButError As Boolean) As String
	
	Dim Msg As StringBuilder : Msg.Initialize
	
	If connectedButError Then
		Msg.Append("Connected to Octoprint but there is an error.").Append(CRLF)
		Msg.Append("Check that Octoprint is connected to the printer?").Append(CRLF)
		Msg.Append("Make sure you can print from the Octoprint UI.")
	Else
		Msg.Append("No connection to Octoprint. Is Octoprint turned on?")
		Msg.Append(CRLF).Append("Connected to the printer?")
	End If
	
	Return Msg.ToString
End Sub

Public Sub GetOctoPluginWarningTxt() As String
	
	Dim Msg As StringBuilder : Msg.Initialize
	Msg.Append("When setting up a connection here to an Octoprint ")
	Msg.Append("plugin make sure it is working in Octoprint first ")
	Msg.Append("before you complete the setup here.").Append(CRLF)
	
	Return Msg.ToString
	
End Sub

'--- just an easy wat to Toast!!!!
Public Sub Show_toast(msg As String, ms As Int)
	CallSub3(B4XPages.MainPage,"Show_Toast", msg, ms)
End Sub
Public Sub Show_toast2(msg As String, ms As Int)
	CallSubDelayed3(B4XPages.MainPage,"Show_Toast", msg, ms)
End Sub

public Sub HidePageParentObjs(obj() As B4XView)
	For Each o As B4XView In obj
		o.Visible = False
		o.Color = xui.Color_Transparent
	Next
End Sub


Public Sub ReSkinB4XComboBox(cbo() As B4XComboBox)
	
	For Each cb As B4XComboBox In cbo
		Try
			
			cb.cmbBox.TextColor = clrTheme.txtNormal
			cb.cmbBox.Color = clrTheme.BackgroundHeader
			cb.cmbBox.DropdownBackgroundColor = clrTheme.BackgroundHeader
			cb.cmbBox.DropdownTextColor = clrTheme.txtNormal
		Catch
			Log(LastException)
		End Try
	Next
End Sub


Public Sub SetTextColorB4XFloatTextField(views() As B4XFloatTextField)
	
	For Each o As B4XFloatTextField In views
		o.TextField.TextColor = clrTheme.txtNormal
		o.NonFocusedHintColor = clrTheme.txtAccent
		o.HintColor = clrTheme.txtAccent
		o.Update
	Next
	
End Sub

Public Sub pref_BeforeDialogDisplayed(mDlg As sadPreferencesDialog, Template As Object)
	
	Dim fnt0 As B4XFont = xui.CreateDefaultFont(20)
	
	Try
		
		For i = 0 To mDlg.PrefItems.Size - 1
			Dim pit As B4XPrefItem = mDlg.PrefItems.Get(i)
			
			Select Case pit.ItemType
				Case mDlg.TYPE_TEXT, mDlg.TYPE_PASSWORD, mDlg.TYPE_NUMBER, mDlg.TYPE_DECIMALNUMBER, mDlg.TYPE_MULTILINETEXT
					Dim ft As B4XFloatTextField = mDlg.CustomListView1.GetPanel(i).GetView(0).Tag
					ft.TextField.Font = fnt0
					SetTextColorB4XFloatTextField(Array As B4XFloatTextField(ft))
	
				Case mDlg.TYPE_BOOLEAN
					Dim p As B4XView = mDlg.CustomListView1.GetPanel(i).GetView(0)
					p.Font = xui.CreateDefaultFont(20)
				
			End Select
	
		Next
		
	Catch
		Log(LastException)
	End Try
	
End Sub



Public Sub ThemeInputDialogBtnsResize(dlg As B4XDialog)
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnCancel As B4XView = dlg.GetButton(xui.DialogResponse_Cancel)
		btnCancel.Font = xui.CreateDefaultFont(NumberFormat2(btnCancel.Font.Size / gFscale,1,0,0,False))
		btnCancel.Width = btnCancel.Width + 20dip
		btnCancel.Left = btnCancel.Left - 28dip
		btnCancel.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Try '--- reskin button, if it does not exist then skip the error
		Dim btnOk As B4XView = dlg.GetButton(xui.DialogResponse_Positive)
		btnOk.Font = xui.CreateDefaultFont(NumberFormat2(btnOk.Font.Size / gFscale,1,0,0,False))
		btnOk.Width = btnOk.Width + 20dip
		btnOk.Left = btnOk.Left - 48dip
		btnOk.SetColorAndBorder(xui.Color_Transparent,2dip,clrTheme.txtNormal,8dip)
	Catch
		'Log(LastException)
	End Try 'ignore
	
'	Try '--- reskin button, if it does not exist then skip the error
'		Dim btnNo As B4XView = dlg.GetButton(xui.DialogResponse_Negative)
'		btnNo.Font = xui.CreateDefaultFont(NumberFormat2(btnNo.Font.Size / gFscale,1,0,0,False))
'		btnNo.Width = btnOk.Width + 20dip
'		btnNo.Left = btnOk.Left - 48dip
'		btnNo.SetColorAndBorder(xui.Color_Transparent,2dip,xui.Color_White,8dip)
'	Catch
'		'Log(LastException)
'	End Try 'ignore
		
End Sub



Public Sub ThemePrefDialogForm(prefdlg As sadPreferencesDialog)
	
	Try
		
		prefdlg.ItemsBackgroundColor = clrTheme.Background
		prefdlg.SeparatorBackgroundColor = clrTheme.BackgroundHeader
		prefdlg.SeparatorTextColor = clrTheme.txtAccent
		prefdlg.TextColor = clrTheme.txtNormal
		
		'prefdlg.Dialog.BackgroundColor = clrTheme.BackgroundMenu
		'prefdlg.mBase.Color = clrTheme.BackgroundMenu
		
		'prefdlg.Dialog.Base.Color = clrTheme.BackgroundMenu
		'prefdlg.CustomListView1.sv.SetColorAndBorder(xui.Color_Transparent,1dip,xui.Color_blue,0dip)
		'prefdlg.mBase.SetColorAndBorder(xui.Color_Blue,2dip,xui.Color_White,5dip)
		
		'prefdlg.CustomListView1.AsView.Color = clrTheme.BackgroundMenu
		'prefdlg.CustomListView1.GetBase.Color = clrTheme.BackgroundMenu
		'prefdlg.CustomListView1. = clrTheme.BackgroundMenu
		
		ThemeDialogForm(prefdlg.Dialog,prefdlg.Title.As(String))
		
	Catch
		logMe.LogIt2(LastException,mModule,"ThemePrefDialogForm")
	End Try
	

End Sub


Public Sub ThemeDialogForm(dlg As B4XDialog,title As Object)
	ThemeDialogForm2(dlg,title,22)
End Sub


Public Sub ThemeDialogForm2(dlg As B4XDialog,title As Object,txtSize As Int)
	
	Try
		dlg.Title = title
	Catch
		'--- errors sometimes, I think... something to do with the title not showing on smaller screens
		'--- b4xdialog.PutAtTop = False  <----   this!
		'Log("ThemeDialogForm-set title: " & LastException)
	End Try 'ignore
	
	dlg.TitleBarFont = xui.CreateDefaultFont(NumberFormat2(txtSize / gFscale,1,0,0,False))
	dlg.TitleBarColor = clrTheme.BackgroundHeader
	dlg.TitleBarTextColor = clrTheme.txtNormal
	dlg.ButtonsTextColor = clrTheme.txtNormal
	dlg.BorderColor = clrTheme.txtNormal
	dlg.BackgroundColor = clrTheme.BackgroundMenu
	dlg.ButtonsFont = xui.CreateDefaultFont(txtSize)
	dlg.ButtonsHeight = 60dip
	
	
End Sub


public Sub SetTextColor(obj() As B4XView)
	For Each o As B4XView In obj
		o.TextColor = clrTheme.txtNormal
	Next
End Sub



Public Sub AnimateDialog (dlg As B4XDialog, FromEdge As String)
	Dim base As B4XView = dlg.Base
	Dim top As Int = base.Top
	Dim left As Int = base.Left
	Select FromEdge.ToLowerCase
		Case "bottom"
			base.Top = base.Parent.Height
		Case "top"
			base.Top = -base.Height
		Case "left"
			base.Left = -base.Width
		Case "right"
			base.Left = base.Parent.Width
	End Select
	base.SetLayoutAnimated(220, left, top, base.Width, base.Height)
End Sub



'Change the size and color of a Checkbox graphic. Set the tick character and color, as well as the box size and color
'and padding (distance from the box to the edge of the graphic) and a disabled fill color
'Pass "Fill" as the TickChar to fill the box with TickColor when selected.
Public Sub SetCBDrawable(CB As CheckBox,BoxColor As Int,BoxWidth As Int, _
			TickColor As Int,TickChar As String,DisabledColor As Int,Size As Int,Padding As Int)
			
	Dim SLD As StateListDrawable
	SLD.Initialize

	Dim BMEnabled,BMChecked,BMDisabled As Bitmap
	BMEnabled.InitializeMutable(Size,Size)
	BMChecked.InitializeMutable(Size,Size)
	BMDisabled.InitializeMutable(Size,Size)
	'Draw Enabled State
	Dim CNV As Canvas
	CNV.Initialize2(BMEnabled)
	Dim Rect1 As Rect
	Rect1.Initialize(Padding ,Padding ,Size - Padding ,Size - Padding)
	CNV.DrawRect(Rect1,BoxColor,False,BoxWidth)
	Dim Enabled,Checked,Disabled As BitmapDrawable
	Enabled.Initialize(BMEnabled)
	'Draw Selected state
	Dim CNV1 As Canvas
	CNV1.Initialize2(BMChecked)
	If TickChar = "Fill" Then
		CNV1.DrawRect(Rect1,TickColor,True,BoxWidth)
		CNV1.DrawRect(Rect1,BoxColor,False,BoxWidth)
	Else
		CNV1.DrawRect(Rect1,BoxColor,False,BoxWidth)
		'Start small and find the largest font that allows the tick to fit in the box
		Dim FontSize As Int = 6
		Do While CNV.MeasureStringHeight(TickChar,Typeface.DEFAULT,FontSize) < Size - (BoxWidth * 2) - (Padding * 2)
			FontSize = FontSize + 1
		Loop
		FontSize = FontSize - 1
		'Draw the TickChar centered in the box
		CNV1.DrawText(TickChar,Size/2,(Size + CNV.MeasureStringHeight(TickChar,Typeface.DEFAULT,FontSize))/2,Typeface.DEFAULT,FontSize,TickColor,"CENTER")
	End If
	Checked.Initialize(BMChecked)
	'Draw disabled State
	Dim CNV2 As Canvas
	CNV2.Initialize2(BMDisabled)
	CNV2.DrawRect(Rect1,DisabledColor,True,BoxWidth)
	CNV2.DrawRect(Rect1,BoxColor,False,BoxWidth)
	Disabled.Initialize(BMDisabled)

	'Add to the StateList Drawable
	SLD.AddState(SLD.State_Disabled,Disabled)
	SLD.AddState(SLD.State_Checked,Checked)
	SLD.AddState(SLD.State_Enabled,Enabled)
	SLD.AddCatchAllState(Enabled)
	'Add SLD to the Checkbox
	Dim JO As JavaObject = CB
	JO.RunMethod("setButtonDrawable",Array As Object(SLD))
End Sub



Public Sub BuildOptionsMenu(NoOctoConnection As Boolean) As Map
	
	Dim cs As CSBuilder 
	Dim m As Map : 	m.Initialize
	
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE30B)). _
				 Typeface(Typeface.DEFAULT).Append("   General Settings").PopAll,"gn")
				 
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE859)). _
				 Typeface(Typeface.DEFAULT).Append("   Power Settings").PopAll,"pw")
	
	If NoOctoConnection = False Then
		cs.Initialize
		m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE308)). _
				 	 Typeface(Typeface.DEFAULT).Append("   Octoprint Connection").PopAll,"oc")	
	End If
	
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24A)). _
				 Typeface(Typeface.DEFAULT).Append("   Functions Menu").PopAll,"fn")
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE8C1)). _
				 Typeface(Typeface.DEFAULT).Append("   Plugins Menu").PopAll,"plg")
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE24D)). _
				 Typeface(Typeface.DEFAULT).Append("   Read Log File").PopAll,"rt")
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE864)). _
				 Typeface(Typeface.DEFAULT).Append("   Check For Update").PopAll,"cup")
	cs.Initialize
	m.Put(cs.Append(" ").Typeface(Typeface.MATERIALICONS).VerticalAlign(6dip).Append(Chr(0xE85A)). _
				 Typeface(Typeface.DEFAULT).Append("   About Me!").PopAll,"ab")
	
	Return m
	
End Sub


