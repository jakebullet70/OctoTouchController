B4A=true
Group=PAGE_VIEWS
ModulesStructureVersion=1
Type=Class
Version=11.8
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	Aug/6/2022 - Kherson Ukraine
#End Region
Sub Class_Globals
	
	Private Const mModule As String = "pageHeater" 'ignore
	Private mPnlMain As B4XView
	Private mCallBackEvent As String 'ignore
	Private  mMainObj As B4XMainPage'ignore
	
	Private mTempatureUpdatingByRestAPI As Boolean = False
	Private mTempatureCboUpdatedByRestAPI As Boolean = False
	Private mapBedHeatingOptions, mapToolHeatingOptions,mapAllHeatingOptions As Map

End Sub

Public Sub Initialize(masterPanel As B4XView,callBackEvent As String)
	
	mPnlMain = masterPanel
	mCallBackEvent = callBackEvent
	mMainObj = B4XPages.MainPage
	
	mPnlMain.LoadLayout("pageHeater")
	
	CallSubDelayed(Me,"Build_GUI")
	
End Sub

public Sub Set_focus()
	mPnlMain.Visible = True
End Sub

public Sub Lost_focus()
	mPnlMain.Visible = False
End Sub


Private Sub Build_GUI

	Set_HeatingCBOoptions(mMainObj.MasterCtrlr.gMapOctoTempSettings)
	
End Sub
'	CallSub2(mMainObj,mCallBackEvent,oo.Tag2)


public Sub Update_Printer_Btns
	'--- sets enable, disable
	
End Sub





public Sub Set_HeatingCBOoptions(mapOfOptions As Map)
	
	'--- can also be called from the REST API, populates the pre-heaters options
	
	If mTempatureCboUpdatedByRestAPI = True Then Return '--- allready happened, just is case ;)

	'--- clear them out
	mapBedHeatingOptions.Initialize
	mapToolHeatingOptions.Initialize
	mapAllHeatingOptions.Initialize
		
	Dim allOff As String = "** All Off **"
'	#if b4a or b4i
'	Dim cs As CSBuilder : cs.Initialize '--- not used. HATES B4J!
'	#end if
	
'	#if b4a or b4j
'	tmpListBed.Add(cs.Initialize.BackgroundColor(clrTheme.DialogButtonsColor).Alignment("ALIGN_CENTER").Bold _
'			.Color(clrTheme.DialogButtonsTextColor) _ 
'			.Append("  Bed Options  ").PopAll)
'	#else
'	tmpListBed.Add("Bed Options") '--- just a header
'	#end if

	mapBedHeatingOptions.Put(allOff,"alloff")
	mapBedHeatingOptions.Put("Bed Off","bedoff")
	
	mapToolHeatingOptions.Put(allOff,"alloff")
	mapToolHeatingOptions.Put("Tool Off","tooloff")
		
	mapAllHeatingOptions.Put(allOff,"alloff")
	
	Dim cboStr As String
	Dim FilamentType As String
	Dim tmp,ToolTemp As String
	Dim BedTemp As String
	
	Try
		For x  = 0 To mapOfOptions.Size - 1
		
			FilamentType = mapOfOptions.GetKeyAt(x)
			tmp = mapOfOptions.GetValueAt(x)
			ToolTemp = Regex.Split("!!",tmp)(0)
			BedTemp = Regex.Split("!!",tmp)(1)
			
			'--- build string for CBO
			cboStr = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapToolHeatingOptions.Put(cboStr,cboStr)
			
			cboStr = $"Set ${FilamentType} (Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapBedHeatingOptions.Put(cboStr,cboStr)
			
			cboStr = $"Set ${FilamentType} (Tool: ${ToolTemp}${gblConst.DEGREE_SYMBOL}C  / (Bed: ${BedTemp}${gblConst.DEGREE_SYMBOL}C )"$
			mapAllHeatingOptions.Put(cboStr,cboStr)
		
		Next
	Catch
		
		logMe.LogIt(LastException,mModule)
		
	End Try
	
	mTempatureCboUpdatedByRestAPI = True
	
End Sub

