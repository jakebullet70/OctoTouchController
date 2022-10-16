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
	Private xui As XUI	
	Private Const mModule As String = "pageFiles" 'ignore
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private mMainObj As B4XMainPage'ignore
	Private DisplayedFileName As String '--- curently displayed file name
	
	Private CSelections As clvSelectionsX
	Private Const NO_SELECTION As Int = -1
	Private clvLastIndexClicked As Int = NO_SELECTION
	
	Private clvFiles As CustomListView
	Private ivPreview As lmB4XImageViewX
	Private btnDelete, btnLoad, btnLoadAndPrint As B4XView
	Private mCurrentFileInfo As tOctoFileInfo
	Private pnlPortraitDivide As B4XView
	
	'--- list view panel
	Private lblpnlFileViewTop,lblpnlFileViewBottom As B4XView
	Private pnlFileViewBG As B4XView
	
	Private FilesCheckChangeIsBusyFLAG As Boolean = False
	Private firstRun As Boolean = True
	
	Private lblFileName As AutoTextSizeLabel, lblHeaderFileName As B4XView
	Private lblBusy As B4XView
	
	Private lblSort As AutoTextSizeLabel
	Private cboSort As B4XComboBox, rsFiles As ResultSet
	Private SortAscDesc As Boolean = True
	Private	LastSort As String
	
	
	
End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageFiles")
		
	Build_GUI
	
End Sub

public Sub Set_focus()
	
	mPnlMain.SetVisibleAnimated(500,True)
	mPnlMain.Enabled = oc.isConnected  
	
	If firstRun = False Then
		'--- this happened already on 1st run
		tmrFilesCheckChange_Tick '--- call the check change, it will turn on the timer
		Sleep(500)
	Else
		'--- 1st showing of tab page
		If config.logFILE_EVENTS Then logMe.LogIt(firstRun,mModule)
		If clvFiles.Size > 0 Then 
			Show1stFile
		End If
		CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",True)
		firstRun = False
	End If
	
	Update_LoadedFileName2Scrn
	DisplayedFileName = oc.JobFileName
	Update_Printer_Btns
	
	
End Sub

public Sub Lost_focus()
	mPnlMain.SetVisibleAnimated(500,False)
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	CallSub2(Main,"Dim_ActionBar",gblConst.ACTIONBAR_OFF)
End Sub


'============================================================================


public Sub Update_Printer_Btns
	'--- sets enable, disable
	
	mPnlMain.Enabled = oc.isConnected
	Dim enableDisable As Boolean

	If oc.isPrinting Or oc.IsPaused2 Or (clvLastIndexClicked = NO_SELECTION) Then
		enableDisable = False
	Else
		enableDisable = True
	End If
	
	guiHelpers.EnableDisableBtns( _
		Array As B4XView(btnLoad,btnLoadAndPrint,btnDelete),enableDisable)

End Sub

Public Sub tmrFilesCheckChange_Tick
	
	If mPnlMain.Visible = False Then
		'--- we do not have focus so just disable files check
		CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
		Return
	End If
	
	CheckIfFilesChanged
	
	If (oc.JobFileName.Length = 0 And lblFileName.Text <> gblConst.NO_FILE_LOADED) Or _
		(oc.JobFileName.Length <> 0 And lblFileName.Text = gblConst.NO_FILE_LOADED) Or _
		(DisplayedFileName <> oc.JobFileName) Then
		 Update_LoadedFileName2Scrn
	End If
	
	DisplayedFileName = oc.JobFileName
	
End Sub

Private Sub Build_GUI
	
	guiHelpers.ReSkinB4XComboBox(Array As B4XComboBox(cboSort))
	cboSort.setitems(Array As String("File Name","Date Added"))
	cboSort.SelectedIndex = 0
	cboSort.cmbBox.Prompt = "Sort Order"
	LastSort = "File Name"
	
	lblBusy.Visible = True
	lblBusy.SetColorAndBorder(clrTheme.BackgroundHeader,1dip,clrTheme.txtNormal,8dip)
	lblBusy.TextColor = clrTheme.txtNormal
	
	pnlPortraitDivide.SetColorAndBorder(clrTheme.BackgroundHeader,2dip,clrTheme.BackgroundHeader,8dip)
	
	If mMainObj.oMasterController.gMapOctoFilesList.IsInitialized And mMainObj.oMasterController.gMapOctoFilesList.Size > 0 Then
		Build_ListViewFileList
		Show1stFile '--- select the 1st item and load image
	Else
		clvFiles.Clear
		clvFiles_ItemClick(0,Null)
	End If
	
	lblSort.Text = Chr(0xF160)
	
	If guiHelpers.gIsLandScape = False And guiHelpers.gScreenSizeAprox < 5.2 Then
		btnLoadAndPrint.Text = "Print"
	Else
		btnLoadAndPrint.Text = "Load" & CRLF & "Print"
	End If
	
	btnLoad.Text = "Load"
	btnDelete.Text = "Delete"
	
	guiHelpers.SetTextColor(Array As B4XView( _
			btnLoadAndPrint,btnLoad,btnDelete,lblFileName.BaseLabel, _
			lblHeaderFileName,lblSort.BaseLabel))
	
	Dim fn As B4XFont = _
				xui.CreateDefaultFont(NumberFormat2(btnDelete.TextSize / guiHelpers.gFscale,1,0,0,False) - _
				IIf(guiHelpers.gFscale > 1,2,0))
	btnDelete.Font = fn
	btnLoad.Font  = fn
	btnLoadAndPrint.Font  = fn
	
End Sub


Private Sub btnAction_Click
	
	Dim btn As B4XView : btn = Sender
			
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If clvLastIndexClicked = NO_SELECTION Then
		guiHelpers.Show_toast("No item selected",2500)
		Return
	End If
	
	Select Case btn.Tag
		Case "delete"
			CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
			
			Dim mb As dlgMsgBox 
			mb.Initialize(mMainObj.Root,"Question", IIf(guiHelpers.gIsLandScape,500dip,guiHelpers.gWidth-40dip), 170dip,False)
			Wait For (mb.Show("Delete file from Octoprint?",gblConst.MB_ICON_QUESTION,"Yes - Delete It","","No")) Complete (res As Int)
			
			If res = xui.DialogResponse_Positive Then
				SendDeleteCmdAndRemoveFromGrid
			End If
			CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",True)
			
		Case "load"
			mMainObj.oMasterController.cn.PostRequest(oc.cPOST_FILES_SELECT.Replace("!LOC!",mCurrentFileInfo.Origin).Replace("!PATH!",mCurrentFileInfo.Name))
			guiHelpers.Show_toast("Loading file...",2000)
			'Sleep(100)
			CallSub(B4XPages.MainPage.oMasterController,"tmrMain_Tick")
			Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"Update_LoadedFileName2Scrn",400)
			
		Case "loadandprint"
			mMainObj.oMasterController.cn.PostRequest(oc.cPOST_FILES_PRINT.Replace("!LOC!",mCurrentFileInfo.Origin).Replace("!PATH!",mCurrentFileInfo.Name))
			guiHelpers.EnableDisableBtns(Array As B4XView(btnLoad,btnLoadAndPrint,btnDelete),False)
			CallSubDelayed2(mMainObj,"Switch_Pages",gblConst.PAGE_PRINTING)
			
	End Select
		
End Sub

Private Sub GetFileSortOrder() As String 'ignore
	Select Case cboSort.SelectedItem.ToLowerCase
		Case "file name" 	: Return "file_name"
		Case "date added" 	: Return "date_added"
	End Select
End Sub

Public Sub Build_ListViewFileList()
	
	Dim inSub As String = "Build_ListViewFileList"
	
	Try ' DEBUG try-catch

		clvFiles.Clear
		If rsFiles.IsInitialized Then rsFiles.Close
		Starter.db.BuildTable
		Starter.db.SeedTable(mMainObj.oMasterController.gMapOctoFilesList)

		CSelections.Initialize(clvFiles)
		CSelections.Mode = CSelections.MODE_SINGLE_ITEM_PERMANENT
	Catch
		logMe.LogIt2("Build_ListViewFileList1: " & LastException,mModule,inSub)
	End Try

	Try ' DEBUG try-catch
		Dim ndx As Int = 0
		Dim fname As String
		
		If rsFiles.IsInitialized Then rsFiles.Close
		rsFiles = Starter.db.sql.ExecQuery( _
						$"SELECT * FROM files ORDER BY ${GetFileSortOrder} ${IIf(SortAscDesc,"ASC","DESC")}"$)
		
		Do While rsFiles.NextRow
			fname = rsFiles.GetString("file_name")
			Dim o As tOctoFileInfo  = mMainObj.oMasterController.gMapOctoFilesList.Get(fname)
			clvFiles.InsertAt(ndx, CreateListItem(o, clvFiles.AsView.Width, 60dip), fname)
			ndx = ndx + 1
		Loop
		
	Catch
		logMe.LogIt2("Build_ListViewFileList 2:" & LastException,mModule,inSub)
	End Try
	
	
	Try ' DEBUG try-catch
		clvFiles.PressedColor = 0x721F1C1C  '--- alpha set to 128
		CSelections.SelectionColor = clvFiles.PressedColor
		clvFiles.DefaultTextColor  = clrTheme.txtNormal
		clvFiles.DefaultTextBackgroundColor = xui.Color_Transparent
	
		If clvFiles.Size > 0 Then
			'--- if we have data select the 1st one
			CSelections.ItemClicked(0)
			clvLastIndexClicked = 0
		Else
			clvLastIndexClicked = NO_SELECTION
		End If
	
	Catch
		logMe.LogIt2("Build_ListViewFileList 3: " & LastException,mModule,inSub)
	End Try
	
	lblBusy.Visible = False
	
End Sub

Sub CreateListItem(oData As tOctoFileInfo, Width As Int, Height As Int) As B4XView
	
	Dim p As B4XView = xui.CreatePanel("")
	'--- add 20dip to height for larger screens
	p.SetLayoutAnimated(0, 0, 0, Width, Height + IIf(guiHelpers.gScreenSizeAprox > 7.8,20dip,0dip))
	p.LoadLayout("viewFiles")

	lblpnlFileViewTop.TextColor = clrTheme.txtNormal
	lblpnlFileViewTop.font = xui.CreateDefaultFont( _
		NumberFormat2(lblpnlFileViewTop.TextSize / guiHelpers.gFscale,1,0,0,False))
		
	Try
		lblpnlFileViewTop.Text = fileHelpers.RemoveExtFromeFileName(oData.Name)
	Catch
		logMe.LogIt2("CreatListItem 2: (Lamensis)" & LastException,mModule,"CreateListItem")
	End Try	

	lblpnlFileViewBottom.TextColor = clrTheme.txtAccent
	lblpnlFileViewBottom.Font = lblpnlFileViewTop.Font
	lblpnlFileViewBottom.Text = "Size: " &  fileHelpers.BytesToReadableString(oData.Size) & _
								$"  ${oData.length.As(String)}m / ${oData.Volume.As(String)}³"$
			

	Return p
	
End Sub

Private Sub SetThumbnail2Nothing
	ivPreview.Load(File.DirAssets,"no_thumbnail.jpg")
End Sub



'Private Sub clvFiles_ItemLongClick (Index As Int, Value As Object)
'	mCurrentFileInfo =  mMainObj.oMasterController.gMapOctoFilesList.Get(Value)
'End Sub
Private Sub clvFiles_ItemClick (Index As Int, Value As Object)
	
	CallSub(Main,"Set_ScreenTmr") '--- reset the power / screen on-off
	
	If Value = Null Then
		clvLastIndexClicked = NO_SELECTION
		SetThumbnail2Nothing
		Return 
	End If
	
	CSelections.ItemClicked(Index)
	clvLastIndexClicked = Index
	mCurrentFileInfo =  mMainObj.oMasterController.gMapOctoFilesList.Get(Value)
	
	If mCurrentFileInfo.myThumbnail_filename_disk = "" Then
		SetThumbnail2Nothing
		Return
	End If
	
	If File.Exists(xui.DefaultFolder,mCurrentFileInfo.myThumbnail_filename_disk) = False Then
	
		SetThumbnail2Nothing
		guiHelpers.Show_toast("Getting Thumbnail...",2000)
		
		If config.logFILE_EVENTS Then logMe.LogIt("downloading missing thumbnail file; " & mCurrentFileInfo.myThumbnail_filename_disk,mModule)
		
		mMainObj.oMasterController.cn.Download_AndSaveFile( _
			$"http://${mMainObj.oMasterController.cn.gIP}:${mMainObj.oMasterController.cn.gPort}/"$ & mCurrentFileInfo.Thumbnail, _
			mCurrentFileInfo.myThumbnail_filename_disk)
			 
		Sleep(1800)
		
		If File.Exists(xui.DefaultFolder,mCurrentFileInfo.myThumbnail_filename_disk) = False Then
			SetThumbnail2Nothing
		Else
			ivPreview.Load(xui.DefaultFolder,mCurrentFileInfo.myThumbnail_filename_disk)
		End If
		
	Else
		ivPreview.Load(xui.DefaultFolder,mCurrentFileInfo.myThumbnail_filename_disk)
	End If
	
End Sub


#region "FILES_CHANGED_CHECK"


Public Sub CheckIfFilesChanged
	
	Dim inSub As String = "CheckIfFilesChanged"
	If FilesCheckChangeIsBusyFLAG Then Return
	If mMainObj.oMasterController.gMapOctoFilesList.IsInitialized = False Then
		mMainObj.oMasterController.GetAllOctoFilesInfo
		Return
	End If
	
	Dim oldListViewSize As Int = clvFiles.Size
		
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	FilesCheckChangeIsBusyFLAG = True
	
	'--- grab a list of files
	Dim rs As ResumableSub =  mMainObj.oMasterController.cn.SendRequestGetInfo(oc.cFILES)
	Wait For(rs) Complete (Result As String)
	
	If Result.Length <> 0 Then
	
		'--- compare new list with old
		Dim o As JsonParserFiles : o.Initialize(False) '--- DO NOT download thumbnails
		Dim didSomethingChange As Boolean = o.CheckIfChanged(Result, mMainObj.oMasterController.gMapOctoFilesList)
		Dim IncompleteData As Boolean = mMainObj.oMasterController.IsIncompleteFileData
		
		Dim SizeMisMatch As Boolean = (clvFiles.Size <> mMainObj.oMasterController.gMapOctoFilesList.Size)
		
		If didSomethingChange Or IncompleteData Or SizeMisMatch Then
			
			'--- ok, something changed, missing data
			If config.logFILE_EVENTS Then logMe.LogIt2($"did change:(incomplete:${IncompleteData})(SizeMisMatch:${SizeMisMatch})"$,mModule,inSub)
			
			logMe.LogIt2($"did change:(incomplete:${IncompleteData})(SizeMisMatch:${SizeMisMatch})"$,mModule,inSub)
			
			Dim mapNewFileList As Map = o.StartParseAllFiles(Result)
			ProcessNewOldThumbnails(mapNewFileList)
			
			'--- refresh the old list with new changes
			mMainObj.oMasterController.gMapOctoFilesList = objHelpers.CopyMap(mapNewFileList)'  o.StartParseAllFiles(Result)
			
			If IncompleteData = False Then
				Build_ListViewFileList
			Else
				If config.logFILE_EVENTS Then logMe.LogIt2("Incomplete file data processed",mModule,inSub)
			End If
			
		Else
			
			'--- nothing new
			If config.logFILE_EVENTS Then logMe.LogIt2("did change --- NO!!!!!!!!!!",mModule,inSub)
			
		End If
		
	End If
	
	FilesCheckChangeIsBusyFLAG = False
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",True)
	
	Dim ttlRecsInDB As Int = Starter.db.GetTotalRecs
	If oldListViewSize <> clvFiles.Size And ttlRecsInDB > 0 Then
		'--- highllight the first row
		Sleep(100) : Show1stFile
	End If
	
	If ttlRecsInDB = 0 Then SetThumbnail2Nothing
	
	Update_Printer_Btns
	
End Sub


Private Sub ProcessNewOldThumbnails(NewMap As Map)
	
	Dim InSub As String = "ProcessNewOldThumbnails"
	Try
	
		'--- remove any old thumbnail files
		Dim deletedFiles As Int = 0
		If config.logFILE_EVENTS Then logMe.LogIt("ProcessThumbnails - start - remove any old thumbnail files",mModule)
		
		For Each oldMap As tOctoFileInfo In mMainObj.oMasterController.gMapOctoFilesList.Values
			
			Dim oldMapKey As String = oldMap.Name
			If NewMap.ContainsKey(oldMapKey) = False Then
				
				If config.logFILE_EVENTS Then logMe.LogIt("deleted old thumbnail: " & oldMap.myThumbnail_filename_disk,mModule)
				
				fileHelpers.SafeKill(oldMap.myThumbnail_filename_disk)
				LogColor("del --> " & oldMap.myThumbnail_filename_disk,Colors.Yellow)
				deletedFiles = deletedFiles + 1
				
			End If
			
		Next
		
	Catch
		logMe.LogIt2(LastException,mModule,InSub)
	End Try

	If config.logFILE_EVENTS Then 
		logMe.LogIt2("END - remove any old thumbnail files: #" & deletedFiles,mModule,InSub)
		logMe.LogIt2("START - download new thumbnails for new and changed files",mModule,InSub)
	End If
	
	Try

		Dim changedFiles = 0, NewFiles = 0 As Int
		
		'--- download new thumbnails for new and changed files
		For Each oNewMap As tOctoFileInfo In NewMap.Values

			Dim mapKey As String = oNewMap.Name
			If mMainObj.oMasterController.gMapOctoFilesList.ContainsKey(mapKey) = True Then

				'---  found a file, BUT... has the date changed?
				Dim ffFileToWorkOn As tOctoFileInfo = mMainObj.oMasterController.gMapOctoFilesList.get(mapKey)
				If ffFileToWorkOn.Date <> oNewMap.Date Then '--- date changed
				
					If config.logFILE_EVENTS Then logMe.LogIt2("refreshing old thumbnail: " & oNewMap.Name,mModule,InSub)
					fileHelpers.SafeKill(ffFileToWorkOn.myThumbnail_filename_disk)
					changedFiles = changedFiles + 1
					mMainObj.oMasterController.Download_ThumbnailAndCache2File(oNewMap.Thumbnail,oNewMap.myThumbnail_filename_disk)
					
				End If
				
			Else

				'--- new file, need thumbnail
				NewFiles = NewFiles + 1
				If config.logFILE_EVENTS Then logMe.LogIt2("downloading new thumbnail; " & oNewMap.name,mModule,InSub)
				
				mMainObj.oMasterController.Download_ThumbnailAndCache2File(oNewMap.Thumbnail,oNewMap.myThumbnail_filename_disk)
								
			End If
		
		Next
			
	Catch
		logMe.LogIt2(LastException,mModule,InSub)
	End Try
	
	If config.logFILE_EVENTS Then logMe.LogIt2("files changed #" & changedFiles & "   files new #" & NewFiles,mModule,InSub)
	
End Sub
#end region

Private Sub SendDeleteCmdAndRemoveFromGrid
	
	mMainObj.oMasterController.cn.DeleteRequest(oc.cDELETE_FILES_DELETE.Replace("!LOC!",mCurrentFileInfo.Origin).Replace("!PATH!",mCurrentFileInfo.Name))
	'Sleep(500)
	
	guiHelpers.Show_toast("Deleting File",1200)
	
	'--- delete from thumbnail cache
	fileHelpers.SafeKill(mCurrentFileInfo.myThumbnail_filename_disk)
	
	'--- remove from grid
	clvFiles.RemoveAt(clvLastIndexClicked)
	CSelections.SelectedItems.Remove(clvLastIndexClicked)
	mMainObj.oMasterController.gMapOctoFilesList.Remove(mCurrentFileInfo.Name)
	Starter.db.DeleteFileRec(mCurrentFileInfo.Name) 
	Sleep(100)
	
	Dim ff As tOctoFileInfo

	If clvFiles.Size > 1 Then
		If clvLastIndexClicked <> 0 Then 
			clvLastIndexClicked = clvLastIndexClicked - 1
		End If
		ff = mMainObj.oMasterController.gMapOctoFilesList.Get(clvFiles.GetValue(clvLastIndexClicked))
		clvFiles_ItemClick(clvLastIndexClicked,ff.name)
	Else if clvFiles.Size = 1 Then
		clvLastIndexClicked = 0
		ff = mMainObj.oMasterController.gMapOctoFilesList.Get(clvFiles.GetValue(clvLastIndexClicked))
		clvFiles_ItemClick(clvLastIndexClicked,ff.name)
	Else
		clvFiles_ItemClick(0,Null)
	End If
	
	Sleep(200)
	CallSub(B4XPages.MainPage.oMasterController,"tmrMain_Tick")
	Sleep(100)
	Starter.tmrTimerCallSub.CallSubDelayedPlus(Me,"Update_LoadedFileName2Scrn",500)
	
End Sub


Public Sub Update_LoadedFileName2Scrn
	If oc.isFileLoaded Then
		lblFileName.Text = fileHelpers.RemoveExtFromeFileName(oc.JobFileName)
	Else
		lblFileName.Text = gblConst.NO_FILE_LOADED
	End If
End Sub

Private Sub	Show1stFile
	If Starter.db.GetTotalRecs = 0 Then Return
	rsFiles.Position = 0 : clvFiles_ItemClick(0,rsFiles.GetString("file_name"))
	clvFiles.JumpToItem(0)
	Sleep(100)
End Sub

#Region "GRID SORT"

Private Sub cboSort_SelectedIndexChanged (Index As Int)
	If LastSort = cboSort.SelectedItem Then
		SortAscDesc = Not (SortAscDesc)
	Else
		SortAscDesc = True
	End If
	lblSort.Text = IIf(SortAscDesc,Chr(0xF160),Chr(0xF161))
	guiHelpers.Show_toast("Sorting file list - " & IIf(SortAscDesc,"Ascending","Descending") ,1800)
	Build_ListViewFileList
	Show1stFile
	LastSort = cboSort.SelectedItem
	
End Sub

Private Sub lblSort_Click
	cboSort_SelectedIndexChanged(cboSort.SelectedIndex)
End Sub
#end region

