OnExit(SaveValues)
TraySetIcon(A_MacroWorkingDir "img\sdm-logo.ico", Freeze := true)
A_TrayMenu.Delete()
A_TrayMenu.Add()
A_TrayMenu.Add("Open Logs", (*) => ListLines())
A_TrayMenu.Add()
A_TrayMenu.Add("Edit This Script", (*) => Edit())
A_TrayMenu.Add("Suspend Hotkeys", (*) => (A_TrayMenu.ToggleCheck("Suspend Hotkeys"), Suspend()))
A_TrayMenu.Add()
A_TrayMenu.Add()
A_TrayMenu.Add("Start Macro", sd_Start)
A_TrayMenu.Add("Pause Macro", sd_Pause)
A_TrayMenu.Add("Stop Macro", sd_Reload)
A_TrayMenu.Add()
A_TrayMenu.Add("Close Macro", sd_Close)
A_TrayMenu.Add()
A_TrayMenu.Default := "Start Macro"

global AlwaysOnTop := IniRead(SettingsPath "main-config.ini", "Settings", "AlwaysOnTop")
global GUITransparency := IniRead(SettingsPath "main-config.ini", "Settings", "GUITransparency")
global MainGUILoadProgress := IniRead(SettingsPath "main-config.ini", "Settings", "MainGUILoadPercent")
global HotkeyGUILoadProgress := IniRead(SettingsPath "main-config.ini", "Settings", "HotkeyGUILoadPercent")
global GUI_X := IniRead(SettingsPath "main-config.ini", "Settings", "GUI_X")
global GUI_Y := IniRead(SettingsPath "main-config.ini", "Settings", "GUI_Y")
global StartHotkey := IniRead(SettingsPath "main-config.ini", "Settings", "StartHotkey")
global StartHotkeyRef := StartHotkey
global PauseHotkey := IniRead(SettingsPath "main-config.ini", "Settings", "PauseHotkey")
global StopHotkey := IniRead(SettingsPath "main-config.ini", "Settings", "StopHotkey")
global CloseHotkey := IniRead(SettingsPath "main-config.ini", "Settings", "CloseHotkey")



MainGUI := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", "Skibi Defense Macro (Loading: 0%)")
WinSetTransparent 255-floor(GUITransparency*2.55), MainGUI
MainGUI.Show("x" GUI_X " y" GUI_Y " w500 h300"), SetLoadProgress(3, MainGUI, "Skibi Defense Macro", "MainGUI")
DefaultTabs := ["Settings"]
AllTabs := defaultTabs.Clone(), SetLoadProgress(6, MainGUI, "Skibi Defense Macro", "MainGUI")
TabCtrl := MainGUI.Add("Tab3", "x0 y0 w500 h300", AllTabs), SetLoadProgress(9, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.OnEvent("Close", sd_Close)
MainGUI.AddText("x7 y285 +BackgroundTrans", VerNum), SetLoadProgress(12, MainGUI, "Skibi Defense Macro", "MainGUI")
DiscordHBitmap := Gdip_CreateHBITMAPFromBitmap(bitmaps["DiscordIcon"])
DiscordButton := MainGUI.AddPicture("x440 y270 w25 h25 +BackgroundTrans"), SetLoadProgress(15, MainGUI, "Skibi Defense Macro", "MainGUI")
DiscordButton.Value := "HBITMAP:" DiscordHBitmap
DiscordButton.OnEvent("Click", ShowDiscordUser)
GitHubHBitmap := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"])
GitHubButton := MainGUI.AddPicture("x470 y270 w25 h25 +BackgroundTrans"), SetLoadProgress(18, MainGUI, "Skibi Defense Macro", "MainGUI")
GitHubButton.Value := "HBITMAP:" GitHubHBitmap
GitHubButton.OnEvent("Click", OpenGitHub)
MainGUI.AddButton("x15 y260 w65 h20 -Wrap vStartButton", " Start (" StartHotkey ")").OnEvent("Click", sd_Start), SetLoadProgress(21, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddButton("x85 y260 w65 h20 -Wrap vPauseButton", " Pause (" PauseHotkey ")").OnEvent("Click", sd_Pause), SetLoadProgress(24, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddButton("x155 y260 w65 h20 -Wrap vStopButton", " Stop (" StopHotkey ")").OnEvent("Click", sd_Reload), SetLoadProgress(27, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddButton("x225 y260 w65 h20 -Wrap vCloseButton", " Close (" CloseHotkey ")").OnEvent("Click", sd_Close), SetLoadProgress(30, MainGUI, "Skibi Defense Macro", "MainGUI")



TabCtrl.UseTab("Settings"), SetLoadProgress(33, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.SetFont("s8 cDefault Bold", "Tahoma")
MainGUI.AddGroupBox("x10 y25 w200 h100 +BackgroundTrans", "GUI Settings"), SetLoadProgress(36, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddGroupBox("x10 y130 w200 h100 +BackgroundTrans", "Hotkey Settings"), SetLoadProgress(39, MainGUI, "Skibi Defense Macro", "MainGUI")

MainGUI.SetFont("Norm")
MainGUI.AddCheckBox("x15 y40 vAlwaysOnTop" AlwaysOnTop, "Always On Top").OnEvent("Click", sd_AlwaysOnTop), SetLoadProgress(42, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddText("x15 y57 w100 +BackgroundTrans", "GUI Transparency:"), SetLoadProgress(45, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddText("x104 y57 w20 +Center +BackgroundTrans vGUITransparency", GUITransparency), SetLoadProgress(48, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddUpDown("xp+22 yp-1 h16 -16 Range0-14 vGUITransparencyUpDown", GUITransparency//5).OnEvent("Change", sd_GUITransparency), SetLoadProgress(51, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddButton("x15 y155 w150 h20 vHotkeyGUI", "Change Hotkeys").OnEvent("Click", sd_HotkeyGUI), SetLoadProgress(54, MainGUI, "Skibi Defense Macro", "MainGUI")
MainGUI.AddButton("x20 yp+24 w140 h20", "Restore Defaults").OnEvent("Click", sd_ResetHotkeys)
wait(1)
SetLoadProgress(100, MainGUI, "Skibi Defense Macro", "MainGUI")



SetLoadProgress(percent, GUICtrl, Title1, SavePlace, Title2 := Title1) {
    if percent < 100 {
        GUICtrl.Opt("+Disabled")
        GUICtrl.Title := Title1 " (Loading: " Round(percent) "%)"
    } else if percent = 100 {
        GUICtrl.Title := Title2
        GUICtrl.Opt("-Disabled")
        GUICtrl.Flash
    }
    if percent > 100 {
        throw ValueError("'Load Progress' exceeds max value of 100", -2)
    }
    global LoadPercent := "" percent ""
    IniWrite(LoadPercent, SettingsPath "main-config.ini", "Settings", SavePlace "LoadPercent")
}

sd_AlwaysOnTop(*){
	global
	IniWrite((AlwaysOnTop := MainGUI["AlwaysOnTop"].Value), SettingsPath "main-config.ini", "Settings", "AlwaysOnTop")
	MainGUI.Opt((AlwaysOnTop ? "+" : "-") "AlwaysOnTop")
    if AlwaysOnTop = 1 {
        global AlwaysOnTop := "+AlwaysOnTop "
    }
}

sd_GUITransparency(*){
	global GUITransparency
	MainGUI["GUITransparency"].Text := GUITransparency := MainGUI["GUITransparencyUpDown"].Value * 5
	IniWrite(GUITransparency, SettingsPath "main-config.ini", "Settings", "GUITransparency")
	WinSetTransparent 255-floor(GUITransparency*2.55), MainGUI
}

sd_HotkeyGUI(*){
	global
	GUIClose(*){
        MainGUI.Opt("-Disabled")
		if (IsSet(HotkeyGUI) && IsObject(HotkeyGUI)) {
			HotkeyGUI.Destroy(), HotkeyGUI := ""
            Hotkey StartHotkey, sd_Start, "On"
            Hotkey PauseHotkey, sd_Pause, "On"
            Hotkey StopHotkey, sd_Reload, "On"
            Hotkey CloseHotkey, sd_Close, "On"
            sd_Reload
        }
	}
	GUIClose()
    Hotkey StartHotkey, sd_Start, "Off"
	Hotkey PauseHotkey, sd_Pause, "Off"
	Hotkey StopHotkey, sd_Reload, "Off"
    Hotkey CloseHotkey, sd_Close, "Off"
	HotkeyGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Hotkeys")
    MainGUI.Opt("+Disabled")
    HotkeyGUI.Show("w190 h175"), SetLoadProgress(10, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w190 h144", "Change Hotkeys"), SetLoadProgress(20, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y23 w60 +BackgroundTrans", "Start:"), SetLoadProgress(30, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+19 w60 +BackgroundTrans", "Pause:"), SetLoadProgress(40, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+19 w60 +BackgroundTrans", "Stop:"), SetLoadProgress(50, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddText("x10 yp+19 w60 +BackgroundTrans", "Close:"), SetLoadProgress(60, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 y20 w120 h18 vStartHotkeyEdit", StartHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(70, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+19 w120 h18 vPauseHotkeyEdit", PauseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(80, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+19 w120 h18 vStopHotkeyEdit", StopHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(90, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddHotkey("x70 yp+19 w120 h18 vCloseHotkeyEdit", CloseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(100, HotkeyGUI, "Hotkeys", "HotkeyGUI")
}

sd_saveHotkey(GuiCtrl, *){
	global
	local k, v, l, StartHotkeyEdit, PauseHotkeyEdit, StopHotkeyEdit, CloseHotkeyEdit
	k := GuiCtrl.Name, %k% := GuiCtrl.Value

	v := StrReplace(k, "Edit")
	if !(%k% ~= "^[!^+]+$")
	{
		; do not allow necessary keys
        OnError (e, mode) => (mode = "Return") ? -1 : 0
		switch Format("sc{:03X}", GetKeySC(%k%)), 0
		{
			case W,A,S,D,I,O,E,E,L,Escape,Enter,LShift,RShift,Space:
			GuiCtrl.Value := %v%
			MsgBox "That hotkey cannot be used!`nThe key is already used elsewhere in the macro.", "Unacceptable Hotkey!", 0x1030
			return

			case Zero,One,Two,Three,Four,Five,Six,Seven, Eight, Nine:
			GuiCtrl.Value := %v%
			MsgBox "That hotkey cannot be used!`nIt will be required to use your units.", "Unacceptable Hotkey!", 0x1030
			return
		}

		if ((StrLen(%k%) = 0) || (%k% = StartHotkey) || (%k% = PauseHotkey) || (%k% = StopHotkey) || (%k% = CloseHotkey) ) { ; do not allow empty or already used hotkey (not necessary in most cases)
			GuiCtrl.Value := %v%
            MsgBox("That hotkey cannot be used!`nThe key is already used as a different hotkey.", "Unacceptable Hotkey!", 0x1030)
            return
        }
		else ; update the hotkey
		{
			l := StrReplace(v, "Hotkey")
			try Hotkey %v%, (l = "Pause") ? sd_Pause : %l%, "Off"
			IniWrite (%v% := %k%), SettingsPath "main-config.ini", "Settings", v
		}
	}
}

sd_ResetHotkeys(*){
	global
	try {
        sd_HotkeyGUI
		Suspend(1)
	}
	IniWrite((StartHotkey := "F1"), SettingsPath "main-config.ini", "Settings", "StartHotkey")
	IniWrite((PauseHotkey := "F2"), SettingsPath "main-config.ini", "Settings", "PauseHotkey")
	IniWrite((StopHotkey := "F3"), SettingsPath "main-config.ini", "Settings", "StopHotkey")
    IniWrite((CloseHotkey:= "F4"), SettingsPath "main-config.ini", "Settings", "CloseHotkey")
	HotkeyGUI["StartHotkeyEdit"].Value := "F1"
	HotkeyGUI["PauseHotkeyEdit"].Value := "F2"
	HotkeyGUI["StopHotkeyEdit"].Value := "F3"
    HotkeyGUI["CloseHotkeyEdit"].Value := "F4"
	MainGUI["StartButton"].Text := " Start (F1)"
	MainGUI["PauseButton"].Text := " Pause (F2)"
	MainGUI["StopButton"].Text := " Stop (F3)"
    MainGUI["CloseButton"].Text := " Close (F4)"
	try {
		Suspend(0)
	}
}

SaveGUIPos() {
	wp := Buffer(44)
	DllCall("GetWindowPlacement", "UInt", MainGUI.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int")
    y := NumGet(wp, 32, "Int")
	if (x > 0)  {
		IniWrite(x, SettingsPath "main-config.ini", "Settings", "GUI_X")
    }
	if (y > 0)  {
		IniWrite(y, SettingsPath "main-config.ini", "Settings", "GUI_Y")
    }
}

SaveValues(*) {
    SaveGUIPos()
    ExitApp
}

ShowDiscordUser(*) {
    Run "https://discordapp.com/users/1198320993958117458"
}

OpenGitHub(*) {
    Run "https://github.com/NegativeZero01/skibi-defense-macro"
}