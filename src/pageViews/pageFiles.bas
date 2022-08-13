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
	Private  mMainObj As B4XMainPage'ignore
	
	Private CSelections As clvSelectionsX
	Private const cNO_SELECTION As Int = -1
	Private clvLastIndexClicked As Int = cNO_SELECTION

	Private clvFiles As CustomListView
	Private ivPreview As lmB4XImageViewX
	Private btnDelete, btnLoad, btnLoadAndPrint As B4XView
	Private currentFileInfo As typOctoFileInfo
	
	'--- list view panel
	Private lblpnlFileViewBottom As Label
	Private lblpnlFileViewTop As Label
	Private pnlFileViewBG As B4XView
	
	Private FilesCheckChangeIsBusyFLAG As Boolean = False
	Private firstRun As Boolean = True
	
End Sub

'TODO - check gcode files with spaces in them, need encoding?

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.SetLayoutAnimated(0,0,masterPanel.top,masterPanel.Width,masterPanel.Height)
	mPnlMain.LoadLayout("pageFiles")
		
	Build_GUI
	
End Sub

public Sub Set_focus()
	mPnlMain.Visible = True
	
	If firstRun = False Then
		'--- this happened already on 1st run
		tmrFilesCheckChange_Tick '--- call the check change, it will turn on the timer
	Else
		'--- 1st showing of tab page
		'logMe.Logit(firstRun,mModule)
		If clvFiles.Size > 0 Then 
			clvFiles_ItemClick(0,mMainObj.MasterCtrlr.gMapOctoFilesList.GetKeyAt(0))
		End If
		CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",True)
		firstRun = False
	End If
	
End Sub

public Sub Lost_focus()
	mPnlMain.Visible = False
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
End Sub


'============================================================================


public Sub Update_Printer_Btns
	'--- sets enable, disable
	
	Dim enableDisable As Boolean

	If oc.isPrinting Or oc.IsPaused2 Or oc.isHeating  Or (clvLastIndexClicked = cNO_SELECTION) Then
		enableDisable = False
	Else
		enableDisable = True
	End If
	
	For Each btn As B4XView In Array As B4XView(btnLoad,btnLoadAndPrint)
		btn.Enabled = enableDisable
	Next
	guiHelpers.SetEnableDisableColor(Array As B4XView(btnLoad,btnLoadAndPrint,btnDelete))

End Sub

Public Sub tmrFilesCheckChange_Tick
	
	If mPnlMain.Visible = False Then
		'--- we  do not have focus so just disable files check
		'logMe.Logit("tmrFilesCheckChange_Tick - pnl not visible",mModule)
		CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
		Return
	End If
	
	logMe.Logit("tmrFilesCheckChange_Tick --> FIRED",mModule)
	CheckIfFilesChanged
	
End Sub


Private Sub Build_GUI
	
	If mMainObj.MasterCtrlr.gMapOctoFilesList.IsInitialized And mMainObj.MasterCtrlr.gMapOctoFilesList.Size > 0 Then
		Build_ListViewFileList
		'--- select the 1st item and load image
		clvFiles_ItemClick(0,mMainObj.MasterCtrlr.gMapOctoFilesList.GetKeyAt(0))
	Else
		clvFiles.Clear
		clvLastIndexClicked = cNO_SELECTION
		clvFiles_ItemClick(0,Null)
	End If
	
End Sub

Private Sub btnAction_Click
	
	If clvLastIndexClicked = cNO_SELECTION Then
		guiHelpers.Show_toast("No item selected",2500)
		Return
	End If
	
	Dim btn As B4XView : btn = Sender
	Select Case btn.Tag
		Case "delete"
			CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
			Dim sf As Object = xui.Msgbox2Async("Delete file from Octoprint?", "Question", "Yes - Delete It", "No", "", Null)
			Wait For (sf) Msgbox_Result (Result As Int)
			If Result = xui.DialogResponse_Positive Then
				SendDeleteCmdAndRemoveFromGrid
			End If
			CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",True)
			
		Case "load"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cPOST_FILES_SELECT.Replace("!LOC!",currentFileInfo.Origin).Replace("!PATH!",currentFileInfo.Name))
			btnDelete.Enabled = False
			
		Case "loadandprint"
			mMainObj.MasterCtrlr.cn.PostRequest(oc.cPOST_FILES_PRINT.Replace("!LOC!",currentFileInfo.Origin).Replace("!PATH!",currentFileInfo.Name))
			For Each btn As B4XView In Array As B4XView(btnLoad,btnLoadAndPrint,btnDelete)
				btn.Enabled = False
			Next
			guiHelpers.SetEnableDisableColor(Array As B4XView(btnLoad,btnLoadAndPrint,btnDelete))
			CallSubDelayed2(mMainObj,"Switch_Pages",gblConst.PAGE_PRINTING)
			
	End Select
		
End Sub

Public Sub Build_ListViewFileList()

	clvFiles.Clear
	clvLastIndexClicked = cNO_SELECTION
		
	CSelections.Initialize(clvFiles) '--- adds new selection modes
	CSelections.Mode = CSelections.MODE_SINGLE_ITEM_PERMANENT
	
	For ndx = 0 To mMainObj.MasterCtrlr.gMapOctoFilesList.Size - 1
	
		Dim o As typOctoFileInfo  = mMainObj.MasterCtrlr.gMapOctoFilesList.GetValueAt(ndx)
		clvFiles.InsertAt(ndx, _
					CreateListItem(o, clvFiles.AsView.Width, 60dip), mMainObj.MasterCtrlr.gMapOctoFilesList.GetKeyAt(ndx))
		
	Next
	
	clvFiles.PressedColor = 0x721F1C1C  '--- alpha sat to 128
	CSelections.SelectionColor = clvFiles.PressedColor
	clvFiles.DefaultTextColor =  clrTheme.txtNormal
	clvFiles.DefaultTextBackgroundColor = xui.Color_Transparent
	
	If clvFiles.Size > 0 Then
		'--- if we have data select the 1st one
		CSelections.ItemClicked(0)
	End If
	
End Sub

Sub CreateListItem(oData As typOctoFileInfo, Width As Int, Height As Int) As B4XView
	
	Dim p As B4XView = xui.CreatePanel("")
	'p.Color = xui.Color_Transparent
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("viewFiles")
	lblpnlFileViewTop.Text = fileHelpers.RemoveExtFromeFileName( oData.Name)
	lblpnlFileViewBottom.Text = "Size: " &   fileHelpers.BytesToReadableString(oData.Size) '& "Length: " & oData.Length
	Return p
	
End Sub

Private Sub SetThumbnail2Nothing
	ivPreview.Load(File.DirAssets,"no_thumbnail.jpg")
End Sub

Private Sub clvFiles_ItemClick (Index As Int, Value As Object)
	
	If Value = Null Then
		clvLastIndexClicked = cNO_SELECTION
		SetThumbnail2Nothing
		Return'ignore
	End If
	
	CSelections.ItemClicked(Index)
	clvLastIndexClicked = Index
	currentFileInfo =  mMainObj.MasterCtrlr.gMapOctoFilesList.Get(Value)
	
	If File.Exists(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk) = False Then
	
		guiHelpers.Show_toast("Getting Thumbnail",1500)
		logMe.LogIt("downloading missing thumbnail file; " & currentFileInfo.myThumbnail_filename_disk,mModule)
		Dim link As String = $"http://${mMainObj.MasterCtrlr.cn.gIP}:${mMainObj.MasterCtrlr.cn.gPort}/"$ & currentFileInfo.Thumbnail
		mMainObj.MasterCtrlr.cn.Download_AndSaveFile(link,currentFileInfo.myThumbnail_filename_disk)
		Sleep(1500)
		
		If File.Exists(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk) = False Then
			SetThumbnail2Nothing
		Else
			ivPreview.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
		End If
		
	Else
		ivPreview.Load(xui.DefaultFolder,currentFileInfo.myThumbnail_filename_disk)
		
	End If
	
	If Value = oc.JobFileName And oc.isPrinting Then
		btnDelete.Enabled = False
	Else
		btnDelete.Enabled = True
	End If

End Sub

#region "FILES_CHANGED_CHECK"

Public Sub CheckIfFilesChanged
	
	If FilesCheckChangeIsBusyFLAG Then Return
	
	Dim oldListViewSize As Int = clvFiles.Size
		
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",False)
	FilesCheckChangeIsBusyFLAG = True
	
	'logMe.Logit("tmrFilesCheckChange.Enabled = False  -->  START CHECK",mModule)

	'--- grab a list of files
	Dim rs As ResumableSub =  mMainObj.MasterCtrlr.cn.SendRequestGetInfo( oc.cFILES)
	Wait For(rs) Complete (Result As String)
	
	If Result.Length <> 0 Then
	
		'--- compre new list with old
		Dim o As JsonParserFiles  : o.Initialize(False) '--- DO NOT download thumbnails
		Dim didChange As Boolean  = o.CheckIfChanged( Result,mMainObj.MasterCtrlr.gMapOctoFilesList)
		
		If didChange Then
			
			'--- ok, something changed,  delete - removed thumbnails
			logMe.Logit("did change - YES ;)",mModule)
			Dim mapNewFileList As Map = o.GetAllFiles(Result)
			ProcessThumbnails(mapNewFileList)
			
			'--- refresh the old list with new changes
			mMainObj.MasterCtrlr.gMapOctoFilesList = o.GetAllFiles(Result)
			'logMe.Logit("refresh original File list",mModule)
			
			Build_ListViewFileList
	
'			If mainObj.gMapOctoFilesList.Size > 0 Then
'				clvFiles_ItemClick(0,mainObj.gMapOctoFilesList.GetKeyAt(0))
			''			Else
			''				clvFiles_ItemClick(0,Null)
'			End If
			
		Else
			
			'--- nothing new, bail
			logMe.Logit("did change --- NO!!!!!!!!!!",mModule)
'			FilesCheckChangeIsBusyFLAG = False
'			tmrFilesCheckChange.Enabled = True
'			Log("tmrFilesCheckChange.Enabled = True  -->  END CHECK")
'			Return
			
		End If
		
	End If
	
	FilesCheckChangeIsBusyFLAG = False
	CallSub2(Main,"TurnOnOff_FilesCheckChangeTmr",True)
	'logMe.Logit("tmrFilesCheckChange.Enabled = True  -->  END CHECK",mModule)
	
	If oldListViewSize <> clvFiles.Size Then
		'--- highllight the first row
		Sleep(200)
		clvFiles_ItemClick(0,mMainObj.MasterCtrlr.gMapOctoFilesList.GetKeyAt(0))
		Sleep(200)
	End If
	
End Sub


private Sub ProcessThumbnails(NewMap As Map)
	
	Try
	
		'--- remove any old thumbnail files
		Dim deletedFiles As Int = 0
		logMe.Logit("ProcessThumbnails - start - remove any old thumbnail files",mModule)
		For Each oldMap As typOctoFileInfo In mMainObj.MasterCtrlr.gMapOctoFilesList.Values
			
			Dim oldMapKey As String = oldMap.Name
			If NewMap.ContainsKey(oldMapKey) = False Then
				
				logMe.Logit("deleted old thumbnail: " & oldMap.myThumbnail_filename_disk,mModule)
				fileHelpers.SafeKill(oldMap.myThumbnail_filename_disk)
				deletedFiles = deletedFiles + 1
				
			End If
			
		Next
		
	Catch
		Log(LastException)
	End Try
	logMe.Logit("ProcessThumbnails - END - remove any old thumbnail files: #" & deletedFiles,mModule)
	
	
	logMe.Logit("ProcessThumbnails - START - download new thumbnails for new and changed files",mModule)
	Try

		Dim changedFiles = 0, NewFiles = 0 As Int
		'--- download new thumbnails for new and changed files
		For Each oNewMap As typOctoFileInfo In NewMap.Values

			Dim mapKey As String = oNewMap.Name
			If mMainObj.MasterCtrlr.gMapOctoFilesList.ContainsKey(mapKey) = True Then

				'---  found a file, BUT... has the date changed?
				Dim ffFileToWorkOn As typOctoFileInfo = mMainObj.MasterCtrlr.gMapOctoFilesList.get(mapKey)
				If ffFileToWorkOn.Date <> oNewMap.Date Then '--- date changed
				
					logMe.Logit("refreshing old thumbnail: " & oNewMap.Name,mModule)
					fileHelpers.SafeKill(ffFileToWorkOn.myThumbnail_filename_disk)
					changedFiles = changedFiles + 1
					mMainObj.MasterCtrlr.Download_ThumbnailAndCache2File(oNewMap.Thumbnail,oNewMap.myThumbnail_filename_disk)
					
				End If
				
			Else

				'--- new file, need thumbnail
				NewFiles = NewFiles + 1
				logMe.Logit("downloading new thumbnail; " & oNewMap.name,mModule)
				mMainObj.MasterCtrlr.Download_ThumbnailAndCache2File(oNewMap.Thumbnail,oNewMap.myThumbnail_filename_disk)
								
			End If
		
		Next
			
	Catch
		Log(LastException)
	End Try
	logMe.Logit("ProcessThumbnails - END - download new thumbnails for new and changed files",mModule)
	logMe.Logit("files changed #" & changedFiles & "   files new #" & NewFiles,mModule)
	
	
End Sub
#end region



Private Sub SendDeleteCmdAndRemoveFromGrid
	
	mMainObj.MasterCtrlr.cn.DeleteRequest(oc.cDELETE_FILES_DELETE.Replace("!LOC!",currentFileInfo.Origin).Replace("!PATH!",currentFileInfo.Name))
	Sleep(500)
	
	guiHelpers.Show_toast("Deleting File",1000)
	
	'--- delete from thumbnail cache
	fileHelpers.SafeKill (currentFileInfo.myThumbnail_filename_disk)
	
	'--- remove from grid
	clvFiles.RemoveAt(clvLastIndexClicked)
	CSelections.SelectedItems.Remove(clvLastIndexClicked)
	mMainObj.MasterCtrlr.gMapOctoFilesList.Remove(currentFileInfo.Name)
	Sleep(200)
	
	Dim ff As typOctoFileInfo

	If clvFiles.Size > 1 Then
		If clvLastIndexClicked <> 0 Then
			clvLastIndexClicked = clvLastIndexClicked - 1
		End If
		ff = mMainObj.MasterCtrlr.gMapOctoFilesList.GetValueAt(clvLastIndexClicked)
		clvFiles_ItemClick(clvLastIndexClicked,ff.name)
		
	Else if clvFiles.Size = 1 Then
		ff = mMainObj.MasterCtrlr.gMapOctoFilesList.GetValueAt(0)
		clvFiles_ItemClick(0,ff.name)
		clvLastIndexClicked = 0
		
	Else
		clvFiles_ItemClick(0,Null)
	End If
	
End Sub
