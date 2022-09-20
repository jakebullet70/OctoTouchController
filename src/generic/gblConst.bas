B4A=true
Group=GENERIC
ModulesStructureVersion=1
Type=StaticCode
Version=11.5
@EndOfDesignText@
' Author:  sadLogic
#Region VERSIONS 
' V. 1.0 	June/7/2022
#End Region
Sub Process_Globals
	
	Public Const DEGREE_SYMBOL As String = "°" 
	Public const APP_TITLE As String = "OctoTC ™"
	Public const VERSION As String = "V1.0.0 - Beta 4"
	Public Const PRINTER_SETTING_BASE_FILE_NAME As String = "p_settings"
	
	Public Const PRINTER_DESC As String = "desc"
	Public Const PRINTER_IP As String = "ip"
	Public Const PRINTER_PORT As String = "port"
	Public Const PRINTER_OCTO_KEY As String = "octokey"
	
	Public Const PWR_SONOFF_IP As String = "pwr_sonoff_ip"
	Public Const PWR_CTRL_ON As String = "pwr_on"
	Public Const PWR_PSU_PLUGIN As String = "pwr_psu_on"
	Public Const PWR_SONOFF_PLUGIN As String = "pwr_sonoff_on"
	
	Public Const POWER_OPTIONS_FILE As String = "power_options.map"
	Public Const GENERAL_OPTIONS_FILE As String = "general_options.map"
	
	Public Const PAGE_PRINTING As String = "ppr"
	Public Const PAGE_FILES As String = "pfi"
	Public Const PAGE_MAIN As String = "MainPage"
	Public Const PAGE_MOVEMENT As String = "mve"
	Public Const PAGE_MENU As String = "mnu"
	
	Public Const NO_FILE_LOADED As String = " No file loaded"
	
	Public Const WIN_CRLF As String = Chr(10) & Chr(13)
	
	Public Const MB_ICON_WARNING As String = "mb_stop.png"
	Public Const MB_ICON_INFO As String = "mb_info.png"
	Public Const MB_ICON_QUESTION As String = "mb_question.png"
	
	Public Const ACTIONBAR_OFF As Int = 1
	Public Const ACTIONBAR_ON As Int = 0
	
End Sub