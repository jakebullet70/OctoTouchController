B4A=true
Group=GENERIC
ModulesStructureVersion=1
Type=StaticCode
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.Whatever 	June-Nov/2022
#End Region
Sub Process_Globals
	
	Public Const API_ANDROID_4_0 As Int = 14
	Public Const API_ANDROID_4_4 As Int = 19
	
	Public Const DEGREE_SYMBOL As String = "°" 
		
	#if not (klipper)
	Public const APP_TITLE As String = "OctoTC ™"
	Private Const WEB_ADDR As String = "http://sadlogic.com/octotouchcontroller/"
	Public Const APK_NAME As String         = WEB_ADDR & "MoonrakerTouchController.apk"
	Public Const APK_FILE_INFO As String = WEB_ADDR & "MoonrakerTouchController.txt"
	#else
	Public const APP_TITLE As String = "MoonrakerTC ™"
	Private Const WEB_ADDR As String = "http://sadlogic.com/moonrakertouchcontroller/"
	Public Const APK_NAME As String         = WEB_ADDR & "OctoTouchController.apk"
	Public Const APK_FILE_INFO As String = WEB_ADDR & "OctoTouchController.txt"
	#End If

	
	Public Const NO_THUMBNAIL As String = "no_thumbnail.jpg"
	Public Const SELECTED_CLR_THEME As String = "themeclr" '--- selected theme color
	Public Const CUSTOM_THEME_COLORS As String = "customClrs" '--- users custom colors
	
	#if klipper
	Public Const psetupPRINTER_DESC As String = "desc"
	Public Const psetupPRINTER_IP As String = "ip"
	Public Const psetupPRINTER_PORT As String = "port"
	Public Const psetupPRINTER_X As String = "bx"
	Public Const psetupPRINTER_Y As String = "by"
	#else
	Public Const PRINTER_SETTING_BASE_FILE_NAME As String = "p_settings"
	Public Const PRINTER_DESC As String = "desc"
	Public Const PRINTER_IP As String = "ip"
	Public Const PRINTER_PORT As String = "port"
	Public Const PRINTER_OCTO_KEY As String = "octokey"
	#End If
	
	'---------------------------------------------------------------------------------------------------------------------
	
	'--- data in kvs PWRControl -------------------------------------------------------------------------------
	Public Const PWR_SONOFF_IP As String = "pwr_sonoff_ip"
	Public Const PWR_CTRL_ON As String = "pwr_on"
	Public Const PWR_PSU_PLUGIN As String = "pwr_psu_on"
	Public Const PWR_SONOFF_PLUGIN As String = "pwr_sonoff_on"
	'---------------------------------------------------------------------------------------------------------------------
	
	Public Const CHECK_VERSION_DATE As String = "chk_v_dt"
	
	'---------------------------------------------------------------------------------------------------------------------
	'--- Plugins - ZLED and WS281
	Public Const ZLED_CTRL_ON As String = "sTurnOn"
	Public Const ZLED_ENDPOINT As String = "sEP"
	Public Const ZLED_CMD_ON As String = "sOn"
	Public Const ZLED_CMD_OFF As String = "sOff"
	'--- above const used in both configs below
	Public Const ZLED_OPTIONS_FILE As String = "zled_options.map"
	Public Const WS281_OPTIONS_FILE As String = "ws281_options.map"
	'---------------------------------------------------------------------------------------------------------------------
	
	'---------------------------------------------------------------------------------------------------------------------
	'--- saved data for pref dialogs
	Public Const ANDROID_POWER_OPTIONS_FILE As String = "power_options.map"
	Public Const GENERAL_OPTIONS_FILE As String = "general_options.map"
	Public Const FILAMENT_CHANGE_FILE As String = "fil_loadunload.map"
	Public Const BED_LEVEL_FILE As String = "bed_level.map"
	Public Const PRINTER_SETUP_FILE As String = "printer_setup.map"
	'---------------------------------------------------------------------------------------------------------------------
	
	'--- pages
	Public Const PAGE_PRINTING As String = "ppr"
	Public Const PAGE_FILES As String = "pfi"
	Public Const PAGE_MAIN As String = "MainPage"
	Public Const PAGE_MOVEMENT As String = "mve"
	Public Const PAGE_MENU As String = "mnu"
	
	'--- misc
	Public Const NO_FILE_LOADED As String = " No file loaded"
	Public Const NOT_CONNECTED As String = "No Connection"
	Public Const WIN_CRLF As String = Chr(10) & Chr(13)
	
	'--- msgbox
	Public Const MB_ICON_WARNING As String = "mb_stop.png"
	Public Const MB_ICON_INFO As String = "mb_info.png"
	Public Const MB_ICON_QUESTION As String = "mb_question.png"

	'--- android pre 4 action bar	
	Public Const ACTIONBAR_OFF As Int = 1
	Public Const ACTIONBAR_ON As Int = 0

	'---------------------------------------------------------------------------------------------------------------------
	'--- Filament wizard ---
	Public Const filHomeBeforePark As String = "hbp",filRetractBeforePark As String = "rbp"
	Public Const filPauseBeforePark As String = "pbp"
	Public Const filUnloadLen As String = "ulen",filUnloadSpeed As String = "uspd"
	Public Const filLoadLen As String = "llen", filLoadSpeed As String = "lspd"
	Public Const filYPark As String = "yp",filXPark As String = "xp"
	Public Const filZLiftRel As String = "zrel", filParkSpeed As String = "pmspd"
	Public Const filShow As String = "mnu", filSmallExtBeforeUload As String = "extb"
	
	'---------------------------------------------------------------------------------------------------------------------
	'--- bed level wizard ---
	Public Const bedXYspeed As String = "xyspeed"
	Public Const bedZspeed As String = "zspeed"
	Public Const bedXYoffset As String = "xyoffset"
	Public Const bedLevelHeight As String = "zlheight"
	Public Const bedTravelHeight As String = "ztheight"
	Public Const bedShow As String = "mnu"
	Public Const bedStartGcode As String = "sgcode"
	Public Const bedEndGCode As String = "egcode"
	
	
End Sub
