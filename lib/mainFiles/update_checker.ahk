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
			VersionWidth += 16
			MainGUI["VersionText"].Move(494 - VersionWidth), MainGUI["VersionText"].Redraw()
			MainGUI["GitHubButton"].Move(494 - VersionWidth - 23), MainGUI["GitHubButton"].Redraw()
			MainGUI["DiscordButton"].Move(494 - VersionWidth - 48), MainGUI["DiscordButton"].Redraw()
			if LatestVer != IgnoredUpdateVersion {
				sd_AutoUpdateGUI()
            }
		}
	}
}

sd_AutoUpdateGUI(*) {
	global
	local size, downloads, posW, hBM, UpdateText, UpdateButton
	GUIClose(*) {
		if (IsSet(UpdateGUI) && IsObject(UpdateGUI)) {
			Suspend(0)
			MainGUI.Opt("-Disabled")
			UpdateGUI.Destroy(), UpdateGUI := ""
        }
	}
	GUIClose()
	;Suspend(1)
	MainGUI.Opt("+Disabled")
	UpdateGUI := Gui("+Border +Owner" MainGUI.Hwnd " -MinimizeBox", "Skibi Defense Macro Update")
	UpdateGUI.OnEvent("Close", GUIClose), UpdateGUI.OnEvent("Escape", GUIClose)
	UpdateGUI.SetFont("s9 cDefault Norm", "Tahoma")
	local MajorUpdate := (StrSplit(VersionID, ".")[1] < StrSplit(LatestVer, ".")[1])
	UpdateText := UpdateGUI.AddText("x20 w260 +Center +BackgroundTrans", "A newer version of Skibi Defense Macro was found!`nDo you want to update now?")

	if (MajorUpdate) {
		local PatchesText := "Patch Notes and Updates"
	} else {
		PatchesText := "Patch Notes and Bug Fixes"
	}

	posW := TextExtent("Skibi Defense Macro v" VersionID " ⮕ v" LatestVer, UpdateText)
	UpdateGUI.AddText("x" 149-posW//2 " y75 +BackgroundTrans", "Skibi Defense Macro v" VersionID " ⮕ ")
	UpdateGUI.AddText("x+0 yp +c379e37 +BackgroundTrans", "v" LatestVer)

	posW := TextExtent((size := Round(latest_release["assets"][1]["size"]/1048576, 2)) " MB // Downloads: " (downloads := latest_release["assets"][1]["download_count"]), UpdateText)
	UpdateGUI.AddText("x" 150-posW//2 " y54 +BackgroundTrans", size " MB // Downloads: " downloads)

	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["GitHubIcon"]), UpdateGUI.AddPicture("x76 y+25 w16 h16 +BackgroundTrans", "HBITMAP:*" hBM).OnEvent("Click", OpenGitHub), DllCall("DeleteObject", "ptr", hBM)
	UpdateGUI.AddText("x+4 yp+1 c0046ee +BackgroundTrans", PatchesText).OnEvent("Click", OpenGitHubLatestRelease)

	UpdateGUI.SetFont("s8 w700")
	UpdateGUI.AddGroupBox("x5 y+10 w294 h" (MajorUpdate ? 74 : 50), "Options")
	UpdateGUI.SetFont("Norm")
	UpdateGUI.AddCheckBox("xp+8 yp+20 vCopySettings Checked", "Copy Settings")
	UpdateGUI.AddCheckBox("xp+102 yp vDeleteOld " ((MajorUpdate) ? "Disabled Checked" : "Checked"), "Delete v" VersionID)
	if (MajorUpdate) {
		UpdateGUI.AddButton("x60 y+5 w180 h20", "Major Update Information").OnEvent("Click", sd_MajorUpdateHelp)
    }

	UpdateGUI.SetFont("s9")
	UpdateGUI.AddButton("x8 y+30 w92 h26", "Never").OnEvent("Click", sd_NeverButton)
	UpdateGUI.AddButton("xp+96 yp wp hp vDismissButton", "Dismiss (120)").OnEvent("Click", sd_DismissButton)
	SetTimer(sd_DismissLabel, -1000)

	UpdateGUI.SetFont("Bold")
	(UpdateButton := UpdateGUI.AddButton("xp+96 yp wp hp", "Update")).OnEvent("Click", sd_UpdateButton)
	UpdateGUI.Show("w300 h250")
	UpdateButton.Focus()
	WinWaitClose("ahk_id " UpdateGUI.Hwnd, , 125)
	GUIClose()
}

sd_DismissLabel() {
	static countdown := unset
	global UpdateGUI
	if !IsSet(countdown) {
		countdown := 120
    }

	if (UpdateGUI) {
		if (--countdown <= 0) {
			countdown := unset
			Suspend(0)
			MainGUI.Opt("-Disabled")
			UpdateGUI.Destroy()
		} else {
			UpdateGUI["DismissButton"].Text := "Dismiss (" countdown ")"
			SetTimer(sd_DismissLabel, -1000)
		}
	}
	else {
		countdown := unset
    }
}

sd_DismissButton(*) {
	global UpdateGUI
	Suspend(0)
	MainGUI.Opt("-Disabled")
	UpdateGUI.Destroy(), UpdateGUI := ""
}

sd_NeverButton(*) {
	global UpdateGUI
	if (MsgBox("Are you sure you want to disable prompts for v" LatestVer "? You can still update manually, or by clicking the red symbol in the bottom right corner of the GUI.", "Disable Automatic Update Reminders for v" LatestVer, 0x1044 " Owner" UpdateGUI.Hwnd) = "Yes") {
		IniWrite((IgnoredUpdateVersion := LatestVer), A_SettingsWorkingDir "main_config.ini", "Settings", "IgnoredUpdateVersion")
		UpdateGUI.Destroy(), UpdateGUI := ""
	}
}

sd_UpdateButton(*) {
	global latest_release, VersionID, UpdateGUI
	url := latest_release["assets"][1]["browser_download_url"]
	olddir := A_WorkingDir
	CopySettings := UpdateGUI["CopySettings"].Value
	DeleteOld := UpdateGUI["DeleteOld"].Value
	UpdateGUI.Destroy(), UpdateGUI := ""

	Run('"' A_WorkingDir '\submacros\update.bat" "' url '" "' olddir '" "' CopySettings '" "' DeleteOld '"')
	ExitApp()
}

sd_MajorUpdateHelp(*) {
	MsgBox("v" VersionID " to v" LatestVer " is a major version update, meaning it introduces lots of new features.`nThe old version is required to be deleted.`n`nFor some information on how versions are numbered, you can review the convention at https://semver.org/", "Major Update", 0x1040)
}
