OnExit(sd_Close)

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
		if (GUI_X > MonLeft) && (GUI_X < MonRight) && (GUI_Y > MonTop) && (GUI_Y < MonBottom) {
			break
		}
		if A_Index = MonitorCount {
			global GUI_X := GUI_Y := 0
		}
	}
} else {
	global GUI_X := GUI_Y := 0
}



MainGUI := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", MacroName " (Loading: 0%)")
WinSetTransparent(255-Floor(GUITransparency * 2.55), MainGUI)
MainGUI.Show("x" GUI_X " y" GUI_Y " w500 h300")
MainGUI.OnEvent("Close", sd_Close)
VersionTextEdit := MainGUI.AddText("x482 y282 vVersionText", "v" VersionID), VersionTextEdit.Move(494 - (VersionWidth := TextExtent("v" VersionID, VersionTextEdit)))
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["WarningIcon"])
MainGUI.AddPicture("+BackgroundTrans x380 y280 w14 h14 Hidden vUpdateButton", "HBITMAP:*" hBM).OnEvent("Click", sd_AutoUpdateGUI)
DllCall("DeleteObject", "Ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"])
MainGUI.AddPicture("+BackgroundTrans x" 470 - VersionWidth - 3 " y271 w25 h23 vGitHubButton", "HBITMAP:*" hBM).OnEvent("Click", OpenGitHub)
DllCall("DeleteObject", "Ptr", hBM)
pBM := Gdip_BitmapConvertGray(bitmaps["DiscordIcon"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
MainGUI.AddPicture("+BackgroundTrans x" 440 - VersionWidth - 2 " y271 w25 h24 vDiscordButton", "HBITMAP:*" hBM).OnEvent("Click", DiscordServer)
Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)
MainGUI.AddButton("x10 y275 w65 h20 -Wrap vStartButton Disabled", " " LanguageText[21] " " StartHotkey).OnEvent("Click", StartButton)
MainGUI.AddButton("x80 y275 w65 h20 -Wrap vPauseButton Disabled", " " LanguageText[22] " " PauseHotkey).OnEvent("Click", PauseButton)
MainGUI.AddButton("x150 y275 w65 h20 -Wrap vStopButton Disabled", " " LanguageText[23] " " StopHotkey).OnEvent("Click", StopButton)
MainGUI.AddButton("x220 y275 w65 h20 -Wrap vAutoClickerButton Disabled", " " LanguageText[24] " " AutoClickerHotkey).OnEvent("Click", AutoClickerButton)
MainGUI.AddButton("x290 y275 w65 h20 -Wrap vCloseButton Disabled", " " LanguageText[25] " " CloseHotkey).OnEvent("Click", CloseButton)
MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
MainGUI.SetFont("w700")
MainGUI.AddText("x12 y255 -Wrap +BackgroundTrans", "Current Chapter:")
MainGUI.AddText("x220 y255 w30 +BackgroundTrans", "Status:")
MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
MainGUI.AddButton("x110 y254 w10 h15 vCurrentChapterUp Disabled", "<").OnEvent("Click", sd_CurrentChapterUp)
MainGUI.AddButton("x198 y254 w10 h15 vCurrentChapterDown Disabled", ">").OnEvent("Click", sd_CurrentChapterDown)
MainGUI.AddText("x122 y254 w73 +Center +BackgroundTrans +Border vCurrentChapter", CurrentChapter := ChapterName%CurrentChapterNum%)
MainGUI.AddText("x265 y254 w230 +BackgroundTrans +Border vCurrentState", "Startup: GUI")

; Create an array of default tabs
DefaultTabs := ["Game Controls", "Status", "Settings", "Miscellaneous", "Credits"]
; Get all files in the Plugins directory, excluding PluginsExample.ahk
PluginFiles := []
Loop Files A_MacroWorkingDir "lib\Plugins\*.ahk" {
    SplitPath(A_LoopFilePath, &FileName)
    if (FileName != "PluginsExample.ahk") {
        PluginFiles.Push(StrReplace(FileName, ".ahk"))
    }
}
; Combine default tabs and plugin tabs
TabArr := DefaultTabs.Clone(), TabArr.Push(PluginFiles*)
; Create the Tab control with all tabs
(TabCtrl := MainGUI.Add("Tab", "x0 y-1 w500 h250 -Wrap", TabArr)).OnEvent("Change", (*) => TabCtrl.Focus())



TabCtrl.UseTab("Game Controls")
MainGUI.SetFont("w700")
MainGUI.AddGroupBox("x5 y23 w150 h110", "Chapters")
MainGUI.AddGroupBox("x5 y135 w170 h110", "Modes")
MainGUI.AddGroupBox("x200 y23 w290 h195", "Units")

MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
(ChapterName1Edit := MainGUI.AddDropDownList("x18 y50 w106 Disabled vChapterName1", ChapterNamesList)).Text := ChapterName1, ChapterName1Edit.OnEvent("Change", sd_ChapterSelect_1)
(ChapterName2Edit := MainGUI.AddDropDownList("xp yp+25 wp Disabled vChapterName2", ["None"])).Add(ChapterNamesList), ChapterName2Edit.Text := ChapterName2, ChapterName2Edit.OnEvent("Change", sd_ChapterSelect_2)
(ChapterName3Edit := MainGUI.AddDropDownList("xp yp+25 wp Disabled vChapterName3", ["None"])).Add(ChapterNamesList), ChapterName3Edit.Text := ChapterName3, ChapterName3Edit.OnEvent("Change", sd_ChapterSelect_3)
MainGUI.AddText("x220 y40 +BackgroundTrans", "Unit Slots:")
MainGUI.AddText("x280 y40 +Center +BackgroundTrans vUnitSlots", UnitSlots)
MainGUI.AddUpDown("xp+17 yp-1 h16 -16 Range5-10 vUnitSlotsUpDown Disabled", UnitSlots).OnEvent("Change", sd_UnitSlots)
GrindModesArr := ["Loss Farm", "Games Played", "CC Farm", "XP Farm", "Win Farm"]
MainGUI.AddText("x15 y155", "Grind Mode:")
(GrindModeEdit := MainGUI.AddDropDownList("x15 y170 vGrindMode Disabled", GrindModesArr)).Text := GrindMode, GrindModeEdit.OnEvent("Change", sd_GrindMode)
MainGUI.AddButton("x140 y171 w20 h20 vGrindModesHelp Disabled", "?").OnEvent("Click", sd_GrindModesHelp)
UnitModesArr := ["Preset", "Input", "Detect"]
MainGUI.AddText("x15 y195", "Units Mode:")
(UnitModeEdit := MainGUI.AddDropDownList("x15 y210 vUnitModeEdit Disabled", UnitModesArr)).Text := UnitMode, UnitModeEdit.OnEvent("Change", sd_UnitMode)
MainGUI.AddButton("x140 y211 w20 h20 vUnitModesHelp Disabled", "?").OnEvent("Click", sd_UnitModeHelp)
MainGUI.SetFont("w700")
MainGUI.AddText("x320 y39", "1:")
MainGUI.AddText("x206 y69", "2:")
MainGUI.AddText("x345 y69", "3:")
MainGUI.AddText("x206 y99", "4:")
MainGUI.AddText("x345 y99", "5:")
MainGUI.AddText("x206 y129", "6:")
MainGUI.AddText("x345 y129", "7:")
MainGUI.AddText("x206 y159", "8:")
MainGUI.AddText("x345 y159", "9:")
MainGUI.AddText("x206 y189", "10:")
MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
(UnitSlot1Edit := MainGUI.AddDropDownList("x335 y36 vUnitSlot1Edit Disabled", UnitNamesList)).Text := UnitSlot1, UnitSlot1Edit.OnEvent("Change", sd_UnitSlotSelect_1)
(UnitSlot2Edit := MainGUI.AddDropDownList("x221 y66 vUnitSlot2Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot2Edit.Text := UnitSlot2, UnitSlot2Edit.OnEvent("Change", sd_UnitSlotSelect_2)
(UnitSlot3Edit := MainGUI.AddDropDownList("x360 y66 vUnitSlot3Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot3Edit.Text := UnitSlot3, UnitSlot3Edit.OnEvent("Change", sd_UnitSlotSelect_3)
(UnitSlot4Edit := MainGUI.AddDropDownList("x221 y96 vUnitSlot4Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot4Edit.Text := UnitSlot4, UnitSlot4Edit.OnEvent("Change", sd_UnitSlotSelect_4)
(UnitSlot5Edit := MainGUI.AddDropDownList("x360 y96 vUnitSlot5Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot5Edit.Text := UnitSlot5, UnitSlot5Edit.OnEvent("Change", sd_UnitSlotSelect_5)
(UnitSlot6Edit := MainGUI.AddDropDownList("x221 y126 vUnitSlot6Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot6Edit.Text := UnitSlot6, UnitSlot6Edit.OnEvent("Change", sd_UnitSlotSelect_6)
(UnitSlot7Edit := MainGUI.AddDropDownList("x360 y126 vUnitSlot7Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot7Edit.Text := UnitSlot7, UnitSlot7Edit.OnEvent("Change", sd_UnitSlotSelect_7)
(UnitSlot8Edit := MainGUI.AddDropDownList("x221 y156 vUnitSlot8Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot8Edit.Text := UnitSlot8, UnitSlot8Edit.OnEvent("Change", sd_UnitSlotSelect_8)
(UnitSlot9Edit := MainGUI.AddDropDownList("x360 y156 vUnitSlot9Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot9Edit.Text := UnitSlot9, UnitSlot9Edit.OnEvent("Change", sd_UnitSlotSelect_9)
(UnitSlot0Edit := MainGUI.AddDropDownList("x228 y186 vUnitSlot0Edit Disabled", ["None"])).Add(UnitNamesList), UnitSlot0Edit.Text := UnitSlot0, UnitSlot0Edit.OnEvent("Change", sd_UnitSlotSelect_0)
MainGUI.AddButton("x400 y187 w20 h20 vUnitsHelp Disabled", "?").OnEvent("Click", sd_UnitsHelp)
MainGUI.AddButton("x205 y220 vResetGameConfig", "Reset Configs").OnEvent("Click", sd_ResetGameConfigButton)
MainGUI.AddButton("x305 y220 vQuickStartButton", "Quickstart").OnEvent("Click", sd_QuickstartButton)


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
MainGUI.AddButton("x412 y39 w50 h15 vResetTotalStats Disabled", "Reset").OnEvent("Click", sd_ResetTotalStatsButton)
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
MainGUI.AddButton("x14 y100 w150 h20 vAdvancedOptions Disabled", LanguageText[33]).OnEvent("Click", sd_AdvancedOptionsGUI)
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
LangArr := ["English", "Türkçe", "Español", "Português"]
MainGUI.AddText(LanguageTextXPos " y42 +BackgroundTrans", LanguageText[42])
(LanguageEdit := MainGUI.AddDropDownList("x360 y65 vLanguageSelection Disabled", LangArr)).Text := DisplayedLanguage, LanguageEdit.OnEvent("Change", sd_LanguageManager)


TabCtrl.UseTab("Miscellaneous")
MainGUI.SetFont("s8 cDefault Bold", "Tahoma")
MainGUI.AddGroupBox("x5 y23 w180 h105", "GitHub")
MainGUI.AddGroupBox("x5 y140 w160 h80", "Skibi Defense Server")

MainGUI.SetFont("Norm")
; reporting
MainGUI.AddButton("x15 y40 w150 h20 vReportBugs Disabled", "Report a Bug").OnEvent("Click", sd_ReportBugButton)
MainGUI.AddButton("x15 y65 w150 h20 vMakeSuggestions Disabled", "Make a Suggestion").OnEvent("Click", sd_MakeSuggestionButton)
MainGUI.AddButton("x15 y90 w150 h30 vReportSecurityBreaches Disabled", "Report a Security Vulnerability").OnEvent("Click", sd_ReportSecurityVulnerabilitiesButton)
; sd server
MainGUI.AddButton("x15 y160 h30 vDankMemerAutoGrinder Disabled", "Dank Memer AutoGrinder").OnEvent("Click", sd_DankMemerAutoGrinderGUI)
MainGUI.AddText("x20 y200", '"Does it work" counter: 109').OnEvent("Click", sd_CommunityCreationsPost)


TabCtrl.UseTab("Credits")
MainGUI.SetFont("Bold Norm c000000 s15")
MainGUI.AddText("x10 y30", LanguageText[89])
MainGUI.SetFont("Underline Norm c0000FF s8")
MainGUI.AddText("xp yp+30 vDiscordIconArtist", LanguageText[90]).OnEvent("Click", DiscordIconArtist)
MainGUI.SetFont("Bold Norm c000000 s15")
MainGUI.AddText("x10 y100", LanguageText[91])
MainGUI.SetFont("Underline Norm c0000FF s8")
MainGUI.AddText("x10 yp+30 vTurkishDiscordTranslator", LanguageText[92]).OnEvent("Click", TurkishDiscordTranslator)
MainGUI.AddText("x10 yp+20 vSpanishDiscordTranslator", LanguageText[93]).OnEvent("Click", SpanishDiscordTranslator)
MainGUI.AddText("x10 yp+20 vPortugueseDiscordTranslator", LanguageText[94]).OnEvent("Click", PortugueseDiscordTranslator)

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
		sd_LockTabs(0)
		GUICtrl.Opt("-Disabled")
        GUICtrl.Flash
	}
    if percent > 100 {
        throw ValueError('"percent" exceeds max value of 100.', -2, '"percent" should only be a value between 1 and 100.')
    }
}

sd_AlwaysOnTop(*) {
	global
	IniWrite((AlwaysOnTop := MainGUI["AlwaysOnTop"].Value), A_SettingsWorkingDir "main_config.ini", "Settings", "AlwaysOnTop")
	MainGUI.Opt(((AlwaysOnTop = 1) ? "+" : "-") "AlwaysOnTop")
}

sd_GUITransparency(*) { 
	global GUITransparency
	MainGUI["GUITransparency"].Text := GUITransparency := MainGUI["GUITransparencyUpDown"].Value * 5
	IniWrite(GUITransparency, A_SettingsWorkingDir "main_config.ini", "Settings", "GUITransparency")
	WinSetTransparent(255-Floor(GUITransparency * 2.55), MainGUI)
}

sd_SaveKeyDelay(*) {
	global
	KeyDelay := MainGUI["KeyDelay"].Value
	IniWrite(KeyDelay, A_SettingsWorkingDir "main_config.ini", "Settings", "KeyDelay")
}

/**
 * @description Lock/unlock GUI tabs
 * @param lock Change the lock (1 = locked, 0 = unlocked)
 * @default 1 (Locked)
*/
sd_LockTabs(lock := 1) {
	static tabs := ["Game", "Status", "Settings", "Miscellaneous", "Credits"]
	global bitmaps

	; controls outside tabs
	if lock = 1 {
		MainGUI["CurrentChapterUp"].Enabled := 0
		MainGui["CurrentChapterDown"].Enabled := 0

		pBM := Gdip_BitmapConvertGray(bitmaps["DiscordIcon"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
		MainGUI["DiscordButton"].Value := "HBITMAP:*" hBM, MainGUI["DiscordButton"].OnEvent("Click", DiscordServer, 0)
		Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)

		MainGUI["GitHubButton"].OnEvent("Click", OpenGitHub, 0)

		c := "Lock"
	} else {
		MainGUI["CurrentChapterUp"].Enabled := 1
		MainGui["CurrentChapterDown"].Enabled := 1

		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["DiscordIcon"])
		MainGUI["DiscordButton"].Value := "HBITMAP:*" hBM, MainGUI["DiscordButton"].OnEvent("Click", DiscordServer)
		DllCall("DeleteObject", "Ptr", hBM)

		MainGUI["GitHubButton"].OnEvent("Click", OpenGitHub)

		c := "Unlock"
	}

	for i, tab in tabs {
		sd_%tab%Tab%c%()
	}
}

sd_GameTabLock() {
	MainGUI["ChapterName1"].Enabled := 0
	MainGUI["ChapterName2"].Enabled := 0
	MainGUI["ChapterName3"].Enabled := 0
	MainGUI["UnitSlotsUpDown"].Enabled := 0
	MainGUI["GrindMode"].Enabled := 0
	MainGUI["GrindModesHelp"].Enabled := 0
	UnitModeEdit.Enabled := 0
	MainGUI["UnitModesHelp"].Enabled := 0
	MainGUI["UnitsHelp"].Enabled := 0
	UnitSlot1Edit.Enabled := 0
	UnitSlot2Edit.Enabled := 0
	UnitSlot3Edit.Enabled := 0
	UnitSlot4Edit.Enabled := 0
	UnitSlot5Edit.Enabled := 0
	UnitSlot6Edit.Enabled := 0
	UnitSlot7Edit.Enabled := 0
	UnitSlot8Edit.Enabled := 0
	UnitSlot9Edit.Enabled := 0
	UnitSlot0Edit.Enabled := 0
}

sd_GameTabUnlock() {
	MainGUI["ChapterName1"].Enabled := 1
	MainGUI["ChapterName2"].Enabled := 1
	MainGUI["ChapterName3"].Enabled := 1
	MainGUI["UnitSlotsUpDown"].Enabled := 1
	MainGUI["GrindMode"].Enabled := 1
	MainGUI["GrindModesHelp"].Enabled := 1
	MainGUI["UnitsHelp"].Enabled := 1
	MainGUI["UnitModesHelp"].Enabled := 1
	UnitModeEdit.Enabled := 1
	UnitSlot1Edit.Enabled := 1
	UnitSlot2Edit.Enabled := 1
	UnitSlot3Edit.Enabled := 1
	UnitSlot4Edit.Enabled := 1
	UnitSlot5Edit.Enabled := 1
	sd_UnitSlotDefaults()
}

sd_StatusTabLock() {
	MainGUI["ReverseStatusLog"].Enabled := 0
	MainGUI["ResetTotalStats"].Enabled := 0
	MainGUI["DiscordIntegrationHelp"].Enabled := 0
	MainGUI["DiscordIntegrationDocumentation"].Enabled := 0
	MainGUI["DiscordIntegrationGUI"].Enabled := 0
}

sd_StatusTabUnlock() {
	MainGUI["ReverseStatusLog"].Enabled := 1
	MainGUI["ResetTotalStats"].Enabled := 1
	MainGUI["DiscordIntegrationHelp"].Enabled := 1
	MainGUI["DiscordIntegrationDocumentation"].Enabled := 1
	MainGUI["DiscordIntegrationGUI"].Enabled := 1
}

sd_SettingsTabLock() {
	MainGUI["AlwaysOnTop"].Enabled := 0
	MainGUI["GUITransparencyUpDown"].Enabled := 0
	MainGUI["AdvancedOptions"].Enabled := 0
	MainGUI["HotkeyGUI"].Enabled := 0
	MainGUI["HotkeyRestore"].Enabled := 0
	MainGUI["GUITheme"].Enabled := 0
	MainGUI["AutoClickerGUI"].Enabled := 0
	MainGUI["KeyDelay"].Enabled := 0
	MainGUI["SettingsRestore"].Enabled := 0
	MainGUI["ReconnectTest"].Enabled := 0
	MainGUI["PrivServer"].Enabled := 0
	LanguageEdit.Enabled := 0
	MainGUI["PublicFallback"].Enabled := 0
	MainGUI["PublicFallbackHelp"].Enabled := 0
	MainGUI["ReconnectMethodHelp"].Enabled := 0
	MainGUI["RMLeft"].Enabled := 0
	MainGUI["RMRight"].Enabled := 0
}

sd_SettingsTabUnlock() {
	MainGUI["AlwaysOnTop"].Enabled := 1
	MainGUI["GUITransparencyUpDown"].Enabled := 1
	MainGUI["AdvancedOptions"].Enabled := 1
	MainGUI["HotkeyGUI"].Enabled := 1
	MainGUI["HotkeyRestore"].Enabled := 1
	MainGUI["GUITheme"].Enabled := 1
	MainGUI["AutoClickerGUI"].Enabled := 1
	MainGUI["KeyDelay"].Enabled := 1
	MainGUI["SettingsRestore"].Enabled := 1
	MainGUI["ReconnectTest"].Enabled := 1
	MainGUI["PrivServer"].Enabled := 1
	LanguageEdit.Enabled := 1
	MainGUI["PublicFallback"].Enabled := 1
	MainGUI["PublicFallbackHelp"].Enabled := 1
	MainGUI["ReconnectMethodHelp"].Enabled := 1
	MainGUI["RMLeft"].Enabled := 1
	MainGUI["RMRight"].Enabled := 1
}

sd_MiscellaneousTabLock() {
	MainGUI["ReportBugs"].Enabled := 0
	MainGUI["MakeSuggestions"].Enabled := 0
	MainGUI["ReportSecurityBreaches"].Enabled := 0
	MainGUI["DankMemerAutoGrinder"].Enabled := 0
}

sd_MiscellaneousTabUnlock() {
	MainGUI["ReportBugs"].Enabled := 1
	MainGUI["MakeSuggestions"].Enabled := 1
	MainGUI["ReportSecurityBreaches"].Enabled := 1
	MainGUI["DankMemerAutoGrinder"].Enabled := 1
}

sd_CreditsTabLock() {
	MainGUI["TurkishDiscordTranslator"].OnEvent("Click", TurkishDiscordTranslator, 0)
	MainGUI["SpanishDiscordTranslator"].OnEvent("Click", SpanishDiscordTranslator, 0)
	MainGUI["PortugueseDiscordTranslator"].OnEvent("Click", PortugueseDiscordTranslator, 0)
	MainGUI["DiscordIconArtist"].OnEvent("Click", DiscordIconArtist, 0)
}

sd_CreditsTabUnlock() {
	MainGUI["TurkishDiscordTranslator"].OnEvent("Click", TurkishDiscordTranslator)
	MainGUI["SpanishDiscordTranslator"].OnEvent("Click", SpanishDiscordTranslator)
	MainGUI["PortugueseDiscordTranslator"].OnEvent("Click", PortugueseDiscordTranslator)
	MainGUI["DiscordIconArtist"].OnEvent("Click", DiscordIconArtist)
}

sd_HotkeyGUI(*) {
	global
	GUIClose(*) {
		if (IsSet(HotkeyGUI) && (IsObject(HotkeyGUI))) {
			Suspend(0)
			sd_LockTabs(0)
			HotkeyGUI.Destroy(), HotkeyGUI := ""
            Reload()
        }
	}
	GUIClose()
    Suspend(1)
	HotkeyGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, LanguageText[43])
    sd_LockTabs()
	HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w290 h190", LanguageText[76])
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y30 +BackgroundTrans", LanguageText[21])
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[22])
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[23])
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[24])
    HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", LanguageText[25])
	HotkeyGUI.AddHotkey("x70 y30 w200 h18 vStartHotkeyEdit", StartHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vPauseHotkeyEdit", PauseHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vStopHotkeyEdit", StopHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vAutoClickerHotkeyEdit", AutoClickerHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vCloseHotkeyEdit", CloseHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddText("xp+2 yp+35", LanguageText[78])
	HotkeyGUI.Show("w300 h200")
}

sd_SaveHotkey(GUICtrl, *) {
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
	sd_SetStatus("GUI", "Resetting Hotkeys")
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

sd_ResetHotkeysButton(*) {
	local confirmation := MsgBox("Are you sure you would like to reset your confirgurations for Hotkeys?`nThis action cannot be undone!", "Reset Hotkeys", 0x1024 " Owner" MainGUI.Hwnd)
	if confirmation = "Yes" {
		sd_ResetHotkeys()
		Reload()
	}
}

sd_ResetSettingsButton(*) {
	local confirmation := MsgBox("Are you sure you would like to reset your confirgurations for the macro?`nThis action cannot be undone!", "Reset Macro Configurations", 0x1024 " Owner" MainGUI.Hwnd)
	if confirmation = "Yes" {
		sd_ResetSettings()
		ExitApp()
	}
}

sd_ResetSettings() {
	global
	sd_SetStatus("GUI", "Resetting Settings")
	IniWrite((AlwaysOnTop := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "AlwaysOnTop")
	IniWrite((GUITransparency := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "GUITransparency")
	IniWrite((GUITheme := "None"), A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
	IniWrite((KeyDelay := 25), A_SettingsWorkingDir "main_config.ini", "Settings", "KeyDelay")
	IniWrite((Language := "english"), A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
	IniWrite((PrivServer := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "PrivServer")
	IniWrite((ReconnectMethod := "Deeplink"), A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMethod")
	IniWrite((PublicFallback := 1), A_SettingsWorkingDir "main_config.ini", "Settings", "PublicFallback")
	IniWrite((DankMemerJob := "Unemployed"), A_SettingsWorkingDIr "main_config.ini", "Miscellaneous", "DankMemerJob")
	IniWrite((DisplayedDankMemerJobCooldown := DankMemerJobCooldown := 0), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
	sd_ResetSessionStats(), sd_ResetTotalStats()
	sd_ResetHotkeys(), sd_ResetAdvancedOptions(), sd_ResetDiscordIntegration(), sd_ResetGameConfig()
	FileDelete(A_SettingsWorkingDir "debug_log.txt")
	FileAppend("[" (A_DD + 1) "/" (A_MM - 1) "][" (A_Hour//2) ":" (A_Min * 2.51) ":" (A_Sec - (A_Min * A_Hour)) "] Hello world!`n", A_SettingsWorkingDir "debug_log.txt")
	IniWrite((FirstTime := 1), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "FirstTime")
}

sd_ResetGameConfigButton(*) {
	local confirmation := MsgBox("Are you sure you would like to reset your game configurations?`nThis action cannot be undone!", "Reset Game Config", 0x1024 " Owner" MainGUI.Hwnd)
	if confirmation = "Yes" {
		sd_ResetGameConfig()
	}
}

sd_ResetGameConfig() {
	global
	IniWrite((ChapterName1 := "Chapter 1"), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName1")
	IniWrite((ChapterName2 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName2")
	IniWrite((ChapterName3 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName3")
	IniWrite((GrindMode := "Loss Farm"), A_SettingsWorkingDir "main_config.ini", "Game", "GrindMode")
	IniWrite((UnitMode := "Preset"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitMode")
	IniWrite((UnitSlot1 := "Cameraman"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot1")
	IniWrite((UnitSlot2 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot2")
	IniWrite((UnitSlot3 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot3")
	IniWrite((UnitSlot4 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot4")
	IniWrite((UnitSlot5 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot5")
	IniWrite((UnitSlot6 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot6")
	IniWrite((UnitSlot7 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot7")
	IniWrite((UnitSlot8 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot8")
	IniWrite((UnitSlot9 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot9")
	IniWrite((UnitSlot0 := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot0")
}

sd_GUITheme(*) {
	global
	GUITheme := MainGUI["GUITheme"].Text
	IniWrite(GUITheme, A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
	Reload()
}

sd_ReconnectTest(*) {
	sd_SetStatus("GUI", "Testing Reconnect")
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
		Run("https://github.com/NZMacros/SkibiDefenseMacro")
	}
}

OpenGitHubReleases(*) {
	try {
		Run("https://github.com/NZMacros/SkibiDefenseMacro/releases")
	}
}

OpenGitHubLatestRelease(*) {
	try {
		Run("https://github.com/NZMacros/SkibiDefenseMacro/releases/latest")
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

sd_AdvancedOptionsGUI(*) {
	global
	GUIClose(*) {
		if (IsSet(AdvancedOptionsGUI) && (IsObject(AdvancedOptionsGUI))) {
			sd_LockTabs(0)
			AdvancedOptionsGUI.Destroy(), AdvancedOptionsGUI := ""
            Reload()
        }
	}
	GUIClose()
	AdvancedOptionsGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, LanguageText[65])
    sd_LockTabs()
	AdvancedOptionsGUI.OnEvent("Close", GUIClose)
	AdvancedOptionsGUI.AddButton("x265 y55 w40 h120 vStartupManagerGUI", "Open Macro on Startup").OnEvent("Click", sd_StartupManager)
	AdvancedOptionsGUI.AddText("x265 y25", "Custom Reconnect Message:")
	AdvancedOptionsGUI.AddEdit("x410 y22 w200 h20 vCustomReconnectMessage", ReconnectMessage).OnEvent("Change", sd_SaveReconnectMessage)
	AdvancedOptionsGUI.AddButton("x310 y55 vResetAdvancedOptions", "Reset Configs").OnEvent("Click", sd_ResetAdvancedOptionsButton)
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
		MsgBox(MacroName " has been run as administrator!`nStartup Manager can only launch " MacroName " on logon without admin privileges.`n`nIf you need to run " MacroName " as admin, either:`n	- Fix the reason why admin is required (reinstall Roblox unelevated, move " MacroName " folder)`n    - Manually set up a Scheduled Task in Task Scheduler with 'Run with highest privileges' checked`n    - Disable User Account Control (not recommended at all!)", "Startup Manager", 0x40030 " T120 Owner" MainGUI.Hwnd)
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
		 , ((status = 0) ? MacroName " will automatically start on user login using the settings below:"
		 : (status = 1) ? "No " MacroName " startup found!`nUse the 'Add' button below."
		 : "Your startup needs updating!`nUse 'Add' to create a new startup."))
	
		SMGUI.AddText("x0 yp+39 vNTLabel", MacroName " Path: ")
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
		if (MsgBox("Are you sure?`nThis will overwrite the existing " MacroName " Startup!", "Overwrite Existing Entry", 0x40024 " T30 Owner" SMGUI.Hwnd) != "Yes") {
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
	SMGUI["StatusText"].SetFont("cGreen"), SMGUI["StatusText"].Text := MacroName " will automatically start on user login using the settings below:"
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
		SMGUI["StatusText"].SetFont("cRed"), SMGUI["StatusText"].Text := "No " MacroName " Startup found!`nUse the 'Add' button below."
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
		Language := "turkish"
	}
	if MainGUI["LanguageSelection"].Value = 3 {
		Language := "spanish"
	}
	if MainGUI["LanguageSelection"].Value = 4 {
		Language := "portuguese"
	}
	IniWrite(Language, A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
	sd_SetStatus("GUI", "Language set to " MainGUI["LanguageSelection"].Text)
	Reload()
}

sd_ReconnectMethod(GUICtrl, *) {
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

; reconnect method information
sd_ReconnectMethodHelp(*) {
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

sd_ReverseStatusLog(*) {
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

sd_ResetTotalStatsButton(*) {
	local confirmation := MsgBox("Are you sure you would like to reset your total statistics?`nThis action cannot be undone!", "Reset Total Statistics", 0x1024 " Owner" MainGUI.Hwnd)
	if confirmation = "Yes" {
		sd_ResetTotalStats()
		sd_SetStats()
		Reload()
	}
}

sd_ResetTotalStats() {
	global
	IniWrite((TotalRuntime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalRuntime")
	IniWrite((TotalPlaytime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalPlaytime")
	IniWrite((TotalPausedTime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalPausedTime")
	IniWrite((TotalDisconnects := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalDisconnects")
}

sd_DiscordIntegrationGUI(*) {
	global
	local DiscordUserIDEdit, CEPEdit, DPEdit, CritSSEdit, WebhookURLEdit, BotTokenEdit
	GUIClose(*) {
		if (IsSet(DiscordIntegrationGUI) && IsObject(DiscordIntegrationGUI)) {
			sd_LockTabs(0)
			DiscordIntegrationGUI.Destroy(), DiscordIntegrationGUI := ""
            Reload()
		}
	}
	GUIClose()
	DiscordIntegrationGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Discord Integration Settings")
	sd_LockTabs()
	DiscordIntegrationGUI.OnEvent("Close", GUIClose)
	DiscordIntegrationGUI.SetFont("s8 cDefault Bold", "Tahoma")
	DiscordIntegrationGUI.AddGroupBox("x5 y2 w150 h85", LanguageText[80])
	DiscordIntegrationGUI.AddGroupBox("x5 y90 w270 h77", "Channels")
	DiscordIntegrationGUI.AddGroupBox("x160 y2 w380 h85", "Pings")
	DiscordIntegrationGUI.AddGroupBox("x280 y90 w235 h45", "Screenshots")
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
	(DiscordUserIDEdit := DiscordIntegrationGUI.AddEdit("xp+45 yp-3 w150 vDiscordUserID " PingsDisabled, DiscordUserID)).Section := "Discord", DiscordUserIDEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	(CEPEdit := DiscordIntegrationGUI.AddCheckBox("xp-45 yp+30 vCriticalErrorPings " PingsDisabled " Checked" CriticalErrorPings, "Critical Errors")).Section := "Discord", CEPEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	(DPEdit := DiscordIntegrationGUI.AddCheckBox("xp+88 yp vDisconnectPings " PingsDisabled " Checked" DisconnectPings, "Disconnects")).Section := "Discord", DPEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	DiscordIntegrationGUI.AddCheckBox("x400 y90 vEnableDiscordScreenshots " DiscordIntegrationDisabled " Checked" Screenshots, "Screenshots").OnEvent("Click", sd_EnableDiscordScreenshots)
	(CritSSEdit := DiscordIntegrationGUI.AddCheckBox("x285 y110 vCriticalScreenshots " ScreenshotsDisabled " Checked" CriticalScreenshots, "Critical Screenshots")).Section := "Discord", CritSSEdit.OnEvent("Click", sd_UpdateConfigShortcut)
	DiscordIntegrationGUI.AddText("x285 y150", "Webhook URL/Bot Token:")
	(WebhookURLEdit := DiscordIntegrationGUI.AddEdit("x415 yp-3 w700 vWebhookURL " DiscordIntegrationDisabled " " DiscordMode1Hidden, WebhookURL)).Section := "Discord", WebhookURLEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	(BotTokenEdit := DiscordIntegrationGUI.AddEdit("x415 yp-3 w700 vBotToken " DiscordIntegrationDisabled " " DiscordMode2Hidden, BotToken)).Section := "Discord", BotTokenEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	DiscordIntegrationGUI.AddText("x12 y172", "Please ignore incorrectly displayed values. When you make a change, it is automatically and instantly saved!`nValues should display correctly next reload.")
	DiscordIntegrationGUI.AddButton("x550 y7", "Reset Configs").OnEvent("Click", sd_ResetDiscordIntegrationButton)
	DiscordIntegrationGUI.Show("w1125 h200")
}

sd_DiscordIntegrationHelp(*) {
	MsgBox("Discord Integration allows you to receive notifications through Discord about the status of your macro, allowing you to monitor your macro. Integration can also let you use commands to modify your settings, start/stop your macro etc. all from Discord. If you want to see the mini documentation, click the [*] next to the [?].", "Discord Integration Help", 0x20)
}

sd_DiscordIntegrationDocumentation(*) {
	Run("https://rawcdn.githack.com/NZMacros/GitHub/main/docs/DiscordIntegration/DiscordIntegrationDocumentation.html")
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
	IniWrite((Screenshots := DiscordIntegrationGUI["EnableDiscordScreenshots"].Value), A_SettingsWorkingDir "main_config.ini", "Discord", "Screenshots")
}

; buttons
StartButton(GUICtrl, *) {
	MouseGetPos( , , , &hCtrl, 2)
	if hCtrl = GUICtrl.Hwnd {
		SetTimer(sd_Start, -50)
	}
}

PauseButton(GUICtrl, *) {
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
	Run("https://github.com/NZMacros/GitHub/issues/new?assignees=&labels=type%3Abug%2Cmacro%3Askibi_defense_macro&projects=&template=skibi_defense_macro-bug_report.yml")
}

sd_MakeSuggestionButton(*) {
	Run("https://github.com/NZMacros/GitHub/issues/new?assignees=&labels=type%3Asuggestion%2Cmacro%3Askibi_defense_macro&projects=&template=skibi_defense_macro-suggestion.yml")
}

sd_CommunityCreationsPost(*) {
	sd_RunDiscord("channels/1145457576432128011/1301510934350532701")
}

sd_ReportSecurityVulnerabilitiesButton(*) {
	Run("https://github.com/NZMacros/SkibiDefenseMacro/security/advisories/new")
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

sd_ChapterSelect_1(GUICtrl?, *) {
	global ChapterName1, CurrentChapterNum, CurrentChapter
	if (IsSet(GUICtrl)) {
		ChapterName1 := MainGUI["ChapterName1"].Text
		IniWrite(ChapterName1, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName1")
	}
	CurrentChapterNum := 1
	IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
	MainGUI["CurrentChapter"].Text := ChapterName1
	CurrentChapter := ChapterName1
	sd_ColourfulEmbedsEasterEgg()
}

sd_ChapterSelect_2(GUICtrl?, *) {
	global
	if (IsSet(GUICtrl)) {
		ChapterName2 := MainGUI["ChapterName2"].Text
	}
	if ChapterName2 != "None" {
		MainGUI["ChapterName3"].Enabled := 1
	} else {
		ChapterName1 := MainGUI["ChapterName1"].Text
		CurrentChapterNum := 1
		IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
		MainGUI["CurrentChapter"].Text := ChapterName1
		CurrentChapter := ChapterName1
		MainGUI["ChapterName3"].Text := "None"
		MainGUI["ChapterName3"].Enabled := 0
		sd_ChapterSelect_3(1)
	}
	if (IsSet(GUICtrl)) {
		IniWrite(ChapterName2, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName2")
	}
	sd_ColourfulEmbedsEasterEgg()
}

sd_ChapterSelect_3(GUICtrl?, *) {
	global
	if (IsSet(GUICtrl)) {
		ChapterName3 := MainGUI["ChapterName3"].Text
	}
	if ChapterName3 = "None" {
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
	sd_SetStatus("GUI", "Resetting Advanced Options")
	Loop 3 {
		IniWrite((FallbackServer%A_Index% := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "FallbackServer" A_Index)
	}
	IniWrite((DebuggingScreenshots := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "DebuggingScreenshots")
	IniWrite((DebugLogEnabled := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DebugLogEnabled")
	IniWrite((ReconnectMessage := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMessage")
	try {
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro")
	}
}

sd_ResetAdvancedOptionsButton(*) {
	local confirmation := MsgBox("Are you sure you would like to reset your confirgurations for Advanced Options?`nThis action cannot be undone!", "Reset Advanced Options", 0x1024 " Owner" MainGUI.Hwnd)
	if confirmation = "Yes" {
		sd_ResetAdvancedOptions()
		Reload()
	}
}

sd_ResetDiscordIntegrationButton(*) {
	local confirmation := MsgBox("Are you sure you would like to reset your confirgurations for Discord Integration?`nThis action cannot be undone!", "Reset Discord Integration", 0x1024 " Owner" MainGUI.Hwnd)
	if confirmation = "Yes" {
		sd_ResetDiscordIntegration()
		Reload()
	}
}

sd_ResetDiscordIntegration() {
	global
	sd_SetStatus("GUI", "Resetting Discord Integration")
	IniWrite((BotToken := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "BotToken")
	IniWrite((ColourfulEmbeds := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "ColourfulEmbeds")
	IniWrite((CommandPrefix := "?"), A_SettingsWorkingDir "main_config.ini", "Discord", "CommandPrefix")
	IniWrite((CriticalErrorPings := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "CriticalErrorPings")
	IniWrite((CriticalScreenshots := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "CriticalScreenshots")
	IniWrite((Criticals := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "Criticals")
	IniWrite((DebugLogEnabled := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DebugLogEnabled")
	IniWrite((DebuggingScreenshots := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DebuggingScreenshots")
	IniWrite((DisconnectPings := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DisconnectPings")
	IniWrite((DiscordCheck := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordCheck")
	IniWrite((DiscordMode := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordMode")
	IniWrite((DiscordUserID := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordUserID")
	IniWrite((MainChannelCheck := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "MainChannelCheck")
	IniWrite((MainChannelID := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "MainChannelID")
	IniWrite((ReportChannelCheck := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "ReportChannelCheck")
	IniWrite((ReportChannelID := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "ReportChannelID")
	IniWrite((Screenshots := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "Screenshots")
	IniWrite((WebhookURL := ""), A_SettingsWorkingDir "main_config.ini", "Discord", "WebhookURL")
}

sd_UnitSlotSelect_1(*) {
	global
	IniWrite((UnitSlot1 := UnitSlot1Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot1")
}

sd_UnitSlotSelect_2(*) {
	global
	IniWrite((UnitSlot2 := UnitSlot2Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot2")
}

sd_UnitSlotSelect_3(*) {
	global
	IniWrite((UnitSlot3 := UnitSlot3Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot3")
}

sd_UnitSlotSelect_4(*) {
	global
	IniWrite((UnitSlot4 := UnitSlot4Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot4")
}

sd_UnitSlotSelect_5(*) {
	global
	IniWrite((UnitSlot5 := UnitSlot5Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot5")
}

sd_UnitSlotSelect_6(*) {
	global
	IniWrite((UnitSlot6 := UnitSlot6Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot6")
}

sd_UnitSlotSelect_7(*) {
	global
	IniWrite((UnitSlot7 := UnitSlot7Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot7")
}

sd_UnitSlotSelect_8(*) {
	global
	IniWrite((UnitSlot8 := UnitSlot8Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot8")
}

sd_UnitSlotSelect_9(*) {
	global
	IniWrite((UnitSlot9 := UnitSlot9Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot9")
}

sd_UnitSlotSelect_0(*) {
	global
	IniWrite((UnitSlot0 := UnitSlot0Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot0")
}

sd_UnitSlots(*) { 
	global UnitSlots
	MainGUI["UnitSlots"].Text := UnitSlots := MainGUI["UnitSlotsUpDown"].Value
	IniWrite(UnitSlots, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlots")
	sd_UnitSlotDefaults()
}

sd_GrindMode(*) {
	global
	IniWrite((GrindMode := MainGUI["GrindMode"].Text), A_SettingsWorkingDir "main_config.ini", "Game", "GrindMode")
	if GrindMode = "Loss Farm" {
		UnitSlot1 := "Cameraman"
		UnitSlot2 := "None"
		UnitSlot3 := "None"
		UnitSlot4 := "None"
		UnitSlot5 := "None"
		UnitSlot6 := "None"
		UnitSlot7 := "None"
		UnitSlot8 := "None"
		UnitSlot9 := "None"
		UnitSlot0 := "None"
	} else if (GrindMode = "Games Played") {
		UnitSlot1 := "Cameraman"
		UnitSlot2 := "None"
		UnitSlot3 := "None"
		UnitSlot4 := "None"
		UnitSlot5 := "None"
		UnitSlot6 := "None"
		UnitSlot7 := "None"
		UnitSlot8 := "None"
		UnitSlot9 := "None"
		UnitSlot0 := "None"
	} else if (GrindMode = "Win Farm") {
		if CurrentChapter = ChapterName1 && ChapterName1 = "Chapter 1" {
			UnitSlot1 := "Cameraman"
			UnitSlot2 := "Speakerman"
			UnitSlot3 := "TV Man"
			UnitSlot4 := "None"
			UnitSlot5 := "None"
			UnitSlot6 := "None"
			UnitSlot7 := "None"
			UnitSlot8 := "None"
			UnitSlot9 := "None"
			UnitSlot0 := "None"
		}
	}
	IniWrite(UnitSlot1, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot1"), UnitSlot1Edit.Text := UnitSlot1, UnitSlot1Edit.Redraw()
	IniWrite(UnitSlot2, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot2"), UnitSlot2Edit.Text := UnitSlot2, UnitSlot2Edit.Redraw()
	IniWrite(UnitSlot3, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot3"), UnitSlot3Edit.Text := UnitSlot3, UnitSlot3Edit.Redraw()
	IniWrite(UnitSlot4, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot4"), UnitSlot4Edit.Text := UnitSlot4, UnitSlot4Edit.Redraw()
	IniWrite(UnitSlot5, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot5"), UnitSlot5Edit.Text := UnitSlot5, UnitSlot5Edit.Redraw()
	IniWrite(UnitSlot6, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot6"), UnitSlot6Edit.Text := UnitSlot6, UnitSlot6Edit.Redraw()
	IniWrite(UnitSlot7, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot7"), UnitSlot7Edit.Text := UnitSlot7, UnitSlot7Edit.Redraw()
	IniWrite(UnitSlot8, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot8"), UnitSlot8Edit.Text := UnitSlot8, UnitSlot8Edit.Redraw()
	IniWrite(UnitSlot9, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot9"), UnitSlot9Edit.Text := UnitSlot9, UnitSlot9Edit.Redraw()
	IniWrite(UnitSlot0, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot0"), UnitSlot0Edit.Text := UnitSlot0, UnitSlot0Edit.Redraw()
}

sd_UnitSlotDefaults(*) {
	if UnitSlots = 5 {
		UnitSlot6Edit.Enabled := 0
		UnitSlot7Edit.Enabled := 0
		UnitSlot8Edit.Enabled := 0
		UnitSlot9Edit.Enabled := 0
		UnitSlot0Edit.Enabled := 0
	} else if (UnitSlots = 6) {
		UnitSlot6Edit.Enabled := 1
		UnitSlot7Edit.Enabled := 0
		UnitSlot8Edit.Enabled := 0
		UnitSlot9Edit.Enabled := 0
		UnitSlot0Edit.Enabled := 0
	} else if (UnitSlots = 7) {
		UnitSlot6Edit.Enabled := 1
		UnitSlot7Edit.Enabled := 1
		UnitSlot8Edit.Enabled := 0
		UnitSlot9Edit.Enabled := 0
		UnitSlot0Edit.Enabled := 0
	} else if (UnitSlots = 8) {
		UnitSlot6Edit.Enabled := 1
		UnitSlot7Edit.Enabled := 1
		UnitSlot8Edit.Enabled := 1
		UnitSlot9Edit.Enabled := 0
		UnitSlot0Edit.Enabled := 0
	} else if (UnitSlots = 9) {
		UnitSlot6Edit.Enabled := 1
		UnitSlot7Edit.Enabled := 1
		UnitSlot8Edit.Enabled := 1
		UnitSlot9Edit.Enabled := 1
		UnitSlot0Edit.Enabled := 0
	} else if (UnitSlots = 10) {
		UnitSlot6Edit.Enabled := 1
		UnitSlot7Edit.Enabled := 1
		UnitSlot8Edit.Enabled := 1
		UnitSlot9Edit.Enabled := 1
		UnitSlot0Edit.Enabled := 1
	}
	if UnitSlot6Edit.Enabled != 1 {
		UnitSlot6Edit.Text := "None"
	} else {
		UnitSlot6Edit.Text := UnitSlot6
	}
	if UnitSlot7Edit.Enabled != 1 {
		UnitSlot7Edit.Text := "None"
	} else {
		UnitSlot7Edit.Text := UnitSlot7
	}
	if UnitSlot8Edit.Enabled != 1 {
		UnitSlot8Edit.Text := "None"
	} else {
		UnitSlot8Edit.Text := UnitSlot8
	}
	if UnitSlot9Edit.Enabled != 1 {
		UnitSlot9Edit.Text := "None"
	} else {
		UnitSlot9Edit.Text := UnitSlot9
	}
	if UnitSlot0Edit.Enabled != 1 {
		UnitSlot0Edit.Text := "None"
	} else {
		UnitSlot0Edit.Text := UnitSlot0
	}
	gofys()
}

gofys(*) {
	gofuckyourself()
}

gofuckyourself() {
	UnitSlot1Edit.Enabled := 0
	UnitSlot2Edit.Enabled := 0
	UnitSlot3Edit.Enabled := 0
	UnitSlot4Edit.Enabled := 0
	UnitSlot5Edit.Enabled := 0
	UnitSlot6Edit.Enabled := 0
	UnitSlot7Edit.Enabled := 0
	UnitSlot8Edit.Enabled := 0
	UnitSlot9Edit.Enabled := 0
	UnitSlot0Edit.Enabled := 0
	GrindModeEdit.Enabled := 0
	UnitModeEdit.Enabled := 0
	ChapterName2Edit.Enabled := 0
	ChapterName3Edit.Enabled := 0
	LanguageEdit.Enabled := 0
	MainGUI["DankMemerAutoGrinder"].Enabled := 0
}

sd_UnitsHelp(*) {
	MsgBox("Having trouble understanding abbreviated or community-modified unit names? Continue on to the following MsgBox's to see a a list of all of them and their corresponding names in the lobby:", "Units Glossary", 0x1020 " T60 Owner" MainGUI.Hwnd)
	MsgBox("Cameraman - Camera Fighter`n`nLarge Cam - Large Camera`n`nScientist Cam - Researcher Camera`n`nCamerawoman - Camera Sniper Girl`n`nDancing Cam - Dancing Camera`n`nCam Strider - Camera Strider`n`nLaser Cam - Laser Camera`n`nUpg Cam - Upgraded Cameraguy`n`nHTC - High Tech Camera`n`nPlunger - Plunger Camera`n`nEngineer Cam - Engineer Camera`n`nGeneral Cameraman - Camera General`n`nUpg Camerawoman - Upgraded Camera Girl`n`nMech - Mech Camera`n`nTCM - Colossal Cameraguy`n`nLRC - Large Rocket Cameraguy`n`nFlamethrower - Flamethrower Cameraguy`n`nGlitch Plunger - Glitch Cameraguy`n`nUTCM - Upgraded Camera Colossal`n`nLLC - Large Laser Cameraguy`n`nUpg Mech - Upgraded Mech Camera`n`nALC - Astro Large Cameraguy`n`nUCS - Upgraded Camera Strider`n`nULLC - Upgraded Large Laser Cameraguy`n`nOrbital - Orbital Camera`n`nFred - Fred`n`nUlt Cam - Ultimate Cameraguy`n`nAUTC - Astro Upgraded Camera Colossal", "Cameras", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Speakerman - Speaker Fighter`n`nLarge Speakerman - Large Speaker`n`nHelicopter Speaker - Helicopter Speaker`n`nSpeaker Strider - Speaker Strider`n`nUpg Knife Speaker - Upgraded Knife Speakerguy`n`nDJ Woman - DJ Girl`n`nDSM - Dark Speakerguy`n`nTSM - Speaker Colossal`n`nUpg DJ Woman - Upgraded DJ Girl`n`nUTSM - Upgraded Speaker Colossal`n`nAlliance DJ - Alliance DJ`N`NUlt Speakerman - Ultimate Speakerguy`n`nHCUTSM - Overcharged Upgraded Speaker Colossal", "Speakers", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("TV Man - TV-Person`n`nTV Woman - TV-Girl`n`nBig TV Man - Large TV-Person`n`nloud big tv - Speaker Large TV-Person`n`nUpgraded TV Man - Upgraded TV Guy`n`nTTVM - Titan TV Guy`n`nEnergised TV Man - Energized TV Guy`n`nUlt TV Man - Ultimate TVGuy`n`nUTTVM - Upgraded Colossal TV Guy", "TV", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Clockwoman - Clock Girl`n`nGeneral Clockman - General Clockman`n`nLarge Clockman - Large Clockman`n`nGuardian Clockman - Guardian Clockman`n`nClock Titan - Colossal Clockman`n`nFuture Large Clock - Future Large Clockman`n`nTimer Clockman - Timer Clockman", "The Clockmen", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Normal Toilet - Normal Toilet`n`nRocket Toilet - Rocket Toilet`n`nChill Toilet - Chill Pal Toilet`n`nMafia Boss Toilet - Mafia Boss Toilet`n`nMutant Woman oiler - Mutant Woman Toilet`n`nTCT - Colossal Camera Toilet`n`nKatana Mutant Toilet - Katana Mutant Toilet`n`nScythe Mutant Toilet - Scythe Mutant Toilet`n`nG-Toilet 3 - G-Man Toilet 3.0`n`nTST - Colossal Speaker Toilet`n`nBuff Mutant Toilet - Large Buff Mutant Toilet`n`nCat Toilet - Cat Toilet`n`nG-Toilet 5 - Gman 5.0", "Toilets", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Astro UFO - Space UFO Toilet`n`nAstro Detainer - Space Detainer`n`nMini Juggernaut - Mini Astro Juggernaut`n`nAstro Juggernaut - The Juggernaut", "Astros", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Secret Agent - Secret Agent`n`nChair - Chair Phase 1`n`nSix Lens - The Strongest Camera", "???", 0x1020 " Owner" MainGUI.Hwnd)
}

sd_GrindModesHelp(*) {
	MsgBox("Grind modes allow you to choose which way you want the macro to grind currency for you. The following MsgBox's include a description for each:", "Grind Modes Help", 0x1020 " T60 Owner" MainGUI.Hwnd)
	MsgBox("In-development`n`n`nThe macro will join the chapters you select and instantly lose the game over and over again. While this isn't so efficient with credits per game, you can still earn tons of credits over longer periods of time.`n`n`nRecommended Chapters (ONLY DO THIS WITH ONE CHAPTER TO AVOID WASTING TIME CHANGING CHAPTERS): Chapter 3, Chapter 4, Chapter 5", "Loss Farm", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox('In-development`n`n`nFor the leaderboard, the macro will farm as many games as possible to increase your "Games Played" counter.`n`n`nRecommended Chapters: Endless', "Games Played", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Coming soon`n`n`nThe macro will join the selected chapter and grind clock coins using clock units, along with some backup units.`n`n`nRecommended Chapters: Chapter 1", "CC Farm", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Coming soon`n`n`nGrinds your selected chapters for XP specifically`n`n`nRecommended Chapters: Nightmare 1", "XP Farm", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Currently unavailable`n`n`nGrinds wins in your selected chapters for credits, using preset units and on 2x speed.`n`n`nRecommended Chapters: ???", "Win Farm", 0x1020 " Owner" MainGUI.Hwnd)
}

sd_UnitMode(*) {
	global
	IniWrite((UnitMode := UnitModeEdit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "UnitMode")
	if UnitMode = ("Preset" || "Detect") {
		UnitSlot1Edit.Enabled := 0
		UnitSlot2Edit.Enabled := 0
		UnitSlot3Edit.Enabled := 0
		UnitSlot4Edit.Enabled := 0
		UnitSlot5Edit.Enabled := 0
		UnitSlot6Edit.Enabled := 0
		UnitSlot7Edit.Enabled := 0
		UnitSlot8Edit.Enabled := 0
		UnitSlot9Edit.Enabled := 0
		UnitSlot0Edit.Enabled := 0
	} else if (UnitMode = "Input") {
		UnitSlot1Edit.Enabled := 1
		UnitSlot2Edit.Enabled := 1
		UnitSlot3Edit.Enabled := 1
		UnitSlot4Edit.Enabled := 1
		UnitSlot5Edit.Enabled := 1
		sd_UnitSlotDefaults()
	}
}

sd_UnitModeHelp(*) {
	MsgBox("There are three different Unit Modes you can select for the macro; Input, Detect and Preset.`nThe following MsgBox's will describe them for you.", "Unit Modes Help", 0x1020 " T60 Owner" MainGUI.Hwnd)
	MsgBox("Unavailable`n`n`nThis mode allows you to input a custom unit strategy that the macro will use to beat the selected chapters.", "Input", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Unavailable`n`n`nThis will make the macro detect your units upon joining game and use an algorithm to decide which ones to place first.", "Detect", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("In-development`n`n`nThe macro will give you units you need to equip before-hand to avoid any issues in-game.`n`nUsually, these presets are noob-friendly", "Preset", 0x1020 " Owner" MainGUI.Hwnd)
}

sd_DankMemerAutoGrinderGUI(*) {
	global
	GUIClose(*) {
		if (IsSet(DankMemerAutoGrinderGUI) && (IsObject(DankMemerAutoGrinderGUI))) {
			sd_LockTabs(0)
			DankMemerAutoGrinderGUI.Destroy(), DankMemerAutoGrinderGUI := ""
        }
	}
	GUIClose()
	DankMemerAutoGrinderGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Dank Memer Auto-Grinder")
    sd_LockTabs()
	DankMemerAutoGrinderGUI.OnEvent("Close", GUIClose)
	DankMemerAutoGrinderGUI.SetFont("s8 cDefault Bold", "Tahoma")
	DankMemerAutoGrinderGUI.AddGroupBox("x5 y2 w290 h96", "Settings")
	DankMemerAutoGrinderGUI.SetFont("Norm")
	DankMemerAutoGrinderGUI.AddText("x20 y30", "My job as ")
	DankMemerJobsArr := ["Discord Mod", "Babysitter", "Fast Food Cook", "House Wife"
	 , "Twitch Streamer", "YouTuber", "Professional Hunter", "Professional Fisherman"
	 , "Grave Digger", "Bartender", "Robber", "Police Officer"
	 , "Teacher", "Musician", "Pro Gamer", "Manager"
	 , "Developer", "Day Trader", "Santa Claus", "Politician"
	 , "Veterinarian", "Pharmacist", "Dank Memer Shopkeeper", "Lawyer"
	 , "Doctor", "Scientist", "Ghost", "Adventurer"]
	(DankMemerJobEdit := DankMemerAutoGrinderGUI.AddDropDownList("x75 y27 vDankMemerJobEdit", ["Unemployed"])).Add(DankMemerJobsArr), DankMemerJobEdit.Text := DankMemerJob, DankMemerJobEdit.OnEvent("Change", sd_DankMemerJob)
	DankMemerAutoGrinderGUI.AddText("x195 y30", "  has a cooldown of")
	(DisplayedDankMemerJobCooldownEdit := DankMemerAutoGrinderGUI.AddText("x30 y60 vDisplayedDankMemerJobCooldown", (DankMemerJobCooldown//60000) " minutes."))
	DankMemerAutoGrinderGUI.AddButton("x150 y60", "Start Grind").OnEvent("Click", sd_StartDankMemerAutoGrinder)
	DankMemerAutoGrinderGUI.Show("w300 h100")
	sd_DankMemerJob(*) {
		IniWrite((DankMemerJob := DankMemerJobEdit.Text), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJob")
		if DankMemerJob = "Unemployed" {
			IniWrite((DankMemerJobCooldown := (0 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		} else if (DankMemerJob = "Discord Mod" || DankMemerJob = "Babysitter") {
			IniWrite((DankMemerJobCooldown := (40 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		} else if (DankMemerJob = "Fast Food Cook" || DankMemerJob = "House Wife") {
			IniWrite((DankMemerJobCooldown := (43 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		} else if (DankMemerJob = "Twitch Streamer" || DankMemerJob = "YouTuber") {
			IniWrite((DankMemerJobCooldown := (46 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		} else if (DankMemerJob = "Professional Hunter" || DankMemerJob = "Professional Fisherman" || DankMemerJob = "Grave Digger" || DankMemerJob = "Bartender" || DankMemerJob = "Robber" || DankMemerJob = "Police Officer" || DankMemerJob = "Teacher" || DankMemerJob = "Musician") {
			IniWrite((DankMemerJobCooldown := (49 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		} else if (DankMemerJob = "Pro Gamer" || DankMemerJob = "Manager" || DankMemerJob = "Developer") {
			IniWrite((DankMemerJobCooldown := (52 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		} else if (DankMemerJob = "Day Trader" || DankMemerJob = "Santa Claus" || DankMemerJob = "Politician" || DankMemerJob = "Veterinarian" || DankMemerJob = "Pharmacist" || DankMemerJob = "Dank Memer Shopkeeper") {
			IniWrite((DankMemerJobCooldown := (55 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		} else if (DankMemerJob = "Lawyer" || DankMemerJob = "Doctor" || DankMemerJob = "Scientist" || DankMemerJob = "Ghost" || DankMemerJob = "Adventurer") {
			IniWrite((DankMemerJobCooldown := (58 * 60000)), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
		}
		DisplayedDankMemerJobCooldownEdit.Text := (DankMemerJobCooldown//60000) " minutes.", DisplayedDankMemerJobCooldownEdit.Redraw()
	}
	sd_StartDankMemerAutoGrinder(*) {
		Run("https://discord.com/channels/1145457576432128011/1315005994211872888")
		sd_DankMemerAutoGrinder()
	}
}

sd_QuickstartButton(*) {
	sd_LockTabs()
	MainGUI.Minimize()
	sd_Quickstart()
}


SetLoadProgress(Round(83.3333333333333343, 1), MainGUI, MacroName " (" LanguageText[77] " ")
