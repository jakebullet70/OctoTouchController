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
	
	Private mDisplayedFileName As String '--- curently displayed file name
	Private mNumOfTries4Thumbnail As Int = 0
	
	Private btnCancel, btnPause, btnPrint As Button
	
	Private lblFileName As AutoTextSizeLabel
	Private CircularProgressBar1 As CircularProgressBar

	Private mText4PrintBtn,mText4ResumeBtn As Object
	Private lblPrintStats1 As AutoTextSizeLabel
	Private lblPrintStats3,lblPrintStats2 As B4XView
	Private lblPrintStatsTMP As AutoTextSizeLabel
	
	Private ivPreviewLG As lmB4XImageViewX
	Private mTmpTemps As String
	
	Private pnlHeating,pnlBtns,pnlBGbed,pnlBGTool As B4XView
	
	Private ivBed,ivTool As lmB4XImageViewX
	
	Private lblToolTemp1,lblBedTemp1 As B4XView
	
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
	mDisplayedFileName = oc.JobFileName
	
End Sub

public Sub Lost_focus()
	mPnlMain.SetVisibleAnimated(500,False)
End Sub


Private Sub BuildGUI
	
	Dim ph As Phone
	If ph.SdkVersion < gblConst.API_ANDROID_4_4 Then 
		pnlHeating.Height = pnlHeating.Height - 26dip
	End If
	
	
	guiHelpers.SetTextColor2(Array As B4XView(lblBedTemp1,lblToolTemp1, _
								lblPrintStats1.BaseLabel,lblPrintStats2,lblPrintStats3, _
								CircularProgressBar1.MainLabel,lblFileName.BaseLabel))
								
	ivPreviewLG.Load(File.DirAssets,gblConst.NO_THUMBNAIL)
	
	ivBed.Bitmap  = guiHelpers.ChangeColorBasedOnAlphaLevel( _
		LoadBitmapSample(File.DirAssets, "bed.png", ivBed.mBase.Width, ivBed.mBase.Height),clrTheme.txtNormal)
	ivTool.Bitmap = guiHelpers.ChangeColorBasedOnAlphaLevel( _ 
		LoadBitmapSample(File.DirAssets, "hotend.png", ivBed.mBase.Width, ivBed.mBase.Height),clrTheme.txtNormal)
	
	guiHelpers.SkinButton(Array As Button( btnCancel,btnPause,btnPrint))
	
	guiHelpers.ResizeText("200  ",lblBedTemp1) '--- sets font size
	guiHelpers.ResizeText("200  ",lblToolTemp1) '--- sets font size
	
	CircularProgressBar1.ColorEmpty = clrTheme.txtNormal
	CircularProgressBar1.ColorFull  = clrTheme.Background2
	CircularProgressBar1.Value      = 0
	CircularProgressBar1.ValueUnit  = "%"
	
	If guiHelpers.gScreenSizeAprox > 6 Then
		CircularProgressBar1.MainLabel.Font = xui.CreateDefaultFont(62)
	Else
		CircularProgressBar1.MainLabel.Font = xui.CreateDefaultFont(42)
	End If

	'--- scale font
	guiHelpers.SetTextSize(Array As Button(btnCancel,btnPause,btnPrint), _ 
										NumberFormat2(btnCancel.TextSize / guiHelpers.gFscale,1,0,0,False))
	
	'--- figure out best font size
	lblPrintStatsTMP.Text   = $"Total Time:0:00:00:00"$ '--- autosize font label control
	lblPrintStats2.TextSize = lblPrintStatsTMP.BaseLabel.Font.Size
	lblPrintStats3.TextSize = lblPrintStats2.TextSize
	
	'--- will show thumbnail on startup
	ivPreviewLG.mBase.Visible = False : 	ivPreviewLG_Click
	
	#if klipper
	lblPrintStats3.Visible = False '--- cannot figure this one out yet!!!!  TODO
	#End If
	
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
'	cs.Initialize
'	guiHelpers.ResizeText(cs.Typeface(Typeface.FONTAWESOME).VerticalAlign(4dip).Append(Chr(0xF04C)).Append(CRLF). _
'												Typeface(Typeface.DEFAULT).Append("Pause").PopAll,btnPause)
#end region											
End Sub

Public Sub Update_Printer_Btns
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
	#if klipper
	If oc.isFileLoaded = False Or oc.isKlipperCanceling Then
	#else
	If oc.isFileLoaded = False Then
	#End If
		
		guiHelpers.EnableDisableBtns2(Array As Button(btnPrint,btnPause,btnCancel),False)
		Return
		
	Else
		
		'If SubExists(B4XPages.MainPage.oPageCurrent,"PrintStarting_UpdateThumbnail") Then
		'	CallSub(B4XPages.MainPage.oPageCurrent,"PrintStarting_UpdateThumbnail")
		'End If
			
	End If
	
	'--- enable / disable printing buttons depending on printing status
	If oc.isPrinting Then
		
		'--- we are printing or heating
		guiHelpers.EnableDisableBtns2(Array As Button(btnCancel,btnPause),True)
		guiHelpers.EnableDisableBtns2(Array As Button(btnPrint),False)
	
	else if oc.isPrinting = False And oc.isPaused2 = True Then
		
		'--- job is paused
		guiHelpers.EnableDisableBtns2(Array As Button(btnCancel,btnPrint),True)
		guiHelpers.EnableDisableBtns2(Array As Button(btnPause),False)
		
	Else
		
		'--- not printing anything
		btnPrint.Enabled = oc.isFileLoaded 
		guiHelpers.EnableDisableBtns2(Array As Button(btnPrint),oc.isFileLoaded)
		guiHelpers.EnableDisableBtns2(Array As Button(btnCancel,btnPause),False)
		
	End If
	
End Sub

Public Sub Update_Printer_Stats
	
	#if klipper 
	If oc.isConnected = False Then
		CallSubDelayed2(mMainObj,"Switch_Pages",gblConst.PAGE_MENU)
		Return
	End If
	#End If
	
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
		(mDisplayedFileName <> oc.JobFileName) Then
		UpdateFileName
	End If
	
	mDisplayedFileName = oc.JobFileName
	
End Sub

Private Sub UpdateFileName
	If oc.isFileLoaded Then
		lblFileName.Text = " File: " & fileHelpers.RemoveExtFromeFileName(oc.JobFileName)
	Else
		lblFileName.Text = gblConst.NO_FILE_LOADED
	End If
	mNumOfTries4Thumbnail = 0
	LoadThumbNail
	If (oc.isHeating Or oc.isPrinting) Then
		Printing_FromFilesPage
	End If
End Sub

Public Sub Update_Printer_Temps
	
	'--- temps, only update the label if it has changed,
	'--- the Autosize label ctrl flickers in some cases
	
	If lblBedTemp1.Visible = False Then Return
	
	mTmpTemps = IIf(oc.Tool1Actual = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.Tool1Actual)
	If lblToolTemp1.Text <> mTmpTemps Then
		lblToolTemp1.Text = mTmpTemps.Replace("C","") '--- TODO fix C issue
	End If
	
	mTmpTemps = IIf(oc.BedActual = $"0${gblConst.DEGREE_SYMBOL}C"$,"off",oc.BedActual)
	If lblBedTemp1.Text <> mTmpTemps Then
		lblBedTemp1.Text = mTmpTemps.Replace("C","") '--- TODO fix C issue
	End If
	
End Sub


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
				
				#if klipper
				If oc.isklipperCanceling = True Then
				#else
				If oc.isCanceling = True Then
				#End If
					guiHelpers.Show_toast("Printer Is Canceling, Please Wait...",2000)
					Return
				End If
				
				Dim mb2 As dlgMsgBox2 : 	mb2.Initialize(mMainObj.Root,"Question",280dip, 150dip,False)
				mb2.NewTextSize = 32
				Wait For (mb2.Show("Start print job?",gblConst.MB_ICON_QUESTION, "PRINT","","CANCEL")) Complete (res As Int)
				If res = xui.DialogResponse_Cancel Then Return
				
				guiHelpers.Show_toast("Starting Print...",2000)
				#if klipper
				Dim fname As String = oc.cCMD_PRINT.Replace("!FN!",oc.JobFileName) '--- TODO KLIPPER, folders?
				mMainObj.oMasterController.cn.PostRequest(fname)
				#else
				mMainObj.oMasterController.cn.PostRequest(oc.cCMD_PRINT)
				#End If
				
				If ivPreviewLG.mBase.Visible = True Then
					ivPreviewLG_Click '--- show tempeture panel
				End If

			End If
			
		Case "cancel"
			Dim w As Float = IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth - 10dip)
			Dim mb As dlgMsgBox : mb.Initialize(mMainObj.Root,"Question",w, 170dip,False)
			Wait For (mb.Show("Do you want to cancel this print?",gblConst.MB_ICON_QUESTION, _
							"Yes - Cancel It","","No")) Complete (res As Int)

			If res = xui.DialogResponse_Positive Then
				guiHelpers.Show_toast("Canceling...",2000)
				#if klipper
				oc.isKlipperCanceling = True
				#end if
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


Public Sub LoadThumbNail
	
	Dim Const THUMBNAIL_ISSUE As String = "Getting Thumbnail..."
	If oc.JobFileName = "" Then Return
	#if klipper
	If oc.isConnected = False Then Return
	#End If
		
	If mMainObj.oMasterController.gMapOctoFilesList.IsInitialized = False Then
		'--- sometimes happens on 1st startup
		guiHelpers.Show_toast(THUMBNAIL_ISSUE,1500)
		Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"LoadThumbNail",6200)
		Return
	End If

	Dim currentFileInfo As tOctoFileInfo
	currentFileInfo =  mMainObj.oMasterController.gMapOctoFilesList.Get(oc.JobFileName)
	
	mNumOfTries4Thumbnail = mNumOfTries4Thumbnail + 1
	If mNumOfTries4Thumbnail > 5 Then Return '--- I have tried 5 times, something is wrong
	
	If currentFileInfo = Null Or currentFileInfo.myThumbnail_filename_disk = "" Then
		If currentFileInfo = Null Then 
			CallSubDelayed(mMainObj.oMasterController, "GetAllOctoFilesInfo")
			Main.tmrTimerCallSub.CallSubDelayedPlus(Me,"LoadThumbNail",3000)
			guiHelpers.Show_toast(THUMBNAIL_ISSUE,1500)
		End If
		ivPreviewLG.Load(File.DirAssets,gblConst.NO_THUMBNAIL)
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
				ivPreviewLG.Load(File.DirAssets,gblConst.NO_THUMBNAIL)
			Else
				ivPreviewLG.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
			End If
		Else
			ivPreviewLG.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
		End If
	Catch
		
		guiHelpers.Show_toast("NULL Error loading thumbnail",2000) '--- happens when no file is loaded
		logMe.LogIt2(LastException,mModule,"LoadThumbNail")
		
	End Try
	
End Sub


Private Sub ivPreviewLG_Click
	
	'--- show thumbnail or heat info
	If ivPreviewLG.mBase.Visible = True Then
		ivPreviewLG.mBase.Visible = False
		pnlBGbed.Visible = True
		pnlBGTool.Visible = True
		Update_Printer_Temps
	Else
		ivPreviewLG.mBase.Visible = True
		pnlBGbed.Visible = False
		pnlBGTool.Visible = False
	End If
	
End Sub
Private Sub HeaterView_Click
	ivPreviewLG_Click
End Sub
Private Sub HeaterViewLbl_Click
	ivPreviewLG_Click
End Sub
Public Sub Printing_FromFilesPage
	'--- called when starting a print from files page
	Log("Printing_FromFilesPage")
	If ivPreviewLG.mBase.Visible = True Then
		ivPreviewLG_Click
	End If
End Sub
