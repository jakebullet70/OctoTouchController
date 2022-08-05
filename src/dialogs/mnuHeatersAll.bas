B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
Sub Class_Globals
	Private const mModule As String = "mnuHeatersAll"' 'ignore
	Private mCallingView As B4XView
	Private mainObj As B4XMainPage
	Private xui As XUI
	Private mMenuItems As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(mobj As B4XMainPage, menuItems As Map, callingView As B4XView)
	mainObj = mobj
	mCallingView = callingView
	mMenuItems = menuItems
End Sub


Public Sub Show
	
	Dim o As mnuPopup
	o.Initialize( Me,"TempsMaster",mainObj,mMenuItems, mCallingView,"All Heaters")
	o.MenuWidth = 300dip '--- defaults to 100
	o.aspm_main.OrientationVertical = o.aspm_main.OrientationHorizontal_MIDDLE '--- change menu position
	Sleep(0)
	o.Show

End Sub



private Sub TempsMaster_Closed (index As Int, tag As Object)
	
	Dim msg As String
	Dim SelectedMsg As String = tag.As(String)
	Dim ShortMsg As Boolean = False
	
	Try
	
		Select Case True
			Case SelectedMsg = "alloff" '--- all off
				CallSub(mainObj.MasterCtrlr,"AllHeaters_Off")
				msg = "Tool / Bed Off"
			
			Case Else
				'Set ABS (Tool: 240øC  / (Bed: 105øC )
				Dim toolMSG As String  = Regex.Split("/",SelectedMsg)(0)
				Dim bedMSG As String  = Regex.Split("/",SelectedMsg)(1)
				
				Dim startNDX As Int = toolMSG.IndexOf(": ")
				Dim endNDX As Int = toolMSG.IndexOf(gblConst.DEGREE_SYMBOL)
				Dim getTemp As String = toolMSG.SubString2(startNDX + 2,endNDX).Trim
				'mainObj.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
				
				Dim startNDX As Int = bedMSG.IndexOf(": ")
				Dim endNDX As Int = bedMSG.IndexOf(gblConst.DEGREE_SYMBOL)
				Dim getTemp As String = bedMSG.SubString2(startNDX + 2,endNDX).Trim
				
				mainObj.MasterCtrlr.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
				ShortMsg = True
		
		End Select
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
	If ShortMsg Then
		guiHelpers.Show_toast(SelectedMsg,3000)
	Else
		guiHelpers.Show_toast($"${msg}"$,3000)
	End If
	
	'--- refresh screen
	'CallSub(mainObj,"tmrMain_Tick_CallDirect")
	
End Sub




