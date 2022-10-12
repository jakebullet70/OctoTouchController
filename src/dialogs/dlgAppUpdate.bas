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
	Private oFTP As ftp_support
	
End Sub


Public Sub Initialize(parentObj As B4XView)
	
	mMainObj = parentObj
	
	BasePnl = xui.CreatePanel("")
	BasePnl.SetLayoutAnimated(0, 0, 0, 360dip,240dip)
	BasePnl.LoadLayout("viewAppUpdate")
	
	lblAction.TextColor = clrTheme.txtNormal
	lblAction.Text = "Checking for update..."
	btnContinue.Visible = False
	
	lblPB.Visible   = False
	lblPB.TextColor = clrTheme.txtNormal
	
End Sub


Public Sub Show() As ResumableSub
	
	'--- init dialog
	mDialog.Initialize(mMainObj)
	
	guiHelpers.ThemeDialogForm(mDialog, "App Update")
	Dim rs As ResumableSub = mDialog.ShowCustom(BasePnl,"","","CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)
	
	'--- grab the txt file with version info
	oFTP.Initialize(Me,"ftp_done","ftp_progress","192.168.1.230",21,"","")
	oFTP.CleanUpApkDownload
	oFTP.Download(gblConst.APK_FILE_INFO,"",True)

	'--- wait for dialog	
	Wait For (rs) Complete (Result As Int)
	
	oFTP.ftp.Close '--- make sure it is closed
	Return Result
	
End Sub


Public Sub ftp_progress(totalDloaded As Long)
	
	If lblPB.Visible = False Then Return
	lblPB.Text = fileHelpers.BytesToReadableString(totalDloaded)
	'Sleep(0)
	
End Sub


Public Sub ftp_done(m As Map)
	
	If m.Get("ok") = False Then
		lblAction.BaseLabel.Height = lblAction.BaseLabel.Height + 20dip
		lblAction.Text = "Error talking to update server." & CRLF & m.Get("err")
		Return
	End If
	
	If m.Get("file") = gblConst.APK_FILE_INFO Then
		ParseVerTextFile
	Else 
		'--- we have the APK, install it
		Starter.tmrTimerCallSub.CallSubDelayedPlus2(Main,"Start_ApkInstall",400,Array As String(oFTP.DownloadDir))
		mDialog.Close(-1) '--- close me, exit dialog
	End If
	
End Sub


Private Sub btnCtrl_Click
	
	'--- continue, download the APK
	Dim btn As B4XView = mDialog.GetButton(xui.DialogResponse_Cancel)
	btn.Text = "CANCEL"
	btnContinue.Visible = False
	lblPB.Visible = True
	lblPB.Text = "Connecting..."
	oFTP.Initialize(Me,"ftp_done","ftp_progress","192.168.1.230",21,"","")
	oFTP.Download(gblConst.APK_NAME,"",False)
	
End Sub


Private Sub ParseVerTextFile
	
	Dim txt As String = File.ReadString(oFTP.DownloadDir,gblConst.APK_FILE_INFO)
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


