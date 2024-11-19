; Hotkey(PauseHotkey, sd_Pause)
sd_Pause(*) {
    Pause
}

Hotkey(StopHotkey, sd_Reload)
sd_Reload(*) {
    Reload()
}

Hotkey(AutoClickerHotkey, sd_AutoClicker, "T2")
sd_AutoClicker(*) {
	global ClickDuration, ClickDelay
	static toggle:=0
	toggle := !toggle

	for var, default in Map("ClickDuration", 50, "ClickDelay", 10)
		if !IsNumber(%var%)
			%var% := default

	while ((ClickMode || (A_Index <= ClickCount)) && toggle) {
		sendinput "{click down}"
		sleep ClickDuration
		sendinput "{click up}"
		sleep ClickDelay
	}
	toggle := 0
}

Hotkey(CloseHotkey, sd_Close)
sd_Close(*) {
    confirmation := MsgBox(LanguageText[1], LanguageText[2], "0x4")
    if confirmation = "Yes" {
        SaveValues()
        ExitApp()
    } else if confirmation = "No" {
        return
    }
}



TapKey(Key, Loops := 1, Delay := 0) {
    Loop Loops {
        Send "{" Key " down}"
		PreciseSleep(Delay)
		Send "{" Key " up}"
    }
}

wait(sec) {
    PreciseSleep(sec * 1000)
}

RunWith32() {
	if (A_PtrSize != 4) {
		SplitPath A_AhkPath, , &ahkDirectory

		if !FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe")
			MsgBox LanguageText[3] "`n" ahkPath, LanguageText[4], 0x10
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
	    MsgBox(LanguageText[5] "`n" LanguageText[6] "`n" LanguageText[7] "`n" LanguageText[8] "`n" LanguageText[9] "`n" LanguageText[10] "`n" LanguageText[11] "`n" LanguageText[12], LanguageText[13], 0x1030)
    }
}

ObjMinIndex(obj)
{
	for k,v in obj
		return k
	return 0
}

LoadLanguages() {
	global
	LanguageText := []
	LanguageFileContent := FileRead(A_MacroWorkingDir "lib\Languages\" Language ".txt")
    Loop Parse LanguageFileContent, "`r`n", "`r`n" {
        (A_LoopField !="" ? LanguageText.Push(A_LoopField) :"")
    }
}

sd_DefaultHandlers(*) {
	global

	if Language = "english" {
		DisplayedLanguage := "English"

		GUIThemeDDLXPos := "x75"
		GUITransparencyTextXPos := "xp+98"
		KeyDelayTextXPos := "x313"
		LanguageTextXPos := "x390"
		ResetSettingsButtonWidth := "w120"
	}
	if Language = "spanish" {
		DisplayedLanguage := "Español"

		GUIThemeDDLXPos := "x100"
		GUITransparencyTextXPos := "xp+120"
		KeyDelayTextXPos := "x340"
		LanguageTextXPos := "x400"
		ResetSettingsButtonWidth := "w120"
	}
	if Language = "turkish" {
		DisplayedLanguage := "Türkçe"

		GUIThemeDDLXPos := "xp+63"
		GUITransparencyTextXPos := "xp+90"
		KeyDelayTextXPos := "xp+100"
		LanguageTextXPos := "x410"
		ResetSettingsButtonWidth := "w120"
		ReconnectMethodLeftButtonXPos := ""
	}
	if Language = "portuguese" {
		DisplayedLanguage := "Português"

		GUIThemeDDLXPos := "x90"
		GUITransparencyTextXPos := "xp+123"
		KeyDelayTextXPos := "x350"
		LanguageTextXPos := "x410"
		ResetSettingsButtonWidth := "w126"
	}
}

GetPSLinkcode() {
	global
	linkCodes := Map()
		for k,v in ["PrivServer"] {
			if (%v% && (StrLen(%v%) > 0)) {
				if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode)
					linkCodes[k] := linkCode[0]
			}
		}
	return linkCodes
}



CreateFolder(folder) {
	if !FileExist(folder) {
        try {
			DirCreate(folder) 
        } catch {
		    MsgBox(LanguageText[14] "`n" LanguageText[15] "`n" LanguageText[16], LanguageText[17], 0x40010)
        }
	}
}

WriteConfig(Data, Dir) {
    if !FileExist(Dir) {
        FileAppend(Data, Dir)
    }
}

sd_WriteGlobalsfromIni() {
	global

	GUI_X := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "GUI_X")
	GUI_Y := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "GUI_Y")
	AlwaysOnTop := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "AlwaysOnTop")
	GUITransparency := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "GUITransparency")
	GUITheme := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "GUITheme")
	KeyDelay := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "KeyDelay")
	MainGUILoadPercent := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "MainGUILoadPercent")
	HotkeyGUILoadPercent := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "HotkeyGUILoadPercent")
	StartHotkey := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "StartHotkey")
	PauseHotkey := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "PauseHotkey")
	StopHotkey := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "StopHotkey")
	AutoClickerHotkey := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "AutoClickerHotkey")
	CloseHotkey := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "CloseHotkey")
	PrivServer := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "PrivServer")
	VID := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "VID")
	Language := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "Language")
	ReconnectMethod := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "ReconnectMethod")
	NeverAsk := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "NeverAsk")
	ClickCount := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "ClickCount")
	ClickDelay := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDelay")
	ClickDuration := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "ClickDuration")
	ClickMode := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "ClickMode")
	ClickButton := IniRead(A_SettingsWorkingDir "main_config.ini", "Settings", "ClickButton")

	SetKeyDelay KeyDelay
}

; Quickly update configurations
sd_UpdateConfigShortcut(GUICtrl, *){
	global
	switch GUICtrl.Type, 0 {
		case "DDL":
		%GUICtrl.Name% := GUICtrl.Text
		default: ; "CheckBox", "Edit", "UpDown", "Slider"
		%GUICtrl.Name% := GUICtrl.Value
	}
	IniWrite(%GUICtrl.Name%, A_SettingsWorkingDir "main_config.ini", GUICtrl.Section, GUICtrl.Name)
}



ImgSearch(imageName, Variation := 10) { ; Uses Gdip_ImageSearch to check if the user is on a GUI
    GetRobloxClientPos(hwnd := GetRobloxHWND())
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
    Gdip_SaveBitmapToFile(pBMScreen, A_MacroWorkingDir "img\bitmap-debugging\" imageName " " FormatTime("YYYYMMDDHH24MISS", "d/M/yyyy HH:mm") ".png") ; See what the image is for debugging purposes
    if (Gdip_ImageSearch(pBMScreen, bitmaps[imageName], , , , , , Variation) = 1) {
        Gdip_DisposeImage(pBMScreen)
		return 1 ; The return value to end with if it was found
   } else {
		Gdip_DisposeImage(pBMScreen)
		return 0 ; The return value to end with if it was not found
   }
}





/*EXTERNAL*/


/*
ShellRun by Lexikos
	requires: AutoHotkey v1.1
	license: http://creativecommons.org/publicdomain/zero/1.0/
Credit for explaining this method goes to BrandonLive:
http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/

Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
;Note might have to use for deeplinking if we have roblox admin issues
ShellRun(prms*)
{
	shellWindows := ComObject("Shell.Application").Windows
	desktop := shellWindows.FindWindowSW(0, 0, 8, 0, 1) ; SWC_DESKTOP, SWFO_NEEDDISPATCH

	; Retrieve top-level browser object.
	tlb := ComObjQuery(desktop,
		"{4C96BE40-915C-11CF-99D3-00AA004AE837}", ; SID_STopLevelBrowser
		"{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser

	; IShellBrowser.QueryActiveShellView -> IShellView
	ComCall(15, tlb, "ptr*", sv := ComValue(13, 0)) ; VT_UNKNOWN

	; Define IID_IDispatch.
	NumPut("int64", 0x20400, "int64", 0x46000000000000C0, IID_IDispatch := Buffer(16))

	; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
	ComCall(15, sv, "uint", 0, "ptr", IID_IDispatch, "ptr*", sfvd := ComValue(9, 0)) ; VT_DISPATCH

	; Get Shell object.
	shell := sfvd.Application

	; IShellDispatch2.ShellExecute
	shell.ShellExecute(prms*)
}

PreciseSleep(ms)
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

PostSubmacroMessage(submacro, args*){
	DetectHiddenWindows 1
	if WinExist(submacro ".ahk ahk_class AutoHotkey")
		try PostMessage(args*)
	DetectHiddenWindows 0
}

sd_RunDiscord(path){
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","discord", "Str","open", "Ptr",cmd.Ptr, "IntP",512),
		DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
	, exe := (pEXE > 0) ? StrGet(pEXE) : ""
	, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""
	, appenabled := (StrLen(exe) > 0)

	Run appenabled ? ('"' exe '" ' StrReplace(params, "%1", "discord://-/" path)) : ('"https://discord.com/' path '"')
}

; close any remnant running scripts
CloseScripts(hb := 0) {
	list := WinGetList("ahk_class AutoHotkey ahk_exe " exe_path32)
	if (exe_path32 != exe_path64) {
		list.Push(WinGetList("ahk_class AutoHotkey ahk_exe " exe_path64)*)
	}
	for hwnd in list {
		if !((hwnd = A_ScriptHwnd) || ((hb = 1) && A_Args.Has(2) && (hwnd = A_Args[2]))) {
			try {
				WinClose "ahk_id " hwnd
			}
		}
	}
}