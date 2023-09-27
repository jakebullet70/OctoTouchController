B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/11/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgGeneralOptions"' 'ignore
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mGeneralDlg As sadPreferencesDialog
	Private prefHelper As sadPreferencesDialogHelper
	
End Sub

Public Sub Initialize() As Object
	
	mainObj = B4XPages.MainPage
	Return Me
	
End Sub

Public Sub Close_Me
	mGeneralDlg.Dialog.Close(xui.DialogResponse_Cancel)
End Sub

public Sub CreateDefaultFile
	
	If File.Exists(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE) = False Then
		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,  _
						CreateMap( "logall": "false", "logpwr": "false",  "logfiles": "false", "logoctokey": "false", "logrest": "false","syscmds": "false",  _
							"axesx": "false",  "axesy": "false", "axesz": "false","sboot":"false","syscmds":"false", "m600":"true","prpwr":"false","mpsd":"false"))					 
	End If
End Sub


Public Sub Show
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE)
	
	Dim h,w As Float '--- TODO - needs refactor
	If guiHelpers.gIsLandScape Then
		If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
			h = 62%y
		Else If guiHelpers.gScreenSizeAprox >= 8 Then
			h = 55%y
		Else '--- 4 to 5.9 inch
			h = 80%y
		End If
		w = 360dip
	Else
		h = 440dip
		w = guiHelpers.gWidth * .92
	End If
	
	mGeneralDlg.Initialize(mainObj.root, "General Settings", w, h)
	
	Dim s As String = File.ReadString(File.DirAssets,"dlggeneral.json")
	If guiHelpers.gIsPortrait Then s = s.Replace("Movement ","Move ") '--- portrait screen GUI fix
	mGeneralDlg.LoadFromJson(s)
	mGeneralDlg.SetEventsListener(Me,"dlgGeneral")
	
	
	prefHelper.Initialize(mGeneralDlg)
	If guiHelpers.gIsPortrait Then prefHelper.pDefaultFontSize = 17
	prefHelper.ThemePrefDialogForm
	mGeneralDlg.PutAtTop = False
	Dim RS As ResumableSub = mGeneralDlg.ShowDialog(Data, "OK", "CANCEL")
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast(gblConst.DATA_SAVED,1500)
		File.WriteMap(xui.DefaultFolder,gblConst.GENERAL_OPTIONS_FILE,Data)
		ProcessAutoBootFlag(Data.Get("sboot").As(Boolean))
		config.ReadGeneralCFG
		CallSub(mainObj.oPageCurrent,"Set_focus")
		CallSubDelayed(B4XPages.MainPage,"Build_RightSideMenu")
	End If
	
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	mainObj.pObjCurrentDlg1 = Null
	
End Sub


Private Sub dlgGeneral_IsValid (TempData As Map) As Boolean 'ignore
	Return True '--- all is good!
	'--- NOT USED BUT HERE IF NEEDED
	
'	Try
'		Dim number As Int = TempData.GetDefault("days", 1)
'		If number < 1 Or number > 14 Then
'			guiHelpers.Show_toast("Days must be between 1 and 14",1200)
'			pdlgLogging.ScrollToItemWithError("days")
'			Return False
'		End If
'		Return True
'	Catch
'		Log(LastException)
'	End Try
'	Return False

End Sub



Private Sub dlgGeneral_BeforeDialogDisplayed (Template As Object)
	prefHelper.SkinDialog(Template)
	
	For i = 0 To mGeneralDlg.PrefItems.Size - 1
		Dim pi As B4XPrefItem = mGeneralDlg.PrefItems.Get(i)
		If pi.ItemType = mGeneralDlg.TYPE_BOOLEAN Then
'			Dim ft As B4XFloatTextField = mGeneralDlg.CustomListView1.GetPanel(i).GetView(0).Tag
'			ft.TextField.Font = xui.CreateDefaultBoldFont(14)    'or whatever you want
'			'rest
		End If
	Next
	
End Sub


Private Sub ProcessAutoBootFlag(Enabled As Boolean)
	
	Dim fname As String = "autostart.bin"
	If Enabled Then
		If File.Exists(xui.DefaultFolder,fname) Then Return
		File.WriteString(xui.DefaultFolder,fname,"boot")
	Else
		fileHelpers.SafeKill(fname)
	End If
	
End Sub

