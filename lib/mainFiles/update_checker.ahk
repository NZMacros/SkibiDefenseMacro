QueryUpdateValidity() {
	if (Ver2Num(CRRN) > Ver2Num(CurrentVersion)) {
	    QueryUpdate()
	}
}

QueryGitHubRepo(repo, subrequest := "", data := "", token := "") {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    repo := StrSplit(repo, "/")
    if (subrequest := Trim(subrequest, "/\"))
        subrequest := "/" subrequest

    whr.Open("GET", "https://api.github.com/repos/" repo[1] "/" repo[2] subrequest (data ? ObjToQuery(data) : ""), true)
    whr.SetRequestHeader("Accept", "application/vnd.github+json")
    if token
        whr.SetRequestHeader("Authorization", "Bearer " token)
    whr.Send()
    whr.WaitForResponse()
    return cJSON.Load(whr.ResponseText)
}

ObjToQuery(oData) { ; https://gist.github.com/anonymous1184/e6062286ac7f4c35b612d3a53535cc2a?permalink_comment_id=4475887#file-winhttprequest-ahk
    static HTMLFile := InitHTMLFile()
    if (!IsObject(oData)) {
        return oData
    }
    out := ""
    for key, val in (oData is Map ? oData : oData.OwnProps()) {
        out .= HTMLFile.parentWindow.encodeURIComponent(key) "="
        out .= HTMLFile.parentWindow.encodeURIComponent(val) "&"
    }
    return "?" RTrim(out, "&")

			
    InitHTMLFile() {
        doc := ComObject("HTMLFile")
        doc.write("<meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
        return doc
    }
}

ReplaceChar(Str) {
    try {
        if InStr(Str, "v") {
            Str := StrReplace(Str, "v")
        }
        if InStr(Str, "-") {
            Str := StrReplace(Str, "-")
        }
        if InStr(Str, "alpha") {
            Str := StrReplace(Str, "alpha", ".1")
        }
        if InStr(Str, "beta") {
            Str := StrReplace(Str, "beta", ".2")
        }
        return Str
    } catch {
        throw MsgBox("Failed to erase characters from the " Str " string!!!`nThis means the automatic-update system will not be able to interpret the string!!!", "Failed to use ReplaceChar", 0x400010)
	; Goto('Script')
    }
}

; Convert the version to a readable number
Ver2Num(Ver) {
	global
    VerParts := StrSplit(Ver, ".")
    MainVer := VerParts.Has(1) ? VerParts[1] : 0
    MajorVer := VerParts.Has(2) ? VerParts[2] : 0
    MidVer := VerParts.Has(3) ? VerParts[3] : 0
    MinorVer := VerParts.Has(4) ? VerParts[4] : 0
    VerType := VerParts.Has(5) ? VerParts[5] : 0
    VerPatch := VerParts.Has(6) ? VerParts[6] : 0

    return (((MainVer * 100000) + (MajorVer * 10000) + (MidVer * 1000) + (MinorVer * 100)) - (VerType * 10) - VerPatch)
}

QueryUpdate() {
    if NeverAsk != 1 {
        MainGUI.Opt("+Disabled")
        local confirmation := MsgBox("An updated version of the macro was found. This release is " RRN ", and your current version is " VID ".", "New Update Available", 0x1000) ; Set the user's answer to a query asking them to update
        if confirmation = "OK" {
            ; Upd2Ver(RRN)
            local NeverAskConfirmation := MsgBox("Keep recieving notifications?", "New Update Available Options: Notifications", 0x4)
            if NeverAskConfirmation = "No" {
                global NeverAsk := 1
                IniWrite(NeverAsk, A_SettingsWorkingDir "main_config.ini", "Settings", "NeverAsk")
            }
        }
        /*else if (confirmation = "No") {
        MainGUI.Opt("-Disabled")
        } else if (confirmation = "Cancel") {
            NeverAsk := 1
            IniWrite(NeverAsk, A_SettingsWorkingDir "main_config.ini", "Settings", "NeverAsk")
            sd_Reload()
        }*/
        MainGUI.Opt("-Disabled")
    }
}

Upd2Ver(Ver) {
	try WinClose "Start.bat"
    DownloadURL := "https://github.com/NegativeZero01/skibi-defense-macro/releases/download/" Ver "/" Ver ".zip"
    ; NewVersionDir := A_MacroWorkingDir ReleaseName

    try {
        AsyncHttpRequest("GET", "https://api.github.com/repos/NegativeZero01/skibi-defense-macro/releases/latest", sd_AutoUpdateHandler, Map("accept", "application/vnd.github+json"))
    }
    url := latest_release["assets"][1]["browser_download_url"]
    CopySettings := 1
    DeleteOld := 1

    ; Run (A_MacroWorkingDir "submacros\update.bat" "" DownloadURL "" "" A_InitialWorkingDir "" "" 1 "" "" NewVersionDir "")
    Run '"' A_WorkingDir '\submacros\update.bat" "' url '" "' A_MacroWorkingDir '" "' CopySettings '" "' DeleteOld '"'
	ExitApp
}


/*EXTERNAL*/

;(used to update GUI with info fetched from GitHub)
AsyncHttpRequest(method, url, func?, headers?)
{
	req := ComObject("Msxml2.XMLHTTP")
	req.open(method, url, true)
	if IsSet(headers)
		for h, v in headers
			req.setRequestHeader(h, v)
	IsSet(func) && (req.onreadystatechange := func.Bind(req))
	req.send()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AUTO-UPDATE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sd_AutoUpdateHandler(req)
{
	global

	if (req.readyState != 4)
		return

	if (req.status = 200)
	{
		LatestVer := Trim((latest_release := JSON.parse(req.responseText))["tag_name"], "v")
		/*if (VerCompare(VersionID, LatestVer) < 0)
		{
			MainGui["ImageUpdateLink"].Visible := 1
			VersionWidth += 16
			MainGui["VersionText"].Move(494 - VersionWidth), MainGui["VersionText"].Redraw()
			MainGui["ImageGitHubLink"].Move(494 - VersionWidth - 23), MainGui["ImageGitHubLink"].Redraw()
			MainGui["ImageDiscordLink"].Move(494 - VersionWidth - 48), MainGui["ImageDiscordLink"].Redraw()
			try MainGui["SecretButton"].Move(494-VersionWidth-104), MainGui["SecretButton"].Redraw()

			if (LatestVer != IgnoreUpdateVersion)
				nm_AutoUpdateGUI()
		}*/
	}
}