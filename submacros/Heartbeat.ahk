#NoTrayIcon
#SingleInstance Force
#MaxThreads 255

MacroName := A_Args[1]
if A_Args.Length < 1 || A_Args.Length > 1 {
	MsgBox("This script needs to be run by " MacroName "! You are not supposed to run it manually.")
	ExitApp()
}

#Include "%A_ScriptDir%\..\lib\externalFuncs\nowUnix.ahk"

SetWorkingDir(A_ScriptDir "\..")
OnMessage(0x5552, sd_SetGlobalInt)
OnMessage(0x5556, sd_SetHeartbeat)

LastRobloxWindow := LastDiscordHeartbeat := LastMainHeartbeat := LastBackgroundHeartbeat := nowUnix()
MacroState := 0
path := '"' A_AhkPath '" "' A_ScriptDir '\skibi_defense_macro.ahk"'

Loop {
	time := nowUnix()
	DetectHiddenWindows 0
	if (WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox ahk_exe ApplicationFrameHost.exe")) {
		LastRobloxWindow := time
    }
	DetectHiddenWindows 1
	; request heartbeat
	if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
		PostMessage(0x5556)
    }
	if WinExist("Discord.ahk ahk_class AutoHotkey") {
		PostMessage(0x5556)
    }
	if WinExist("background.ahk ahk_class AutoHotkey") {
		PostMessage(0x5556)
    }
	; check for timeouts
	if (((MacroState = 2) && (((time - LastMainHeartbeat > 120) && (reason := "Macro Unresponsive Timeout!"))
	 || ((time - LastBackgroundHeartbeat > 120) && (reason := "Background Script Timeout!"))
	 || ((time - LastDiscordHeartbeat > 120) && (reason := "Discord Script Timeout!"))
	 || ((time - LastRobloxWindow > 600) && (reason := "No Roblox Window Timeout!"))))

	 || ((MacroState = 1) && (((time - LastMainHeartbeat > 120) && (reason := "Macro Unresponsive Timeout!"))
	 || ((time - LastBackgroundHeartbeat > 120) && (reason := "Background Script Timeout!"))
	 || ((time - LastDiscordHeartbeat > 120) && (reason := "Discord Script Timeout!")))))
	 {
		Prev_MacroState := MacroState, MacroState := 0
		Loop {
			while WinExist("skibi_defense_macro ahk_class AutoHotkey") {
				ProcessClose WinGetPID()
            }
			for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'") {
				ProcessClose p.ProcessID
            }

			ForceStart := (Prev_MacroState = 2)

			Run(path ' "' ForceStart '" "' A_ScriptHwnd '"')

			if (WinWait("Skibi ahk_class AutoHotkeyGUI", , 300) != 0) {
				Sleep 2000
				Send_WM_COPYDATA("Error: " reason "`nSuccessfully restarted macro!", "skibi_defense_macro ahk_class AutoHotkey")
				Sleep 1000
				LastRobloxWindow := LastDiscordHeartbeat := LastMainHeartbeat := LastBackgroundHeartbeat := nowUnix()
				break
			}
		}
	} else {
		switch MacroState {
			case 1:
			LastRobloxWindow += 5

			case 0:
			LastBackgroundHeartbeat += 5
			LastRobloxWindow += 5
		}
	}
	Sleep 5000
}

Send_WM_COPYDATA(StringToSend, TargetScriptTitle, wParam := 0) {
    CopyDataStruct := Buffer(3*A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut("Ptr", SizeInBytes
		, "Ptr", StrPtr(StringToSend)
		, CopyDataStruct, A_PtrSize)

	try {
		s := SendMessage(0x004A, wParam, CopyDataStruct,, TargetScriptTitle)
    } catch {
		return -1
    } else {
		return s
    }
}

sd_SetHeartbeat(wParam, *) {
	global
	Critical
	static arr := ["Main", "Background", "Discord"]
	script := arr[wParam], Last%script%Heartbeat := nowUnix()
}

sd_SetGlobalInt(wParam, lParam, *) {
	global
	Critical
	local var
	; enumeration
	static arr := Map(23, "MacroState")

	var := arr[wParam], %var% := lParam
	return 0
}