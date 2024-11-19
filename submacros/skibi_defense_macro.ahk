#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 255
#Warn All, Off
Persistent(true)
SetWorkingDir A_InitialWorkingDir
CoordMode("Pixel", "Client")
SendMode("Event")
OnError (e, mode) => (mode = "Return") ? -1 : 0

;@Ahk2Exe-SetOrigFilename skibi_defense_macro.exe
;@Ahk2Exe-SetCopyright Copyright © NegativeZero01 on Github (https://github.com/NegativeZero01)
;@Ahk2Exe-SetDescription Skibi Defense Macro [ALPHA]

global A_MacroWorkingDir := A_InitialWorkingDir "\"
global A_SettingsWorkingDir := A_MacroWorkingDir "settings\"
global A_ThemesWorkingDir := A_MacroWorkingDir "lib\Themes\"
global exe_path32 := A_AhkPath
global exe_path64 := (A_Is64bitOS && FileExist("AutoHotkey64.exe")) ? (A_MacroWorkingDir "submacros\AutoHotkey64.exe") : A_AhkPath
global ACToggle := false

sd_WriteGlobalsfromIni()
global Month := FormatTime("MM", "MMMM")
global releases := QueryGitHubRepo("NegativeZero01/skibi-defense-macro", "releases")
global RRN := releases[1]["tag_name"]
global ReleaseName := "skibi-defense-macro-" RRN
global CurrentVersion := ReplaceChar(VID)
global CRRN := ReplaceChar(RRN)

RunWith32()
CreateFolder(A_MacroWorkingDir "img\bitmap-debugging")

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

CheckDisplaySpecs()
LoadLanguages()
sd_DefaultHandlers()

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
Enter := "sc01c"
Space := "sc039"
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

#Include "%A_InitialWorkingDir%\lib\"
#Include "DJSON.ahk"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"

if !(pToken := Gdip_Startup()) {
    throw OSError("Gdip_Startup failed")
}
(bitmaps := Map()).CaseSense := 0

#Include "%A_InitialWorkingDir%\img\bitmaps.ahk"

#Include "%A_InitialWorkingDir%\lib\mainFiles\"
#Include "update_checker.ahk"
#Include "functions.ahk"
#Include "ROBLOX.ahk"
#Include "GUI.ahk"


QueryUpdateValidity()



; Hotkey(StartHotkey, sd_Start)
sd_Start(*) {
    ; func
}