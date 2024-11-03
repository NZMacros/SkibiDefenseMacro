QueryUpdateValidity() {
	if Ver2Num(CRRN) > Ver2Num(CurrentVersion) {
	    QueryUpdate()
	} else if (Ver2Num(CRRN) = Ver2Num(CurrentVersion)) or (Ver2Num(CRRN) < Ver2Num(CurrentVersion)) {
	    MsgBox("No updates found! You are on the latest version (" VersionID ").", "No Updates Found", T60 0x1000)
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
    return JSON.Load(whr.ResponseText)
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

    return ((MainVer * 100000) + (MajorVer * 10000) + (MidVer * 1000) + (MinorVer * 100) + (VerType * 10) + VerPatch)
}

QueryUpdate() {
    confirmation := MsgBox("An updated version of the macro was found. This release is " RRN ", and your current version is " VersionID ". Would you like to download it?", "New Update Available", 0x1 0x1000) ; Set the user's answer to a query asking them to update
    if confirmation = "OK" {
        Upd2Ver(RRN)
    }
}

Upd2Ver(Ver) {
	try WinClose "Start.bat"
    DownloadURL := "https://github.com/NegativeZero01/skibi-defense-macro/releases/download/" Ver "/" Ver ".zip"
    NewVersionDir := A_MacroWorkingDir ReleaseName

    Run (A_MacroWorkingDir "submacros\update.bat" "' DownloadURL '" "' A_InitialWorkingDir '" "' 1 '" "' NewVersionDir '")
	ExitApp
}
