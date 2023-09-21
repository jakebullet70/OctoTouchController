B4A=true
Group=DIALOGS_GENERIC
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Apr/14/2023
#End Region

Sub Class_Globals
	
	Private Const mModule As String = "dlgIpOnOffSetup"' 'ignore
	Private xui As XUI
	Private mPrefDlg As sadPreferencesDialog
	Private mPrefHelper As sadPreferencesDialogHelper
	Private mCallBackModule As Object
	Private mCallBackMethod As String
End Sub

Public Sub Initialize(callbackMod As Object, callbackMethod As String) As Object
	mCallBackModule = callbackMod
	mCallBackMethod = callbackMethod
	Return Me
End Sub

Public Sub Visible() As Boolean
	Try
		Return mPrefDlg.Dialog.Visible
	Catch
		Return False
	End Try
End Sub

Public Sub Close_Me
	mPrefDlg.Dialog.Close(xui.DialogResponse_Cancel)
End Sub


Public Sub CreateDefaultDataFile(dataFileName As String)
	
	fileHelpers.SafeKill(dataFileName)	
	Dim descTxt As String
	If IsNumber(dataFileName.SubString2(0,1)) Then
		descTxt = "Generic HTTP Control: "	& dataFileName.SubString2(0,1)
	Else
		descTxt = "Printer Power SonOff"
	End If
	File.WriteMap(xui.DefaultFolder,dataFileName, _
					CreateMap("desc": descTxt, _
										"ipon": "http://192.168.1.235/cm?cmnd=Power On", _
										 "ipoff": "http://192.168.1.235/cm?cmnd=Power Off", _
										  "active": "false","tgl":"false"))

End Sub


Public Sub Show(title As String,dataFileName As String)
	
	If File.Exists(xui.DefaultFolder,dataFileName) = False Then
		CreateDefaultDataFile(dataFileName)
	End If
		
	Dim data As Map = File.ReadMap(xui.DefaultFolder,dataFileName)
	Dim ToTop As Boolean = False
	
	Dim h,w As Float
	If guiHelpers.gScreenSizeAprox >= 6 And guiHelpers.gScreenSizeAprox <= 8 Then
		h = 62%y
	Else If guiHelpers.gScreenSizeAprox >= 8 Then
		h = 52%y
	Else '--- 4 to 5.9 inch
		h = 60%y
	End If
	
	If guiHelpers.gIsLandScape = False Then
		w = 92%x
	Else
		w = 420dip
	End If
	
	 ' guiHelpers.gWidth * guiHelpers.gScreenSizeDPI
	mPrefDlg.Initialize(B4XPages.MainPage.root, title, w, h)
	Dim s As String = File.ReadString(File.DirAssets,"dlgonoff.json")
	If guiHelpers.gIsPortrait Then s = s.Replace("1st Command ","1st Cmd ") '--- portrait screen GUI fix
	mPrefDlg.LoadFromJson(s)
	mPrefDlg.SetEventsListener(Me,"dlgEvent")
	
	mPrefHelper.Initialize(mPrefDlg)
	
	mPrefHelper.ThemePrefDialogForm
	mPrefDlg.PutAtTop = ToTop
	Dim RS As ResumableSub = mPrefDlg.ShowDialog(data, "SAVE", "CLOSE")
	mPrefHelper.dlgHelper.NoCloseOn2ndDialog
	mPrefHelper.dlgHelper.ThemeInputDialogBtnsResize
	
	
	Wait For (RS) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		guiHelpers.Show_toast(gblConst.DATA_SAVED,1500)
		File.WriteMap(xui.DefaultFolder,dataFileName,data)
		
		If SubExists(mCallBackModule,mCallBackMethod) Then
			CallSubDelayed2(mCallBackModule,mCallBackMethod,data)
		End If
		
		CallSubDelayed(B4XPages.MainPage.oPageCurrent,"Set_focus")
	End If
		
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
		
End Sub




Private Sub dlgEvent_IsValid (TempData As Map) As Boolean 'ignore
	
	Dim retval As Boolean = True
	Return retval '--- all is good!

End Sub


Private Sub dlgEvent_BeforeDialogDisplayed (Template As Object)
	mPrefHelper.SkinDialog(Template)
End Sub



