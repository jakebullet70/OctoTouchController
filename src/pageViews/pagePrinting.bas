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
	
	Private btnPresetTool, btnPresetBed, btnPresetMaster As Button
	Private btnCancel, btnPause, btnPrint As Button
	
	Private lblFileName As AutoTextSizeLabel
	Private CircularProgressBar1 As CircularProgressBar

	Private mText4PrintBtn,mText4ResumeBtn As Object
	Private lblToolTemp,lblBedTemp,lblPrintStats1 As AutoTextSizeLabel
	Private lblPrintStats3,lblPrintStats2 As B4XView
	Private lblPrintStatsTMP As AutoTextSizeLabel
	
	Private lblHeaderBed,lblHeaderTool As B4XView
	
	Private ivPreviewLG,ivPreview As lmB4XImageViewX
	Private mTmpTemps As String
	
	Private pnlBGbed,pnlBGTool As B4XView
	
End Sub


Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pagePrinting")
	
	BuildGUI
	
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

Private Sub BuildGUI
	
	guiHelpers.SetTextColor(Array As B4XView(lblBedTemp.BaseLabel,lblToolTemp.BaseLabel, _
								lblPrintStats1.BaseLabel,lblPrintStats2,lblPrintStats3, _
								CircularProgressBar1.MainLabel,lblFileName.BaseLabel,lblHeaderBed,lblHeaderTool))
								
	ivPreviewLG.mBase.Visible = False
	SetNoThumbnail
	
	guiHelpers.SkinButton(Array As Button( btnCancel,btnPause,btnPrint,btnPresetTool,btnPresetMaster,btnPresetBed))
	guiHelpers.SetEnableDisableColor(Array As B4XView(lblBedTemp.BaseLabel,lblToolTemp.BaseLabel))
	
	CircularProgressBar1.ColorEmpty = clrTheme.txtNormal
	CircularProgressBar1.ColorFull     = clrTheme.Background2
	CircularProgressBar1.Value = 0
	CircularProgressBar1.ValueUnit = "%"
	
	If guiHelpers.gScreenSizeAprox > 6 Then
		CircularProgressBar1.MainLabel.Font = xui.CreateDefaultFont(62)
	Else
		CircularProgressBar1.MainLabel.Font = xui.CreateDefaultFont(42)
	End If

	'--- scale font
	guiHelpers.SetTextSize(Array As Button(btnCancel,btnPause,btnPrint), _ 
										NumberFormat2(btnCancel.TextSize / guiHelpers.gFscale,1,0,0,False))
	
	'---thumbnail preview is same size as progressbar
	ivPreview.Width  = CircularProgressBar1.mBase.Width + 28dip
	ivPreview.Height = CircularProgressBar1.mBase.Height
	ivPreview.Top     = CircularProgressBar1.mBase.Top
	ivPreview.Left    = CircularProgressBar1.mBase.Left - 14dip
	
	'--- figure out best font size
	lblPrintStatsTMP.Text   = $"Total Time:0:00:00:00"$ 
	lblPrintStats2.TextSize = lblPrintStatsTMP.BaseLabel.Font.Size
	lblPrintStats3.TextSize = lblPrintStats2.TextSize
	
#region "PRINTER BTNS TXT"	
	Dim cs As CSBuilder 
	 
	cs.Initialize
	mText4PrintBtn  = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF02F)).Append(CRLF). _
												Typeface(Typeface.DEFAULT).Append("Print").PopAll
	cs.Initialize
	mText4ResumeBtn = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF04B)).Append(CRLF). _
												Typeface(Typeface.DEFAULT).Append("Resume").PopAll
	cs.Initialize
	btnPause.Text = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF04C)).Append(CRLF). _
												Typeface(Typeface.DEFAULT).Append("Pause").PopAll
	cs.Initialize
	btnCancel.Text = cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF04D)).Append(CRLF). _
												Typeface(Typeface.DEFAULT).Append("Cancel").PopAll												
#end region											
End Sub

public Sub Update_Printer_Btns
	'--- sets enable, disable
	mPnlMain.Enabled = oc.isConnected
	
	'--- rename printing buttons as needed
	If oc.isPaused2 = True Then
		btnPrint.Text = mText4ResumeBtn
		btnPrint.Tag = "resume"
	Else
		btnPrint.Text = mText4PrintBtn
		btnPrint.Tag = "print"
	End If
	
	
	'--- is a file loaded and ready?
	If oc.isFileLoaded = False Then
		
		guiHelpers.EnableDisableBtns2(Array As Button(btnPrint,btnPause,btnCancel),False)
		guiHelpers.EnableDisableBtns2(Array As Button(btnPresetTool,btnPresetBed,btnPresetMaster),True)
		Return
		
	Else
		
		'If SubExists(B4XPages.MainPage.oPageCurrent,"PrintStarting_UpdateThumbnail") Then
		'	CallSub(B4XPages.MainPage.oPageCurrent,"PrintStarting_UpdateThumbnail")
		'End If
			
	End If
	
	'--- enable / disable printing buttons depending on printing status
	If oc.isPrinting = True Then
		
		'--- we are printing or heating
		guiHelpers.EnableDisableBtns2(Array As Button(btnCancel,btnPause),True)
		guiHelpers.EnableDisableBtns2(Array As Button(btnPrint,btnPresetTool,btnPresetBed,btnPresetMaster),False)
		ShowThumbnailWhilePrinting(True)
	
	else if oc.isPrinting = False And oc.isPaused2 = True Then
		
		'--- job is paused
		guiHelpers.EnableDisableBtns2(Array As Button(btnCancel,btnPrint),True)
		guiHelpers.EnableDisableBtns2(Array As Button(btnPause,btnPresetTool,btnPresetBed,btnPresetMaster),False)
		If ivPreviewLG.mBase.Visible = False Then
			ShowThumbnailWhilePrinting(True)
		End If
	Else
		
		'--- not printing anything
		btnPrint.Enabled = oc.isFileLoaded 
		guiHelpers.EnableDisableBtns2(Array As Button(btnPrint),oc.isFileLoaded)
		guiHelpers.EnableDisableBtns2(Array As Button(btnCancel,btnPause),False)
		guiHelpers.EnableDisableBtns2(Array As Button(btnPresetTool,btnPresetBed,btnPresetMaster),True)
		ShowThumbnailWhilePrinting(False)
		
	End If
	
End Sub

Private Sub ShowThumbnailWhilePrinting(show As Boolean)
	
	btnPresetMaster.Visible = Not (show)
	ivPreviewLG.mBase.Visible = show
	pnlBGbed.Visible = Not (show)
	pnlBGTool.Visible = Not (show)
	If show = True Then 
		LoadThumbNail
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
		lblPrintStats2.Text = $"Total Time:${fnc.ConvertSecondsToString(oc.JobPrintTime)}"$
		lblPrintStats3.Text = $"Time Left:${fnc.ConvertSecondsToString(oc.JobPrintTimeLeft)}"$
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
	
	mTmpTemps = IIf(oc.tool1Target = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.tool1Target)
	If lblToolTemp.Text <> mTmpTemps Then
		lblToolTemp.Text = mTmpTemps
		lblToolTemp.BaseLabel.Font = xui.CreateDefaultFont(NumberFormat2(lblToolTemp.BaseLabel.TextSize / guiHelpers.gFscale,1,0,0,False) - 3)
	End If
	
	mTmpTemps = IIf(oc.BedTarget = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.BedTarget)
	If lblBedTemp.Text <> mTmpTemps Then
		lblBedTemp.Text = mTmpTemps
		lblBedTemp.BaseLabel.Font = xui.CreateDefaultFont(NumberFormat2(lblBedTemp.BaseLabel.TextSize / guiHelpers.gFscale,1,0,0,False) - 3)
	End If
	
End Sub

#Region "HEATER_PRESETS"
Private Sub btnPresetMaster_Click
	
	CallSub2(B4XPages.MainPage,"ShowPreHeatMenu_All2","System Presets")
	
End Sub



Private Sub btnPresetTemp_Click
	
	Dim btn As Button : btn = Sender
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Then Return
		
	Dim o1 As dlgListbox
	o1.Initialize(mMainObj,IIf(btn.tag = "tool","Tool Presets","Bed Presets"),B4XPages.MainPage,"TempChange_Presets")
	o1.Tag = btn.tag
	o1.Show(280dip,290dip,IIf(btn.Tag = "tool", _
				mMainObj.oMasterController.mapToolHeatingOptions, _
				mMainObj.oMasterController.mapBedHeatingOptions))
	
End Sub

#end region

#region "TEMP_CHANGE_EDIT"
Private Sub lblTempChange(what As String)
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If oc.isConnected = False Or oc.isPrinting Or oc.IsPaused2 Then Return
	
	Dim o1 As dlgNumericInput
	o1.Initialize(mMainObj, _
		IIf(what = "bed","Bed Temperature","Tool Temperature"), _
		"Enter Temperature",Me, _
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
				
				If oc.isCanceling = True Then
					guiHelpers.Show_toast("Printer Is Canceling, Please Wait...",2000)
					Return
				End If
				
				guiHelpers.Show_toast("Starting Print...",2000)
				mMainObj.oMasterController.cn.PostRequest(oc.cCMD_PRINT)

			End If
			
		Case "cancel"
			Dim w As Float = IIf(guiHelpers.gIsLandScape,500dip,380dip)
			Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Question",w, 170dip,False)
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
		SetNoThumbnail
		Return
	End If

	Try
		'--- Same code as in pageFiles so...   TODO, make method and share code
		If File.Exists(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk) = False Then
	
			guiHelpers.Show_toast("Getting Thumbnail",1000)
			If config.logFILE_EVENTS Then logMe.LogIt("downloading missing thumbnail file; " & currentFileInfo.myThumbnail_filename_disk,mModule)
		
			Wait For (mMainObj.oMasterController.cn.Download_AndSaveFile( _
					$"http://${mMainObj.oMasterController.cn.gIP}:${mMainObj.oMasterController.cn.gPort}/"$ & currentFileInfo.Thumbnail, _
					currentFileInfo.myThumbnail_filename_disk)) Complete (i As Object)
					
			'Sleep(2200)
		
			If File.Exists(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk) = False Then
				SetNoThumbnail
			Else
				ivPreview.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
				ivPreviewLG.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
			End If
		Else
			ivPreview.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
			ivPreviewLG.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
		End If
	Catch
		
		guiHelpers.Show_toast("NULL Error loading thumbnail",2000) '--- happens when no file is loaded
		logMe.LogIt2(LastException,mModule,"LoadThumbNail")
		
	End Try
	
End Sub

Private Sub SetNoThumbnail
	ivPreview.Load(File.DirAssets,gblConst.NO_THUMBNAIL)
	ivPreviewLG.Load(File.DirAssets,gblConst.NO_THUMBNAIL)
End Sub



