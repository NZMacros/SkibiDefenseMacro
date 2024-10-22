; Hotkey(PauseHotkey, sd_Pause)
sd_Pause(*) {
    Pause
}

Hotkey(StopHotkey, sd_Reload)
sd_Reload(*) {
	wait(1.5)
    Reload
}

Hotkey(CloseHotkey, sd_Close)
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
    HyperSleep(sec * 1000)
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

CheckDisplaySpecs() {
    hwnd := GetRobloxHWND()
	ActivateRoblox()
	GetRobloxClientPos(hwnd)
	/*offsetY := GetYOffset(hwnd, &offsetfail)
	if (offsetfail = 1) {
		MsgBox "Unable to detect in-game GUI offset!`nStopping Feeder!`n`nThere are a few reasons why this can happen:`n - Incorrect graphics settings (check Troubleshooting Guide!)``n - Your `'Experience Language`' is not set to English``n - Something is covering the top of your Roblox window``n``nJoin our Discord server for support!", "WARNING!!", "0x40030"
		ExitApp
	}*/
	if A_ScreenDPI != 96 {
	    MsgBox("Your display scale is not 100%!`nThis means the Macro will not be able to detect images in-game correctly, resulting in failure!`nTo fix this, follow these steps:`n - Open Settings (Win+I)`n - Navigate to System >> Display`n - Then set the scale to 100% (even if it isn't recommended for your device)`n - Restart the Macro and ROBLOX`n - Sign out if prompted to", "Warning", 0x1030)
    }
}

ObjMinIndex(obj)
{
	for k,v in obj
		return k
	return 0
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



ImgSearch(imageName, Variation := 6) {
    GetRobloxClientPos(hwnd := GetRobloxHWND())
	; offsetY := GetYOffset(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30))
    Gdip_SaveBitmapToFile(pBMScreen, A_MacroWorkingDir "img\bitmap-debugging\" imageName ".jpg") ; See what the image is for debugging purposes
    if (Gdip_ImageSearch(pBMScreen, bitmaps[imageName], , , , , , Variation) = 1) {
         Gdip_DisposeImage(pBMScreen)
         return 1 ; The return value to end with if it was found
    }
    Gdip_DisposeImage(pBMScreen)
    return 0 ; The return value to end with if it was not found
}