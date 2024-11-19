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
/*GetYOffset(hwnd?, &fail?) {
	static hRoblox := 0, offset := 0

    if !IsSet(hwnd) {
        hwnd := GetRobloxHWND()
	}

	if (hwnd = hRoblox) {
		fail := 0
		return offset
	} else if WinExist("ahk_id " hwnd) {
		try WinActivate "Roblox"
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")

		Loop 20 { ; for red vignette effect
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["toppollen"], &pos, , , , , 20) = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["toppollenfill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 41, y + 10, 20) = 0)) {
				Gdip_DisposeImage(pBMScreen)
				hRoblox := hwnd, fail := 0
				return offset := y - 14
			} else {
				if (A_Index = 20) {
					Gdip_DisposeImage(pBMScreen), fail := 1
					return 0 ; default offset, change this if needed
				} else {
					Sleep 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")
				}				
			}
		}
	} else {
		return 0
	}
}*/

; Activate the ROBLOX window
ActivateRoblox() {
	try {
		WinActivate "Roblox"
	} catch {
		return 0
	} else {
		return 1
	}
}


/*EXTERNAL*/

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
	for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'") {
		ProcessClose p.ProcessID
	}
}

DisconnectCheck(testCheck := 0) {
	static ServerLabels := Map(0,"Public Server", 1,"Private Server")

	; If testCheck has no value, return if client hasn't disconnected or crashed
	if testCheck != 1 {
		ActivateRoblox()
		GetRobloxClientPos()
		if ((windowWidth > 0) && !WinExist("Roblox Crash")) {
			if (ImgSearch("Disconnected") != 1) {
				return 0
			}
		}
	}

	; End any residual movement and obtain the linkcode from the PS link
	Click "Up"
	linkCodes := Map()
	for k,v in ["PrivServer"] {
		if (%v% && (StrLen(%v%) > 0)) {
			if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode) {
				linkCodes[k] := linkCode[0]
			} else {
				MsgBox(ServerLabels[k] " Invalid", "Error", 0x1000)
			}
		}
	}

	; Main reconnect loop
	Loop {
		;Decide server
		server := ((A_Index <= 20) && linkCodes.Has(n := (A_Index-1)//5 + 1)) ? n : ((n := ObjMinIndex(linkCodes))) ? n : 0

		; Wait for success
		i := A_Index, success := 0
		Loop 5 {
			switch (ReconnectMethod = "Browser") ? 0 : Mod(i, 5) {
				case 1,2:
				CloseRoblox()
				;Run Deeplink
				try Run '"roblox://placeID=14279693118 (server ? ("&linkCode=" linkCodes[server]) : "")"'

				case 3,4:
				;Run Deeplink (without closing ROBLOX)
				try Run '"roblox://placeID=14279693118 (server ? ("&linkCode=" linkCodes[server]) : "")"'

				default:
				if server {
					CloseRoblox()
					;Run link via browser
					if ((success := BrowserReconnect(linkCodes[server], i, 1, 1)) = 1) {
						if (ReconnectMethod != "Browser") {
							ReconnectMethod := "Browser"
						}
						break
					} else {
						continue 2
					}
				} else {
					(i = 1) && CloseRoblox()
					;Spam Deeplink
					try Run '"roblox://placeID=14279693118"'
				}
			}
			; Detect ROBLOX window
			Loop 300 {
				if GetRobloxHWND() {
					ActivateRoblox()
					break
				}
				if (A_Index = 300) {
					break 2
				}
				wait(1) ; Timeout 5 minutes in the case of a ROBLOX update
			}
			; Detect joining screen or loading game and wait for game
			msgbox "starting searches"
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					continue 2
				}
				if (ImgSearch("ChapterCheck") = 1) {
					success := 1
					break 2
				}
				if (ImgSearch("Disconnected") = 1) {
					continue 2
				}
				if (A_Index = 180) {
					break 2
				}
				wait(1) ; Timeout 3 minutes, slow loading
			}
		}

		; Successful reconnect
		ActivateRoblox()
		GetRobloxClientPos()
		if (success = 1) && (testCheck = 0) {
			return 1
		} else if (success = 1) && (testCheck = 1) {
			return 2
		}
	}
}

BrowserReconnect(linkCode, i, fromPrev := 0, testCheck := 0) {
	if (fromPrev = 0) || (testCheck = 0) {
		if (ImgSearch("Disconnected") != 1) {
			return 0
		}
	} 

	global bitmaps
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","http", "Str","open", "Ptr",cmd.Ptr, "IntP",512),

	DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
	, exe := (pEXE > 0) ? StrGet(pEXE) : ""
	, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""

	url := "https://www.roblox.com/games/14279693118?privateServerLinkCode=" linkCode
	if ((StrLen(exe) > 0) && (StrLen(params) > 0))
		ShellRun(exe, StrReplace(params, "%1", url)), success := 0
	else
		Run '"' url '"'

	Loop 1 {
		; Detect ROBLOX Window
		Loop 300 {
			if WinExist("Roblox") {
				break
			}
			if (A_Index = 300) {
				wait(1)
				break 2
			}
			wait(1) ; Timeout 5 minutes, slow internet/not logged in
		}
		; Detect open ROBLOX
		Loop 300 {
			if WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate
				break
			}
			if (A_Index = 300) {
				wait(1)
				break 2
			}
			wait(1) ; Timeout 5 minutes in the case of a ROBLOX update
		}
		; Detect game
		Loop 180 {
			if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) {
				WinActivate
				GetRobloxClientPos(hwnd)
			} else {
				wait(1)
				break 2
			}
			if (ImgSearch("ChapterCheck") = 1) {
				success := 1
				break 2
			}
			if (ImgSearch("Disconnected") = 1){
				wait(1)
				break 2
			}
			if (A_Index = 180) {
				wait(1)
				break 2
			}
			wait(1) ; Timeout 3 minutes, slow loading
		}
	; Kill Browser
		for hwnd in WinGetList(,, "Program Manager") {
			p := WinGetProcessName("ahk_id " hwnd)
			if (InStr(p, "Roblox") || InStr(p, "AutoHotkey")) {
				continue ; Skip ROBLOX and AutoHotkey windows
			}
			title := WinGetTitle("ahk_id " hwnd)
			if (title = "") {
				continue ; Skip empty title windows
			}
			s := WinGetStyle("ahk_id " hwnd)
			if ((s & 0x8000000) || !(s & 0x10000000)) {
				continue ; Skip 'NoActivate' and invisible Windows
			}
			s := WinGetExStyle("ahk_id " hwnd)
			if ((s & 0x80) || (s & 0x40000) || (s & 0x8)) {
				continue ; Soip ToolWindow and AlwaysOnTop windows
			}
			try {
				WinActivate "ahk_id " hwnd
				Sleep 500
				Send "^{w}"
			}
		}
		break
	}

	; Successes
	if (fromPrev = 1) {
		return success
	}
	if (success = 1) && (testCheck = 0) {
		return 1
	}
	if (success = 1) && (testCheck = 2) {
		return 2
	}
}
