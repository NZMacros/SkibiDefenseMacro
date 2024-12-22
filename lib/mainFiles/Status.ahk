; stats
sd_SetStats() {
	global
	local rundelta := 0, gamedelta := 0, pauseddelta := 0, TotalStatsString, SessionStatsString

	if MacroState = 2 {
		rundelta := (nowUnix() - MacroStartTime)
		if GameStartTime > 0 {
			gamedelta := (nowUnix() - GameStartTime)
		}
		if PausedStartTime > 0 {
			pauseddelta := (nowUnix() - PausedStartTime)
		}
	}

	SessionStatsString :=
	(
		"Runtime: " DurationFromSeconds(SessionRuntime + rundelta) "
		Playtime: " DurationFromSeconds(SessionPlaytime + gamedelta) "
		Paused: " DurationFromSeconds(SessionPausedTime + pauseddelta) "
		Disconnects=" SessionDisconnects "
		Credits=" SessionCredits "
		Wins=" SessionWins "
		Losses=" SessionLosses
	)

	TotalStatsString :=
	(
		"Runtime: " DurationFromSeconds(TotalRuntime + rundelta) "
		Playtime: " DurationFromSeconds(TotalPlaytime + gamedelta) "
		Paused: " DurationFromSeconds(TotalPausedTime + pauseddelta) "
		Disconnects=" TotalDisconnects "
		Credits=" SessionCredits "
		Wins=" TotalWins "
		Losses=" TotalLosses
	)

	MainGUI["SessionStats"].Text := SessionStatsString
	MainGUI["TotalStats"].Text := TotalStatsString
}

; status
sd_SetStatus(newState := 0, newObjective := 0){
	global state, objective, ReversedStatusLog, DebugLogEnabled
	static statuslog := [], status_number := 0

	if ((DebugLogEnabled = 1) && (statuslog.Length = 0) && FileExist(A_SettingsWorkingDir "debug_log.txt")) {
		txt := FileOpen(A_SettingsWorkingDir "debug_log.txt", "r"), c := f := 0
		while ((c < 15) && (!f) && (A_Index < 100)) {
			txt.Seek(- (((p := (A_Index * 128)) > txt.Length) ? (f := txt.Length) : p), 2), log := txt.Read(), StrReplace(log, "`n", , , &c)
		}
		txt.Close()
		Loop Parse SubStr(RTrim(log, "`r`n"), f ? 1 : InStr(log, "`n", , , Max(c - 15, 1)) + 1), "`n", "`r" {
			statuslog.Push(SubStr(A_LoopField, 8))
		}
	}

	if newState != "Detected" {
		if (newState) {
			state := newState
		}
		if (newObjective) {
			objective := newObjective
		}
	}
	stateString := ((newState ? newState : state) . ": " . (newObjective ? newObjective : objective))

	statuslog.Push("[" A_Hour ":" A_Min ":" A_Sec "] " (InStr(stateString, "`n") ? SubStr(stateString, 1, InStr(stateString, "`n")-1) : stateString))
	statuslog.RemoveAt(1, (statuslog.Length > 15) ? statuslog.Length - 15 : 0), len := statuslog.Length
	statuslogtext := ""
	for k, v in statuslog {
		i := ((ReversedStatusLog) ? len + 1 - k : k), statuslogtext .= (((A_Index > 1) ? "`r`n" : "") statuslog[i])
	}

	try {
		MainGui["CurrentState"].Text := stateString
		MainGui["StatusLog"].Text := statuslogtext
	}

	; update status
	DetectHiddenWindows(1)
	if (newState != "Detected") {
		num := ((state = "Grinding") && (!InStr(objective, "Ended"))) ? 1 : ((state = "Returned") && (objective = "Lobby")) ? 2 : 0
		if num != status_number {
			status_number := num
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				try {
					PostMessage(0x5554, status_number, 60 * A_Min + A_Sec)
				}
			}
			if WinExist("background.ahk ahk_class AutoHotkey") {
				try {
					PostMessage(0x5555, status_number, nowUnix())
				}
			}
		}
	}
	if WinExist("Discord.ahk ahk_class AutoHotkey") {
		try {
			SendMessage(0xC2, 0, StrPtr("[" A_DD "/" A_MM "][" A_Hour ":" A_Min ":" A_Sec "] " stateString), , "Discord.ahk ahk_class AutoHotkey")
		}
	}
	DetectHiddenWindows(0)
}

sd_UpdateAction(action) {
	global CurrentAction, PreviousAction
	if CurrentAction != action {
		PreviousAction := CurrentAction
		CurrentAction := action
	}
}


SetLoadProgress(91, MacroName " (Loading: ")
