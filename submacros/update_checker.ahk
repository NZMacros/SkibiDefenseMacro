#Requires AutoHotkey v2.0 
#Include "%A_InitialWorkingDir%\lib\cJSON.ahk"
#Warn All, Off

/*Declarations*\
global CurrentVer := "v0.0.0.0"
global releases := QueryGitHubRepo("NegativeZero01/skibi-defense-macro", "releases")
global ReleaseName := "skibi-defense-macro-" releases[1]["tag_name"]
global RefReleaseName := releases[1]["tag_name"]
global A_MacroWorkingDir := A_InitialWorkingDir "\"

ConvertCurrentVer := ReplaceChar(CurrentVer)
ConvertRefReleaseName := ReplaceChar(RefReleaseName)

if Ver2Num(ConvertRefReleaseName) > Ver2Num(ConvertCurrentVer) {
    QueryUpdate()
} else if (Ver2Num(ConvertRefReleaseName) = Ver2Num(ConvertCurrentVer)) or (Ver2Num(ConvertRefReleaseName) < Ver2Num(ConvertCurrentVer)) {
    MsgBox "No updates found! You are on the latest version.", "No Updates Found (Success)", "T60"
    ExitApp
}


/*Functions*/

; QGHR
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

; ObjToQuery
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

    ; InitHTMLFile
    InitHTMLFile() {
        doc := ComObject("HTMLFile")
        doc.write("<meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
        return doc
    }
}

; ReplaceChar
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
    VerParts := StrSplit(Ver, ".")
    MainVer := VerParts.Has(1) ? VerParts[1] : 0
    MajorVer := VerParts.Has(2) ? VerParts[2] : 0
    MidVer := VerParts.Has(3) ? VerParts[3] : 0
    MinorVer := VerParts.Has(4) ? VerParts[4] : 0
    VerType := VerParts.Has(5) ? VerParts[5] : 0
    VerPatch := VerParts.Has(6) ? VerParts[6] : 0
    Ver := (MainVer * 100000) + (MajorVer * 10000) + (MidVer * 1000) + (MinorVer * 100) + (VerType * 10) + VerPatch
    return Ver
}

; Ask the user if they would like to update to a new version
QueryUpdate() {
    confirmation := MsgBox("An updated version of the macro was found. This release is " RefReleaseName ", and your current version is " CurrentVer ". Would you like to download it?", "New Update Available", 0x1) ; Set the user's answer to a query asking them to update
    if confirmation = "OK" {
        Upd2Ver(RefReleaseName)
        ExitApp
    } else if confirmation = "Cancel" {
        ExitApp
    }
}

; Run update.bat under specific parameters to update the Macro
Upd2Ver(Ver) {
    DownloadURL := "https://github.com/NegativeZero01/skibi-defense-macro/releases/download/" Ver "/" Ver ".zip"
    NewVersionDir := A_MacroWorkingDir "skibi-defense-macro-" Ver

    Run (A_MacroWorkingDir "\submacros\update.bat" "' DownloadURL '" "' A_InitialWorkingDir '" "' 1 '" "' NewVersionDir '")
	ExitApp
}

Run (A_MacroWorkingDir "\submacros\update.bat" "' DownloadURL '" "' A_InitialWorkingDir '" "' 1 '" "' NewVersionDir '")
	ExitApp