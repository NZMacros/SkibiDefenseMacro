EnumInt(*) {
	static arr := ["ReversedStatusLog" ; 1 (status)
	 , "DiscordCheck" ; 2 (Discord)
	 , "DiscordMode" ; 3
	 , "MainChannelCheck"
	 , "ReportChannelCheck"
	 , "DebugLogEnabled"
	 , "Criticals"
	 , "Screenshots"
	 , "DebuggingScreenshots"
	 , "CriticalErrorPings"
	 , "DisconnectPings"
	 , "CriticalScreenshots"
	 , "DeathScreenshots"
	 , "ColourfulEmbeds"
	 , "GUI_X" ; settings
	 , "GUI_Y"
	 , "AlwaysOnTop"
	 , "GUITransparency"
	 , "KeyDelay"
	 , "PublicFallback"
	 , "ShowOnPause"
	 , "ClickCount"
	 , "ClickDelay"
	 , "ClickDuration"
	 , "ClickMode"
	 , "MacroState"]
}

EnumStr(*) {
	static arr := ["CommandPrefix" ; 1 (Discord)
	 , "WebhookURL" ; 2
	 , "BotToken" ; 3
	 , "MainChannelID"
	 , "ReportChannelID"
	 , "DiscordUserID"
	 , "GUITheme" ; settings
	 , "Language"
	 , "PrivServer"
	 , "FallbackServer1"
	 , "FallbackServer2"
	 , "FallbackServer3"
	 , "ReconnectMethod"
	 , "ReconnectMessage"
	 , "ClickButton"]
}
