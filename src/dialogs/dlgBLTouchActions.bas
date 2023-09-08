B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/08/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgBLTouchActions"' 'ignore
	Private xui As XUI
	
	Private pnlMain As Panel
	Private mDialog As B4XDialog
	
	Private btnUp,btnSelftTest,btnSave,btnrAlarm,btnDn,btnPBed As Button
	Private mapFile As Map, gcode As String
End Sub

Public Sub Initialize() As Object
	mapFile = File.ReadMap(xui.DefaultFolder,gblConst.BLCR_TOUCH_FILE)
	Return Me
End Sub

Public Sub Close_Me
	mDialog.Close(-1)
End Sub


Public Sub Show
	
	mDialog.Initialize(B4XPages.MainPage.Root)
	Dim dlgHelper As sadB4XDialogHelper
	dlgHelper.Initialize(mDialog)
	
	Dim p As B4XView = xui.CreatePanel("")
	
	Log(guiHelpers.gScreenSizeAprox)
	'--- needs to be cleaned up ------------------
	Dim w,h As Float 
	If guiHelpers.gIsLandScape Then
		w = IIf(guiHelpers.gScreenSizeAprox < 6,460dip,640dip)
		h = IIf(guiHelpers.gScreenSizeAprox < 4.6,guiHelpers.gHeight * .7,290dip)
	Else
	 	w = IIf(guiHelpers.gScreenSizeAprox < 6,guiHelpers.gWidth - 40dip,520dip)
		h = 310dip
	End If
	If guiHelpers.gScreenSizeAprox > 8 Then '-- tablet, big guy!
		h = 370dip
	End If
	'--------------------------------------------
	
	p.SetLayoutAnimated(0, 0, 0, w,h)
	p.LoadLayout("dlgBLCRtouch")
	pnlMain.Color = clrTheme.Background
	guiHelpers.SkinButton(Array As Button(btnDn,btnPBed,btnrAlarm,btnSave,btnSelftTest,btnUp))
	
	
	dlgHelper.ThemeDialogForm("BL/CR Touch Menu")
	Dim rs As ResumableSub = mDialog.ShowCustom(p, "", "", "CLOSE")
	dlgHelper.ThemeInputDialogBtnsResize

	Wait For (rs) Complete (Result As Int)
	
	CallSubDelayed2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
	B4XPages.MainPage.pObjCurrentDlg1 = Null
		
End Sub

#end region



Private Sub btnCtrl_Click
	
	Dim b As Button : b = Sender
	
	Select Case b.tag
		Case "up" : gcode = mapFile.Get(gblConst.probeUP)
		Case "dn" : gcode = mapFile.Get(gblConst.probeDN)
		Case "st" : gcode = mapFile.Get(gblConst.probeTest)
		Case "ra" : gcode = mapFile.Get(gblConst.probeRelAlarm)
		Case "pb" : gcode = mapFile.Get(gblConst.probeBed)
		Case "sv" : gcode = mapFile.Get(gblConst.probeSave)
			
	End Select
	
	CallSubDelayed2(B4XPages.MainPage,"Send_Gcode",gcode)
	guiHelpers.Show_toast("Command sent",1200)
	
End Sub