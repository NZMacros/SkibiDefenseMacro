; pause macro
sd_Pause(*) {
	global
	if objective = "Startup" {
		return
	}
	if (A_IsPaused) {
		sd_MainGUIKey(0)
		ActivateRoblox()
		DetectHiddenWindows(1)
		if WinExist("ahk_class AutoHotkey ahk_pid " CurrentWalk.pid) {
			Send "{F16}"
		} else {
			if (W_State) {
				SendInput "{" W " down}"
			}
			if (S_State) {
				SendInput "{" S " down}"
			}
			if (A_State) {
				SendInput "{" A " down}"
			}
			if (D_State) {
				SendInput "{" D " down}"
			}
			if (Space_State) {
				SendInput "{" Space " down}"
			}
		}
		MacroState := 2
		if WinExist("Discord.ahk ahk_class AutoHotkey") {
			try {
				PostMessage(0x5552, 23, MacroState)
			}
		}
		if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
			try {
				PostMessage(0x5552, 23, MacroState)
			}
		}
		if WinExist("background.ahk ahk_class AutoHotkey") {
			try {
				PostMessage(0x5552, 23, MacroState)
			}
		}
		YouDied := 0
		; manage runtimes
		MacroStartTime := nowUnix()
		GameStartTime := nowUnix()
		DetectHiddenWindows 0
		sd_SetStatus(PauseState, PauseObjective)
	} else {
		PausedStartTime := nowUnix()
		if ShowOnPause = 1 {
			WinActivate("ahk_id " MainGUI.Hwnd)
		}
		DetectHiddenWindows(1)
		if WinExist("ahk_class AutoHotkey ahk_pid " CurrentWalk.pid) {
			Send "{F16}"
		} else {
			W_State := GetKeyState(W), S_State := GetKeyState(S), A_State := GetKeyState(A), D_State := GetKeyState(D), Space_State := GetKeyState(Space)
			SendInput "{" W " up} {" S " up} {" A " up} {" D " up} {" Space " up}"
			Click("Up")
		}
		MacroState := 1
		if WinExist("Discord.ahk ahk_class AutoHotkey") {
			try {
				PostMessage(0x5552, 23, MacroState)
			}
		}
		if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
			try {
				PostMessage(0x5552, 23, MacroState)
			}
		}
		if WinExist("background.ahk ahk_class AutoHotkey") {
			try {
				PostMessage(0x5552, 23, MacroState)
			}
		}
		PauseState := state
		PauseObjective := objective
		; manage runtimes
		SessionRuntime := SessionRuntime + (nowUnix() - MacroStartTime)
		TotalRuntime := TotalRuntime + (nowUnix() - MacroStartTime)
		if (GameStartTime) {
			SessionPlaytime := SessionPlaytime + (nowUnix() - GameStartTime)
			TotalPlaytime := TotalPlaytime + (nowUnix() - GameStartTime)
		}
		if (PausedStartTime) {
			SessionPausedTime := SessionPausedTime + (nowUnix() - PausedStartTime)
			TotalPausedTime := TotalPausedTime + (nowUnix() - PausedStartTime)
		}
		IniWrite(TotalRuntime, A_SettingsWorkingDir "main_config.ini", "Status", "TotalRuntime")
		DetectHiddenWindows(0)
		sd_SetStatus("Paused", "Press " PauseHotkey " to Continue")
		sd_MainGUIKey(0)
	}
	Pause(-1)
}

; stop macro
sd_Stop(*) {
	global
	try {
		Hotkey(StartHotkey, sd_Start, "Off")
		Hotkey(PauseHotkey, sd_Pause, "Off")
		Hotkey(StopHotkey, sd_Stop, "Off")
	}	
	sd_EndMovement()
	SendInput "{" W " up} {" S " up} {" A " up} {" D " up} {" Space " up}"
	Click("Up")    
	if (MacroState) {
		SessionRuntime := SessionRuntime + (nowUnix() - MacroStartTime)
		TotalRuntime := TotalRuntime + (nowUnix() - MacroStartTime)
		if (!GameStartTime) {
			GameStartTime := nowUnix()
		}
		SessionPlaytime := SessionPlaytime + (nowUnix() - GameStartTime)
		TotalPlaytime := TotalPlaytime + (nowUnix() - GameStartTime)
		if (!PausedStartTime) {
			PausedStartTime := nowUnix()
		}
		SessionPausedTime := SessionPausedTime + (nowUnix() - PausedStartTime)
		TotalPausedTime := TotalPausedTime + (nowUnix() - PausedStartTime)
	}
	IniWrite(SessionRuntime, A_SettingsWorkingDir "main_config.ini", "Status", "SessionRuntime")
	IniWrite(TotalRuntime, A_SettingsWorkingDir "main_config.ini", "Status", "TotalRuntime")
	IniWrite(SessionPlaytime, A_SettingsWorkingDir "main_config.ini", "Status", "SessionPlaytime")
	IniWrite(TotalPlaytime, A_SettingsWorkingDir "main_config.ini", "Status", "TotalPlaytime")
	IniWrite(SessionPausedTime, A_SettingsWorkingDir "main_config.ini", "Status", "SessionPausedTime")
	IniWrite(TotalPausedTime, A_SettingsWorkingDir "main_config.ini", "Status", "TotalPausedTime")
	sd_SetStatus("End", "Macro")
	DetectHiddenWindows(1)
	MacroState := 0
	Reload()
	Sleep 10000
}

; autoclicker
sd_AutoClicker(*) {
	global ClickButton, ClickDuration, ClickDelay
	static toggle:=0
	toggle := !toggle

	for var, default in Map("ClickButton", "LMB", "ClickDuration", 50, "ClickDelay", 10) {
		if (!IsNumber(%var%)) {
			%var% := default
		}
	}	

	while ((ClickMode || (A_Index <= ClickCount)) && toggle) {
		SendInput "{" ClickButton " down}"
		Sleep(ClickDuration)
		SendInput "{" ClickButton " up}"
		Sleep(ClickDelay)
	}
	toggle := 0
}

sd_Close(*) {
	SaveGUIPos()
	sd_EndMovement()
	CloseScripts()
	try {
		Gdip_Shutdown(pToken)
	}
	DllCall(A_ThemesWorkingDir "USkin.dll\USkinExit")
	ExitApp()
}



sd_ResetSessionStats(*){
	global
	IniWrite((SessionRuntime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "SessionRuntime")
	IniWrite((SessionPlaytime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "SessionPlaytime")
	IniWrite((SessionPausedTime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "SessionPausedTime")
	IniWrite((SessionDisconnects := 0), A_SettingsWorkingDir "main_config.ini", "Status", "SessionDisconnects")
	sd_setStats()
}

TapKey(Key, Loops := 1, Delay := 0) {
    Loop Loops {
        Send "{" Key " down}"
		PreciseSleep(Delay)
		Send "{" Key " up}"
    }
}

wait(sec) {
    PreciseSleep(sec * 1000)
}

RunWith32() {
	if A_PtrSize != 4 {
		SplitPath(A_AhkPath, , &ahkDirectory)

		if (!FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe")) {
			MsgBox(LanguageText[3] "`n" ahkPath, LanguageText[4], 0x10)
		} else {
			AHKReloadScript(ahkpath)
		}

		ExitApp()
	}
}

AHKReloadScript(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run('"' ahkpath '" /restart ' params)
}

CheckDisplaySpecs() {
	global offsetY, windowDimensions
	ActivateRoblox()
	DisconnectCheck()
	hwnd := GetRobloxHWND()
	GetRobloxClientPos(hwnd)
	offsetY := GetYOffset(hwnd)
	windowDimensions := windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)
	if offsetfail = 1 {
		MsgBox("Unable to detect in-game GUI offset!`nThis means the macro will NOT work correctly!`n`nThere are a few reasons why this can happen:`n	- Incorrect graphics settings`n	- You are not in the lobby at the moment/Roblox failed to open or the check happened too early (re-run the macro with Roblox pre-opened)`n	- Something is covering the top of your Roblox window`n`nEnter SD's lobby and try again making sure your display settings are correct.`nUse a 16:9 resolution (1920x1080/1600x900/1366/768) as well.", LanguageText[13], 0x1030 " T60")
		ExitApp()
	}
	if A_ScreenDPI != 96 {
	    MsgBox(LanguageText[5] "`n" LanguageText[6] "`n" LanguageText[7] "`n" LanguageText[8] "`n" LanguageText[9] "`n" LanguageText[10] "`n" LanguageText[11] "`n" LanguageText[12], LanguageText[13], 0x1030)
    }
	(IsSet(MainGUI) ? MainGUI.Restore() : 0)
}

ObjMinIndex(obj) {
	for k,v in obj {
		return k
	}
	return 0
}

sd_LoadLanguages() {
	global
	LanguageText := []
	LanguageFileContent := FileRead(A_MacroWorkingDir "lib\Languages\" Language ".txt")
    Loop Parse LanguageFileContent, "`r`n", "`r`n" {
        (A_LoopField !="" ? LanguageText.Push(A_LoopField) :"")
    }

	if Language = "english" {
	DisplayedLanguage := "English"
	}
	if Language = "spanish" {
		DisplayedLanguage := "Español"
	}
	if Language = "turkish" {
		DisplayedLanguage := "Türkçe"
	}
	if Language = "portuguese" {
		DisplayedLanguage := "Português"
	}
}

sd_DefaultHandlers() {
	global

	if Language = "english" {
		DisplayedLanguage := "English"

		GUIThemeDDLXPos := "x75"
		GUITransparencyTextXPos := "xp+98"
		KeyDelayTextXPos := "x313"
		LanguageTextXPos := "x390"
		ResetSettingsButtonWidth := "w120"
	}
	if Language = "spanish" {
		DisplayedLanguage := "Español"

		GUIThemeDDLXPos := "x100"
		GUITransparencyTextXPos := "xp+120"
		KeyDelayTextXPos := "x340"
		LanguageTextXPos := "x400"
		ResetSettingsButtonWidth := "w120"
	}
	if Language = "turkish" {
		DisplayedLanguage := "Türkçe"

		GUIThemeDDLXPos := "xp+63"
		GUITransparencyTextXPos := "xp+90"
		KeyDelayTextXPos := "xp+100"
		LanguageTextXPos := "x410"
		ResetSettingsButtonWidth := "w120"
		ReconnectMethodLeftButtonXPos := ""
	}
	if Language = "portuguese" {
		DisplayedLanguage := "Português"

		GUIThemeDDLXPos := "x90"
		GUITransparencyTextXPos := "xp+123"
		KeyDelayTextXPos := "x350"
		LanguageTextXPos := "x410"
		ResetSettingsButtonWidth := "w126"
	}

	if (DiscordMode = 1) && (DiscordCheck = 1) {
		DiscordWebhookCheck := 1, DiscordBotCheck := 0
		DiscordIntegrationDisabled := ""
	} else if ((DiscordMode = 2) && (DiscordCheck = 1)) {
		DiscordWebhookCheck := 0, DiscordBotCheck := 1
		DiscordIntegrationDisabled := ""
	} else {
		DiscordWebhookCheck := 0, DiscordBotCheck := 0
		DiscordIntegrationDisabled := "Disabled"
	}
	if (DiscordCheck = 0) && (MainChannelCheck = 1) || (DiscordCheck = 1) && (MainChannelCheck = 0) || (DiscordCheck = 0) && (MainChannelCheck = 0) {
		MainChannelEditDisabled := "Disabled"
	} else {
		MainChannelEditDisabled := ""
	}
	if (DiscordCheck = 0) && (ReportChannelCheck = 1) || (DiscordCheck = 1) && (ReportChannelCheck = 0) || (DiscordCheck = 0) && (ReportChannelCheck = 0) {
		ReportsChannelEditDisabled := "Disabled"
	} else {
		ReportsChannelEditDisabled := ""
	}
	if (DiscordCheck = 0) && (Criticals = 1) || (DiscordCheck = 1) && (Criticals = 0) || (DiscordCheck = 0) && (Criticals = 0) {
		PingsDisabled := "Disabled"
	} else {
		PingsDisabled := ""
	}
	if (DiscordCheck = 0) && (Screenshots = 1) || (DiscordCheck = 1) && (Screenshots = 0) || (DiscordCheck = 0) && (Screenshots = 0) {
		ScreenshotsDisabled := "Disabled"
	} else {
		ScreenshotsDisabled := ""
	}
	if ((DiscordCheck = 1) && (DiscordMode = 1)) || DiscordCheck = 0 {
		DiscordMode1Hidden := ""
		DiscordMode2Hidden := "Hidden"
	} else if ((DiscordCheck = 1) && (DiscordMode = 2)) {
		DiscordMode1Hidden := "Hidden"
		DiscordMode2Hidden := ""
	}

	if (Month = "September") || (Month = "October") || (Month = "November") {
		if !FileExist(A_Desktop "\Start Skibi Cursed Macro.lnk") {
			FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Cursed Macro.lnk")
		}
	} else if (Month = "December") || (Month = "January") || (Month = "February") {
		if !FileExist(A_Desktop "\Start Skibi Jolly Macro.lnk") {
			FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Jolly Macro.lnk")
        }
	} else {
		if !FileExist(A_Desktop "\Start Skibi Defense Macro.lnk") {
			FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Defense Macro.lnk")
		}
	}
}

sd_ForceReconnect(wParam, *) {
	Critical
	global ReconnectDelay := wParam
	sd_EndMovement()
	CloseRoblox()
	return 0
}

Background() {
	; stats
	sd_SetStats()
}


    
CreateFolder(folder) {
	if !FileExist(folder) {
        try {
			DirCreate(folder) 
        } catch {
		    MsgBox(LanguageText[14] "`n" LanguageText[15] "`n" LanguageText[16], LanguageText[17], 0x40010)
        }
	}
}

WriteConfig(Data, Dir) {
    if !FileExist(Dir) {
        FileAppend(Data, Dir)
    }
}

; Import globals from main_config.ini
sd_ImportConfig() {
	global
	local config := Map() ; store default values, these are loaded initially

	config["Status"] := Map("ReversedStatusLog", 0
	 , "TotalRuntime", 0
	 , "SessionRuntime", 0
	 , "TotalPlaytime", 0
	 , "SessionPlaytime", 0
	 , "SessionPausedTime", 0
	 , "TotalPausedTime", 0
	 , "TotalDisconnects", 0
	 , "SessionDisconnects", 0
	 , "SessionTotalCredits", 0
	 , "CreditsAverage", 0)

	 config["Discord"] := Map("CommandPrefix", "?"
	 , "DiscordCheck", 0
	 , "DiscordMode", 1
	 , "WebhookURL", ""
	 , "BotToken", ""
	 , "MainChannelCheck", 1
	 , "ReportChannelCheck", 1
	 , "MainChannelID", 0
	 , "ReportChannelID", 0
	 , "DiscordUserID", ""
	 , "DebugLogEnabled", 1
	 , "Criticals", 0
	 , "Screenshots", 0
	 , "DebuggingScreenshots", 0
	 , "CriticalErrorPings", 1
	 , "DisconnectPings", 1
	 , "CriticalScreenshots", 1
	 , "DeathScreenshots", 1
	 , "ColourfulEmbeds", 0)

	 config["Settings"] := Map("GUI_X", ""
	 , "GUI_Y", ""
	 , "Language", "english"
	 , "AlwaysOnTop", 0
	 , "GUITransparency", 0
	 , "GUITheme", "Concaved"
	 , "KeyDelay", 25
	 , "StartHotkey", "F1"
	 , "PauseHotkey", "F2"
	 , "StopHotkey", "F3"
	 , "AutoClickerHotkey", "F4"
	 , "CloseHotkey", "F5"
	 , "PrivServer", ""
	 , "FallbackServer1", ""
	 , "FallbackServer2", ""
	 , "FallbackServer3", ""
	 , "PublicFallback", 1
	 , "ReconnectMethod", "Deeplink"
	 , "ReconnectMessage", "I'm a proud user of Skibi Defense Macro!"
	 , "IgnoredVersion", ""
	 , "ShowOnPause", 0
	 , "ClickCount", 1000
	 , "ClickDelay", 10
	 , "ClickDuration", 50
	 , "ClickMode", 1
	 , "ClickButton", "LMB")

	 config["Game"] := Map("ChapterName1", "Chapter 1"
	 , "ChapterName2", "None"
	 , "ChapterName3", "None"
	 , "CurrentChapterNum", 1)

	local k, v, i, j
	for k,v in config { ; load the default values as globals, will be overwritten if a new value exists when reading
		for i, j in v {
			%i% := j
		}
	}

	local inipath := A_SettingsWorkingDir "main_config.ini"

	if FileExist(inipath) { ; update default values with new ones read from any existing .ini
		sd_ReadIni(inipath)
	}

	local ini := ""
	for k, v in config { ; overwrite any existing .ini with updated one with all new keys and old values
		ini .= "[" k "]`r`n"
		for i in v {
			ini .= i "=" %i% "`r`n"
		}
		ini .= "`r`n"
	}

	local file := FileOpen(inipath, "w-d")
	file.Write(ini), file.Close()
}

sd_ReadIni(path) {
	global
	local ini, str, c, p, k, v

	ini := FileOpen(path, "r"), str := ini.Read(), ini.Close()
	Loop Parse str, "`n", "`r" A_Space A_Tab {
		switch (c := SubStr(A_LoopField, 1, 1)) {
			; ignore comments and section names
			case "[", ";":
			continue

			default:
			if (p := InStr(A_LoopField, "=")) {
				try k := SubStr(A_LoopField, 1, p-1), %k% := IsInteger(v := SubStr(A_LoopField, p+1)) ? Integer(v) : v
			}
		}
	}
}

; Quickly update configurations
sd_UpdateConfigShortcut(GUICtrl, *){
	global
	switch GUICtrl.Type, 0 {
		case "DDL":
		%GUICtrl.Name% := GUICtrl.Text
		default: ; "CheckBox", "Edit", "UpDown", "Slider"
		%GUICtrl.Name% := GUICtrl.Value
	}
	IniWrite(%GUICtrl.Name%, A_SettingsWorkingDir "main_config.ini", GUICtrl.Section, GUICtrl.Name)
}



sd_ImgSearch(imageName, v, aim := "full", trans:="none") {
	GetRobloxClientPos()
	;xi := 0
	;yi := 0
	;ww := windowWidth
	;wh := windowHeight
	xi := (aim = "actionbar") ? windowWidth//4 : (aim = "highright") ? windowWidth//2 : (aim = "right") ? windowWidth//2 : (aim = "center") ? windowWidth//4 : (aim = "lowright") ? windowWidth//2 : 0
	yi := (aim = "low") ? windowHeight//2 : (aim = "actionbar") ? (windowHeight//4)*3 : (aim = "center") ? windowHeight//4 : (aim = "lowright") ? windowHeight//2 : (aim = "quest") ? 150 : 0
	ww := (aim = "actionbar") ? xi*3 : (aim = "highleft") ? windowWidth//2 : (aim = "left") ? windowWidth//2 : (aim = "center") ? xi*3 : (aim = "quest") ? 310 : windowWidth
	wh := (aim = "high") ? windowHeight//2 : (aim = "highright") ? windowHeight//2 : (aim = "highleft") ? windowHeight//2 : (aim = "buff") ? 150 : (aim = "abovebuff") ? 30 : (aim = "center") ? yi*3 : (aim = "quest") ? Max(560, windowHeight-100) : windowHeight
	if DirExist(A_WorkingDir "\img_assets") {
		try {
			result := ImageSearch(&FoundX, &FoundY, windowX + xi, windowY + yi, windowX + ww, windowY + wh, "*" v ((trans != "none") ? (" *Trans" trans) : "") " " A_WorkingDir "\img\" imageName)
		} catch {
			sd_SetStatus("Error", "Image file " imageName " was not found in:`n" A_WorkingDir "\img_assets\" imageName)
			Sleep 5000
			ProcessClose(DllCall("GetCurrentProcessId"))
		}
		if (result = 1) {
			return [0, FoundX - windowX, FoundY - windowY]
		} else {
			return [1, 0, 0]
		}
	} else {
		MsgBox("Folder location cannot be found:`n" A_WorkingDir "\img_assets\")
		return [3, 0, 0]
	}
}





/*EXTERNAL*/

CloseRoblox() {
	global
	; if roblox exists, activate it and send Esc + L + Enter
	if (hwnd := GetRobloxHWND()) {
		GetRobloxClientPos(hwnd)
		if (windowHeight >= 500) { ; requirement for L to activate "Leave"
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay(250 + KeyDelay)
			Send "{" Escape "} {" L "} {" Enter "}"
			SetKeyDelay PrevKeyDelay
		}
		try {
			WinClose("Roblox")
		}
		Sleep 500
		try {
			WinClose("Roblox")
		}
		Sleep 4500 ; Delay to prevent Roblox Error Code 264
	}
	; kill any remnant processes
	for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%RobloxCORPORATION%'") {
		ProcessClose(p.ProcessID)
	}
}

DisconnectCheck(testCheck := 0) {
	global PrivServer, TotalDisconnects, SessionDisconnects, ReconnectMethod, PublicFallback, ResetTime
	, MacroState, ReconnectDelay
	, FallbackServer1, FallbackServer2, FallbackServer3
	static ServerLabels := Map(0, "Public Server", 1, "Private Server", 2, "Fallback Server 1", 3, "Fallback Server 2", 4, "Fallback Server 3")
	static LastReconnectMessage := 1

	; Return if not disconnected or crashed
	ActivateRoblox()
	GetRobloxClientPos()
	if ((windowWidth > 0) && (!WinExist("Roblox Crash"))) {
		pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
		if Gdip_ImageSearch(pBMScreen, bitmaps["Disconnected"], , , , , , 2) != 1 {
			Gdip_DisposeImage(pBMScreen)
			return 0
		}
	Gdip_DisposeImage(pBMScreen)
	}

	; End any residual movement and set reconnect start time
	Click("Up")
	sd_EndMovement()
	ReconnectStart := nowUnix()
	sd_UpdateAction("Reconnect")
	
	; Wait for any requested delay time from remote control
	if (ReconnectDelay) {
		sd_SetStatus("Waiting", ReconnectDelay " seconds before Reconnect")
		wait(ReconnectDelay)
		ReconnectDelay := 0
	}
	else if (MacroState = 2) {
		TotalDisconnects := TotalDisconnects + 1
		SessionDisconnects := SessionDisconnects + 1
		PostScriptsMessage("StatMonitor", 0x5555, 1, 1)
		IniWrite(TotalDisconnects, A_SettingsWorkingDir "main_config.ini", "Status", "TotalDisconnects")
		IniWrite(SessionDisconnects, A_SettingsWorkingDir "main_config.ini", "Status", "SessionDisconnects")
		sd_SetStatus("Disconnected", "Reconnecting")
	}

	; Obtain link code from Private Server link
	linkCodes := Map()
	for k, v in ["PrivServer", "FallbackServer1", "FallbackServer2", "FallbackServer3"] {
		if (%v% && (StrLen(%v%) > 0)) {
			if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode) {
				linkCodes[k] := linkCode[0]
			} else {
				sd_SetStatus("Error", ServerLabels[k] " Invalid")
			}
		}
	}

	; Main reconnect loop
	Loop {
		; Decide Server
		server := ((A_Index <= 20) && linkCodes.Has(n := (A_Index - 1)//5 + 1)) ? n : ((PublicFallback = 0) && (n := ObjMinIndex(linkcodes))) ? n : 0

		; Wait For Success
		i := A_Index, success := 0
		Loop 5 {
			; START
			switch (ReconnectMethod = "Browser") ? 0 : Mod(i, 5) {
				case 1, 2:
				; Close Roblox
				SendInput "{" F11 "}"
				CloseRoblox()
				; Run Server Deeplink
				sd_SetStatus("Attempting", ServerLabels[server])
				try {
					Run('"roblox://placeID=14279693118' (server ? ("&linkCode=" linkCodes[server]) : "") '"')
				}

				case 3, 4:
				; Run Server Deeplink (without closing Roblox)
				sd_SetStatus("Attempting", ServerLabels[server])
				try {
					Run('"roblox://placeID=14279693118' (server ? ("&linkCode=" linkCodes[server]) : "") '"')
				}

				default:
				if (server) {
					; Close Roblox
					SendInput "{" F11 "}"
					CloseRoblox()
					;Run Server Link (legacy method w/ browser)
					sd_SetStatus("Attempting", ServerLabels[server] " (Browser)")
					if ((success := BrowserReconnect(linkCodes[server], i)) = 1) {
						if ReconnectMethod != "Browser" {
							ReconnectMethod := "Browser"
							sd_SetStatus("Warning", "Deeplink reconnect failed, switched to browser reconnect for this session!")
						}
						break
					} else {
						continue 2
					}
				} else {
					; Close Roblox
					(i = 1) && CloseRoblox()
					; Run Server Link (spam deeplink method)
					try {
						Run('"roblox://placeID=14279693118"')
					}
				}
			}
			; STAGE 1 - wait for Roblox window
			Loop 240 {
				if (GetRobloxHWND()) {
					ActivateRoblox()
					sd_SetStatus("Detected", "Roblox Open")
					break
				}
				if A_Index = 240 {
					sd_SetStatus("Error", "No Roblox Found`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 4 mins, wait for any Roblox update to finish
			}
			; STAGE 2 - wait for loading screen (or loaded game)
			Loop 180 {
				ActivateRoblox()
				if (!GetRobloxClientPos()) {
					sd_SetStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
				if Gdip_ImageSearch(pBMScreen, bitmaps["LoadingData"], , , , , , 4) = 1 {
					Gdip_DisposeImage(pBMScreen)
					sd_SetStatus("Detected", "Game Open")
					break
				}
				if Gdip_ImageSearch(pBMScreen, bitmaps["ChapterButton"], , , , , , 6) = 1 {
					Gdip_DisposeImage(pBMScreen)
					sd_SetStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["Disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					sd_SetStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if A_Index = 180 {
					sd_SetStatus("Error", "No SD Found`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 3 mins, slow loading
			}
			;STAGE 3 - wait for loaded game
			Loop 180 {
				ActivateRoblox()
				if (!GetRobloxClientPos()) {
					sd_SetStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
				if (Gdip_ImageSearch(pBMScreen, bitmaps["LoadingData"], , , , , , 4) = 0 )|| (Gdip_ImageSearch(pBMScreen, bitmaps["ChapterButton"], , , , , , 6) = 1) {
					Gdip_DisposeImage(pBMScreen)
					sd_SetStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["Disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					sd_SetStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if A_Index = 180 {
					sd_SetStatus("Error", "SD Load Timeout`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 3 mins, slow loading
			}
		}

		; Successful Reconnect
		if success = 1 {
			ActivateRoblox()
			GetRobloxClientPos()
			Duration := DurationFromSeconds(ReconnectDuration := (nowUnix() - ReconnectStart), "mm:ss")
			sd_SetStatus("Completed", "Reconnect`nTime: " Duration " - Attempts: " i)
			Sleep 500

			if server > 1 { ; swap PrivServer and FallbackServer - original PrivServer probably has an issue
				n := server - 1
				temp := PrivServer, PrivServer := FallbackServer%n%, FallbackServer%n% := temp
				MainGUI["PrivServer"].Value := PrivServer
				sd_AdvancedOptions(), AdvancedOptionsGUI.Hide()
				AdvancedOptionsGUI["FallbackServer" n].Value := FallbackServer%n%
				AdvancedOptionsGUI.Destroy()
				IniWrite(PrivServer, A_SettingsWorkingDir "main_config.ini", "Settings", "PrivServer")
				IniWrite(FallbackServer%n%, A_SettingsWorkingDir "main_config.ini", "Settings", "FallbackServer" n)
				PostScriptsMessage("Discord", 0x5553, 10, 6)
			}
			PostScriptsMessage("Discord", 0x5552, 221, (server = 0))

			;;;; Custom reconnect message
			if ((ReconnectMessage) && ((nowUnix() - LastReconnectMessage) > 3600)) { ; limit to once per hour
				LastReconnectMessage := nowUnix()
				SentReconnectMessage := StrLower(ReconnectMessage)
				SendText "/"
				Sleep 250
				SendText "[" A_Hour ":" A_Min "] " SentReconnectMessage
				Sleep 250
				SendInput Enter
			}
			MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
			SendInput "{" F11 "}"

			if (!testCheck) {
				return 1
			} else if (testCheck = 1) {
				return 2
			}
		}
	}
}

BrowserReconnect(linkCode, i) {
	global bitmaps
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int", 0, "Int", 1, "Str", "http", "Str", "open", "Ptr", cmd.Ptr, "IntP", 512),
		DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
		 , exe := (pEXE > 0) ? StrGet(pEXE) : ""
		 , params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""

	url := "https://www.roblox.com/games/14279693118?privateServerLinkCode=" linkCode
	if ((StrLen(exe) > 0) && (StrLen(params) > 0)) {
		ShellRun(exe, StrReplace(params, "%1", url)), success := 0
	} else {
		Run('"' url '"')
	}

	Loop 1 {
		; STAGE 1 - wait for Roblox Launcher
		Loop 120 {
			if WinExist("Roblox") {
				break
			}
			if A_Index = 120 {
				sd_SetStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 2 mins, slow internet / not logged in
		}
		; STAGE 2 - wait for RobloxPlayerBeta.exe
		Loop 180 {
			if WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate()
				sd_SetStatus("Detected", "Roblox Open")
				break
			}
			if A_Index = 180 {
				sd_SetStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 3 mins, wait for any Roblox update to finish
		}
		; STAGE 3 - wait for loading screen (or loaded game)
		Loop 180 {
			if hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate()
				GetRobloxClientPos(hwnd)
			} else {
				sd_SetStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
			pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
			if Gdip_ImageSearch(pBMScreen, bitmaps["LoadingData"], , , , , , 4) = 1 {
				Gdip_DisposeImage(pBMScreen)
				sd_SetStatus("Detected", "Game Open")
				break
			}
			if Gdip_ImageSearch(pBMScreen, bitmaps["ChapterButton"], , , , , , 2) = 1 {
				Gdip_DisposeImage(pBMScreen)
				sd_SetStatus("Detected", "Game Loaded")
				success := 1
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			if sd_ImgSearch("Reconnect\disconnected.png", 25, "center")[1] = 0 {
				sd_SetStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
			if A_Index = 180 {
				sd_SetStatus("Error", "No BSS Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 3 mins, slow loading
		}
		; STAGE 4 - wait for loaded game
		Loop 240 {
			if hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate()
				GetRobloxClientPos(hwnd)
			} else {
				sd_SetStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
			pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
			if (Gdip_ImageSearch(pBMScreen, bitmaps["LoadingData"], , , , , , 4) = 0 || Gdip_ImageSearch(pBMScreen, bitmaps["ChapterButton"], , , , , , 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				sd_SetStatus("Detected", "Game Loaded")
				success := 1
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			if sd_ImgSearch("Reconnect\disconnected.png", 25, "center")[1] = 0 {
				sd_SetStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
			if A_Index = 240 {
				sd_SetStatus("Error", "SD Load Timeout`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 4 mins, slow loading
		}
	}
	; Close Browser Tab
	for hwnd in WinGetList( , , "Program Manager") {
		p := WinGetProcessName("ahk_id " hwnd)
		if InStr(p, "Roblox") || InStr(p, "AutoHotkey") {
			continue ; skip roblox and AHK windows
		}
		title := WinGetTitle("ahk_id " hwnd)
		if title = "" {
			continue ; skip empty title windows
		}
		s := WinGetStyle("ahk_id " hwnd)
		if (s & 0x8000000) || !(s & 0x10000000) {
			continue ; skip NoActivate and invisible windows
		}
		s := WinGetExStyle("ahk_id " hwnd)
		if (s & 0x80) || (s & 0x40000) || (s & 0x8) {
			continue ; skip ToolWindow and AlwaysOnTop windows
		}
		try {
			WinActivate("ahk_id " hwnd)
			Sleep 500
			Send "^{w}"
		}
		break
	}
	return success
}

PostScriptsMessage(script, args*) {
	DetectHiddenWindows(1)
	if WinExist(script ".ahk ahk_class AutoHotkey") {
		try {
			PostMessage(args*)
		}
	}
	DetectHiddenWindows(0)
}

sd_RunDiscord(link){
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","discord", "Str","open", "Ptr",cmd.Ptr, "IntP",512),
		DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
	, exe := (pEXE > 0) ? StrGet(pEXE) : ""
	, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""
	, appenabled := (StrLen(exe) > 0)

	Run appenabled ? ('"' exe '" ' StrReplace(params, "%1", "discord://-/" link)) : ('"https://discord.com/' link '"')
}

; close any remnant running scripts
CloseScripts(hb := 0) {
	list := WinGetList("ahk_class AutoHotkey ahk_exe " exe_path32)
	if (exe_path32 != exe_path64) {
		list.Push(WinGetList("ahk_class AutoHotkey ahk_exe " exe_path64)*)
	}
	for hwnd in list {
		if !((hwnd = A_ScriptHwnd) || ((hb = 1) && A_Args.Has(2) && (hwnd = A_Args[2]))) {
			try {
				WinClose("ahk_id " hwnd)
			}
		}
	}
}

; elevate script if required (check write permissions in ScriptDir using Heartbeat.ahk)
ElevateScript() {
	try {
		file := FileOpen(A_InitialWorkingDir "\submacros\Heartbeat.ahk", "a")
	} catch {
		if (!A_IsAdmin || !(DllCall("GetCommandLine","Str") ~= " /restart(?!\S)")) {
			try {
				RunWait '*RunAs "' A_AhkPath '" /script /restart "' A_ScriptFullPath '"'
			}
		}
		if !A_IsAdmin {
			MsgBox("You must run Skibi Defense Macro as administrator in this folder!`nIf you don't want to do this, move the macro to a different folder (e.g. Downloads, Desktop)", "Error", 0x40010)
			ExitApp()
		}
		; elevated but still can't write, read-only directory?
		MsgBox("You cannot run Skibi Defense Macro in this folder!`nTry moving the macro to a different folder (e.g. Downloads, Desktop)", "Error", 0x40010)
	}
	else {
		file.Close()
	}
}

sd_SendHeartbeat(*) {
	Critical
	PostScriptsMessage("Heartbeat", 0x5556, 1)
	return 0
}

sd_SetGlobalStr(wParam, lParam, *) {
	global
	local arr := []
	Critical
	; enumeration
	EnumStr()
	static sections := ["Discord", "Game", "Settings", "Status"]

	local var := arr[wParam], section := sections[lParam]
	try %var% := IniRead(A_SettingsWorkingDir "main_config.ini", section, var)
	sd_UpdateGUIVar(var)
	return 0
}

sd_SetGlobalInt(wParam, lParam, *) {
	global
	local arr := []
	Critical
	; enumeration
	EnumInt()

	local var := arr[wParam]
	try %var% := lParam
	sd_UpdateGUIVar(var)
	return 0
}

sd_UpdateGUIVar(var) {
	/*global
	local k, z, num

	try {
		MainGUI[var]
	} catch {
		k := ""
	} else {
		k := var
	}

	switch k, 0 {
		case "FieldPatternSize1", "FieldPatternSize2", "FieldPatternSize3":
		MainGui[k].Text := %k%
		MainGui[k "UpDown"].Value := FieldPatternSizeArr[%k%]

		case "FieldUntilPack1", "FieldUntilPack2", "FieldUntilPack3", "FieldBoosterMins":
		MainGui[k].Text := %k%
		MainGui[k "UpDown"].Value := %k%//5

		case "FieldName1":
		MainGui[k].Text := %k%
		nm_FieldSelect1(1)

		case "FieldName2":
		MainGui[k].Text := %k%
		nm_FieldSelect2(1)

		case "FieldName3":
		MainGui[k].Text := %k%
		nm_FieldSelect3(1)

		case "FieldPattern1", "FieldPattern2", "FieldPattern3":
		MainGui[k].Text := %k%

		case "FieldBooster1", "FieldBooster2", "FieldBooster3":
		MainGui[k].Text := %k%
		nm_FieldBooster()

		case "HotbarWhile2", "HotbarWhile3", "HotbarWhile4", "HotbarWhile5", "HotbarWhile6", "HotbarWhile7":
		MainGui[k].Text := %k%
		nm_HotbarWhile()

		case "KingBeetleAmuletMode", "ShellAmuletMode":
		MainGui[k].Value := %k%
		nm_saveAmulet(MainGui[k])

		case "HotbarTime2", "HotbarTime3", "HotbarTime4", "HotbarTime5", "HotbarTime6", "HotbarTime7":
		MainGui[k].Value := %k%
		nm_HotbarWhile()

		Case "SnailTime":
		MainGui["SnailTimeUpDown"].Value := (SnailTime = "Kill") ? 4 : SnailTime//5
		nm_SnailTime()

		Case "ChickTime":
		MainGui["ChickTimeUpDown"].Value := (ChickTime = "Kill") ? 4 : ChickTime//5
		nm_ChickTime()

		case "InputSnailHealth":
		MainGui["SnailHealthEdit"].Value := Round(30000000*InputSnailHealth/100)
		MainGui["SnailHealthText"].SetFont("c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0)), MainGui["SnailHealthText"].Redraw()
		MainGui["SnailHealthText"].Text := InputSnailHealth "%"

		case "InputChickHealth":
		MainGui["ChickHealthText"].SetFont("c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0)), MainGui["ChickHealthText"].Redraw()
		MainGui["ChickHealthText"].Text := InputChickHealth "%"

		case "MondoAction":
		MainGui[k].Text := %k%
		nm_MondoAction()

		case "":
		k := var
		switch k, 0
		{
			case "BlenderItem1", "BlenderItem2", "BlenderItem3":
			MainGui[k "Picture"].Value := hBitmapsSB[%k%] ? ("HBITMAP:*" hBitmapsSB[%k%]) : ""
			z := SubStr(k, -1)
			MainGui["BlenderAdd" z].Text := (BlenderItem%z% = "None") ? "Add" : "Clear"

			case "BlenderIndex1", "BlenderIndex2", "BlenderIndex3":
			Num := SubStr(k, -1)
			local BlenderData1, BlenderData2, BlenderData3
			BlenderData%Num% := MainGui["BlenderData" Num].Text
			MainGui["BlenderData" Num].Text := StrReplace(BlenderData%Num%, SubStr(BlenderData%Num%, InStr(BlenderData%Num%, " ") + 1), "[" ((%k% = "Infinite") ? "∞" : %k%) "]")

			case "BlenderAmount1", "BlenderAmount2", "BlenderAmount3":
			Num := SubStr(k, -1)
			local BlenderData1, BlenderData2, BlenderData3
			BlenderData%Num% := MainGui["BlenderData" Num].Text
			MainGui["BlenderData" Num].Text := StrReplace(BlenderData%Num%, SubStr(BlenderData%Num%, 1, InStr(BlenderData%Num%, " ") - 1), "(" %k% ")")

			case "ShrineItem1", "ShrineItem2":
			MainGui[k "Picture"].Value := hBitmapsSB[%k%] ? ("HBITMAP:*" hBitmapsSB[%k%]) : ""
			z := SubStr(k, -1)
			MainGui["ShrineAdd" z].Text := (ShrineItem%z% = "None") ? "Add" : "Clear"

			case "ShrineIndex1", "ShrineIndex2":
			Num := SubStr(k, -1)
			local ShrineData1, ShrineData2, ShrineData3
			ShrineData%Num% := MainGui["ShrineData" Num].Text
			MainGui["ShrineData" Num].Text := StrReplace(ShrineData%Num%, SubStr(ShrineData%Num%, InStr(ShrineData%Num%, " ") + 1), "[" ((%k% = "Infinite") ? "∞" : %k%) "]")

			case "ShrineAmount1", "ShrineAmount2":
			Num := SubStr(k, -1)
			local ShrineData1, ShrineData2, ShrineData3
			ShrineData%Num% := MainGui["ShrineData" Num].Text
			MainGui["ShrineData" Num].Text := StrReplace(ShrineData%Num%, SubStr(ShrineData%Num%, 1, InStr(ShrineData%Num%, " ") - 1), "(" %k% ")")

			case "StickerStackMode":
			nm_StickerStackMode()
		}

		default:
		switch MainGui[k].Type, 0
		{
			case "DDL", "Text":
			MainGui[k].Text := %k%
			default: ; "CheckBox", "Edit", "UpDown", "Slider"
			MainGui[k].Value := %k%
		}
	}*/
}

; text control positioning functions
CenterText(Text1, Text2, Font, w := 260) {
	w1 := TextExtent(Text1.Text, Font), w2 := TextExtent(Text2.Text, Font)
	Text1.Move(x1 := (w - w1 - w2)//2, , w1), Text2.Move(x1 + w1, , w2)
	Text1.Redraw(), Text2.Redraw()
}

TextExtent(text, textCtrl) {
	hDC := DllCall("GetDC", "Ptr", textCtrl.Hwnd, "Ptr")
	hFold := DllCall("SelectObject", "Ptr", hDC, "Ptr", SendMessage(0x31, , , textCtrl), "Ptr")
	nSize := Buffer(8)
	DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", text, "Int", StrLen(text), "Ptr", nSize)
	DllCall("SelectObject", "Ptr", hDC, "Ptr", hFold)
	DllCall("ReleaseDC", "Ptr", textCtrl.Hwnd, "Ptr", hDC)
	return NumGet(nSize, 0, "UInt")
}

sd_ForceMode(wParam, *) {
	Critical
	switch wParam {
		case 1:
		if MainGUI["StartButton"].Enabled = 1 {
			SetTimer(sd_Start, -500)
		}

		case 2:
		sd_Pause()

		case 3:
		sd_Stop()

		case 5:
		sd_Close(1)
	}
	return 0
}

sd_BackgroundEvent(wParam, lParam, *){
	Critical
	global Dead
	static arr:=["Dead"]

	var := arr[wParam], %var% := lParam
	return 0
}

sd_WM_COPYDATA(wParam, lParam, *){
	Critical
	global CurrentWalk, W, S, A, D, Space
	StringAddress := NumGet(lParam + 2 * A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
	StringText := StrGet(StringAddress)  ; Copy the string out of the structure.
	; pause
	DetectHiddenWindows(1)
	if (WinExist("ahk_class AutoHotkey ahk_pid " CurrentWalk.pid)) {
		Send "{F16}"
	} else {
		W_State := GetKeyState(W)
		S_State := GetKeyState(S)
		A_State := GetKeyState(A)
		D_State := GetKeyState(D)
		Space_State := GetKeyState(Space)
		PauseState := state
		PauseObjective := objective
		SendInput "{" W " up} {" S " up} {" A " up} {" D " up} {" Space " up}"
		Click("Up")
	}
	if (WinExist("ahk_class AutoHotkey ahk_pid " CurrentWalk.pid)) {
		Send "{F16}"
	} else {
			if (W_State) {
				SendInput "{" W " down}"
			}
			if (S_State) {
				SendInput "{" S " down}"
			}
			if (A_State) {
				SendInput "{" A " down}"
			}
			if (D_State) {
				SendInput "{" D " down}"
			}
			if (Space_State) {
				SendInput "{" Space " down}"
			}
	}
	DetectHiddenWindows(0)
	InStr(StringText, ": ") ? sd_SetStatus(SubStr(StringText, 1, InStr(StringText, ": ")-1), SubStr(StringText, InStr(StringText, ": ") + 2)) : sd_SetStatus(StringText)
	return 0
}

; this function ends the movement script(s)
sd_EndMovement() {
	global CurrentWalk
	DetectHiddenWindows(1)
	try {
		WinClose("ahk_class AutoHotkey ahk_pid " CurrentWalk.pid)
	}
	DetectHiddenWindows(0)
	CurrentWalk.pid := CurrentWalk.name := ""
	; if issues, we can check if closed, else kill and force keys up
}

sd_ColourfulEmbedsEasterEgg() {
	global ColourFulEmbeds
	; ChapterName1 := MainGUI["ChapterName1"].Text
	; ChapterName2 := MainGUI["ChapterName2"].Text
	; ChapterName3 := MainGUI["ChapterName3"].Text
	if ((ChapterName1 = ChapterName2) && (ChapterName2 = ChapterName3)) {
		local confirmation := MsgBox("You found an easter egg!`nEnable Rainbow Embeds?", , 0x1024 " Owner" MainGUI.Hwnd)
		if confirmation = "Yes" {
			ColourfulEmbeds := 1
		} else {
			ColourfulEmbeds := 0
		}
		IniWrite(ColourfulEmbeds, A_SettingsWorkingDir "main_config.ini", "Discord", "ColourfulEmbeds")
		PostScriptsMessage("Discord", 0x5552, 5, ColourfulEmbeds)
	}
}


SetLoadProgress(91, MainGUI, GUIName " (" LanguageText[77] " ")
