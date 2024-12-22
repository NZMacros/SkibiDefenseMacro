;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AUTO-UPDATE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (used to update GUI with info fetched from GitHub)
AsyncHTTPRequest(method, url, func?, headers?) {
	req := ComObject("Msxml2.XMLHTTP")
	req.open(method, url, true)
	if IsSet(headers) {
		for h, v in headers {
			req.setRequestHeader(h, v)
        }
    }
	IsSet(func) && (req.onreadystatechange := func.Bind(req))
	req.send()
}


sd_AutoUpdateHandler(req) {
	global

	if req.readyState != 4 {
		return
    }

	if req.status = 200 {
		LatestVer := Trim((latest_release := JSON.parse(req.responseText))["tag_name"], "v")
	    if (VerCompare(VersionID, LatestVer) < 0) {
			MainGUI["UpdateButton"].Visible := 1
			if LatestVer != IgnoredUpdateVersion {
				sd_SetStatus("GitHub", "Update found! v" LatestVer)
				sd_AutoUpdateGUI()
            }
		}
	}
}

sd_AutoUpdateGUI(*) {
	global
	local size, downloads, posW, hBM, UpdateText, UpdateButton
	GUIClose(*){
		if (IsSet(UpdateGUI) && IsObject(UpdateGUI))
			UpdateGUI.Destroy(), UpdateGUI := ""
	}
	GUIClose()
	UpdateGUI := Gui("+Border +Owner" MainGUI.Hwnd " -MinimizeBox", "Skibi Defense Macro Update")
	UpdateGUI.OnEvent("Close", GUIClose), UpdateGUI.OnEvent("Escape", GUIClose)
	UpdateGUI.SetFont("s9 cDefault Norm", "Tahoma")
	UpdateText := UpdateGUI.Add("Text", "x20 w260 +Center +BackgroundTrans", "A newer version of Skibi Defense Macro was found!`nDo you want to update now?")

	posW := TextExtent("Skibi Defense Macro v" VersionID " ⮕ v" LatestVer, UpdateText)
	UpdateGUI.AddText("x" 149 - posW//2 " y40 +BackgroundTrans", "Skibi Defense Macro v" VersionID " ⮕ ")
	UpdateGUI.AddText("x+0 yp +c379e37 +BackgroundTrans", "v" LatestVer)

	posW := TextExtent((size := Round(latest_release["assets"][1]["size"]/1048576, 2)) " MB // Downloads: " (downloads := latest_release["assets"][1]["download_count"]), UpdateText)
	UpdateGUI.AddText("x" 150 - posW//2 " y54 +BackgroundTrans", size " MB // Downloads: " downloads)

	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"]), UpdateGUI.AddPicture("x76 y+1 w16 h16 +BackgroundTrans", "HBITMAP:*" hBM).OnEvent("Click", OpenGitHub), DllCall("DeleteObject", "ptr", hBM)
	UpdateGUI.AddText("x+4 yp+1 c0046ee +BackgroundTrans", "Patch Notes & Updates").OnEvent("Click", OpenGitHubLatestRelease)

	UpdateGUI.SetFont("s8 w700")
	local MajorUpdate := (StrSplit(VersionID, ".")[1] < StrSplit(LatestVer, ".")[1])
	UpdateGUI.AddGroupBox("x50 y+4 w200 h" (MajorUpdate ? 74 : 50), "Options")
	UpdateGUI.SetFont("Norm")
	UpdateGUI.AddCheckBox("xp+8 yp+16 Checked vCopySettings", "Copy Settings")
	UpdateGUI.AddCheckBox("xp+92 yp vCopyStrats Checked" (!MajorUpdate) " Disabled" MajorUpdate, "Copy Strategies")
	UpdateGUI.AddCheckBox("xp-92 yp+16 vCopyPaths Checked" (!MajorUpdate) " Disabled" MajorUpdate, "Copy Paths")
	UpdateGUI.AddCheckBox("xp+92 yp vDeleteOld", "Delete v" VersionID)
	if (MajorUpdate) {
		UpdateGUI.AddButton("x60 y+5 w180 h18", "Why are some options disabled?").OnEvent("Click", sd_MajorUpdateHelp)
	}

	UpdateGUI.SetFont("s9")
	UpdateGUI.AddButton("x8 y+12 w92 h26", "Never").OnEvent("Click", sd_NeverButton)
	UpdateGUI.AddButton("xp+96 yp wp hp vDismissButton", "Dismiss (120)").OnEvent("Click", sd_DismissButton)
	SetTimer(sd_DismissLabel, -1000)

	UpdateGUI.SetFont("Bold")
	(UpdateButton := UpdateGUI.AddButton("xp+96 yp wp hp", "Update")).OnEvent("Click", sd_UpdateButton)
	UpdateGUI.Show("w290 h168")
	UpdateButton.Focus()
	WinWaitClose("ahk_id " UpdateGUI.Hwnd, , 125)
	GUIClose()
}

sd_DismissLabel() {
	static countdown := unset
	global UpdateGUI
	if (!IsSet(countdown)) {
		countdown := 120
	}

	if (UpdateGUI) {
		if (--countdown <= 0) {
			countdown := unset
			UpdateGUI.Destroy()
		} else {
			UpdateGUI["DismissButton"].Text := "Dismiss (" countdown ")"
			SetTimer(sd_DismissLabel, -1000)
		}
	} else {
		countdown := unset
	}
}

sd_DismissButton(*) {
	global UpdateGUI
	UpdateGUI.Destroy(), UpdateGUI := ""
}

sd_NeverButton(*) {
	global UpdateGUI
	if (MsgBox("Are you sure you want to disable prompts for v" LatestVer "?`nYou can still update manually, or by clicking the red symbol in the bottom right corner of the GUI.", "Disable Automatic Update", 0x1044 " Owner" UpdateGUI.Hwnd) = "Yes") {
		IniWrite((IgnoredUpdateVersion := LatestVer), A_SettingsWorkingDir "main_config.ini", "Settings", "IgnoredUpdateVersion")
		UpdateGUI.Destroy(), UpdateGUI := ""
	}
}

sd_UpdateButton(*) {
	global latest_release, VersionID, UpdateGUI
	url := latest_release["assets"][1]["browser_download_url"]
	olddir := A_WorkingDir
	CopySettings := UpdateGUI["CopySettings"].Value
	CopyStrats := UpdateGUI["CopyStrats"].Value
	CopyPaths := UpdateGUI["CopyPaths"].Value
	DeleteOld := UpdateGUI["DeleteOld"].Value
	changedpaths := ""
	UpdateGUI.Destroy(), UpdateGUI := ""

	if CopyPaths = 1 {
		try {
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Open("GET", "https://api.github.com/repos/NZMacros/SkibiDefenseMacro/tags?per_page=100", 1)
			wr.SetRequestHeader("accept", "application/vnd.github+json")
			wr.Send()
			wr.WaitForResponse()
			for k, v in (tags := JSON.parse(wr.ResponseText)) {
				if ((VerCompare(Trim(v["name"], "v"), VersionID) <= 0) && (base := v["name"])) {
					break
				}
			}
			if (!base) {
				throw
			}

			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Open("GET", "https://api.github.com/repos/NZMacros/SkibiDefenseMacro/compare/" base "..." latest_release["tag_name"] , 1)
			wr.SetRequestHeader("accept", "application/vnd.github+json")
			wr.Send()
			wr.WaitForResponse()
			for k,v in (files := JSON.parse(wr.ResponseText)["files"]) {
				if (SubStr(v["filename"], 1, 6) = "paths/") {
					changedpaths .= '"' SubStr(v["filename"], 7) '" '
				}
			}
			changedpaths := RTrim(changedpaths)
		} catch {
			MsgBox("Unable to fetch changed paths from GitHub!`nIf you still want to update, disable 'Copy Paths' (and copy them manually) or try again later.", "Error", 0x1010 " T30")
			return
		}
	}

	Run('"' A_MacroWorkingDir 'submacros\update.bat" "' url '" "' olddir '" "' CopySettings '" "' CopyStrats '" "' CopyPaths '" "' DeleteOld '" "' changedpaths '"')
	ExitApp()
}

sd_MajorUpdateHelp(*) {
	MsgBox("v" VersionID " to v" LatestVer " is a major version update.`n`nThis means that backward compatibility of Paths and Strategies cannot be guaranteed, so they cannot be automatically copied.`nHowever, in Skibi Defense Macro, your Settings are guaranteed to be transferable to any new version, so that option remains enabled.`n`nFor more information, you can review the convention at https://semver.org/", "Major Update", 0x1040)
}
