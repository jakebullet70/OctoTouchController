B4A=true
Group=DIALOGS_POPUPS
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
' Author:  sadLogic - Kherson, Ukraine
#Region VERSIONS 
' V. 1.0 	Oct/11/2022
#End Region

Sub Class_Globals
	
	Private const mModule As String = "dlgAppUpdate"' 'ignore
	Private mMainObj As B4XView
	Private xui As XUI
	
	Private BasePnl As B4XView, mDialog As B4XDialog
	Private lblAction As AutoTextSizeLabel,lblPB As Label
	
	Private btnContinue As B4XView

	'Private oFTP As ftp_support
	
End Sub

Public Sub CleanUpApkDownload
	
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_NAME)
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_FILE_INFO)
	fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.APK_NAME)
	fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.APK_FILE_INFO)
		
End Sub



Public Sub Initialize(parentObj As B4XView)
	
	mMainObj = parentObj
	
End Sub


Public Sub Show() As ResumableSub
	
	CleanUpApkDownload
	BasePnl = xui.CreatePanel("")
	BasePnl.SetLayoutAnimated(0, 0, 0, 360dip,240dip)
	BasePnl.LoadLayout("viewAppUpdate")
	
	lblAction.TextColor = clrTheme.txtNormal
	lblAction.Text = "Checking for update..."
	btnContinue.Visible = False
	
	lblPB.Visible   = False
	lblPB.TextColor = clrTheme.txtNormal
	
	
	'--- init dialog
	mDialog.Initialize(mMainObj)
	
	guiHelpers.ThemeDialogForm(mDialog, "App Update")
	Dim rs As ResumableSub = mDialog.ShowCustom(BasePnl,"","","CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)
	
	'--- grab the txt file with version info
	Starter.tmrTimerCallSub.CallSubPlus(Me,"GrabVerInfo",250)

	'--- wait for dialog	
	Wait For (rs) Complete (Result As Int)
	
	'oFTP.ftp.Close '--- make sure it is closed
	Return Result
	
End Sub


Private Sub GrabVerInfo
	
	Dim sm As HttpDownloadStr : sm.Initialize
	Wait For (sm.SendRequest(gblConst.APK_FILE_INFO)) Complete(txt As String)
	
	If txt.Contains("vcode=") = False Then
		lblAction.BaseLabel.Height = lblAction.BaseLabel.Height + 20dip
		lblAction.Text = "Error talking to update server."
		Return
	End If
	
	
	txt = txt.Replace(Chr(13),"") '--- strip the chr(13) in case its a Windows file
	
	Try
		
		Dim parts() As String = Regex.Split(CRLF,txt)
		Dim VerCode As String = Regex.Split("=",parts(0))(1)
		
		If VerCode.As(Int) <= Application.VersionCode Then
			lblAction.Text = "No update found."
			Return
		End If
		
		lblAction.BaseLabel.Top = lblAction.BaseLabel.Top - 6dip
		lblAction.Text = $"Update found: V${Regex.Split("=",parts(1))(1)}"$
		btnContinue.Visible = True
		btnContinue.Text = "Download"
		
	Catch
		
		Log(LastException)
		lblAction.Text = "Error parsing update file."
		
	End Try
	
	
End Sub




Private Sub btnCtrl_Click
	
	'--- continue, download the APK
	Dim btn As B4XView = mDialog.GetButton(xui.DialogResponse_Cancel)
	btn.Visible = False
	btnContinue.Visible = False
	'lblPB.Visible = True
	lblAction.Text = "Downloading Update..."
	
		
	Dim DownloadDir As String = GetDownloadDir 'ignore
	
	Dim j As HttpJob : j.Initialize("", Me)
	
	j.Download(gblConst.APK_NAME)
	Wait For (j) JobDone(j As HttpJob)
	Sleep(0)
	
	If j.Success Then
		
		lblAction.Text = "Writing file..."
		Sleep(300)
		
		Dim out As OutputStream = File.OpenOutput(DownloadDir, _
				fileHelpers.GetFilenameFromPath(gblConst.APK_NAME), False)
				
		File.Copy2(j.GetInputStream, out)
		out.Close '<------ very important
		
		Starter.tmrTimerCallSub.CallSubDelayedPlus2(Main,"Start_ApkInstall",400,Array As String(DownloadDir))
		
		j.Release
		mDialog.Close(-1) '<--- close me, exit dialog
		Return

	Else
		
		Dim err As String = ""
		'--- if end point is bad it will have errored aot at downloading the ver text file
		If j.ErrorMessage.Contains("File not") Then err = "File not found"
		lblAction.Text = "Download failed" & CRLF & err
		
	End If
	
	j.Release
	
End Sub


Private Sub GetDownloadDir() As String
	
	'--- its an android 6.x thing...
	
	Try
		Dim ph As Phone
		If ph.SdkVersion >= 24 Then
			Dim dl As String = Starter.Provider.SharedFolder
			File.WriteString(dl,"t.t","test")
			File.Delete(dl,"t.t")
			Return dl '--- all good
		End If
		
	Catch
		'Log(LastException)
	End Try 'ignore
	
	Return xui.DefaultFolder
	
End Sub






