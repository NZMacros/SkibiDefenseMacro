#SingleInstance Force
#NoTrayIcon
#MaxThreads 255
#Warn VarUnset, Off

#Include "%A_ScriptDir%\..\lib\"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "mainFiles\Roblox.ahk"
#Include "externalFuncs\DurationFromSeconds.ahk"
#Include "externalFuncs\nowUnix.ahk"
#Include "externalFuncs\enum.ahk"

OnError (e, mode) => (mode = "Return") ? -1 : 0
SetWorkingDir(A_ScriptDir "\..")

MacroName := A_Args[3]
if A_Args.Length < 3 || A_Args.Length > 3 {
	Msgbox("This script needs to be run by " MacroName "! You are not supposed to run it manually.")
	ExitApp()
}

; initialization
ResetTime := LastState := nowUnix()
state := 0
MacroState := 2
offsetY := A_Args[1]
windowDimensions := A_Args[2]


pToken := Gdip_Startup()
bitmaps := Map(), bitmaps.CaseSense := 0
#Include "%A_ScriptDir%\..\img_assets\offset\bitmaps.ahk"

CoordMode("Pixel", "Screen")
DetectHiddenWindows(1)

; OnMessages
OnExit((*) => ProcessClose(DllCall("GetCurrentProcessId")))
OnMessage(0x5552, sd_SetGlobalInt, 255)
OnMessage(0x5553, sd_SetGlobalStr, 255)
OnMessage(0x5555, sd_SetState, 255)
OnMessage(0x5556, sd_SendHeartbeat)


Loop {
    hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd)
    ; sd_DeathCheck()
	Sleep 1000
}



sd_SetState(wParam, lParam, *){
	Critical
	global state, lastState
	state := wParam, LastState := lParam
	return 0
}

/*sd_DeathCheck() {
	static LastDeathDetected := 0
	if (((nowUnix() - ResetTime) > 20) && ((nowUnix() - LastDeathDetected) > 10)) {
		try {
			result := ImageSearch(&FoundX, &FoundY, windowX + windowWidth//2, windowY + windowHeight//2, windowX + windowWidth, windowY + windowHeight, A_WorkingDir "\img_assets\empty_healthbar.png")
        } catch {
			return
        }
		if (result = 1) {
			if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
				PostMessage(0x5555, 1, 1)
				Send_WM_COPYDATA("Dead", "skibi_defense_macro ahk_class AutoHotkey")
			}
			LastDeathDetected := nowUnix()
		}
	}
}*/

sd_SendHeartbeat(*) {
	Critical
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
		PostMessage(0x5556, 2)
	}
	return 0
}

sd_SetGlobalInt(wParam, lParam, *) {
	global
	Critical
	; enumeration
	EnumInt()

	local var := arr[wParam]
	try {
        %var% := lParam
    }
	return 0
}

sd_SetGlobalStr(wParam, lParam, *) {
	global
	Critical
	; enumeration
	EnumStr()
	static sections := ["Discord", "Game", "Settings", "Status"]

	local var := arr[wParam], section := sections[lParam]
	try {
        %var% := IniRead("settings\main_config.ini", section, var)
    }
	return 0
}

Send_WM_COPYDATA(StringToSend, TargetScriptTitle, wParam := 0) {
    CopyDataStruct := Buffer(3*A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut("Ptr", SizeInBytes
	 , "Ptr", StrPtr(StringToSend)
	 , CopyDataStruct, A_PtrSize)

	try {
		s := SendMessage(0x004A, wParam, CopyDataStruct, , TargetScriptTitle)
    } catch {
		return -1
	} else {
		return s
    }
}
