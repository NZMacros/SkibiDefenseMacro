#Requires AutoHotkey v2.0.18+
#SingleInstance Force
#MaxThreads 255
; #MaxThreadsPerHotkey 255
#MaxThreadsBuffer false
#Warn VarUnset, Off
Persistent(true)
SetWorkingDir(A_ScriptDir "\..")
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
SendMode("Event")
OnExit(sd_Close)
;OnError (e, mode) => (mode = "Return") ? -1 : 0

/*
Skibi Defense Macro (https://github.com/NZMacros/SkibiDefenseMacro)
Copyright © NZ Macros (https://github.com/NZMacros)

This file is part of Skibi Defense Macro. The macro's source code will always be open and available.

Skibi Defense Macro is free software: you can personally modify it under the terms of the SDML License by NZ Macros,
attached to the macro's software.

Skibi Defense Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from it's code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Skibi Defense Macro. If not, please redownload from an official source.
*/




; important vars
global A_MacroWorkingDir := A_WorkingDir "\"
global A_SettingsWorkingDir := A_MacroWorkingDir "settings\"
global A_ThemesWorkingDir := A_MacroWorkingDir "lib\Themes\"
; declare executable paths
global exe_path32 := A_AhkPath
global exe_path64 := ((A_Is64bitOS && FileExist("AutoHotkey64.exe")) ? (A_MacroWorkingDir "submacros\AutoHotkey64.exe") : A_AhkPath)
global Month := FormatTime("MM", "MMMM")
;sd_LoadLanguages()
; load macro's seasonal name(s)
if Month = "September" || Month = "October" || Month = "November" {
	TraySetIcon(A_MacroWorkingDir "sd_img_assets\icons\sdm_halloweenlogo.ico")
	global MacroName := "Skibi Cursed Macro"
	if (!FileExist(A_Desktop "\Start Skibi Cursed Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Cursed Macro.lnk")
	}
} else if (Month = "December" || Month = "January" || Month = "February") {
	TraySetIcon(A_MacroWorkingDir "sd_img_assets\icons\sdm_jollylogo.ico")
	global MacroName := "Skibi Jolly Macro"
	if (!FileExist(A_Desktop "\Start Skibi Jolly Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Jolly Macro.lnk")
	}
} else if (Month = "March" || Month = "April" || Month = "May") {
	TraySetIcon(A_MacroWorkingDir "sd_img_assets\icons\sdm_easterlogo.ico")
	global MacroName := "Skibi Easter Macro"
	if (!FileExist(A_Desktop "\Start Skibi Easter Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Easter Macro.lnk")
	}
} else {
	TraySetIcon(A_MacroWorkingDir "sd_img_assets\icons\sdm_logo.ico")
	global MacroName := "Skibi Defense Macro"
	if (!FileExist(A_Desktop "\Start Skibi Defense Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Defense Macro.lnk")
	}
}
; tray icon's menu
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
A_TrayMenu.Add("AutoClicker", sd_AutoClicker)
A_TrayMenu.Add()
A_TrayMenu.Default := "Start Macro"


; Compiler directives:
;@Ahk2Exe-SetName Skibi Defense Macro
;@Ahk2Exe-SetDescription Skibi Defense Macro
;@Ahk2Exe-SetCompanyName NZ Macros
;@Ahk2Exe-SetCopyright Copyright © NZ Macros
;@Ahk2Exe-SetOrigFilename skibi_defense_macro.exe

; global vars
global MacroState := 0 ; 0 = stopped, 1 = paused, 2 = running
; set version identifier
global VersionID := "0.5.0-alpha.1"
CurrentStrat := {pid: "", name: ""} ; stores "pid" (script process ID) and "name" (strat or join name)
global ResetTime := MacroStartTime := MacroReloadTime := nowUnix()
global PausedStartTime := 0
global GameStartTime := 0
global InLobby := 2 ; 1 = game, 2 = lobby
global PreviousAction := "None"
global CurrentAction := "Startup"
global ReconnectDelay := 0
global CurrentChapter := "None"
; game arrays
global ChapterNames := ["Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6"
 , "Nightmare 3", "Nightmare 4", "Nightmare 1", "Nightmare 2", "Nightmare 6", "Nightmare 5"
 , "Endless", "Endless Shield"]
global ChapterNamesList := [ "Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6"
 , "Endless", "Endless Shield"
 , "Nightmare 1", "Nightmare 2", "Nightmare 3", "Nightmare 4", "Nightmare 5", "Nightmare 6"]
global UnitNames := ["Cameraman", "Large Cam", "Scientist Cam", "Camerawoman", "Dancing Cam", "Cam Strider", "Laser Cam", "Upg Cam", "HTC", "Plunger", "Engineer Cam", "General Cameraman", "Upg Camerawoman", "Mech", "TCM", "LRC", "Flamethrower", "Glitch Plunger", "UTCM", "LLC", "Upg Mech", "ALC", "UCS", "ULLC", "Orbital", "Fred", "Ult Cam", "AUTC"
 , "Speakerman", "Large Speakerman", "Helicopter Speaker", "Speaker Strider", "Upg Knife Speaker", "DJ Woman", "DSM", "TSM", "Upg DJ Woman", "UTSM", "Alliance DJ", "Ult Speakerman", "HCUTSM"
 , "TV Man", "TV Woman", "Big TV Man", "loud big tv", "Upgraded TV Man", "TTVM", "Energised TV Man", "Ult TV Man", "UTTVM"
 , "Clockwoman", "General Clockman", "Large Clockman", "Guardian Clockman", "Clock Titan", "Future Large Clock", "Timer Clockman"
 , "Normal Toilet", "Rocket Toilet", "Chill Toilet", "Mafia Boss Toilet", "Mutant Woman oiler", "TCT", "Katana Mutant Toilet", "Scythe Mutant Toilet", "G-Toilet 3", "TST", "Buff Mutant Toilet", "Cat Toilet", "G-Toilet 5"
 , "Astro UFO", "Astro Detainer", "Mini Juggernaut", "Astro Juggernaut"
 , "Secret Agent", "Chair", "Six Lens"]
global UnitNamesList := ["ALC", "Alliance DJ", "Astro Detainer", "Astro Juggernaut", "Astro UFO", "AUTC"
 , "Big TV Man", "Buff Mutant Toilet"
 , "Cam Strider", "Cameraman", "Camerawoman", "Cat Toilet", "Chair", "Chill Toilet", "Clock Titan", "Clockwoman"
 , "Dancing Cam", "DJ Woman", "DSM"
 , "Energised TV Man", "Engineer Cam"
 , "Flamethrower", "Fred", "Future Large Clock"
 , "G-Toilet 3", "G-Toilet 5", "General Cameraman", "General Clockman", "Glitch Plunger", "Guardian Clockman"
 , "HCUTSM", "Helicopter Speaker", "HTC"
 , "Katana Mutant Toilet"
 , "Large Cam", "Large Clockman", "Large Speakerman", "Laser Cam", "LLC", "loud big tv", "LRC"
 , "Mafia Boss Toilet", "Mech", "Mini Juggernaut", "Mutant Woman oiler"
 , "Normal Toilet"
 , "Orbital"
 , "Plunger"
 , "Rocket Toilet"
 , "Scientist Cam", "Scythe Mutant Toilet", "Secret Agent", "Six Lens", "Speaker Strider", "Speakerman"
 , "TCM", "TCT", "Timer Clockman", "TSM", "TST", "TTVM", "TV Man", "TV Woman"
 , "UCS", "ULLC", "Ult Cam", "Ult Speakerman", "Ult TV Man", "Upg Cam", "Upg Camerawoman", "Upg DJ Woman", "Upg Knife Speaker", "Upg Mech", "Upgraded TV Man", "UTCM", "UTSM", "UTTVM"]
; assign scan codes to key variables
FwdKey := "sc011" ; w
LeftKey := "sc01e" ; a
BackKey := "sc01f" ; s
RightKey := "sc020" ; d
SC_Space := "sc039"
SC_0 := "sc00b"
SC_1 := "sc002"
SC_2 := "sc003"
SC_3 := "sc004"
SC_4 := "sc005"
SC_5 := "sc006"
SC_6 := "sc007"
SC_7 := "sc008"
SC_8 := "sc009"
SC_9 := "sc00a"
SC_Q := "sc010"
SC_E := "sc012"
SC_L := "sc026"
SC_R := "sc013"
SC_Y := "sc015"
SC_Z := "sc02c"
SC_X := "sc02d"
SC_N := "sc031"
ZoomIn := "sc017" ; i
ZoomOut := "sc018" ; o
RotUp := "sc149" ; PgUp
RotLeft := "sce04b" ; Left Arrow
RotRight := "sce04d" ; Right Arrow
RotDown := "sc151" ; PgDn
SC_Esc := "sc001"
SC_Enter := "sc01c"
SC_LShift := "sc02a"
statement := "SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%RobloxCORPORATION%'"
; finish main globals with configurations from .ini configs
sd_ImportConfig()
sd_ImportStrategies(), sd_ImportChapterDefaults()
sd_ImportPaths()



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PREPARE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ahem.... no you won't
; I hereby forbid every person using this macro...
; from using it until I fix it.
; hehe... get the reference?
msgbox("Hi user! Unfortunately, the macro currently doesn't work due to constant changes in the game. Thank you for downloading!", "Notice")
exitapp(404)
MainGUI := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", MacroName " (Loading: 0%)")
SetLoadProgress(7, MacroName " (Loading: ")
MainGUI.Show("x" GUI_X " y" GUI_Y " w500 h300")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI SKINNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
DllCall(DllCall("GetProcAddress"
 , "Ptr",DllCall("LoadLibrary", "Str", A_ThemesWorkingDir "USkin.dll")
 , "AStr","USkinInit", "Ptr")
 , "Int", 0, "Int", 0, "AStr", A_ThemesWorkingDir "" GUITheme ".msstyles")


; Ensure GUI will be visible
if (GUI_X) && (GUI_Y) {
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
WinSetTransparent(255 - (Floor(GUITransparency * 2.55)), MainGUI)
MainGUI.OnEvent("Close", sd_Close)
SetLoadProgress(12, MacroName " (Loading: ")


try {
	Hotkey(StopHotkey, sd_Stop, "On")
}

RunWith32()
ElevateScript()

sd_DefaultHandlers()

DetectHiddenWindows(1)
CloseScripts(1)
if (!WinExist("Heartbeat.ahk ahk_class AutoHotkey")) {
	Run('"' exe_path32 '" /script "' A_MacroWorkingDir 'submacros\Heartbeat.ahk" "' MacroName '"')
}
DetectHiddenWindows(0)


#Include "%A_ScriptDir%\..\lib\"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"

if !(pToken := Gdip_Startup()) {
    throw OSError("Gdip_Startup failed")
}
(bitmaps := Map()).CaseSense := 0

; bitmaps
#Include "%A_ScriptDir%\..\sd_img_assets\"
#Include "bitmaps.ahk"
#Include "GUI\bitmaps.ahk"
#Include "Reconnect\bitmaps.ahk"
#Include "offset\bitmaps.ahk"
#Include "Daily\bitmaps.ahk"
CheckDisplaySpecs()

#Include "%A_ScriptDir%\..\lib\"
#Include "JSON.ahk"
#Include "externalFuncs\"
#Include "PreciseSleep.ahk"
#Include "nowUnix.ahk"
#Include "DurationFromSeconds.ahk"
#Include "enum.ahk"
#Include "ShellRun.ahk"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RUN Discord HANDLER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Run('"' exe_path64 '" /script "' A_MacroWorkingDir 'lib\Discord.ahk" ' ; path
	'"' CommandPrefix '" "' DiscordCheck '" "' DiscordMode '" "' WebhookURL '" "' BotToken '" ' ; main
	'"' MainChannelCheck '" "' ReportChannelCheck '" "' MainChannelID '" "' ReportChannelID '" "' DiscordUserID '" ' ; id's
	'"' DebugLogEnabled '" "' Criticals '" "' Screenshots '" "' DebuggingScreenshots '" ' ; modes
	'"' CriticalErrorPings '" "' DisconnectPings '" ' ; pings
	'"' CriticalScreenshots '" ' ; screenshots
	'"' offsetY '" "' windowDimensions '" ' ; bitmaps
	'"' ColourfulEmbeds '" "' MacroName '"') ; other

#Include "%A_ScriptDir%\..\lib\mainFiles\"
#Include "GUI.ahk"
#Include "*i update_checker.ahk"
#Include "functions.ahk"
#Include "Roblox.ahk"
#Include "Status.ahk"
if FirstTime = 1 {
	sd_LockTabs()
	MainGUI.Hide()
	sd_Quickstart()
}

; testing via hotkey
/*f5:: {
	ActivateRoblox(), hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
	Gdip_ImageSearch(pBMScreen, bitmaps["MoreCurrencies"], &output)
	X := SubStr(output, 1, (comma := InStr(output, ",")) - 1), X += 25
	Y := SubStr(output, comma + 1), Y += 47
	MouseMove(X, Y + 1), Send("{Click}"), MouseMove(X, Y)
	Loop {
		ActivateRoblox()
		MsgBox(Gdip_ImageSearch(pBMScreen, bitmaps["MoreCurrenciesOptions"], &output2, , , , , 100) " | " output2)
		if Gdip_ImageSearch(pBMScreen, bitmaps["MoreCurrenciesOptions"], &output3, , , , , 100) = 1 {
			break
		}
		Send "{Click}"
		Sleep 5000
	}
	sd_SetStatus("Success", "Opened more currencies menu!")
	return
}
f6:: {
	DisconnectCheck()
	Sleep 1000
	local CharName1 := "Chapter 1"
	Loop {
		returnVal := sd_JoinChapter(CharName1)
		if returnVal = 1 {
			sd_SetStatus("Joined", CharName1)
			break
		} else if (returnVal = -1 || returnVal = -2) {
			sd_ForceReconnect(0)
		}
	}
	return
}
f7:: {
	global letoggli := 2
	Loop {
		if letoggli = 1 {
			break
		} else if (letoggli = 2) {
			Key := "sc"
			Key .= (A_Index < 10 ? "00" A_Index : A_Index < 100 ? "0" A_Index : "")
			FileAppend(Key "`n`n", A_MacroWorkingDir "newkeyvars.txt")
			Sleep 1000
			Send "{" Key "}"
		}
	}
	return
}*/





; OnMessages
OnMessage(0x004A, sd_WM_COPYDATA)
OnMessage(0x5550, sd_ForceMode, 255)
OnMessage(0x5552, sd_SetGlobalInt, 255)
OnMessage(0x5553, sd_SetGlobalStr, 255)
OnMessage(0x5555, sd_BackgroundEvent, 255)
OnMessage(0x5556, sd_SendHeartbeat)
OnMessage(0x5557, sd_ForceReconnect)
OnMessage(0x5558, sd_GrindingInterruptReason, 255)

Sleep 1000
; check for updates
sd_SetStatus("GitHub", "Checking for Updates")
try {
	AsyncHTTPRequest("GET", "https://api.github.com/repos/NZMacros/SkibiDefenseMacro/releases/latest", sd_AutoUpdateHandler, Map("accept", "application/vnd.github+json"))
}
sd_SetStatus("GUI", "Startup")
; activate hotkeys
try {
	Hotkey(StartHotkey, sd_Start, "On")
	Hotkey(PauseHotkey, sd_Pause, "On")
	Hotkey(AutoClickerHotkey, sd_AutoClicker, "On T2")
}
SetTimer(Background, 2000)
/*if (A_Args.Has(1) && (A_Args[1] = 1))
	SetTimer(sd_Start, -1000)

return*/
; check for speed events
if DetectSpeedEvents = 1 {
	try {
		AsyncHttpRequest("GET", "https://raw.githubusercontent.com/NZMacros/GitHub/main/skibi_defense_macro/data/Speedevents.txt", sd_AutoSpeedEventHandler, Map("accept", "application/vnd.github.v3.raw"))
	} 
}
SetLoadProgress(96, MacroName " (Loading: ")





; prepare macro for start
sd_Start(*) {
	global
	youdied := 0, gameended := 0
	SetKeyDelay(100 + KeyDelay)
	sd_LockTabs()
	MainGUI["StartButton"].Enabled := 0
	Hotkey(StartHotkey, "Off")
	sd_SetStatus("Begin", "Macro")
	ActivateRoblox()
	;Send "{F11}"
	DisconnectCheck()
	; check UIPI
	try {
		PostMessage(0x100, 0x7, 0, , "ahk_id " (hRoblox := GetRobloxHWND()))
	} catch {
		MsgBox("Your Roblox window is run as administrator, but the macro is not!`nThis means the macro will be unable to send any inputs to Roblox.`nYou must either reinstall Roblox without administrative rights, or run " MacroName " as admin!`n`nNOTE: It is recommended to stop the macro now, as this issue also causes hotkeys to not work while Roblox is active.", "Warning", 0x1030 " T60")
	}
	try {
		PostMessage(0x101, 0x7, 0xC0000000, , "ahk_id " hRoblox)
	}
	GetRobloxClientPos(hRoblox)
	MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
	DetectHiddenWindows(1)
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
	DetectHiddenWindows(0)
	; set stats
	MacroStartTime := nowUnix()
	sd_ResetSessionStats()
	global CurrentChapter
	CurrentChapter := MainGUI["CurrentChapter"].Text
	; start ancillary macros
	try {
		Run('"' exe_path64 '" /script "' A_MacroWorkingDir 'submacros\background.ahk" "' offsetY '" "' windowDimensions '" "' MacroName '"')
	}
	;(re)start stat monitor
	global SessionCredits, HourlyCreditsAverage
	if ((DiscordCheck) && (((DiscordMode = 1) && RegExMatch(WebhookURL, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$"))
	 || ((DiscordMode = 2) && (ReportChannelCheck = 1) && (ReportChannelID || MainChannelID)))) {
	 	Run('"' exe_path64 '" /script "' A_MacroWorkingDir 'submacros\StatMonitor.ahk" "' MacroName '" "' VersionID '" "' offsetY '" "' windowDimensions '" "' ChapterGrindMode%CurrentChapterNum% '" "' Month '" "' InLobby '"')
	 }
	; start main loop
	sd_SetStatus("Begin", "Main Loop")
	macro()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main loop
macro() {
	ActivateRoblox()
	global ServerStart := nowUnix(), InLobby := 2
	Loop {
		DisconnectCheck()
		; collect daily
		;sd_CollectDaily()
		; grind
		sd_GoGrind()
	}
}
SetLoadProgress(97, MacroName " (Loading: ")

sd_CollectDaily() {
	if InLobby != 2 {
		return -2
	}

	sd_UpdateAction("Collect")
	hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
	if Gdip_ImageSearch(pBMScreen, bitmaps["DailyReady"], &pos) = 1 {
		MouseMove((X := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1)), (Y := SubStr(pos, comma + 1)))
		Send "{Click}"
		Sleep 1000
		sd_SetStatus("Collecting", "Daily Rewards")
		while Gdip_ImageSearch(pBMScreen, bitmaps["ClaimDaily"], &claimPos) = 1 {
			MouseMove((X := SubStr(claimPos, 1, (comma := InStr(claimPos, ",")) - 1)), (Y := SubStr(claimPos, comma + 1)))
			Send "{Click}"
			Sleep 1000
		}
		sd_SetStatus("Success", "Claimed Daily Rewards!")
	} else if (Gdip_ImageSearch(pBMScreen, bitmaps["DailyUnavailable"]) = 1) {
		return 0
	} else {
		sd_SetStatus("Error", "No Daily Found")
		return -1
	}
}

sd_GoGrind() {
	global YouDied, GameEnded
	 , TCFBKey, AFCFBKey, TCLRKey, AFCLRKey, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, SC_E, KeyDelay
	 , CurrentChapterNum
	 , objective
	 , ChapterName1, ChapterStrat1, ChapterGrindMode1, ChapterStratInvertFB1, ChapterStratInvertLR1, ChapterMaxSpeed1, ChapterMaxTime1, ChapterReturnType1, ChapterUnitSlots1, ChapterUnitMode1, ChapterUnitSlot11, ChapterUnitSlot21, ChapterUnitSlot31, ChapterUnitSlot41, ChapterUnitSlot51, ChapterUnitSlot61, ChapterUnitSlot71, ChapterUnitSlot81, ChapterUnitSlot91, ChapterUnitSlot01
	 , ChapterName2, ChapterStrat2, ChapterGrindMode2, ChapterStratInvertFB2, ChapterStratInvertLR2, ChapterMaxSpeed2, ChapterMaxTime2, ChapterReturnType2, ChapterUnitSlots2, ChapterUnitMode2, ChapterUnitSlot12, ChapterUnitSlot22, ChapterUnitSlot32, ChapterUnitSlot42, ChapterUnitSlot52, ChapterUnitSlot62, ChapterUnitSlot72, ChapterUnitSlot82, ChapterUnitSlot92, ChapterUnitSlot02
	 , ChapterName3, ChapterStrat3, ChapterGrindMode3, ChapterStratInvertFB3, ChapterStratInvertLR3, ChapterMaxSpeed3, ChapterMaxTime3, ChapterReturnType3, ChapterUnitSlots3, ChapterUnitMode3, ChapterUnitSlot13, ChapterUnitSlot23, ChapterUnitSlot33, ChapterUnitSlot43, ChapterUnitSlot53, ChapterUnitSlot63, ChapterUnitSlot73, ChapterUnitSlot83, ChapterUnitSlot93, ChapterUnitSlot03
	 , ChapterName, ChapterStrat, ChapterGrindMode, ChapterStratInvertFB, ChapterStratInvertLR, ChapterMaxSpeed, ChapterMaxTime, ChapterReturnType, ChapterUnitSlots, ChapterUnitMode, ChapterUnitSlot1, ChapterUnitSlot2, ChapterUnitSlot3, ChapterUnitSlot4, ChapterUnitSlot5, ChapterUnitSlot6, ChapterUnitSlot7, ChapterUnitSlot8, ChapterUnitSlot9, ChapterUnitSlot0
	 , GameStartTime, TotalPlaytime, SessionPlaytime

	utc_min := FormatTime(A_NowUTC, "m")
	; for chapter overrides
	global ChapterOverrideReason := "None"
	Loop 1 {
		ChapterName := ChapterName%CurrentChapterNum%
		ChapterStrat := ChapterStrat%CurrentChapterNum%
		ChapterGrindMode := ChapterGrindMode%CurrentChapterNum%
		ChapterStratInvertFB := ChapterStratInvertFB%CurrentChapterNum%
		ChapterStratInvertLR := ChapterStratInvertLR%CurrentChapterNum%
		ChapterMaxSpeed := ChapterMaxSpeed%CurrentChapterNum%
		ChapterMaxTime := ChapterMaxTime%CurrentChapterNum%
		ChapterReturnType := ChapterReturnType%CurrentChapterNum%
		ChapterUnitSlots := ChapterUnitSlots%CurrentChapterNum%
		ChapterUnitMode := ChapterUnitMode%CurrentChapterNum%
		ChapterUnitSlot1 := ChapterUnitSlot1%CurrentChapterNum%
		ChapterUnitSlot2 := ChapterUnitSlot2%CurrentChapterNum%
		ChapterUnitSlot3 := ChapterUnitSlot3%CurrentChapterNum%
		ChapterUnitSlot4 := ChapterUnitSlot4%CurrentChapterNum%
		ChapterUnitSlot5 := ChapterUnitSlot5%CurrentChapterNum%
		ChapterUnitSlot6 := ChapterUnitSlot6%CurrentChapterNum%
		ChapterUnitSlot7 := ChapterUnitSlot7%CurrentChapterNum%
		ChapterUnitSlot8 := ChapterUnitSlot8%CurrentChapterNum%
		ChapterUnitSlot9 := ChapterUnitSlot9%CurrentChapterNum%
		ChapterUnitSlot0 := ChapterUnitSlot0%CurrentChapterNum%
	}
	sd_UpdateAction("Grind")
	; if applicablem reset will be added
	sd_SetStatus("Joining", ChapterName)
	; go to chapter game
	sd_GoTo(ChapterName)
	sd_SetStatus("Joined", ChapterName)
	time_limit := DurationFromSeconds(ChapterMaxTime * 60, "mm:ss")
	if ChapterOverrideReason = "None" {
		sd_SetStatus("Grinding", ChapterName "`nLimit: " time_limit " - Strategy: " ChapterStrat " - Invert F/B: " ChapterStratInvertFB " - Invert L/R: " ChapterStratInvertLR " - Return via: " ChapterReturnType "`nUnits: " (ChapterUnitSlot1 ? ChapterUnitSlot1 (ChapterUnitSlot2 ? ", " ChapterUnitSlot2 (ChapterUnitSlot3 ? ", " ChapterUnitSlot3 (ChapterUnitSlot4 ? ", " ChapterUnitSlot4 (ChapterUnitSlot5 ? ", " ChapterUnitSlot5 (ChapterUnitSlot6 ? ", " ChapterUnitSlot6 (ChapterUnitSlot7 ? ", " ChapterUnitSlot7 (ChapterUnitSlot8 ? ", " ChapterUnitSlot8 (ChapterUnitSlot9 ? ", " ChapterUnitSlot9 (ChapterUnitSlot0 ? ", " ChapterUnitSlot0 : "") : "") : "") : "") : "") : "") : "") : "") : "") : ""))
	} else {
		sd_SetStatus("Grinding", "Overrided! Reason: " ChapterOverrideReason " - Chapter: " ChapterName "`nLimit: " time_limit " - Strategy: " ChapterStrat " - Invert F/B: " ChapterStratInvertFB " - Invert L/R: " ChapterStratInvertLR " - Return via: " ChapterReturnType "`nUnits: " (ChapterUnitSlot1 ? ChapterUnitSlot1 (ChapterUnitSlot2 ? ", " ChapterUnitSlot2 (ChapterUnitSlot3 ? ", " ChapterUnitSlot3 (ChapterUnitSlot4 ? ", " ChapterUnitSlot4 (ChapterUnitSlot5 ? ", " ChapterUnitSlot5 (ChapterUnitSlot6 ? ", " ChapterUnitSlot6 (ChapterUnitSlot7 ? ", " ChapterUnitSlot7 (ChapterUnitSlot8 ? ", " ChapterUnitSlot8 (ChapterUnitSlot9 ? ", " ChapterUnitSlot9 (ChapterUnitSlot0 ? ", " ChapterUnitSlot0 : "") : "") : "") : "") : "") : "") : "") : "") : "") : ""))
	}
	; set direction keys
	; foward/back
	if (ChapterStratInvertFB) {
		TCFBKey := BackKey
		AFCFBKey := FwdKey
	} else {
		TCFBKey := FwdKey
		AFCFBKey := BackKey
	}
	; left/right
	if (ChapterStratInvertLR) {
		TCLRKey := RightKey
		AFCLRKey := LeftKey
	} else {
		TCLRKey := LeftKey
		AFCLRKey := RightKey
	}

	; grind loop
	hwnd := GetRobloxHWND()
	GetRobloxClientPos(hwnd)
	MouseMove(windowX + 350, windowY + offsetY + 100)
	bypass := 0
	InterruptReason := ""
	GameStartTime := GameStart := nowUnix()
	while ((nowUnix() - GameStart) < (ChapterMaxTime * 60)) {
		MouseMove(windowX + 350, windowY + offsetY + 100)
		sd_Grind(ChapterStrat, A_Index)

		while ((GetKeyState("F14") && (A_Index <= 3600)) || (A_Index = 1)) { ; timeout 3m
			; high priority interrupts
			if (Mod(A_Index, 5) = 1) { ; every 250ms
				if (DisconnectCheck()) {
					InterruptReason := "Disconnect"
					break
				}
				if (YouDied) {
					InterruptReason := "You Died"
					break
				}
				if (GameEnded) {
					InterruptReason := "Game Ended"
				}
			}
			Sleep 50
		}

		Click "Up"
		if InterruptReason {
			bypass := (InterruptReason ~= "i)Disconnect|You Died|Game Ended")
			if (!bypass && InStr(strats[ChapterStrat], ";@NoInterrupt")) {
				KeyWait("F14", "T180 L")
			}
			break
		}
	}
	sd_EndStrategies()

	; set game ended status
	GameDuration := DurationFromSeconds(nowUnix() - GameStart, "mm:ss")
	sd_SetStatus("Grinding", "Ended`nTime: " GameDuration " - " (InterruptReason ? InterruptReason : "Time Limit") " - Return: " ChapterReturnType)

	if (GameStarttIME) {
		TotalPlaytime := TotalPlaytime + (nowUnix() - GameStartTime)
		SessionPlaytime := SessionPlaytime + (nowUnix() - GameStartTime)
	}
	GameStartTime := 0
	if bypass = 0 {
		if ChapterReturnType = "Rejoin" { ; rejoin back
			CloseRoblox()
			DisconnectCheck()
		} else { ; return button
			sd_ReturnFrom(ChapterName)
			DisconnectCheck()
		}
	}
	sd_CurrentChapterDown()
	utc_min := FormatTime(A_NowUTC, "m")
}

sd_Grind(strat, index) {
	if (!strats.Has(strat)) {
		global ChapterStrat
		sd_SetStatus("Error", 'Strategy "' strat '" does not exist!`nChanged back to "' (ChapterStrat := strat := StandardChapterDefault[ChapterName]["strat"]) '"')
		IniWrite(ChapterDefault[ChapterName]["strat"] := strat, A_SettingsWorkingDir "game_config.ini", ChapterName, "Strat")
	}

	DetectHiddenWindows(1)
	if (index = 1 || (!WinExist("ahk_class AutoHotkey ahk_pid " CurrentStrat.pid))) {
		sd_CreateWalk(strats[strat], "strat",
			(
			'

			ChapterName := "' ChapterName '"
			ChapterStrat := "' ChapterStrat '"
			ChapterGrindMode := "' ChapterGrindMode '"
			ChapterStratInvertFB := ' ChapterStratInvertFB '
			ChapterStratInvertLR := ' ChapterStratInvertLR '
			ChapterMaxTime := ' ChapterMaxTime '
			ChapterReturnType := "' ChapterReturnType '"
			ChapterUnitMode := "' ChapterUnitMode '"
			ChapterUnitSlots := "' ChapterUnitSlots '"
			ChapterUnitSlot1 := "' ChapterUnitSlot1 '"
			ChapterUnitSlot2 := "' ChapterUnitSlot2 '"
			ChapterUnitSlot3 := "' ChapterUnitSlot3 '"
			ChapterUnitSlot4 := "' ChapterUnitSlot4 '"
			ChapterUnitSlot5 := "' ChapterUnitSlot5 '"
			ChapterUnitSlot6 := "' ChapterUnitSlot6 '"
			ChapterUnitSlot7 := "' ChapterUnitSlot7 '"
			ChapterUnitSlot8 := "' ChapterUnitSlot8 '"
			ChapterUnitSlot9 := "' ChapterUnitSlot9 '"
			ChapterUnitSlot0 := "' ChapterUnitSlot0 '"'
			)
		) ; create / replace cycled walk script for this gather session
	} else {
		Send "{F13}" ; start new cycle
	}
	DetectHiddenWindows(0)

	if KeyWait("F14", "D T5 L") = 0 { ; wait for pattern start
		sd_EndStrategies()
	}
}

sd_JoinChapter(Ch) {
	sd_SetStatus("Joining", Ch)
	hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd)
	switch Ch, 0 {
		case "Chapter 1":
		if sd_ImgSearch("Chapters\ch1.png", 10)[1] = 0 { ; if this succeeds, move the mouse here and join
			MouseMove(sd_ImgSearch("Chapters\ch1.png", 10)[2] + 699, sd_ImgSearch("Chapters\ch1.png", 10)[3] + 89), MouseMove(sd_ImgSearch("Chapters\ch1.png", 10)[2] + 700, sd_ImgSearch("Chapters\ch1.png", 10)[3] + 90)
			Send "{Click}"
			Sleep 5000
			; use an image search to verify its in the correct chapter and start the game. If it fails, find the disband button to exit and scroll to the top to try again
			if sd_ImgSearch("Chapters\ch1game.png", 10)[1] = 0 {
				if sd_ImgSearch("Chapters\startgame.png", 10)[1] = 0 {
					MouseMove(sd_ImgSearch("Chapters\startgame.png", 10)[2] - 1, sd_ImgSearch("Chapters\startgame.png", 10)[3] + 29), MouseMove(sd_ImgSearch("Chapters\startgame.png", 10)[2], sd_ImgSearch("Chapters\startgame.png", 10)[3] + 30)
					Sleep(250), Send("{Click}")
					sd_SetStatus("Joining", "Game")
					pBMScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)))
					Loop {
						if sd_ImgSearch("Chapters\readygame.png", 10)[1] = 0 {
							sd_SetStatus("Detected", "Game Loading")
							break
						} else if (Gdip_ImageSearch(pBMScreen, bitmaps["settingsicon"], &pos, , , , , 15) = 1) { ; enable low quality mode
							/*MouseMove(sd_ImgSearch("settingsicon.png", 70)[2] - 1, sd_ImgSearch("settingsicon.png", 70)[3] + 14), MouseMove(sd_ImgSearch("settingsicon.png", 70)[2], sd_ImgSearch("settingsicon.png", 70)[3] + 15)
							Sleep(250), Send("{Click}")*/
							global InLobby := 1
							PostScriptsMessage("StatMonitor", 0x5556, InLobby), PostScriptsMessage("background", 0x5557, InLobby)
							Send "{" Z "}"
							sd_SetStatus("Joined", ChapterName)
							return 1
						}
						Sleep 1000
						if A_Index > 300 {
							sd_SetStatus("Error", "No Game Found")
						}
					}
					Loop { ;  enable low quality mode
						if Gdip_ImageSearch(pBMScreen, bitmaps["settingsicon"], &pos, , , , , 15) = 1 {
							/*MouseMove(sd_ImgSearch("settingsicon.png", 70)[2] - 1, sd_ImgSearch("settingsicon.png", 70)[3] + 29), MouseMove(sd_ImgSearch("settingsicon.png", 70)[2], sd_ImgSearch("settingsicon.png", 70)[3] + 30)
							Sleep(250), Send("Click")*/
							global InLobby := 1
							PostScriptsMessage("StatMonitor", InLobby), PostScriptsMessage("background", 0x5557, InLobby)
							Send "{" Z "}"
							sd_SetStatus("Joined", ChapterName)
							return 1
						}
						Sleep 1000
						if A_Index > 300 {
							sd_SetStatus("Error", "No Game Found")
						}
					}
				}
			} else {
				if sd_ImgSearch("Chapters\disbandparty.png", 15)[1] = 0 {
					MouseMove(sd_ImgSearch("Chapters\disbandparty.png", 15)[2] + 9, sd_ImgSearch("Chapters\disbandparty.png", 15)[3] + 24), MouseMove(sd_ImgSearch("Chapters\disbandparty.png", 15)[2] + 10, sd_ImgSearch("Chapters\disbandparty.png", 15)[3] + 25)
					Sleep(250), Send("{Click}")
				} else {
					return -1
				}
				MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
				Loop {
					if sd_ImgSearch("Chapters\top.png", 10)[1] = 0 {
						break
					}
					Send "{WheelUp}"
				}
				return 0
			}
		} else if (sd_ImgSearch("Chapters\bottom.png", 10)[1] = 1) { ; scroll down and try again
			MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
			Send "{WheelDown}"
			return 0
		} else { ; if chapter 6 is found, scroll all the way back up and try again
			MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
			Loop {
				if sd_ImgSearch("Chapters\top.png", 10)[1] = 0 {
					break
				}
				Send "{WheelUp}"
			}
			return 0
		}


		default:
		sd_SetStatus("Error", 'Chapter "' Ch '" is invalid.')
		throw Error('Invalid chapter: "' Ch '" does not exist.', -1, "(or code does not exist)")
	}
}
SetLoadProgress(98, MacroName " (Loading: ")




sd_ChStrat(Ch, grindType) {
	global
	local NewCh, NewFarm
	DetectHiddenWindows(1)
	switch Ch, 0 {
		case "Chapter 1":
		NewCh := 1


		case "Chapter 2":
		NewCh := 2


		case "Chapter 3":
		NewCh := 3


		case "Chapter 4":
		NewCh := 4


		case "Chapter 5":
		NewCh := 5


		case "Chapter 6":
		NewCh := 6


		case "Nightmare 3":
		NewCh := 7


		case "Nightmare 4":
		NewCh := 8


		case "Nightmare 1":
		NewCh := 9


		case "Nightmare 2":
		NewCh := 10


		case "Nightmare 6":
		NewCh := 11


		case "Nightmare 5":
		NewCh := 12


		case "Endless":
		NewCh := 13


		case "Endless Shield":
		NewCh := 14


		default:
		sd_SetStatus("Error", "Chapter Num " Ch " is invalid!")
	}
	switch grindType, 0 {
		case "Loss Farm":
		NewFarm := 1


		case "Games Played":
		NewFarm := 2


		case "CC Farm":
		NewFarm := 3


		case "XP Farm":
		NewFarm := 4


		case "WinFarm":
		NewFarm := 5


		default:
		sd_SetStatus("Error", "Grind Type " grindType " is invalid!")
	}

	switch NewCh, 1 {
		; chapter 1
		case 1:
		switch NewFarm, 1 {
			; loss farm
			case 1:
			try {
				Run('"' exe_path32 '" /script "' A_MacroWorkingDir 'chstrats\ch1lossfarm.ahk" "' offsetY '" "' windowDimensions '" "' MacroName '" "' MaxSpeed '"')
			}


			default:
			sd_SetStatus("Error", "Grind Mode " NewFarm " for Chapter " NewCh " is invalid!")
		}


		default:
		sd_SetStatus("Error", "Ch" NewCh " is invalid!")
	}
	DetectHiddenWindows(0)
}

sd_GoTo(Location) {
	global ChapterConfirmed := 0
	local joinChar := ""
	if (InStr(Location, "Chapter ")) {
		joinChar := StrReplace(Location, "pte")
	}
	if (InStr(Location, "Nightmare ")) {
		joinChar := StrReplace(Location, "ight")
		joinChar := StrReplace(joinChar, "are")
		joinChar := StrUpper(joinChar)
	}
	if (InStr(Location, "Endless Shield")) {
		joinChar := StrReplace(Location, "less")
	}
	path := paths["jc"][StrReplace(joinChar, " ")]

	sd_CreatePath(path)
	KeyWait("F14", "D T5 L")
	KeyWait("F14", "T120 L")
	sd_EndStrategies()
}

sd_ReturnFrom(Location) {
	global ChapterConfirmed := 0
	local joinChar := ""
	if (InStr(Location, "Chapter ")) {
		joinChar := StrReplace(Location, "pte")
	}
	if (InStr(Location, "Nightmare ")) {
		joinChar := StrReplace(Location, "ight")
		joinChar := StrReplace(joinChar, "are")
		joinChar := StrUpper(joinChar)
	}
	if (InStr(Location, "Endless Shield")) {
		joinChar := StrReplace(Location, "less")
	}
	path := paths["rtf"][StrReplace(joinChar, " ")]

	sd_CreatePath(path)
	KeyWait("F14", "D T5 L")
	sd_SetStatus("Returning", "Lobby")
	KeyWait("F14", "T120 L")
	sd_EndStrategies()
}





MainGUI["StartButton"].Enabled := 1
MainGUI["PauseButton"].Enabled := 1
MainGUI["StopButton"].Enabled := 1
SetLoadProgress(99, MacroName " (Loading: ")


percentMax := 100
SetLoadProgress(percentMax, MacroName " (Loading: ", MacroName " [BETA]")
