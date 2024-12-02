#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 255
; #MaxThreadsPerHotkey 255
#MaxThreadsBuffer false
#Warn VarUnset, Off
Persistent(true)
SetWorkingDir(A_ScriptDir "\..")
CoordMode("Pixel", "Client")
SendMode("Event")
; OnError (e, mode) => (mode = "Return") ? -1 : 0


;@Ahk2Exe-SetOrigFilename skibi_defense_macro.exe
;@Ahk2Exe-SetCopyright Copyright © NegativeZero01 on Github (https://github.com/NegativeZero01)
;@Ahk2Exe-SetDescription Skibi Defense Macro [ALPHA]

global A_MacroWorkingDir := A_WorkingDir "\"
global A_SettingsWorkingDir := A_MacroWorkingDir "settings\"
global A_ThemesWorkingDir := A_MacroWorkingDir "lib\Themes\"
global exe_path32 := A_AhkPath
global exe_path64 := (A_Is64bitOS && FileExist("AutoHotkey64.exe")) ? (A_MacroWorkingDir "submacros\AutoHotkey64.exe") : A_AhkPath
global CurrentWalk := {pid: "", name:""} ; stores "pid" (script process ID) and "name" (path-to-game name)
global MacroState := 0 ; 0 = stopped, 1 = paused, 2 = running
global Month := FormatTime("MM", "MMMM")
; set version identifier
global VersionID := "0.4.0.0"
global ResetTime := MacroStartTime := MacroReloadTime := nowUnix()
global PausedStartTime := 0
global GameStartTime := 0
global PreviousAction := "None"
global CurrentAction := "Startup"
global ReconnectDelay := 0
global CurrentChapter := "None"
global ChapterNames := ["Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6", "Nightmare 3", "Nightmare 4", "Nightmare 1", "Nightmare 2", "Nightmare 5", "Nightmare 6", "Endless", "Endless Shield"]
global ChapterNameList := ["Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6", "Endless", "Endless Shield", "Nightmare 1", "Nightmare 2", "Nightmare 3", "Nightmare 4", "Nightmare 5", "Nightmare 6"]
sd_ImportConfig()
try {
	Hotkey(StopHotkey, sd_Stop, "On")
}

RunWith32()
CreateFolder(A_SettingsWorkingDir "personal_commands")

ElevateScript()
sd_LoadLanguages()
sd_DefaultHandlers()

DetectHiddenWindows(1)
CloseScripts(1)
if (!WinExist("Heartbeat.ahk ahk_class AutoHotkey")) {
	Run('"' exe_path32 '" /script "' A_MacroWorkingDir 'submacros\Heartbeat.ahk"')
}
DetectHiddenWindows(0)



W := "sc011"
A := "sc01e"
S := "sc01f"
D := "sc020"
I := "sc017"
O := "sc018"
E := "sc012" 
R := "sc013"
L := "sc026"
Escape := "sc001"
Enter := "`n"
Space := "/"
Slash := "sc035"
LShift := "sc02a"
RShift := "sc036"
Zero := "sc00B"
One := "sc002"
Two := "sc003"
Three := "sc004"
Four := "sc005"
Five := "sc006"
Six := "sc007"
Seven := "sc008"
Eight := "sc009"
Nine := "sc00A"
LMB := "LButton"
RMB := "RButton"
ScrollUp := "WheelUp"
ScrollDown := "WheelDown"
F11 := "F11"



#Include "%A_ScriptDir%\..\lib\"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"

if !(pToken := Gdip_Startup()) {
    throw OSError("Gdip_Startup failed")
}
(bitmaps := Map()).CaseSense := 0

; bitmaps
#Include "%A_ScriptDir%\..\img_assets\"
#Include "GUI\bitmaps.ahk"
#Include "Reconnect\bitmaps.ahk"
#Include "offset\bitmaps.ahk"
CheckDisplaySpecs()

#Include "%A_ScriptDir%\..\lib\"
#Include "JSON.ahk"
#Include "externalFuncs\"
#Include "PreciseSleep.ahk"
#Include "nowUnix.ahk"
#Include "DurationFromSeconds.ahk"
#Include "enum.ahk"
#Include "ShellRun.ahk"

Run('"' exe_path64 '" /script "' A_MacroWorkingDir 'lib\Discord.ahk" ' ; path
	'"' CommandPrefix '" "' DiscordCheck '" "' DiscordMode '" "' WebhookURL '" "' BotToken '" ' ; main
	'"' MainChannelCheck '" "' ReportChannelCheck '" "' MainChannelID '" "' ReportChannelID '" "' DiscordUserID '" ' ; id's
	'"' DebugLogEnabled '" "' Criticals '" "' Screenshots '" "' DebuggingScreenshots '" ' ; modes
	'"' CriticalErrorPings '" "' DisconnectPings '" ' ; pings
	'"' CriticalScreenshots '" "' DeathScreenshots '" ' ; screenshots
	'"' offsetY '" "' windowDimensions '" ' ; bitmaps
	'"' ColourfulEmbeds '"') ; other

#Include "%A_ScriptDir%\..\lib\mainFiles\"
#Include "GUI.ahk"
#Include "*i update_checker.ahk"
#Include "functions.ahk"
#Include "Roblox.ahk"
#Include "Status.ahk"



; OnMessages
OnMessage(0x004A, sd_WM_COPYDATA)
OnMessage(0x5550, sd_ForceMode, 255)
OnMessage(0x5552, sd_SetGlobalInt, 255)
OnMessage(0x5553, sd_SetGlobalStr, 255)
OnMessage(0x5555, sd_BackgroundEvent, 255)
OnMessage(0x5556, sd_SendHeartbeat)
OnMessage(0x5557, sd_ForceReconnect)

Sleep 1000
sd_SetStatus("GitHub", "Checking for Updates")
; check for updates
try {
	AsyncHTTPRequest("GET", "https://api.github.com/repos/NegativeZero01/skibi-defense-macro/releases/latest", sd_AutoUpdateHandler, Map("accept", "application/vnd.github+json"))
}
sd_SetStatus("GUI", "Startup")
; activate hotkeys
try {
	Hotkey(StartHotkey, sd_Start, "On")
	Hotkey(PauseHotkey, sd_Pause, "On")
	Hotkey(AutoClickerHotkey, sd_AutoClicker, "On T2")
	Hotkey(CloseHotkey, sd_Close, "On")
}
SetTimer(Background, 2000)
/*if (A_Args.Has(1) && (A_Args[1] = 1))
	SetTimer(sd_Start, -1000)

return*/





; prepare macro for start
sd_Start(*) {
	global
	SetKeyDelay(100 + KeyDelay)
	sd_MainGUIKey(0)
	MainGUI["StartButton"].Enabled := 0
	Hotkey(StartHotkey, "Off")
	sd_SetStatus("Begin", "Macro")
	ActivateRoblox()
	DisconnectCheck()
	; check UIPI
	try {
		PostMessage(0x100, 0x7, 0, , "ahk_id " (hRoblox := GetRobloxHWND()))
	} catch {
		MsgBox("Your Roblox window is run as administrator, but the macro is not!`nThis means the macro will be unable to send any inputs to Roblox.`nYou must either reinstall Roblox without administrative rights, or run Skibi Defense Macro as admin!`n`nNOTE: It is recommended to stop the macro now, as this issue also causes hotkeys to not work while Roblox is active.", LanguageText[13], 0x1030 " T60")
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
		Run('"' exe_path64 '" /script "' A_MacroWorkingDir 'submacros\background.ahk" " ' offsetY '"')
	}
	;(re)start stat monitor
	global SessionTotalCredits, CreditsAverage
	if ((DiscordCheck) && (((DiscordMode = 1) && RegExMatch(WebhookURL, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$"))
	 || ((DiscordMode = 2) && (ReportChannelCheck = 1) && (ReportChannelID || MainChannelID)))) {
	 	Run('"' exe_path64 '" /script "' A_MacroWorkingDir 'submacros\StatMonitor.ahk" "' VersionID '" "' offsetY '" "' windowDimensions '"')
	 }
	; start main loop
	sd_SetStatus("Begin", "Main Loop")
	MainLoop()
}

; start macro
MainLoop() {
	ActivateRoblox()
	global ServerStart := nowUnix()
	Loop {

	}
}


SetLoadProgress(100.00000000000001, MainGUI, GUIName " (" LanguageText[77] " ", GUIName " " LanguageText[88])
