B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
Sub Class_Globals
	Private const mModule As String = "mnuHeatersBed" 'ignore
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
	o.Initialize( Me,"TempsTool",mainObj,mMenuItems, mCallingView,"Bed Heater")
	'o.MenuWidth = 300dip '--- defaults to 100
	'o.MenuObj.OrientationVertical = o.MenuObj.OrientationHorizontal_MIDDLE '--- change menu position
	'Sleep(0)
	'o.Show
	
	Dim top As Float
	If guiHelpers.gScreenSizeAprox >= 6 Then
		top = 31%y
	Else
		top = 9%y
	End If
	
	Dim w As Float = 300dip
	o.MenuObj.OpenMenuAdvanced((50%x - w / 2),top,w)

End Sub



private Sub TempsTool_Closed (index As Int, tag As Object)
	
	Dim msg As String
	Dim SelectedMsg As String = tag.As(String)
	Dim ShortMsg As Boolean = False
	
	Try
		
		Select Case True
			Case SelectedMsg = "alloff" '--- all off
				CallSub(mainObj.MasterCtrlr,"AllHeaters_Off")
				msg = "Tool / Bed Off"
			
			Case index = 1  '--- bed off
				mainObj.MasterCtrlr.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",0))
				msg = "Bed Off"
		
			Case Else
				'Set PLA (Bed: 60øC )
				Dim startNDX As Int = SelectedMsg.IndexOf(": ")
				Dim endNDX As Int = SelectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
				Dim getTemp As String = SelectedMsg.SubString2(startNDX + 2,endNDX).Trim
				mainObj.MasterCtrlr.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
				ShortMsg = True
		
		End Select
		
	Catch
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
	If ShortMsg Then
		guiHelpers.Show_toast(SelectedMsg,3000)
	Else
		guiHelpers.Show_toast(msg,3000)
	End If
	
	CallSub(B4XPages.MainPage.MasterCtrlr,"tmrMain_Tick")

End Sub