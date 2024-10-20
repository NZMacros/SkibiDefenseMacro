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
GetYOffset(hwnd?, &fail?)
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

		/*Loop 20 ; for red vignette effect
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
		}*/
	}
	else
		return 0
}

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

DisconnectCheck(testCheck := 0)
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
			Loop 240 {
				if GetRobloxHWND() {
					ActivateRoblox()
					break
				}
				if (A_Index = 240) {
					break 2
				}
				wait(1) ; timeout 4 mins, wait for any Roblox update to finish
			}
			;STAGE 2 - wait for loading screen (or loaded game)
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["SkibiData"], , , , , 150, 4) = 1) {
					Gdip_DisposeImage(pBMScreen)

					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["LobbyCheck"], , , , , 150, 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["Disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (A_Index = 180) {
					break 2
				}
				wait(1) ; timeout 3 mins, slow loading
			}
			;STAGE 3 - wait for loaded game
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["SkibiData"], , , , , 150, 4) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["LobbyCheck"], , , , , 150, 2) = 1)) {
					Gdip_DisposeImage(pBMScreen)
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["Disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (A_Index = 180) {
					break 2
				}
				wait(1) ; timeout 3 mins, slow loading
			}
		}

		;Successful Reconnect
		if (success = 1) && testCheck = 0
		{
			ActivateRoblox()
			GetRobloxClientPos()
			wait(0.5)
			return 1
		}
		else if (success = 1) && testCheck = 1
		{
			ActivateRoblox()
			GetRobloxClientPos()
			wait(0.5)
			return 2
		}
	}
}