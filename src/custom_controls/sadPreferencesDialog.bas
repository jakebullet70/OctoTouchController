B4J=true
Group=CUSTOM_CONTROLS
ModulesStructureVersion=1
Type=Class
Version=7.31
@EndOfDesignText@
' Tweaker:  sadLogic-JakeBullet70
#Region VERSIONS 
' My tweaks... (see TWEAKS comments)
' V. 1.1 	Aug/29/2022
'			Pulled from B4Xlib and added as internal class
'			Still uses assets from PrefDialog b4xlib
' V. 1.0 	Aug/12/2022
'			Fixed issue with PutAtTop forced as true
' V. Whatever, from B4x 11.8
#End Region
#Event: IsValid (TempData As Map) As Boolean
#Event: BeforeDialogDisplayed (Template As Object)
Sub Class_Globals
	Private xui As XUI
	Public mBase As B4XView
	Public CustomListView1 As CustomListView
	
	'--- TWEAKS
	'Type B4XPrefItem (Title As Object, ItemType As Int, Extra As Map, Key As String, Required As Boolean)
	'---
	
	Public PrefItems As List
	Public TYPE_BOOLEAN = 1, TYPE_TEXT = 2, TYPE_DATE = 3, TYPE_OPTIONS = 4, TYPE_COLOR = 5, _
		TYPE_SEPARATOR = 6, TYPE_NUMBER = 7, TYPE_PASSWORD = 8, TYPE_SHORTOPTIONS = 9, TYPE_DECIMALNUMBER = 10, TYPE_MULTILINETEXT = 11, _
		TYPE_TIME = 12, TYPE_NUMERICRANGE = 13, TYPE_EXPLANATION = 14 As Int
	Public DateTemplate As B4XDateTemplate
	Public LongTextTemplate As B4XLongTextTemplate
	Public Dialog As B4XDialog
	Private RESULT_SHOWING_NESTED_DIALOG As Int = 100
	Private NestedDialogItemIndex As Int
	Private mTitle As Object
	Public SearchTemplate As B4XSearchTemplate
	Private Template As Object
	Public ColorTemplate As B4XColorTemplate
	Private B4XComboBox1 As B4XComboBox
	Public const THEME_DARK = 1, THEME_LIGHT = 2 As Int
	Private mTheme As Int
	Public ItemsBackgroundColor As Int
	Public TextColor As Int
	Public SeparatorBackgroundColor, SeparatorTextColor As Int
	Private mCallback As Object
	Private mEventName As String
	Public DefaultHintFont As B4XFont
	Public DefaultHintLargeSize As Int
	'--- TWEAKS
	Public PutAtTop As Object = Null
	'---
End Sub

Public Sub Initialize (Parent As B4XView, Title As Object, Width As Int, Height As Int)
	Dialog.Initialize(Parent)
	Dialog.VisibleAnimationDuration = 0
	mTitle = Title
	mBase = xui.CreatePanel("mBase")
	mBase.SetLayoutAnimated(0, 0, 0, Width, Height)
	mBase.LoadLayout("ListTemplate")
	mBase.SetColorAndBorder(xui.Color_Transparent, 0, 0, 0)
	CustomListView1.sv.SetColorAndBorder(xui.Color_Transparent, 0, 0, 0)
	CustomListView1.PressedColor = xui.Color_Transparent
	PrefItems.Initialize
	SearchTemplate.Initialize
	DateTemplate.Initialize
	LongTextTemplate.Initialize
	LongTextTemplate.CustomListView1.PressedColor = 0
	Dialog.OverlayColor = xui.Color_Transparent
	#if B4J
	Dim sv As ScrollPane = CustomListView1.sv
	sv.StyleClasses.Add("b4xdialog")
	sv.InnerNode.StyleClasses.Add("b4xdialog")
	#end if
	#if B4i
	DefaultHintFont = xui.CreateFont(Font.CreateNew2("Helvetica", 15), 15)
	#else
	DefaultHintFont = xui.CreateDefaultBoldFont(16)
	#End If
	DefaultHintLargeSize = 16
	setTheme(THEME_DARK)
	
End Sub

Public Sub SetEventsListener(Callback As Object, EventName As String)
	mCallback = Callback
	mEventName = EventName
End Sub

Public Sub getTitle As Object
	Return mTitle
End Sub

Public Sub setTitle(o As Object)
	mTitle = o
End Sub

Public Sub KeyboardHeightChanged (Height As Int)
	If Dialog.Visible Then
	#if B4i
		If CustomListView1.AsView.Parent.IsInitialized = False Or CustomListView1.AsView.Parent.Parent.IsInitialized = False Then Return
		Dim p As View = CustomListView1.AsView.Parent.Parent
		Dim rel As Int = p.CalcRelativeKeyboardHeight(Height)
		If rel = 0 Then rel = p.Height
		CustomListView1.sv.Height = Min(rel - mBase.Top, mBase.Height)
	#else
	CustomListView1.sv.Height = Min(CustomListView1.AsView.Height, Height - _
		CustomListView1.AsView.Parent.Top - CustomListView1.AsView.Parent.Parent.Top)
	#End If
		For Each v As B4XView In CustomListView1.AsView.GetAllViewsRecursive
			If v.Tag Is B4XFloatTextField Then
				Dim f As B4XFloatTextField = v.Tag
				If f.Focused Then
					Dim index As Int = CustomListView1.GetItemFromView(f.mBase)
					CustomListView1.ScrollToItem(index)
				End If
			End If
		Next
	End If
End Sub

Public Sub BackKeyPressed As Boolean
	If Dialog.Visible Then
		Dialog.Close(xui.DialogResponse_Cancel)
		Return True
	End If
	Return False
End Sub

Public Sub LoadFromJson (Json As String)
	Dim p As JSONParser
	p.Initialize(Json)
	Dim m As Map = p.NextObject
	Dim theme As String = m.GetDefault("Theme", "Dark Theme")
	Select theme
		Case "Dark Theme"
			setTheme(THEME_DARK)
		Case "Light Theme"
			setTheme(THEME_LIGHT)
	End Select
	Dim items As List = m.Get("Items")
	For Each item As Map In items
		Dim key As String = item.Get("key")
		Dim title As String = item.Get("title")
		Dim required As Boolean = item.Get("required")
		Dim itemType As String = item.Get("type")
		Select itemType
			Case "Separator"
				AddSeparator(title)
			Case "Boolean"
				AddBooleanItem(key, title)
			Case "Text"
				AddTextItem(key, title)
			Case "Date"
				AddDateItem(key, title)
			Case "Short Options"
				AddShortOptionsItem(key, title, item.Get("options"))
			Case "Color"
				AddColorItem(key, title)
			Case "Number"
				AddNumberItem(key, title)
			Case "Password"
				AddPasswordItem(key, title)
			Case "Options"
				AddOptionsItem(key, title, item.Get("options"))
			Case "Decimal Number"
				AddDecimalNumberItem(key, title)
			Case "Multiline Text"
				Dim l As List = item.Get("options")
				If l.IsInitialized = False Or l.Size = 0 Or IsNumber(l.Get(0)) = False Then
					AddMultilineTextItem(key, title, 100dip)
				Else
					AddMultilineTextItem(key, title, DipToCurrent(l.Get(0)))
				End If
			Case "Time"
				AddTimeItem(key, title)
				Dim l As List = item.Get("options")
				If l.IsInitialized And l.Size > 0 Then
					Dim pi As B4XPrefItem = PrefItems.Get(PrefItems.Size - 1)
					pi.Extra.Put("24", l.Get(0) = "24")
				End If
				
			Case "Numeric Range"
				Dim l As List = item.Get("options")
				If l.IsInitialized = False Or l.Size < 3 Or IsNumber(l.Get(0)) = False Or IsNumber(l.Get(1)) = False Or IsNumber(l.Get(2)) = False Then
					AddNumericRangeItem(key, title, 0, 100, 1)
				Else
					AddNumericRangeItem(key, title, l.Get(0), l.Get(1), l.Get(2))
				End If
			Case "Explanation"
				Dim l As List = item.Get("options")
				Dim text As String
				If l.IsInitialized Then
					Dim sb As StringBuilder
					sb.Initialize
					For i = 0 To l.Size - 1
						If i > 0 Then sb.Append(CRLF)
						sb.Append(l.Get(i))
					Next
					text = sb.ToString
				End If
				AddExplanationItem(key, title, text)
		End Select
		Dim pi As B4XPrefItem = PrefItems.Get(PrefItems.Size - 1)
		pi.Required = required
	Next
End Sub

Public Sub AddOptionsItem (Key As String, Title As Object, Options As List)
		
	Dim pi As B4XPrefItem = CreatePrefItem(Title, TYPE_OPTIONS, Key)
	If Options.IsInitialized Then
		pi.Extra = CreateMap("options": Options)
	End If
	PrefItems.Add(pi)
End Sub

Public Sub AddShortOptionsItem (Key As String, Title As Object, Options As List)
	Dim pi As B4XPrefItem = CreatePrefItem(Title, TYPE_SHORTOPTIONS, Key)
	If Options.IsInitialized Then
		pi.Extra = CreateMap("options": Options)
	End If
	PrefItems.Add(pi)
End Sub

Public Sub AddBooleanItem (Key As String, Title As Object)
	PrefItems.Add(CreatePrefItem(Title, TYPE_BOOLEAN, Key))
End Sub

Public Sub AddTextItem (Key As String, Title As Object)
	PrefItems.Add(CreatePrefItem(Title, TYPE_TEXT, Key))
End Sub

Public Sub AddNumberItem (Key As String, Title As Object)
	PrefItems.Add(CreatePrefItem(Title, TYPE_NUMBER, Key))
End Sub

Public Sub AddDecimalNumberItem (Key As String, Title As Object)
	PrefItems.Add(CreatePrefItem(Title, TYPE_DECIMALNUMBER, Key))
End Sub

Public Sub AddMultilineTextItem (Key As String, Title As Object, Height As Int)
	Dim pi As B4XPrefItem = CreatePrefItem(Title, TYPE_MULTILINETEXT, Key)
	pi.Extra = CreateMap("height": Height)
	PrefItems.Add(pi)
End Sub


Public Sub AddNumericRangeItem (Key As String, Title As Object, RangeStart As Double, RangeEnd As Double, Interval As Double)
	Dim pi As B4XPrefItem = CreatePrefItem(Title, TYPE_NUMERICRANGE, Key)
	pi.Extra = CreateMap("start": RangeStart, "end": RangeEnd, "interval": Interval)
	PrefItems.Add(pi)
End Sub

Public Sub AddTimeItem (Key As String, Title As Object)
	Dim pi As B4XPrefItem = CreatePrefItem(Title, TYPE_TIME, Key)
	pi.Extra = CreateMap("24": False)
	PrefItems.Add(pi)
End Sub

Public Sub AddPasswordItem (Key As String, Title As Object)
	PrefItems.Add(CreatePrefItem(Title, TYPE_PASSWORD, Key))
End Sub

Public Sub AddDateItem (Key As String, Title As Object)
	PrefItems.Add(CreatePrefItem(Title, TYPE_DATE, Key))
End Sub

Public Sub AddColorItem(Key As String, Title As Object)
	If ColorTemplate.IsInitialized = False Then
		ColorTemplate.Initialize
	End If
	PrefItems.Add(CreatePrefItem(Title, TYPE_COLOR, Key))
End Sub

'The key can be empty.
Public Sub AddExplanationItem (Key As String, Title As Object, Text As Object)
	Dim pi As B4XPrefItem = CreatePrefItem(Title, TYPE_EXPLANATION, Key)
	pi.Extra = CreateMap("text": Text)
	PrefItems.Add(pi)
End Sub

Public Sub AddSeparator (Title As Object)
	PrefItems.Add(CreatePrefItem(Title, TYPE_SEPARATOR, ""))
End Sub

Private Sub CreatePrefItem(Title As Object, ItemType As Int, Key As String) As B4XPrefItem
	Dim pi As B4XPrefItem
	pi.Initialize
	pi.Title = Title
	pi.ItemType = ItemType
	pi.Key = Key
	Return pi
End Sub

'Example:<code>
'Dim Data As Map = CreateMap()
'Wait For (Preferences.ShowDialog(Data, "OK", "CANCEL")) Complete (Result As Int)
'If Result = xui.DialogResponse_Positive Then
'	
'End If</code>
Public Sub ShowDialog (Data As Map, Yes As Object, Cancel As Object) As ResumableSub
	If CustomListView1.Size = 0 Then
		Dim LastTextField As B4XFloatTextField
		For Each pi As B4XPrefItem In PrefItems
			Dim pnl As B4XView = CreateLayouts(pi)
			CustomListView1.Add (pnl, pi)
			If pnl.GetView(0).Tag Is B4XFloatTextField Then
				Dim tf As B4XFloatTextField = pnl.GetView(0).Tag
				If LastTextField.IsInitialized Then
					LastTextField.NextField = tf
				End If
				LastTextField = tf
			End If
		Next
		#if B4A
		'this sets ForceDone to True.
		If LastTextField.IsInitialized Then LastTextField.NextField = LastTextField
		#end if
		
		Dialog.InternalAddStubToCLVIfNeeded(CustomListView1, CustomListView1.DefaultTextBackgroundColor)
	End If
	FillData (Data)
	Dim ScrollViewOffset As Int 'ignore
	Do While True
		Dialog.Title = mTitle
		'--- TWEAKS
		If PutAtTop = Null Then 
			Dialog.PutAtTop = xui.IsB4A Or xui.IsB4i
		Else
			Dialog.PutAtTop = PutAtTop.As(Boolean)
		End If
		'---
		Dim rs As Object = Dialog.ShowTemplate(Me, Yes, "", Cancel)
		#if B4A
		If ScrollViewOffset > 0 Then
			Sleep(50)
			Dim sv As ScrollView = CustomListView1.sv
			sv.ScrollToNow(ScrollViewOffset)
		End If
		#End If
		RaiseBeforeDialogDisplayed(Me)
		Wait For (rs) Complete (Result As Int)
		ScrollViewOffset = CustomListView1.sv.ScrollViewOffsetY
		If Result <> RESULT_SHOWING_NESTED_DIALOG Then
			If Result = xui.DialogResponse_Positive Then
				If CommitChanges(Data) = False Then
					ScrollViewOffset = 0
					Continue
				End If
			End If
			Return Result
		Else
			Dim y As Object
			Dim c As Object = Cancel
			If Template = ColorTemplate Then 
				y = Yes 
			Else If Template = LongTextTemplate Then
				y = Yes
				c = ""
			Else 
				y = ""
			End If
			'--- TWEAKS
			If PutAtTop = Null Then 
				Dialog.PutAtTop = xui.IsB4A Or xui.IsB4i
			Else
				Dialog.PutAtTop = PutAtTop.As(Boolean)
			End If
			'---
			Dim rs As Object = Dialog.ShowTemplate(Template, y, "", c)
			RaiseBeforeDialogDisplayed(Template)
			Wait For (rs) Complete (Result As Int)
			If Result = xui.DialogResponse_Positive Then
				Dim lbl As B4XView = CustomListView1.GetPanel(NestedDialogItemIndex).GetView(1)
				Dim value As String
				If Template = DateTemplate Then
					value = DateTime.Date(DateTemplate.Date)
					lbl.Text = value
				Else if Template = SearchTemplate Then
					value = SearchTemplate.SelectedItem
					lbl.Text = value
				Else If Template = ColorTemplate Then
					value = ColorTemplate.SelectedColor
					SetLabelColor(lbl, value)
				End If
			End If
		End If
	Loop
	Return -1 'never happens
End Sub

Private Sub RaiseBeforeDialogDisplayed (Temp As Object)
	If mEventName <> "" And  xui.SubExists(mCallback, mEventName & "_BeforeDialogDisplayed", 1) Then
		CallSub2(mCallback, mEventName & "_BeforeDialogDisplayed", Temp)
	End If
End Sub


Public Sub GetPanel (Dialog1 As B4XDialog) As B4XView
	Return mBase
End Sub

Private Sub Show (Dialog1 As B4XDialog) 'ignore
	
End Sub

Public Sub Clear
	CustomListView1.Clear
	PrefItems.Clear
End Sub


Private Sub FillData (Data As Map)
	For i = 0 To CustomListView1.Size - 1
		Dim Item As CLVItem = CustomListView1.GetRawListItem(i)
		If (Item.Value Is B4XPrefItem) = False Then Exit
		Dim PrefItem As B4XPrefItem = Item.Value
		Dim ItemPanel As B4XView = Item.Panel.GetView(0)
		Select PrefItem.ItemType
			Case TYPE_BOOLEAN
				Dim switch As B4XSwitch = ItemPanel.GetView(1).Tag
				switch.Value = GetPrefItemValue(PrefItem, False, Data)
			Case TYPE_TEXT, TYPE_PASSWORD, TYPE_NUMBER, TYPE_DECIMALNUMBER, TYPE_MULTILINETEXT
				Dim ft As B4XFloatTextField = ItemPanel.GetView(0).Tag
				ft.Text = GetPrefItemValue(PrefItem, "", Data)
			Case TYPE_DATE
				ItemPanel.GetView(1).Text = DateTime.Date(GetPrefItemValue(PrefItem, DateTime.Now, Data))
			Case TYPE_OPTIONS
				ItemPanel.GetView(1).Text = GetPrefItemValue(PrefItem, "", Data)
			Case TYPE_SHORTOPTIONS
				Dim cmb As B4XComboBox = ItemPanel.GetView(1).Tag
				Dim options As List = PrefItem.Extra.Get("options")
				cmb.SelectedIndex = Max(0, options.IndexOf(GetPrefItemValue(PrefItem, "", Data)))
			Case TYPE_COLOR
				SetLabelColor(ItemPanel.GetView(1), GetPrefItemValue(PrefItem, xui.Color_Red, Data))
				ItemPanel.GetView(2).Text = "Pick"
			Case TYPE_TIME
				Dim pmHours As B4XPlusMinus = ItemPanel.GetView(0).Tag
				Dim pmMinutes As B4XPlusMinus = ItemPanel.GetView(1).Tag
				Dim pmAMPM As B4XPlusMinus = ItemPanel.GetView(2).Tag
				Dim p As Period
				p = GetPrefItemValue(PrefItem, p, Data)
				Dim hour As Int = p.Hours
				Dim m As String
				If PrefItem.Extra.GetDefault("24", False) = False Then
					If hour <= 11 Then
						m = "am"
					Else
						m = "pm"
						hour = hour - 12
					End If
					If hour = 0 Then hour = 12
				End If
				pmHours.SelectedValue = hour
				pmMinutes.SelectedValue = p.Minutes
				pmAMPM.SelectedValue = m
			Case TYPE_SEPARATOR, TYPE_EXPLANATION
			Case TYPE_NUMERICRANGE
				Dim pm As B4XPlusMinus = ItemPanel.GetView(0).Tag
				pm.SelectedValue = GetPrefItemValue(PrefItem, 0, Data)
			Case Else
				Log("Unknown type: " & PrefItem.ItemType)
		End Select
	Next
End Sub

Private Sub SetLabelColor(lbl As B4XView, clr As Int)
	Dim ft As B4XFloatTextField = lbl.Parent.GetView(0).Tag
	ft.Text = ColorToHex(clr)
	lbl.SetColorAndBorder(clr, 1dip, Dialog.BorderColor, 5dip)
End Sub

Private Sub GetPrefItemValue (PrefItem As B4XPrefItem, DefaultValue As Object, Data As Map) As Object
	Return Data.GetDefault(PrefItem.Key, DefaultValue)
End Sub

Public Sub getTheme As Int
	Return mTheme
End Sub

Public Sub setTheme (t As Int)
	If t <> mTheme Then
		mTheme = t
		CustomListView1.Clear
		Dim DividerColor As Int
		Select mTheme
			Case THEME_DARK
				ItemsBackgroundColor = 0xFF626262
				SeparatorBackgroundColor = 0xFFC0C0C0
				SeparatorTextColor = xui.Color_Black
				TextColor = xui.Color_White
				DividerColor = 0xFF464646
				Dialog.BackgroundColor = 0xFF555555
				Dialog.ButtonsColor = 0xFF555555
				Dialog.BorderColor = 0xff000000
				Dialog.ButtonsTextColor = 0xFF89D5FF
				DateTemplate.DaysInWeekColor = xui.Color_Gray
				DateTemplate.SelectedColor = 0xFF0BA29B
			Case THEME_LIGHT
				ItemsBackgroundColor = xui.Color_White
				SeparatorBackgroundColor = 0xFFD0D0D0
				SeparatorTextColor = 0xFF4E4F50
				TextColor = 0xFF5B5B5B
				DividerColor = 0xFFDFDFDF
				Dialog.BackgroundColor = xui.Color_White
				Dialog.ButtonsColor = xui.Color_White
				Dialog.BorderColor = xui.Color_Gray
				Dialog.ButtonsTextColor = 0xFF007DC3
				DateTemplate.DaysInWeekColor = xui.Color_Black
				DateTemplate.SelectedColor = 0xFF39D7CE
				
		End Select
		SearchTemplate.SearchField.TextField.TextColor = TextColor
		SearchTemplate.SearchField.NonFocusedHintColor = TextColor
		Dialog.BorderCornersRadius = 0
		Dialog.BorderWidth = 1dip
		DateTemplate.HighlightedColor = 0xFF00CEFF
		DateTemplate.DaysInMonthColor = TextColor
		DateTemplate.lblMonth.TextColor = TextColor
		DateTemplate.lblYear.TextColor = TextColor
		For Each clv As CustomListView In Array(CustomListView1, SearchTemplate.CustomListView1, LongTextTemplate.CustomListView1)
			clv.sv.ScrollViewInnerPanel.Color = DividerColor
			clv.sv.Color = Dialog.BackgroundColor
			clv.DefaultTextBackgroundColor = ItemsBackgroundColor
			clv.DefaultTextColor = TextColor
			#if B4J
			Dim sv As Node = clv.sv
			sv.StyleClasses.Clear
			sv.StyleClasses.Add("b4xdialog")
			If mTheme = THEME_LIGHT Then sv.StyleClasses.Add("b4xdialoglight")
			#End if
		Next
		For Each b As B4XView In Array(DateTemplate.btnMonthLeft, DateTemplate.btnMonthRight, DateTemplate.btnYearLeft, DateTemplate.btnYearRight)
			b.Color = xui.Color_Transparent
			b.TextColor = TextColor
		#if B4i
			Dim no As NativeObject = b
			no.RunMethod("setTitleColor:forState:", Array(no.ColorToUIColor(TextColor), 0))
		#End If
		Next
	End If
End Sub

Private Sub CreateLayouts (PrefItem As B4XPrefItem) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	p.Width = CustomListView1.sv.ScrollViewContentWidth
	p.Height = 50dip
	Select PrefItem.ItemType
		Case TYPE_BOOLEAN
			p.LoadLayout("booleanitem")
			Dialog.InternalSetTextOrCSBuilderToLabel(p.GetView(0), PrefItem.Title)
			p.GetView(0).TextColor = TextColor
		Case TYPE_MULTILINETEXT
			p.Height = PrefItem.Extra.Get("height")
			p.LoadLayout("textitemmulti")
			Dim ft As B4XFloatTextField = p.GetView(0).Tag
			ft.HintText = PrefItem.Title
			ft.HintFont = DefaultHintFont
			ft.LargeLabelTextSize = DefaultHintLargeSize
			ft.Update
		Case TYPE_TIME
			CreateTimeItem(PrefItem, p)
		Case TYPE_NUMERICRANGE
			CreateNumericRangeItem(PrefItem, p)
		Case TYPE_TEXT, TYPE_PASSWORD, TYPE_NUMBER, TYPE_DECIMALNUMBER
			p.Height = 60dip
			If PrefItem.ItemType = TYPE_PASSWORD Then
				p.LoadLayout("passworditem")
			Else
				p.LoadLayout("textitem")
				Dim ft As B4XFloatTextField = p.GetView(0).Tag
				If PrefItem.ItemType = TYPE_NUMBER Then
					#if B4A
					Dim et As EditText = ft.TextField
					et.InputType = et.INPUT_TYPE_NUMBERS
					#else if B4I
					Dim ttf As TextField = ft.TextField
					ttf.KeyboardType = ttf.TYPE_NUMBER_PAD
					#End If
				Else If PrefItem.ItemType = TYPE_DECIMALNUMBER Then
					#if B4A
					Dim et As EditText = ft.TextField
					et.InputType = et.INPUT_TYPE_DECIMAL_NUMBERS
					#else if B4I
					Dim ttf As TextField = ft.TextField
					ttf.KeyboardType = ttf.TYPE_NUMBERS_AND_PUNCTUATIONS
					#End If
				End If
			End If
			
			Dim ft As B4XFloatTextField = p.GetView(0).Tag
			ft.HintText = PrefItem.Title
			ft.HintFont = DefaultHintFont
			ft.LargeLabelTextSize = DefaultHintLargeSize
			ft.Update
		Case TYPE_DATE
			TwoLabelsLayout("lblDate", p, PrefItem)
		Case TYPE_OPTIONS
			TwoLabelsLayout("lblOptions", p, PrefItem)
		Case TYPE_SHORTOPTIONS
			p.LoadLayout("shortoptions")
			p.GetView(0).TextColor = TextColor
			Dim original As List = PrefItem.Extra.Get("options")
			#if B4i
			Dim no As NativeObject = B4XComboBox1.mBtn
			B4XComboBox1.mBtn.Font = xui.CreateDefaultBoldFont(16)
			no.RunMethod("setTitleColor:forState:", Array(no.ColorToUIColor(TextColor), 0))
			no.SetField("contentHorizontalAlignment", 2) 'right
			#end if
			#if B4A
			Dim spnr As Spinner = B4XComboBox1.cmbBox
			spnr.TextColor = TextColor
			spnr.DropdownBackgroundColor = Dialog.BackgroundColor
			SetBackgroundTintList(spnr, xui.Color_Gray, TextColor)
			Dim options As List
			options.Initialize
			Dim cs As CSBuilder
			For Each opt As String In original
				options.Add(cs.Initialize.Alignment("ALIGN_OPPOSITE").Typeface(Typeface.DEFAULT_BOLD).Append(opt).PopAll)
			Next
			B4XComboBox1.SetItems(options)
			#else
			B4XComboBox1.SetItems(original)
			#End If
			Dialog.InternalSetTextOrCSBuilderToLabel(p.GetView(0), PrefItem.Title)
		Case TYPE_COLOR
			p.Height = 60dip
			p.LoadLayout("coloritem")
			Dim tf As B4XFloatTextField = p.GetView(0).Tag
			tf.HintFont = DefaultHintFont
			tf.LargeLabelTextSize = DefaultHintLargeSize
			tf.HintText = PrefItem.Title
			tf.Update
			#if B4A
			Dim ed As EditText = tf.TextField
			ed.InputType = Bit.Or(0x00000080, 0x00080000)
			#End If
		Case TYPE_EXPLANATION
			TwoLabelsLayout("lblExplanation", p, PrefItem)
		Case TYPE_SEPARATOR
			Dim lbl As Label
			lbl.Initialize("")
			Dim xlbl As B4XView = lbl
			xlbl.SetTextAlignment("CENTER", "CENTER")
			xlbl.TextColor = SeparatorTextColor
			xlbl.Font = xui.CreateDefaultBoldFont(14)
			xlbl.Color = SeparatorBackgroundColor
			p.Height = 30dip
			p.AddView(xlbl, 0, 0, p.Width, p.Height)
			Dialog.InternalSetTextOrCSBuilderToLabel(xlbl, PrefItem.Title)
			PrefItem.Required = False
	End Select
	If PrefItem.Required Then
		Dim rlbl As Label
		rlbl.Initialize("")
		Dim xlbl As B4XView = rlbl
		xlbl.Text = "*"
		xlbl.TextColor = xui.Color_Red
		xlbl.TextSize = 11
		xlbl.SetTextAlignment("TOP", "LEFT")
		p.AddView(xlbl, 01dip, 0dip, 10dip, 10dip)
	End If
	p.Color = ItemsBackgroundColor
	If mTheme <> THEME_DARK Then
		If p.GetView(0).Tag Is B4XFloatTextField Then
			Dim tf As B4XFloatTextField = p.GetView(0).Tag
			tf.TextField.TextColor = TextColor
			tf.NonFocusedHintColor = TextColor
			tf.Update
			If tf.lblClear.IsInitialized Then tf.lblClear.TextColor = TextColor
			If tf.lblV.IsInitialized Then tf.lblV.TextColor = TextColor
		End If
	End If
	Return p
End Sub

Private Sub CreateNumericRangeItem (PrefItem As B4XPrefItem, p As B4XView)
	p.LoadLayout("numericrange")
	Dim pm As B4XPlusMinus = p.GetView(0).Tag
	pm.SetNumericRange(PrefItem.Extra.Get("start"), PrefItem.Extra.Get("end"), PrefItem.Extra.Get("interval"))
	pm.Formatter.GetDefaultFormat.MaximumFractions = 2
	Dialog.InternalSetTextOrCSBuilderToLabel(p.GetView(1), PrefItem.Title)
	For Each v As B4XView In p.GetAllViewsRecursive
		If v Is Label Then v.TextColor = TextColor
	Next
End Sub

Private Sub CreateTimeItem (PrefItem As B4XPrefItem, p As B4XView)
	p.Height = 60dip
	Dim is24 As Boolean = PrefItem.Extra.GetDefault("24", False)
	If is24 Then
		p.LoadLayout("timeitem24")
	Else
		p.LoadLayout("timeitem")
	End If
	Dim pmHours As B4XPlusMinus = p.GetView(0).Tag
	pmHours.RapidPeriod2 = 100
	Dim pmMinutes As B4XPlusMinus = p.GetView(1).Tag
	Dim pmAMPM As B4XPlusMinus = p.GetView(2).Tag
	If xui.IsB4J = False Then
		Dim clr As Int = CustomListView1.sv.ScrollViewInnerPanel.Color
		pmHours.mBase.SetColorAndBorder(xui.Color_Transparent, 1dip, clr, 0)
		pmMinutes.mBase.SetColorAndBorder(xui.Color_Transparent, 1dip, clr, 0)
		pmAMPM.mBase.SetColorAndBorder(xui.Color_Transparent, 1dip, clr, 0)
	End If
	
	If is24 Then
		pmHours.SetNumericRange(0, 23, 1)
	Else
		pmHours.SetNumericRange(1, 12, 1)
	End If
	pmMinutes.SetNumericRange(0, 59, 1)
	pmMinutes.Formatter.GetDefaultFormat.MinimumIntegers = 2
	
	pmAMPM.SetStringItems(Array("am", "pm"))
	Dialog.InternalSetTextOrCSBuilderToLabel(p.GetView(3), PrefItem.Title)
	For Each v As B4XView In p.GetAllViewsRecursive
		If v Is Label Then v.TextColor = TextColor
	Next
End Sub

'return True if valid
Private Sub CommitChanges (Data As Map) As Boolean
	Dim Temp As Map
	Temp.Initialize
	For i = 0 To CustomListView1.Size - 1
		Dim Item As CLVItem = CustomListView1.GetRawListItem(i)
		If (Item.Value Is B4XPrefItem) = False Then Exit
		Dim PrefItem As B4XPrefItem = Item.Value
		Dim ItemPanel As B4XView = Item.Panel.GetView(0)
		Dim Required As Boolean = PrefItem.Required
		Dim Value As Object
		Select PrefItem.ItemType
			Case TYPE_BOOLEAN
				Dim switch As B4XSwitch = ItemPanel.GetView(1).Tag
				Value = switch.Value
			Case TYPE_TEXT, TYPE_PASSWORD, TYPE_MULTILINETEXT
				Dim ft As B4XFloatTextField = ItemPanel.GetView(0).Tag
				Value = ft.Text
				
			Case TYPE_NUMBER, TYPE_DECIMALNUMBER
				Dim ft As B4XFloatTextField = ItemPanel.GetView(0).Tag
				Dim n As Double
				If ft.Text <> "" Then
					If IsNumber(ft.Text) Then
						n = ft.Text
						If PrefItem.ItemType = TYPE_NUMBER Then
							Dim n2 As Int = n
							Value = n2
						Else
							Value = n
						End If
					Else
						GoToItem(i)
						Return False
					End If
				Else
					Value = ""
				End If
			Case TYPE_DATE
				Value = DateTime.DateParse(ItemPanel.GetView(1).Text)
			Case TYPE_TIME
				Dim pmHours As B4XPlusMinus = ItemPanel.GetView(0).Tag
				Dim pmMinutes As B4XPlusMinus = ItemPanel.GetView(1).Tag
				Dim pmAMPM As B4XPlusMinus = ItemPanel.GetView(2).Tag
				Dim p As Period
				p.Initialize
				p.Hours = pmHours.SelectedValue
				If PrefItem.Extra.GetDefault("24", False) = False Then
					If p.Hours = 12 Then p.Hours = 0
					If pmAMPM.SelectedValue = "pm" Then p.Hours = p.Hours + 12
				End If
				p.Minutes = pmMinutes.SelectedValue
				Value = p
			Case TYPE_NUMERICRANGE
				Dim pm As B4XPlusMinus = ItemPanel.GetView(0).Tag
				Value = pm.SelectedValue
			Case TYPE_OPTIONS
				Value = ItemPanel.GetView(1).Text
			Case TYPE_SHORTOPTIONS
				Dim cmb As B4XComboBox = ItemPanel.GetView(1).Tag
				If cmb.SelectedIndex > -1 Then Value = cmb.GetItem(cmb.SelectedIndex) Else Value = ""
			Case TYPE_COLOR
				Value = ItemPanel.GetView(1).Color
			Case TYPE_SEPARATOR, TYPE_EXPLANATION
				Continue
		End Select
		If Value = "" Then
			If Required Then
				GoToItem(i)
				Return False
			Else
				Continue
			End If
		End If
		Temp.Put(PrefItem.Key, Value)
	Next
	If mEventName <> "" And xui.SubExists(mCallback, mEventName  & "_IsValid", 1) Then
		Dim Valid As Boolean = CallSub2(mCallback, mEventName & "_IsValid", Temp)
		If Valid = False Then Return False
	End If
	For Each key As String In Temp.Keys
		Data.Put(key, Temp.Get(key))
	Next
	Return True
End Sub

'Scrolls to the item and shows a "shake" animation.
Public Sub ScrollToItemWithError (key As String)
	For i = 0 To CustomListView1.Size - 1
		Dim Item As CLVItem = CustomListView1.GetRawListItem(i)
		Dim PrefItem As B4XPrefItem = Item.Value
		If PrefItem.Key = key Then 
			GoToItem(i)
			Return
		End If
	Next
End Sub

Private Sub GoToItem (i As Int)
	CustomListView1.JumpToItem(i)
	Dim p As B4XView = CustomListView1.GetPanel(i)
	For i = 0 To 3
		Dim duration As Int = 100 - i * 20
		p.SetLayoutAnimated(duration, -10dip, 0, p.Width, p.Height)
		Sleep(duration)
		p.SetLayoutAnimated(duration, 10dip, 0, p.Width, p.Height)
		Sleep(duration)
	Next
	p.SetLayoutAnimated(50, 0, 0, p.Width, p.Height)
End Sub

Private Sub TwoLabelsLayout (EventName As String, p As B4XView, PrefItem As B4XPrefItem)
	Dim lblTitle As B4XView = CreateLabel(EventName)
	lblTitle.SetTextAlignment("CENTER", "LEFT")
	lblTitle.TextColor = TextColor
	Dim fnt As B4XFont = xui.CreateDefaultBoldFont(16)
	lblTitle.Font = fnt
	Dialog.InternalSetTextOrCSBuilderToLabel(lblTitle, PrefItem.Title)
	p.AddView(lblTitle, 10dip, 10dip, p.Width - 110dip, 30dip)
	Dim lblDate As B4XView = CreateLabel(EventName)
	lblDate.TextColor = TextColor
	lblDate.SetTextAlignment("CENTER", "RIGHT")
	lblDate.Font = fnt
	p.AddView(lblDate, p.Width - 108dip, 10dip, 98dip, 30dip)
End Sub

#if B4J
Private Sub lblOptions_MouseClicked (EventData As MouseEvent)
	EventData.Consume
#else
Private Sub lblOptions_Click
#end if
	NestedDialogItemIndex = CustomListView1.GetItemFromView(Sender)
	Dim pref As B4XPrefItem = CustomListView1.GetValue(NestedDialogItemIndex)
	Dialog.Title = pref.Title
	If pref.Extra.ContainsKey("index") Then
		SearchTemplate.SetIndex(pref.Extra.Get("index"))
	Else
		pref.Extra.Put("index", SearchTemplate.SetItems(pref.Extra.Get("options")))
	End If
	SearchTemplate.SelectedItem = CustomListView1.GetPanel(NestedDialogItemIndex).GetView(1).Text
	Template = SearchTemplate
	Dialog.Close(RESULT_SHOWING_NESTED_DIALOG)
End Sub

#if B4J
Private Sub lblDate_MouseClicked (EventData As MouseEvent)
	EventData.Consume
#else
Private Sub lblDate_Click
#end If
	NestedDialogItemIndex = CustomListView1.GetItemFromView(Sender)
	Dim pref As B4XPrefItem = CustomListView1.GetValue(NestedDialogItemIndex)
	Dialog.Title = pref.Title
	DateTemplate.Date = DateTime.DateParse(CustomListView1.GetPanel(NestedDialogItemIndex).GetView(1).Text)
	Template = DateTemplate
	Dialog.Close(RESULT_SHOWING_NESTED_DIALOG)
End Sub

#if B4J
Private Sub lblColors_MouseClicked (EventData As MouseEvent)
	EventData.Consume
#else
Private Sub lblColors_Click
#end if
	NestedDialogItemIndex = CustomListView1.GetItemFromView(Sender)
	Dim pref As B4XPrefItem = CustomListView1.GetValue(NestedDialogItemIndex)
	Dialog.Title = pref.Title
	ColorTemplate.SelectedColor = CustomListView1.GetPanel(NestedDialogItemIndex).GetView(1).Color
	Template = ColorTemplate
	Dialog.Close(RESULT_SHOWING_NESTED_DIALOG)
End Sub

#if B4J
Private Sub lblExplanation_MouseClicked (EventData As MouseEvent)
	EventData.Consume
#else
Private Sub lblExplanation_Click
#end if
	NestedDialogItemIndex = CustomListView1.GetItemFromView(Sender)
	Dim pref As B4XPrefItem = CustomListView1.GetValue(NestedDialogItemIndex)
	Dialog.Title = pref.Title
	LongTextTemplate.Text = pref.Extra.Get("text")
	Template = LongTextTemplate
	Dialog.Close(RESULT_SHOWING_NESTED_DIALOG)
End Sub

Private Sub CreateLabel(EventName As String) As B4XView
	Dim lbl As Label
	lbl.Initialize(EventName)
	Return lbl
End Sub

'Sets the options of a preference item
Public Sub SetOptions (Key As String, Options As List)
	Dim pi As B4XPrefItem = GetPrefItem(Key)
	If pi.Extra.IsInitialized = False Then
		pi.Extra.Initialize
	End If
	pi.Extra.Put("options", Options)
End Sub

Public Sub SetExplanation (Key As String, Explanation As Object)
	GetPrefItem(Key).Extra.Put("text", Explanation)
End Sub

'Gets the B4XPrefItem with the given key.
Public Sub GetPrefItem (Key As String) As B4XPrefItem
	For Each pi As B4XPrefItem In PrefItems
		If pi.Key = Key Then Return pi
	Next
	Return Null
End Sub

Private Sub DialogClosed(Result As Int) 'ignore
	
End Sub


Private Sub B4XSwitch1_ValueChanged (Value As Boolean)
	
End Sub

Private Sub B4XComboBox1_SelectedIndexChanged (Index As Int)
	
End Sub

#if B4A
Private Sub SetBackgroundTintList(View As View,Active As Int, Enabled As Int)
	Dim States(2,1) As Int
	States(0,0) = 16842908     'Active
	States(1,0) = 16842910    'Enabled
	Dim Color(2) As Int = Array As Int(Active,Enabled)
	Dim CSL As JavaObject
	CSL.InitializeNewInstance("android.content.res.ColorStateList",Array As Object(States,Color))
	Dim jo As JavaObject
	jo.InitializeStatic("android.support.v4.view.ViewCompat")
	jo.RunMethod("setBackgroundTintList", Array(View, CSL))
End Sub
#End If

Private Sub tfColorCode_EnterPressed
	Dim ft As B4XFloatTextField = Sender
	Dim clr() As Int = HexToColor(ft.Text)
	Dim index As Int = CustomListView1.GetItemFromView(ft.mBase)
	Dim lbl As B4XView = CustomListView1.GetPanel(index).GetView(1)
	If clr.Length = 1 Then
		SetLabelColor(lbl, clr(0))
	Else
		ft.Text = ColorToHex(lbl.Color)
	End If
End Sub

Private Sub ColorToHex(clr As Int) As String
	Dim bc As ByteConverter
	Return bc.HexFromBytes(bc.IntsToBytes(Array As Int(clr)))
End Sub

Private Sub HexToColor(Hex As String) As Int()
	Dim bc As ByteConverter
	Hex = Hex.ToLowerCase
	If Hex.StartsWith("#") Then
		Hex = Hex.SubString(1)
	Else If Hex.StartsWith("0x") Then
		Hex = Hex.SubString(2)
	End If
	If Hex.Length = 6 Then Hex = "ff" & Hex
	
	Dim res() As Int
	If Regex.IsMatch("[0-9a-f]{8}", Hex) = False Then Return res
	Dim ints() As Int = bc.IntsFromBytes(bc.HexToBytes(Hex))
	Return ints
End Sub

