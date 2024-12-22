; main GUI
VersionTextEdit := MainGUI.AddText("x482 y282 vVersionText", "v" VersionID), VersionTextEdit.Move(494 - (VersionWidth := TextExtent("v" VersionID, VersionTextEdit)))
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["WarningIcon"])
MainGUI.AddPicture("+BackgroundTrans x" 345 - VersionWidth - 5 " y280 w14 h14 Hidden vUpdateButton", "HBITMAP:*" hBM).OnEvent("Click", sd_AutoUpdateGUI)
DllCall("DeleteObject", "Ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"])
MainGUI.AddPicture("+BackgroundTrans x" 470 - VersionWidth - 3 " y271 w25 h23 vGitHubButton", "HBITMAP:*" hBM).OnEvent("Click", OpenGitHub)
DllCall("DeleteObject", "Ptr", hBM)
pBM := Gdip_BitmapConvertGray(bitmaps["DiscordIcon"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
MainGUI.AddPicture("+BackgroundTrans x" 440 - VersionWidth - 2 " y271 w25 h24 vDiscordButton", "HBITMAP:*" hBM).OnEvent("Click", DiscordServer)
Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)
MainGUI.SetFont("s8 w700 c0046ee")
MainGUI.AddText("x" 365 - VersionWidth - 5 " y271 +Center vDiscordText", "Made by`nNegativeZero").OnEvent("Click", DiscordProfile) ; increasing the left value moves it right, increasing the right value moves it left
MainGUI.SetFont("s8 cDefault Norm")
MainGUI.AddButton("x10 y275 w65 h20 -Wrap vStartButton Disabled", " Start (" StartHotkey ")").OnEvent("Click", StartButton)
MainGUI.AddButton("x80 y275 w65 h20 -Wrap vPauseButton Disabled", " Pause (" PauseHotkey ")").OnEvent("Click", PauseButton)
MainGUI.AddButton("x150 y275 w65 h20 -Wrap vStopButton Disabled", " Stop (" StopHotkey ")").OnEvent("Click", StopButton)
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
DefaultTabs := ["Game", "Units", "Status", "Settings", "Miscellaneous", "Credits"]
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



; GAME TAB
; ------------------------
;TabCtrl.UseTab("Game") ; not needed since TabCtrl creation defaults to using first tab, but specified for readability
MainGUI.SetFont("w700 Underline")
MainGUI.AddText("x0 y25 w126 +Center +BackgroundTrans", "Chapter")
MainGUI.AddText("x126 y25 w205 +Center +BackgroundTrans", "Strategy")
MainGUI.AddText("x331 y25 w83 +Center +BackgroundTrans", "Time")
MainGUI.AddText("x414 y25 w86 +Center +BackgroundTrans", "Units")
MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
MainGUI.AddText("x2 y39 w124 +Center +BackgroundTrans", "Chapter Rotation")
MainGUI.AddText("x126 y25 w1 h206 0x7") ; 0x7 = SS_BLACKFRAME - faster drawing of lines since no text rendered
MainGUI.AddText("x122 y39 w112 +Center +BackgroundTrans", "Strat")
MainGUI.AddText("x263 y39 w200 +BackgroundTrans", "Grind Mode")
MainGUI.AddText("x331 y25 w1 h206 0x7")
MainGUI.AddText("x363 y39 w100 +BackgroundTrans", "Mins")
MainGUI.AddText("x412 y25 w1 h206 0x7")
MainGUI.AddText("x424 y39 w100 +BackgroundTrans", "Unit Selection")
MainGUI.AddText("x5 y53 w492 h2 0x7")
MainGUI.AddText("xp y115 wp h1 0x7")
MainGUI.AddText("xp yp+60 wp h1 0x7")
MainGUI.AddText("xp yp+60 wp h1 0x7")
MainGUI.SetFont("w700")
MainGUI.AddText("x4 y61 w10 +BackgroundTrans", "1:")
MainGUI.AddText("xp yp+60 wp +BackgroundTrans", "2:")
MainGUI.AddText("xp yp+60 wp +BackgroundTrans", "3:")
MainGUI.SetFont("s8 cDefault Norm", "Tahoma")

(ChapterName1Edit := MainGUI.AddDropDownList("x18 y57 w106 Disabled vChapterName1Edit", ChapterNamesList)).Text := ChapterName1, ChapterName1Edit.OnEvent("Change", sd_ChapterSelect1)
(ChapterName2Edit := MainGUI.AddDropDownList("xp yp+60 wp Disabled vChapterName2Edit", ["None"])).Add(ChapterNamesList), ChapterName2Edit.Text := ChapterName2, ChapterName2Edit.OnEvent("Change", sd_ChapterSelect2)
(ChapterName3Edit := MainGUI.AddDropDownList("xp yp+60 wp Disabled vChapterName3Edit", ["None"])).Add(ChapterNamesList), ChapterName3Edit.Text := ChapterName3, ChapterName3Edit.OnEvent("Change", sd_ChapterSelect3)

hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["SaveCharDisabled"])
MainGUI.AddPicture("x2 y86 w18 h18 Disabled vSaveCharDefault1", "HBITMAP:*" hBM).OnEvent("Click", sd_SaveCharDefault)
MainGUI.AddPicture("xp yp+60 wp hp Disabled vSaveCharDefault2", "HBITMAP:*" hBM).OnEvent("Click", sd_SaveCharDefault)
MainGUI.AddPicture("xp yp+60 wp hp Disabled vSaveCharDefault3", "HBITMAP:*" hBM).OnEvent("Click", sd_SaveCharDefault)
DllCall("DeleteObject", "ptr", hBM)

MainGUI.AddButton("x27 y82 h14 w40 Disabled vCopyGame1", "Copy").OnEvent("Click", sd_CopyGameSettings)
MainGUI.AddButton("xp yp+15 hp wp Disabled vPasteGame1", "Paste").OnEvent("Click", sd_PasteGameSettings)
MainGUI.AddButton("xp yp+45 hp wp Disabled vCopyGame2", "Copy").OnEvent("Click", sd_CopyGameSettings)
MainGUI.AddButton("xp yp+15 hp wp Disabled vPasteGame2", "Paste").OnEvent("Click", sd_PasteGameSettings)
MainGUI.AddButton("xp yp+45 hp wp Disabled vCopyGame3", "Copy").OnEvent("Click", sd_CopyGameSettings)
MainGUI.AddButton("xp yp+15 hp wp Disabled vPasteGame3", "Paste").OnEvent("Click", sd_PasteGameSettings)

(ChapterStrat1Edit := MainGUI.AddDropDownList("x129 y57 w112 Disabled vChapterStrat1", stratslist)).Text := ChapterStrat1
ChapterStrat1Edit.Section := "Game", ChapterStrat1Edit.OnEvent("Change", sd_UpdateConfigShortcut)
(ChapterStrat2Edit := MainGUI.AddDropDownList("xp yp+60 wp Disabled vChapterStrat2", stratslist)).Text := ChapterStrat2
ChapterStrat2Edit.Section := "Game", ChapterStrat2Edit.OnEvent("Change", sd_UpdateConfigShortcut)
(ChapterStrat3Edit := MainGUI.AddDropDownList("xp yp+60 wp Disabled vChapterStrat3", stratslist)).Text := ChapterStrat3
ChapterStrat3Edit.Section := "Game", ChapterStrat3Edit.OnEvent("Change", sd_UpdateConfigShortcut)

GrindModesArr := ["Loss Farm", "Games Played", "CC Farm", "XP Farm", "Win Farm"]
(ChapterGrindMode1Edit := MainGUI.AddDropDownList("x244 y57 w85 Disabled vChapterGrindMode1", GrindModesArr)).Text := ChapterGrindMode1
ChapterGrindMode1Edit.Section := "Game", ChapterGrindMode1Edit.OnEvent("Change", sd_UpdateConfigShortcut)
(ChapterGrindMode2Edit := MainGUI.AddDropDownList("xp yp+60 wp Disabled vChapterGrindMode2", GrindModesArr)).Text := ChapterGrindMode2
ChapterGrindMode2Edit.Section := "Game", ChapterGrindMode2Edit.OnEvent("Change", sd_UpdateConfigShortcut)
(ChapterGrindMode3Edit := MainGUI.AddDropDownList("xp yp+60 wp Disabled vChapterGrindMode3", GrindModesArr)).Text := ChapterGrindMode3
ChapterGrindMode3Edit.Section := "Game", ChapterGrindMode3Edit.OnEvent("Change", sd_UpdateConfigShortcut)

MainGUI.AddText("x132 y92", "Invert:")
MainGUI.AddText("xp yp+60", "Invert:")
MainGUI.AddText("xp yp+60", "Invert:")
(ChapterStratInvertFB1Edit := MainGUI.AddCheckBox("x171 y92 Disabled vChapterStratInvertFB1 Checked" ChapterStratInvertFB1, "F/B")).Section := "Game", ChapterStratInvertFB1Edit.OnEvent("Click", sd_UpdateConfigShortcut)
(ChapterStratInvertFB2Edit := MainGUI.AddCheckBox("xp yp+60 Disabled vChapterStratInvertFB2 Checked" ChapterStratInvertFB2, "F/B")).Section := "Game", ChapterStratInvertFB2Edit.OnEvent("Click", sd_UpdateConfigShortcut)
(ChapterStratInvertFB3Edit := MainGUI.AddCheckBox("xp yp+60 Disabled vChapterStratInvertFB3 Checked" ChapterStratInvertFB3, "F/B")).Section := "Game", ChapterStratInvertFB3Edit.OnEvent("Click", sd_UpdateConfigShortcut)
(ChapterStratInvertLR1Edit := MainGUI.AddCheckBox("x211 y92 Disabled vChapterStratInvertLR1 Checked" ChapterStratInvertLR1, "L/R")).Section := "Game", ChapterStratInvertLR1Edit.OnEvent("Click", sd_UpdateConfigShortcut)
(ChapterStratInvertLR2Edit := MainGUI.AddCheckBox("xp yp+60 Disabled vChapterStratInvertLR2 Checked" ChapterStratInvertLR2, "L/R")).Section := "Game", ChapterStratInvertLR2Edit.OnEvent("Click", sd_UpdateConfigShortcut)
(ChapterStratInvertLR3Edit := MainGUI.AddCheckBox("xp yp+60 Disabled vChapterStratInvertLR3 Checked" ChapterStratInvertLR3, "L/R")).Section := "Game", ChapterStratInvertLR3Edit.OnEvent("Click", sd_UpdateConfigShortcut)

MainGUI.AddText("x260 y81 h10", "Max Speed:")
MainGUI.AddText("xp yp+60 hp", "Max Speed:")
MainGUI.AddText("xp yp+60 hp", "Max Speed:")
(ChapterMaxSpeed1Edit := MainGUI.AddEdit("x" (SpeedEvent ? "250" : "270") " y96 w40 h18 vChapterMaxSpeed1 Number Limit1" (SpeedEvent ? " Disabled" : ""), ChapterMaxSpeed1)).OnEvent("Change", (*) => sd_MaxSpeed(ChapterMaxSpeed1Edit, 1))
MainGUI.AddUpDown("vChapterMaxSpeed1Edit Range1-5 Disabled", ChapterMaxSpeed1).OnEvent("Change", (*) => sd_MaxSpeed(ChapterMaxSpeed1Edit, 1))
(ChapterMaxSpeed2Edit := MainGUI.AddEdit("x" (SpeedEvent ? "250" : "270") " yp+60 w40 h18 vChapterMaxSpeed2 Number Limit1" (SpeedEvent ? " Disabled" : ""), ChapterMaxSpeed2)).OnEvent("Change", (*) => sd_MaxSpeed(ChapterMaxSpeed2Edit, 2))
MainGUI.AddUpDown("vChapterMaxSpeed2Edit Range1-5 Disabled", ChapterMaxSpeed2).OnEvent("Change", (*) => sd_MaxSpeed(ChapterMaxSpeed2Edit, 2))
(ChapterMaxSpeed3Edit := MainGUI.AddEdit("x" (SpeedEvent ? "250" : "270") " yp+60 w40 h18 vChapterMaxSpeed3 Number Limit1" (SpeedEvent ? " Disabled" : ""), ChapterMaxSpeed3)).OnEvent("Change", (*) => sd_MaxSpeed(ChapterMaxSpeed3Edit, 3))
MainGUI.AddUpDown("vChapterMaxSpeed3Edit Range1-5 Disabled", ChapterMaxSpeed3).OnEvent("Change", (*) => sd_MaxSpeed(ChapterMaxSpeed3Edit, 3))
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["Speedevent"])
MainGUI.AddPicture("+BackgroundTrans x290 y93 w23 h24 vSpeedEventNotice2" (!SpeedEvent ? " Hidden" : ""), "HBITMAP:*" hBM).OnEvent("Click", sd_SpeedEventNotice)
MainGUI.AddPicture("+BackgroundTrans x290 yp+60 w23 h24 vSpeedEventNotice1" (!SpeedEvent ? " Hidden" : ""), "HBITMAP:*" hBM).OnEvent("Click", sd_SpeedEventNotice)
MainGUI.AddPicture("+BackgroundTrans x290 yp+60 w23 h24 vSpeedEventNotice3" (!SpeedEvent ? " Hidden" : ""), "HBITMAP:*" hBM).OnEvent("Click", sd_SpeedEventNotice)
DllCall("DeleteObject", "Ptr", hBM)

MainGUI.AddText("x301 y95 w28 h16 0x201 +Center")
MainGUI.AddText("xp yp+60 wp h16 0x201 +Center")
MainGUI.AddText("xp yp+60 wp h16 0x201 +Center")
MainGUI.AddText("x440 y95 w32 h16 0x201 +Center")
MainGUI.AddText("xp yp+60 wp h16 0x201 +Center")
MainGUI.AddText("xp yp+60 wp h16 0x201 +Center")

(ChapterMaxTime1Edit := MainGUI.AddEdit("x354 y58 w36 h20 Limit4 Number vChapterMaxTime1 Disabled", ValidateInt(&ChapterMaxTime1, 15))).Section := "Game", ChapterMaxTime1Edit.OnEvent("Change", sd_UpdateConfigShortcut)
(ChapterMaxTime2Edit := MainGUI.AddEdit("xp yp+60 wp h20 Limit4 Number vChapterMaxTime2 Disabled", ValidateInt(&ChapterMaxTime2, 15))).Section := "Game", ChapterMaxTime2Edit.OnEvent("Change", sd_UpdateConfigShortcut)
(ChapterMaxTime3Edit := MainGUI.AddEdit("xp yp+60 wp h20 Limit4 Number vChapterMaxTime3 Disabled", ValidateInt(&ChapterMaxTime3, 15))).Section := "Game", ChapterMaxTime3Edit.OnEvent("Change", sd_UpdateConfigShortcut)

MainGUI.AddText("x327 y80 w93 +BackgroundTrans +Center", "To Lobby by:")
MainGUI.AddText("xp yp+60 wp +BackgroundTrans +Center", "To Lobby by:")
MainGUI.AddText("xp yp+60 wp +BackgroundTrans +Center", "To Lobby by:")
MainGUI.AddText("x356 y96 w33 +Center +BackgroundTrans vChapterReturnType1", ChapterReturnType1)
MainGUI.AddButton("xp-16 yp-1 w12 h16 vCRT1Left Disabled", "<").OnEvent("Click", sd_ChapterReturnType)
MainGUI.AddButton("xp+52 yp w12 h16 Disabled vCRT1Right", ">").OnEvent("Click", sd_ChapterReturnType)
MainGUI.AddText("x356 yp+61 w33 +Center +BackgroundTrans vChapterReturnType2", ChapterReturnType2)
MainGUI.AddButton("xp-16 yp-1 w12 h16 Disabled vCRT2Left", "<").OnEvent("Click", sd_ChapterReturnType)
MainGUI.AddButton("xp+52 yp w12 h16 Disabled vCRT2Right", ">").OnEvent("Click", sd_ChapterReturnType)
MainGUI.AddText("x356 yp+61 w33 +Center +BackgroundTrans vChapterReturnType3", ChapterReturnType3)
MainGUI.AddButton("xp-16 yp-1 w12 h16 Disabled vCRT3Left", "<").OnEvent("Click", sd_ChapterReturnType)
MainGUI.AddButton("xp+52 yp w12 h16 Disabled vCRT3Right", ">").OnEvent("Click", sd_ChapterReturnType)

MainGUI.AddButton("x421 y60 w70 h50 vChangeUnits1 Disabled", "Change`nLoadout").OnEvent("Click", sd_ChangeUnits1GUI)
MainGUI.AddButton("xp yp+60 wp hp vChangeUnits2 Disabled", "Change`nLoadout").OnEvent("Click", sd_ChangeUnits2GUI)
MainGUI.AddButton("xp yp+60 wp hp vChangeUnits3 Disabled", "Change`nLoadout").OnEvent("Click", sd_ChangeUnits3GUI)



TabCtrl.UseTab("Units")
; gpbxs

MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
MainGUI.AddButton("x400 y187 w20 h20 vUnitsHelp Disabled", "?").OnEvent("Click", sd_UnitDefinitions)
MainGUI.AddButton("x205 y220 vResetGameConfig", "Reset Configs").OnEvent("Click", sd_ResetGameConfigButton)
MainGUI.AddButton("x305 y220 vQuickStartButton", "Quickstart").OnEvent("Click", sd_QuickstartButton)


TabCtrl.UseTab("Status")
MainGUI.SetFont("w700")
MainGUI.AddGroupBox("x5 y23 w240 h210", "Status Log")
MainGUI.AddGroupBox("x250 y23 w245 h160", "Statistics")
MainGUI.AddGroupBox("x250 y185 w245 h48", "Discord Integration")

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
MainGUI.AddGroupBox("x10 y25 w200 h100 +BackgroundTrans", "GUI Settings")
MainGUI.AddGroupBox("x10 y130 w200 h100 +BackgroundTrans", "Hotkey Settings")
MainGUI.AddGroupBox("x220 y25 w270 h70 +BackgroundTrans", "General Settings")
MainGUI.AddGroupBox("x220 y100 w270 h130 +BackgroundTrans", "Reconnect Settings")

MainGUI.SetFont("Norm")
MainGUI.AddText("x15 y80 +BackgroundTrans", "GUI Theme:")
ThemesList := []
Loop Files A_ThemesWorkingDir "*.msstyles" {
	ThemesList.Push(StrReplace(A_LoopFileName, ".msstyles"))
}
(ThemesEdit := MainGUI.AddDropDownList("x75 y76 w72 h100 vGUITheme Disabled", ThemesList)).Text := GUITheme, ThemesEdit.OnEvent("Change", sd_GUITheme)
MainGUI.AddCheckBox("x15 y40 vAlwaysOnTop Disabled Checked" AlwaysOnTop, "Always On Top").OnEvent("Click", sd_AlwaysOnTop)
MainGUI.AddText("x15 y57 +BackgroundTrans", "GUI Transparency:")
MainGUI.AddText("xp+103 y57 +Center +BackgroundTrans vGUITransparency", GUITransparency)
MainGUI.AddUpDown("xp+21 yp-1 h16 -16 Range0-14 vGUITransparencyUpDown Disabled", GUITransparency//5).OnEvent("Change", sd_GUITransparency)
MainGUI.AddButton("x14 y100 w150 h20 vAdvancedOptions Disabled", "Advanced Options").OnEvent("Click", sd_AdvancedOptionsGUI)
MainGUI.AddButton("x15 y155 w150 h20 vHotkeyGUI Disabled", "Change Hotkeys").OnEvent("Click", sd_HotkeyGUI)
MainGUI.AddButton("x16 yp+24 w150 h20 vAutoClickerGUI Disabled", "AutoClicker Settings").OnEvent("Click", sd_AutoClickerGUI)
MainGUI.AddButton("x20 yp+24 w140 h20 vHotkeyRestore Disabled", "Restore Defaults").OnEvent("Click", sd_ResetHotkeysButton)
MainGUI.AddText("x230 y41 +BackgroundTrans", "Input Delay (ms):")
MainGUI.AddText("x317 y39 w47 h18 0x201")
MainGUI.AddUpDown("xp+10 Range0-9999 vKeyDelay Disabled", KeyDelay).OnEvent("Change", sd_SaveKeyDelay)
MainGUI.AddButton("x227 yp+27 w120 h20 vSettingsRestore Disabled", "Reset Settings").OnEvent("Click", sd_ResetSettingsButton)
MainGUI.AddButton("x400 y97 w30 h20 vReconnectTest Disabled", "Test").OnEvent("Click", sd_ReconnectTest)
MainGUI.AddText("x230 y125 +BackgroundTrans", "Private Server Link:")
MainGUI.AddEdit("x230 y150 w250 h20 vPrivServer Lowercase Disabled", PrivServer).OnEvent("Change", sd_ServerLink)
MainGUI.AddText("x235 yp+37 +BackgroundTrans", "Reconnect Method:")
MainGUI.AddText("xp+110 yp w48 vReconnectMethod +Center +BackgroundTrans", ReconnectMethod)
MainGUI.AddButton("xp-12 yp-1 w12 h15 vRMLeft Disabled", "<").OnEvent("Click", sd_ReconnectMethod)
MainGUI.AddButton("xp+59 yp w12 h15 vRMRight Disabled", ">").OnEvent("Click", sd_ReconnectMethod)
MainGUI.AddButton("xp+25 yp-3 w20 h20 vReconnectMethodHelp Disabled", "?").OnEvent("Click", sd_ReconnectMethodHelp)
(FallbackEdit := MainGUI.AddCheckBox("x230 y210 w132 h15 vPublicFallback Disabled Checked" PublicFallback, "Fallback to Public Server")).Section := "Settings", FallbackEdit.OnEvent("Click", sd_UpdateConfigShortcut)
MainGUI.AddButton("x380 y207 w20 h20 vPublicFallbackHelp Disabled", "?").OnEvent("Click", sd_PublicFallbackHelp)
LangArr := ["English"]
MainGUI.AddText("x390 y42 +BackgroundTrans", "Language:")
(LanguageEdit := MainGUI.AddDropDownList("x360 y65 vLanguageEdit Disabled", LangArr)).Text := Language, LanguageEdit.OnEvent("Change", sd_Language)


TabCtrl.UseTab("Miscellaneous")
MainGUI.SetFont("s8 cDefault Bold", "Tahoma")
MainGUI.AddGroupBox("x5 y23 w180 h130", "GitHub")
MainGUI.AddGroupBox("x5 y155 w180 h75", "Skibi Defense Server")
MainGUI.AddGroupBox("x200 y23 w155 h80", "Other Cool Stuff")

MainGUI.SetFont("Norm")
; reporting
MainGUI.AddButton("x15 y40 w150 h20 vReportBugs Disabled", "Report a Bug").OnEvent("Click", sd_ReportBugButton)
MainGUI.AddButton("x15 y65 w150 h20 vMakeSuggestions Disabled", "Make a Suggestion").OnEvent("Click", sd_MakeSuggestionButton)
MainGUI.AddButton("x15 y90 w150 h32 vReportSecurityBreaches Disabled", "Report a Security Vulnerability").OnEvent("Click", sd_ReportSecurityVulnerabilitiesButton)
MainGUI.AddButton("x15 y125 w150 h20 vAskQuestions Disabled", "Ask a Question").OnEvent("Click", sd_MacroQuestionsButton)
; sd server
MainGUI.AddButton("x15 y175 h30 vDankMemerAutoGrinder Disabled", "Dank Memer AutoGrinder").OnEvent("Click", sd_DMAGPriorWarning)
MainGUI.AddButton("x155 y179 w20 h20 vDMAGDefinition Disabled", "?").OnEvent("Click", sd_DMAGDefinition)
MainGUI.AddText("x20 y210 vDoesItWork Disabled", '"Does it work" counter: 118').OnEvent("Click", sd_CommunityCreationsPost)
; other
MainGUI.AddButton("x210 y40 vRandomStringGenerator Disabled", "Random String Generator").OnEvent("Click", sd_RandomStringGenerator)
MainGUI.AddButton("x210 y70 vRegistryDumper Disabled", "Registry Dumper").OnEvent("Click", sd_RegistryDumperGUI)
MainGUI.AddButton("x312 y72 w20 h20 vRegDumpHelp Disabled", "?").OnEvent("Click", sd_RegDumpHelp)


TabCtrl.UseTab("Credits")
/*MainGUI.SetFont("Bold Norm c000000 s15")
MainGUI.AddText("x10 y30", "Art:")
MainGUI.SetFont("Underline Norm c0000FF s8")
MainGUI.AddText("xp yp+30 vDiscordIconArtist", "    -   @ender4byss on Discord - Icons").OnEvent("Click", DiscordIconArtist)
MainGUI.SetFont("Bold Norm c000000 s15")
MainGUI.AddText("x10 y100", "Translations:")
MainGUI.SetFont("Underline Norm c0000FF s8")
MainGUI.AddText("x10 yp+30 vTurkishDiscordTranslator", "    -   @ekmekdover12 on Discord - Current Turkish Translation").OnEvent("Click", TurkishDiscordTranslator)
MainGUI.AddText("x10 yp+20 vSpanishDiscordTranslator", "    -   @taneoron on Discord - Previous Spanish Translation").OnEvent("Click", SpanishDiscordTranslator)
MainGUI.AddText("x10 yp+20 vPortugueseDiscordTranslator", "    -   @the.hex.guy on Discord - Previous Portuguese Translation").OnEvent("Click", PortugueseDiscordTranslator)*/
MainGUI.AddPicture("+BackgroundTrans vContributorsDevImage x5 y24 AltSubmit")
MainGUI.AddPicture("+BackgroundTrans vContributorsImage x253 y24 AltSubmit")

MainGUI.SetFont("w700")
MainGUI.AddText("x15 y28 w225 +Wrap +BackgroundTrans cWhite", "Development")
MainGUI.AddText("x261 y28 w225 +Wrap +BackgroundTrans cWhite", "Supporters")

MainGUI.SetFont("s8 cDefault Norm", "Tahoma")
MainGUI.AddText("x18 y43 w225 +Wrap +BackgroundTrans cWhite", "Special thanks to those who tested the macro,`nClick the names to view their Discord profiles!")
MainGUI.AddText("x264 y43 w180 +Wrap +BackgroundTrans cWhite", "Thank you for your contributions to this project!")

MainGUI.AddButton("x440 y46 w18 h18 vContributorsLeft Disabled", "<").OnEvent("Click", sd_ContributorsPageButton)
MainGUI.AddButton("x464 y46 w18 h18 vContributorsRight Disabled", ">").OnEvent("Click", sd_ContributorsPageButton)


try {
	AsyncHTTPRequest("GET", "https://raw.githubusercontent.com/NZMacros/GitHub/main/skibi_defense_macro/data/contributors.txt", sd_ContributorsHandler, Map("accept", "application/vnd.github.v3.raw"))
}

#Include "%A_ScriptDir%\..\lib\Plugins\"
; #Include "*i .ahk"



/**
 * @description Sets the current loading progress of the GUI
 * @param percent The percentage to set it to
 * @param Title1 The title to set it to (with the percentage)
 * @param Title2 The title to set it to if the percentage is at 100
*/
SetLoadProgress(percent, Title1, Title2 := Title1) {
	percent := Round(percent, 1)
    if percent < 100 {
        MainGUI.Opt("+Disabled")
        MainGUI.Title := Title1 percent "%)"
    } else if (percent = 100.0) {
        MainGUI.Title := Title2
		sd_LockTabs(0), MainGUI.Opt("-Disabled")
		MainGUI.Flash()
		MainGUI.Restore()
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
	WinSetTransparent(255 - Floor(GUITransparency * 2.55), MainGUI)
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
		MainGUI["CurrentChapterDown"].Enabled := 0

		pBM := Gdip_BitmapConvertGray(bitmaps["DiscordIcon"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
		MainGUI["DiscordButton"].Value := "HBITMAP:*" hBM, MainGUI["DiscordButton"].OnEvent("Click", DiscordServer, 0)
		Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)

		MainGUI["GitHubButton"].OnEvent("Click", OpenGitHub, 0)
		MainGUI["DiscordText"].OnEvent("Click", DiscordProfile, 0)

		c := "Lock"
	} else {
		MainGUI["CurrentChapterUp"].Enabled := 1
		MainGUI["CurrentChapterDown"].Enabled := 1

		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["DiscordIcon"])
		MainGUI["DiscordButton"].Value := "HBITMAP:*" hBM, MainGUI["DiscordButton"].OnEvent("Click", DiscordServer)
		DllCall("DeleteObject", "Ptr", hBM)

		MainGUI["GitHubButton"].OnEvent("Click", OpenGitHub)
		MainGUI["DiscordText"].OnEvent("Click", DiscordProfile)

		c := "Unlock"
	}

	for i, tab in tabs {
		sd_%tab%Tab%c%()
	}

}

sd_GameTabLock() {
	global
	local hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["SaveCharDisabled"])
	ChapterName1Edit.Enabled := 0
	MainGUI["SaveCharDefault1"].Enabled := 0
	MainGUI["SaveCharDefault1"].Value := "HBITMAP:*" hBM
	MainGUI["CopyGame1"].Enabled := 0
	MainGUI["PasteGame1"].Enabled := 0
	ChapterStrat1Edit.Enabled := 0
	ChapterGrindMode1Edit.Enabled := 0
	ChapterStratInvertFB1Edit.Enabled := 0
	ChapterStratInvertLR1Edit.Enabled := 0
	ChapterMaxSpeed1Edit.Enabled := 0
	MainGUI["ChapterMaxSpeed1Edit"].Enabled := 0
	ChapterMaxTime1Edit.Enabled := 0
	MainGUI["CRT1Left"].Enabled := 0
	MainGUI["CRT1Right"].Enabled := 0
	MainGUI["ChangeUnits1"].Enabled := 0
	ChapterName2Edit.Enabled := 0
	MainGUI["SaveCharDefault2"].Enabled := 0
	MainGUI["SaveCharDefault2"].Value := "HBITMAP:*" hBM
	MainGUI["CopyGame2"].Enabled := 0
	MainGUI["PasteGame2"].Enabled := 0
	ChapterStrat2Edit.Enabled := 0
	ChapterGrindMode2Edit.Enabled := 0
	ChapterStratInvertFB2Edit.Enabled := 0
	ChapterStratInvertLR2Edit.Enabled := 0
	ChapterMaxSpeed2Edit.Enabled := 0
	MainGUI["ChapterMaxSpeed2Edit"].Enabled := 0
	ChapterMaxTime2Edit.Enabled := 0
	MainGUI["CRT2Left"].Enabled := 0
	MainGUI["CRT2Right"].Enabled := 0
	MainGUI["ChangeUnits2"].Enabled := 0
	ChapterName3Edit.Enabled := 0
	MainGUI["SaveCharDefault3"].Enabled := 0
	MainGUI["SaveCharDefault3"].Value := "HBITMAP:*" hBM
	MainGUI["CopyGame3"].Enabled := 0
	MainGUI["PasteGame3"].Enabled := 0
	ChapterStrat3Edit.Enabled := 0
	ChapterGrindMode3Edit.Enabled := 0
	ChapterStratInvertFB3Edit.Enabled := 0
	ChapterStratInvertLR3Edit.Enabled := 0
	ChapterMaxSpeed3Edit.Enabled := 0
	MainGUI["ChapterMaxSpeed3Edit"].Enabled := 0
	ChapterMaxTime3Edit.Enabled := 0
	MainGUI["CRT3Left"].Enabled := 0
	MainGUI["CRT3Right"].Enabled := 0
	MainGUI["ChangeUnits3"].Enabled := 0
}

sd_GameTabUnlock() {
	local hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["SaveChapter"])
	ChapterName1Edit.Enabled := 1
	MainGUI["SaveCharDefault1"].Enabled := 1
	MainGUI["SaveCharDefault1"].Value := "HBITMAP:*" hBM
	MainGUI["CopyGame1"].Enabled := 1
	MainGUI["PasteGame1"].Enabled := 1
	ChapterStrat1Edit.Enabled := 1
	ChapterGrindMode1Edit.Enabled := 1
	ChapterStratInvertFB1Edit.Enabled := 1
	ChapterStratInvertLR1Edit.Enabled := 1
	ChapterMaxSpeed1Edit.Enabled := (!SpeedEvent ? 1 : 0)
	MainGUI["ChapterMaxSpeed1Edit"].Enabled := (!SpeedEvent ? 1 : 0)
	ChapterMaxTime1Edit.Enabled := 1
	MainGUI["CRT1Left"].Enabled := 1
	MainGUI["CRT1Right"].Enabled := 1
	MainGUI["ChangeUnits1"].Enabled := 1
	ChapterName2Edit.Enabled := 1
	MainGUI["PasteGame2"].Enabled := 1
	if ChapterName2 != "None" {
		MainGUI["SaveCharDefault2"].Enabled := 1
		MainGUI["SaveCharDefault2"].Value := "HBITMAP:*" hBM
		MainGUI["CopyGame2"].Enabled := 1
		ChapterStrat2Edit.Enabled := 1
		ChapterGrindMode2Edit.Enabled := 1
		ChapterStratInvertFB2Edit.Enabled := 1
		ChapterStratInvertLR2Edit.Enabled := 1
		ChapterMaxSpeed2Edit.Enabled := (!SpeedEvent ? 1 : 0)
		MainGUI["ChapterMaxSpeed2Edit"].Enabled := (!SpeedEvent ? 1 : 0)
		ChapterMaxTime2Edit.Enabled := 1
		MainGUI["CRT2Left"].Enabled := 1
		MainGUI["CRT2Right"].Enabled := 1
		MainGUI["ChangeUnits2"].Enabled := 1
	}
	if ChapterName3 != "None" {
		ChapterName3Edit.Enabled := 1
		MainGUI["SaveCharDefault3"].Enabled := 1
		MainGUI["SaveCharDefault3"].Value := "HBITMAP:*" hBM
		MainGUI["CopyGame3"].Enabled := 1
		MainGUI["PasteGame3"].Enabled := 1
		ChapterStrat3Edit.Enabled := 1
		ChapterGrindMode3Edit.Enabled := 1
		ChapterStratInvertFB3Edit.Enabled := 1
		ChapterStratInvertLR3Edit.Enabled := 1
		ChapterMaxSpeed3Edit.Enabled := (!SpeedEvent ? 1 : 0)
		MainGUI["ChapterMaxSpeed3Edit"].Enabled := (!SpeedEvent ? 1 : 0)
		ChapterMaxTime3Edit.Enabled := 1
		MainGUI["CRT3Left"].Enabled := 1
		MainGUI["CRT3Right"].Enabled := 1
		MainGUI["ChangeUnits3"].Enabled := 1
	}
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
	MainGUI["AskQuestions"].Enabled := 0
	MainGUI["DankMemerAutoGrinder"].Enabled := 0
	MainGUI["DMAGDefinition"].Enabled := 0
	MainGUI["DoesItWork"].Enabled := 0
	MainGUI["RandomStringGenerator"].Enabled := 0
	MainGUI["RegistryDumper"].Enabled := 0
	MainGUI["RegDumpHelp"].Enabled := 0
}

sd_MiscellaneousTabUnlock() {
	MainGUI["ReportBugs"].Enabled := 1
	MainGUI["MakeSuggestions"].Enabled := 1
	MainGUI["ReportSecurityBreaches"].Enabled := 1
	MainGUI["AskQuestions"].Enabled := 1
	MainGUI["DankMemerAutoGrinder"].Enabled := 1
	MainGUI["DMAGDefinition"].Enabled := 1
	MainGUI["DoesItWork"].Enabled := 1
	MainGUI["RandomStringGenerator"].Enabled := 1
	MainGUI["RegistryDumper"].Enabled := 1
	MainGUI["RegDumpHelp"].Enabled := 1
}

sd_CreditsTabLock() {
	/*MainGUI["TurkishDiscordTranslator"].OnEvent("Click", TurkishDiscordTranslator, 0)
	MainGUI["SpanishDiscordTranslator"].OnEvent("Click", SpanishDiscordTranslator, 0)
	MainGUI["PortugueseDiscordTranslator"].OnEvent("Click", PortugueseDiscordTranslator, 0)
	MainGUI["DiscordIconArtist"].OnEvent("Click", DiscordIconArtist, 0)*/
	MainGUI["ContributorsLeft"].Enabled := 0
	MainGUI["ContributorsRight"].Enabled := 0
}

sd_CreditsTabUnlock() {
	/*MainGUI["TurkishDiscordTranslator"].OnEvent("Click", TurkishDiscordTranslator)
	MainGUI["SpanishDiscordTranslator"].OnEvent("Click", SpanishDiscordTranslator)
	MainGUI["PortugueseDiscordTranslator"].OnEvent("Click", PortugueseDiscordTranslator)
	MainGUI["DiscordIconArtist"].OnEvent("Click", DiscordIconArtist)*/
	MainGUI["ContributorsLeft"].Enabled := 1
	MainGUI["ContributorsRight"].Enabled := 1
}

sd_HotkeyGUI(*) {
	global
	GUIClose(*) {
		if (IsSet(HotkeyGUI) && (IsObject(HotkeyGUI))) {
			Suspend(0)
			sd_LockTabs(0)
			HotkeyGUI.Destroy(), HotkeyGUI := ""
        }
	}
	GUIClose()
    Suspend(1)
	HotkeyGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Hotkeys")
    sd_LockTabs()
	HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w275 h130", "Change Hotkeys")
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y30 +BackgroundTrans", "Start:")
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", "Pause:")
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", "Stop:")
	HotkeyGUI.AddText("x10 yp+25 +BackgroundTrans", "AutoClicker:")
	HotkeyGUI.AddHotkey("x70 y28 w200 h18 vStartHotkeyEdit", StartHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vPauseHotkeyEdit", PauseHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vStopHotkeyEdit", StopHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.AddHotkey("xp yp+25 w200 h18 vAutoClickerHotkeyEdit", AutoClickerHotkey).OnEvent("Change", sd_SaveHotkey)
	HotkeyGUI.Show("w280 h135")
}

sd_DMAGDefinition(*) {
	MsgBox("Dank Memer Auto Grinder", '"DMAG"', 0x1020 " T60")
}

sd_RegDumpHelp(*) {
	MsgBox("Registry dumper is a gimmick that I (NegativeZero) wanted to test from within the macro.`n`nRegistry dumper exports the contents of the specified path in your registry editor to the dump path, giving information on the full path, item, type and value (you may need to run it as administrator for some of these if you encounter issues).", "RegDump Help", 0x1020 " T90")
}

sd_DMAGPriorWarning(*) {
	if (MsgBox("Use this at your own risk!!!`nAs stated in the macro's license, only you are responsible for any damages or issues caused by macroing Dank Memer!`n`nClick confirm to continue to the GUI.", "DMAG Warning", 0x1031) = "OK") {
		sd_DankMemerAutoGrinderGUI()
	}
}

sd_SpeedEventNotice(*) {
	MsgBox("Following a global speed event in Skibi Defense, your max speed has been automatically updated to the global of " SpeedEvent "x.`n`nIf you do not want this to happen again, disable the checkbox above and reload (press " StopHotkey ").", "Speed Events", 0x1020 " T80 Owner" MainGUI.Hwnd)
}

sd_MaxSpeed(GUICtrl, charNum, *) {
	global
	if GUICtrl.Value = "" {
		MsgBox("Speed cannot be empty!!`n`nInstead, highlight the existing value to replace it rather than deleting the value and retyping it.", "Max Speed", 0x1030 " T60 Owner" MainGUI.Hwnd)
		ChapterMaxSpeed%charNum% := MainGUI["ChapterMaxSpeed" charNum].Text := 2
	} else if (GUICtrl.Value > 5 || GUICtrl.Value < 1) {
		MsgBox("Invalid value (" GUICtrl.Value "x)!", "Max Speed", 0x1030 " T60 Owner" MainGUI.Hwnd)
		ChapterMaxSpeed%charNum% := MainGUI["ChapterMaxSpeed" charNum].Text := 2
	} else {
		IniWrite((ChapterMaxSpeed%charNum% := GUICtrl.Value), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterMaxSpeed" charNum)
	}
}

sd_DetectSpeedEvents(*) {
	global
	IniWrite((DetectSpeedEvents := AdvancedOptionsGUI["DetectSpeedEvents"].Value), A_SettingsWorkingDir "main_config.ini", "Game", "DetectSpeedEvents")
}

sd_SaveHotkey(GUICtrl, *) {
	global
	local k, v, l, NewHotkey, StartHotkeyEdit, PauseHotkeyEdit, StopHotkeyEdit, AutoClickerHotkeyEdit
	k := GUICtrl.Name, %k% := GUICtrl.Value

	v := StrReplace(k, "Edit")
	if !(%k% ~= "^[!^+]+$") {
		; do not allow necessary keys
		switch Format("sc{:03X}", GetKeySC(%k%)), 0 {
			case FwdKey, LeftKey, BackKey, RightKey, SC_Space:
			GUICtrl.Value := %v%
			MsgBox("That hotkey cannot be used!`nThe key is already used for movement.", "Unnaceptable Hotkey", 0x1030)
			return


			case ZoomIn, ZoomOut, RotUp, RotDown, RotRight, RotLeft, SC_Esc, SC_Enter, SC_LShift, SC_Q, SC_E, SC_R, SC_Y, SC_L, SC_Z, SC_X, SC_N:
			GUICtrl.Value := %v%
			MsgBox("That hotkey cannot be used!`nThe key is already used elsewhere in the macro.", "Unnaceptable Hotkey", 0x1030)
			return


			case SC_0, SC_1, SC_2, SC_3, SC_4, SC_5, SC_6, SC_7, SC_8, SC_9:
			GUICtrl.Value := %v%
			MsgBox("That hotkey cannot be used!`nIt will be needed to place your units.", "Unnaceptable Hotkey", 0x1030)
			return
		}

		if ((StrLen(%k%) = 0) || (%k% = StartHotkey) || (%k% = PauseHotkey) || (%k% = StopHotkey) || (%k% = AutoClickerHotkey)) { ; do not allow empty or already used hotkey (not necessary in most cases)
			GUICtrl.Value := %v%
			MsgBox("That hotkey cannot be used!`nThe key is already used as a different hotkey.`n`nIf you wish to use this hotkey, please remove it from the other one (Key: " %k% ").", "Unnaceptable Hotkey", 0x1030)
		} else { ; update the hotkey
			l := StrReplace(v, "Hotkey")
			try {
				Hotkey(%v%, sd_%l%, "Off")
			}
			IniWrite((%v% := %k%), A_SettingsWorkingDir "main_config.ini", "Settings", v)
			(l != "AutoClicker") ? (MainGUI[l "Button"].Text := " " l " (" %v% ")") : (IsSet(AutoClickerGUI) ? (AutoClickerGUI["StartAutoClicker"].Text := "Start (" AutoClickerHotkey ")") : "")
			try {
				Hotkey(%v%, sd_%l%, (v = "AutoClickerHotkey") ? "On T2" : "On")
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
	}
	IniWrite((StartHotkey := "F1"), A_SettingsWorkingDir "main_config.ini", "Settings", "StartHotkey")
	IniWrite((PauseHotkey := "F2"), A_SettingsWorkingDir "main_config.ini", "Settings", "PauseHotkey")
	IniWrite((StopHotkey := "F3"), A_SettingsWorkingDir "main_config.ini", "Settings", "StopHotkey")
	IniWrite((AutoClickerHotkey := "F4"), A_SettingsWorkingDir "main_config.ini", "Settings", "AutoClickerHotkey")
	IniWrite((ClickCount := 1000), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickCount")
	IniWrite((ClickDelay := 100), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDelay")
	IniWrite((ClickDuration := 50), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDuration")
	IniWrite((ClickMode := 1), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickMode")
	IniWrite((ClickButton := "LButton"), A_SettingsWorkingDir "main_config.ini", "Settings", "ClickButton")
	try {
		Hotkey(StartHotkey, sd_Start, "On")
		Hotkey(PauseHotkey, sd_Pause, "On")
		Hotkey(StopHotkey, sd_Stop, "On")
		Hotkey(AutoClickerHotkey, sd_AutoClicker, "On T2")
	}
}

sd_ResetHotkeysButton(*) {
	sd_LockTabs()
	if (MsgBox("Are you sure you would like to reset your confirgurations for Hotkeys?`nThis action cannot be undone!", "Reset Hotkeys", 0x1024 " Owner" MainGUI.Hwnd) = "Yes") {
		sd_ResetHotkeys()
	}
	sd_LockTabs(0)
}

sd_ResetSettingsButton(*) {
	sd_LockTabs()
	if (MsgBox("Are you sure you would like to reset your confirgurations for the macro?`nThis action cannot be undone!", "Reset Macro Configurations", 0x1024 " Owner" MainGUI.Hwnd) = "Yes") {
		sd_ResetSettings()
		sd_Close()
	}
	sd_LockTabs(0)
}

sd_ResetSettings() {
	global
	sd_SetStatus("GUI", "Resetting Settings")
	IniWrite((GUI_X := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "GUI_X")
	IniWrite((GUI_Y := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "GUI_Y")
	IniWrite((AlwaysOnTop := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "AlwaysOnTop")
	IniWrite((GUITransparency := 0), A_SettingsWorkingDir "main_config.ini", "Settings", "GUITransparency")
	IniWrite((GUITheme := "None"), A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
	IniWrite((KeyDelay := 25), A_SettingsWorkingDir "main_config.ini", "Settings", "KeyDelay")
	IniWrite((Language := "English"), A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
	IniWrite((PrivServer := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "PrivServer")
	IniWrite((ReconnectMethod := "Deeplink"), A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMethod")
	IniWrite((PublicFallback := 1), A_SettingsWorkingDir "main_config.ini", "Settings", "PublicFallback")
	IniWrite((IgnoredUpdateVersion := VersionID), A_SettingsWorkingDir "main_config.ini", "Settings", "IgnoredUpdateVersion")
	IniWrite((DankMemerJob := "Unemployed"), A_SettingsWorkingDIr "main_config.ini", "Miscellaneous", "DankMemerJob")
	IniWrite((DankMemerJobCooldown := 0), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
	IniWrite((DankMemerSlashCommands := 1), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
	IniWrite((DankMemerFarmBeg := 1), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
	IniWrite((RandomStringCount := 32), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerJobCooldown")
	IniWrite((RegLogPath := "HKEY_LOCAL_MACHINE"), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "RegLogPath")
	IniWrite((RegDumpPath := ""), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "RegDumpPath")
	sd_ResetSessionStats(), sd_ResetTotalStats()
	sd_ResetHotkeys(), sd_ResetAdvancedOptions(), sd_ResetDiscordIntegration(), sd_ResetGameConfig()
	DirDelete(A_SettingsWorkingDir "misc", true)
	DirCreate(A_SettingsWorkingDir "misc\randomstrings"), DirCreate(A_SettingsWorkingDir "misc\regdumps")
	FileDelete(A_SettingsWorkingDir "debug_log.txt"), FileAppend("[" A_DD "/" A_MM "][" A_Hour ":" A_Min ":" A_Sec "] Hello world!`n", A_SettingsWorkingDir "debug_log.txt")
	IniWrite((FirstTime := 1), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "FirstTime")
}

sd_ResetGameConfigButton(*) {
	sd_LockTabs()
	if (MsgBox("Are you sure you would like to reset your game configurations?`nThis action cannot be undone!", "Reset Game Config", 0x1024 " Owner" MainGUI.Hwnd) = "Yes") {
		sd_ResetGameConfig()
	}
	sd_LockTabs(0)
}

sd_ResetGameConfig() {
	global
	IniWrite((ChapterName1 := ChapterName1Edit.Text := "Chapter 1"), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName1")
	IniWrite((ChapterName2 := ChapterName2Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName2")
	IniWrite((ChapterName3 := ChapterName3Edit := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName3")
	IniWrite((GrindMode := GrindModeEdit.Text := "Loss Farm"), A_SettingsWorkingDir "main_config.ini", "Game", "GrindMode")
	IniWrite((UnitMode := UnitModeEdit.Text := "Preset"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitMode")
	IniWrite((UnitSlot1 := UnitSlot1Edit.Text := "Cameraman"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot1")
	IniWrite((UnitSlot2 := UnitSlot2Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot2")
	IniWrite((UnitSlot3 := UnitSlot3Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot3")
	IniWrite((UnitSlot4 := UnitSlot4Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot4")
	IniWrite((UnitSlot5 := UnitSlot5Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot5")
	IniWrite((UnitSlot6 := UnitSlot6Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot6")
	IniWrite((UnitSlot7 := UnitSlot7Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot7")
	IniWrite((UnitSlot8 := UnitSlot8Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot8")
	IniWrite((UnitSlot9 := UnitSlot9Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot9")
	IniWrite((UnitSlot0 := UnitSlot0Edit.Text := "None"), A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot0")
}

sd_GUITheme(*) {
	global
	GUITheme := MainGUI["GUITheme"].Text
	IniWrite(GUITheme, A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
	MsgBox("GUI Theme will apply next reload.", "GUI Theme", 0x1020 " T60 Owner" MainGUI.Hwnd)
}

sd_ReconnectTest(*) {
	sd_SetStatus("GUI", "Testing Reconnect")
	CloseRoblox()
	if (DisconnectCheck(1) = 2) {
		MsgBox("Success!", "Reconnect Test Complete", 0x1000)
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
			sd_ErrorBalloon(GUICtrl, "Unresolved Private Server Link", 'You entered a "share?code" link! To fix this, follow these steps:`n    1. Paste the link into your browser`n    2. Wait for Skibi Defense to load`n    3. Copy the link at the top of your browser')
		} else {
			sd_ErrorBalloon(GUICtrl, "Invalid Private Server Link", "Make sure your link:`r`    - Is copied correctly and completely`r`n    - Is for Skibi Defense by Archkos Studios`n    - Does not have a language specification")
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

DiscordProfile(*){
	try {
		sd_RunDiscord("users/1198320993958117458")
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
        }
	}
	GUIClose()
	AdvancedOptionsGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Advanced Options")
    sd_LockTabs()
	AdvancedOptionsGUI.OnEvent("Close", GUIClose)
	AdvancedOptionsGUI.AddButton("x265 y55 w40 h120 vStartupManagerGUI", "Open Macro on Startup").OnEvent("Click", sd_StartupManager)
	AdvancedOptionsGUI.AddText("x265 y25", "Custom Reconnect Message:")
	AdvancedOptionsGUI.AddEdit("x410 y22 w200 h20 vCustomReconnectMessage", ReconnectMessage).OnEvent("Change", sd_SaveReconnectMessage)
	AdvancedOptionsGUI.AddButton("x310 y55 vResetAdvancedOptions", "Reset Configs").OnEvent("Click", sd_ResetAdvancedOptionsButton)
	(DetectSpeedEventsEdit := AdvancedOptionsGUI.AddCheckBox("x312 y80 vDetectSpeedEvents Checked" DetectSpeedEvents, "Automatically detect global speed events")).Section := "Game", DetectSpeedEventsEdit.OnEvent("Click", sd_UpdateConfigShortcut)
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
	global
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
	try {
		RegWrite('"' A_MacroWorkingDir 'Start.bat"'
	 	 . ((Startup = 1) ?  ' "1"' : ' ""')		; Startup parameter
		 . ' ""'										; existing heartbeat PID
		 . ((secs > 0) ?  ' "' secs '"' : ' ""')		; delay before run (.bat)
		 , "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro")
	} catch {
		MsgBox("Failed to create Startup Parameter! This could be due to the fact that the macro does not have sufficient permissions and needs to be run as administrator!", "Startup Manager", 0x1020 " T60 Owner" SMGUI.Hwnd)
	} else {
		SMGUI["Delay"].Text := "Delay Duration: " ((secs > 0) ? hmsFromSeconds(secs) : "None")
		SMGUI["StatusVal"].SetFont("cGreen", "Tahoma"), SMGUI["StatusVal"].Text := "Active"
		CenterText(SMGUI["StatusLabel"], SMGUI["StatusVal"], SMGUI["StatusLabel"])
		SMGUI["StatusText"].SetFont("cGreen"), SMGUI["StatusText"].Text := MacroName " will automatically start on user login using the settings below:"
		SMGUI["NTVal"].SetFont("cGreen"), SMGUI["NTVal"].Text := "Valid"
		CenterText(SMGUI["NTLabel"], SMGUI["NTVal"], SMGUI["StatusText"])
		SMGUI["ASVal"].SetFont((Startup = 1) ? "cGreen" : "cRed"), SMGUI["ASVal"].Text := (Startup = 1) ? "Enabled" : "Disabled"
		CenterText(SMGUI["ASLabel"], SMGUI["ASVal"], SMGUI["StatusText"])
	}
}

RemoveButton(*) {
	global
	try {
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro")
	} catch {
		; show MsgBox	
	} else {
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

sd_Language(*) {
	global
	Language := LanguageEdit.Text
	IniWrite(Language, A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
	sd_SetStatus("GUI", "Language set to " Language)
	MsgBox("Language will apply next reload.", "Language", 0x1020 " T60 Owner" MainGUI.Hwnd)
}

sd_ReconnectMethod(GUICtrl, *) {
	global ReconnectMethod
	static val := ["Deeplink", "Browser"], l := val.Length

	if (ReconnectMethod = "Deeplink") {
		if (MsgBox('Setting reconnect method to "Browser" is not recommended!`n`nEven if you have problems while using the "Deeplink" method, fixing it is a much better option than using the "Browser" method. Read the [?] for more information.`n`Are you sure you want to change this?', "Reconnect Method Warning", 0x1034 " Owner" MainGUI.Hwnd) = 'Yes') {
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
	MsgBox("This option lets you choose between the 'Deeplink' and 'Browser' reconnect methods.`n`n'Deeplink' is the recommended method; it's faster (since it skips opening your browser and waiting for it to load completely) and works with the Roblox UWP (Microsoft Store) app.`nIt can also join SD directly without the need for a redirecting game like SD Rejoin. You can search 'Roblox Developer Deeplinking' online for more information.`n`n'Browser' should only be used when 'Deeplink' absolutely fails and is unfixable.`nThis is the old/legacy method of reconnecting; it can have inconsistencies between browsers (e.g. failure to close tabs, Roblox not logged in) and you will not be able to join a public server directly (because 'Deeplink' is forced when joining public servers).", "Reconnect Methods", 0x1020)
}

sd_AutoClickerGUI(*) {
	global
	local ClickCountEdit, ClickDurationEdit, ClickDelayEdit
	GUIClose(*) {
		if (IsSet(AutoClickerGUI) && IsObject(AutoClickerGUI)) {
			sd_LockTabs(0)
			AutoClickerGUI.Destroy(), AutoClickerGUI := ""
		}
	}
	GUIClose()
	sd_LockTabs()
	AutoClickerGUI := Gui("+AlwaysOnTop +Border -MaximizeBox -MinimizeBox", "AutoClicker")
	AutoClickerGUI.OnEvent("Close", GUIClose)
	AutoClickerGUI.SetFont("s8 cDefault w700", "Tahoma")
	AutoClickerGUI.AddGroupBox("x5 y2 w195 h105", "Settings")
	AutoClickerGUI.SetFont("Norm")
	AutoClickerGUI.AddCheckBox("x110 y2 vClickMode Checked" ClickMode, "Infinite").OnEvent("Click", sd_AutoClickerClickMode)
	AutoClickerGUI.AddText("x13 y27", "Repeat")
	AutoClickerGUI.AddEdit("x50 yp-2 w80 h18 vClickCountEdit Number Limit7 Disabled" ClickMode)
	(ClickCountEdit := AutoClickerGUI.AddUpDown("vClickCount Range0-9999999 Disabled" ClickMode, ClickCount)).Section := "Settings", ClickCountEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	AutoClickerGUI.AddText("x133 y27", "times")
	AutoClickerGUI.AddText("x10 yp+22", "Click Interval (ms):")
	AutoClickerGUI.AddEdit("xp+100 yp-2 w61 h18 vClickDelayEdit Number Limit5", ClickDelay).OnEvent("Change", (*) => sd_UpdateConfigShortcut(ClickDelayEdit))
	(ClickDelayEdit := AutoClickerGUI.AddUpDown("vClickDelay Range0-99999", ClickDelay)).Section := "Settings", ClickDelayEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	AutoClickerGUI.AddText("x10 yp+22", "Click Duration (ms):")
	AutoClickerGUI.AddEdit("xp+116 yp-2 w57 h18 vClickDurationEdit Number Limit4", ClickDuration).OnEvent("Change", (*) => sd_UpdateConfigShortcut(ClickDurationEdit))
	(ClickDurationEdit := AutoClickerGUI.AddUpDown("vClickDuration Range0-9999", ClickDuration)).Section := "Settings", ClickDurationEdit.OnEvent("Change", sd_UpdateConfigShortcut)
	AutoClickerGUI.AddText("x10 yp+22", "Click Button:")
	AutoClickerGUI.AddText("xp+105 yp w48 vClickButton +Center ", ClickButton)
	AutoClickerGUI.AddButton("xp-12 yp-1 w10 h12 vCBLeft", "<").OnEvent("Click", sd_AutoClickerClickButton)
	AutoClickerGUI.AddButton("xp+59 yp w10 h12 vCBRight", ">").OnEvent("Click", sd_AutoClickerClickButton)
	AutoClickerGui.AddButton("x60 y108 w80 h20 vStartAutoClicker", "Start (" AutoClickerHotkey ")").OnEvent("Click", sd_StartAutoClicker)
	sd_StartAutoClicker(*) {
		GUIClose()
		MainGUI.Minimize()
		sd_AutoClicker()
	}
	AutoClickerGUI.Show("w206 h130")
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
	static val := ["LButton", "RButton"], l := val.Length

	i := (ClickButton = "LButton") ? 1 : 2

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
	sd_LockTabs()
	if (MsgBox("Are you sure you would like to reset your total statistics?`nThis action cannot be undone!", "Reset Total Statistics", 0x1024 " Owner" MainGUI.Hwnd) = "Yes") {
		sd_ResetTotalStats()
	}
	sd_LockTabs(0)
}

sd_ResetTotalStats() {
	global
	IniWrite((TotalRuntime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalRuntime")
	IniWrite((TotalPlaytime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalPlaytime")
	IniWrite((TotalPausedTime := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalPausedTime")
	IniWrite((TotalDisconnects := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalDisconnects")
	IniWrite((TotalWins := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalWins")
	IniWrite((TotalLosses := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalLosses")
	IniWrite((TotalCredits := 0), A_SettingsWorkingDir "main_config.ini", "Status", "TotalCredits")
	sd_SetStats()
}

sd_DiscordIntegrationGUI(*) {
	global
	local DiscordUserIDEdit, CEPEdit, DPEdit, CritSSEdit, WebhookURLEdit, BotTokenEdit
	GUIClose(*) {
		if (IsSet(DiscordIntegrationGUI) && IsObject(DiscordIntegrationGUI)) {
			sd_LockTabs(0)
			DiscordIntegrationGUI.Destroy(), DiscordIntegrationGUI := ""
		}
	}
	GUIClose()
	DiscordIntegrationGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Discord Integration Settings")
	sd_LockTabs()
	DiscordIntegrationGUI.OnEvent("Close", GUIClose)
	DiscordIntegrationGUI.SetFont("s8 cDefault Bold", "Tahoma")
	DiscordIntegrationGUI.AddGroupBox("x5 y2 w150 h85", "Settings")
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
	Run("https://rawcdn.githack.com/NZMacros/GitHub/main/skibi_defense_macro/docs/DiscordIntegration/DiscordIntegrationDocumentation.html")
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

sd_MacroQuestionsButton(*) {
	Run("https://github.com/NZMacros/GitHub/issues/new?assignees=&labels=type%3Aquestion%2Cmacro%3Askibi_defense_macro&projects=&template=skibi-defense-macro_question.yml")
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

; CHAPTER SELECT
; ------------------------
sd_ChapterSelect1(GUICtrl?, *) {
	global ChapterName1, CurrentChapterNum, CurrentChapter
	if (IsSet(GUICtrl)) {
		ChapterName1 := MainGUI["ChapterName1Edit"].Text
		sd_CharDefaults(1)
		IniWrite(ChapterName1, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName1")
	}
	CurrentChapterNum := 1
	IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
	MainGUI["CurrentChapter"].Text := ChapterName1
	CurrentChaoter := ChapterName1
	sd_ColourfulEmbedsEasterEgg()
}

sd_ChapterSelect2(GUICtrl?, *) {
	global
	local hBM
	if (IsSet(GuiCtrl)) {
		ChapterName2 := ChapterName2Edit.Text
	}
	if ChapterName2 != "None" {
		ChapterName3Edit.Enabled := 1
		MainGUI["PasteGame3"].Enabled := 1
		ChapterStrat2Edit.Enabled := 1
		ChapterGrindMode2Edit.Enabled := 1
		ChapterStratInvertFB2Edit.Enabled := 1
		ChapterStratInvertLR2Edit.Enabled := 1
		ChapterMaxSpeed2Edit.Enabled := 1
		ChapterMaxTime2Edit.Enabled := 1
		MainGUI["CRT2Left"].Enabled := 1
		MainGUI["CRT2Right"].Enabled := 1
		MainGUI["CopyGame2"].Enabled := 1
		MainGUI["PasteGame2"].Enabled := 1
		MainGUI["SaveCharDefault2"].Enabled := 1
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["SaveChapter"])
		MainGUI["SaveCharDefault2"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
		MainGUI["ChangeUnits2"].Enabled := 1
	} else {
		ChapterName1 := ChapterName1Edit.Text
		CurrentChapterNUM := 1
		IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
		MainGUI["CurrentChapter"].Text := ChapterName1
		CurrentChapter := ChapterName1
		ChapterStrat2Edit.Enabled := 0
		ChapterGrindMode2Edit.Enabled := 0
		ChapterStratInvertFB2Edit.Enabled := 0
		ChapterStratInvertLR2Edit.Enabled := 0
		ChapterMaxSpeed2Edit.Enabled := 0
		ChapterMaxTime2Edit.Enabled := 0
		MainGUI["CRT2Left"].Enabled := 0
		MainGUI["CRT2Right"].Enabled := 0
		MainGUI["CopyGame2"].Enabled := 0
		MainGUI["SaveCharDefault2"].Enabled := 0
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["SaveCharDisabled"])
		MainGUI["SaveCharDefault2"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
		MainGUI["ChangeUnits2"].Enabled := 0
		ChapterName3Edit.Text := "None"
		ChapterName3Edit.Enabled := 0
		MainGUI["PasteGame3"].Enabled := 0
		sd_ChapterSelect3(1)
	}
	if IsSet(GuiCtrl) {
		sd_CharDefaults(2)
		IniWrite(ChapterName2, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName2")
	}
	sd_ColourfulEmbedsEasterEgg()
}

sd_ChapterSelect3(GUICtrl?, *) {
	global
	local hBM
	if (IsSet(GuiCtrl)) {
		ChapterName3 := ChapterName3Edit.Text
	}
	if ChapterName3 != "None" {
		ChapterStrat3Edit.Enabled := 1
		ChapterGrindMode3Edit.Enabled := 1
		ChapterStratInvertFB3Edit.Enabled := 1
		ChapterStratInvertLR3Edit.Enabled := 1
		ChapterMaxSpeed3Edit.Enabled := 1
		ChapterMaxTime3Edit.Enabled := 1
		MainGUI["CRT3Left"].Enabled := 1
		MainGUI["CRT3Right"].Enabled := 1
		MainGUI["CopyGame3"].Enabled := 1
		MainGUI["PasteGame3"].Enabled := 1
		MainGUI["SaveCharDefault3"].Enabled := 1
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["SaveChapter"])
		MainGUI["SaveCharDefault3"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
		MainGUI["ChangeUnits3"].Enabled := 1
	} else {
		ChapterName1 := ChapterName1Edit.Text
		CurrentChapterNum := 1
		IniWrite(CurrentChapterNum, A_SettingsWorkingDir "main_config.ini", "Game", "CurrentChapterNum")
		MainGUI["CurrentChapter"].Text := ChapterName1
		CurrentChapter := ChapterName1
		ChapterStrat3Edit.Enabled := 0
		ChapterGrindMode3Edit.Enabled := 0
		ChapterStratInvertFB3Edit.Enabled := 0
		ChapterStratInvertLR3Edit.Enabled := 0
		ChapterMaxSpeed3Edit.Enabled := 0
		ChapterMaxTime3Edit.Enabled := 0
		MainGUI["CRT3Left"].Enabled := 0
		MainGUI["CRT3Right"].Enabled := 0
		MainGUI["CopyGame3"].Enabled := 0
		MainGUI["SaveCharDefault3"].Enabled := 0
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["SaveCharDisabled"])
		MainGUI["SaveCharDefault3"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
		MainGUI["ChangeUnits3"].Enabled := 0
	}
	if (IsSet(GuiCtrl)) {
		sd_CharDefaults(3)
		IniWrite(ChapterName3, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName3")
	}
	sd_ColourfulEmbedsEasterEgg()
}

sd_CharDefaults(num) {
	global ChapterDefault
	 , ChapterName1, ChapterName2, ChapterName3
	 , ChapterStrat1, ChapterStrat2, ChapterStrat3
	 , ChapterGrindMode1, ChapterGrindMode2, ChapterGrindMode3
	 , ChapterStratInvertFB1, ChapterStratInvertFB2, ChapterStratInvertFB3
	 , ChapterStratInvertLR1, ChapterStratInvertLR2, ChapterStratInvertLR3
	 , ChapterMaxTime1, ChapterMaxTime2, ChapterMaxTime3
	 , ChapterMaxSpeed1, ChapterMaxSpeed2, ChapterMaxSpeed3
	 , ChapterReturnType1, ChapterReturnType2, ChapterReturnType3
	 , ChapterUnitSlots1, ChapterUnitSlots2, ChapterUnitSlots3
	 , ChapterUnitMode1, ChapterUnitMode2, ChapterUnitMode3
	 , ChapterUnitSlot11, ChapterUnitSlot12, ChapterUnitSlot13
	 , ChapterUnitSlot21, ChapterUnitSlot22, ChapterUnitSlot23
	 , ChapterUnitSlot31, ChapterUnitSlot32, ChapterUnitSlot33
	 , ChapterUnitSlot41, ChapterUnitSlot42, ChapterUnitSlot43
	 , ChapterUnitSlot51, ChapterUnitSlot52, ChapterUnitSlot53
	 , ChapterUnitSlot61, ChapterUnitSlot62, ChapterUnitSlot63
	 , ChapterUnitSlot71, ChapterUnitSlot72, ChapterUnitSlot73
	 , ChapterUnitSlot81, ChapterUnitSlot82, ChapterUnitSlot83
	 , ChapterUnitSlot91, ChapterUnitSlot92, ChapterUnitSlot93
	 , ChapterUnitSlot01, ChapterUnitSlot02, ChapterUnitSlot03
	 , stratslist, DisableSave := 1

	ChapterName%num% := ChapterName%num%Edit.Text
	if ChapterName%num% = "None" {
		ChapterStrat%num% := "Char3"
		ChapterGrindMode%num% := "Loss Farm"
		ChapterStratInvertFB%num% := 0
		ChapterStratInvertLR%num% := 0
		ChapterMaxSpeed%num% := 2
		ChapterMaxTime%num% := 15
		ChapterReturnType%num% := "Rejoin"
		ChapterUnitSlots%num% := 10
		ChapterUnitMode%num% := "Input"
		ChapterUnitSlot1%num% := "Cameraman"
		ChapterUnitSlot2%num% := "Speakerman"
		ChapterUnitSlot3%num% := "TV Man"
		ChapterUnitSlot4%num% := "None"
		ChapterUnitSlot5%num% := "None"
		ChapterUnitSlot6%num% := "None"
		ChapterUnitSlot7%num% := "None"
		ChapterUnitSlot8%num% := "None"
		ChapterUnitSlot9%num% := "None"
		ChapterUnitSlot0%num% := "None"
	} else {
		ChapterStrat%num% := ChapterDefault[ChapterName%num%]["Strat"]
		ChapterGrindMode%num% := ChapterDefault[ChapterName%num%]["GrindMode"]
		ChapterStratInvertFB%num% := ChapterDefault[ChapterName%num%]["InvertFB"]
		ChapterStratInvertLR%num% := ChapterDefault[ChapterName%num%]["InvertLR"]
		ChapterMaxSpeed%num% := ChapterDefault[ChapterName%num%]["MaxSpeed"]
		ChapterMaxTime%num% := ChapterDefault[ChapterName%num%]["MaxTime"]
		ChapterReturnType%num% := ChapterDefault[ChapterName%num%]["ReturnType"]
		ChapterUnitSlots%num% := ChapterDefault[ChapterName%num%]["UnitSlots"]
		ChapterUnitMode%num% := ChapterDefault[ChapterName%num%]["UnitMode"]
		ChapterUnitSlot1%num% := ChapterDefault[ChapterName%num%]["UnitSlot1"]
		ChapterUnitSlot2%num% := ChapterDefault[ChapterName%num%]["UnitSlot2"]
		ChapterUnitSlot3%num% := ChapterDefault[ChapterName%num%]["UnitSlot3"]
		ChapterUnitSlot4%num% := ChapterDefault[ChapterName%num%]["UnitSlot4"]
		ChapterUnitSlot5%num% := ChapterDefault[ChapterName%num%]["UnitSlot5"]
		ChapterUnitSlot6%num% := ChapterDefault[ChapterName%num%]["UnitSlot6"]
		ChapterUnitSlot7%num% := ChapterDefault[ChapterName%num%]["UnitSlot7"]
		ChapterUnitSlot8%num% := ChapterDefault[ChapterName%num%]["UnitSlot8"]
		ChapterUnitSlot9%num% := ChapterDefault[ChapterName%num%]["UnitSlot9"]
		ChapterUnitSlot0%num% := ChapterDefault[ChapterName%num%]["UnitSlot0"]
	}
	ChapterStrat%num%Edit.Text := ChapterStrat%num%
	ChapterGrindMode%num%Edit.Text := ChapterGrindMode%num%
	ChapterStratInvertFB%num%Edit.Value := ChapterStratInvertFB%num%
	ChapterStratInvertLR%num%Edit.Value := ChapterStratInvertLR%num%
	ChapterMaxSpeed%num%Edit.Text := ChapterMaxSpeed%num%
	ChapterMaxTime%num%Edit.Text := ChapterMaxTime%num%
	MainGUI["ChapterReturnType" num].Text := ChapterReturnType%num%
	IniWrite(ChapterStrat%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterStrat" num)
	IniWrite(ChapterGrindMode%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterGrindMode" num)
	IniWrite(ChapterStratInvertFB%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterStratInvertFB" num)
	IniWrite(ChapterStratInvertLR%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterStratInvertLR" num)
	IniWrite(ChapterMaxSpeed%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterMaxSpeed" num)
	IniWrite(ChapterMaxTime%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterMaxTime" num)
	IniWrite(ChapterReturnType%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterReturnType" num)
	IniWrite(ChapterUnitSlots%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlots" num)
	IniWrite(ChapterUnitMode%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitMode" num)
	IniWrite(ChapterUnitSlot1%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot1" num)
	IniWrite(ChapterUnitSlot2%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot2" num)
	IniWrite(ChapterUnitSlot3%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot3" num)
	IniWrite(ChapterUnitSlot4%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot4" num)
	IniWrite(ChapterUnitSlot5%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot5" num)
	IniWrite(ChapterUnitSlot6%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot6" num)
	IniWrite(ChapterUnitSlot7%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot7" num)
	IniWrite(ChapterUnitSlot8%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot8" num)
	IniWrite(ChapterUnitSlot9%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot9" num)
	IniWrite(ChapterUnitSlot0%num%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot0" num)
	DisableSave := 0
}

sd_ResetAdvancedOptions() {
	global
	IniWrite((FallbackServer1 := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "FallbackServer1")
	IniWrite((FallbackServer2 := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "FallbackServer2")
	IniWrite((FallbackServer3 := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "FallbackServer3")
	IniWrite((DebuggingScreenshots := 0), A_SettingsWorkingDir "main_config.ini", "Discord", "DebuggingScreenshots")
	IniWrite((DebugLogEnabled := 1), A_SettingsWorkingDir "main_config.ini", "Discord", "DebugLogEnabled")
	IniWrite((ReconnectMessage := ""), A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMessage")
	try {
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SkibiDefenseMacro")
	}
}

sd_ResetAdvancedOptionsButton(*) {
	sd_LockTabs()
	if (MsgBox("Are you sure you would like to reset your confirgurations for Advanced Options?`nThis action cannot be undone!", "Reset Advanced Options", 0x1024 " Owner" MainGUI.Hwnd) = "Yes") {
		sd_ResetAdvancedOptions()
	}
	sd_LockTabs(1)
}

sd_ResetDiscordIntegrationButton(*) {
	sd_LockTabs()
	if (MsgBox("Are you sure you would like to reset your confirgurations for Discord Integration?`nThis action cannot be undone!", "Reset Discord Integration", 0x1024 " Owner" MainGUI.Hwnd) = "Yes") {
		sd_SetStatus("Discord", "Resetting Integration")
		sd_ResetDiscordIntegration()
	}
	sd_LockTabs(1)
}

sd_ResetDiscordIntegration() {
	global
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

sd_CopyGameSettings(GUICtrl, *) {
	global
	static q := Chr(34), ob := Chr(123), cb := Chr(125)
	local i := SubStr(GUICtrl.Name, -1)
	A_Clipboard := ob q "Name" q ":" q ChapterName%i% q ","
	 . q "Strat" q ":" q ChapterStrat%i% q ","
	 . q "GrindMode" q ":" q ChapterGrindMode%i%
	 . q "StratInvertFB" q ":" q ChapterStratInvertFB%i%
	 . q "StratInvertLR" q ":" q ChapterStratInvertLR%i%
	 . q "MaxTime" q ":" ChapterMaxTime%i% ","
	 . q "MaxSpeed" q ":" ChapterMaxSpeed%i% ","
	 . q "ReturnType" q ":" ChapterReturnType%i% ","
	 . q "UnitSlot1" q ":" ChapterUnitSlot1%i% ","
	 . q "UnitSlot2" q ":" ChapterUnitSlot2%i% ","
	 . q "UnitSlot3" q ":" ChapterUnitSlot3%i% ","
	 . q "UnitSlot4" q ":" ChapterUnitSlot4%i% ","
	 . q "UnitSlot5" q ":" ChapterUnitSlot5%i% ","
	 . q "UnitSlot6" q ":" ChapterUnitSlot6%i% ","
	 . q "UnitSlot7" q ":" ChapterUnitSlot7%i% ","
	 . q "UnitSlot8" q ":" ChapterUnitSlot8%i% ","
	 . q "UnitSlot9" q ":" ChapterUnitSlot9%i% ","
	 . q "UnitSlot0" q ":" ChapterUnitSlot0%i% cb
}

sd_PasteGameSettings(GUICtrl, *) {
	global
	static validation := Map("GrindMode", "i)^(Loss Farm|Games Played|CC Farm|XP Farm|Win Farm)$"
	 , "StratInvertFB", "^(0|1)$"
	 , "StratInvertLR", "^(0|1)$"
	 , "MaxSpeed", "^(1|2|3|4|5)$"
	 , "MaxTime", "^\d{1,4}$"
	 , "ReturnType", "i)^(Rejoin|Return)$"), q := Chr(34)
	local i := SubStr(GUICtrl.Name, -1), obj, ctrl

	If (!RegExMatch(A_Clipboard, "^\s*\{.*\}\s*$")) {
		MsgBox("Your String Format is incorrect!`nMake sure you also copy the " q "{" q " and the " q "}" q, "Warning", 0x1030 " T60")
		return
	}
	obj := JSON.parse(A_Clipboard)
	if obj.Has("Name") {
		if (ObjHasValue(ChapterNamesList, obj["Name"])) {
			ChapterName%i% := obj["Name"]
			IniWrite(obj["Name"], A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName" i)
			MainGUI["ChapterName" i "Edit"].Text := ChapterName%i%
		} else {
			MsgBox("The Chapter Name you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " obj["Name"], "Warning", 0x1030 " T60")
		}
	}
	if obj.Has("Strat") {
		if (ObjHasValue(stratslist, obj["Strat"])) {
			ChapterStrat%i% := obj["Strat"]
			IniWrite(obj["Strat"], A_SettingsWorkingDir "main_config.ini", "Game", "ChapterStrat" i)
			MainGUI["ChapterStrat" i].Text := ChapterStrat%i%
		} else {
			MsgBox("The Strategy you tried to import is NOT valid!`nMake sure you copied the string correctly and have the strategy installed.`nSpecific: " obj["Strat"], "Warning", 0x1030 " T60")
		}
	}
	if obj.Has("UnitMode") {
		if (ObjHasValue(UnitModesArr, obj["UnitMode"])) {
			ChapterUnitMode%i% := obj["UnitMode"]
			IniWrite(obj["UnitMode"], A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitMode" i)
		} else {
			MsgBox("The Unit Mode you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " obj["UnitMode"], "Warning", 0x1030 " T60")
		}
	}
	if obj.Has("UnitSlots") {
		if (ObjHasValue([5, 6, 7, 8, 9, 10], obj["UnitSlots"])) {
			ChapterUnitSlots%i% := obj["UnitSlots"]
			IniWrite(obj["UnitSlots"], A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlots" i)
		} else {
			MsgBox("The amount of Unit Slots you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " obj["UnitSlots"], "Warning", 0x1030 " T60")
		}
	}
	Loop 9 {
		local j := A_Index
		if obj.Has("UnitSlot" j) {
			if (ObjHasValue(UnitNamesList, obj["UnitSlot" j])) {
				ChapterUnitSlot%j%%i% := obj["UnitSlot" j]
				IniWrite(obj["UnitSlot"], A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot" j i)
			} else {
				MsgBox("The Unit you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " obj["UnitSlot" j], "Warning", 0x1030 " T60")
			}
		}
	}
	if obj.Has("UnitSlot0") {
		if (ObjHasValue(UnitNamesList, obj["UnitSlot0"])) {
			ChapterUnitSlot0%i% := obj["UnitSlot0"]
			IniWrite(obj["UnitSlot0"], A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlot0" i)
		} else {
			MsgBox("The Unit you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " obj["UnitSlot0"], "Warning", 0x1030 " T60")
		}
	}
	for k, v in validation {
		if obj.Has(k) {
			if (obj[k] ~= v) {
				Chapter%k%%i% := obj[k]
				IniWrite(obj[k], A_SettingsWorkingDir "main_config.ini", "Game", "Chapter" k i)
				ctrl := MainGUI["Chapter" k i]
				switch ctrl.Type, 0 {
					case "DDL", "Text":
					ctrl.Text := obj[k]


					default:
					ctrl.Value := obj[k]
				}
			} else {
				MsgBox("The item you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " k ":" obj[k], "Warning", 0x1030 " T60")
			}
		}
	}
	sd_ChapterSelect%i%()
}

sd_SaveCharDefault(GUICtrl, *){
	global
	local i, k, v
	i := SubStr(GUICtrl.Name, -1)
	if ChapterName%i% != "None" {
		if (MsgBox("Update " ChapterName%i% "'s default settings with the currently selected settings? These will become the default settings when you change to this chapter.`n`nThe macro will use the updated settings automatically.", "Change Chapter Defaults", 0x40044 " Owner" MainGUI.Hwnd) = "Yes") {
			ChapterDefault[ChapterName%i%]["Strat"] := ChapterStrat%i%
			ChapterDefault[ChapterName%i%]["GrindMode"] := ChapterGrindMode%i%
			ChapterDefault[ChapterName%i%]["InvertFB"] := ChapterStratInvertFB%i%
			ChapterDefault[ChapterName%i%]["InvertLR"] := ChapterStratInvertLR%i%
			ChapterDefault[ChapterName%i%]["MaxSpeed"] := ChapterMaxSpeed%i%
			ChapterDefault[ChapterName%i%]["MaxTime"] := ChapterMaxTime%i%
			ChapterDefault[ChapterName%i%]["ReturnType"] := ChapterReturnType%i%
			Loop 9 {
				local j := A_Index
				ChapterDefault[ChapterName%i%]["UnitSlot" j] := ChapterUnitSlot%j%%i%
			}
			ChapterDefault[ChapterName%i%]["UnitSlot0"] := ChapterUnitSlot0%i%
			for k, v in ChapterDefault[ChapterName%i%] {
				IniWrite(v, A_SettingsWorkingDir "game_config.ini", ChapterName%i%, k)
			}
		}
	}
}

sd_ChapterReturnType(GUICtrl, *){
	global
	static val := ["Rejoin", "Return"], l := val.Length
	local i, index

	switch GUICtrl.Name, 0 {
		case "CRT1Left", "CRT1Right":
		index := 1


		case "CRT2Left", "CRT2Right":
		index := 2


		case "CRT3Left", "CRT3Right":
		index := 3
	}

	i := (ChapterReturnType%index% = "Rejoin") ? 1 : 2

	MainGUI["ChapterReturnType" index].Text := ChapterReturnType%index% := val[(GUICtrl.Name = "CRT" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite(ChapterReturnType%index%, A_SettingsWorkingDir "main_config.ini", "Game", "ChapterReturnType" index)
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
	IniWrite(UnitSlot1, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot1"), UnitSlot1Edit.Text := UnitSlot1
	IniWrite(UnitSlot2, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot2"), UnitSlot2Edit.Text := UnitSlot2
	IniWrite(UnitSlot3, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot3"), UnitSlot3Edit.Text := UnitSlot3
	IniWrite(UnitSlot4, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot4"), UnitSlot4Edit.Text := UnitSlot4
	IniWrite(UnitSlot5, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot5"), UnitSlot5Edit.Text := UnitSlot5
	IniWrite(UnitSlot6, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot6"), UnitSlot6Edit.Text := UnitSlot6
	IniWrite(UnitSlot7, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot7"), UnitSlot7Edit.Text := UnitSlot7
	IniWrite(UnitSlot8, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot8"), UnitSlot8Edit.Text := UnitSlot8
	IniWrite(UnitSlot9, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot9"), UnitSlot9Edit.Text := UnitSlot9
	IniWrite(UnitSlot0, A_SettingsWorkingDir "main_config.ini", "Game", "UnitSlot0"), UnitSlot0Edit.Text := UnitSlot0
}

sd_UnitDefinitions(*) {
	MsgBox("Having trouble understanding abbreviated or community-modified unit names? Continue on to the following MsgBox's to see a a list of all of them and their corresponding names in the lobby:", "Units Glossary", 0x1020 " T60 Owner" MainGUI.Hwnd)
	MsgBox("Cameraman - Camera Fighter`n`nLarge Cam - Large Camera`n`nScientist Cam - Researcher Camera`n`nCamerawoman - Camera Sniper Girl`n`nDancing Cam - Dancing Camera`n`nCam Strider - Camera Strider`n`nLaser Cam - Laser Camera`n`nUpg Cam - Upgraded Cameraguy`n`nHTC - High Tech Camera`n`nPlunger - Plunger Camera`n`nEngineer Cam - Engineer Camera`n`nGeneral Cameraman - Camera General`n`nUpg Camerawoman - Upgraded Camera Girl`n`nMech - Mech Camera`n`nTCM - Colossal Cameraguy`n`nLRC - Large Rocket Cameraguy`n`nFlamethrower - Flamethrower Cameraguy`n`nGlitch Plunger - Glitch Cameraguy`n`nUTCM - Upgraded Camera Colossal`n`nLLC - Large Laser Cameraguy`n`nUpg Mech - Upgraded Mech Camera`n`nALC - Astro Large Cameraguy`n`nUCS - Upgraded Camera Strider`n`nULLC - Upgraded Large Laser Cameraguy`n`nOrbital - Orbital Camera`n`nFred - Fred`n`nUlt Cam - Ultimate Cameraguy`n`nAUTC - Astro Upgraded Camera Colossal", "Cameras", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Speakerman - Speaker Fighter`n`nLarge Speakerman - Large Speaker`n`nHelicopter Speaker - Helicopter Speaker`n`nSpeaker Strider - Speaker Strider`n`nUpg Knife Speaker - Upgraded Knife Speakerguy`n`nDJ Woman - DJ Girl`n`nDSM - Dark Speakerguy`n`nTSM - Speaker Colossal`n`nUpg DJ Woman - Upgraded DJ Girl`n`nUTSM - Upgraded Speaker Colossal`n`nAlliance DJ - Alliance DJ`N`NUlt Speakerman - Ultimate Speakerguy`n`nHCUTSM - Overcharged Upgraded Speaker Colossal", "Speakers", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("TV Man - TV-Person`n`nTV Woman - TV-Girl`n`nBig TV Man - Large TV-Person`n`nloud big tv - Speaker Large TV-Person`n`nUpgraded TV Man - Upgraded TV Guy`n`nTTVM - Titan TV Guy`n`nEnergised TV Man - Energized TV Guy`n`nUlt TV Man - Ultimate TVGuy`n`nUTTVM - Upgraded Colossal TV Guy", "TV", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Clockwoman - Clock Girl`n`nGeneral Clockman - General Clockman`n`nLarge Clockman - Large Clockman`n`nGuardian Clockman - Guardian Clockman`n`nClock Titan - Colossal Clockman`n`nFuture Large Clock - Future Large Clockman`n`nTimer Clockman - Timer Clockman", "The Clockmen", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Normal Toilet - Normal Toilet`n`nRocket Toilet - Rocket Toilet`n`nChill Toilet - Chill Pal Toilet`n`nMafia Boss Toilet - Mafia Boss Toilet`n`nMutant Woman oiler - Mutant Woman Toilet`n`nTCT - Colossal Camera Toilet`n`nKatana Mutant Toilet - Katana Mutant Toilet`n`nScythe Mutant Toilet - Scythe Mutant Toilet`n`nG-Toilet 3 - G-Man Toilet 3.0`n`nTST - Colossal Speaker Toilet`n`nBuff Mutant Toilet - Large Buff Mutant Toilet`n`nCat Toilet - Cat Toilet`n`nG-Toilet 5 - Gman 5.0", "Toilets", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Astro UFO - Space UFO Toilet`n`nAstro Detainer - Space Detainer`n`nMini Juggernaut - Mini Astro Juggernaut`n`nAstro Juggernaut - The Juggernaut", "Astros", 0x1020 " Owner" MainGUI.Hwnd)
	MsgBox("Secret Agent - Secret Agent`n`nChair - Chair Phase 1`n`nSix Lens - The Strongest Camera", "???", 0x1020 " Owner" MainGUI.Hwnd)
}

sd_UnitModesHelp(*) {
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
	DankMemerAutoGrinderGUI := Gui("-MinimizeBox +Owner" MainGUI.Hwnd, "Dank Memer Auto-Grinder")
    sd_LockTabs()
	DankMemerAutoGrinderGUI.OnEvent("Close", GUIClose)
	DankMemerAutoGrinderGUI.SetFont("s8 cDefault Bold", "Tahoma")
	DankMemerAutoGrinderGUI.AddGroupBox("x5 y2 w150 h200", "Farms")
	DankMemerAutoGrinderGUI.AddGroupBox("x160 y2 w135 h120", "Job Settings")
	DankMemerAutoGrinderGUI.SetFont("Norm")
	DankMemerAutoGrinderGUI.AddText("x220 y27", "Job:")
	DankMemerJobsArr := ["Discord Mod", "Babysitter", "Fast Food Cook", "House Wife"
	 , "Twitch Streamer", "YouTuber", "Professional Hunter", "Professional Fisherman"
	 , "Grave Digger", "Bartender", "Robber", "Police Officer"
	 , "Teacher", "Musician", "Pro Gamer", "Manager"
	 , "Developer", "Day Trader", "Santa Claus", "Politician"
	 , "Veterinarian", "Pharmacist", "Dank Memer Shopkeeper", "Lawyer"
	 , "Doctor", "Scientist", "Ghost", "Adventurer"]
	(DankMemerJobEdit := DankMemerAutoGrinderGUI.AddDropDownList("x168 y47 vDankMemerJobEdit Disabled", ["Unemployed"])).Add(DankMemerJobsArr), DankMemerJobEdit.Text := DankMemerJob, DankMemerJobEdit.OnEvent("Change", sd_DankMemerJob)
	(DisplayedDankMemerJobCooldownEdit := DankMemerAutoGrinderGUI.AddText("x175 y75 vDisplayedDankMemerJobCooldown", "Cooldown: " (DankMemerJobCooldown//60000) " minutes."))
	DankMemerAutoGrinderGUI.AddCheckBox("x10 y32 vUseSlashCommands Checked" DankMemerSlashCommands, "Message Farm (" ((DankMemerSlashCommands = 1) ? "Off" : "On") ")").OnEvent("Click", sd_DMAGswitchNewCmds)
	DankMemerAutoGrinderGUI.AddCheckBox("x10 y67 vBegEdit Checked" DankMemerFarmBeg, "Beg Farm").OnEvent("Click", sd_DankMemerBegFarm)
	DankMemerAutoGrinderGUI.AddButton("x170 y130", "Start Grind").OnEvent("Click", sd_StartDankMemerAutoGrinder)
	DankMemerAutoGrinderGUI.AddButton("x170 y160", "End Grind").OnEvent("Click", sd_Stop)
	DankMemerAutoGrinderGUI.Show("w300 h200")
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
		DisplayedDankMemerJobCooldownEdit.Text := "Cooldown: " (DankMemerJobCooldown//60000) " minutes."
	}
	sd_StartDankMemerAutoGrinder(*) {
		MainGUI.Minimize(), DankMemerAutoGrinderGUI.Minimize()
		sd_DankMemerAutoGrinder()
	}
}

sd_DankMemerBegFarm(*) {
	global
	IniWrite((DankMemerFarmBeg := DankMemerAutoGrinderGUI["BegEdit"].Value), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerFarmBeg")
}

sd_DMAGswitchNewCmds(*) {
	global
	IniWrite((DankMemerSlashCommands := DankMemerAutoGrinderGUI["UseSlashCommands"].Value), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "DankMemerSlashCommands")
	((DankMemerAutoGrinderGUI["UseSlashCommands"].Value = 1) ? (DankMemerAutoGrinderGUI["UseSlashCommands"].Text := "Message Farm (Off)") : (DankMemerAutoGrinderGUI["UseSlashCommands"].Text := "Message Farm (On)"))
}

sd_QuickstartButton(*) {
	sd_LockTabs()
	MainGUI.Hide()
	sd_Quickstart()
}

sd_RandomStringGenerator(*) {
	global
	GUIClose(*) {
		if (IsSet(RandomStringGeneratorGUI) && (IsObject(RandomStringGeneratorGUI))) {
			sd_LockTabs(0)
			RandomStringGeneratorGUI.Destroy(), RandomStringGeneratorGUI := ""
        }
	}
	GUIClose()
	RandomStringGeneratorGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Random Strings")
    sd_LockTabs()
	RandomStringGeneratorGUI.OnEvent("Close", GUIClose)
	RandomStringGeneratorGUI.SetFont("s8 cDefault Bold", "Tahoma")
	RandomStringGeneratorGUI.AddGroupBox("x5 y2 w175 h55", "Settings")
	RandomStringGeneratorGUI.SetFont("Norm")
	RandomStringGeneratorGUI.AddText("x10 y30 +BackgroundTrans", "Length:")
	RandomStringGeneratorGUI.AddText("x50 y30 +Center +BackgroundTrans vRandomStringCount", RandomStringCount)
	RandomStringGeneratorGUI.AddUpDown("xp+17 yp-1 h16 -16 Range1-93 vRandomStringCountUpDown", RandomStringCount).OnEvent("Change", sd_RandomStringLength)
	RandomStringGeneratorGUI.AddButton("x110 y27 vGenerateRandomString", "Generate").OnEvent("Click", RandomString)
	RandomStringGeneratorGUI.Show("w185 h60")
	RandomString(*) {
		local NewFile :=  A_DD "-" A_MM "-" A_YYYY "--" A_Hour "-" A_Min "-" A_Sec
		FileAppend("<!DOCTYPE html>`n<head>`n<title>SDM Random String</title>`n</head>`n<body>`n<b>" GenerateRandomString() "</b>`n</body>`n</html>", A_SettingsWorkingDir "misc\randomstrings\randomstring_" NewFile ".html")
		Run(A_SettingsWorkingDir "misc\randomstrings\randomstring_" NewFile ".html")
	}
}

sd_RandomStringLength(*) { 
	global RandomStringCount
	RandomStringGeneratorGUI["RandomStringCount"].Text := RandomStringCount := RandomStringGeneratorGUI["RandomStringCountUpDown"].Value
	IniWrite(RandomStringCount, A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "RandomStringCount")
}

sd_RegistryDumperGUI(*) {
	global
	GUIClose(*) {
		if (IsSet(RegistryDumperGUI) && (IsObject(RegistryDumperGUI))) {
			sd_LockTabs(0)
			RegistryDumperGUI.Destroy(), RegistryDumperGUI := ""
        }
	}
	GUIClose()
	RegistryDumperGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "RegDump")
    sd_LockTabs()
	RegistryDumperGUI.OnEvent("Close", GUIClose)
	RegistryDumperGUI.SetFont("s8 cDefault Bold", "Tahoma")
	RegistryDumperGUI.AddGroupBox("x5 y2 w293 h146", "Settings")
	RegistryDumperGUI.SetFont("Norm")
	RegistryDumperGUI.AddText("x10 y25 +BackgroundTrans", "Registry Path:")
	RegistryDumperGUI.AddEdit("x10 y50 w285 h20 +Center vRegPath", RegDumpPath).OnEvent("Change", sd_RegDumpPath)
	RegistryDumperGUI.AddText("x10 y75 +BackgroundTrans", "Dump Path:")
	RegistryDumperGUI.AddEdit("x10 y95 w285 h20 +Center vDumpPath", RegLogPath).OnEvent("Change", sd_RegLogPath)
	RegistryDumperGUI.AddButton("x110 y120 vStartRegDump", "Begin").OnEvent("Click", StartRegDump)
	RegistryDumperGUI.AddButton("x150 y120 vEndRegDump", "Stop").OnEvent("Click", sd_Stop)
	RegistryDumperGUI.Show("w300 h150")
	StartRegDump(*) {
		MsgBox("Click OK to confirm, or press F3 to stop.", "RegDump.ahk", 0x1010 " T60 Owner" RegistryDumperGUI.Hwnd)
		sd_DumpRegistry(RegDumpPath, RegLogPath)
		if MsgBox("Complete! Time: " RegDumpTotalTime " minutes.`nOpen dump file?", "RegDump.ahk", 0x1004 " T120") = "Yes" {
			Run(ExtendedRegLogPath)
		}
	}
}

sd_RegDumpPath(*) {
	global
	IniWrite((RegDumpPath := RegistryDumperGUI["RegPath"].Value), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "RegDumpPath")
}

sd_RegLogPath(*) {
	global
	IniWrite((RegLogPath := RegistryDumperGUI["DumpPath"].Value), A_SettingsWorkingDir "main_config.ini", "Miscellaneous", "RegLogPath")
}

sd_ChangeUnits1GUI(*) {
	global
	GUIClose(*) {
		if (IsSet(ChangeLoadout1GUI) && (IsObject(ChangeLoadout1GUI))) {
			sd_LockTabs(0)
			ChangeLoadout1GUI.Destroy(), ChangeLoadout1GUI := ""
        }
	}
	GUIClose()
	ChangeLoadout1GUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "For: " ChapterName1)
    sd_LockTabs()
	ChangeLoadout1GUI.OnEvent("Close", GUIClose)
	ChangeLoadout1GUI.SetFont("s8 cDefault Bold", "Tahoma")
	ChangeLoadout1GUI.SetFont("w700")
	ChangeLoadout1GUI.AddGroupBox("x5 y3 w300 h182", ChapterName1 " Loadout")
	ChangeLoadout1GUI.AddGroupBox("x310 y3 w180 h100", ChapterName1 " Loadout Settings")
	ChangeLoadout1GUI.AddText("x15 y36", "1:")
	ChangeLoadout1GUI.AddText("x154 y36", "2:")
	ChangeLoadout1GUI.AddText("x15 y66", "3:")
	ChangeLoadout1GUI.AddText("x154 y66", "4:")
	ChangeLoadout1GUI.AddText("x15 y96", "5:")
	ChangeLoadout1GUI.AddText("x154 y96", "6:")
	ChangeLoadout1GUI.AddText("x15 y126", "7:")
	ChangeLoadout1GUI.AddText("x154 y126", "8:")
	ChangeLoadout1GUI.AddText("x15 y156", "9:")
	ChangeLoadout1GUI.AddText("x154 y156", "10:")
	ChangeLoadout1GUI.SetFont("s8 cDefault Norm", "Tahoma")
	(ChapterUnitSlot11Edit := ChangeLoadout1GUI.AddDropDownList("x30 y33 vChapterUnitSlot11", UnitNamesList)).Text := ChapterUnitSlot11, ChapterUnitSlot11Edit.Section := "Game", ChapterUnitSlot11Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot21Edit := ChangeLoadout1GUI.AddDropDownList("x170 y33 vChapterUnitSlot21", ["None"])).Add(UnitNamesList), ChapterUnitSlot21Edit.Text := ChapterUnitSlot21, ChapterUnitSlot21Edit.Section := "Game", ChapterUnitSlot21Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot31Edit := ChangeLoadout1GUI.AddDropDownList("x30 y63 vChapterUnitSlot31", ["None"])).Add(UnitNamesList), ChapterUnitSlot31Edit.Text := ChapterUnitSlot31, ChapterUnitSlot31Edit.Section := "Game", ChapterUnitSlot31Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot41Edit := ChangeLoadout1GUI.AddDropDownList("x170 y63 vChapterUnitSlot41", ["None"])).Add(UnitNamesList), ChapterUnitSlot41Edit.Text := ChapterUnitSlot41, ChapterUnitSlot41Edit.Section := "Game", ChapterUnitSlot41Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot51Edit := ChangeLoadout1GUI.AddDropDownList("x30 y93 vChapterUnitSlot51", ["None"])).Add(UnitNamesList), ChapterUnitSlot51Edit.Text := ChapterUnitSlot51, ChapterUnitSlot51Edit.Section := "Game", ChapterUnitSlot51Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot61Edit := ChangeLoadout1GUI.AddDropDownList("x170 y93 vChapterUnitSlot61", ["None"])).Add(UnitNamesList), ChapterUnitSlot61Edit.Text := ChapterUnitSlot61, ChapterUnitSlot61Edit.Section := "Game", ChapterUnitSlot61Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot71Edit := ChangeLoadout1GUI.AddDropDownList("x30 y123 vChapterUnitSlot71", ["None"])).Add(UnitNamesList), ChapterUnitSlot71Edit.Text := ChapterUnitSlot71, ChapterUnitSlot71Edit.Section := "Game", ChapterUnitSlot71Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot81Edit := ChangeLoadout1GUI.AddDropDownList("x170 y123 vChapterUnitSlot81", ["None"])).Add(UnitNamesList), ChapterUnitSlot81Edit.Text := ChapterUnitSlot81, ChapterUnitSlot81Edit.Section := "Game", ChapterUnitSlot81Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot91Edit := ChangeLoadout1GUI.AddDropDownList("x30 y153 vChapterUnitSlot91", ["None"])).Add(UnitNamesList), ChapterUnitSlot91Edit.Text := ChapterUnitSlot91, ChapterUnitSlot91Edit.Section := "Game", ChapterUnitSlot91Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot01Edit := ChangeLoadout1GUI.AddDropDownList("x174 y153 vChapterUnitSlot01", ["None"])).Add(UnitNamesList), ChapterUnitSlot01Edit.Text := ChapterUnitSlot01, ChapterUnitSlot01Edit.Section := "Game", ChapterUnitSlot01Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	ChangeLoadout1GUI.AddText("x322 y31 +BackgroundTrans", "Unit Slots:")
	ChangeLoadout1GUI.AddText("x390 y31 +Center +BackgroundTrans vChapterUnitSlots1", ChapterUnitSlots1)
	ChangeLoadout1GUI.AddUpDown("xp+26 yp-1 h16 -16 Range5-10 vChapterUnitSlots1UpDown", ChapterUnitSlots1).OnEvent("Change", sd_ChapterUnitSlots1)
	ChangeLoadout1GUI.AddText("x322 y51", "Selection Mode:")
	UnitModesArr := ["Preset", "Input", "Detect"]
	(ChapterUnitMode1Edit := ChangeLoadout1GUI.AddDropDownList("x322 y68 vChapterUnitMode1Edit", UnitModesArr)).Text := ChapterUnitMode1, ChapterUnitMode1Edit.OnEvent("Change", sd_ChapterUnitMode1)
	ChangeLoadout1GUI.AddButton("x450 y69 w20 h20 vUnitModesHelp", "?").OnEvent("Click", sd_UnitModesHelp)
	sd_ChapterUnitMode1()
	ChangeLoadout1GUI.Show("w495 h187")
}

sd_ChapterUnitMode1(*) {
	global
	IniWrite((ChapterUnitMode1 := ChapterUnitMode1Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitMode1")
	if ChapterUnitMode1 == "Preset" || ChapterUnitMode1 == "Detect" {
		Loop 9 {
			local i := A_Index, num := 1
			ChapterUnitSlot%i%%num%Edit.Enabled := 0
		}
		ChapterUnitSlot01Edit.Enabled := 0
	} else if (ChapterUnitMode1 = "Input") {
		Loop 5 {
			local i := A_Index, num := 1
			ChapterUnitSlot%i%%num%Edit.Enabled := 1
		}
		sd_ChapterUnitSlots1Locks()
	}
}

sd_ChapterUnitSlots1(*) {
	global
	IniWrite((ChangeLoadout1GUI["ChapterUnitSlots1"].Text := ChapterUnitSlots1 := ChangeLoadout1GUI["ChapterUnitSlots1UpDown"].Value), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlots1")
	sd_ChapterUnitSlots1Locks()
}

sd_ChapterUnitSlots1Locks(*) {
	global
	switch ChapterUnitMode1, 0 {
		case "Input":
		if ChapterUnitSlots1 = 5 {
			ChapterUnitSlot61Edit.Enabled := 0
			ChapterUnitSlot71Edit.Enabled := 0
			ChapterUnitSlot81Edit.Enabled := 0
			ChapterUnitSlot91Edit.Enabled := 0
			ChapterUnitSlot01Edit.Enabled := 0
		} else if (ChapterUnitSlots1 = 6) {
			ChapterUnitSlot61Edit.Enabled := 1
			ChapterUnitSlot71Edit.Enabled := 0
			ChapterUnitSlot81Edit.Enabled := 0
			ChapterUnitSlot91Edit.Enabled := 0
			ChapterUnitSlot01Edit.Enabled := 0
		} else if (ChapterUnitSlots1 = 7) {
			ChapterUnitSlot61Edit.Enabled := 1
			ChapterUnitSlot71Edit.Enabled := 1
			ChapterUnitSlot81Edit.Enabled := 0
			ChapterUnitSlot91Edit.Enabled := 0
			ChapterUnitSlot01Edit.Enabled := 0
		} else if (ChapterUnitSlots1 = 8) {
			ChapterUnitSlot61Edit.Enabled := 1
			ChapterUnitSlot71Edit.Enabled := 1
			ChapterUnitSlot81Edit.Enabled := 1
			ChapterUnitSlot91Edit.Enabled := 0
			ChapterUnitSlot01Edit.Enabled := 0
		} else if (ChapterUnitSlots1 = 9) {
			ChapterUnitSlot61Edit.Enabled := 1
			ChapterUnitSlot71Edit.Enabled := 1
			ChapterUnitSlot81Edit.Enabled := 1
			ChapterUnitSlot91Edit.Enabled := 1
			ChapterUnitSlot01Edit.Enabled := 0
		} else if (ChapterUnitSlots1 = 10) {
			ChapterUnitSlot61Edit.Enabled := 1
			ChapterUnitSlot71Edit.Enabled := 1
			ChapterUnitSlot81Edit.Enabled := 1
			ChapterUnitSlot91Edit.Enabled := 1
			ChapterUnitSlot01Edit.Enabled := 1
		}


		default:
		ChapterUnitSlot11Edit.Enabled := 0
		ChapterUnitSlot21Edit.Enabled := 0
		ChapterUnitSlot31Edit.Enabled := 0
		ChapterUnitSlot41Edit.Enabled := 0
		ChapterUnitSlot51Edit.Enabled := 0
		ChapterUnitSlot61Edit.Enabled := 0
		ChapterUnitSlot71Edit.Enabled := 0
		ChapterUnitSlot81Edit.Enabled := 0
		ChapterUnitSlot91Edit.Enabled := 0
		ChapterUnitSlot01Edit.Enabled := 0
	}
	if ChapterUnitSlot61Edit.Enabled != 1 {
		ChapterUnitSlot61Edit.Text := "None"
	} else {
		ChapterUnitSlot61Edit.Text := ChapterUnitSlot61
	}
	if ChapterUnitSlot71Edit.Enabled != 1 {
		ChapterUnitSlot71Edit.Text := "None"
	} else {
		ChapterUnitSlot71Edit.Text := ChapterUnitSlot71
	}
	if ChapterUnitSlot81Edit.Enabled != 1 {
		ChapterUnitSlot81Edit.Text := "None"
	} else {
		ChapterUnitSlot81Edit.Text := ChapterUnitSlot81
	}
	if ChapterUnitSlot91Edit.Enabled != 1 {
		ChapterUnitSlot91Edit.Text := "None"
	} else {
		ChapterUnitSlot91Edit.Text := ChapterUnitSlot91
	}
	if ChapterUnitSlot01Edit.Enabled != 1 {
		ChapterUnitSlot01Edit.Text := "None"
	} else {
		ChapterUnitSlot01Edit.Text := ChapterUnitSlot01
	}
}

sd_ChangeUnits2GUI(*) {
	global
	GUIClose(*) {
		if (IsSet(ChangeLoadout2GUI) && (IsObject(ChangeLoadout2GUI))) {
			sd_LockTabs(0)
			ChangeLoadout2GUI.Destroy(), ChangeLoadout2GUI := ""
        }
	}
	GUIClose()
	ChangeLoadout2GUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "For: " ChapterName2)
    sd_LockTabs()
	ChangeLoadout2GUI.OnEvent("Close", GUIClose)
	ChangeLoadout2GUI.SetFont("s8 cDefault Bold", "Tahoma")
	ChangeLoadout2GUI.SetFont("w700")
	ChangeLoadout2GUI.AddGroupBox("x5 y3 w300 h182", ChapterName2 " Loadout")
	ChangeLoadout2GUI.AddGroupBox("x310 y3 w180 h100", ChapterName2 " Loadout Settings")
	ChangeLoadout2GUI.AddText("x15 y36", "1:")
	ChangeLoadout2GUI.AddText("x154 y36", "2:")
	ChangeLoadout2GUI.AddText("x15 y66", "3:")
	ChangeLoadout2GUI.AddText("x154 y66", "4:")
	ChangeLoadout2GUI.AddText("x15 y96", "5:")
	ChangeLoadout2GUI.AddText("x154 y96", "6:")
	ChangeLoadout2GUI.AddText("x15 y126", "7:")
	ChangeLoadout2GUI.AddText("x154 y126", "8:")
	ChangeLoadout2GUI.AddText("x15 y156", "9:")
	ChangeLoadout2GUI.AddText("x154 y156", "10:")
	ChangeLoadout2GUI.SetFont("s8 cDefault Norm", "Tahoma")
	(ChapterUnitSlot12Edit := ChangeLoadout2GUI.AddDropDownList("x30 y33 vChapterUnitSlot12", UnitNamesList)).Text := ChapterUnitSlot12, ChapterUnitSlot12Edit.Section := "Game", ChapterUnitSlot12Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot22Edit := ChangeLoadout2GUI.AddDropDownList("x170 y33 vChapterUnitSlot22", ["None"])).Add(UnitNamesList), ChapterUnitSlot22Edit.Text := ChapterUnitSlot22, ChapterUnitSlot22Edit.Section := "Game", ChapterUnitSlot22Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot32Edit := ChangeLoadout2GUI.AddDropDownList("x30 y63 vChapterUnitSlot32", ["None"])).Add(UnitNamesList), ChapterUnitSlot32Edit.Text := ChapterUnitSlot32, ChapterUnitSlot32Edit.Section := "Game", ChapterUnitSlot32Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot42Edit := ChangeLoadout2GUI.AddDropDownList("x170 y63 vChapterUnitSlot42", ["None"])).Add(UnitNamesList), ChapterUnitSlot42Edit.Text := ChapterUnitSlot42, ChapterUnitSlot42Edit.Section := "Game", ChapterUnitSlot42Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot52Edit := ChangeLoadout2GUI.AddDropDownList("x30 y93 vChapterUnitSlot52", ["None"])).Add(UnitNamesList), ChapterUnitSlot52Edit.Text := ChapterUnitSlot52, ChapterUnitSlot52Edit.Section := "Game", ChapterUnitSlot52Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot62Edit := ChangeLoadout2GUI.AddDropDownList("x170 y93 vChapterUnitSlot62", ["None"])).Add(UnitNamesList), ChapterUnitSlot62Edit.Text := ChapterUnitSlot62, ChapterUnitSlot62Edit.Section := "Game", ChapterUnitSlot62Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot72Edit := ChangeLoadout2GUI.AddDropDownList("x30 y123 vChapterUnitSlot72", ["None"])).Add(UnitNamesList), ChapterUnitSlot72Edit.Text := ChapterUnitSlot72, ChapterUnitSlot72Edit.Section := "Game", ChapterUnitSlot72Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot82Edit := ChangeLoadout2GUI.AddDropDownList("x170 y123 vChapterUnitSlot82", ["None"])).Add(UnitNamesList), ChapterUnitSlot82Edit.Text := ChapterUnitSlot82, ChapterUnitSlot82Edit.Section := "Game", ChapterUnitSlot82Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot92Edit := ChangeLoadout2GUI.AddDropDownList("x30 y153 vChapterUnitSlot92", ["None"])).Add(UnitNamesList), ChapterUnitSlot92Edit.Text := ChapterUnitSlot92, ChapterUnitSlot92Edit.Section := "Game", ChapterUnitSlot92Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot02Edit := ChangeLoadout2GUI.AddDropDownList("x174 y153 vChapterUnitSlot02", ["None"])).Add(UnitNamesList), ChapterUnitSlot02Edit.Text := ChapterUnitSlot02, ChapterUnitSlot02Edit.Section := "Game", ChapterUnitSlot02Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	ChangeLoadout2GUI.AddText("x322 y31 +BackgroundTrans", "Unit Slots:")
	ChangeLoadout2GUI.AddText("x390 y31 +Center +BackgroundTrans vChapterUnitSlots2", ChapterUnitSlots2)
	ChangeLoadout2GUI.AddUpDown("xp+26 yp-1 h16 -16 Range5-10 vChapterUnitSlots2UpDown", ChapterUnitSlots2).OnEvent("Change", sd_ChapterUnitSlots2)
	ChangeLoadout2GUI.AddText("x322 y51", "Selection Mode:")
	UnitModesArr := ["Preset", "Input", "Detect"]
	(ChapterUnitMode2Edit := ChangeLoadout2GUI.AddDropDownList("x322 y68 vChapterUnitMode2Edit", UnitModesArr)).Text := ChapterUnitMode2, ChapterUnitMode2Edit.OnEvent("Change", sd_ChapterUnitMode2)
	ChangeLoadout2GUI.AddButton("x450 y69 w20 h20 vUnitModesHelp", "?").OnEvent("Click", sd_UnitModesHelp)
	sd_ChapterUnitMode2()
	ChangeLoadout2GUI.Show("w495 h187")
}

sd_ChapterUnitMode2(*) {
	global
	IniWrite((ChapterUnitMode2 := ChapterUnitMode2Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitMode2")
	if ChapterUnitMode2 == "Preset" || ChapterUnitMode2 == "Detect" {
		Loop 9 {
			local i := A_Index, num := 2
			ChapterUnitSlot%i%%num%Edit.Enabled := 0
		}
		ChapterUnitSlot02Edit.Enabled := 0
	} else if (ChapterUnitMode2 = "Input") {
		Loop 5 {
			local i := A_Index, num := 2
			ChapterUnitSlot%i%%num%Edit.Enabled := 1
		}
		sd_ChapterUnitSlots2Locks()
	}
}

sd_ChapterUnitSlots2(*) {
	global
	IniWrite((ChangeLoadout2GUI["ChapterUnitSlots2"].Text := ChapterUnitSlots2 := ChangeLoadout1GUI["ChapterUnitSlots2UpDown"].Value), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlots2")
	sd_ChapterUnitSlots2Locks()
}

sd_ChapterUnitSlots2Locks(*) {
	global
	switch ChapterUnitMode2, 0 {
		case "Input":
		if ChapterUnitSlots2 = 5 {
			ChapterUnitSlot62Edit.Enabled := 0
			ChapterUnitSlot72Edit.Enabled := 0
			ChapterUnitSlot82Edit.Enabled := 0
			ChapterUnitSlot92Edit.Enabled := 0
			ChapterUnitSlot02Edit.Enabled := 0
		} else if (ChapterUnitSlots2 = 6) {
			ChapterUnitSlot62Edit.Enabled := 1
			ChapterUnitSlot72Edit.Enabled := 0
			ChapterUnitSlot82Edit.Enabled := 0
			ChapterUnitSlot92Edit.Enabled := 0
			ChapterUnitSlot02Edit.Enabled := 0
		} else if (ChapterUnitSlots2 = 7) {
			ChapterUnitSlot62Edit.Enabled := 1
			ChapterUnitSlot72Edit.Enabled := 1
			ChapterUnitSlot82Edit.Enabled := 0
			ChapterUnitSlot92Edit.Enabled := 0
			ChapterUnitSlot02Edit.Enabled := 0
		} else if (ChapterUnitSlots2 = 8) {
			ChapterUnitSlot62Edit.Enabled := 1
			ChapterUnitSlot72Edit.Enabled := 1
			ChapterUnitSlot82Edit.Enabled := 1
			ChapterUnitSlot92Edit.Enabled := 0
			ChapterUnitSlot02Edit.Enabled := 0
		} else if (ChapterUnitSlots2 = 9) {
			ChapterUnitSlot62Edit.Enabled := 1
			ChapterUnitSlot72Edit.Enabled := 1
			ChapterUnitSlot82Edit.Enabled := 1
			ChapterUnitSlot92Edit.Enabled := 1
			ChapterUnitSlot02Edit.Enabled := 0
		} else if (ChapterUnitSlots2 = 10) {
			ChapterUnitSlot62Edit.Enabled := 1
			ChapterUnitSlot72Edit.Enabled := 1
			ChapterUnitSlot82Edit.Enabled := 1
			ChapterUnitSlot92Edit.Enabled := 1
			ChapterUnitSlot02Edit.Enabled := 1
		}


		default:
		ChapterUnitSlot12Edit.Enabled := 0
		ChapterUnitSlot22Edit.Enabled := 0
		ChapterUnitSlot32Edit.Enabled := 0
		ChapterUnitSlot42Edit.Enabled := 0
		ChapterUnitSlot52Edit.Enabled := 0
		ChapterUnitSlot62Edit.Enabled := 0
		ChapterUnitSlot72Edit.Enabled := 0
		ChapterUnitSlot82Edit.Enabled := 0
		ChapterUnitSlot92Edit.Enabled := 0
		ChapterUnitSlot02Edit.Enabled := 0
	}
	if ChapterUnitSlot62Edit.Enabled != 1 {
		ChapterUnitSlot62Edit.Text := "None"
	} else {
		ChapterUnitSlot62Edit.Text := ChapterUnitSlot62
	}
	if ChapterUnitSlot72Edit.Enabled != 1 {
		ChapterUnitSlot72Edit.Text := "None"
	} else {
		ChapterUnitSlot72Edit.Text := ChapterUnitSlot72
	}
	if ChapterUnitSlot82Edit.Enabled != 1 {
		ChapterUnitSlot82Edit.Text := "None"
	} else {
		ChapterUnitSlot82Edit.Text := ChapterUnitSlot82
	}
	if ChapterUnitSlot92Edit.Enabled != 1 {
		ChapterUnitSlot92Edit.Text := "None"
	} else {
		ChapterUnitSlot92Edit.Text := ChapterUnitSlot92
	}
	if ChapterUnitSlot02Edit.Enabled != 1 {
		ChapterUnitSlot02Edit.Text := "None"
	} else {
		ChapterUnitSlot02Edit.Text := ChapterUnitSlot02
	}
}

sd_ChangeUnits3GUI(*) {
	global
	GUIClose(*) {
		if (IsSet(ChangeLoadout3GUI) && (IsObject(ChangeLoadout3GUI))) {
			sd_LockTabs(0)
			ChangeLoadout3GUI.Destroy(), ChangeLoadout3GUI := ""
        }
	}
	GUIClose()
	ChangeLoadout3GUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "For: " ChapterName3)
    sd_LockTabs()
	ChangeLoadout3GUI.OnEvent("Close", GUIClose)
	ChangeLoadout3GUI.SetFont("s8 cDefault Bold", "Tahoma")
	ChangeLoadout3GUI.SetFont("w700")
	ChangeLoadout3GUI.AddGroupBox("x5 y3 w300 h182", ChapterName3 " Loadout")
	ChangeLoadout3GUI.AddGroupBox("x310 y3 w180 h100", ChapterName3 " Loadout Settings")
	ChangeLoadout3GUI.AddText("x15 y36", "1:")
	ChangeLoadout3GUI.AddText("x154 y36", "2:")
	ChangeLoadout3GUI.AddText("x15 y66", "3:")
	ChangeLoadout3GUI.AddText("x154 y66", "4:")
	ChangeLoadout3GUI.AddText("x15 y96", "5:")
	ChangeLoadout3GUI.AddText("x154 y96", "6:")
	ChangeLoadout3GUI.AddText("x15 y126", "7:")
	ChangeLoadout3GUI.AddText("x154 y126", "8:")
	ChangeLoadout3GUI.AddText("x15 y156", "9:")
	ChangeLoadout3GUI.AddText("x154 y156", "10:")
	ChangeLoadout3GUI.SetFont("s8 cDefault Norm", "Tahoma")
	(ChapterUnitSlot13Edit := ChangeLoadout3GUI.AddDropDownList("x30 y33 vChapterUnitSlot13", UnitNamesList)).Text := ChapterUnitSlot13, ChapterUnitSlot13Edit.Section := "Game", ChapterUnitSlot13Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot23Edit := ChangeLoadout3GUI.AddDropDownList("x170 y33 vChapterUnitSlot23", ["None"])).Add(UnitNamesList), ChapterUnitSlot23Edit.Text := ChapterUnitSlot23, ChapterUnitSlot23Edit.Section := "Game", ChapterUnitSlot23Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot33Edit := ChangeLoadout3GUI.AddDropDownList("x30 y63 vChapterUnitSlot33", ["None"])).Add(UnitNamesList), ChapterUnitSlot33Edit.Text := ChapterUnitSlot33, ChapterUnitSlot33Edit.Section := "Game", ChapterUnitSlot33Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot43Edit := ChangeLoadout3GUI.AddDropDownList("x170 y63 vChapterUnitSlot43", ["None"])).Add(UnitNamesList), ChapterUnitSlot43Edit.Text := ChapterUnitSlot43, ChapterUnitSlot43Edit.Section := "Game", ChapterUnitSlot43Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot53Edit := ChangeLoadout3GUI.AddDropDownList("x30 y93 vChapterUnitSlot53", ["None"])).Add(UnitNamesList), ChapterUnitSlot53Edit.Text := ChapterUnitSlot53, ChapterUnitSlot53Edit.Section := "Game", ChapterUnitSlot53Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot63Edit := ChangeLoadout3GUI.AddDropDownList("x170 y93 vChapterUnitSlot63", ["None"])).Add(UnitNamesList), ChapterUnitSlot63Edit.Text := ChapterUnitSlot63, ChapterUnitSlot63Edit.Section := "Game", ChapterUnitSlot63Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot73Edit := ChangeLoadout3GUI.AddDropDownList("x30 y123 vChapterUnitSlot73", ["None"])).Add(UnitNamesList), ChapterUnitSlot73Edit.Text := ChapterUnitSlot73, ChapterUnitSlot73Edit.Section := "Game", ChapterUnitSlot73Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot83Edit := ChangeLoadout3GUI.AddDropDownList("x170 y123 vChapterUnitSlot83", ["None"])).Add(UnitNamesList), ChapterUnitSlot83Edit.Text := ChapterUnitSlot83, ChapterUnitSlot83Edit.Section := "Game", ChapterUnitSlot83Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot93Edit := ChangeLoadout3GUI.AddDropDownList("x30 y153 vChapterUnitSlot93", ["None"])).Add(UnitNamesList), ChapterUnitSlot93Edit.Text := ChapterUnitSlot93, ChapterUnitSlot93Edit.Section := "Game", ChapterUnitSlot93Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	(ChapterUnitSlot03Edit := ChangeLoadout3GUI.AddDropDownList("x174 y153 vChapterUnitSlot03", ["None"])).Add(UnitNamesList), ChapterUnitSlot03Edit.Text := ChapterUnitSlot03, ChapterUnitSlot03Edit.Section := "Game", ChapterUnitSlot03Edit.OnEvent("Change", sd_UpdateConfigShortcut)
	ChangeLoadout3GUI.AddText("x322 y31 +BackgroundTrans", "Unit Slots:")
	ChangeLoadout3GUI.AddText("x390 y31 +Center +BackgroundTrans vChapterUnitSlots3", ChapterUnitSlots3)
	ChangeLoadout3GUI.AddUpDown("xp+26 yp-1 h16 -16 Range5-10 vChapterUnitSlots3UpDown", ChapterUnitSlots3).OnEvent("Change", sd_ChapterUnitSlots3)
	ChangeLoadout3GUI.AddText("x322 y51", "Selection Mode:")
	UnitModesArr := ["Preset", "Input", "Detect"]
	(ChapterUnitMode3Edit := ChangeLoadout3GUI.AddDropDownList("x322 y68 vChapterUnitMode3Edit", UnitModesArr)).Text := ChapterUnitMode3, ChapterUnitMode3Edit.OnEvent("Change", sd_ChapterUnitMode3)
	ChangeLoadout3GUI.AddButton("x450 y69 w20 h20 vUnitModesHelp", "?").OnEvent("Click", sd_UnitModesHelp)
	sd_ChapterUnitMode3()
	ChangeLoadout3GUI.Show("w495 h187")
}

sd_ChapterUnitMode3(*) {
	global
	IniWrite((ChapterUnitMode3 := ChapterUnitMode3Edit.Text), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitMode3")
	if ChapterUnitMode3 == "Preset" || ChapterUnitMode3 == "Detect" {
		Loop 9 {
			local i := A_Index, num := 3
			ChapterUnitSlot%i%%num%Edit.Enabled := 0
		}
		ChapterUnitSlot01Edit.Enabled := 0
	} else if (ChapterUnitMode3 = "Input") {
		Loop 5 {
			local i := A_Index, num := 3
			ChapterUnitSlot%i%%num%Edit.Enabled := 1
		}
		sd_ChapterUnitSlots3Locks()
	}
}

sd_ChapterUnitSlots3(*) {
	global
	IniWrite((ChangeLoadout3GUI["ChapterUnitSlots3"].Text := ChapterUnitSlots3 := ChangeLoadout3GUI["ChapterUnitSlots3UpDown"].Value), A_SettingsWorkingDir "main_config.ini", "Game", "ChapterUnitSlots3")
	sd_ChapterUnitSlots3Locks()
}

sd_ChapterUnitSlots3Locks(*) {
	global
	switch ChapterUnitMode3, 0 {
		case "Input":
		if ChapterUnitSlots3 = 5 {
			ChapterUnitSlot63Edit.Enabled := 0
			ChapterUnitSlot73Edit.Enabled := 0
			ChapterUnitSlot83Edit.Enabled := 0
			ChapterUnitSlot93Edit.Enabled := 0
			ChapterUnitSlot03Edit.Enabled := 0
		} else if (ChapterUnitSlots3 = 6) {
			ChapterUnitSlot63Edit.Enabled := 1
			ChapterUnitSlot73Edit.Enabled := 0
			ChapterUnitSlot83Edit.Enabled := 0
			ChapterUnitSlot93Edit.Enabled := 0
			ChapterUnitSlot03Edit.Enabled := 0
		} else if (ChapterUnitSlots3 = 7) {
			ChapterUnitSlot63Edit.Enabled := 1
			ChapterUnitSlot73Edit.Enabled := 1
			ChapterUnitSlot83Edit.Enabled := 0
			ChapterUnitSlot93Edit.Enabled := 0
			ChapterUnitSlot03Edit.Enabled := 0
		} else if (ChapterUnitSlots3 = 8) {
			ChapterUnitSlot63Edit.Enabled := 1
			ChapterUnitSlot73Edit.Enabled := 1
			ChapterUnitSlot83Edit.Enabled := 1
			ChapterUnitSlot93Edit.Enabled := 0
			ChapterUnitSlot03Edit.Enabled := 0
		} else if (ChapterUnitSlots3 = 9) {
			ChapterUnitSlot63Edit.Enabled := 1
			ChapterUnitSlot73Edit.Enabled := 1
			ChapterUnitSlot83Edit.Enabled := 1
			ChapterUnitSlot93Edit.Enabled := 1
			ChapterUnitSlot03Edit.Enabled := 0
		} else if (ChapterUnitSlots3 = 10) {
			ChapterUnitSlot63Edit.Enabled := 1
			ChapterUnitSlot73Edit.Enabled := 1
			ChapterUnitSlot83Edit.Enabled := 1
			ChapterUnitSlot93Edit.Enabled := 1
			ChapterUnitSlot03Edit.Enabled := 1
		}


		default:
		ChapterUnitSlot13Edit.Enabled := 0
		ChapterUnitSlot23Edit.Enabled := 0
		ChapterUnitSlot33Edit.Enabled := 0
		ChapterUnitSlot43Edit.Enabled := 0
		ChapterUnitSlot53Edit.Enabled := 0
		ChapterUnitSlot63Edit.Enabled := 0
		ChapterUnitSlot73Edit.Enabled := 0
		ChapterUnitSlot83Edit.Enabled := 0
		ChapterUnitSlot93Edit.Enabled := 0
		ChapterUnitSlot03Edit.Enabled := 0
	}
	if ChapterUnitSlot63Edit.Enabled != 1 {
		ChapterUnitSlot63Edit.Text := "None"
	} else {
		ChapterUnitSlot63Edit.Text := ChapterUnitSlot63
	}
	if ChapterUnitSlot73Edit.Enabled != 1 {
		ChapterUnitSlot73Edit.Text := "None"
	} else {
		ChapterUnitSlot73Edit.Text := ChapterUnitSlot73
	}
	if ChapterUnitSlot83Edit.Enabled != 1 {
		ChapterUnitSlot83Edit.Text := "None"
	} else {
		ChapterUnitSlot83Edit.Text := ChapterUnitSlot83
	}
	if ChapterUnitSlot93Edit.Enabled != 1 {
		ChapterUnitSlot93Edit.Text := "None"
	} else {
		ChapterUnitSlot93Edit.Text := ChapterUnitSlot93
	}
	if ChapterUnitSlot03Edit.Enabled != 1 {
		ChapterUnitSlot03Edit.Text := "None"
	} else {
		ChapterUnitSlot03Edit.Text := ChapterUnitSlot03
	}
}

sd_ContributorsPageButton(GUICtrl, *){
	static p := 1
	sd_ContributorsImage(p += (GUICtrl.Name = "ContributorsLeft") ? -1 : 1)
}


SetLoadProgress(Round(83.3333333333333343, 1), MacroName " (Loading: ")
