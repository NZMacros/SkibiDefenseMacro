/***********************************************************
* @description: Functions for automating the Roblox window
* @author SP
***********************************************************/

; Updates global variables windowX, windowY, windowWidth, windowHeight
; Optionally takes a known window handle to skip GetRobloxHWND call
; Returns: 1 = successful; 0 = TargetError
GetRobloxClientPos(hwnd?)
{
    global windowX, windowY, windowWidth, windowHeight
    if !IsSet(hwnd)
        hwnd := GetRobloxHWND()

    try
        WinGetClientPos &windowX, &windowY, &windowWidth, &windowHeight, "ahk_id " hwnd
    catch TargetError
        return windowX := windowY := windowWidth := windowHeight := 0
    else
        return 1
}

; Returns: hWnd = successful; 0 = window not found
GetRobloxHWND()
{
	if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe"))
		return hwnd
	else if (WinExist("Roblox ahk_exe ApplicationFrameHost.exe"))
    {
        try
            hwnd := ControlGetHwnd("ApplicationFrameInputSinkWindow1")
        catch TargetError
		    hwnd := 0
        return hwnd
    }
	else
		return 0
}

; Finds the y-offset of GUI elements in the current Roblox window
; Image is specific to BSS but can be altered for use in other games
; Optionally takes a known window handle to skip GetRobloxHWND call
; Returns: offset (integer), defaults to 0 on fail (ByRef param fail is then set to 1, else 0)
/*GetYOffset(hwnd?, &fail?)
{
	static hRoblox := 0, offset := 0
    if !IsSet(hwnd)
        hwnd := GetRobloxHWND()

	if (hwnd = hRoblox)
	{
		fail := 0
		return offset
	}
	else if WinExist("ahk_id " hwnd)
	{
		try WinActivate "Roblox"
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")

		Loop 20 ; for red vignette effect
		{ 
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["toppollen"], &pos, , , , , 20) = 1)
				&& (Gdip_ImageSearch(pBMScreen, bitmaps["toppollenfill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 41, y + 10, 20) = 0))
			{
				Gdip_DisposeImage(pBMScreen)
				hRoblox := hwnd, fail := 0
				return offset := y - 14
			}
			else
			{
				if (A_Index = 20)
				{
					Gdip_DisposeImage(pBMScreen), fail := 1
					return 0 ; default offset, change this if needed
				}
				else
				{
					Sleep 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")
				}				
			}
		}
	}
	else
		return 0
}*\

ActivateRoblox()
{
	try
		WinActivate "Roblox"
	catch
		return 0
	else
		return 1
}

CloseRoblox() {
	; if roblox exists, activate it and send Esc+L+Enter
	if (hwnd := GetRobloxHWND()) {
		GetRobloxClientPos(hwnd)
		if (windowHeight >= 500) { ; requirement for L to activate "Leave"
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay 250+KeyDelay
			Send "{" Escape "}{" L "}{" Enter "}"
			SetKeyDelay PrevKeyDelay
		}
		try WinClose "Roblox"
		wait(0.5)
		try WinClose "Roblox"
		wait(4.5) ;Delay to prevent Roblox Error Code 264
	}
	; kill any remnant processes
	for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'")
		ProcessClose p.ProcessID
}

/*DisconnectCheck(testCheck := 0)
{
	global PrivServer, Fallback

	; return if not disconnected or crashed
	ActivateRoblox()
	GetRobloxClientPos()
	if ((windowWidth > 0) && !WinExist("Roblox Crash")) {
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY+windowHeight//2 "|200|80")
		if (ImgSearch("Disconnected") != 1) {
			Gdip_DisposeImage(pBMScreen)
			return 0
		}
		Gdip_DisposeImage(pBMScreen)
	}

	; obtain link codes from Private Server and Fallback Server links
	linkCodes := Map()
	for k,v in ["PrivServer"] {
		if (%v% && (StrLen(%v%) > 0)) {
			if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode)
				linkCodes[k] := linkCode[0]
			; else
				; nm_setStatus("Error", ServerLabels[k] " Invalid")
		}
	}

	; main reconnect loop
	Loop {
		;Decide Server
		server := ((A_Index <= 20) && linkCodes.Has(n := (A_Index-1)//5 + 1)) ? n : ((Fallback = 0) && (n := ObjMinIndex(linkcodes))) ? n : 0

		;Wait For Success
		i := A_Index, success := 0
		Loop 5 {
			;START
			CloseRoblox()
				;Run Server Deeplink
				try Run '"roblox://placeID=14279693118' (server ? ("&linkCode=" linkCodes[server]) : "") '"'

				default:
			;STAGE 1 - wait for Roblox window
			if WinExist "Roblox"
				if GetRobloxHWND() {
					ActivateRoblox()
					break
				}
				if (A_Index = 240) {
					break 2
				}
				wait(1) ; timeout 4 mins, wait for any Roblox update to finish
			}

			while ImgSearch("ChapterCheck") != 1 {
				ActivateRoblox()
					if !GetRobloxClientPos() {
						continue 2
					}
				ImgSearch("ChapterCheck")
			}
			if ImgSearch("ChapterCheck") = 1 {
				success := 1
			}

			;STAGE 2 - wait for loading screen (or loaded game)
			/*Loop 240 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["SkibiData"], , , , , , 4) = 1) {
					Gdip_DisposeImage(pBMScreen)

					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["LobbyCheck"], , , , , , 10) = 1) {
					Gdip_DisposeImage(pBMScreen)
					success := 1
					break 2
				}
				if ImgSearch("ChapterCheck", 10) = 1 {
					success := 1
					break 2
				}
				if ImgSearch("Disconnected", 2) = 1 {
					continue 2
				}
				if (A_Index = 240) {
					break 2
				}
				wait(1) ; timeout 3 mins, slow loading
			}
			;STAGE 3 - wait for loaded game
			Loop 240 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if ImgSearch("ChapterCheck", 10) = 1 {
					success := 1
					break 2
				}
				if ImgSearch("Disconnected", 2) = 1 {
					continue 2
				}
				if (A_Index = 240) {
					break 2
				}
				wait(1) ; timeout 3 mins, slow loading
			}
		}*/

		;Successful Reconnect
		if (success = 1) && testCheck = 0
		{
			ActivateRoblox()
			GetRobloxClientPos()
			wait(0.5)
			TapKey(F11)
			return 1
		}
		else if (success = 1) && testCheck = 1
		{
			ActivateRoblox()
			GetRobloxClientPos()
			wait(0.5)
			TapKey(F11)
			return 2
		}
	}
	}
}*/


global ReconnectMethod := "Deeplink"

DisconnectCheck(testCheck := 0)
{
	/*static ServerLabels := Map(0,"Public Server", 1,"Private Server", 2,"Fallback Server 1", 3,"Fallback Server 2", 4,"Fallback Server 3")*/

	; return if not disconnected or crashed
	ActivateRoblox()
	GetRobloxClientPos()
	if ((windowWidth > 0) && !WinExist("Roblox Crash")) {
		if (ImgSearchReconnect("Disconnected", 2) != 1) {
			return 0
		}
	}

	; end any residual movement and set reconnect /*start time
	Click "Up"
	nm_endWalk()
	ReconnectStart := nowUnix()
	nm_updateAction("Reconnect")*/

	; wait for any requested delay time (e.g. from remote control or daily reconnect)
	if (ReconnectDelay) {
		nm_setStatus("Waiting", ReconnectDelay " seconds before Reconnect")
		Sleep 1000*ReconnectDelay
		ReconnectDelay := 0
	}
	else if (MacroState = 2) {
		TotalDisconnects:=TotalDisconnects+1
		SessionDisconnects:=SessionDisconnects+1
		PostSubmacroMessage("StatMonitor", 0x5555, 6, 1)
		IniWrite TotalDisconnects, "settings\nm_config.ini", "Status", "TotalDisconnects"
		IniWrite SessionDisconnects, "settings\nm_config.ini", "Status", "SessionDisconnects"
		nm_setStatus("Disconnected", "Reconnecting")
	}*/

	; obtain link codes from Private Server and Fallback Server links
	linkCodes := Map()
	for k,v in ["PrivServer" /*,"FallbackServer1", "FallbackServer2", "FallbackServer3"*/] {
		if (%v% && (StrLen(%v%) > 0)) {
			if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode)
				linkCodes[k] := linkCode[0]
			else
				; nm_setStatus("Error", ServerLabels[k] " Invalid")
		}
	}

	; main reconnect loop
	Loop {
		;Decide Server
		server := ((A_Index <= 20) && linkCodes.Has(n := (A_Index-1)//5 + 1)) ? n : ((PublicFallback = 0) && (n := ObjMinIndex(linkcodes))) ? n : 0

		;Wait For Success
		i := A_Index, success := 0
		Loop 5 {
			;START
			switch (ReconnectMethod = "Browser") ? 0 : Mod(i, 5) {
				case 1,2:
				;Close Roblox
				CloseRoblox()
				;Run Server Deeplink
				; nm_setStatus("Attempting", ServerLabels[server])
				try Run '"roblox://placeID=1537690962' (server ? ("&linkCode=" linkCodes[server]) : "") '"'

				case 3,4:
				;Run Server Deeplink (without closing)
				; nm_setStatus("Attempting", ServerLabels[server])
				try Run '"roblox://placeID=1537690962' (server ? ("&linkCode=" linkCodes[server]) : "") '"'

				default:
				if server {
					;Close Roblox
					CloseRoblox()
					;Run Server Link (legacy method w/ browser)
					; nm_setStatus("Attempting", ServerLabels[server] " (Browser)")
					if ((success := LegacyReconnect(linkCodes[server], i)) = 1) {
						if (ReconnectMethod != "Browser") {
							ReconnectMethod := "Browser"
							; nm_setStatus("Warning", "Deeplink reconnect failed, switched to legacy reconnect (browser) for this session!")
						}
						break
					}
					else
						continue 2
				} else {
					;Close Roblox
					(i = 1) && CloseRoblox()
					;Run Server Link (spam deeplink method)
					try Run '"roblox://placeID=1537690962"'
				}
			}
			;STAGE 1 - wait for Roblox window
			Loop 240 {
				if GetRobloxHWND() {
					ActivateRoblox()
					; nm_setStatus("Detected", "Roblox Open")
					break
				}
				if (A_Index = 240) {
					; nm_setStatus("Error", "No Roblox Found`nRetry: " i)
					break 2
				}
				wait(1) ; timeout 4 mins, wait for any Roblox update to finish
			}
			;STAGE 2 - wait for loading screen (or loaded game)
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					; nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				if (ImgSearchReconnect("SkibiData") = 1) {
					; nm_setStatus("Detected", "Game Open")
					break
				}
				if (ImgSearchReconnect("ChapterCheck", 2) = 1) {
					; nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (ImgSearchReconnect("Disconnected", 2) = 1) {
					; nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				if (A_Index = 180) {
					; nm_setStatus("Error", "No BSS Found`nRetry: " i)
					break 2
				}
				wait(1) ; timeout 3 mins, slow loading
			}
			;STAGE 3 - wait for loaded game
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					; nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				if ((ImgSearchReconnect2("SkibiData", 4) = 0) || (ImgSearchReconnect2("ChapterCheck") = 1)) {
					; nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (ImgSearchReconnect2("Disconnected", 2) = 1) {
					; nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				if (A_Index = 180) {
					; nm_setStatus("Error", "BSS Load Timeout`nRetry: " i)
					break 2
				}
				wait(1) ; timeout 3 mins, slow loading
			}
		}

		;Successful Reconnect
		if (success = 1)
		{
			ActivateRoblox()
			GetRobloxClientPos()
			/*MouseMove windowX + windowWidth//2, windowY + windowHeight//2
			duration := DurationFromSeconds(ReconnectDuration := (nowUnix() - ReconnectStart), "mm:ss")
			nm_setStatus("Completed", "Reconnect`nTime: " duration " - Attempts: " i)
			Sleep 500

			LastClock:=nowUnix()
			IniWrite LastClock, "settings\nm_config.ini", "Collect", "LastClock"
			if (beesmasActive)
			{
				LastGingerbread += ReconnectDuration ? ReconnectDuration : 300
				IniWrite LastGingerbread, "settings\nm_config.ini", "Collect", "LastGingerbread"
			}
			Loop 3 {
				PlanterHarvestTime%A_Index% += PlanterName%A_Index% ? (ReconnectDuration ? ReconnectDuration : 300) : 0
				IniWrite PlanterHarvestTime%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
			}

			if (server > 1) ; swap PrivServer and FallbackServer - original PrivServer probably has an issue
			{
				n := server - 1
				temp := PrivServer, PrivServer := FallbackServer%n%, FallbackServer%n% := temp
				MainGui["PrivServer"].Value := PrivServer
				MainGui["FallbackServer" n].Value := FallbackServer%n%
				IniWrite PrivServer, "settings\nm_config.ini", "Settings", "PrivServer"
				IniWrite FallbackServer%n%, "settings\nm_config.ini", "Settings", "FallbackServer" n
				PostSubmacroMessage("Status", 0x5553, 10, 6)
			}
			PostSubmacroMessage("Status", 0x5552, 221, (server = 0))*/

			if testCheck = 1 && success = 1) {
				return 2
			} else if testCheck = 0 && success = 1 {
				return 1
			}
		}
	}
}

LegacyReconnect(linkCode, i)
{
	global bitmaps
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","http", "Str","open", "Ptr",cmd.Ptr, "IntP",512),
		DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
	, exe := (pEXE > 0) ? StrGet(pEXE) : ""
	, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""

	url := "https://www.roblox.com/games/1537690962?privateServerLinkCode=" linkCode
	if ((StrLen(exe) > 0) && (StrLen(params) > 0))
		ShellRun(exe, StrReplace(params, "%1", url)), success := 0
	else
		Run '"' url '"'

	Loop 1 {
		;STAGE 1 - wait for Roblox Launcher
		Loop 120 {
			if WinExist("Roblox") {
				break
			}
			if (A_Index = 120) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 2 mins, slow internet / not logged in
		}
		;STAGE 2 - wait for RobloxPlayerBeta.exe
		Loop 180 {
			if WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate
				nm_setStatus("Detected", "Roblox Open")
				break
			}
			if (A_Index = 180) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 3 mins, wait for any Roblox update to finish
		}
		;STAGE 3 - wait for loading screen (or loaded game)
		Loop 180 {
			if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) {
				WinActivate
				GetRobloxClientPos(hwnd)
			} else {
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , , 4) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Detected", "Game Open")
				break
			}
			if (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , , 2) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Detected", "Game Loaded")
				success := 1
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			if (nm_imgSearch("disconnected.png",25, "center")[1] = 0){
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
			if (A_Index = 180) {
				nm_setStatus("Error", "No BSS Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 3 mins, slow loading
		}
		;STAGE 4 - wait for loaded game
		Loop 240 {
			if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) {
				WinActivate
				GetRobloxClientPos(hwnd)
			} else {
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|150")
			if ((ImgSearchReconnect2("SkibiData", 4) = 0) || (ImgSearchReconnect2("ChapterCheck", 2) = 1))
			{
				; nm_setStatus("Detected", "Game Loaded")
				success := 1
				break 2
			}
			/*if (nm_imgSearch("disconnected.png",25, "center")[1] = 0){
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2*/
			}
			if (A_Index = 240) {
				; nm_setStatus("Error", "BSS Load Timeout`nRetry: " i)
				Sleep 1000
				break 2
			}
			Wait(1) ; timeout 4 mins, slow loading
		}
	}
	;Close Browser Tab
	for hwnd in WinGetList(,, "Program Manager")
	{
		p := WinGetProcessName("ahk_id " hwnd)
		if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
			continue ; skip roblox and AHK windows
		title := WinGetTitle("ahk_id " hwnd)
		if (title = "")
			continue ; skip empty title windows
		s := WinGetStyle("ahk_id " hwnd)
		if ((s & 0x8000000) || !(s & 0x10000000))
			continue ; skip NoActivate and invisible windows
		s := WinGetExStyle("ahk_id " hwnd)
		if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
			continue ; skip ToolWindow and AlwaysOnTop windows
		try
		{
			WinActivate "ahk_id " hwnd
			Sleep 500
			Send "^{w}"
		}
		break
	}
	return success
}