B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/4/2022 - Kherson Ukraine
#End Region

Sub Class_Globals
	Private Const mModule As String = "pageMenu" 'ignore
	Private xui As XUI
	Private mPnlMain As B4XView
	Private mCallBackEvent As String
	Private mMainObj As B4XMainPage 'ignore

	'Private btnSubBrightness As Button
	Private btnSubHeater As Button
	Private btnSubPlugin1 As Button
	Private btnSubPlugin2 As Button
	Private btnSubPlugin3 As Button
	Private btnSubPlugin4 As Button
	Private btnSubPlugin5 As Button
	'Private btnSubScrnOff As Button
	Private pnlInfo As Panel
	Private pnlMainMenu As Panel
	Private pnlMenuBtns As Panel
	Private pnlMenuLower As Panel
	Private pnlMenuLowerBLine As Panel
	Private pnlMnuFiles As Panel
	Private pnlMnuMovement As Panel
	Private pnlMnuPrinting As Panel
	Private pnlTempBed,pnlTempTool As Panel
	
	Private lblActualTemp,lblTextTop,lblTextBottom As Label
	Private lblBedActualV,lblBedTargetV,lblToolActualV,lblToolTargetV As Label ' <--- pointers to card objects
	Private lblActualTempBedV, lblActualTempToolV As Label ' <--- pointers to card objects
	
	Private pnlMenuUpperBL As Panel

End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String) 
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageMenu2")
	BuildGUI
	Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"ShowVer",2300)
	
End Sub

Private Sub BuildGUI
	
	'--- build the main menu screen
	BuildMenuCard(pnlMnuMovement,"menuMovement.png","Movement",gblConst.PAGE_MOVEMENT)
	BuildMenuCard(pnlMnuFiles,"menuFiles.png","Files",gblConst.PAGE_FILES)
	BuildMenuCard(pnlMnuPrinting,"menuPrint.png","Printing",gblConst.PAGE_PRINTING)
	
	BuildStatCard(pnlTempTool,"hotend.png","tool")
	BuildStatCard(pnlTempBed,"bed.png","bed")
	
	lblToolActualV.Text = "Actual" : lblBedActualV.Text = lblToolActualV.Text
	lblActualTempBedV.TextColor = clrTheme.txtNormal
	lblActualTempToolV.TextColor = clrTheme.txtNormal
	
	If guiHelpers.gIsLandScape = False Then
		lblToolTargetV.TextSize = 20
		lblBedTargetV.TextSize = 20
	End If
		
	guiHelpers.SetVisible(Array As B4XView(btnSubPlugin1,btnSubPlugin2,btnSubPlugin3,btnSubPlugin4,btnSubPlugin5),False)
	guiHelpers.SkinButton_Pugin(Array As Button(btnSubPlugin1,btnSubPlugin2,btnSubPlugin3,btnSubPlugin4,btnSubPlugin5,btnSubHeater))
	pnlMenuLowerBLine.Color = clrTheme.txtAccent
	pnlMenuUpperBL.Color = clrTheme.txtAccent
	pnlMenuLowerBLine.Visible = True '--- turned off in designer
	
End Sub


Public Sub ShowVer
	guiHelpers.Show_toast("Version: V" & Application.VersionName,2200)
End Sub


Public Sub Set_focus()
	
	mPnlMain.SetVisibleAnimated(500,True)
	CallSubDelayed(B4XPages.MainPage ,"Build_RightSideMenu")
		
End Sub


Public Sub Lost_focus()
	mPnlMain.SetVisibleAnimated(500,False)
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
End Sub


Private Sub BuildStatCard(viewPanel As Panel,imgFile As String, Text As String)
	
	viewPanel.LoadLayout("mainstatcard.bal")

	For Each v As View In viewPanel.GetAllViewsRecursive
		
		If v.Tag <> Null Then
			
			If v Is ImageView Then
				Dim b As Bitmap = LoadBitmapResize(File.DirAssets, imgFile, v.Width, v.Height,True)
				v.As(ImageView).Bitmap = guiHelpers.ChangeColorBasedOnAlphaLevel(b,clrTheme.txtNormal)
				v.As(ImageView).Tag = IIf(Text.ToLowerCase = "bed","b","t")
				
			else if v Is Label Then
				Dim o6 As Label = v
				If o6.Text = "t" Then '--- top label - actual
					guiHelpers.ResizeText("Actual .." & gblConst.DEGREE_SYMBOL,o6)
					If Text = "bed" Then
						lblBedActualV = o6
					Else
						lblToolActualV = o6
					End If
				Else if o6.Text = "b" Then '--- bottom label - target
					guiHelpers.ResizeText("Target ......." & gblConst.DEGREE_SYMBOL,o6)
					If Text = "bed" Then
						lblBedTargetV = o6
					Else
						lblToolTargetV = o6
					End If
				Else
					guiHelpers.ResizeText("100" & gblConst.DEGREE_SYMBOL,o6)
					o6.Text = "0" & gblConst.DEGREE_SYMBOL
					If Text = "bed" Then
						lblActualTempBedV = o6
					Else
						lblActualTempToolV = o6
					End If
				End If
				
				o6.TextColor = clrTheme.txtAccent
			End If
			
		End If
		
	Next
	
End Sub

Private Sub BuildMenuCard(mnuPanel As Panel,imgFile As String, Text As String, mnuAction As String)
	
	mnuPanel.LoadLayout("menuCard2")
	For Each v As View In mnuPanel.GetAllViewsRecursive
		
		If v.Tag <> Null Then
			If v.Tag Is lmB4XImageViewX Then
				Dim o1 As lmB4XImageViewX = v.Tag
				o1.mClickAnimationColor = clrTheme.txtAccent
				o1.Load(File.DirAssets,imgFile)
				o1.SetBitmap(guiHelpers.ChangeColorBasedOnAlphaLevel(o1.Bitmap,clrTheme.txtNormal))
				o1.Tag2 = mnuAction '--- set menu action
				
			else if v.Tag Is AutoTextSizeLabel Then
				Dim o6 As AutoTextSizeLabel = v.Tag
				o6.Text = Text
				o6.TextColor = clrTheme.txtAccent
				
			End If
		End If
		
	Next
	
End Sub

Private Sub mnuCardImg1_Click
	
	#if klipper
	If oc.isconnected = False Or mMainObj.lblstatus.text = "no connection"  Then
	#else
	If oc.isconnected = False Then 
	#end if
		guiHelpers.show_toast(gblConst.not_connected,1000)
		Return
	End If
	
	Dim oo1 As ImageView : oo1 = Sender
	Dim oo2 As HeaterRoutines : oo2.Initialize
	If oo1.Tag = "b" Then
		If oc.isPrinting Or oc.IsPaused2 Then
			oo2.ChangeTempBed
		Else
			oo2.PopupBedHeaterMenu
		End If
	Else
		If oc.isPrinting Or oc.IsPaused2 Then
			oo2.ChangeTempTool
		Else
			oo2.PopupToolHeaterMenu
		End If
	End If
	
End Sub

Private Sub mnuCardImg_Click
	
'	Log(oc.isConnected) 
'	Log(oc.FormatedStatus)
	
	#if klipper
	If oc.isconnected = False Or mMainObj.lblstatus.text = "no connection"  Then
	#else
	If oc.isconnected = False Then 
	#end if
		guiHelpers.show_toast(gblConst.not_connected,1000)
		Return
	End If
	
	'--- pass the page menu selection back to main page
	Try
		Dim oo1 As lmB4XImageViewX : oo1 = Sender
		Sleep(50)
		CallSub2(mMainObj,mCallBackEvent,oo1.tag2)
	Catch
		Log(LastException)
	End Try
	
End Sub



'---  small action buttons on main menu
Private Sub btnSubBtnAction_Click
	
	Dim o As B4XView : o = Sender
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	Select Case o.Tag
					
		'Case "br" '--- brightness
		'	DoBrightnessDlg
			
'		Case "soff" '--- screen off
'			CallSub2(Main,"TurnOnOff_ScreenTmr",False)
'			fnc.BlankScreen
			
		Case "heat" '--- pre-heat
			If oc.isConnected = False Then
				guiHelpers.Show_toast(gblConst.NOT_CONNECTED,1000)
				Return
			End If
			If oc.isPrinting Then 
				guiHelpers.Show_toast("Printer is busy",2000)
			Else
				CallSub(B4XPages.MainPage,"ShowPreHeatMenu_All")
			End If
				
	End Select
	
End Sub


Public Sub Update_Printer_Temps

	lblActualTempToolV.Text = oc.Tool1Actual.Replace("C","")
	lblToolTargetV.Text = ("Target: "& $"${IIf(oc.tool1Target = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.tool1Target)}"$).As(String).Replace("C","")

	lblActualTempBedV.Text = oc.BedActual.Replace("C","")
	lblBedTargetV.Text = ("Target: "& $"${IIf(oc.BedTarget = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.BedTarget)}"$).As(String).Replace("C","")
	
	'--- TODO, strip the 'C' of the temps and just use degree symbol
	'--- TODO, strip the 'C' of the temps and just use degree symbol
	'--- TODO, strip the 'C' of the temps and just use degree symbol
	
End Sub
