B4J=true
Group=B4X_EXT_CLASSES
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic
' Helper class for sadB4XPrefDialog V11.8
#Region VERSIONS 
' V1.0  Nov/9/2022	1st run.
#End Region

Sub Class_Globals
	Private xui As XUI
	Private prefdlg As sadPreferencesDialog
	Public dlgHelper As sadB4XDialogHelper
	Private dlg As B4XDialog
End Sub

Public Sub Initialize(oPrefDlg As sadPreferencesDialog)  
	prefdlg = oPrefDlg
	dlg = prefdlg.Dialog
	dlgHelper.Initialize(dlg)
End Sub


Public Sub ThemePrefDialogForm
	
	Try
		
		prefdlg.ItemsBackgroundColor = clrTheme.Background
		prefdlg.SeparatorBackgroundColor = clrTheme.BackgroundHeader
		prefdlg.SeparatorTextColor = clrTheme.txtAccent
		prefdlg.TextColor = clrTheme.txtNormal
		
		'prefdlg.Dialog.BackgroundColor = clrTheme.Background2
		'prefdlg.mBase.Color = clrTheme.Background2
		
		'prefdlg.Dialog.Base.Color = clrTheme.Background2
		'prefdlg.CustomListView1.sv.SetColorAndBorder(xui.Color_Transparent,1dip,xui.Color_blue,0dip)
		'prefdlg.mBase.SetColorAndBorder(xui.Color_Blue,2dip,xui.Color_White,5dip)
		
		'prefdlg.CustomListView1.AsView.Color = clrTheme.Background2
		'prefdlg.CustomListView1.GetBase.Color = clrTheme.Background2
		'prefdlg.CustomListView1. = clrTheme.Background2
		
		dlgHelper.ThemeDialogForm(prefdlg.Title.As(String))
		
	Catch
		Log(LastException)
	End Try
	

End Sub



'Private Sub SetTextColorB4XFloatTextField(views() As B4XFloatTextField)
'	
'	For Each o As B4XFloatTextField In views
'		o.TextField.TextColor = clrTheme.txtNormal
'		o.NonFocusedHintColor = clrTheme.txtAccent
'		o.HintColor = clrTheme.txtAccent
'		o.Update
'	Next
'	
'End Sub



Public Sub SkinDialog(Template As Object)
	
	Dim fnt0 As B4XFont = xui.CreateDefaultFont(20)
	'Dim mDlg As sadPreferencesDialog = prefdlg
	Try
		
		For i = 0 To prefdlg.PrefItems.Size - 1
			Dim pit As B4XPrefItem = prefdlg.PrefItems.Get(i)
			
			Select Case pit.ItemType
				Case prefdlg.TYPE_TEXT, prefdlg.TYPE_PASSWORD, prefdlg.TYPE_NUMBER, prefdlg.TYPE_DECIMALNUMBER, prefdlg.TYPE_MULTILINETEXT
					Dim ft As B4XFloatTextField = prefdlg.CustomListView1.GetPanel(i).GetView(0).Tag
					ft.TextField.Font = fnt0
					guiHelpers.SetTextColorB4XFloatTextField(Array As B4XFloatTextField(ft))
	
				Case prefdlg.TYPE_BOOLEAN
					Dim p As B4XView = prefdlg.CustomListView1.GetPanel(i).GetView(0)
					p.Font = fnt0
					
				Case prefdlg.TYPE_NUMERICRANGE
					Dim plmi As B4XPlusMinus = prefdlg.CustomListView1.GetPanel(i).GetView(0).tag
					plmi.MainLabel.Font = xui.CreateDefaultFont(22) '--- numeric spin label
					Dim p1 As B4XView = prefdlg.CustomListView1.GetPanel(i).GetView(1) '--- description lbl
					p1.Font = fnt0
					'plmi.ArrowsSize = 42  ''  NOT WORKING
					'plmi.Base_Resize(plmi.mBase.Width,plmi.mBase.Height)
					'plmi.lblMinus.Font =xui.CreateDefaultFont(40)
					
					
			End Select
	
		Next
		
	Catch
		Log(LastException)
	End Try
	
End Sub




'TODO
'https://www.b4x.com/android/forum/threads/preferencesdialog-shortoptions-width.143952/
Private Sub SetWidthItemSO (Pref As PreferencesDialog, Key As String, wwidth As Double)
	For i = 0 To Pref.PrefItems.Size - 1
		Dim pi As B4XPrefItem = Pref.PrefItems.Get(i)
		If pi.key = Key Then
			If pi.ItemType = Pref.TYPE_SHORTOPTIONS Then
				Dim Parent As B4XView = Pref.CustomListView1.GetPanel(i).GetView(1)
				Parent.Left = (Parent.Left + Parent.Width) - wwidth
				Parent.Width = wwidth
				Dim view As B4XView = Parent.GetView( 0)
				view.Width = Parent.Width
			Else
				Dim oldx As Double=Pref.CustomListView1.GetPanel(i).GetView(1).Left
				Dim oldw As Double=Pref.CustomListView1.GetPanel(i).GetView(1).Width
				Pref.CustomListView1.GetPanel(i).GetView(1).Left=(oldx+oldw)-wwidth
				Pref.CustomListView1.GetPanel(i).GetView(1).Width= wwidth
			End If
		End If
	Next
End Sub


'TODO
'https://www.b4x.com/android/forum/threads/solved-how-to-hide-cancel-confirm-buttons-in-textitem-of-the-b4xpreferencesdialog.116534/
Public Sub RemoveCancelConfirmBtnsinTextItem(p As PreferencesDialog)
	
	For i = 0 To p.PrefItems.Size - 1
	    Dim pi As B4XPrefItem = p.PrefItems.Get(i)
	    p.CustomListView1.AnimationDuration = 0
	    If pi.ItemType = p.TYPE_TEXT Then
	        Dim pnl As B4XView = p.CustomListView1.GetPanel(i)
	        Dim ft As B4XFloatTextField = pnl.GetView(0).Tag
	        ft.lblClear.Left = -100dip
			ft.lblV.Left = -100dip
		End If
	Next

End Sub


'TODO
'B4X Preference Dialog only as view (edit disable) 
'https://www.b4x.com/android/forum/threads/b4x-preference-dialog-only-as-view-edit-disable-in-order-to-show-only-the-value.143127/
'Private Sub ViewDialog(Item As Map, RowId As Long)
'	DateTime.DateFormat="dd-MM-yyyy"
'	Dim sf As Object =PrefDialog.ShowDialog(Item, "", "CHIUDI")
'	For i = 0 To PrefDialog.PrefItems.Size - 1
'		Dim pi As B4XPrefItem = PrefDialog.PrefItems.Get(i)
'		If pi.ItemType = PrefDialog.TYPE_TEXT  Then
'			Dim txt As B4XFloatTextField = PrefDialog.CustomListView1.GetPanel(i).GetView(0).Tag
'			txt.TextField.Enabled =False
'		End If
'		If pi.ItemType=PrefDialog.TYPE_BOOLEAN Then
'			Dim bool As B4XSwitch=PrefDialog.CustomListView1.GetPanel(i).GetView(1).Tag
'			bool.Enabled=False
'		End If
'	Next
'	SetTwoLabelsItemState(PrefDialog,"Data della Verifica",False) 'date
'	SetTwoLabelsItemState(PrefDialog,"Livello",False) 'options
'	SetTwoLabelsItemState(PrefDialog,"Esito della Verifica",False) 'options
'	SetTwoLabelsItemState(PrefDialog,"Prossima Verifica entro il",False) 'date
'	SetTwoLabelsItemState(PrefDialog,"Firma",False) 'eplanation
'        
'	For i = 0 To PrefDialog.PrefItems.Size - 1
'		Dim pi As B4XPrefItem = PrefDialog.PrefItems.Get(i)
'		If pi.ItemType = PrefDialog.TYPE_BOOLEAN Then
'			PrefDialog.CustomListView1.ResizeItem(i, 80dip)
'			Dim pnl As B4XView = PrefDialog.CustomListView1.GetPanel(i)
'			pnl.Height = pnl.Parent.Height
'			pnl.GetView(0).Height = pnl.Height - 20dip
'			pnl.GetView(0).TextSize=12
'			pnl.GetView(1).Top = 20dip
'		End If
'	Next
'    
'	Wait For (sf) Complete (Result As Int)
'
'End Sub
'
'Private Sub SetTwoLabelsItemState (Pref As PreferencesDialog, Key As String, Enabled As Boolean)
'	For i = 0 To Pref.CustomListView1.Size - 1
'		Dim pi As B4XPrefItem = Pref.CustomListView1.GetValue(i)
'		If pi.Key = Key Then
'			Pref.CustomListView1.GetPanel(i).GetView(0).Enabled = Enabled
'			Pref.CustomListView1.GetPanel(i).GetView(1).Enabled = Enabled
'		End If
'	Next
'End Sub
'
