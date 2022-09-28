B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/20/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgZLEDSetup"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mDlg As sadPreferencesDialog
	Private mDataFile As String
	Private mCaption As String
	
End Sub

Public Sub Initialize(mobj As B4XMainPage,  caption As String,dataFile As String)
	
	mMainObj   = mobj
	mDataFile = dataFile
	mCaption  = caption
	
End Sub

Public Sub CreateDefaultFile
	
	If File.Exists(xui.DefaultFolder,mDataFile) = False Then
		If mDataFile.ToLowerCase.Contains("zled") Then
			
			File.WriteMap(xui.DefaultFolder,mDataFile, CreateMap(gblConst.ZLED_CTRL_ON: "false", _
						 gblConst.ZLED_ENDPOINT: "/api/plugin/wled", _
						 gblConst.ZLED_CMD_ON: "lights_on", _
						 gblConst.ZLED_CMD_OFF: "lights_off"))
			
		Else
			
			File.WriteMap(xui.DefaultFolder,mDataFile, CreateMap(gblConst.ZLED_CTRL_ON: "false", _
						 gblConst.ZLED_ENDPOINT: "/api/plugin/ws281x_led_status", _
						 gblConst.ZLED_CMD_ON: "lights_on", _
						 gblConst.ZLED_CMD_OFF: "lights_off"))
			
		End If
						 
	End If

End Sub

Public Sub Show
	
	'--- show info about setting octoprint plugins first TODO, same code as in dlgPsuSetup
	If Starter.kvs.GetDefault("ledWarning",False).As(Boolean) = False Then
		Dim mb As dlgMsgBox
		mb.Initialize(mMainObj.root,"Information",580dip,260dip,False)
		mb.SetAsOptionalMsgBox("ledWarning")
		Wait For (mb.Show(guiHelpers.GetOctoPluginWarningTxt, _
					gblConst.MB_ICON_INFO,"OK","","")) Complete (Result As Int)
	End If
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,mDataFile)
	
	Dim h As Float
	If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
		h = 52%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		h = 45%y
	Else '--- 4 to 5.9 inch
		h = 70%y
	End If
	
	mDlg.Initialize(mMainObj.root, mCaption, 360dip, h)
	mDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgSimpleApiOnOff.json"))
	mDlg.SetEventsListener(Me,"dlgSimple")
	
	guiHelpers.ThemePrefDialogForm(mDlg)
	If guiHelpers.gScreenSizeAprox > 6.5 Then
		mDlg.PutAtTop = False
	End If
	Dim RS As ResumableSub = mDlg.ShowDialog(Data, "OK", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mDlg.Dialog)
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast("General Data Saved",1500)
		File.WriteMap(xui.DefaultFolder,mDataFile,Data)
		If mDataFile.ToLowerCase.Contains("zled") Then
			config.ReadZLED_CFG
		Else
			config.ReadWS281_CFG
		End If
		CallSub(mMainObj.oPageCurrent,"Set_focus")
	End If
	
End Sub


Private Sub dlgSimple_IsValid (TempData As Map) As Boolean 'ignore
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



Private Sub dlgSimple_BeforeDialogDisplayed (Template As Object)
	
	Try
		
		For i = 0 To mDlg.PrefItems.Size - 1
			Dim pit As B4XPrefItem = mDlg.PrefItems.Get(i)
			
			Select Case pit.ItemType
				Case mDlg.TYPE_TEXT, mDlg.TYPE_PASSWORD, mDlg.TYPE_NUMBER, mDlg.TYPE_DECIMALNUMBER, mDlg.TYPE_MULTILINETEXT
					Dim ft As B4XFloatTextField = mDlg.CustomListView1.GetPanel(i).GetView(0).Tag
					ft.TextField.Font = xui.CreateDefaultFont(20)
	
				Case mDlg.TYPE_BOOLEAN
					Dim p As B4XView = mDlg.CustomListView1.GetPanel(i).GetView(0)
					p.Font = xui.CreateDefaultFont(20)
				
			End Select
	
		Next
		
	Catch
		Log(LastException)
	End Try
	
End Sub



