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

; important vars
global A_MacroWorkingDir := A_WorkingDir "\"
global A_SettingsWorkingDir := A_MacroWorkingDir "settings\"
global A_ThemesWorkingDir := A_MacroWorkingDir "lib\Themes\"
global exe_path32 := A_AhkPath
global exe_path64 := (A_Is64bitOS && FileExist("AutoHotkey64.exe")) ? (A_MacroWorkingDir "submacros\AutoHotkey64.exe") : A_AhkPath
global Month := FormatTime("MM", "MMMM")
sd_LoadLanguages()
if Month = ("September" || "October" || "November") {
	TraySetIcon(A_MacroWorkingDir "img_assets\icons\sdm_halloweenlogo.ico")
	global MacroName := LanguageText[19]
	if (!FileExist(A_Desktop "\Start Skibi Cursed Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Cursed Macro.lnk")
	}
} else if (Month = ("December" || "January" || "February")) {
	TraySetIcon(A_MacroWorkingDir "img_assets\icons\sdm_jollylogo.ico")
	global MacroName := LanguageText[20]
	if (!FileExist(A_Desktop "\Start Skibi Jolly Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Jolly Macro.lnk")
	}
} else if (Month = ("March" || "April" || "May")) {
	TraySetIcon(A_MacroWorkingDir "img_assets\icons\sdm_easterlogo.ico")
	global MacroName := "Skibi Easter Macro"
	if (!FileExist(A_Desktop "\Start Skibi Easter Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Easter Macro.lnk")
	}
} else {
	TraySetIcon(A_MacroWorkingDir "img_assets\icons\sdm_logo.ico")
	global MacroName := LanguageText[18]
	if (!FileExist(A_Desktop "\Start Skibi Defense Macro.lnk")) {
		FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start Skibi Defense Macro.lnk")
	}
}


;@Ahk2Exe-SetOrigFilename "skibi_defense_macro.exe"
;@Ahk2Exe-SetCopyright "Copyright © NZ Macros"
;@Ahk2Exe-SetDescription %MacroName% " [BETA]"

; global vars
global CurrentWalk := {pid: "", name:""} ; stores "pid" (script process ID) and "name" (path-to-game name)
global MacroState := 0 ; 0 = stopped, 1 = paused, 2 = running
; set version identifier
global VersionID := "0.4.1"
global ResetTime := MacroStartTime := MacroReloadTime := nowUnix()
global PausedStartTime := 0
global GameStartTime := 0
global PreviousAction := "None"
global CurrentAction := "Startup"
global ReconnectDelay := 0
global CurrentChapter := "None"
; game arrays
global ChapterNames := ["Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6"
 , "Nightmare 3", "Nightmare 4", "Nightmare 1", "Nightmare 2", "Nightmare 5", "Nightmare 6"
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
GrindModes := ["Loss Farm", "Games Played", "CC Farm", "XP Farm", "Win Farm"]
GrindModesList := ["CC Farm", "Games Played", "Loss Farm", "Win Farm", "XP Farm"]
; finish globals with configurations from main_config.ini
sd_ImportConfig()
try {
	Hotkey(StopHotkey, sd_Stop, "On")
}

RunWith32()
CreateFolder(A_SettingsWorkingDir "personal_commands")

ElevateScript()
sd_DefaultHandlers()

DetectHiddenWindows(1)
CloseScripts(1)
if (!WinExist("Heartbeat.ahk ahk_class AutoHotkey")) {
	Run('"' exe_path32 '" /script "' A_MacroWorkingDir 'submacros\Heartbeat.ahk" "' MacroName '"')
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
	'"' CriticalScreenshots '" ' ; screenshots
	'"' offsetY '" "' windowDimensions '" ' ; bitmaps
	'"' ColourfulEmbeds '" "' MacroName '"') ; other

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
SetLoadProgress(96, MainGUI, MacroName " (" LanguageText[77] " ")





; prepare macro for start
sd_Start(*) {
	global
	SetKeyDelay(100 + KeyDelay)
	sd_LockTabs()
	MainGUI["StartButton"].Enabled := 0
	Hotkey(StartHotkey, "Off")
	sd_SetStatus("Begin", "Macro")
	ActivateRoblox()
	DisconnectCheck()
	; check UIPI
	try {
		PostMessage(0x100, 0x7, 0, , "ahk_id " (hRoblox := GetRobloxHWND()))
	} catch {
		MsgBox("Your Roblox window is run as administrator, but the macro is not!`nThis means the macro will be unable to send any inputs to Roblox.`nYou must either reinstall Roblox without administrative rights, or run " MacroName " as admin!`n`nNOTE: It is recommended to stop the macro now, as this issue also causes hotkeys to not work while Roblox is active.", LanguageText[13], 0x1030 " T60")
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
	global SessionTotalCredits, CreditsAverage
	if ((DiscordCheck) && (((DiscordMode = 1) && RegExMatch(WebhookURL, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$"))
	 || ((DiscordMode = 2) && (ReportChannelCheck = 1) && (ReportChannelID || MainChannelID)))) {
	 	Run('"' exe_path64 '" /script "' A_MacroWorkingDir 'submacros\StatMonitor.ahk" "' MacroName '" "' VersionID '" "' offsetY '" "' windowDimensions '" "' GrindMode '" "' Month '"')
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
		DisconnectCheck()
	}
}


MainGUI["StartButton"].Enabled := 1
MainGUI["PauseButton"].Enabled := 1
MainGUI["StopButton"].Enabled := 1
MainGUI["AutoClickerButton"].Enabled := 1
MainGUI["CloseButton"].Enabled := 1


percentMax := 100
SetLoadProgress(percentMax, MainGUI, MacroName " (" LanguageText[77] " ", MacroName " " LanguageText[88])
gofys()
