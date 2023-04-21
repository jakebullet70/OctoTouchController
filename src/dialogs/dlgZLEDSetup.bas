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
	
	Private const mModule As String = "dlgZLEDSetup" 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	Private mDlg As sadPreferencesDialog
	Private mDataFile As String
	Private mCaption As String
	Private prefHelper As sadPreferencesDialogHelper
	
End Sub

Public Sub Initialize(caption As String,dataFile As String)
	
	mMainObj   = B4XPages.MainPage
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
	If Main.kvs.GetDefault("ledWarning",False).As(Boolean) = False Then
		Dim mb As dlgMsgBox
		mb.Initialize(mMainObj.root,"Information",IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth-40dip),260dip,False)
		mb.SetAsOptionalMsgBox("ledWarning")
		Dim gui As guiMsgs : gui.Initialize
		Wait For (mb.Show(gui.GetOctoPluginWarningTxt, _
					gblConst.MB_ICON_INFO,"","","OK")) Complete (Result As Int)
	End If
	
	Dim Data As Map = File.ReadMap(xui.DefaultFolder,mDataFile)
	
	Dim h,w As Float
	If guiHelpers.gIsLandScape Then
		If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
			h = 52%y
		Else If guiHelpers.gScreenSizeAprox >= 8 Then
			h = 45%y
		Else '--- 4 to 5.9 inch
			h = 70%y
		End If
		w = 360dip
	Else
		h = 280dip
		w = guiHelpers.gWidth * .94
	End If
	
	
	mDlg.Initialize(mMainObj.root, mCaption, w, h)
	mDlg.LoadFromJson(File.ReadString(File.DirAssets, "dlgSimpleApiOnOff.json"))
	mDlg.SetEventsListener(Me,"dlgSimple")
	
	
	prefHelper.Initialize(mDlg)
	
	prefHelper.ThemePrefDialogForm
	If guiHelpers.gScreenSizeAprox > 6.5 Then mDlg.PutAtTop = False
	Dim RS As ResumableSub = mDlg.ShowDialog(Data, "OK", "CANCEL")
	prefHelper.dlgHelper.ThemeInputDialogBtnsResize
	Wait For (RS) Complete (Result As Int)
	
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast(gblConst.DATA_SAVED,1500)
		File.WriteMap(xui.DefaultFolder,mDataFile,Data)
		If mDataFile.ToLowerCase.Contains("zled") Then
			config.ReadZLED_CFG
		Else
			config.ReadWS281_CFG
		End If
		CallSub(mMainObj.oPageCurrent,"Set_focus")
	End If
	Main.tmrTimerCallSub.CallSubDelayedPlus(Main,"Dim_ActionBar_Off",300)
	
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
	prefHelper.SkinDialog(Template)
End Sub



