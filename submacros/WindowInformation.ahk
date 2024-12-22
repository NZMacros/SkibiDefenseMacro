; 
; Window Information for AHKv2
;

#Requires AutoHotkey v2.0.18
#NoTrayIcon
#SingleInstance Force
SetWorkingDir(A_ScriptDir "\..")
CoordMode("Pixel", "Screen")

global MainGUI
WindowInformationGUI()



WindowInformationGUI() {
    global MainGUI
    
    try {
        TraySetIcon(A_WorkingDir "\img_assets\icons\WindowInformation.ico")
    }
    DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "wstr", "AutoHotkey.WindowSpy")
    
    MainGUI := Gui("+AlwaysOnTop -Resize +MinSize +DPIScale", "Window Information for AHKv2")
    MainGUI.OnEvent("Close", GUIClose)
    MainGUI.OnEvent("Size", WindowInformationSize)
    
    MainGUI.SetFont('s9', "Segoe UI")
    
    MainGUI.AddText(, "Window Title, Class and Process:")
    MainGUI.AddCheckBox("yp xp+200 w120 Right vCtrl_FollowMouse", "Follow Mouse").Value := 1
    MainGUI.AddEdit("xm w320 r5 ReadOnly -Wrap vCtrl_Title")
    MainGUI.AddText(, "Mouse Position:")
    MainGUI.AddEdit("w320 r4 ReadOnly vCtrl_MousePos")
    MainGUI.AddText("w320 vCtrl_CtrlLabel", (txtFocusCtrl := "Focused Control") ":")
    MainGUI.AddEdit("w320 r4 ReadOnly vCtrl_Ctrl")
    MainGUI.AddText(, "Active Window Position:")
    MainGUI.AddEdit("w320 r2 ReadOnly vCtrl_Pos")
    MainGUI.AddText(, "Status Bar Text:")
    MainGUI.AddEdit("w320 r2 ReadOnly vCtrl_SBText")
    MainGUI.AddCheckbox("vCtrl_IsSlow", "Slow TitleMatchMode")
    MainGUI.AddText(, "Visible Text:")
    MainGUI.AddEdit("w320 r2 ReadOnly vCtrl_VisText")
    MainGUI.AddText(, "All Text:")
    MainGUI.AddEdit("w320 r2 ReadOnly vCtrl_AllText")
    MainGUI.AddText("w320 r1 vCtrl_Freeze", (txtNotFrozen := "(Hold Ctrl or Shift to suspend updates)"))
    
    MainGUI.Show("NoActivate")
    WinGetClientPos(&x_temp, &y_temp2, , , "ahk_id " MainGUI.hwnd)
    
    ; MainGUI.horzMargin := x_temp * 96//A_ScreenDPI - 320 ; now using MainGUI.MarginX
    
    MainGUI.txtNotFrozen := txtNotFrozen       ; create properties for future use
    MainGUI.txtFrozen    := "(Updates suspended)"
    MainGUI.txtMouseCtrl := "Control Under Mouse Position"
    MainGUI.txtFocusCtrl := txtFocusCtrl
    
    SetTimer(Update, 250)
}

WindowInformationSize(GUIObj, MinMax, Width, Height) {
    global MainGUI
    
    If (!MainGUI.HasProp("txtNotFrozen")) { ; WindowInformationGUI() not done yet, return until it is
        return
    }
    
    SetTimer(Update, (MinMax = 0) ? 250 : 0) ; suspend updates on minimize
    
    ctrlW := Width - (MainGUI.MarginX * 2) ; ctrlW := Width - horzMargin
    list := "Title, MousePos, Ctrl, Pos, SBText, VisText, AllText, Freeze"
    Loop Parse list, "," {
        MainGUI["Ctrl_" A_LoopField].Move(, , ctrlW)
    }
}

GUIClose(GUIObj) {
    ExitApp()
}

Update() { ; timer, no params
    Try {
        TryUpdate() ; Try
    }
}

TryUpdate() {
    global MainGUI
    
    If (!MainGUI.HasProp("txtNotFrozen")) { ; WindowInformationGUI() not done yet, return until it is
        return
    }
    
    Ctrl_FollowMouse := MainGUI["Ctrl_FollowMouse"].Value
    CoordMode("Mouse", "Screen")
    MouseGetPos(&msX, &msY, &msWin, &msCtrl, 2) ; get ClassNN and hWindow
    actWin := WinExist("A")
    
    if (Ctrl_FollowMouse) {
        curWin := msWin, curCtrl := msCtrl
        WinExist("ahk_id " curWin) ; updating LastWindowFound?
    } else {
        curWin := actWin
        curCtrl := ControlGetFocus() ; get focused control hwnd from active win
    }
    curCtrlClassNN := ""
    Try curCtrlClassNN := ControlGetClassNN(curCtrl)
    
    t1 := WinGetTitle(), t2 := WinGetClass()
    if (curWin = MainGUI.hwnd || t2 = "MultitaskingViewFrame") { ; Our GUI || Alt-tab
        UpdateText("Ctrl_Freeze", MainGUI.txtFrozen)
        return
    }
    
    UpdateText("Ctrl_Freeze", MainGUI.txtNotFrozen)
    t3 := WinGetProcessName(), t4 := WinGetPID()
    
    WinDataText := t1 "`n" ; ZZZ
                 . "ahk_class " t2 "`n"
                 . "ahk_exe " t3 "`n"
                 . "ahk_pid " t4 "`n"
                 . "ahk_id " curWin
    
    UpdateText("Ctrl_Title", WinDataText)
    CoordMode("Mouse", "Window")
    MouseGetPos(&mrX, &mrY)
    CoordMode("Mouse", "Client")
    MouseGetPos(&mcX, &mcY)
    mClr := PixelGetColor(msX, msY, "RGB")
    mClr := SubStr(mClr, 3)
    
    mpText := "Screen:`t" msX ", " msY "`n"
            . "Window:`t" mrX ", " mrY "`n"
            . "Client:`t" mcX ", " mcY " (default)`n"
            . "Color:`t" mClr " (Red=" SubStr(mClr, 1, 2) " Green=" SubStr(mClr, 3, 2) " Blue=" SubStr(mClr, 5) ")"
    
    UpdateText("Ctrl_MousePos", mpText)
    
    UpdateText("Ctrl_CtrlLabel", (Ctrl_FollowMouse ? MainGUI.txtMouseCtrl : MainGUI.txtFocusCtrl) ":")
    
    if (curCtrl) {
        ctrlTxt := ControlGetText(curCtrl)
        WinGetClientPos(&sX, &sY, &sW, &sH, curCtrl)
        ControlGetPos(&cX, &cY, &cW, &cH, curCtrl)
        
        cText := "ClassNN:`t" curCtrlClassNN "`n"
               . "Text:`t" TextMangle(ctrlTxt) "`n"
               . "Screen:`tx: " sX "`ty: " sY "`tw: " sW "`th: " sH "`n"
               . "Client:`tx: " cX "`ty: " cY "`tw: " cW "`th: " cH
    } else {
        cText := ""
    }
    
    UpdateText("Ctrl_Ctrl", cText)
    wX := "", wY := "", wW := "", wH := ""
    WinGetPos(&wX, &wY, &wW, &wH, "ahk_id " curWin)
    WinGetClientPos(&wcX, &wcY, &wcW, &wcH, "ahk_id " curWin)
    
    wText := "Screen:`tx: " wX "`ty: " wY "`tw: " wW "`th: " wH "`n"
           . "Client:`tx: " wcX "`ty: " wcY "`tw: " wcW "`th: " wcH
    
    UpdateText("Ctrl_Pos", wText)
    sbTxt := ""
    
    Loop {
        ovi := ""
        Try ovi := StatusBarGetText(A_Index)
        if (ovi = "") {
            break
        }
        sbTxt .= "(" A_Index "):`t" TextMangle(ovi) "`n"
    }
    
    sbTxt := SubStr(sbTxt,1,-1) ; StringTrimRight, sbTxt, sbTxt, 1
    UpdateText("Ctrl_SBText", sbTxt)
    bSlow := MainGUI["Ctrl_IsSlow"].Value ; GUIControlGet, bSlow, , Ctrl_IsSlow
    
    if (bSlow) {
        DetectHiddenText(False)
        ovVisText := WinGetText() ; WinGetText, ovVisText
        DetectHiddenText(True)
        ovAllText := WinGetText() ; WinGetText, ovAllText
    } else {
        ovVisText := WinGetTextFast(false)
        ovAllText := WinGetTextFast(true)
    }
    
    UpdateText("Ctrl_VisText", ovVisText)
    UpdateText("Ctrl_AllText", ovAllText)
}

; ===========================================================================================
; WinGetText ALWAYS uses the "slow" mode - TitleMatchMode only affects
; WinText/ExcludeText parameters. In "fast" mode, GetWindowText() is used
; to retrieve the text of each control.
; ===========================================================================================
WinGetTextFast(detect_hidden) {    
    controls := WinGetControlsHwnd()
    
    static WINDOW_TEXT_SIZE := 32767 ; Defined in AutoHotkey source.
    
    buf := Buffer(WINDOW_TEXT_SIZE * 2, 0)
    
    text := ""
    
    Loop controls.Length {
        hCtl := controls[A_Index]
        if (!detect_hidden && !DllCall("IsWindowVisible", "ptr", hCtl)) {
            continue
        }
        if (!DllCall("GetWindowText", "ptr", hCtl, "Ptr", buf.ptr, "int", WINDOW_TEXT_SIZE)) {
            continue
        }
        
        text .= StrGet(buf) "`r`n" ; text .= buf "`r`n"
    }
    return text
}

; ===========================================================================================
; Unlike using a pure GUIControl, this function causes the text of the
; controls to be updated only when the text has changed, preventing periodic
; flickering (especially on older systems).
; ===========================================================================================
UpdateText(vCtl, NewText) {
    global MainGUI
    static OldText := {}
    ctl := MainGUI[vCtl], hCtl := Integer(ctl.hwnd)
    
    if (!oldText.HasProp(hCtl) || OldText.%hCtl% != NewText) {
        ctl.Value := NewText
        OldText.%hCtl% := NewText
    }
}

TextMangle(x) {
    elli := false
    if (pos := InStr(x, "`n")) {
        x := SubStr(x, 1, pos - 1), elli := true
    } else if (StrLen(x) > 40) {
        x := SubStr(x, 1, 40), elli := true
    }
    if (elli) {
        x .= " (...)"
    }
    return x
}

suspend_timer() {
    global MainGUI
    SetTimer(Update, 0)
    UpdateText("Ctrl_Freeze", MainGUI.txtFrozen)
}

~*Shift::
~*Ctrl::suspend_timer()

~*Ctrl up::
~*Shift up::SetTimer Update, 250
