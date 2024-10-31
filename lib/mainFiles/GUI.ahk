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

global AlwaysOnTop := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "AlwaysOnTop")
global GUITransparency := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "GUITransparency")
global MainGUILoadProgress := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "MainGUILoadPercent")
global HotkeyGUILoadProgress := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "HotkeyGUILoadPercent")
global GUI_X := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "GUI_X")
global GUI_Y := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "GUI_Y")
global StartHotkey := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "StartHotkey")
global StartHotkeyRef := StartHotkey
global PauseHotkey := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "PauseHotkey")
global StopHotkey := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "StopHotkey")
global CloseHotkey := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "CloseHotkey")
global GUITheme := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "GUITheme")
global KeyDelay := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "KeyDelay")
global PrivServer := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "PrivServer")
global Fallback := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "Fallback")
global AGC_InputtedUnlockCode := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "AGCIUC")
global AGC_UnlockCodeAnswer := Random(100000, 999999)

global AGC_Unlocked := IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "AGCU")
if AGC_Unlocked := 1 {
	MainGUI["AdvancedGUICustomisation"].Enabled := 1
}

SetKeyDelay KeyDelay

DllCall(DllCall("GetProcAddress"
		, "Ptr",DllCall("LoadLibrary", "Str", A_MacroWorkingDir "lib\Themes\USkin.dll")
		, "AStr","USkinInit", "Ptr")
	, "Int",0, "Int",0, "AStr", A_MacroWorkingDir "lib\Themes\" GUITheme ".msstyles")

;ensure Gui will be visible
if (GuiX && GuiY)
{
	Loop (MonitorCount := MonitorGetCount())
	{
		MonitorGetWorkArea A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom
		if(GuiX>MonLeft && GuiX<MonRight && GuiY>MonTop && GuiY<MonBottom)
			break
		if(A_Index=MonitorCount)
			guiX:=guiY:=0
	}
}
else
	guiX:=guiY:=0



MainGUI := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", "Skibi Defense Macro (Loading: 0%)")
WinSetTransparent 255-floor(GUITransparency*2.55), MainGUI
MainGUI.Show("x" GUI_X " y" GUI_Y " w500 h300")
MainGUI.OnEvent("Close", sd_Close)
MainGUI.AddText("x7 y285 +BackgroundTrans", VersionID)
DiscordHBitmap := Gdip_CreateHBITMAPFromBitmap(bitmaps["DiscordIcon"])
DiscordButton := MainGUI.AddPicture("x440 y270 w25 h25 +BackgroundTrans vDiscordButton Disabled")
DiscordButton.Value := "HBITMAP:" DiscordHBitmap
DiscordButton.OnEvent("Click", OpenDisord)
GitHubHBitmap := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"])
GitHubButton := MainGUI.AddPicture("x470 y270 w25 h25 +BackgroundTrans vGitHubButton Disabled")
GitHubButton.Value := "HBITMAP:" GitHubHBitmap
GitHubButton.OnEvent("Click", OpenGitHub)
MainGUI.AddButton("x10 y265 w65 h20 -Wrap vStartButton Disabled", " Start (" StartHotkey ")").OnEvent("Click", sd_Start)
MainGUI.AddButton("x80 y265 w65 h20 -Wrap vPauseButton Disabled", " Pause (" PauseHotkey ")").OnEvent("Click", sd_Pause)
MainGUI.AddButton("x150 y265 w65 h20 -Wrap vStopButton Disabled", " Stop (" StopHotkey ")").OnEvent("Click", sd_Reload)
MainGUI.AddButton("x220 y265 w65 h20 -Wrap vCloseButton Disabled", " Close (" CloseHotkey ")").OnEvent("Click", sd_Close)
TabArr := ["Settings","Credits"] ;, (Code = 467854) && TabArr.Push("Advanced")
(TabCtrl := MainGui.Add("Tab", "x0 y-1 w500 h250 -Wrap", TabArr)).OnEvent("Change", (*) => TabCtrl.Focus())



TabCtrl.UseTab("Settings")
MainGUI.SetFont("s8 cDefault Bold", "Tahoma")
MainGUI.AddGroupBox("x10 y25 w200 h100 +BackgroundTrans", "GUI Settings")
MainGUI.AddGroupBox("x10 y130 w200 h100 +BackgroundTrans", "Hotkey Settings")
MainGUI.AddGroupBox("x220 y25 w270 h70 +BackgroundTrans", "General Settings")
MainGUI.AddGroupBox("x220 y100 w270 h100 +BackgroundTrans", "Reconnect Settings")

MainGUI.SetFont("Norm")
MainGUI.AddText("x15 y80 w70 +BackgroundTrans", "GUI Theme:")
ThemesList := []
Loop Files A_ThemesWorkingDir "*.msstyles" {
	ThemesList.Push(StrReplace(A_LoopFileName, ".msstyles"))
}
(ThemesEdit := MainGui.AddDropDownList("x80 y76 w72 h100 vGUITheme Disabled", ThemesList)).Text := GUITheme, ThemesEdit.OnEvent("Change", sd_GUITheme)
MainGui.AddCheckbox("x15 y40 vAlwaysOnTop Disabled Checked" AlwaysOnTop, "Always On Top").OnEvent("Click", sd_AlwaysOnTop)
MainGUI.AddText("x15 y57 w100 +BackgroundTrans", "GUI Transparency:")
MainGUI.AddText("x104 y57 w20 +Center +BackgroundTrans vGUITransparency", GUITransparency)
MainGUI.AddUpDown("xp+24 yp-1 h16 -16 Range0-14 vGUITransparencyUpDown Disabled", GUITransparency//5).OnEvent("Change", sd_GUITransparency)
MainGUI.AddButton("x14 y100 w150 h20 vAdvancedGUICustomisation Disabled", "Advanced Customisation").OnEvent("Click", sd_AdvancedCustomisation)
MainGUI.AddButton("x15 y155 w150 h20 vHotkeyGUI Disabled", "Change Hotkeys").OnEvent("Click", sd_HotkeyGUI)
MainGUI.AddButton("x16 yp+24 w150 h20 vAutoclickerGUI Disabled", "Autoclicker Settings")
MainGUI.AddButton("x20 yp+24 w140 h20 vHotkeyRestore Disabled", "Restore Defaults").OnEvent("Click", sd_ResetHotkeys)
MainGUI.AddText("x225 y41 w100 +BackgroundTrans", "Input Delay (ms):")
MainGUI.AddText("x305 y39 w47 h18 0x201")
MainGUI.AddUpDown("Range0-9999 vKeyDelay Disabled", KeyDelay).OnEvent("Change", sd_SaveKeyDelay)
MainGUI.AddButton("x227 yp+27 w120 h20 vSettingsRestore Disabled", "Reset Settings").OnEvent("Click", sd_ResetSettings)
MainGUI.AddButton("x400 y97 w30 h20 vReconnectTest Disabled", "Test").OnEvent("Click", sd_ReconnectTest)
MainGUI.AddText("x230 y125 +BackgroundTrans", "Private Server Link:")
MainGUI.AddEdit("x230 y150 w250 h20 vPrivServer Lowercase Disabled", PrivServer).OnEvent("Change", sd_ServerLink)
MainGui.AddCheckbox("x230 y180 vFallback Disabled Checked" Fallback, "Fallback to Public Server").OnEvent("Click", sd_Fallback)
MainGUI.AddButton("x390 y177 w20 h20 vFallbackHelp Disabled", "?").OnEvent("Click", sd_FallbackHelp)
MainGUI.AddText("x230 y210 +BackgroundTrans", "Code:")
MainGUI.AddEdit("x270 y207 w70 h20 vCode Number Limit6", Code).OnEvent("Change", sd_Code)
if (IniRead(A_SettingsWorkingDir "main-config.ini", "Settings", "SecretTab") = 1) {
	; MainGUI["AdvancedGUICustomisation"].Enabled := 1
}

TabCtrl.UseTab("Credits")
; aaaaaaaaaaaaaaaa
wait(1)
SetLoadProgress(100, MainGUI, "Skibi Defense Macro", "MainGUI")



SetLoadProgress(percent, GUICtrl, Title1, SavePlace, Title2 := Title1) {
    if percent < 100 {
        GUICtrl.Opt("+Disabled")
		if SavePlace = "MainGUI" {
			sd_MainTabsChange(0)
		}
		if SavePlace = "HotkeyGUI" {
			sd_HotkeyGUIChange(0)
		}
        GUICtrl.Title := Title1 " (Loading: " Round(percent) "%)"
    } else if percent = 100 {
        GUICtrl.Title := Title2
        GUICtrl.Opt("-Disabled")
		if SavePlace = "MainGUI" {
			sd_MainTabsChange(1)
		} if SavePlace = "HotkeyGUI" {
			sd_HotkeyGUIChange(1)
		}
        GUICtrl.Flash
		if Rudeness = 1 {
			MsgBox("I hate you!!!", "KYS", 0x1030)
			ExitApp
		}
    }
    if percent > 100 {
        throw ValueError("'Load Progress' exceeds max value of 100", -2)
    }
    global LoadPercent := "" percent ""
    IniWrite(LoadPercent, A_SettingsWorkingDir "main-config.ini", "Settings", SavePlace "LoadPercent")
}

sd_AlwaysOnTop(*){
	global
	IniWrite (AlwaysOnTop := MainGui["AlwaysOnTop"].Value), A_SettingsWorkingDir "main-config.ini", "Settings", "AlwaysOnTop"
	MainGui.Opt((AlwaysOnTop ? "+" : "-") "AlwaysOnTop")
}

sd_GUITransparency(*){
	global GUITransparency
	MainGUI["GUITransparency"].Text := GUITransparency := MainGUI["GUITransparencyUpDown"].Value * 5
	IniWrite(GUITransparency, A_SettingsWorkingDir "main-config.ini", "Settings", "GUITransparency")
	WinSetTransparent 255-floor(GUITransparency*2.55), MainGUI
}

sd_SaveKeyDelay(*){
	global
	KeyDelay := MainGUI["KeyDelay"].Value
	IniWrite(KeyDelay, A_SettingsWorkingDir "main-config.ini", "Settings", "KeyDelay")
}

sd_MainTabsChange(value) {
	MainGUI["DiscordButton"].Enabled := value
	MainGUI["GitHubButton"].Enabled := value
	MainGUI["StartButton"].Enabled := value
	; MainGUI["PauseButton"].Enabled := value
	MainGUI["StopButton"].Enabled := value
	MainGUI["CloseButton"].Enabled := value
	MainGUI["AlwaysOnTop"].Enabled := value
	MainGUI["GUITransparencyUpDown"].Enabled := value
	MainGUI["HotkeyGUI"].Enabled := value
	MainGUI["HotkeyRestore"].Enabled := value
	MainGUI["GUITheme"].Enabled := value
	; MainGUI["AutoclickerGUI"].Enabled := value
	MainGUI["KeyDelay"].Enabled := value
	MainGUI["SettingsRestore"].Enabled := value
	MainGUI["ReconnectTest"].Enabled := value
	MainGUI["PrivServer"].Enabled := value
	MainGUI["Fallback"].Enabled := value
	MainGUI["FallbackHelp"].Enabled := value
}

sd_HotkeyGUIChange(value) {
	OnError (e, mode) => (mode = "Return") ? -1 : 0
	HotkeyGUI["StartHotkeyEdit"].Enabled := value
	; HotkeyGUI["PauseHotkeyEdit"].Enabled := value
	HotkeyGUI["StopHotkeyEdit"].Enabled := value
	HotkeyGUI["CloseHotkeyEdit"].Enabled := value
}

sd_HotkeyGUI(*){
	global
	GUIClose(*){
		MainGUI.Opt("-Disabled"), sd_MainTabsChange(1)
		if (IsSet(HotkeyGUI) && IsObject(HotkeyGUI)) {
			Suspend(0)
			HotkeyGUI.Destroy(), HotkeyGUI := ""
            sd_Reload
        }
	}
	GUIClose()
    Suspend(1)
	HotkeyGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Hotkeys")
    MainGUI.Opt("+Disabled"), sd_MainTabsChange(0)
    HotkeyGUI.Show("w300 h200"), SetLoadProgress(10, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w290 h190", "Change Hotkeys"), SetLoadProgress(20, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y30 w60 +BackgroundTrans", "Start:"), SetLoadProgress(30, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Pause:"), SetLoadProgress(40, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Stop:"), SetLoadProgress(50, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Close:"), SetLoadProgress(60, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 y30 w200 h18 vStartHotkeyEdit Disabled", StartHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(70, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vPauseHotkeyEdit Disabled", PauseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(80, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vStopHotkeyEdit Disabled", StopHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(90, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vCloseHotkeyEdit Disabled", CloseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(100, HotkeyGUI, "Hotkeys", "HotkeyGUI")
}

sd_SaveHotkey(GuiCtrl, *){
	global
	local k, v, l, StartHotkeyEdit, PauseHotkeyEdit, StopHotkeyEdit, CloseHotkeyEdit
	k := GuiCtrl.Name, %k% := GuiCtrl.Value

	v := StrReplace(k, "Edit")
	if !(%k% ~= "^[!^+]+$")
	{
		; do not allow necessary keys
		switch Format("sc{:03X}", GetKeySC(%k%)), 0
		{
			case W,A,S,D,I,O,E,R,"sc026",Escape,Enter,LShift,RShift,Space:
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
			IniWrite (%v% := %k%), A_SettingsWorkingDir "main-config.ini", "Settings", v
		}
	}
}

sd_ResetHotkeys(*){
	global
	sd_HotkeyGUI
	HotkeyGUI.Hide
	try Suspend(1)
	IniWrite((StartHotkey := "F1"), A_SettingsWorkingDir "main-config.ini", "Settings", "StartHotkey")
	IniWrite((PauseHotkey := "F2"), A_SettingsWorkingDir "main-config.ini", "Settings", "PauseHotkey")
	IniWrite((StopHotkey := "F3"), A_SettingsWorkingDir "main-config.ini", "Settings", "StopHotkey")
    IniWrite((CloseHotkey:= "F4"), A_SettingsWorkingDir "main-config.ini", "Settings", "CloseHotkey")
	HotkeyGUI["StartHotkeyEdit"].Value := "F1"
	HotkeyGUI["PauseHotkeyEdit"].Value := "F2"
	HotkeyGUI["StopHotkeyEdit"].Value := "F3"
    HotkeyGUI["CloseHotkeyEdit"].Value := "F4"
	MainGUI["StartButton"].Text := " Start (F1)"
	MainGUI["PauseButton"].Text := " Pause (F2)"
	MainGUI["StopButton"].Text := " Stop (F3)"
    MainGUI["CloseButton"].Text := " Close (F4)"
	HotkeyGUI.Destroy
	sd_Reload()
	try Suspend(0)
}

sd_ResetSettings(*) {
	global
	confirmation := MsgBox("Are you sure you would like to reset your settings to the default?`nAny configurations you've made will be wiped and replaced with original values.", "Confirm Reset", 0x1 0x1030)
	if confirmation := "OK" {
	IniWrite((AlwaysOnTop := 0), A_SettingsWorkingDir "main-config.ini", "Settings", "AlwaysOnTop")
	IniWrite((GUITransparency := 0), A_SettingsWorkingDir "main-config.ini", "Settings", "GUITransparency")
	IniWrite((GUITheme := "None"), A_SettingsWorkingDir "main-config.ini", "Settings", "GUITheme")
	IniWrite((KeyDelay := 25), A_SettingsWorkingDir "main-config.ini", "Settings", "KeyDelay")
	MainGUI["AlwaysOnTop"].Value = "-AlwaysOnTop"
	MainGUI["GUITransparency"].Value = "0"
	MainGUI["GUITheme"].Value = "None"
	MainGUI["KeyDelay"].Value = "25"
	sd_ResetHotkeys
	} else if confirmation = "Cancel" {
		return
	}
}

sd_Fallback(*) {
	global
	Fallback := MainGUI["Fallback"].Value
	IniWrite(Fallback, A_SettingsWorkingDir "main-config.ini", "Settings", "Fallback")
}

sd_FallbackHelp(*) {
	MsgBox("Fallback works as an emergency rejoin if the Macro fails to rejoin your PS.`nIt will automatically join a public server to continue Macroing after 3 failed join attempts.", "Fallback to Public Server", 0x40)
}

sd_GUITheme(*) {
	global
	GUITheme := MainGui["GUITheme"].Text
	IniWrite(GUITheme, A_SettingsWorkingDir "main-config.ini", "Settings", "GUITheme")
	sd_Reload()
	wait(10)
}

sd_ReconnectTest(*){
	MainGUI.Minimize
	MainGUI.Opt("+Disabled"), sd_MainTabsChange(0)
	if (ActivateRoblox() = 1) {
		CloseRoblox()
	}
	if (DisconnectCheck(1) = 2)
		MsgBox("Successfully rejoined via Deeplink!", "Reconnect Test Complete", 0x1000)
	MainGUI.Restore
	MainGUI.Opt("-Disabled"), sd_MainTabsChange(1)
}

sd_ServerLink(GuiCtrl, *){
	global PrivServer
	p := EditGetCurrentCol(GuiCtrl)
	k := GuiCtrl.Name
	str := GuiCtrl.Value

	RegExMatch(str, "i)((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/14279693118\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*", &NewPrivServer)
	if ((StrLen(str) > 0) && !IsObject(NewPrivServer))
	{
		OnError (e, mode) => (mode = "Return") ? -1 : 0
		GuiCtrl.Value := %k%
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		if InStr(str, "/share?code")
			sd_ShowErrorBalloon(GuiCtrl, "Unresolved Private Server Link", "
				(
				You entered a 'share?code' link!
				To fix this:
				 1. Paste this link into your browser
				 2. Wait for Skibi Defense to load
				 3. Copy the link at the top of your browser.
				)")
		else
			sd_ShowErrorBalloon(GuiCtrl, "Invalid Private Server Link", "Make sure your link is:`r`n- Copied correctly and completely`r`n- For Skibi Defense by Archkos")
	}
	else
	{
		GuiCtrl.Value := %k% := IsObject(NewPrivServer) ? NewPrivServer[0] : ""
		IniWrite(%k%, A_SettingsWorkingDir "main-config.ini", "Settings", "PrivServer")

		; if (k = "PrivServer")
			; PostSubmacroMessage("Status", 0x5553, 10, 6)*/
	}
}

sd_ShowErrorBalloon(Ctrl, Title, Text){
	EBT := Buffer(4 * A_PtrSize, 0)
	NumPut("UInt", 4 * A_PtrSize
		, "Ptr", StrPtr(Title)
		, "Ptr", StrPtr(Text)
		, "UInt", 3, EBT)
	DllCall("SendMessage", "UPtr", Ctrl.Hwnd, "UInt", 0x1503, "Ptr", 0, "Ptr", EBT.Ptr, "Ptr")
}

SaveGUIPos() {
	wp := Buffer(44)
	DllCall("GetWindowPlacement", "UInt", MainGUI.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int")
    y := NumGet(wp, 32, "Int")
	if (x > 0)  {
		IniWrite(x, A_SettingsWorkingDir "main-config.ini", "Settings", "GUI_X")
    }
	if (y > 0)  {
		IniWrite(y, A_SettingsWorkingDir "main-config.ini", "Settings", "GUI_Y")
    }
}

SaveValues(*) {
    SaveGUIPos()
	DllCall(A_MacroWorkingDir "lib\Themes\USkin.dll\USkinExit")
	try Gdip_Shutdown(pToken)
    ExitApp
}

OpenDisord(*) {
    Run "https://discordapp.com/users/1198320993958117458"
}

OpenGitHub(*) {
    Run "https://github.com/NegativeZero01/skibi-defense-macro"
}

sd_AdvancedCustomisation(*) {
	global
	GUIClose(*){
		MainGUI.Opt("-Disabled"), sd_MainTabsChange(1)
		if (IsSet(AdvancedGUI) && IsObject(AdvancedGUI)) {
			AdvancedGUI.Destroy(), AdvancedGUI := ""
            Suspend(0)
            sd_Reload
        }
	}
	GUIClose()
    Suspend(1)
	AdvancedGUI := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGUI.Hwnd, "Advanced Customisation")
    MainGUI.Opt("+Disabled"), sd_MainTabsChange(0)
    AdvancedGUI.Show("w300 h200"), SetLoadProgress(10, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	/*HotkeyGUI.OnEvent("Close", GUIClose)
	HotkeyGUI.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGUI.AddGroupBox("x5 y2 w290 h190", "Change Hotkeys"), SetLoadProgress(20, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.SetFont("Norm")
	HotkeyGUI.AddText("x10 y30 w60 +BackgroundTrans", "Start:"), SetLoadProgress(30, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Pause:"), SetLoadProgress(40, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Stop:"), SetLoadProgress(50, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddText("x10 yp+25 w60 +BackgroundTrans", "Close:"), SetLoadProgress(60, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 y30 w200 h18 vStartHotkeyEdit Disabled", StartHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(70, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vPauseHotkeyEdit Disabled", PauseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(80, HotkeyGUI, "Hotkeys", "HotkeyGUI")
	HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vStopHotkeyEdit Disabled", StopHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(90, HotkeyGUI, "Hotkeys", "HotkeyGUI")
    HotkeyGUI.AddHotkey("x70 yp+25 w200 h18 vCloseHotkeyEdit Disabled", CloseHotkey).OnEvent("Change", sd_SaveHotkey), SetLoadProgress(100, HotkeyGUI, "Hotkeys", "HotkeyGUI")*/
}

sd_Code(*) {
	global
	AGC_InputtedUnlockCode := MainGUI["InputAGCUnlockCode"].Value
	IniWrite(AGC_InputtedUnlockCode, A_SettingsWorkingDir "main-config.ini", "Settings", "AGCIUC")
	if AGC_InputtedUnlockCode = AGC_UnlockCodeAnswer {
		MainGUI["InputAGCUnlockCode"].Enabled := 0
		MsgBox("You have enabled advanced GUI customisation!`nThis allows you to customise other GUI objects part of the Macro.", "ACA Enabled", 0x20)
		IniWrite(1, A_SettingsWorkingDir "main-config.ini", "Settings", "AGCUnlocked")
		sd_Reload()
	}
}
