OnExit(sd_Close)

if (Month = "September") || (Month = "October") || (Month = "November") {
	TraySetIcon(A_MacroWorkingDir "img_assets\icons\sdm_halloweenlogo.ico", Freeze := true)
	global GUIName := LanguageText[19]
} else if (Month = "December") || (Month = "January") || (Month = "February") {
	TraySetIcon(A_MacroWorkingDir "img_assets\icons\skibidefense_logo.ico", Freeze := true)
	global GUIName := LanguageText[20]
} else {
	TraySetIcon(A_MacroWorkingDir "img_assets\icons\sdm_logo.ico", Freeze := true)
	global GUIName := LanguageText[18]
}


A_TrayMenu.Delete()
A_TrayMenu.Add()
A_TrayMenu.Add("Open Logs", (*) => ListLines())
A_TrayMenu.Add("Edit This Script", (*) => Edit())
A_TrayMenu.Add()
A_TrayMenu.Add("Open Window Information", (*) => WindowInformation())
A_TrayMenu.Add("Suspend Hotkeys", (*) => (A_TrayMenu.ToggleCheck("Suspend Hotkeys"), Suspend()))
A_TrayMenu.Add()
A_TrayMenu.Add()
A_TrayMenu.Add("Start Macro", sd_Start)
A_TrayMenu.Add("Pause Macro", sd_Pause)
A_TrayMenu.Add("Stop Macro", sd_Stop)
A_TrayMenu.Add()
A_TrayMenu.Add("Start AutoClicker", sd_AutoClicker)
A_TrayMenu.Add("Close Macro", sd_Close)
A_TrayMenu.Add()
A_TrayMenu.Default := "Start Macro"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI SKINNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
DllCall(DllCall("GetProcAddress"
 , "Ptr",DllCall("LoadLibrary", "Str", A_ThemesWorkingDir "USkin.dll")
 , "AStr","USkinInit", "Ptr")
 , "Int", 0, "Int", 0, "AStr", A_ThemesWorkingDir "" GUITheme ".msstyles")


; Ensure GUI will be visible
if (GUI_X && GUI_Y) {
	Loop (MonitorCount := MonitorGetCount()) {
		MonitorGetWorkArea(A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom)
		if (GUI_X > MonLeft && GUI_X < MonRight && GUI_Y > MonTop && GUI_Y < MonBottom) {
			break
		}
		if (A_Index = MonitorCount) {
			global GUI_X := GUI_Y := 0
		}
	}
} else {
	global GUI_X := GUI_Y := 0
}



MainGUI := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", GUIName " (Loading: 0%)")
WinSetTransparent 255-floor(GUITransparency*2.55), MainGUI
MainGUI.Show("x" GUI_X " y" GUI_Y " w500 h300")
MainGUI.OnEvent("Close", sd_Close)
MainGUI.AddText("x7 y285 +BackgroundTrans", "v" VersionID)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["WarningIcon"])
MainGUI.AddPicture("+BackgroundTrans x420 y280 w14 h14 Hidden vUpdateButton", "HBITMAP:*" hBM).OnEvent("Click", sd_AutoUpdateGUI)
DllCall("DeleteObject", "Ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"])
MainGUI.AddPicture("+BackgroundTrans x470 y270 w25 h25 vGitHubButton", "HBITMAP:*" hBM).OnEvent("Click", OpenGitHub)
DllCall("DeleteObject", "Ptr", hBM)
pBM := Gdip_BitmapConvertGray(bitmaps["DiscordIcon"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
MainGUI.AddPicture("+BackgroundTrans x440 y271 w25 h25 vDiscordButton", "HBITMAP:*" hBM).OnEvent("Click", DiscordServer)
Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)
MainGUI.AddButton("x10 y264 w65 h20 -Wrap vStartButton Disabled", " " LanguageText[21] " " StartHotkey).OnEvent("Click", StartButton)
MainGUI.AddButton("x80 y264 w65 h20 -Wrap vPauseButton Disabled", " " LanguageText[22] " " PauseHotkey).OnEvent("Click", PauseButton)
MainGUI.AddButton("x150 y264 w65 h20 -Wrap vStopButton Disabled", " " LanguageText[23] " " StopHotkey).OnEvent("Click", StopButton)
MainGUI.AddButton("x220 y264 w65 h20 -Wrap vAutoClickerButton Disabled", " " LanguageText[24] " " AutoClickerHotkey).OnEvent("Click", AutoClickerButton)
MainGUI.AddButton("x290 y264 w65 h20 -Wrap vCloseButton Disabled", " " LanguageText[25] " " CloseHotkey).OnEvent("Click", CloseButton)
MainGUI.AddText("x12 y250", "Current Chapter:")
MainGUI.AddText("xp+85 yp-1 w65 h14 +Center +BackgroundTrans +Border vCurrentChapter", CurrentChapter := ChapterName%CurrentChapterNum%)
MainGUI.AddText("x55 y285", "Status:")
MainGUI.AddText("xp+40 yp-1 w300 +BackgroundTrans +Border vCurrentState", "Startup: GUI")
; Create an array of default tabs
DefaultTabs := ["Status", "Settings", "Miscellaneous", "Credits"]
; Get all files in the Plugins directory, excluding PluginsExample.ahk
PluginFiles := []
Loop Files A_MacroWorkingDir "lib\Plugins\*.ahk" {
    SplitPath(A_LoopFilePath, &FileName)
    if (FileName != "PluginsExample.ahk") {
        PluginFiles.Push(StrReplace(fileName, ".ahk"))
    }
}
; Combine default tabs and plugin tabs
TabArr := DefaultTabs.Clone(), TabArr.Push(PluginFiles*)
; Create the Tab control with all tabs
(TabCtrl := MainGUI.Add("Tab", "x0 y-1 w500 h250 -Wrap", TabArr)).OnEvent("Change", (*) => TabCtrl.Focus())



TabCtrl.UseTab("Status")
MainGUI.SetFont("w700")
MainGUI.AddGroupBox("x5 y23 w240 h210", "Status Log")
MainGUI.AddGroupBox("x250 y23 w245 h160", "Statistics")
MainGUI.Add("GroupBox", "x250 y185 w245 h48", "Discord Integration")

MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
MainGUI.AddCheckBox("x85 y23 Disabled vReverseStatusLog Checked" ReversedStatusLog, "Reverse Order").OnEvent("Click", sd_ReverseStatusLog)
MainGUI.AddText("x10 y37 w230 r15 +BackgroundTrans -Wrap vStatusLog")
MainGUI.SetFont("w700")
MainGUI.AddText("x275 y40", "Session")
MainGUI.AddText("x375 y40", "Total")
MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
MainGUI.AddText("x255 y55 w119 h120 -Wrap vSessionStats")
MainGUI.AddText("x375 y55 w119 h120 -Wrap vTotalStats")
MainGUI.AddButton("x412 y39 w50 h15 vResetTotalStats Disabled", "Reset").OnEvent("Click", sd_ResetTotalStats)
MainGUI.AddButton("x400 y183 w15 h20 vDiscordIntegrationHelp Disabled", "?").OnEvent("Click", sd_DiscordIntegrationHelp)
MainGUI.AddButton("xp+12 yp+2 w12 h12 vDiscordIntegrationDocumentation Disabled", "*").OnEvent("Click", sd_DiscordIntegrationDocumentation)
MainGUI.AddButton("x265 y202 w215 h24 vDiscordIntegrationGUI Disabled", "Change Discord Settings").OnEvent("Click", sd_DiscordIntegrationGUI)
sd_SetStats()


TabCtrl.UseTab("Settings")
MainGUI.SetFont("s8 cDefault Bold", "Tahoma")
MainGUI.AddGroupBox("x10 y25 w200 h100 +BackgroundTrans", LanguageText[26])
MainGUI.AddGroupBox("x10 y130 w200 h100 +BackgroundTrans", LanguageText[27])
MainGUI.AddGroupBox("x220 y25 w270 h70 +BackgroundTrans", LanguageText[28])
MainGUI.AddGroupBox("x220 y100 w270 h130 +BackgroundTrans", LanguageText[29])

MainGUI.SetFont("Norm")
MainGUI.AddText("x15 y80 +BackgroundTrans", LanguageText[30])
ThemesList := []
Loop Files A_ThemesWorkingDir "*.msstyles" {
	ThemesList.Push(StrReplace(A_LoopFileName, ".msstyles"))
}
(ThemesEdit := MainGUI.Add("DropDownList", GUIThemeDDLXPos " y76 w72 h100 vGUITheme Disabled", ThemesList)).Text := GUITheme, ThemesEdit.OnEvent("Change", sd_GUITheme)
MainGUI.AddCheckBox("x15 y40 vAlwaysOnTop Disabled Checked" AlwaysOnTop, LanguageText[31]).OnEvent("Click", sd_AlwaysOnTop)
MainGUI.AddText("x15 y57 +BackgroundTrans", LanguageText[32])
MainGUI.AddText(GUITransparencyTextXPos " y57 +Center +BackgroundTrans vGUITransparency", GUITransparency)
MainGUI.AddUpDown("xp+17 yp-1 h16 -16 Range0-14 vGUITransparencyUpDown Disabled", GUITransparency//5).OnEvent("Change", sd_GUITransparency)
MainGUI.AddButton("x14 y100 w150 h20 vAdvancedOptions Disabled", LanguageText[33]).OnEvent("Click", sd_AdvancedOptions)
MainGUI.AddButton("x15 y155 w150 h20 vHotkeyGUI Disabled", LanguageText[34]).OnEvent("Click", sd_HotkeyGUI)
MainGUI.AddButton("x16 yp+24 w150 h20 vAutoClickerGUI Disabled", LanguageText[35]).OnEvent("Click", sd_AutoClickerGUI)
MainGUI.AddButton("x20 yp+24 w140 h20 vHotkeyRestore Disabled", LanguageText[36]).OnEvent("Click", sd_ResetHotkeysButton)
MainGUI.AddText("x230 y41 +BackgroundTrans", LanguageText[37])
MainGUI.AddText(KeyDelayTextXPos " y39 w47 h18 0x201")
MainGUI.AddUpDown("Range0-9999 vKeyDelay Disabled", KeyDelay).OnEvent("Change", sd_SaveKeyDelay)
MainGUI.AddButton("x227 yp+27 " ResetSettingsButtonWidth " h20 vSettingsRestore Disabled", LanguageText[38]).OnEvent("Click", sd_ResetSettingsButton)
MainGUI.AddButton("x400 y97 w30 h20 vReconnectTest Disabled", LanguageText[39]).OnEvent("Click", sd_ReconnectTest)
MainGUI.AddText("x230 y125 +BackgroundTrans", LanguageText[40])
MainGUI.AddEdit("x230 y150 w250 h20 vPrivServer Lowercase Disabled", PrivServer).OnEvent("Change", sd_ServerLink)
MainGUI.AddText("x235 yp+37 +BackgroundTrans", LanguageText[41])
MainGUI.AddText("xp+110 yp w48 vReconnectMethod +Center +BackgroundTrans", ReconnectMethod)
MainGUI.AddButton("xp-12 yp-1 w12 h15 vRMLeft Disabled", "<").OnEvent("Click", sd_ReconnectMethod)
MainGUI.AddButton("xp+59 yp w12 h15 vRMRight Disabled", ">").OnEvent("Click", sd_ReconnectMethod)
MainGUI.AddButton("xp+25 yp-3 w20 h20 vReconnectMethodHelp Disabled", "?").OnEvent("Click", sd_ReconnectMethodHelp)
(FallbackEdit := MainGUI.AddCheckBox("x230 y210 w132 h15 vPublicFallback Disabled Checked" PublicFallback, "Fallback to Public Server")).Section := "Settings", FallbackEdit.OnEvent("Click", sd_UpdateConfigShortcut)
MainGUI.AddButton("x380 y207 w20 h20 vPublicFallbackHelp Disabled", "?").OnEvent("Click", sd_PublicFallbackHelp)
LangArr := ["English", "Español", "Türkçe", "Português"]
MainGUI.AddText(LanguageTextXPos " y42 +BackgroundTrans", LanguageText[42])
(LanguageEdit := MainGUI.AddDropDownList("x360 y65 vLanguageSelection Disabled", LangArr)).Text := DisplayedLanguage, LanguageEdit.OnEvent("Change", sd_LanguageManager)


TabCtrl.UseTab("Miscellaneous")
MainGUI.SetFont("s8 cDefault Bold", "Tahoma")
MainGUI.AddGroupBox("x5 y23 w180 h105", "GitHub")

MainGUI.SetFont("Norm")
; reporting
MainGUI.AddButton("x15 y40 w150 h20 vReportBugs Disabled", "Report a Bug").OnEvent("Click", sd_ReportBugButton)
MainGUI.AddButton("x15 y65 w150 h20 vMakeSuggestions Disabled", "Make a Suggestion").OnEvent("Click", sd_MakeSuggestionButton)
MainGUI.AddButton("x15 y90 w150 h30 vReportSecurityBreaches Disabled", "Report a Security Vulnerability").OnEvent("Click", sd_ReportSecurityVulnerabilitiesButton)
; other
MainGUI.AddText("x20 y180 vDoesItWorkCounter", '"Does it work" counter: 85').OnEvent("Click", sd_CommunityCreationsPost)


TabCtrl.UseTab("Credits")
MainGUI.SetFont("Bold Norm c000000 s15")
MainGUI.AddText("x10 y30", LanguageText[89])
MainGUI.SetFont("Underline Norm c0000FF s8")
MainGUI.AddText("xp yp+30", LanguageText[90]).OnEvent("Click", DiscordIconArtist)
MainGUI.SetFont("Bold Norm c000000 s15")
MainGUI.AddText("x10 y100", LanguageText[91])
MainGUI.SetFont("Underline Norm c0000FF s8")
MainGUI.AddText("x10 yp+30", LanguageText[92]).OnEvent("Click", TurkishDiscordTranslator)
MainGUI.AddText("x10 yp+20", LanguageText[93]).OnEvent("Click", SpanishDiscordTranslator)
MainGUI.AddText("x10 yp+20", LanguageText[94]).OnEvent("Click", PortugueseDiscordTranslator)

#Include "%A_ScriptDir%\..\lib\Plugins\"
; #Include "*i .ahk"



/**
 * @description Sets the current loading progress of the GUI
 * @param percent The percentage to set it to
 * @param GUICtrl The GUI to change
 * @param Title1 The title to set it to (with the percentage)
 * @param Title2 The title to set it to if the percentage is at 100
*/
SetLoadProgress(percent, GUICtrl, Title1, Title2 := Title1) {
	percent := Round(percent, 1)
    if percent < 100 {
        GUICtrl.Opt("+Disabled")
        GUICtrl.Title := Title1 percent "%)"
    } else if (percent = 100) {
        GUICtrl.Title := Title2
		sd_MainGUIKey(1)
		GUICtrl.Opt("-Disabled")
        GUICtrl.Flash
	}
    if percent > 100 {
        throw ValueError('"percent" exceeds max value of 100', -2)
    }
}

sd_AlwaysOnTop(*){
	global
	IniWrite (AlwaysOnTop := MainGUI["AlwaysOnTop"].Value), A_SettingsWorkingDir "main_config.ini", "Settings", "AlwaysOnTop"
	MainGUI.Opt((AlwaysOnTop ? "+" : "-") "AlwaysOnTop")
}

sd_GUITransparency(*){
	global GUITransparency
	MainGUI["GUITransparency"].Text := GUITransparency := MainGUI["GUITransparencyUpDown"].Value * 5
	IniWrite(GUITransparency, A_SettingsWorkingDir "main_config.ini", "Settings", "GUITransparency")
	WinSetTransparent 255-floor(GUITransparency * 2.55), MainGUI
}

sd_SaveKeyDelay(*){
	global
	KeyDelay := MainGUI["KeyDelay"].Value
	IniWrite(KeyDelay, A_SettingsWorkingDir "main_config.ini", "Settings", "KeyDelay")
}

sd_MainGUIKey(value) {
	global
	
	; default
	MainGUI["DiscordButton"].Enabled := value
	MainGUI["GitHubButton"].Enabled := value
	MainGUI["StartButton"].Enabled := value
	MainGUI["PauseButton"].Enabled := value
	MainGUI["StopButton"].Enabled := value
	MainGUI["AutoClickerButton"].Enabled := value
	MainGUI["CloseButton"].Enabled := value

	; status
	MainGUI["ReverseStatusLog"].Enabled := value
	MainGUI["ResetTotalStats"].Enabled := value
	MainGUI["DiscordIntegrationHelp"].Enabled := value
	MainGUI["DiscordIntegrationDocumentation"].Enabled := value
	MainGUI["DiscordIntegrationGUI"].Enabled := value

	; settings
	MainGUI["AlwaysOnTop"].Enabled := value
	MainGUI["GUITransparencyUpDown"].Enabled := value
	MainGUI["AdvancedOptions"].Enabled := value
	MainGUI["HotkeyGUI"].Enabled := value
	MainGUI["HotkeyRestore"].Enabled := value
	MainGUI["GUITheme"].Enabled := value
	MainGUI["AutoClickerGUI"].Enabled := value
	MainGUI["KeyDelay"].Enabled := value
	MainGUI["SettingsRestore"].Enabled := value
	MainGUI["ReconnectTest"].Enabled := value
	MainGUI["PrivServer"].Enabled := value
	; MainGUI["LanguageSelection"].Enabled := value
	MainGUI["PublicFallback"].Enabled := value
	MainGUI["PublicFallbackHelp"].Enabled := value
	MainGUI["ReconnectMethodHelp"].Enabled := value
	MainGUI["RMLeft"].Enabled := value
	MainGUI["RMRight"].Enabled := value

	; miscellaneous
	MainGUI["ReportBugs"].Enabled := value
	MainGUI["MakeSuggestions"].Enabled := value
	MainGUI["ReportSecurityBreaches"].Enabled := value
}

sd_HotkeyGUI(*) {
	global
	GUIClose(*) {
		if (IsSet(HotkeyGUI) && (IsObject(HotkeyGUI))) {
			Suspend(0)
			MainGUI.Opt("-Disabled"), sd_MainGUIKey(1)
			HotkeyGUI.Destroy(), HotkeyGUI := ""
            Reload()
        }
	}
	GUIClose()
    Suspend(1)
	HotkeyGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, LanguageText[43])
    MainGUI.Opt("+Disabled"), sd_MainGUIKey(0)
	HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w290 h190", LanguageText[76])
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y30 +BackgroundTrans", LanguageText[21])
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[22])
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[23])
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[24])
    HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[25])
	HotkeyGUI.AddHotkey("x70 y30 w200 h18 vStartHotkeyEdit Disabled", StartHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vPauseHotkeyEdit", PauseHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vStopHotkeyEdit", StopHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vAutoClickerHotkeyEdit", AutoClickerHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vCloseHotkeyEdit", CloseHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddText("xp+2 yp+35", LanguageText[78])
	HotkeyGUI.Show("w300 h200")
}

sd_SaveHotkey(GUICtrl, *){
	global
	local k, v, l, NewHotkey, StartHotkeyEdit, PauseHotkeyEdit, StopHotkeyEdit, AutoClickerHotkeyEdit, CloseHotkeyEdit
	k := GUICtrl.Name, %k% := GUICtrl.Value

	v := StrReplace(k, "Edit")
	if !(%k% ~= "^[!^+]+$") {
		; do not allow necessary keys
		switch Format("sc{:03X}", GetKeySC(%k%)), 0 {
			case W, A, S, D, I, O, E, R, "sc026", Escape, Enter, LShift, RShift, Space:
			GUICtrl.Value := %v%
			MsgBox(LanguageText[44] "`n" LanguageText[45], LanguageText[46], 0x1030)
			return

			case Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine:
			GUICtrl.Value := %v%
			MsgBox(LanguageText[44] "`n" LanguageText[47], LanguageText[46], 0x1030)
			return
		}

		if ((StrLen(%k%) = 0) || (%k% = StartHotkey) || (%k% = PauseHotkey) || (%k% = StopHotkey) || (%k% = AutoClickerHotkey) || (%k% = CloseHotkey)) { ; do not allow empty or already used hotkey (not necessary in most cases)
			GUICtrl.Value := %v%
			MsgBox(LanguageText[44] "`n" LanguageText[48] "`n`n" LanguageText[79], LanguageText[46], 0x1030)
		} else { ; update the hotkey
			l := StrReplace(v, "Hotkey")
			try {
				Hotkey(%v%, (l = "Pause") ? sd_Pause : %l%, "Off")
			}
			IniWrite((%v% := %k%), A_SettingsWorkingDir "main_config.ini", "Settings", v)
			; MainGUI[l "Button"].Text := ((l = "Close") ? " Show " : (l = "AutoClicker") ? "" : " ") l " (" %v% ")"
			try {
				Hotkey(%v%, (l = "Pause") ? sd_Pause : %l%, (v = "AutoClickerHotkey") ? "On T2" : "On")
			}
		}
	}
}

sd_ResetHotkeys() {
	global
	local confirmation := MsgBox(LanguageText[86] "`n" LanguageText[87], LanguageText[51], 0x4)
	if confirmation = "Yes" {
		try {
			Hotkey(StartHotkey, sd_Start, "Off")
			Hotkey(PauseHotkey, sd_Pause, "Off")
			Hotkey(StopHotkey, sd_Stop, "Off")
			Hotkey(AutoClickerHotkey, sd_AutoClicker, "Off")
			Hotkey(CloseHotkey, sd_Close, "Off")
		}
		IniWrite((StartHotkey := "F1"), A_SettingsWorkingDir "main_config.ini", "Settings", "StartHotkey")
		IniWrite((PauseHotkey := "F2"), A_SettingsWorkingDir "main_config.ini", "Settings", "PauseHotkey")
		IniWrite((StopHotkey := "F3"), A_SettingsWorkingDir "main_config.ini", "Settings", "StopHotkey")
		IniWrite((AutoClickerHotkey := "F4"), A_SettingsWorkingDir "main_config.ini", "Settings", "AutoClickerHotkey")
		IniWrite((CloseHotkey := "F5"), A_SettingsWorkingDir "main_config.ini", "Settings", "CloseHotkey")
		IniWrite((ClickCount := 1000), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickCount")
		IniWrite((ClickDelay := 100), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDelay")
		IniWrite((ClickDuration := 50), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDuration")
		IniWrite((ClickMode := 1), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickMode")
		IniWrite((ClickButton := "LMB"), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickButton")
	}
}
sd_ResetHotkeysButton(*) {
	sd_ResetHotkeys()
	Reload()
}

sd_ResetSettingsButton(*) {
	sd_ResetSettings()
	Reload()
}

sd_ResetSettings() {
	global
	local confirmation := MsgBox(LanguageText[49] "`n" LanguageText[50], LanguageText[51], 0x4)
	if confirmation = "Yes" {
		IniWrite((AlwaysOnTop := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "AlwaysOnTop")
		IniWrite((GUITransparency := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "GUITransparency")
		IniWrite((GUITheme := "None"), A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
		IniWrite((KeyDelay := 25), A_SettingsWorkingDir "main_config.ini", "Settings", "KeyDelay")
		IniWrite((Language := "english"), A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
		IniWrite((PrivServer := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "PrivServer")
		IniWrite((ReconnectMethod := "Deeplink"), A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMethod")
		IniWrite((PublicFallback := 1), A_SettingsWorkingDir "main_config.ini", "Settings", "PublicFallback")
		FileDelete(A_SettingsWorkingDir "debug_log.txt")
		FileAppend("Hello world!", A_SettingsWorkingDir "debug_log.txt")
		sd_SetStatus("GUI", "Resetting Settings")
		sd_ResetSessionStats(), sd_ResetTotalStats()
		sd_ResetHotkeys(), sd_ResetAdvancedOptions(), sd_ResetDiscordIntegration()
		Reload()
	}
}

sd_GUITheme(*) {
	global
	GUITheme := MainGUI["GUITheme"].Text
	IniWrite(GUITheme, A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
	Reload()
}

sd_ReconnectTest(*) {
	sd_SetStatus("Testing", "Reconnect")
	CloseRoblox()
	if (DisconnectCheck(1) = 2) {
		MsgBox(LanguageText[52], LanguageText[53], 0x1000)
	}
}

; public fallback information
sd_PublicFallbackHelp(*) {
	MsgBox("When this option is enabled, the macro will revert to attempting to join a Public Server if your Server Link failed three times.`nOtherwise, it will keep trying the Server Link you entered above until it succeeds.", "Public Server Fallback", 0x40000)
}

sd_ServerLink(GUICtrl, *) {
	global PrivServer, FallbackServer1, FallbackServer2, FallbackServer3
	p := EditGetCurrentCol(GUICtrl)
	k := GUICtrl.Name
	str := GUICtrl.Value

	RegExMatch(str, "i)((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/14279693118\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*", &NewPrivServer)
	if ((StrLen(str) > 0) && !IsObject(NewPrivServer)) {
		GUICtrl.Value := %k%
		SendMessage 0xB1, p-2, p-2, GUICtrl
		if InStr(str, "/share?code") {
			sd_ErrorBalloon(GUICtrl, LanguageText[56], LanguageText[57] "`n" LanguageText[58] "`n" LanguageText[59] "`n" LanguageText[60])
		} else {
			sd_ErrorBalloon(GUICtrl, LanguageText[61], LanguageText[62] "`r`n" LanguageText[63] "`r`n" LanguageText[64])
		}
	} else {
		GUICtrl.Value := %k% := IsObject(NewPrivServer) ? NewPrivServer[0] : ""
		IniWrite(%k%, A_SettingsWorkingDir "main_config.ini", "Settings", k)

		if k = "PrivServer" {
			PostScriptsMessage("Discord", 0x5553, 10, 6)
		}
	}
}

sd_ErrorBalloon(Ctrl, Title, Text) {
	EBT := Buffer(4 * A_PtrSize, 0)
	NumPut("UInt", 4 * A_PtrSize
	 , "Ptr", StrPtr(Title)
	 , "Ptr", StrPtr(Text)
	 , "UInt", 3, EBT)
	DllCall("SendMessage", "UPtr", Ctrl.Hwnd, "UInt", 0x1503, "Ptr", 0, "Ptr", EBT.Ptr, "Ptr")
}

SaveGUIPos() {
	wp := Buffer(44)
	DllCall("GetWindowPlacement", "UInt", MainGUI.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int")
    y := NumGet(wp, 32, "Int")
	if (x > 0)  {
		IniWrite(x, A_SettingsWorkingDir "main_config.ini", "Settings", "GUI_X")
    }
	if (y > 0)  {
		IniWrite(y, A_SettingsWorkingDir "main_config.ini", "Settings", "GUI_Y")
    }
}

DiscordServer(*) {
    try {
		sd_RunDiscord("invite/Nfn6czrzbv")
	}
}

OpenGitHub(*) {
	try {
		Run("https://github.com/NegativeZero01/skibi-defense-macro")
	}
}

OpenGitHubReleases(*) {
	try {
		Run("https://github.com/NegativeZero01/skibi-defense-macro/releases")
	}
}

DiscordIconArtist(*) {
	try {
		sd_RunDiscord("users/1138733013463736401")
	}
}

TurkishDiscordTranslator(*) {
	try {
		sd_RunDiscord("users/1134408729710825532")
	}
}

SpanishDiscordTranslator(*) {
	try {
		sd_RunDiscord("users/677634188035358733")
	}
}

PortugueseDiscordTranslator(*) {
	try {
		sd_RunDiscord("users/847251304644083713")
	}
}

sd_AdvancedOptions(*) {
	global
	GUIClose(*){
		if (IsSet(AdvancedOptionsGUI) && (IsObject(AdvancedOptionsGUI))) {
			MainGUI.Opt("-Disabled"), sd_MainGUIKey(1)
			AdvancedOptionsGUI.Destroy(), AdvancedOptionsGUI := ""
            Reload()
        }
	}
	GUIClose()
	AdvancedOptionsGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, LanguageText[65])
    MainGUI.Opt("+Disabled"), sd_MainGUIKey(0)
	AdvancedOptionsGUI.OnEvent("Close", GUIClose)
	AdvancedOptionsGUI.AddButton("x265 y55 w40 h120 vStartupManagerGUI", "Open Macro on Startup").OnEvent("Click", sd_StartupManager)
	AdvancedOptionsGUI.AddText("x265 y25", "Custom Reconnect Message:")
	AdvancedOptionsGUI.AddEdit("x410 yp-3 w200 h20 vCustomReconnectMessage", ReconnectMessage).OnEvent("Change", sd_SaveReconnectMessage)
	AdvancedOptionsGUI.SetFont("s8 cDefault Norm", "Tahoma")
	AdvancedOptionsGUI.SetFont("w700")
	AdvancedOptionsGUI.AddGroupBox("x5 y24 w240 h90", "Fallback Private Servers")
	AdvancedOptionsGUI.AddGroupBox("x5 y124 w240 h55", "Debugging")
	AdvancedOptionsGUI.SetFont("s8 cDefault Norm", "Tahoma")
	; reconnect
	AdvancedOptionsGUI.AddText("x15 y44", "3 Fails:")
	AdvancedOptionsGUI.AddEdit("x55 y42 w180 h18 vFallbackServer1", FallbackServer1).OnEvent("Change", sd_ServerLink)
	AdvancedOptionsGUI.AddText("x15 y66", "6 Fails:")
	AdvancedOptionsGUI.AddEdit("x55 y64 w180 h18 vFallbackServer2", FallbackServer2).OnEvent("Change", sd_ServerLink)
	AdvancedOptionsGUI.AddText("x15 y88", "9 Fails:")
	AdvancedOptionsGUI.AddEdit("x55 y86 w180 h18 vFallbackServer3", FallbackServer3).OnEvent("Change", sd_ServerLink)
	; debugging
	(DebuggingScreenshotsEdit := AdvancedOptionsGUI.AddCheckBox("x15 y142 vDebuggingScreenshots Checked" DebuggingScreenshots, "Enable Discord Debugging Screenshots")).Section := "Discord", DebuggingScreenshotsEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	(DebugLogEdit := AdvancedOptionsGUI.AddCheckbox("x15 yp+20 vDebugLogEnabled Checked" DebugLogEnabled, "Enable Debug Log")).Section := "Discord", DebugLogEdit.OnEvent("Click", sd_UpdateConfigShortcut)
    AdvancedOptionsGUI.Show("w650 h200")
}

sd_SaveReconnectMessage(*) {
	IniWrite((ReconnectMessage := AdvancedOptionsGUI["CustomReconnectMessage"].Value), A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMessage")
}

sd_StartupManager(*) {
	global SMGUI
	
	if (A_IsAdmin) {
		MsgBox("Skibi Defense Macro has been run as administrator!`nStartup Manager can only launch Skibi Defense Macro on logon without admin privileges.`n`nIf you need to run Skibi Defense Macro as admin, either:`n	- Fix the reason why admin is required (reinstall Roblox unelevated, move Skibi Defense Macro folder)`n    - Manually set up a Scheduled Task in Task Scheduler with 'Run with highest privileges' checked`n    - Disable User Account Control (not recommended at all!)", "Startup Manager", 0x40030 " T120 Owner" MainGUI.Hwnd)
	}
	
		if !(task := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro", "")) {
			validScript := 0, Startup := 0, delay := "None", status := 1
		} else {
			; modified from Args() By SKAN, http://goo.gl/JfMNpN,  CD:23/Aug/2014 | MD:24/Aug/2014
			A := [], pArgs := DllCall("Shell32\CommandLineToArgvW", "Str", task, "PtrP", &nArgs := 0, "Ptr")
			Loop nArgs {
				A.Push(StrGet(NumGet((A_Index - 1) * A_PtrSize + pArgs, "UPtr"), "UTF-16"))
			}
			DllCall("LocalFree", "Ptr", pArgs)
	
			validScript := (A.Has(1) && (A[1] = A_MacroWorkingDir "Start.bat"))
			Startup := (A.Has(2) && (A[2] = 1))
			delay := (A.Has(4) && IsNumber(A[4])) ? hmsFromSeconds(A[4]) : "None"
			status := validScript ? 0 : 2
		}
	
		w := 260, h := 200
		GUIClose(*) {
			if (IsSet(SMGUI) && IsObject(SMGUI)) {
				SMGUI.Destroy(), SMGUI := ""
			}
		}
		GUIClose()
		SMGUI := Gui("+AlwaysOnTop -MinimizeBox", "Startup Manager")
		SMGUI.OnEvent("Close", GUIClose)
		SMGUI.SetFont("s11 cDefault Bold", "Tahoma")
		SMGUI.AddText("x0 y4 vStatusLabel", "Current Status: ")
		SMGUI.AddText("x0 y4 vStatusVal c" ((status > 0) ? "Red" : "Green"), (status > 0) ? "Inactive" : "Active")
		CenterText(SMGUI["StatusLabel"], SMGUI["StatusVal"], SMGUI["StatusLabel"])
		SMGUI.SetFont("s8 cDefault Bold", "Tahoma")
		SMGUI.AddText("x0 y24 w" w " h36 vStatusText +Center c" ((status > 0) ? "Red" : "Green")
		 , ((status = 0) ? "Skibi Defense Macro will automatically start on user login using the settings below:"
		 : (status = 1) ? "No Skibi Defense Macro startup found!`nUse the 'Add' button below."
		 : "Your startup needs updating!`nUse 'Add' to create a new startup."))
	
		SMGUI.AddText("x0 yp+39 vNTLabel", "Skibi Defense Macro Path: ")
		SMGUI.AddText("x0 yp vNTVal c" ((validScript) ? "Green" : "Red"), (status = 1) ? "None" : (validScript) ? "Valid" : "Invalid")
		CenterText(SMGUI["NTLabel"], SMGUI["NTVal"], SMGUI["StatusText"])
		SMGUI.AddText("x0 yp+20 vASLabel", "Start Macro On Run: ")
		SMGUI.AddText("x0 yp vASVal c" ((Startup) ? "Green" : "Red"), (status = 1) ? "None" : (Startup) ? "Enabled" : "Disabled")
		CenterText(SMGUI["ASLabel"], SMGUI["ASVal"], SMGUI["StatusText"])
		SMGUI.AddText("x0 yp+20 w" w " vDelay +Center", "Delay Duration: " delay)
	
		SMGUI.AddButton("x10 yp+30 w115 h24", "Remove").OnEvent("Click", RemoveButton)
		SMGUI.AddButton("x135 yp w115 h24", "Add").OnEvent("Click", AddButton)
	
		SMGUI.AddGroupBox("x5 yp+40 w240 h54 Section", "New Task Settings")
		SMGUI.SetFont("s8 cDefault Norm", "Tahoma")
		SMGUI.AddCheckBox("vStartupCheck x12 ys+18 Checked", "Start Macro on Run")
		SMGUI.AddText("x13 yp+16", "Delay Before Run:")
		SMGUI.AddText("vDelayText x+0 yp w50 +Center", "0s")
		SMGUI.AddUpDown("vDelayDuration x+0 yp-1 w10 h16 -16 Range0-3599", 0).OnEvent("Change", ChangeDelay)
	
		SMGUI.Show("w" w - 10 " h" h + 30)
}

ChangeDelay(*) {
	SMGUI["DelayText"].Text := hmsFromSeconds(SMGUI["DelayDuration"].Value)
}

AddButton(*) {
	global
	local task, Startup, secs

	if (task := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro", "")) {
		if (MsgBox("Are you sure?`nThis will overwrite the existing Skibi Defense Macro Startup!", "Overwrite Existing Entry", 0x40024 " T30 Owner" SMGUI.Hwnd) != "Yes") {
			return
		}
	}

	Startup := SMGUI["StartupCheck"].Value
	secs := SMGUI["DelayDuration"].Value

	RegWrite('"' A_MacroWorkingDir 'Start.bat"'
	 . ((Startup = 1) ?  ' "1"' : ' ""')		; Startup parameter
	 . ' ""'										; existing heartbeat PID
	 . ((secs > 0) ?  ' "' secs '"' : ' ""')		; delay before run (.bat)
	 , "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro")

	SMGUI["Delay"].Text := "Delay Duration: " ((secs > 0) ? hmsFromSeconds(secs) : "None")
	SMGUI["StatusVal"].SetFont("cGreen", "Tahoma"), SMGUI["StatusVal"].Text := "Active"
	CenterText(SMGUI["StatusLabel"], SMGUI["StatusVal"], SMGUI["StatusLabel"])
	SMGUI["StatusText"].SetFont("cGreen"), SMGUI["StatusText"].Text := "Skibi Defense Macro will automatically start on user login using the settings below:"
	SMGUI["NTVal"].SetFont("cGreen"), SMGUI["NTVal"].Text := "Valid"
	CenterText(SMGUI["NTLabel"], SMGUI["NTVal"], SMGUI["StatusText"])
	SMGUI["ASVal"].SetFont((Startup = 1) ? "cGreen" : "cRed"), SMGUI["ASVal"].Text := (Startup = 1) ? "Enabled" : "Disabled"
	CenterText(SMGUI["ASLabel"], SMGUI["ASVal"], SMGUI["StatusText"])
}

RemoveButton(*) {
	global

	try {
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro")
	} catch {
		; show MsgBox
	}
	else {
		SMGUI["Delay"].Text := "Delay Duration: None"
		SMGUI["StatusVal"].SetFont("cRed", "Tahoma"), SMGUI["StatusVal"].Text := "Inactive"
		CenterText(SMGUI["StatusLabel"], SMGUI["StatusVal"], SMGUI["StatusLabel"])
		SMGUI["StatusText"].SetFont("cRed"), SMGUI["StatusText"].Text := "No Skibi Defense Macro Startup found!`nUse the 'Add' button below."
		SMGUI["NTVal"].SetFont("cRed"), SMGUI["NTVal"].Text := "None"
		CenterText(SMGUI["NTLabel"], SMGUI["NTVal"], SMGUI["StatusText"])
		SMGUI["ASVal"].SetFont("cRed"), SMGUI["ASVal"].Text := "None"
		CenterText(SMGUI["ASLabel"], SMGUI["ASVal"], SMGUI["StatusText"])
	}
}

sd_LanguageManager(*) {
	global
	if MainGUI["LanguageSelection"].Value = 1 {
		Language := "english"
	}
	if MainGUI["LanguageSelection"].Value = 2 {
		Language := "spanish"
	}
	if MainGUI["LanguageSelection"].Value = 3 {
		Language := "turkish"
	}
	if MainGUI["LanguageSelection"].Value = 4 {
		Language := "portuguese"
	}
	IniWrite(Language, A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
	sd_SetStatus("GUI", "Language set to " MainGUI["LanguageSelection"].Text)
	Reload()
}

sd_ReconnectMethod(GUICtrl, *){
	global ReconnectMethod
	static val := ["Deeplink", "Browser"], l := val.Length

	if (ReconnectMethod = "Deeplink") {
		if (MsgBox(LanguageText[66] "`n`n" LanguageText[67] "`n`n" LanguageText[68], LanguageText[69], 0x1034 ' T60 Owner' MainGUI.Hwnd) = 'Yes') {
			i := 1
		} else {
			return
		}
	} else {
		i := 2
	}
	
	i := (ReconnectMethod = "Deeplink") ? 1 : 2

	MainGUI["ReconnectMethod"].Text := ReconnectMethod := val[(GUICtrl.Name = "RMRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite(ReconnectMethod, A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMethod")
}

sd_ReconnectMethodHelp(*){ ; reconnect method information
	MsgBox(LanguageText[70] "`n`n" LanguageText[71] "`n" LanguageText[72] "`n`n" LanguageText[73] "`n" LanguageText[74], LanguageText[75], 0x40000)
}

sd_AutoClickerGUI(*) {
	global
	local ClickCountEdit, ClickDurationEdit, ClickDelayEdit
	GUIClose(*) {
		if (IsSet(AutoClickerGUI) && IsObject(AutoClickerGUI)) {
			AutoClickerGUI.Destroy(), AutoClickerGUI := ""
		}
	}
	GUIClose()
	AutoClickerGUI := Gui("+AlwaysOnTop +Border", LanguageText[24])
	AutoClickerGUI.OnEvent("Close", GUIClose)
	AutoClickerGUI.SetFont("s8 cDefault w700", "Tahoma")
	AutoClickerGUI.AddGroupBox("x5 y2 w195 h100", LanguageText[80])
	AutoClickerGUI.SetFont("Norm")
	AutoClickerGUI.AddCheckBox("x110 y2 vClickMode Checked" ClickMode, "Infinite").OnEvent("Click", sd_AutoClickerClickMode)
	AutoClickerGUI.AddText("x13 y27", LanguageText[81])
	AutoClickerGUI.AddEdit("x50 yp-2 w80 h18 vClickCountEdit Number Limit7 Disabled" ClickMode)
	(ClickCountEdit := AutoClickerGUI.AddUpDown("vClickCount Range0-9999999 Disabled" ClickMode, ClickCount)).Section := "Settings", ClickCountEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	AutoClickerGUI.AddText("x133 y27", LanguageText[82])
	AutoClickerGUI.AddText("x10 yp+20", LanguageText[83])
	AutoClickerGUI.AddEdit("xp+100 yp-2 w61 h18 vClickDelayEdit Number Limit5", ClickDelay).OnEvent("Change", (*) => sd_UpdateConfigShortcut(ClickDelayEdit))
	(ClickDelayEdit := AutoClickerGUI.AddUpDown("vClickDelay Range0-99999", ClickDelay)).Section := "Settings", ClickDelayEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	AutoClickerGUI.AddText("x10 yp+20", LanguageText[84])
	AutoClickerGUI.AddEdit("xp+116 yp-2 w57 h18 vClickDurationEdit Number Limit4", ClickDuration).OnEvent("Change", (*) => sd_UpdateConfigShortcut(ClickDurationEdit))
	(ClickDurationEdit := AutoClickerGUI.AddUpDown("vClickDuration Range0-9999", ClickDuration)).Section := "Settings", ClickDurationEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	AutoClickerGUI.AddText("x10 yp+20", LanguageText[85])
	AutoClickerGUI.AddText("xp+105 yp w48 vClickButton +Center ", ClickButton)
	AutoClickerGUI.AddButton("xp-12 yp-1 w10 h12 vCBLeft", "<").OnEvent("Click", sd_AutoClickerClickButton)
	AutoClickerGUI.AddButton("xp+59 yp w10 h12 vCBRight", ">").OnEvent("Click", sd_AutoClickerClickButton)
	AutoClickerGUI.Show("w206 h104")
}

sd_AutoClickerClickMode(*) {
	global
	IniWrite (ClickMode := AutoClickerGUI["ClickMode"].Value), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickMode"
	if ClickMode = 1 {
		AutoClickerGUI["ClickCount"].Enabled := 0
		AutoClickerGUI["ClickCountEdit"].Enabled := 0
	} else if (ClickMode = 0) {
		AutoClickerGUI["ClickCount"].Enabled := 1
		AutoClickerGUI["ClickCountEdit"].Enabled := 1
	}
}

sd_AutoClickerClickButton(GUICtrl, *) {
	global ClickButton
	static val := ["LMB", "RMB"], l := val.Length

	i := (ClickButton = "LMB") ? 1 : 2

	AutoClickerGUI["ClickButton"].Text := ClickButton := val[(GUICtrl.Name = "CBRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite(ClickButton, A_SettingsWorkingDir "main_config.ini", "Settings", "ClickButton")
}

sd_ReverseStatusLog(*){
	global ReversedStatusLog
	ReversedStatusLog := MainGUI["ReverseStatusLog"].Value
	MainGUI["ReverseStatusLog"].Enabled := 0
	IniWrite(ReversedStatusLog, A_SettingsWorkingDir "main_config.ini", "Status", "ReversedStatusLog")
	if (ReversedStatusLog) {
		sd_SetStatus("GUI", "Status Log Reversed")
	} else {
		sd_SetStatus("GUI", "Status Log Un-Reversed")
	}
	MainGUI["ReverseStatusLog"].Enabled := 1
}

sd_ResetTotalStats(*){
	global
	local confirmation := MsgBox("Are you sure you would like to reset your total macro statistics?`nThis cannot be undone!", LanguageText[51], 0x4)
	if confirmation = "Yes" {
		IniWrite((TotalRuntime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalRuntime")
		IniWrite((TotalPlaytime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalPlaytime")
		IniWrite((TotalPausedTime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalPausedTime")
		IniWrite((TotalDisconnects := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalDisconnects")
		sd_SetStats()
	}
}

sd_DiscordIntegrationGUI(*) {
	global
	local DiscordUIDEdit, CEPEdit, DPEdit, CritSSEdit, DeathSSEdit, WebhookURLEdit, BotTokenEdit
	GUIClose(*) {
		if (IsSet(DiscordIntegrationGUI) && IsObject(DiscordIntegrationGUI)) {
			MainGUI.Opt("-Disabled"), sd_MainGUIKey(1)
			DiscordIntegrationGUI.Destroy(), DiscordIntegrationGUI := ""
            Reload()
		}
	}
	GUIClose()
	DiscordIntegrationGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Discord Integration Settings")
	MainGUI.Opt("+Disabled"), sd_MainGUIKey(0)
	DiscordIntegrationGUI.OnEvent("Close", GUIClose)
	DiscordIntegrationGUI.SetFont("s8 cDefault Bold", "Tahoma")
	DiscordIntegrationGUI.AddGroupBox("x5 y2 w150 h85", LanguageText[80])
	DiscordIntegrationGUI.AddGroupBox("x5 y90 w270 h77", "Channels")
	DiscordIntegrationGUI.AddGroupBox("x160 y2 w380 h85", "Pings")
	DiscordIntegrationGUI.AddGroupBox("x280 y90 w255 h45", "Screenshots")
	DiscordIntegrationGUI.AddGroupBox("x280 y130 w843 h41", "URLs/Tokens")
	DiscordIntegrationGUI.SetFont("Norm")
	DiscordIntegrationGUI.AddCheckbox("x10 y30 vEnableDiscord Checked" DiscordCheck, "Discord Integration").OnEvent("Click", sd_EnableDiscord)
	DiscordIntegrationGUI.AddCheckBox("xp y60 vSetWebhook " DiscordIntegrationDisabled " Checked" DiscordWebhookCheck, "Webhook").OnEvent("Click", sd_SetDiscordModetoWebhook)
	DiscordIntegrationGUI.AddCheckBox("xp+100 yp vSetBot " DiscordIntegrationDisabled " Checked" DiscordBotCheck, "Bot").OnEvent("Click", sd_SetDiscordModetoBot)
	(EnableMainChannel := DiscordIntegrationGUI.AddCheckBox("x10 y110 vEnableMainChannel " DiscordIntegrationDisabled " Checked" MainChannelCheck, "Main Channel")).OnEvent("Click", sd_EnableMainChannel)
	(EnableReportsChannel := DiscordIntegrationGUI.AddCheckBox("x10 y140 vEnableReportsChannel " DiscordIntegrationDisabled " Checked" ReportChannelCheck, "Reports Channel")).OnEvent("Click", sd_EnableReportsChannel)
	(MainChannelIDEdit := DiscordIntegrationGUI.AddEdit("x100 y107 w150 vMainChannelID " MainChannelEditDisabled, MainChannelID)).Section := "Discord", MainChannelIDEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ReportsChannelIDEdit := DiscordIntegrationGUI.AddEdit("x115 y137 w150 vReportChannelID " ReportsChannelEditDisabled, ReportChannelID)).Section := "Discord", ReportsChannelIDEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	DiscordIntegrationGUI.AddCheckbox("x275 y3 vEnableUserPings " DiscordIntegrationDisabled " Checked" Criticals, "User Pings").OnEvent("Click", sd_EnableUserPings)
	DiscordIntegrationGUI.AddText("x170 y30", "User ID:")
	(DiscordUIDEdit := DiscordIntegrationGUI.AddEdit("xp+45 yp-3 w150 vDiscordUserID " PingsDisabled, DiscordUserID)).Section := "Discord", DiscordUIDEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	(CEPEdit := DiscordIntegrationGUI.AddCheckBox("xp-45 yp+30 vCriticalErrorPings " PingsDisabled " Checked" CriticalErrorPings, "Critical Errors")).Section := "Discord", CEPEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	(DPEdit := DiscordIntegrationGUI.AddCheckBox("xp+88 yp vDisconnectPings " PingsDisabled " Checked" DisconnectPings, "Disconnects")).Section := "Discord", DPEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	DiscordIntegrationGUI.AddCheckBox("x400 y90 vEnableDiscordScreenshots " DiscordIntegrationDisabled " Checked" Screenshots, "Screenshots").OnEvent("Click", sd_EnableDiscordScreenshots)
	(CritSSEdit := DiscordIntegrationGUI.AddCheckBox("x285 y110 vCriticalScreenshots " ScreenshotsDisabled " Checked" CriticalScreenshots, "Critical Screenshots")).Section := "Discord", CritSSEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	(DeathSSEdit := DiscordIntegrationGUI.AddCheckBox("xp+120 yp vDeathScreenshots " ScreenshotsDisabled " Checked" DeathScreenshots, "Death Screenshots")).Section := "Discord", DeathSSEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	DiscordIntegrationGUI.AddText("x285 y150", "Webhook URL/Bot Token:")
	(WebhookURLEdit := DiscordIntegrationGUI.AddEdit("x415 yp-3 w700 vWebhookURL " DiscordIntegrationDisabled " " DiscordMode1Hidden, WebhookURL)).Section := "Discord", WebhookURLEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	(BotTokenEdit := DiscordIntegrationGUI.AddEdit("x415 yp-3 w700 vBotToken " DiscordIntegrationDisabled " " DiscordMode2Hidden, BotToken)).Section := "Discord", BotTokenEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	DiscordIntegrationGUI.AddText("x12 y172", "Please ignore incorrectly displayed values. When you make a change, it is automatically and instantly saved!`nValues should display correctly next reload.")
	DiscordIntegrationGUI.Show("w1125 h200")
}

sd_DiscordIntegrationHelp(*) {
	MsgBox("Discord Integration allows you to receive notifications through Discord about the status of your macro, allowing you to monitor your macro. Integration can also let you use commands to modify your settings, start/stop your macro etc. all from Discord. If you want to see the mini documentation, click the [*] next to the [?].", "Discord Integration Help", 0x20)
}

sd_DiscordIntegrationDocumentation(*) {
	Run(A_MacroWorkingDir ".github\docs\DiscordIntegration\DiscordIntegrationDocumentation.html", )
}

sd_EnableDiscord(*) {
	global
	IniWrite((DiscordCheck := DiscordIntegrationGUI["EnableDiscord"].Value), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordCheck")
	if DiscordCheck = 0 {
		IniWrite((MainChannelCheck := DiscordIntegrationGUI["EnableDiscord"].Value), A_SettingsWorkingDir "main_config.ini", "Discord", "MainChannelCheck")
		IniWrite((ReportChannelCheck := DiscordIntegrationGUI["EnableDiscord"].Value), A_SettingsWorkingDir "main_config.ini", "Discord", "ReportChannelCheck")
	}

	DiscordIntegrationGUI["SetWebhook"].Enabled := DiscordIntegrationGUI["EnableDiscord"].Value
	DiscordIntegrationGUI["SetBot"].Enabled := DiscordIntegrationGUI["EnableDiscord"].Value
	EnableMainChannel.Enabled := DiscordIntegrationGUI["EnableDiscord"].Value, EnableMainChannel.Redraw()
	EnableReportsChannel.Enabled := DiscordIntegrationGUI["EnableDiscord"].Value, EnableReportsChannel.Redraw()
	DiscordIntegrationGUI["MainChannelID"].Enabled := EnableMainChannel.Value
	DiscordIntegrationGUI["ReportChannelID"].Enabled := EnableReportsChannel.Value
}

sd_SetDiscordModetoWebhook(*) {
	global
	if DiscordIntegrationGUI["SetWebhook"].Value = 1 {
		IniWrite((DiscordMode := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordMode")
		DiscordIntegrationGUI["SetBot"].Value := 0
	} else if (DiscordIntegrationGUI["SetWebhook"].Value = 0) {
		IniWrite((DiscordMode := 2), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordMode")
		DiscordIntegrationGUI["SetBot"].Value := 1
	}
	Reload()
}

sd_SetDiscordModetoBot(*) {
	global
	if DiscordIntegrationGUI["SetBot"].Value = 1 {
		IniWrite((DiscordMode := 2), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordMode")
		DiscordIntegrationGUI["SetWebhook"].Value := 0
	} else if (DiscordIntegrationGUI["SetBot"].Value = 0) {
		IniWrite((DiscordMode := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordMode")
		DiscordIntegrationGUI["SetWebhook"].Value := 1
	}
	Reload()
}

sd_EnableMainChannel(*) {
	global
	DiscordIntegrationGUI["MainChannelID"].Enabled := EnableMainChannel.Value
	IniWrite((MainChannelCheck := EnableMainChannel.Value), A_SettingsWorkingDir "main_config.ini", "Discord", "MainChannelCheck")
}

sd_EnableReportsChannel(*) {
	global
	DiscordIntegrationGUI["ReportChannelID"].Enabled := EnableReportsChannel.Value
	IniWrite((ReportChannelCheck := EnableReportsChannel.Value), A_SettingsWorkingDir "main_config.ini", "Discord", "ReportChannelCheck")
}

sd_EnableUserPings(*) {
	global
	DiscordIntegrationGUI["DiscordUserID"].Enabled := DiscordIntegrationGUI["EnableUserPings"].Value
	DiscordIntegrationGUI["CriticalErrorPings"].Enabled := DiscordIntegrationGUI["EnableUserPings"].Value
	DiscordIntegrationGUI["DisconnectPings"].Enabled := DiscordIntegrationGUI["EnableUserPings"].Value
	IniWrite((Criticals := DiscordIntegrationGUI["EnableUserPings"].Value), A_SettingsWorkingDir "main_config.ini", "Discord", "Criticals")
}

sd_EnableDiscordScreenshots(*) {
	global
	DiscordIntegrationGUI["CriticalScreenshots"].Enabled := DiscordIntegrationGUI["EnableUserPings"].Value
	DiscordIntegrationGUI["DeathScreenshots"].Enabled := DiscordIntegrationGUI["EnableUserPings"].Value
	IniWrite((Screenshots := DiscordIntegrationGUI["EnableDiscordScreenshots"].Value), A_SettingsWorkingDir "main_config.ini", "Discord", "Screenshots")
}

; buttons
StartButton(GUICtrl, *){
	MouseGetPos( , , , &hCtrl, 2)
	if hCtrl = GUICtrl.Hwnd {
		SetTimer(sd_Start, -50)
	}
}

PauseButton(GUICtrl, *){
	MouseGetPos( , , , &hCtrl, 2)
	if hCtrl = GUICtrl.Hwnd {
		return sd_Pause()
	}
}

StopButton(GUICtrl, *) {
	MouseGetPos( , , , &hCtrl, 2)
	if hCtrl = GUICtrl.Hwnd {
		return sd_Stop()
	}
}

AutoClickerButton(GUICtrl, *) {
	MouseGetPos( , , , &hCtrl, 2)
	if hCtrl = GUICtrl.Hwnd {
		return sd_AutoClicker()
	}
}

CloseButton(GUICtrl, *) {
	MouseGetPos( , , , &hCtrl, 2)
	if hCtrl = GUICtrl.Hwnd {
		return sd_Close()
	}
}

WindowInformation(*) {
	try {
		Run('"' exe_path32 '" /script "' A_MacroWorkingDir 'submacros\WindowInformation.ahk" ')
	}
}

sd_ReportBugButton(*) {
	Run("https://github.com/NegativeZero01/skibi-defense-macro/issues/new?assignees=&labels=bug&projects=&template=bug-report.yml")
}

sd_MakeSuggestionButton(*) {
	Run("https://github.com/NegativeZero01/skibi-defense-macro/issues/new?assignees=&labels=suggestion&projects=&template=suggestion.yml")
}

sd_CommunityCreationsPost(*) {
	sd_RunDiscord("channels/1145457576432128011/1301510934350532701")
}

sd_ReportSecurityVulnerabilitiesButton(*) {
	Run("https://github.com/NegativeZero01/skibi-defense-macro/security/advisories/new")
}

; current chapter up/down
sd_CurrentChapterUp(*) {
	global CurrentChapter, CurrentChapterNum
	if CurrentChapterNum = 1 { ; wrap around to bottom
		if ChapterName3 != "None" {
			CurrentChapterNum := 3
			CurrentChapter := ChapterName3
		} else if (ChapterName2 != "None") {
			CurrentChapterNum := 2
			CurrentChapter := ChapterName2
		} else {
			CurrentChapterNum := 1
			CurrentChapter := ChapterName1
		}
	} else if (CurrentChapterNum = 2) {
		CurrentChapterNum := 1
		CurrentChapter := ChapterName1
	} else if (CurrentChapterNum = 3) {
		CurrentChapterNum := 2
		CurrentChapter := ChapterName2
	}
	MainGUI["CurrentChapter"].Text := CurrentChapter
	IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
}

sd_CurrentChapterDown(*) {
	global CurrentChapter, CurrentChapterNum
	if CurrentChapterNum = 1 {
		if ChapterName2 != "None" {
			CurrentChapterNum := 2
			CurrentChapter := ChapterName2
		} else { ; default to 1
			CurrentChapterNum := 1
			CurrentChapter := ChapterName1
		}
	} else if (CurrentChapterNum = 2) {
		if ChapterName3 != "None" {
			CurrentChapterNum := 3
			CurrentChapter := ChapterName3
		} else { ; default to 1
			CurrentChapterNum := 1
			CurrentChapter := ChapterName1
		}
	} else if (CurrentChapterNum = 3) {
		CurrentChapterNum := 1
		CurrentChapter := ChapterName1
	}
	MainGUI["CurrentChapter"].Text := CurrentChapter
	IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
}

sd_ChapterSelect1(GUICtrl?, *) {
	global ChapterName1, CurrentChapterNum, CurrentChapter
	if (IsSet(GUICtrl)) {
		;ChapterName1 := MainGUI["ChapterName1"].Text
		IniWrite(ChapterName1, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName1")
	}
	CurrentChapterNum := 1
	IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
	MainGUI["CurrentChapter"].Text := ChapterName1
	CurrentChapter := ChapterName1
	sd_ColourfulEmbedsEasterEgg()
}

nm_ChapterSelect2(GUICtrl?, *) {
	global
	if (IsSet(GUICtrl)) {
		ChapterName2 := MainGUI["ChapterName2"].Text
	}
	if ChapterName2 != "None" {
		; MainGUI["ChapterName3"].Enabled := 1
	} else {
		; ChapterName1 := MainGUI["ChapterName1"].Text
		CurrentChapterNum := 1
		IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
		MainGUI["CurrentChapter"].Text := ChapterName1
		CurrentChapter := ChapterName1
		sd_ChapterSelect3(1)
	}
	if (IsSet(GUICtrl)) {
		IniWrite(ChapterName2, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName2")
	}
	sd_ColourfulEmbedsEasterEgg()
}

sd_ChapterSelect3(GUICtrl?, *) {
	global
	local hBM
	if (IsSet(GUICtrl)) {
		; ChapterName3 := MainGUI["ChapterName3"].Text
	}
	if ChapterName3 != "None" {
		;
	} else {
		ChapterName1 := MainGUI["ChapterName1"].Text
		CurrentChapterNum := 1
		IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
		MainGUI["CurrentChapter"].Text := ChapterName1
		CurrentChapter := ChapterName1
	}
	if (IsSet(GUICtrl)) {
		IniWrite(ChapterName3, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName3")
	}
	sd_ColourfulEmbedsEasterEgg()
}

sd_ResetAdvancedOptions() {
	global
	Loop 3 {
		IniWrite((FallbackServer%A_Index% := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "FallbackServer" A_Index)
	}
	IniWrite((DebuggingScreenshots := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "DebuggingScreenshots")
	IniWrite((DebugLogEnabled := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DebugLogEnabled")
	IniWrite((ReconnectMessage := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMessage")
	sd_StartupManager(), SMGUI.Hide()
	RemoveButton()
	SMGUI.Destroy()
}

sd_ResetAdvancedOptionsButton(*) {
	sd_ResetAdvancedOptions()
	Reload()
}

sd_ResetDiscordIntegrationButton(*) {
	sd_ResetDiscordIntegration()
	Reload()
}

sd_ResetDiscordIntegration() {
	global
	IniWrite((DiscordCheck := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordCheck")
	IniWrite((DiscordMode := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordMode")
	IniWrite((MainChannelCheck := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "MainChannelCheck")
	IniWrite((ReportChannelCheck := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "ReportChannelCheck")
	IniWrite((MainChannelID := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "MainChannelID")
	IniWrite((ReportChannelID := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "ReportChannelID")
	IniWrite((DiscordUserID := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordUserID")
	IniWrite((Criticals := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "Criticals")
	IniWrite((CriticalErrorPings := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "CriticalErrorPings")
	IniWrite((DisconnectPings := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DisconnectPings")
	IniWrite((DeathScreenshots := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "DeathScreenshots")
	IniWrite((Screenshots := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "Screenshots")
	IniWrite((CriticalScreenshots := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "CriticalScreenshots")
	IniWrite((WebhookURL := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "WebhookURL")
	IniWrite((BotToken := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "BotToken")
}


SetLoadProgress(Round(83.3333333333333343, 1), MainGUI, GUIName " (" LanguageText[77] " ")
