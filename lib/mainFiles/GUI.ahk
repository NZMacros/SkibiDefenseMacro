OnExit(SaveValues)

if (Month = "September") || (Month = "October") || (Month = "November") {
	TraySetIcon(A_MacroWorkingDir "img\sdm_halloweenlogo.ico", Freeze := true)
	global GUIName := LanguageText[19]
} else if (Month = "December") || (Month = "January") || (Month = "February") {
	; TraySetIcon(A_MacroWorkingDir "img\sdm_jollylogo.ico", Freeze := true)
	global GUIName := LanguageText[20]
	MsgBox "jolly icon unavailable"
} else {
	TraySetIcon(A_MacroWorkingDir "img\sdm_logo.ico", Freeze := true)
	global GUIName := LanguageText[18]
}


A_TrayMenu.Delete()
A_TrayMenu.Add()
A_TrayMenu.Add("Open Logs", (*) => ListLines())
A_TrayMenu.Add()
A_TrayMenu.Add("Edit This Script", (*) => Edit())
A_TrayMenu.Add("Suspend Hotkeys", (*) => (A_TrayMenu.ToggleCheck("Suspend Hotkeys"), Suspend()))
A_TrayMenu.Add()
A_TrayMenu.Add()
; A_TrayMenu.Add("Start Macro", sd_Start)
; A_TrayMenu.Add("Pause Macro", sd_Pause)
A_TrayMenu.Add("Stop Macro", sd_Reload)
A_TrayMenu.Add()
A_TrayMenu.Add("Start AutoClicker", sd_AutoClicker)
A_TrayMenu.Add("Close Macro", sd_Close)
A_TrayMenu.Add()
; A_TrayMenu.Default := "Start Macro"


; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
DllCall(DllCall("GetProcAddress"
		, "Ptr",DllCall("LoadLibrary", "Str", A_ThemesWorkingDir "USkin.dll")
		, "AStr","USkinInit", "Ptr")
	, "Int",0, "Int",0, "AStr", A_ThemesWorkingDir "*.msstyles")

; Ensure GUI will be visible
if (GUI_X && GUI_Y) {
	Loop (MonitorCount := MonitorGetCount()) {
		MonitorGetWorkArea A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom
		if(GUI_X>MonLeft && GUI_X<MonRight && GUI_Y>MonTop && GUI_Y<MonBottom)
			break
		if(A_Index=MonitorCount) {
			global GUI_X:=GUI_Y:=0
		}
	}
} else {
	global GUI_X:=GUI_Y:=0
}



MainGUI := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", GUIName " (Loading: 0%)")
WinSetTransparent 255-floor(GUITransparency*2.55), MainGUI
MainGUI.Show("x" GUI_X " y" GUI_Y " w500 h300")
MainGUI.OnEvent("Close", sd_Close)
MainGUI.AddText("x7 y285 +BackgroundTrans", VID)
DiscordHBitmap := Gdip_CreateHBITMAPFromBitmap(bitmaps["DiscordIcon"])
DiscordButton := MainGUI.AddPicture("x440 y271 w25 h25 +BackgroundTrans vDiscordButton Disabled")
DiscordButton.Value := "HBITMAP:" DiscordHBitmap
DiscordButton.OnEvent("Click", DiscordServer)
GitHubHBitmap := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"])
GitHubButton := MainGUI.AddPicture("x470 y270 w25 h25 +BackgroundTrans vGitHubButton Disabled")
GitHubButton.Value := "HBITMAP:" GitHubHBitmap
GitHubButton.OnEvent("Click", OpenGitHub)
MainGUI.AddButton("x10 y263 w65 h20 -Wrap vStartButton Disabled", " " LanguageText[21] " " StartHotkey).OnEvent("Click", sd_Start)
MainGUI.AddButton("x80 y263 w65 h20 -Wrap vPauseButton Disabled", " " LanguageText[22] " " PauseHotkey).OnEvent("Click", sd_Pause)
MainGUI.AddButton("x150 y263 w65 h20 -Wrap vStopButton Disabled", " " LanguageText[23] " " StopHotkey).OnEvent("Click", sd_Reload)
MainGUI.AddButton("x220 y263 w65 h20 -Wrap vAutoClickerButton Disabled", " " LanguageText[24] " " AutoClickerHotkey).OnEvent("Click", sd_AutoClicker)
MainGUI.AddButton("x290 y263 w65 h20 -Wrap vCloseButton Disabled", " " LanguageText[25] " " CloseHotkey).OnEvent("Click", sd_Close)
TabArr := ["Settings","Credits"] ;, (Code = 467854) && TabArr.Push("Advanced")
(TabCtrl := MainGui.Add("Tab", "x0 y-1 w500 h250 -Wrap", TabArr)).OnEvent("Change", (*) => TabCtrl.Focus())



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
(ThemesEdit := MainGui.AddDropDownList(GUIThemeDDLXPos " y76 w72 h100 vGUITheme Disabled", ThemesList)).Text := GUITheme, ThemesEdit.OnEvent("Change", sd_GUITheme)
MainGui.AddCheckbox("x15 y40 vAlwaysOnTop Disabled Checked" AlwaysOnTop, LanguageText[31]).OnEvent("Click", sd_AlwaysOnTop)
MainGUI.AddText("x15 y57 +BackgroundTrans", LanguageText[32])
MainGUI.AddText(GUITransparencyTextXPos " y57 +Center +BackgroundTrans vGUITransparency", GUITransparency)
MainGUI.AddUpDown("xp+17 yp-1 h16 -16 Range0-14 vGUITransparencyUpDown Disabled", GUITransparency//5).OnEvent("Change", sd_GUITransparency)
MainGUI.AddButton("x14 y100 w150 h20 vAGC Disabled", LanguageText[33]).OnEvent("Click", sd_AdvancedCustomisation)
MainGUI.AddButton("x15 y155 w150 h20 vHotkeyGUI Disabled", LanguageText[34]).OnEvent("Click", sd_HotkeyGUI)
MainGUI.AddButton("x16 yp+24 w150 h20 vAutoClickerGUI Disabled", LanguageText[35]).OnEvent("Click", sd_AutoClickerGUI)
MainGUI.AddButton("x20 yp+24 w140 h20 vHotkeyRestore Disabled", LanguageText[36]).OnEvent("Click", sd_ResetHotkeys)
MainGUI.AddText("x230 y41 +BackgroundTrans", LanguageText[37])
MainGUI.AddText(KeyDelayTextXPos " y39 w47 h18 0x201")
MainGUI.AddUpDown("Range0-9999 vKeyDelay Disabled", KeyDelay).OnEvent("Change", sd_SaveKeyDelay)
MainGUI.AddButton("x227 yp+27 " ResetSettingsButtonWidth " h20 vSettingsRestore Disabled", LanguageText[38]).OnEvent("Click", sd_ResetSettings)
MainGUI.AddButton("x400 y97 w30 h20 vReconnectTest Disabled", LanguageText[39]).OnEvent("Click", sd_ReconnectTest)
MainGUI.AddText("x230 y125 +BackgroundTrans", LanguageText[40])
MainGUI.AddEdit("x230 y150 w250 h20 vPrivServer Lowercase Disabled", PrivServer).OnEvent("Change", sd_ServerLink)
MainGUI.AddText("x235 yp+37 +BackgroundTrans", LanguageText[41])
MainGUI.AddText("xp+110 yp w48 vReconnectMethod +Center +BackgroundTrans", ReconnectMethod)
MainGUI.AddButton("xp-12 yp-1 w12 h15 vRMLeft Disabled", "<").OnEvent("Click", sd_ReconnectMethod)
MainGUI.AddButton("xp+59 yp w12 h15 vRMRight Disabled", ">").OnEvent("Click", sd_ReconnectMethod)
MainGUI.AddButton("xp+25 yp-3 w20 h20 vReconnectMethodHelp Disabled", "?").OnEvent("Click", sd_ReconnectMethodHelp)
LangArr := ["English", "Türkçe"]
MainGUI.AddText(LanguageTextXPos " y42 +BackgroundTrans", LanguageText[42])
(LanguageEdit := MainGUI.AddDropDownList("x360 y65 vLanguageSelection Disabled", LangArr)).Text := DisplayedLanguage, LanguageEdit.OnEvent("Change", sd_LanguageManager)

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
SetLoadProgress(100, MainGUI, GUIName " (" LanguageText[77] " ", "MainGUI", GUIName " " LanguageText[88])
sd_MainGUIChange(1)



SetLoadProgress(percent, GUICtrl, Title1, SavePlace, Title2 := Title1) {
    if percent < 100 {
        GUICtrl.Opt("+Disabled")
        GUICtrl.Title := Title1 Round(percent, N := 1) "%)"
    } else if (percent = 100) {
        GUICtrl.Title := Title2
		if SavePlace = "MainGUI" {
			sd_MainGUIChange(1)
		}
		if SavePlace = "HotkeyGUI" {
			sd_HotkeyGUIChange(1)
		}
		GUICtrl.Opt("-Disabled")
        GUICtrl.Flash
	}
    if percent > 100 {
        throw ValueError('"Load Progress" exceeds max value of 100', -2)
    }
    LoadPercent := "" percent ""
    IniWrite(LoadPercent, A_SettingsWorkingDir "main_config.ini", "Settings", SavePlace "LoadPercent")
}

sd_AlwaysOnTop(*){
	global
	IniWrite (AlwaysOnTop := MainGui["AlwaysOnTop"].Value), A_SettingsWorkingDir "main_config.ini", "Settings", "AlwaysOnTop"
	MainGui.Opt((AlwaysOnTop ? "+" : "-") "AlwaysOnTop")
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

sd_MainGUIChange(value) {
	MainGUI["DiscordButton"].Enabled := value
	MainGUI["GitHubButton"].Enabled := value
	; MainGUI["StartButton"].Enabled := value
	; MainGUI["PauseButton"].Enabled := value
	MainGUI["StopButton"].Enabled := value
	MainGUI["AutoClickerButton"].Enabled := value
	MainGUI["CloseButton"].Enabled := value
	MainGUI["AlwaysOnTop"].Enabled := value
	MainGUI["GUITransparencyUpDown"].Enabled := value
	; MainGUI["AGC"].Enabled := value
	MainGUI["HotkeyGUI"].Enabled := value
	MainGUI["HotkeyRestore"].Enabled := value
	MainGUI["GUITheme"].Enabled := value
	MainGUI["AutoClickerGUI"].Enabled := value
	MainGUI["KeyDelay"].Enabled := value
	MainGUI["SettingsRestore"].Enabled := value
	MainGUI["ReconnectTest"].Enabled := value
	MainGUI["PrivServer"].Enabled := value
	MainGUI["LanguageSelection"].Enabled := value
	MainGUI["ReconnectMethodHelp"].Enabled := value
	MainGUI["RMLeft"].Enabled := value
	MainGUI["RMRight"].Enabled := value
}

sd_HotkeyGUIChange(value) {
	; HotkeyGUI["StartHotkeyEdit"].Enabled := value
	; HotkeyGUI["PauseHotkeyEdit"].Enabled := value
	HotkeyGUI["StopHotkeyEdit"].Enabled := value
	HotkeyGUI["AutoClickerHotkeyEdit"].Enabled := value
	HotkeyGUI["CloseHotkeyEdit"].Enabled := value
}

sd_HotkeyGUI(*){
	global
	GUIClose(*){
		MainGUI.Opt("-Disabled"), sd_MainGUIChange(1)
		if (IsSet(HotkeyGUI) && IsObject(HotkeyGUI)) {
			Suspend(0)
			HotkeyGUI.Destroy(), HotkeyGUI := ""
            sd_Reload
        }
	}
	GUIClose()
    Suspend(1)
	HotkeyGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, LanguageText[43])
    MainGUI.Opt("+Disabled"), sd_MainGUIChange(0)
    HotkeyGUI.Show("w300 h200"), SetLoadProgress(8.3, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w290 h190", LanguageText[76]), SetLoadProgress(16.6, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y30 w60 +BackgroundTrans", LanguageText[21]), SetLoadProgress(24.9, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", LanguageText[22]), SetLoadProgress(33.2, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", LanguageText[23]), SetLoadProgress(41.5, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", LanguageText[24]), SetLoadProgress(49.8, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
    HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", LanguageText[25]), SetLoadProgress(58.1, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 y30 w200 h18 vStartHotkeyEdit Disabled", StartHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(66.4, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vPauseHotkeyEdit Disabled", PauseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(74.7, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vStopHotkeyEdit Disabled", StopHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(83.0, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vAutoClickerHotkeyEdit Disabled", AutoClickerHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(91.3, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
    HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vCloseHotkeyEdit Disabled", CloseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(99.6, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI")
	wait(1)
	HotkeyGUI.AddText("xp+2 yp+35", LanguageText[78])
	SetLoadProgress(100, HotkeyGUI, LanguageText[43] " (" LanguageText[77] " ", "HotkeyGUI", LanguageText[43])
	sd_HotkeyGUIChange(1)
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
			; try Hotkey %v%, (l = "Pause") ? nm_Pause : %l%, "Off"
			IniWrite((%v% := %k%), A_SettingsWorkingDir "main_config.ini", "Settings", v)
			; MainGui[l "Button"].Text := ((l = "Timers") ? " Show " : (l = "AutoClicker") ? "" : " ") l " (" %v% ")"
			; try Hotkey %v%, (l = "Pause") ? nm_Pause : %l%, (v = "AutoClickerHotkey") ? "On T2" : "On"
		}
	}
}

sd_ResetHotkeys(*){
	global
	local confirmation := MsgBox(LanguageText[86] "`n" LanguageText[87], LanguageText[51], 0x4)
	if confirmation = "Yes" {
		sd_HotkeyGUI()
		HotkeyGUI.Hide()
		try {
			Suspend(1)
		}
		IniWrite((StartHotkey := "F1"), A_SettingsWorkingDir "main_config.ini", "Settings", "StartHotkey")
		IniWrite((PauseHotkey := "F2"), A_SettingsWorkingDir "main_config.ini", "Settings", "PauseHotkey")
		IniWrite((StopHotkey := "F3"), A_SettingsWorkingDir "main_config.ini", "Settings", "StopHotkey")
		IniWrite((AutoClickerHotkey := "F4"), A_SettingsWorkingDir "main_config.ini", "Settings", "AutoClickerHotkey")
    	IniWrite((CloseHotkey := "F5"), A_SettingsWorkingDir "main_config.ini", "Settings", "CloseHotkey")
		HotkeyGUI["StartHotkeyEdit"].Value := "F1"
		HotkeyGUI["PauseHotkeyEdit"].Value := "F2"
		HotkeyGUI["StopHotkeyEdit"].Value := "F3"
		HotkeyGUI["AutoClickerHotkeyEdit"].Value := "F4"
    	HotkeyGUI["CloseHotkeyEdit"].Value := "F5"
		MainGUI["StartButton"].Text := " " LanguageText[21] " " StartHotkey 
		MainGUI["PauseButton"].Text := " " LanguageText[22] " " PauseHotkey 
		MainGUI["StopButton"].Text := " " LanguageText[23] " " StopHotkey 
		MainGUI["AutoClickerButton"].Text := " " LanguageText[24] " " AutoClickerHotkey 
    	MainGUI["CloseButton"].Text := " " LanguageText[25] " " CloseHotkey
		HotkeyGUI.Destroy()
		try {
			Suspend(0)
		}
		sd_AutoClickerGUI()
		AutoClickerGUI.Hide()
		IniWrite((ClickCount := 1000), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickCount")
		IniWrite((ClickDelay := 100), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDelay")
		IniWrite((ClickDuration := 50), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDuration")
		IniWrite((ClickMode := 1), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickMode")
		IniWrite((ClickButton := "LMB"), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickButton")
		AutoClickerGUI["ClickCountEdit"].Value := 1000
		AutoClickerGUI["ClickDelayEdit"].Value := 100
		AutoClickerGUI["ClickDurationEdit"].Value := 50
		AutoClickerGUI["ClickMode"].Value := 1
		AutoClickerGUI["ClickButton"].Value := "LMB"
		sd_Reload()
	}
}

sd_ResetSettings(*) {
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
		MainGUI["AlwaysOnTop"].Value = "-AlwaysOnTop"
		MainGUI["GUITransparency"].Value = "0"
		MainGUI["GUITheme"].Value = "None"
		MainGUI["KeyDelay"].Value = "25"
		MainGUI["LanguageSelection"].Value := "English"
		MainGUI["PrivServer"].Value := ""
		MainGUI["ReconnectMethod"].Value := "Deeplink"
		sd_ResetHotkeys()
	}
}

sd_GUITheme(*) {
	global
	GUITheme := MainGUI["GUITheme"].Text
	IniWrite(GUITheme, A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
	sd_Reload()
}

sd_ReconnectTest(*) {
	if (ReconnectMethod = "Deeplink") {
		if (DisconnectCheck(1) = 2) {
			MsgBox(LanguageText[52], LanguageText[53], 0x1000)
		}
	}
	if (ReconnectMethod = "Browser") {
		static ServerLabels := Map(0,"Public Server", 1,"Private Server")
		linkCodes := Map()
		for k,v in ["PrivServer"] {
			if (%v% && (StrLen(%v%) > 0)) {
				if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode) {
					linkCodes[k] := linkCode[0]
				} else {
					MsgBox(ServerLabels[k] " Invalid", "Error", 0x1000)
				}
			}
		}
		server := ((A_Index <= 20) && linkCodes.Has(n := (A_Index-1)//5 + 1)) ? n : ((n := ObjMinIndex(linkCodes))) ? n : 0
		if(BrowserReconnect(linkCodes[server], i, 0, 1) = 2) {
			MsgBox(LanguageText[54] "`n" LanguageText[55], LanguageText[53], 0x1000)
		}
	}
}

sd_ServerLink(GUICtrl, *) {
	global PrivServer
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
		GuiCtrl.Value := %k% := IsObject(NewPrivServer) ? NewPrivServer[0] : ""
		IniWrite %k%, A_SettingsWorkingDir "main_config.ini", "Settings", k

		if (k = "PrivServer") {
			PostSubmacroMessage("Status", 0x5553, 10, 6)
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

SaveValues(*) {
    SaveGUIPos()
	try {
		DllCall(A_ThemesWorkingDir "USkin.dll\USkinExit")
		Gdip_Shutdown(pToken)
		CloseScripts(1)
	}
    ExitApp()
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

sd_AdvancedCustomisation(*) {
	global
	GUIClose(*){
		MainGUI.Opt("-Disabled"), sd_MainGUIChange(1)
		if (IsSet(AdvancedGUI) && IsObject(AdvancedGUI)) {
			AdvancedGUI.Destroy(), AdvancedGUI := ""
            Suspend(0)
            sd_Reload
        }
	}
	GUIClose()
    Suspend(1)
	AdvancedGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, LanguageText[65])
    MainGUI.Opt("+Disabled"), sd_MainGUIChange(0)
    AdvancedGUI.Show("w300 h200"), SetLoadProgress(10, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	/*HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w290 h190", "Change Hotkeys"), SetLoadProgress(20, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y30 w60 +BackgroundTrans", "Start:"), SetLoadProgress(30, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Pause:"), SetLoadProgress(40, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Stop:"), SetLoadProgress(50, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Close:"), SetLoadProgress(60, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 y30 w200 h18 vStartHotkeyEdit Disabled", StartHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(70, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vPauseHotkeyEdit Disabled", PauseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(80, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vStopHotkeyEdit Disabled", StopHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(90, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vCloseHotkeyEdit Disabled", CloseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(100, HotkeyGUI, "Hotkeys", "HotkeyGUI")*/
}

sd_LanguageManager(*) {
	global
	if MainGUI["LanguageSelection"].Value = 1 {
		Language := "english"
	}
	/*if MainGUI["LanguageSelection"].Value = 2 {
		Language := "spanish"
	}*/
	if MainGUI["LanguageSelection"].Value = 2 {
		Language := "turkish"
	}
	if MainGUI["LanguageSelection"].Value = 4 {
		Language := "portuguese"
	}
	IniWrite(Language, A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
	sd_Reload()
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
	local GUICtrl, GUICtrlDuration, GUICtrlDelay
	GUIClose(*) {
		if (IsSet(AutoClickerGUI) && IsObject(AutoClickerGUI)) {
			AutoClickerGUI.Destroy(), AutoClickerGUI := ""
		}
	}
	GUIClose()
	AutoClickerGUI := GUI("+AlwaysOnTop +Border", LanguageText[24])
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