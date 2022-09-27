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
	
	Private fUnloadLen,fUnloadSpeed As Int
	Private fLoadLen As Int
	Private fLoadSpeed As Int
	Private fHomeBeforePark,fRetractBeforePark,fPauseBeforePark As Boolean
	Private fYPark,fXPark As Int
	Private fZLift As Boolean
	Private fParkSpeed As Int
	
	Private pnlMain As B4XView, lblStatus As AutoTextSizeLabel
	Private tmrWait4Temp As Timer
	
	Private mContinue As Boolean = False
	Private mCanceled As Boolean = False
	Private mLoadUnload As String
	
	
	
End Sub


Public Sub Initialize(mobj As B4XMainPage)
	
	mMainObj = mobj
	ReadSettingsCfg
	
End Sub


Public Sub Show(LoadUnload As String)
	
	mLoadUnload = LoadUnload
	
	'--- get the target temp
	Log("ddd")
	Wait For (Show_SelectTemp) Complete (Result As Int)
	Log("ddddddddd")
	If mCanceled = True Then 
		guiHelpers.Show_toast($"Filament Change Canceled"$,2000)
		Return
	End If
	
	'--- lets do it!
	Wait For (Show_Wizard) Complete (Result As Int)
	
End Sub


#region "SHOW TEMP SELECT"
Private Sub Show_SelectTemp
	
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,$"Filament Change ${strHelpers.ProperCase(mLoadUnload)}"$ ,Me,"HeatTempChange_Tool")
	Dim mapTmp As Map = objHelpers.CopyMap(mMainObj.oMasterController.mapToolHeatValuesOnly)
	mapTmp.Remove("Tool Off")
	o1.Show(250dip,220dip,mapTmp)
	
End Sub

Private Sub HeatTempChange_Tool(value As String, tag As Object)
	
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
		
	guiHelpers.Show_toast("Heating tool for filament change",1400)
	
End Sub

Private Sub TypeInHeatChangeRequest
		
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj,"Tool Temperature","Enter Temperature",Me,"HeatTempChange_ToolEdit")
	o1.Show
	
End Sub

Private Sub HeatTempChange_ToolEdit(value As String)
	'--- callback for TypeInHeatChangeRequest
	HeatTempChange_Tool(value,"")
End Sub
#END REGION


Private Sub Show_Wizard() As ResumableSub 'ignore
	
	'--- init
	tmrWait4Temp.Initialize("tmrTempCheck",500)
	tmrWait4Temp.Enabled = True
	
	mDialog.Initialize(mMainObj.Root)
	
	Dim p As B4XView = xui.CreatePanel("")
	Dim h As Float
	If guiHelpers.gScreenSizeAprox > 7 Then
		h = 280dip
	Else
		h = 240dip
	End If
	p.SetLayoutAnimated(0, 0, 0, 360dip,h)
	p.LoadLayout("viewFilamentCtrl")
	Build_GUI

	guiHelpers.ThemeDialogForm(mDialog, mLoadUnload & " Filament")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CANCEL")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)

	Wait For (rs) Complete (Result As Int)
	
	
	tmrWait4Temp.Enabled = False
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	
End Sub


Private Sub tmrTempCheck_Tick
	If oc.Tool1ActualReal >= oc.Tool1TargetReal Then
		tmrWait4Temp.Enabled = False
		Sleep(999) '--- settle for a second
		mContinue = True
	End If
End Sub


private Sub Build_GUI
	
	pnlMain.Color = clrTheme.BackgroundMenu
	lblStatus.Text = "Waiting for tempature"	
	'guiHelpers.SetEnableDisableColor(Array As B4XView(btnOff,btnOn))
	
End Sub


Public Sub ReadSettingsCfg

'	mIPaddr = Starter.kvs.GetDefault(gblConst.PWR_SONOFF_IP,"")
'	If Starter.kvs.Get(gblConst.PWR_SONOFF_PLUGIN).As(Boolean) = True Then
'		mPSU_Type = "sonoff"
'	Else
'		mPSU_Type = "octo_k"
'	End If

End Sub


Private Sub btnCtrl_Click
	
	Dim o As B4XView : o = Sender
	Wait For (SendCmd(o.Tag)) Complete(s As String)
	mDialog.Close(-1) '--- close it, exit dialog
	
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





