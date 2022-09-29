B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Sept/24/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgFilamentCtrl"' 'ignore
	Private mMainObj As B4XMainPage
	Private xui As XUI
	
	Private mDialog As B4XDialog

	Private cPRE_PARK_HOME As String = "'G28 X0 Y0"
	Private cPRE_PARK_PAUSE As String = "M0"
	Private cPRE_PARK_EXT0 As String = "M83"
	Private cPRE_PARK_EXT1 As String = "G1 E-5 F50"

	Private pnlMain As B4XView, lblStatus As AutoTextSizeLabel
	Private btnStuff As B4XView, lblTemp As Label
	
	Private mCanceled As Boolean = False, mLoadUnload As String
	
End Sub



Public Sub Initialize(mobj As B4XMainPage)
	
	mMainObj = mobj
	ReadSettings
	
End Sub

Private Sub ReadSettings
	
End Sub


Public Sub Show(LoadUnload As String)
	
	mLoadUnload = LoadUnload
	
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,$"Filament Change - ${strHelpers.ProperCase(mLoadUnload)}"$ ,Me,"HeatTempChange_Tool")
	Dim mapTmp As Map = objHelpers.CopyMap(mMainObj.oMasterController.mapToolHeatValuesOnly)
	mapTmp.Remove("Tool Off")
	o1.Show(250dip,270dip,mapTmp)
	Wait For HeatTempChange_Tool(value As String, tag As Object)
	ProcessHeatTempChange(value,tag)
	If mCanceled Then Return
	
	'--- lets do it!
	Sleep(100) '<---  Need this
	Wait For (Show_Wizard) Complete (Result As Int)
	
End Sub

Private Sub Show_Wizard() As ResumableSub 'ignore
	
	'--- init
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, _
		IIf(guiHelpers.gScreenSizeAprox < 6,460dip,560dip),IIf(guiHelpers.gScreenSizeAprox < 6,224dip,280dip))
	p.LoadLayout("viewFilamentCtrl")
	pnlMain.Color = clrTheme.Background
	lblStatus.TextColor = clrTheme.txtNormal
	lblStatus.Text = "Waiting for temperture..." & CRLF
	lblTemp.TextColor = clrTheme.txtNormal
	btnStuff.Visible = False
	btnStuff.Font = xui.CreateDefaultFont(NumberFormat2(btnStuff.TextSize / guiHelpers.gFscale,1,0,0,False) - IIf(guiHelpers.gFscale > 1,2,0))
	guiHelpers.SetEnableDisableColor(Array As B4XView(btnStuff))
	
	SetTempMonitorTimer
		
	guiHelpers.ThemeDialogForm(mDialog, mLoadUnload & " Filament")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	Wait For (rs) Complete (Result As Int)
	If Result = xui.DialogResponse_Cancel Then
		EndWizard($"Filament Change Canceled - Tool Off"$)
		Return 1'ignore
	End If
	Return 1 'error?
	
End Sub


Private Sub EndWizard(msg As String) 'ignore
	CallSubDelayed3(B4XPages.MainPage,"Show_Toast", msg, 1600)
	mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF) '--- turn it off if its on
	mCanceled = True
End Sub


Private Sub tmrTempCheck_Tick
	If mCanceled Then Return
	'Log(oc.Tool1TargetReal)
	If oc.Tool1TargetReal = 0 Then 
		SetTempMonitorTimer
		Return '--- waiting for target var to be set from thee HTTP read
	End If
	
	If oc.Tool1ActualReal >= oc.Tool1TargetReal Then
		Sleep(1000) '--- settle for a second 
		LoadUnLoadFil
	Else
		lblTemp.Text = oc.Tool1Actual
		SetTempMonitorTimer
	End If
	
End Sub

Private Sub SetTempMonitorTimer
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"tmrTempCheck_Tick",1000)
End Sub

Private Sub LoadUnLoadFil
	
	BeepMe
	If mLoadUnload.ToLowerCase = "load" Then
		lblStatus.Text = "Insert filament and touch the 'Continue' button to load" & CRLF
		btnStuff.Text = "Continue"
		btnStuff.Visible = True
	Else
		lblStatus.Text = "Touch The 'Continue' button to start unload" & CRLF
	End If
	
End Sub

Private Sub BeepMe
	
	Dim b As Beeper : 
	b.Initialize(120,500)
	For xx = 1 To 5
		b.Beep : Sleep(200)
	Next
	
End Sub

Private Sub btnStuff_Click
	lblStatus.Text = "Working..." & CRLF
	mDialog.Close(xui.DialogResponse_Positive) '--- close it, exit dialog
End Sub


Public Sub SendCmd(cmd As String)As ResumableSub'ignore

'	Dim msg As String = $"Sending Power '${cmd.ToUpperCase}' Command"$
'	
'	Select Case mPSU_Type
'		Case "sonoff"
'			If mIPaddr = "" Then 
'				guiHelpers.Show_toast("Missing SonOff IP address",2000)
'				Return 'ignore
'			End If
'			Dim sm As HttpDownloadStr : sm.Initialize
'			Wait For (sm.SendRequest($"http://${mIPaddr}/cm?cmnd=Power%20${cmd}"$)) Complete(s As String)
'			
'		Case "octo_k"
'			mMainObj.oMasterController.cn.PostRequest( _
'				oc.cPSU_CONTROL_K.Replace("!ONOFF!",IIf(cmd.ToLowerCase ="on","On","Off")))
'		
'		Case Else
'			msg = "PSU control config problem"
'			
'	End Select
'	
'	If cmd.ToLowerCase = "off" Then
'		'---printer off, back to main menu
'		If mMainObj.oPageCurrent <> mMainObj.oPageMenu Then
'			CallSub2(mMainObj,"Switch_Pages",gblConst.PAGE_MENU)
'		End If
'	End If
'	
'	guiHelpers.Show_toast(msg,1500)
	
End Sub


#region "SHOW TEMP SELECT"

Private Sub ProcessHeatTempChange(value As String, tag As Object) 'ignore
	
	'--- callback for Show_SelectTemp
	If value.Length = 0 Then 
		mCanceled = True
		Return
	End If

	If value = "ev" Then
		TypeInHeatChangeRequest '--- type in a value
		Return
	End If
	
	If fnc.CheckTempRange("tool", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.oMasterController.cn.PostRequest( _
				oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))
		
End Sub

Private Sub TypeInHeatChangeRequest
		
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj,"Tool Temperature","Enter Temperature",Me,"HeatTempChange_ToolEdit")
	o1.Show
	
End Sub

Private Sub HeatTempChange_ToolEdit(value As String)
	'--- callback for TypeInHeatChangeRequest
	ProcessHeatTempChange(value,"")
End Sub
#END REGION
