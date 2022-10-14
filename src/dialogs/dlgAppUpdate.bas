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
	
	Private Const DAYS_BETWEEN_CHECKS As Int = 1

End Sub

Public Sub CleanUpApkDownload
	
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_NAME)
	fileHelpers.SafeKill2(Starter.Provider.SharedFolder,gblConst.APK_FILE_INFO)
	fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.APK_NAME)
	fileHelpers.SafeKill2(xui.DefaultFolder,gblConst.APK_FILE_INFO)
		
End Sub


Public Sub CheckIfNewDownloadAvail()As ResumableSub
	
	Dim inSub As String = "CheckIfNewDownloadAvail"
	
	Dim oldDate As Long = Starter.kvs.GetDefault(gblConst.CHECK_VERSION_DATE,0)
	If oldDate = 0 Then
		Starter.kvs.Put(gblConst.CHECK_VERSION_DATE,DateTime.Now) '<-- never been run so save date
		Return False
	End If
	
'	Dim p As Period : p.Days = -16 ' TESTING
'	Dim tdate As Long = DateUtils.AddPeriod(DateTime.Now, p)
'	Starter.kvs.Put(gblConst.CHECK_VERSION_DATE,tdate)
'	oldDate = Starter.kvs.GetDefault(gblConst.CHECK_VERSION_DATE,0)
	
	Try
		
		Log(DateUtils.PeriodBetweenInDays(oldDate,DateTime.Now).As(Period).Days)
		If DateUtils.PeriodBetweenInDays(oldDate,DateTime.Now).As(Period).Days < DAYS_BETWEEN_CHECKS Then
			Return False
		End If
		
	Catch
		
		logMe.LogIt2(LastException.Message,mModule,inSub)
		Return False
		
	End Try
	
	
	Dim sm As HttpDownloadStr : sm.Initialize
	Wait For (sm.SendRequest(gblConst.APK_FILE_INFO)) Complete(txt As String)
	
	If txt.Contains("vcode=") = False Then Return False
	txt = txt.Replace(Chr(13),"") '<-- strip the chr(13) in case its a Windows file
	
	
	Try
		
		Starter.kvs.Put(gblConst.CHECK_VERSION_DATE,DateTime.Now) '--- save version check date
		Dim parts() As String = Regex.Split(CRLF,txt)
		Dim VerCode As String = Regex.Split("=",parts(0))(1)
		
		Return (VerCode.As(Int) > Application.VersionCode)
		
	Catch
		
		logMe.LogIt2(LastException.Message,mModule,inSub)
		Return False
		
	End Try
	
End Sub


Public Sub Initialize(parentObj As B4XView)
	
	mMainObj = parentObj
	
End Sub


Public Sub Show() As ResumableSub
	
	CleanUpApkDownload
	BasePnl = xui.CreatePanel("")
	BasePnl.SetLayoutAnimated(0, 0, 0, 360dip ,260dip)
	BasePnl.LoadLayout("viewAppUpdate")
	
	lblAction.TextColor = clrTheme.txtNormal
	lblAction.Text = "Checking for update..."
	btnContinue.Visible = False
	lblPB.Visible   = False
	lblPB.TextColor = clrTheme.txtNormal

	'---TODO, make a generic function
	btnContinue.Font = xui.CreateDefaultFont(NumberFormat2(btnContinue.TextSize / guiHelpers.gFscale,1,0,0,False) - IIf(guiHelpers.gFscale > 1,2,0))
		
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

	'--- save version check date
	Starter.kvs.Put(gblConst.CHECK_VERSION_DATE,DateTime.Now)
	
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
		
		logMe.LogIt2(LastException.Message,mModule,"GrabVerInfo")
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
		Sleep(200)
		
		Dim out As OutputStream = File.OpenOutput(DownloadDir, _
				fileHelpers.GetFilenameFromPath(gblConst.APK_NAME), False)
				
		File.Copy2(j.GetInputStream, out)
		out.Close '<------ very important
		j.Release
		Sleep(200)
		
		Starter.tmrTimerCallSub.CallSubDelayedPlus2(Main,"Start_ApkInstall",300,Array As String(DownloadDir))
		
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
	
	'--- its an android version thing...
	Dim dl As String
	Try

		dl = Starter.Provider.SharedFolder
		File.WriteString(dl,"t.t","test")
		File.Delete(dl,"t.t")
		
	Catch
		
		dl = xui.DefaultFolder
		
	End Try 'ignore
	
	logMe.LogIt("App update folder: " & dl, mModule)
	Return dl '--- all good
	
End Sub






