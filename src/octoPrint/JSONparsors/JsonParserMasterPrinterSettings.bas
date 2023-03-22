B4J=true
Group=OCTOPRINT\PARSORS
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
' Author:  sadLogic, Kherson Ukraine
#Region VERSIONS 
' V. 1.0 	June/27/2022
#End Region
Sub Class_Globals
	Private Const mModule As String = "JsonParserMasterPrinterSettings"
	
	'--- get the heating profiles setup in octoprint
	Public mapHeatingPresets As Map
	
End Sub


Public Sub Initialize
End Sub


Public Sub GetPresetHeaterSettings(MasterJsonTXT As String) As Map
	
	ParseMasterSettings(MasterJsonTXT)
	Return mapHeatingPresets
	
End Sub


private Sub ParseMasterSettings(jsonTXT As String)
	
	Dim inSub As String	= "ParseMasterSettings"
	Dim parser As JSONParser : parser.Initialize(jsonTXT)
	Log(jsonTXT)
	Dim root As Map = parser.NextObject
	'Dim oc_server As Map = root.Get("server") 'ignore
	
	Dim temperature As Map = root.Get("temperature")
	'Dim sendAutomaticallyAfter As Int = temperature.Get("sendAutomaticallyAfter") 'ignore
	'Dim sendAutomatically As String = temperature.Get("sendAutomatically") 'ignore
	
	mapHeatingPresets.Initialize
	Try
		Dim profiles As List = temperature.Get("profiles")
		For Each colprofiles As Map In profiles
			Dim pBedTemp As String = colprofiles.Get("bed")
			'Dim pChamber As String = colprofiles.Get("chamber")
			Dim pNameDesc As String = colprofiles.Get("name")
			Dim pExtruderTemp As String = colprofiles.Get("extruder")
			mapHeatingPresets.Put(pNameDesc,pExtruderTemp & "!!" & pBedTemp )
		Next
		
	Catch
		
		logMe.LogIt2(LastException,mModule,inSub)
		
	End Try
	
	Return
	
#region "REMMED_OUT 00"
	
'	Dim allowFraming As String = oc_server.Get("allowFraming")
	
'	Dim pluginBlacklist As Map = oc_server.Get("pluginBlacklist")
'	Dim pluginBlacklist_ttl As Int = pluginBlacklist.Get("ttl")
'	Dim pluginBlacklist_enabled As String = pluginBlacklist.Get("enabled")
'	Dim pluginBlacklist_url As String = pluginBlacklist.Get("url")
	
'	Dim diskspace As Map = oc_server.Get("diskspace")
'	Dim diskspace_critical As Int = diskspace.Get("critical")
'	Dim diskspace_warning As Int = diskspace.Get("warning")
	
'	Dim cmds As Map = oc_server.Get("commands")
'	Dim cmds_serverRestartCommand As String = cmds.Get("serverRestartCommand")
'	Dim cmds_systemShutdownCommand As String = cmds.Get("systemShutdownCommand")
'	Dim cmds_systemRestartCommand As String = cmds.Get("systemRestartCommand")
'	
	
'	Dim onlineCheck As Map = oc_server.Get("onlineCheck")
'	Dim port As Int = onlineCheck.Get("port")
'	Dim host As String = onlineCheck.Get("host")
'	Dim name As String = onlineCheck.Get("name")
'	Dim interval As Int = onlineCheck.Get("interval")
'	Dim enabled As String = onlineCheck.Get("enabled")
'	
	
'	Dim slicing As Map = root.Get("slicing")
'	Dim defaultSlicer As String = slicing.Get("defaultSlicer")
	
'	Dim terminalFilters As List = root.Get("terminalFilters")
'	For Each colterminalFilters As Map In terminalFilters
'		Dim Regex1 As String = colterminalFilters.Get("regex")
'		Dim name As String = colterminalFilters.Get("name")
'	Next
	
'	Dim plugins As Map = root.Get("plugins")
'	Dim eventmanager As Map = plugins.Get("eventmanager")
'	Dim availableEvents As List = eventmanager.Get("availableEvents")
'	For Each colavailableEvents As String In availableEvents
'	Next
'	Dim subscriptions As List = eventmanager.Get("subscriptions")
'	Dim firmware_check As Map = plugins.Get("firmware_check")
'	Dim ignore_infos As String = firmware_check.Get("ignore_infos")
'	Dim backup As Map = plugins.Get("backup")
'	Dim restore_unsupported As String = backup.Get("restore_unsupported")
'	Dim pluginmanager As Map = plugins.Get("pluginmanager")
'	Dim notices As String = pluginmanager.Get("notices")
'	Dim confirm_disable As String = pluginmanager.Get("confirm_disable")
'	Dim dependency_links As String = pluginmanager.Get("dependency_links")
'	Dim pip_force_user As String = pluginmanager.Get("pip_force_user")
'	Dim hidden As List = pluginmanager.Get("hidden")
'	Dim notices_ttl As Int = pluginmanager.Get("notices_ttl")
'	Dim repository_ttl As Int = pluginmanager.Get("repository_ttl")
'	Dim ignore_throttled As String = pluginmanager.Get("ignore_throttled")
'	Dim pip_args As String = pluginmanager.Get("pip_args")
'	Dim repository As String = pluginmanager.Get("repository")
'	Dim action_command_prompt As Map = plugins.Get("action_command_prompt")
'	Dim enable_emergency_sending As String = action_command_prompt.Get("enable_emergency_sending")
'	Dim enable As String = action_command_prompt.Get("enable")
'	Dim enable_signal_support As String = action_command_prompt.Get("enable_signal_support")
'	Dim command As String = action_command_prompt.Get("command")
'	Dim mqttsubscribe As Map = plugins.Get("mqttsubscribe")
'	Dim api_key As String = mqttsubscribe.Get("api_key")
'	Dim topics As List = mqttsubscribe.Get("topics")
	
'	Dim prusaslicerthumbnails As Map = plugins.Get("prusaslicerthumbnails")
'	Dim inline_thumbnail_align_value As String = prusaslicerthumbnails.Get("inline_thumbnail_align_value")
'	Dim installed As String = prusaslicerthumbnails.Get("installed")
'	Dim align_inline_thumbnail As String = prusaslicerthumbnails.Get("align_inline_thumbnail")
'	Dim state_panel_thumbnail As String = prusaslicerthumbnails.Get("state_panel_thumbnail")
'	Dim scale_inline_thumbnail As String = prusaslicerthumbnails.Get("scale_inline_thumbnail")
'	Dim state_panel_thumbnail_scale_value As String = prusaslicerthumbnails.Get("state_panel_thumbnail_scale_value")
'	Dim filelist_height As String = prusaslicerthumbnails.Get("filelist_height")
'	Dim scale_inline_thumbnail_position As String = prusaslicerthumbnails.Get("scale_inline_thumbnail_position")
'	Dim inline_thumbnail_scale_value As String = prusaslicerthumbnails.Get("inline_thumbnail_scale_value")
'	Dim resize_filelist As String = prusaslicerthumbnails.Get("resize_filelist")
'	Dim inline_thumbnail_position_left As String = prusaslicerthumbnails.Get("inline_thumbnail_position_left")
'	Dim inline_thumbnail As String = prusaslicerthumbnails.Get("inline_thumbnail")
	
	
'	Dim tracking As Map = plugins.Get("tracking")
'	Dim tracking_server As String = tracking.Get("server")
'	Dim tracking_unique_id As String = tracking.Get("unique_id")
'	Dim tracking_ping As String = tracking.Get("ping")
'	Dim tracking_pong As Int = tracking.Get("pong")
'	Dim tracking_enabled As String = tracking.Get("enabled")
	
'	Dim events0 As Map = tracking.Get("events")
'	Dim events_slicing As String = events0.Get("slicing")
'	Dim events_plugin As String = events0.Get("plugin")
'	Dim events_webui_load As String = events0.Get("webui_load")
'	Dim events_startup As String = events0.Get("startup")
'	Dim events_printer As String = events0.Get("printer")
'	Dim events_commerror As String = events0.Get("commerror")
'	Dim events_update As String = events0.Get("update")
'	Dim events_printjob As String = events0.Get("printjob")
'	Dim events_pong1 As String = events0.Get("pong")
'	Dim events_printer_safety_check As String = events0.Get("printer_safety_check")
'	Dim events_throttled As String = events0.Get("throttled")
'	
	
'	Dim errortracking As Map = plugins.Get("errortracking")
'	Dim unique_id As String = errortracking.Get("unique_id")
'	Dim enabled_unreleased As String = errortracking.Get("enabled_unreleased")
'	Dim url_server As String = errortracking.Get("url_server")
'	Dim url_coreui As String = errortracking.Get("url_coreui")
'	Dim enabled As String = errortracking.Get("enabled")
'	Dim gcodeviewer As Map = plugins.Get("gcodeviewer")
'	Dim mobileSizeThreshold As Int = gcodeviewer.Get("mobileSizeThreshold")
'	Dim skipUntilThis As String = gcodeviewer.Get("skipUntilThis")
'	Dim sizeThreshold As Int = gcodeviewer.Get("sizeThreshold")
'	Dim discovery As Map = plugins.Get("discovery")
'	Dim ignoredAddresses As String = discovery.Get("ignoredAddresses")
'	Dim ignoredInterfaces As String = discovery.Get("ignoredInterfaces")
'	Dim addresses As String = discovery.Get("addresses")
'	Dim interfaces As String = discovery.Get("interfaces")
'	Dim upnpUuid As String = discovery.Get("upnpUuid")
'	Dim zeroConf As List = discovery.Get("zeroConf")
'	Dim publicPort As String = discovery.Get("publicPort")
'	Dim httpUsername As String = discovery.Get("httpUsername")
'	Dim model As Map = discovery.Get("model")
	
'	Dim model_number As String = model.Get("number")
'	Dim model_vendorUrl As String = model.Get("vendorUrl")
'	Dim model_serial As String = model.Get("serial")
'	Dim model_vendor As String = model.Get("vendor")
'	Dim model_name As String = model.Get("name")
'	Dim model_description As String = model.Get("description")
'	Dim model_url As String = model.Get("url")
'	
	
'	Dim httpPassword As String = discovery.Get("httpPassword")
'	Dim pathPrefix As String = discovery.Get("pathPrefix")
'	Dim publicHost As String = discovery.Get("publicHost")
'	Dim softwareupdate As Map = plugins.Get("softwareupdate")
'	Dim updatelog_cutoff As Int = softwareupdate.Get("updatelog_cutoff")
'	Dim octoprint_pip_target As String = softwareupdate.Get("octoprint_pip_target")
'	Dim credentials As Map = softwareupdate.Get("credentials")
'	Dim octoprint_branch_mappings As List = softwareupdate.Get("octoprint_branch_mappings")
'	For Each coloctoprint_branch_mappings As Map In octoprint_branch_mappings
'		Dim name As String = coloctoprint_branch_mappings.Get("name")
'		Dim commitish As List = coloctoprint_branch_mappings.Get("commitish")
'		For Each colcommitish As String In commitish
'		Next
'		Dim branch As String = coloctoprint_branch_mappings.Get("branch")
'	Next
	
'	Dim cache_ttl As Int = softwareupdate.Get("cache_ttl")
'	Dim octoprint_checkout_folder As String = softwareupdate.Get("octoprint_checkout_folder")
'	Dim pip_command As String = softwareupdate.Get("pip_command")
'	Dim queued_updates As List = softwareupdate.Get("queued_updates")
'	Dim octoprint_tracked_branch As String = softwareupdate.Get("octoprint_tracked_branch")
'	Dim check_overlay_url As String = softwareupdate.Get("check_overlay_url")
'	Dim minimum_free_storage As Int = softwareupdate.Get("minimum_free_storage")
'	Dim notify_users As String = softwareupdate.Get("notify_users")
'	Dim octoprint_release_channel As String = softwareupdate.Get("octoprint_release_channel")
'	Dim ignore_throttled As String = softwareupdate.Get("ignore_throttled") 'ignore
'	Dim check_overlay_ttl As Int = softwareupdate.Get("check_overlay_ttl")
'	Dim pip_enable_check As String = softwareupdate.Get("pip_enable_check")
'	Dim check_overlay_py2_url As String = softwareupdate.Get("check_overlay_py2_url")
'	Dim octoprint_type As String = softwareupdate.Get("octoprint_type")
'	Dim octoprint_method As String = softwareupdate.Get("octoprint_method")
	
'	Dim action_command_notification As Map = plugins.Get("action_command_notification")
'	Dim action_enable_popups As String = action_command_notification.Get("enable_popups")
'	Dim action_enable As String = action_command_notification.Get("enable") 'ignore
'	
'	Dim announcements As Map = plugins.Get("announcements")
'	Dim forced_channels As List = announcements.Get("forced_channels")
'	For Each colforced_channels As String In forced_channels
'	Next
'	Dim channels As Map = announcements.Get("channels")
'	Dim important As Map = channels.Get("_important")
'	Dim read_until As Int = important.Get("read_until")
'	Dim name_important As String = important.Get("name") 'ignore
'	Dim description As String = important.Get("description")
'	Dim priority As Int = important.Get("priority")
'	Dim Type As String = important.Get("type")
'	Dim url As String = important.Get("url")
'	Dim releases As Map = channels.Get("_releases")
'	Dim read_until As Int = releases.Get("read_until")
'	Dim name As String = releases.Get("name")
'	Dim description As String = releases.Get("description")
'	Dim priority As Int = releases.Get("priority")
'	Dim Type As String = releases.Get("type")
'	Dim url As String = releases.Get("url")
'	Dim octopi As Map = channels.Get("_octopi")
'	Dim read_until As Int = octopi.Get("read_until")
'	Dim name As String = octopi.Get("name")
'	Dim description As String = octopi.Get("description")
'	Dim priority As Int = octopi.Get("priority")
'	Dim Type As String = octopi.Get("type")
'	Dim octopi_url As String = octopi.Get("url")
	
'	Dim plugins As Map = channels.Get("_plugins")
'	Dim read_until As Int = plugins.Get("read_until")
'	Dim name As String = plugins.Get("name")
'	Dim description As String = plugins.Get("description")
'	Dim priority As Int = plugins.Get("priority")
'	Dim Type As String = plugins.Get("type")
'	Dim url As String = plugins.Get("url") 'ignore
	
'	Dim blog As Map = channels.Get("_blog")
'	Dim read_until As Int = blog.Get("read_until")
'	Dim name As String = blog.Get("name")
'	Dim description As String = blog.Get("description")
'	Dim priority As Int = blog.Get("priority")
'	Dim Type As String = blog.Get("type")
'	Dim url As String = blog.Get("url")
		
'	Dim display_limit As Int = announcements.Get("display_limit")
'	Dim enabled_channels As List = announcements.Get("enabled_channels")
'	For Each colenabled_channels As String In enabled_channels
'	Next
'	Dim summary_limit As Int = announcements.Get("summary_limit")
'	Dim channel_order As List = announcements.Get("channel_order")
'	For Each colchannel_order As String In channel_order
'	Next
'	Dim ttl As Int = announcements.Get("ttl") 'ignore
'	Dim virtual_printer As Map = plugins.Get("virtual_printer")
'	Dim throttle As Double = virtual_printer.Get("throttle")
'	Dim m105TargetFormatString As String = virtual_printer.Get("m105TargetFormatString")
'	Dim hasBed As String = virtual_printer.Get("hasBed")
'	Dim okFormatString As String = virtual_printer.Get("okFormatString")
'	Dim sendWait As String = virtual_printer.Get("sendWait")
'	Dim sharedNozzle As String = virtual_printer.Get("sharedNozzle")
'	Dim hasChamber As String = virtual_printer.Get("hasChamber")
'	Dim supportF As String = virtual_printer.Get("supportF")
'	Dim okAfterResend As String = virtual_printer.Get("okAfterResend")
'	Dim enabled As String = virtual_printer.Get("enabled") 'ignore
'	Dim m114FormatString As String = virtual_printer.Get("m114FormatString")
'	Dim okBeforeCommandOutput As String = virtual_printer.Get("okBeforeCommandOutput")
'	Dim includeFilenameInOpened As String = virtual_printer.Get("includeFilenameInOpened")
'	Dim pinnedExtruders As String = virtual_printer.Get("pinnedExtruders")
'	Dim preparedOks As List = virtual_printer.Get("preparedOks")
'	Dim resend_ratio As Int = virtual_printer.Get("resend_ratio")
'	Dim rxBuffer As Int = virtual_printer.Get("rxBuffer")
'	Dim supportM112 As String = virtual_printer.Get("supportM112")
'	Dim numExtruders As Int = virtual_printer.Get("numExtruders")
'	Dim locked As String = virtual_printer.Get("locked")
'	Dim commandBuffer As Int = virtual_printer.Get("commandBuffer")
'	Dim m115ReportCapabilities As String = virtual_printer.Get("m115ReportCapabilities")
'	Dim forceChecksum As String = virtual_printer.Get("forceChecksum")
'	Dim capabilities As Map = virtual_printer.Get("capabilities")
'	Dim AUTOREPORT_POS As String = capabilities.Get("AUTOREPORT_POS")
'	Dim EXTENDED_M20 As String = capabilities.Get("EXTENDED_M20")
'	Dim AUTOREPORT_SD_STATUS As String = capabilities.Get("AUTOREPORT_SD_STATUS")
'	Dim EMERGENCY_PARSER As String = capabilities.Get("EMERGENCY_PARSER")
'	Dim AUTOREPORT_TEMP As String = capabilities.Get("AUTOREPORT_TEMP")
'	Dim m105NoTargetFormatString As String = virtual_printer.Get("m105NoTargetFormatString")
'	Dim support_M503 As String = virtual_printer.Get("support_M503")
'	Dim reprapfwM114 As String = virtual_printer.Get("reprapfwM114")
'	Dim busyInterval As Double = virtual_printer.Get("busyInterval")
'	Dim waitInterval As Double = virtual_printer.Get("waitInterval")
'	Dim ambientTemperature As Double = virtual_printer.Get("ambientTemperature")
'	Dim smoothieTemperatureReporting As String = virtual_printer.Get("smoothieTemperatureReporting")
'	Dim brokenResend As String = virtual_printer.Get("brokenResend")
'	Dim echoOnM117 As String = virtual_printer.Get("echoOnM117")
'	Dim enable_eeprom As String = virtual_printer.Get("enable_eeprom")
'	Dim m115FormatString As String = virtual_printer.Get("m115FormatString")
'	Dim simulateReset As String = virtual_printer.Get("simulateReset")
'	Dim resetLines As List = virtual_printer.Get("resetLines")
'	For Each colresetLines As String In resetLines
'	Next
'	Dim sendBusy As String = virtual_printer.Get("sendBusy")
'	Dim repetierStyleTargetTemperature As String = virtual_printer.Get("repetierStyleTargetTemperature")
'	Dim firmwareName As String = virtual_printer.Get("firmwareName")
'	Dim brokenM29 As String = virtual_printer.Get("brokenM29")
'	Dim sdFiles As Map = virtual_printer.Get("sdFiles")
'	Dim longname As String = sdFiles.Get("longname")
'	Dim size As String = sdFiles.Get("size")
'	Dim longname_quoted As String = sdFiles.Get("longname_quoted")
'	Dim includeCurrentToolInTemps As String = virtual_printer.Get("includeCurrentToolInTemps")
'	Dim klipperTemperatureReporting As String = virtual_printer.Get("klipperTemperatureReporting")
'	Dim errors As Map = virtual_printer.Get("errors")
'	Dim maxtemp As String = errors.Get("maxtemp")
'	Dim checksum_mismatch As String = errors.Get("checksum_mismatch")
'	Dim lineno_missing As String = errors.Get("lineno_missing")
'	Dim checksum_missing As String = errors.Get("checksum_missing")
'	Dim command_unknown As String = errors.Get("command_unknown")
'	Dim mintemp As String = errors.Get("mintemp")
'	Dim lineno_mismatch As String = errors.Get("lineno_mismatch")
'	Dim passcode As String = virtual_printer.Get("passcode")
'	Dim devel As Map = root.Get("devel")
'	Dim pluginTimings As String = devel.Get("pluginTimings")
'	Dim appearance As Map = root.Get("appearance")
'	Dim fuzzyTimes As String = appearance.Get("fuzzyTimes")
'	Dim colorIcon As String = appearance.Get("colorIcon")
'	Dim colorTransparent As String = appearance.Get("colorTransparent")
'	Dim defaultLanguage As String = appearance.Get("defaultLanguage")
'	Dim color As String = appearance.Get("color")
'	Dim showInternalFilename As String = appearance.Get("showInternalFilename")
'	Dim name As String = appearance.Get("name")'ignore
'	Dim closeModalsWithClick As String = appearance.Get("closeModalsWithClick")
'	Dim showFahrenheitAlso As String = appearance.Get("showFahrenheitAlso")
'	Dim folder As Map = root.Get("folder")
'	Dim watched As String = folder.Get("watched")
'	Dim timelapseTmp As String = folder.Get("timelapseTmp")
'	Dim logs As String = folder.Get("logs")
'	Dim timelapse As String = folder.Get("timelapse")
'	Dim uploads As String = folder.Get("uploads")
'	Dim system As Map = root.Get("system")
'	Dim actions As List = system.Get("actions")
'	Dim events1 As String = system.Get("events")
'	Dim feature As Map = root.Get("feature")
'	Dim sdSupport As String = feature.Get("sdSupport")
'	Dim printStartConfirmation As String = feature.Get("printStartConfirmation")
'	Dim modelSizeDetection As String = feature.Get("modelSizeDetection")
'	Dim printCancelConfirmation As String = feature.Get("printCancelConfirmation")
'	Dim pollWatched As String = feature.Get("pollWatched")
'	Dim keyboardControl As String = feature.Get("keyboardControl")
'	Dim uploadOverwriteConfirmation As String = feature.Get("uploadOverwriteConfirmation")
'	Dim temperatureGraph As String = feature.Get("temperatureGraph")
'	Dim autoUppercaseBlacklist As List = feature.Get("autoUppercaseBlacklist")
'	For Each colautoUppercaseBlacklist As String In autoUppercaseBlacklist
'	Next
'	Dim g90InfluencesExtruder As String = feature.Get("g90InfluencesExtruder")
'	Dim rememberFileFolder As String = feature.Get("rememberFileFolder")
	
	
'	Dim serial1 As Map = root.Get("serial")
'	Dim logPositionOnCancel As String = serial1.Get("logPositionOnCancel")
'	Dim ignoreErrorsFromFirmware As String = serial1.Get("ignoreErrorsFromFirmware")
'	Dim firmwareDetection As String = serial1.Get("firmwareDetection")
'	Dim timeoutTemperatureAutoreport As Double = serial1.Get("timeoutTemperatureAutoreport")
'	Dim timeoutSdStatus As Double = serial1.Get("timeoutSdStatus")
'	Dim abortHeatupOnCancel As String = serial1.Get("abortHeatupOnCancel")
'	Dim additionalPorts As List = serial1.Get("additionalPorts")
'	Dim timeoutDetectionConsecutive As Double = serial1.Get("timeoutDetectionConsecutive")
'	Dim capEmergencyParser As String = serial1.Get("capEmergencyParser")
'	Dim capAutoreportPos As String = serial1.Get("capAutoreportPos")
'	Dim notifySuppressedCommands As String = serial1.Get("notifySuppressedCommands")
'	Dim emergencyCommands As List = serial1.Get("emergencyCommands")
'	
'	
'	For Each colemergencyCommands As String In emergencyCommands
'	Next
'	Dim neverSendChecksum As String = serial1.Get("neverSendChecksum")
'	Dim sendM112OnError As String = serial1.Get("sendM112OnError")
'	Dim resendRatioStart As Int = serial1.Get("resendRatioStart")
'	Dim supportResendsWithoutOk As String = serial1.Get("supportResendsWithoutOk")
'	Dim checksumRequiringCommands As List = serial1.Get("checksumRequiringCommands")
'	For Each colchecksumRequiringCommands As String In checksumRequiringCommands
'	Next
'	Dim enableShutdownActionCommand As String = serial1.Get("enableShutdownActionCommand")
'	Dim exclusive As String = serial1.Get("exclusive")
'	Dim capExtendedM20 As String = serial1.Get("capExtendedM20")
'	Dim timeoutPosAutoreport As Double = serial1.Get("timeoutPosAutoreport")
'	Dim longRunningCommands As List = serial1.Get("longRunningCommands")
'	For Each collongRunningCommands As String In longRunningCommands
'	Next
'	Dim baudrate As String = serial1.Get("baudrate")
'	Dim blacklistedPorts As List = serial1.Get("blacklistedPorts")
'	Dim sdLowerCase As String = serial1.Get("sdLowerCase")
'	Dim maxTimeoutsIdle As Int = serial1.Get("maxTimeoutsIdle")
'	Dim blockWhileDwelling As String = serial1.Get("blockWhileDwelling")
'	Dim disableSdPrintingDetection As String = serial1.Get("disableSdPrintingDetection")
'	Dim encoding As String = serial1.Get("encoding")
'	Dim sendChecksumWithUnknownCommands As String = serial1.Get("sendChecksumWithUnknownCommands")
'	Dim unknownCommandsNeedAck As String = serial1.Get("unknownCommandsNeedAck")
'	Dim ackMax As Int = serial1.Get("ackMax")
'	Dim ignoreIdenticalResends As String = serial1.Get("ignoreIdenticalResends")
'	Dim port1 As String = serial1.Get("port")
'	Dim repetierTargetTemp As String = serial1.Get("repetierTargetTemp")
'	Dim sanityCheckTools As String = serial1.Get("sanityCheckTools")
'	Dim timeoutBaudrateDetectionPause As Double = serial1.Get("timeoutBaudrateDetectionPause")
'	Dim timeoutCommunication As Double = serial1.Get("timeoutCommunication")
'	Dim waitForStart As String = serial1.Get("waitForStart")
'	Dim alwaysSendChecksum As String = serial1.Get("alwaysSendChecksum")
'	Dim maxTimeoutsPrinting As Int = serial1.Get("maxTimeoutsPrinting")
'	Dim timeoutTemperatureTargetSet As Double = serial1.Get("timeoutTemperatureTargetSet")
'	Dim baudrateOptions As List = serial1.Get("baudrateOptions")
'	For Each colbaudrateOptions As Int In baudrateOptions
'	Next
'	Dim capAutoreportSdStatus As String = serial1.Get("capAutoreportSdStatus")
'	Dim Log As String = serial1.Get("log")
'	Dim timeoutTemperature As Double = serial1.Get("timeoutTemperature")
'	Dim autoconnect As String = serial1.Get("autoconnect")
'	Dim timeoutSdStatusAutoreport As Double = serial1.Get("timeoutSdStatusAutoreport")
'	Dim lowLatency As String = serial1.Get("lowLatency")
'	Dim logPositionOnPause As String = serial1.Get("logPositionOnPause")
'	Dim maxTimeoutsLong As Int = serial1.Get("maxTimeoutsLong")
'	Dim externalHeatupDetection As String = serial1.Get("externalHeatupDetection")
'	Dim pausingCommands As List = serial1.Get("pausingCommands")
'	For Each colpausingCommands As String In pausingCommands
'	Next
'	Dim helloCommand As String = serial1.Get("helloCommand")
'	Dim resendRatioThreshold As Int = serial1.Get("resendRatioThreshold")
'	Dim timeoutDetectionFirst As Double = serial1.Get("timeoutDetectionFirst")
'	Dim blockedCommands As List = serial1.Get("blockedCommands")
'	For Each colblockedCommands As String In blockedCommands
'	Next
	
'	Dim ignoreEmptyPorts As String = serial1.Get("ignoreEmptyPorts")
'	Dim capBusyProtocol As String = serial1.Get("capBusyProtocol")
'	Dim sdRelativePath As String = serial1.Get("sdRelativePath")
'	Dim timeoutPositionLogWait As Double = serial1.Get("timeoutPositionLogWait")
'	Dim capAutoreportTemp As String = serial1.Get("capAutoreportTemp")
'	Dim triggerOkForM29 As String = serial1.Get("triggerOkForM29")
'	Dim swallowOkAfterResend As String = serial1.Get("swallowOkAfterResend")
'	Dim timeoutConnection As Double = serial1.Get("timeoutConnection")
'	Dim additionalBaudrates As List = serial1.Get("additionalBaudrates")
'	Dim ignoredCommands As List = serial1.Get("ignoredCommands")
'	Dim blacklistedBaudrates As List = serial1.Get("blacklistedBaudrates")
'	Dim useParityWorkaround As String = serial1.Get("useParityWorkaround")
'	Dim sdCancelCommand As String = serial1.Get("sdCancelCommand")
'	Dim portOptions As List = serial1.Get("portOptions")
'	For Each colportOptions As String In portOptions
'	Next


'	Dim disconnectOnErrors As String = serial1.Get("disconnectOnErrors")
'	Dim sdAlwaysAvailable As String = serial1.Get("sdAlwaysAvailable")
'	Dim timeoutCommunicationBusy As Double = serial1.Get("timeoutCommunicationBusy")
'	Dim webcam As Map = root.Get("webcam")
'	Dim streamUrl As String = webcam.Get("streamUrl")
	
	
'	Dim webcamEnabled As String = webcam.Get("webcamEnabled")
'	Dim streamTimeout As Int = webcam.Get("streamTimeout")
'	Dim watermark As String = webcam.Get("watermark")
'	Dim ffmpegPath As String = webcam.Get("ffmpegPath")
'	Dim streamWebrtcIceServers As List = webcam.Get("streamWebrtcIceServers")
'	For Each colstreamWebrtcIceServers As String In streamWebrtcIceServers
'	Next
'	Dim bitrate As String = webcam.Get("bitrate")
'	Dim rotate90 As String = webcam.Get("rotate90")
'	Dim streamRatio As String = webcam.Get("streamRatio")
'	Dim flipH As String = webcam.Get("flipH")
'	Dim timelapseEnabled As String = webcam.Get("timelapseEnabled")
'	Dim cacheBuster As String = webcam.Get("cacheBuster")
'	Dim ffmpegCommandline As String = webcam.Get("ffmpegCommandline")
'	Dim snapshotSslValidation As String = webcam.Get("snapshotSslValidation")
'	Dim ffmpegThreads As Int = webcam.Get("ffmpegThreads")
'	Dim snapshotTimeout As Int = webcam.Get("snapshotTimeout")
'	Dim snapshotUrl As String = webcam.Get("snapshotUrl")
'	Dim flipV As String = webcam.Get("flipV")
'	Dim ffmpegVideoCodec As String = webcam.Get("ffmpegVideoCodec")
	
'	Dim cutoff As Int = temperature.Get("cutoff")
'	Dim api As Map = root.Get("api")
'	Dim allowCrossOrigin As String = api.Get("allowCrossOrigin")
'	Dim key As String = api.Get("key")
'	Dim scripts As Map = root.Get("scripts")
'	Dim gcode As Map = scripts.Get("gcode")
'	Dim afterPrintCancelled As String = gcode.Get("afterPrintCancelled")
'	Dim snippets_disable_hotends As String = gcode.Get("snippets/disable_hotends")
'	Dim snippets_disable_bed As String = gcode.Get("snippets/disable_bed")
'	Dim gcodeAnalysis As Map = root.Get("gcodeAnalysis")
'	Dim runAt As String = gcodeAnalysis.Get("runAt")
'	Dim bedZ As Double = gcodeAnalysis.Get("bedZ")

End Sub
#end region


'--- parses specific printer profile
Public Sub ParsePrinterProfile(jsonTXT As String)
	
	Dim parser As JSONParser
	parser.Initialize(jsonTXT)
	Dim root As Map = parser.NextObject
	
	Try
		Dim volume As Map = root.Get("volume")
		oc.PrinterWidth = volume.Get("width")
		oc.PrinterDepth = volume.Get("depth")
		oc.PrinterCustomBoundingBox  = (volume.Get("custom_box").As(Boolean))
	Catch
		oc.PrinterWidth = 0
		oc.PrinterDepth = 0
		Log(LastException)
	End Try
	'Log("cbox: " & oc.PrinterCustomBoundingBox)
	'Dim formFactor As String = volume.Get("formFactor")
	'Dim origin As String = volume.Get("origin")
	'Dim height As Double = volume.Get("height")
	
	'Dim current As String = root.Get("current")
	'Dim default As String = root.Get("default")
	'Dim heatedBed As String = root.Get("heatedBed")
	'Dim color As String = root.Get("color")
	'Dim resource As String = root.Get("resource")
	'Dim heatedChamber As String = root.Get("heatedChamber")
	
'	Dim axes As Map = root.Get("axes") '---------------------------->  now axes is read in general dialogs
	'Dim e As Map = axes.Get("e")
	'Dim inverted As String = e.Get("inverted")
	'Dim speed As Int = e.Get("speed")
	
'	Dim xMap As Map = axes.Get("x") '---------------------------->  now axes is read in general dialogs
'	oc.PrinterProfileInvertedX = strHelpers.Str2Bool(xMap.Get("inverted"))
'	'Log("X invert:" & xMap.Get("inverted"))
'	'Log("X invert:" & oc.PrinterProfileInvertedX)
'	'Dim speed As Int = xMap.Get("speed")
'	
'	Dim yMap As Map = axes.Get("y") '---------------------------->  now axes is read in general dialogs
'	oc.PrinterProfileInvertedY = strHelpers.Str2Bool(yMap.Get("inverted"))
'	'Log("Y invert:" & yMap.Get("inverted"))
'	'Log("Y invert:" & oc.PrinterProfileInvertedy)
'	'Dim speed As Int = yMap.Get("speed")
'	
'	Dim zMap As Map = axes.Get("z") '---------------------------->  now axes is read in general dialogs
'	oc.PrinterProfileInvertedZ = strHelpers.Str2Bool(zMap.Get("inverted"))
'	'Log("Z invert:" & zMap.Get("inverted"))
'	'Log("Z invert:" & oc.PrinterProfileInvertedz)
'	'Dim speed As Int = z.Get("speed")
	
	oc.PrinterProfileName = root.Get("name")
	oc.PrinterProfileModel = root.Get("model")
	'Dim id As String = root.Get("id")
	Dim extruder As Map = root.Get("extruder")
	'Dim defaultExtrusionLength As Int = extruder.Get("defaultExtrusionLength")
	'Dim offsets As List = extruder.Get("offsets")
	'For Each coloffsets As List In offsets
	'	For Each colcoloffsets As Double In coloffsets
	'	Next
	'Next
	'Dim nozzleDiameter As Double = extruder.Get("nozzleDiameter")
	'Dim sharedNozzle As String = extruder.Get("sharedNozzle")
	oc.PrinterProfileNozzleCount = extruder.Get("count")

End Sub


