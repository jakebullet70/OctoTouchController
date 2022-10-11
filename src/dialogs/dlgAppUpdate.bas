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
	
	Private lblAction As AutoTextSizeLabel
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
	
End Sub

Public Sub Show() As ResumableSub
	
	'--- init
	mDialog.Initialize(mMainObj)
	
	guiHelpers.ThemeDialogForm(mDialog, "App Update")
	Dim rs As ResumableSub = mDialog.ShowCustom(BasePnl,"","","CLOSE")
	guiHelpers.ThemeInputDialogBtnsResize(mDialog)
	'guiHelpers.AnimateDialog(mDialog,"top")
	
	'--- grab the txt file with version info
	oFTP.Initialize(Me,"ftp_done","192.168.1.230",21,"","")
	oFTP.CleanUpApkDownload
	Wait For (oFTP.Download(gblConst.APK_FILE_INFO,"",True)) Complete (r1 As Object)
	
	Wait For (rs) Complete (Result As Int)
	
	oFTP.ftp.Close '--- close it if left open
	Return Result
	
End Sub


Public Sub ftp_done(success As Boolean,filenameDownloaded As String)
	
	If success = False Then
		lblAction.Text = "Error conecting to update server."
		Return
	End If
	
	If filenameDownloaded = gblConst.APK_FILE_INFO Then
		ParseVerTextFile
	Else
		
	End If
	
End Sub


Private Sub btnCtrl_Click
	'--- continue, download the APP
End Sub


Private Sub ParseVerTextFile
	
	Dim txt As String = File.ReadString(Starter.Provider.SharedFolder,gblConst.APK_FILE_INFO)
	txt = txt.Replace(Chr(13),"") '--- strip the chr(13) in case its a Windows file
	
	Try
		
		Dim parts() As String = Regex.Split(CRLF,txt)
		Dim VerCode As String = Regex.Split("=",parts(0))(0)
		
		If VerCode.As(Int) <= Application.VersionCode Then
			lblAction.Text = "No update found."
			Return
		End If
		
		lblAction.Text = $"Update found."$
		btnContinue.Visible = True
		btnContinue.Text = "Download?"
		
	Catch
		Log(LastException)
		lblAction.Text = "Error parsing update file."
	End Try
	
End Sub




