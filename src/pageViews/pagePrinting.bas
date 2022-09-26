B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/5/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "pagePrinting" 'ignore
	Private xui As XUI
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private mMainObj As B4XMainPage'ignore
	
	Private DisplayedFileName As String '--- curently displayed file name
	
	Private btnPresetTool, btnPresetBed, btnPresetMaster As B4XView
	
	Private lblFileName As AutoTextSizeLabel
	Private CircularProgressBar1 As CircularProgressBar
	
	Private btnCancel, btnPause, btnPrint As B4XView
	Private lblBedTemp As AutoTextSizeLabel
	Private lblToolTemp As AutoTextSizeLabel
	Private lblPrintStats1 As AutoTextSizeLabel
	Private lblPrintStats3,lblPrintStats2 As B4XView
	Private lblPrintStatsTMP As AutoTextSizeLabel
	
	Private lblHeaderBed,lblHeaderTool As B4XView
	
	Private ivPreview As lmB4XImageViewX
	
End Sub


Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pagePrinting")
	
	Build_GUI
	
End Sub

public Sub Set_focus()
	
	mPnlMain.SetVisibleAnimated(500,True)
	mPnlMain.Enabled = oc.isConnected

	Update_Printer_Stats
	Update_Printer_Temps
	Update_Printer_Btns
	
	UpdateFileName
	DisplayedFileName = oc.JobFileName
	
	If ivPreview.mBase.Visible = True Then
		LoadThumbNail
	End If
	
End Sub

public Sub Lost_focus()
	mPnlMain.SetVisibleAnimated(500,False)
End Sub

Private Sub Build_GUI
	
	guiHelpers.SetTextColor(Array As B4XView(lblBedTemp.BaseLabel,lblToolTemp.BaseLabel, _
								lblPrintStats1.BaseLabel,lblPrintStats2,lblPrintStats3, _
								btnCancel,btnPause,btnPrint,CircularProgressBar1.MainLabel, _
								lblFileName.BaseLabel,lblHeaderBed,lblHeaderTool))
	
	guiHelpers.SetEnableDisableColor(Array As B4XView(lblBedTemp.BaseLabel,lblToolTemp.BaseLabel))
	
	CircularProgressBar1.ColorEmpty = clrTheme.txtNormal
	CircularProgressBar1.ColorFull = clrTheme.BackgroundMenu
	CircularProgressBar1.Value = 0
	CircularProgressBar1.ValueUnit = "%"
	
	If guiHelpers.gScreenSizeAprox > 6 Then
		CircularProgressBar1.MainLabel.Font = xui.CreateDefaultFont(62)
	Else
		CircularProgressBar1.MainLabel.Font = xui.CreateDefaultFont(42)
	End If

	'--- scale font
	Dim fn As B4XFont = _
			xui.CreateDefaultFont(NumberFormat2(btnCancel.TextSize / guiHelpers.gFscale,1,0,0,False))
	'- 	IIf(guiHelpers.gFscale > 1,4,0))
	btnCancel.Font = fn
	btnPause.Font  = fn
	btnPrint.Font  = fn
	
	ivPreview.Width  = CircularProgressBar1.mBase.Width
	ivPreview.Height = CircularProgressBar1.mBase.Height
	ivPreview.top    = CircularProgressBar1.mBase.Top
	ivPreview.Left   = CircularProgressBar1.mBase.Left
	
	'--- figure out best font size
	lblPrintStatsTMP.Text   = $"Job TTL Time:0:00:00:00"$ : Sleep(20)
	lblPrintStats2.TextSize = lblPrintStatsTMP.BaseLabel.Font.Size
	lblPrintStats3.TextSize = lblPrintStats2.TextSize
	
End Sub

public Sub Update_Printer_Btns
	'--- sets enable, disable
	mPnlMain.Enabled = oc.isConnected
	
	'--- rename printing buttons as needed
	If oc.isPaused2 = True Then
		btnPrint.Text = "Resume"
		btnPrint.Tag = "resume"
	Else
		btnPrint.Text = "Print"
		btnPrint.Tag = "print"
	End If
	
	
	'--- is a file loaded and ready?
	If oc.isFileLoaded = False Then
		
		guiHelpers.EnableDisableBtns(Array As B4XView(btnPrint,btnPause,btnCancel),False)
		guiHelpers.EnableDisableBtns(Array As B4XView(btnPresetTool,btnPresetBed,btnPresetMaster),True)
		Return
		
	Else
		
		'If SubExists(B4XPages.MainPage.oPageCurrent,"PrintStarting_UpdateThumbnail") Then
		'	CallSub(B4XPages.MainPage.oPageCurrent,"PrintStarting_UpdateThumbnail")
		'End If
			
	End If
	
	'--- enable / disable printing buttons depending on printing status
	If oc.isPrinting = True Then
		
		'--- we are printing or heating
		guiHelpers.EnableDisableBtns(Array As B4XView(btnCancel,btnPause),True)
		guiHelpers.EnableDisableBtns(Array As B4XView(btnPrint,btnPresetTool,btnPresetBed,btnPresetMaster),False)
		
	
	else if oc.isPrinting = False And oc.isPaused2 = True Then
		
		'--- job is paused
		guiHelpers.EnableDisableBtns(Array As B4XView(btnCancel,btnPrint),True)
		guiHelpers.EnableDisableBtns(Array As B4XView(btnPause,btnPresetTool,btnPresetBed,btnPresetMaster),False)
				
	Else
		
		'--- not printing anything
		btnPrint.Enabled = oc.isFileLoaded : guiHelpers.SetEnableDisableColor(Array As B4XView(btnPrint))
		guiHelpers.EnableDisableBtns(Array As B4XView(btnCancel,btnPause),False)
		guiHelpers.EnableDisableBtns(Array As B4XView(btnPresetTool,btnPresetBed,btnPresetMaster),True)
		
	End If
	
End Sub

Public Sub Update_Printer_Stats
	
	'--- update printer job
	If IsNumber(oc.JobCompletion) Then
		CircularProgressBar1.Value = oc.JobCompletion
	Else
		CircularProgressBar1.Reset
	End If

	Dim tmp As String = $"File Size:${fileHelpers.BytesToReadableString(oc.JobFileSize)}"$
	If lblPrintStats1.Text <> tmp Then
		lblPrintStats1.Text = tmp
	End If
	
	If oc.JobPrintTime <> "-" Then
		lblPrintStats2.Text = $"Job TTL Time:${fnc.ConvertSecondsToString(oc.JobPrintTime)}"$
		lblPrintStats3.Text = $"Job Time Left:${fnc.ConvertSecondsToString(oc.JobPrintTimeLeft)}"$
	Else
		lblPrintStats2.Text = ""
		lblPrintStats3.Text = ""
	End If
	
	If (oc.JobFileName.Length = 0 And lblFileName.Text <> gblConst.NO_FILE_LOADED) Or _
		(oc.JobFileName.Length <> 0 And lblFileName.Text = gblConst.NO_FILE_LOADED) Or _
		(DisplayedFileName <> oc.JobFileName) Then
		UpdateFileName
	End If
	
	DisplayedFileName = oc.JobFileName
	
End Sub

private Sub UpdateFileName
	If oc.isFileLoaded Then
		lblFileName.Text = " File: " & fileHelpers.RemoveExtFromeFileName(oc.JobFileName)
	Else
		lblFileName.Text = gblConst.NO_FILE_LOADED
	End If
End Sub

Public Sub Update_Printer_Temps
	
	'--- temps, only update the label if it has changed,
	'--- the Autosize label ctrl flickers in some cases
	Dim tmp As String
	
	tmp = IIf(oc.tool1Target = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.tool1Target)
	If lblToolTemp.Text <> tmp Then
		lblToolTemp.Text = tmp : Sleep(0)
		lblToolTemp.BaseLabel.Font = xui.CreateDefaultFont(NumberFormat2(lblToolTemp.BaseLabel.TextSize / guiHelpers.gFscale,1,0,0,False) - 3)
	End If
	
	tmp = IIf(oc.BedTarget = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.BedTarget)
	If lblBedTemp.Text <> tmp Then
		lblBedTemp.Text = tmp : Sleep(0)
		lblBedTemp.BaseLabel.Font = xui.CreateDefaultFont(NumberFormat2(lblBedTemp.BaseLabel.TextSize / guiHelpers.gFscale,1,0,0,False) - 3)
	End If
	
End Sub

#Region "HEATER_PRESETS"
Private Sub btnPresetMaster_Click
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Then Return
	
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,"Heater Presets",Me,"TempChange_Presets")
	o1.Show(220dip,450dip,mMainObj.oMasterController.mapAllHeatingOptions)
	
End Sub



Private Sub btnPresetTemp_Click
	
	Dim btn As Button : btn = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Then Return
		
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,IIf(btn.tag = "tool","Tool Presets","Bed Presets"),Me,"TempChange_Presets")
	o1.Tag = btn.tag
	o1.Show(280dip,290dip,IIf(btn.Tag = "tool", _
				mMainObj.oMasterController.mapToolHeatingOptions, _
				mMainObj.oMasterController.mapBedHeatingOptions))
	
End Sub


Private Sub TempChange_Presets(selectedMsg As String, tag As Object)
	
	'--- callback for btnPresetTemp_Click
	
	If selectedMsg.Length = 0 Then Return
	
	If selectedMsg = "alloff" Then
		mMainObj.oMasterController.AllHeaters_Off
		guiHelpers.Show_toast("Tool / Bed Off",1200)
		Return
	End If
	
	Dim tagme As String = tag.As(String)
	Dim msg, getTemp As String
	Dim startNDX, endNDX As Int
	
	Select Case True
		
		Case selectedMsg.EndsWith("off")
			If tagme = "bed" Then
				mMainObj.oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",0))
				msg = "Bed Off"
			Else
				mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",0).Replace("!VAL1!",0))
				msg = "Tool Off"
			End If
			
		Case selectedMsg.Contains("Tool") And Not (selectedMsg.Contains("Bed"))
			'--- Example, Set PLA (Tool: 60øC )
			startNDX = selectedMsg.IndexOf(": ")
			endNDX = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
			
		Case selectedMsg.Contains("Bed") And Not (selectedMsg.Contains("Tool"))
			'--- Example, PLA (Bed: 60øC )
			startNDX = selectedMsg.IndexOf(": ")
			endNDX = selectedMsg.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp = selectedMsg.SubString2(startNDX + 2,endNDX).Trim
			mMainObj.oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
			
		Case Else
			'--- Example, Set ABS (Tool: 240øC  / Bed: 105øC )
			Dim toolMSG As String = Regex.Split("/",selectedMsg)(0)
			Dim bedMSG  As String = Regex.Split("/",selectedMsg)(1)
				
			startNDX = toolMSG.IndexOf(": ")
			endNDX = toolMSG.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp = toolMSG.SubString2(startNDX + 2,endNDX).Trim
			mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",getTemp.As(Int)))
				
			startNDX = bedMSG.IndexOf(": ")
			endNDX = bedMSG.IndexOf(gblConst.DEGREE_SYMBOL)
			getTemp = bedMSG.SubString2(startNDX + 2,endNDX).Trim
			mMainObj.oMasterController.CN.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",getTemp.As(Int)))
			msg = selectedMsg.Replace("Set","Setting")
			
	End Select
	
	guiHelpers.Show_toast(msg,3000)
	
End Sub
#end region

#region "TEMP_CHANGE_EDIT"
Private Sub lblTempChange(what As String)
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Or oc.isPrinting Or oc.IsPaused2 Then Return
	
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj, _
		IIf(what = "bed","Bed Temperature","Tool Temperature"),"Enter Temperature",Me, _
		IIf(what = "bed","TempChange_Bed","TempChange_Tool1"))
		
	o1.Show
	
End Sub

Private Sub lblToolTemp_Click
	lblTempChange("tool")
End Sub
Private Sub lblBedTemp_Click
	lblTempChange("bed")
End Sub

Private Sub TempChange_Bed(value As String)
	
	'--- callback for lblTempChange
	'--- callback for lblTempChange
	If value = "" Then Return
	If fnc.CheckTempRange("bed", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_BED_TEMP.Replace("!VAL!",value))
	guiHelpers.Show_toast("Bed Temperature Change",1400)
	
End Sub

Private Sub TempChange_Tool1(value As String)
	
	'--- callback for lblTempChange
	'--- callback for lblTempChange
	If value.Length = 0 Then Return
	If fnc.CheckTempRange("tool", value) = False Then
		guiHelpers.Show_toast("Invalid Temperature",1800)
		Return
	End If
		
	mMainObj.oMasterController.cn.PostRequest(oc.cCMD_SET_TOOL_TEMP.Replace("!VAL0!",value).Replace("!VAL1!",0))
		
	guiHelpers.Show_toast("Tool Temperature Change",1400)
	
End Sub
#end region

Private Sub btnAction_Click
	
	Dim o As B4XView : o = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Then Return
	
	Update_Printer_Btns
	
	'--- what does the user want?
	Select Case o.tag
		Case "print"
			If oc.isFileLoaded = False Then
				
				guiHelpers.Show_toast("No file loaded",2000)
				
			Else
				
				CallSub(B4XPages.MainPage.oMasterController,"tmrMain_Tick")
				Sleep(50) '--- do we need this?
				
				If oc.isCanceling = True Then
					guiHelpers.Show_toast("Printer Is Canceling, Please Wait...",2000)
					Return
				End If
				
				guiHelpers.Show_toast("Starting Print...",2000)
				mMainObj.oMasterController.cn.PostRequest(oc.cCMD_PRINT)
				'Sleep(500)
				'lblPrintStats.RefreshView

			End If
			
		Case "cancel"
			Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Question",540dip, 170dip,False)
			Wait For (mb.Show("Do you want to cancel this print?",gblConst.MB_ICON_QUESTION, _
			"Yes - Cancel It","","No")) Complete (res As Int)

			If res = xui.DialogResponse_Positive Then
				guiHelpers.Show_toast("Canceling...",2000)
				mMainObj.oMasterController.cn.PostRequest(oc.cCMD_CANCEL)
			End If
			
		Case "pause"
			guiHelpers.Show_toast("Pausing...",2000)
			mMainObj.oMasterController.cn.PostRequest(oc.cCMD_PAUSE)
			
		Case "resume"
			guiHelpers.Show_toast("Resuming...",2000)
			mMainObj.oMasterController.cn.PostRequest(oc.cCMD_RESUME)
			
	End Select
	
End Sub



Private Sub CircularProgressBar1_Click
	If oc.JobFileName = "" Then
		Return '--- no file loaded
	End If
	LoadThumbNail
	CircularProgressBar1.Visible = False
	ivPreview.mBase.Visible = True
End Sub
Private Sub ivPreview_Click
	CircularProgressBar1.Visible = True
	ivPreview.mBase.Visible = False
End Sub


Private Sub LoadThumbNail
	
	If mMainObj.oMasterController.gMapOctoFilesList.IsInitialized = False Then
		guiHelpers.Show_toast("Retriving info, try again later",1500)
		Return
	End If

	Dim currentFileInfo As tOctoFileInfo
	currentFileInfo =  mMainObj.oMasterController.gMapOctoFilesList.Get(oc.JobFileName)
	
	If currentFileInfo.myThumbnail_filename_disk = "" Then
		ivPreview.Load(File.DirAssets,"no_thumbnail.jpg")
		Return
	End If

	Try
		'--- Same code as in pageFiles so...   TODO, make method and share code
		If File.Exists(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk) = False Then
	
			guiHelpers.Show_toast("Getting Thumbnail",2200)
			If config.logFILE_EVENTS Then logMe.LogIt("downloading missing thumbnail file; " & currentFileInfo.myThumbnail_filename_disk,mModule)
		
			Dim link As String = $"http://${mMainObj.oMasterController.cn.gIP}:${mMainObj.oMasterController.cn.gPort}/"$ & currentFileInfo.Thumbnail
			mMainObj.oMasterController.cn.Download_AndSaveFile(link,currentFileInfo.myThumbnail_filename_disk)
			Sleep(2200)
		
			If File.Exists(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk) = False Then
				ivPreview.Load(File.DirAssets,"no_thumbnail.jpg")
			Else
				ivPreview.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
			End If
		Else
			ivPreview.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
		End If
	Catch
		
		guiHelpers.Show_toast("NULL Error loading thumbnail",2000) '--- happens when no file is loaded
		logMe.LogIt2(LastException,mModule,"LoadThumbNail")
		
	End Try
	
End Sub







