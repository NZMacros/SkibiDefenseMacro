f2:: sd_Pause()
sd_Pause(*) {
    MsgBox "Hi"
}

f3:: sd_Reload()
sd_Reload(*) {
    wait(2.5)
    Reload
}

f4:: sd_Close()
sd_Close(*) {
    confirmation := MsgBox("Close Macro?", "Closing Macro", "0x4")
    if confirmation = "Yes" {
        SaveValues()
        wait(2.5)
        ExitApp
    } else if confirmation = "No" {
        return
    }
}



TapKey(Key, Loops := 1) {
    Loop Loops {
        Send "{" Key " down}" "{" Key " up}"
    }
}

HyperSleep(ms)
{
	static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
	DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
	current := 0, finish := begin + ms * freq / 1000
	while (current < finish)
	{
		if ((finish - current) > 30000)
		{
			DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
			DllCall("Sleep", "UInt", 1)
			DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
		}
		DllCall("QueryPerformanceCounter", "Int64*", &current)
	}
}

wait(sec) {
    Sleep(sec * 1000)
}

RunWith32() {
	if (A_PtrSize != 4) {
		SplitPath A_AhkPath, , &ahkDirectory

		if !FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe")
			MsgBox "Couldn't find the 32-bit version of Autohotkey in:`n" ahkPath, "Error", 0x10
		else
			AHKReloadScript(ahkpath)

		ExitApp
	}
}

AHKReloadScript(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run '"' ahkpath '" /restart ' params
}



CreateFolder(folder) {
	if !FileExist(folder) {
        try {
			DirCreate(folder) 
        } catch {
		    MsgBox("Could not create the " folder " directory!`nThis means the Macro will not be able to use the functions of the files usually in this folder!`nTry moving the Macro to a different folder (e.g. Downloads or Documents).", "Failed to Create Folder", 0x40010)
        }
	}
}

ImportConfig(Data, Dir) {
    if !FileExist(Dir) {
        FileAppend(Data, Dir)
    }
}