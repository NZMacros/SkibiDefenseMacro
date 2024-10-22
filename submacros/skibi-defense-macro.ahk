#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 255
#Warn VarUnset, Off
Persistent(true)
SetWorkingDir A_InitialWorkingDir
CoordMode("Pixel", "Client")
SendMode("Event")

global A_MacroWorkingDir := A_InitialWorkingDir "\"
global A_SettingsWorkingDir := A_MacroWorkingDir "settings\"
global A_ThemesWorkingDir := A_MacroWorkingDir "lib\Themes\"
global exe_path32 := A_AhkPath
global exe_path64 := (A_Is64bitOS && FileExist("AutoHotkey64.exe")) ? (A_MacroWorkingDir "submacros\AutoHotkey64.exe") : A_AhkPath
global VersionID := "v0.2.0.0-alpha.1"

RunWith32()
CreateFolder(A_MacroWorkingDir "settings")
ImportConfig("[Settings]`nGUI_X=100`nGUI_Y=100`nAlwaysOnTop=0`nGUITransparency=0`nGUITheme=None`nKeyDelay=25`nMainGUILoadPercent=0`nHotkeyGUILoadPercent=0`nStartHotkey=F1`nPauseHotkey=F2`nStopHotkey=F3`nCloseHotkey=F4`nPrivServer=`nFallback=1`nCode=`nRudeness=0", A_SettingsWorkingDir "main-config.ini")
if !FileExist(A_Desktop "\Start SD-Macro.lnk") {
    FileCreateShortcut(A_MacroWorkingDir "Start.bat", A_Desktop "\Start SD-Macro.lnk")
}
CheckDisplaySpecs()
global Rudeness := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "Rudeness")

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
#Include "FormData.ahk"
#Include "cJSON.ahk"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"


if !(pToken := Gdip_Startup())
    Throw OSError("Gdip_Startup failed")
(bitmaps:=Map()).CaseSense := 0

#Include "%A_InitialWorkingDir%\img\bitmaps.ahk"


#Include "mainFiles\GUI.ahk"
#Include "mainfiles\ROBLOX.ahk"
#Include "mainFiles\functions.ahk"



Hotkey(StartHotkey, sd_Start)
sd_Start(*) {
    MsgBox("Hi", "Nothing to see here", 0x20)
}