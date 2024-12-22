#Requires AutoHotkey v2.0.18
#SingleInstance Force
#Warn VarUnset, Off
SetWorkingDir(A_ScriptDir "\..")

#Include "%A_ScriptDir%\..\lib\"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "mainFiles\Roblox.ahk"
#Include "externalFuncs\DurationFromSeconds.ahk"
#Include "externalFuncs\nowUnix.ahk"

; set version identifier
VersionID := "0.5.2"

MacroName := A_Args[1]
; assign variables from A_Args
if A_Args.Length < 7 || A_Args.Length > 7 {
	Msgbox("This script needs to be run by " MacroName "! You are not supposed to run it manually.")
	ExitApp()
}
MacroVersionID := A_Args[2]
offsetY := A_Args[3]
hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd)
windowDimensions := A_Args[4]
GrindMode := A_Args[5]
Month := A_Args[6]
A_SettingsWorkingDir := A_WorkingDir "\settings\"
InLobby := A_Args[7]

; ▰▰▰▰▰▰▰▰
; INITIAL SETUP
; ▰▰▰▰▰▰▰▰

; set image width and height, in pixels
w := 3000, h := 2900

; prepare graphics and template bitmap
pToken := Gdip_Startup()
pBM := Gdip_CreateBitmap(w, h)
G := Gdip_GraphicsFromImage(pBM)
Gdip_SetSmoothingMode(G, 4)
Gdip_SetInterpolationMode(G, 7)


; IMAGE ASSETS
; store buff icons for drawing
(bitmaps := Map()).CaseSense := 0

#Include "%A_ScriptDir%\..\sd_img_assets\"
#Include "icons\bitmaps.ahk"
#Include "offset\bitmaps.ahk"



; ▰▰▰▰▰▰▰▰▰▰▰▰
; INITIALISE VARIABLES
; ▰▰▰▰▰▰▰▰▰▰▰▰


; OCR TEST
; check that classes needed for OCR function exist and can be created
OCR_enabled := 1
OCR_language := ""
for k, v in Map("Windows.Globalization.Language","{9B0252AC-0C27-44F8-B792-9793FB66C63E}", "Windows.Graphics.Imaging.BitmapDecoder","{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", "Windows.Media.Ocr.OcrEngine","{5BFFA85A-3384-3540-9940-699120D428A8}") {
	CreateHString(k, &hString)
	GUID := Buffer(16), DllCall("ole32\CLSIDFromString", "WStr", v, "Ptr", GUID)
	result := DllCall("Combase.dll\RoGetActivationFactory", "Ptr", hString, "Ptr", GUID, "PtrP", &pClass := 0)
	DeleteHString(hString)
	if result != 0 {
		OCR_enabled := 0
		break
	}
}
if OCR_enabled = 1 {
	list := OCR("ShowAvailableLanguages")
	for lang in ["ko", "en-"] { ; priority list
		Loop Parse list, "`n", "`r" {
			if (InStr(A_LoopField, lang) = 1) {
				OCR_language := A_LoopField
				break 2
			}
		}
	}
	if OCR_language = "" {
		if ((OCR_language := SubStr(list, 1, InStr(list, "`n") - 1)) = "") {
			MsgBox("No OCR-supported languages are installed on your system! Please install a supported language as a secondary language on Windows.", "Warning", 0x1030)
		}
	}
}


; CREDITS MONITORING
; credit_values format: (A_Min):value
credit_values := Map()

; obtain start credits
start_credits := (OCR_enabled ? DetectCredits() : 0)

; credits_12h format: (minutes DIV 4):value
credits_12h := Map()
credits_12h[180] := start_credits

; INFO FROM MAIN SCRIPT
; status_changes format: (A_Min * 60 + A_Sec+1):status_number (0 = Other, 1 = Game, 2 = Lobby)
status_changes := Map()

; stats format: number:[string, value]
stats := [["Disconnects", 0], ["Games Played", 0], ["Wins", 0], ["Losses", 0]]

; enable receiving of messages
OnMessage(0x5554, SetStatus, 255)
OnMessage(0x5555, IncrementStat, 255)
OnMessage(0x5556, SetLobbyState, 255)



; ▰▰▰▰▰▰▰▰
; STARTUP REPORT
; ▰▰▰▰▰▰▰▰


; OBTAIN DATA
; detect OS version
OS_version := "Unknown"
for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem") {
	OS_version := Trim(StrReplace(StrReplace(StrReplace(StrReplace(objItem.Caption, "Microsoft"), "Майкрософт"), "مايكروسوفت"), "微软"))
}

; read information from main_config.ini
Loop 3 {
	ChapterName%A_Index% := IniRead(A_SettingsWorkingDir "main_config.ini", "Game", "ChapterName" A_Index, "N/A")
}

; FORM MESSAGE
message := "Hourly Reports will start sending in **" DurationFromSeconds(60 * (59 - A_Min) + (60 - A_Sec), "m'm 's's'") "**\n"
 . "Version: **StatMonitor v" VersionID "**\n"
 . "Detected OS: **" OS_version "**\n"
 . (OCR_enabled ? "OCR Status: **Enabled (" OCR_language ")**\nCurrent Credits: **" (start_credits ? FormatNumber(start_credits) : "Unknown") "**"
	 : "OCR Status: **Disabled; Credit Graphs will be blank.**")

message .= (((IsSet(MacroVersionID)) ? ("\n\nMacro: **" MacroName " v" MacroVersionID "**\n") : ("\n\nMacro: **Unknown**\n"))
 . ("Chapters: **" ChapterName1 ", " ChapterName2 " & " ChapterName3 "**\n"))


; SEND STARTUP REPORT
; create postdata
postdata :=
(
'
{
	"embeds": [{
		"title": "[' A_Hour ':' A_Min ':' A_Sec '] Startup Report",
		"description": "' message '",
		"color": "14052794"
	}]
}
'
)

; post to status
Send_WM_COPYDATA(postdata, "Discord.ahk ahk_class AutoHotkey")



; ▰▰▰▰▰▰▰▰▰
; CREATE TEMPLATE
; ▰▰▰▰▰▰▰▰▰


; DRAW REGIONS
; draw background (fill with rounded dark grey rectangle)
pBrush := Gdip_BrushCreateSolid(0xff121212), Gdip_FillRoundedRectangle(G, pBrush, -1, -1, w + 1, h + 1, 60), Gdip_DeleteBrush(pBrush)

; regions format: region_name:[x,y,w,h]
; subtracting height pulls up from bottom and vice versa
regions := Map("Stats", [w - 1560 - 120, 120, 1560, h - 150]
 , "Info", [w - 2500 - 400, 120, 1200, h - 150])

stat_regions := Map("LastHour", [regions["Stats"][1] + 100, regions["Stats"][2] + 100, regions["Stats"][3] - 200, 1206]
 , "Session", [regions["Stats"][1] + 100, regions["Stats"][2] + 1406, regions["Stats"][3] - 200, 1289]
 , "Stats", [regions["Info"][1] + 100, regions["Info"][2] + 100, regions["Info"][3] - 200, 1800]
 , "Info", [regions["Info"][1] + 100, regions["Info"][2] + 2100, regions["Info"][3] - 200, regions["Info"][4] - 4940 - 100])

; draw region backgrounds (dark grey background for each region)
for k, v in regions {
	pPen := Gdip_CreatePen(0xff282628, 10), Gdip_DrawRoundedRectangle(G, pPen, v[1], v[2], v[3], v[4], 20), Gdip_DeletePen(pPen)
	pBrush := Gdip_BrushCreateSolid(0xff201e20), Gdip_FillRoundedRectangle(G, pBrush, v[1], v[2], v[3], v[4], 20), Gdip_DeleteBrush(pBrush)
}
for k, v in stat_regions {
	pPen := Gdip_CreatePen(0xff353335, 10), Gdip_DrawRoundedRectangle(G, pPen, v[1], v[2], v[3], v[4], 20), Gdip_DeletePen(pPen)
	pBrush := Gdip_BrushCreateSolid(0xff2c2a2c), Gdip_FillRoundedRectangle(G, pBrush, v[1], v[2], v[3], v[4], 20), Gdip_DeleteBrush(pBrush)
}


; DRAW GRAPHS AND OTHER ASSETS
; declare coordinate bounds for each graph
graph_regions := Map("Credits", [stat_regions["LastHour"][1] + 200, stat_regions["LastHour"][2] + 650, 1080, 480]
 , "Credits12h", [stat_regions["Session"][1] + 200, stat_regions["Session"][2] + 734, 1080, 480])

; draw graph grids and axes
pPen := Gdip_CreatePen(0x40c0c0f0, 4)
Loop 61 {
	n := (Mod(A_Index, 10) = 1) ? 45 : 25

	if (Mod(A_Index, 10) = 1) {
		i := A_Index
		for k, v in graph_regions {
			Gdip_DrawLine(G, pPen, v[1] + v[3] * (i - 1)//60, v[2], v[1] + v[3] * (i - 1)//60, v[2] + v[4])
		}
	}

}
for k, v in graph_regions {
	if ((v[4] = 280) || (v[4] = 400)) {
		Gdip_DrawLine(G, pPen, v[1] - 60, v[2] + v[4]//2, v[1] + v[3] + 60, v[2] + v[4]//2)
	} else if (v[4] = 480) {
		Loop 3 {
			Gdip_DrawLine(G, pPen, v[1] - 60, v[2] + v[4] * A_Index//4, v[1] + v[3] + 60, v[2] + v[4] * A_Index//4)
		}
	}
}

; draw graph backgrounds
pBrush := Gdip_BrushCreateSolid(0x80141414)
for k, v in graph_regions {
	Gdip_FillRectangle(G, pBrush, v[1]-60, v[2], v[3]+120, v[4])
}
Gdip_DeleteBrush(pBrush), Gdip_DeletePen(pPen)
pBrush := Gdip_BrushCreateSolid(0x40cc0000)
for k, v in ["Credits", "Credits12h"] {
	Gdip_FillRectangle(G, pBrush, graph_regions[v][1], graph_regions[v][2], graph_regions[v][3], graph_regions[v][4])
}
Gdip_DeleteBrush(pBrush)

; ▰▰▰▰
; TESTING
; ▰▰▰▰
/*
start_time := A_Now
status_changes[A_Min * 60 + A_Sec] := 0

credit_values[0] := 1241244
credits_12h[180] := 14388439

Loop 60 {
	credit_values[A_Index] := credit_values[A_Index - 1] + ((Mod(A_Index, 15) < 4) ? 123468123 : 58340000)
}

Loop 3601 {
	if (Mod(A_Index, 5) = 1) {
		x := Random(0, 6)
	}
}

status_changes := Map(0, 2, 180, 1, 780, 2, 1080, 1, 1680, 2, 1784, 3 ,1832, 2, 1980, 1, 2100, 3, 2120, 1, 2580, 2, 2880, 1, 3480, 2)

stats[1][2] := 1000
stats[2][2] := 100

start_credits := 58348164
start_time := DateAdd(start_time, -1, "Hours")

SendHourlyReport()
KeyWait("F4", "D")
Reload()
ExitApp()
*/

; ▰▰▰▰▰
; MAIN LOOP
; ▰▰▰▰▰

; startup finished, set start time
start_time := A_Now
status_changes[A_Min * 60 + A_Sec] := 0

; set emergency switches in case of time error
last_credits := last_report := time := 0

; indefinite loop of detection and reporting
Loop {
	; obtain current time and wait until next 6-second interval
	DllCall("GetSystemTimeAsFileTime", "int64p", &time)
	Sleep (60000000 - Mod(time, 60000000))//10000 + 100
	time_value := (60 * A_Min + A_Sec)//6

	; detect credits every minute if OCR is enabled
	if (((OCR_enabled = 1) && ((Mod(time_value, 10) = 0) || (last_credits && time > last_credits + 580000000))) && (InLobby = 2)) {
		DetectCredits()
		DllCall("GetSystemTimeAsFileTime", "int64p", &time)
		last_credits := time
	}

	; send report every hour
	if ((time_value = 0) || (last_report && time > last_report + 35980000000)) {
		SendHourlyReport()
		DllCall("GetSystemTimeAsFileTime", "int64p", &time)
		last_report := time
	}
}



; ▰▰▰▰▰
; FUNCTIONS
; ▰▰▰▰▰

/**
 * @description Uses OCR to detect the current credits value in SD
 * @returns Current credits value or 0 on failure
 * @note Function is a WIP, and OCR readings are not 100% reliable!
*/
DetectCredits() {
	global credit_values, start_credits, start_time, OCR_language

	; check roblox window exists
	hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd), offsetY := GetYOffset(hwnd)
	if !(windowHeight >= 500) {
		return 0
	}

	; initialise array to store detected values and get bitmap and effect ready
	detected := Map()
	pBM := Gdip_BitmapFromScreen(windowX + windowWidth//6 + 22 "|" windowY + offsetY "|160|52")
	pEffect := Gdip_CreateEffect(5,-80, 30)

	; detect credits, enlarge image if necessary
	Loop 25 {
		i := A_Index
		Loop 2 {
			pBMNew := Gdip_ResizeBitmap(pBM, ((A_Index = 1) ? (250 + i * 20) : (750 - i * 20)), 36 + i * 4, 2)
			Gdip_BitmapApplyEffect(pBMNew, pEffect)
			hBM := Gdip_CreateHBITMAPFromBitmap(pBMNew)
			; Gdip_SaveBitmapToFile(pBMNew, i A_Index ".png")
			Gdip_DisposeImage(pBMNew)
			pIRandomAccessStream := HBitmapToRandomAccessStream(hBM)
			DllCall("DeleteObject", "Ptr", hBM)
			try {
				detected[v := ((StrLen((n := RegExReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(OCR(pIRandomAccessStream, OCR_language), "o", "0"), "i", "1"), "l", "1"), "a", "4"), "c", ""), "z", "2"), "\D"))) > 0) ? n : 0)] := detected.Has(v) ? [detected[v][1] + 1, detected[v][2] " " i . A_Index] : [1, i . A_Index]
			}
		}
	}

	; clean up
	Gdip_DisposeImage(pBM), Gdip_DisposeEffect(pEffect)
	DllCall("psapi.dll\EmptyWorkingSet", "UInt", -1)

	; evaluate current credits
	current_credits := 0
	for k, v in detected {
		if ((v[1] > 2) && (k > current_credits)) {
			current_credits := k
		}
	}

	; update credit values array and write values to ini
	index := (A_Min = "00") ? 60 : Integer(A_Min)
	if (current_credits) {
		credit_values[index] := current_credits
		if (FileExist(A_SettingsWorkingDir "main_config.ini") && (IsSet(start_time))) {
			session_time := DateDiff(A_Now, start_time, "S")
			session_total := current_credits - start_credits
			try {
				IniWrite((FormatNumber(session_total)), A_SettingsWorkingDir "main_config.ini", "Status", "SessionCredits")
				IniWrite((FormatNumber(session_total)), A_SettingsWorkingDir "main_config.ini", "Status", "TotalCredits")
			}
			try {
				IniWrite((FormatNumber(session_total * 3600 / session_time)), A_SettingsWorkingDir "main_config.ini", "Status", "HourlyCreditsAverage")
			}
		}
		return current_credits
	} else {
		return 0
	}
}

/**
 * @description Creates a report (image) from the total credit arrays and sends it to Discord
*/
SendHourlyReport() {
	global pBM, regions, stat_regions, credit_values, credits_12h, status_changes, start_time, start_credits, stats, graph_regions, VersionID, MacroVersionID, OS_version, bitmaps, OCR_enabled, OCR_language
	static credits_average := 0, credits_earned := 0, Lobby_time := 0, Game_time := 0, Other_time := 0, stats_old := [["Disconnects", 0], ["Games Played", 0], ["Wins", 0], ["Losses", 0]]

	if credit_values.Count > 0 {
		; identify and exterminate misread values
		max_value := maxX(credit_values)

		str := ""
		for k, v in credit_values {
			if v < max_value//8 { ; any value smaller than this is regarded as a misread
				str .= (StrLen(str) ? " " : "") k
			}
		}

		Loop Parse str, A_Space {
			credit_values.Delete(Integer(A_LoopField))
		}

		min_value := minX(credit_values), max_value := Max(maxX(credit_values), min_value + 1000), range_value := max_value - min_value
	} else {
		min_value := 0, max_value := 1000, range_value := 1000
	}

	; populate credit_values array, fill missing values
	enum := credit_values.__Enum()
	enum.Call(&x2, &y2)
	for x1, y1 in credit_values {
		if enum.Call(&x2, &y2) = 0 {
			if x1 < 60 {
				Loop (60 - x1) {
					credit_values[x1 + A_Index] := y1
				}
			}
			break
		}
		delta_x := x2 - x1
		if delta_x > 1 {
			delta_y := y2 - y1
			Loop (delta_x - 1) {
				credit_values[x1 + A_Index] := y1 + A_Index * (delta_y / delta_x)
			}
		}
	}
	Loop 61 {
		if (!credit_values.Has(A_Index - 1)) {
			credit_values[A_Index - 1] := min_value
		}
	}

	; update credit gradients and 12h data
	credit_gradients := Map()
	for k, v in credit_values {
		if k < 60 {
			credit_gradients[k + 1] := (credit_values[k + 1]-credit_values[k]) / 60
		}
	}
	credit_gradients[0] := credit_gradients[1], credit_gradients[61] := credit_gradients[60]

	Loop 166 {
		try {
			credits_12h[A_Index - 1] := credits_12h[A_Index + 14]
		}
	}
	Loop 15 {
		credits_12h[A_Index + 165] := credit_values[4 * A_Index]
	}

	; set time arrays (10 min interval and 2 hour for 12h graph)
	times := [], times_12h := []
	time := A_Now
	Loop 7 {
		times.InsertAt(1, FormatTime(time, "HH:mm")), time := DateAdd(time, -10, "m")
	}
	time := DateAdd(time, 70, "m")
	Loop 7 {
		times_12h.InsertAt(1, FormatTime(time, "HH:mm")), time := DateAdd(time, -2, "h")
	}

	; create report bitmap and graphics
	pBMReport := Gdip_CloneBitmap(pBM)
	G := Gdip_GraphicsFromImage(pBMReport)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetInterpolationMode(G, 7)

	; set variable graph bounds
	min_gradient := 0, max_gradient := Max(maxX(credit_gradients), min_gradient + 1000), range_gradient := Floor(max_gradient - min_gradient)
	min_12h := minX(credits_12h), max_12h := Max(maxX(credits_12h), min_12h + 1000), range_12h := max_12h - min_12h

	; draw times
	for k, v in Map("Credits", "Times", "Credits12h", "times_12h") {
		Loop 7 {
			Gdip_TextToGraphics(G, %v%[A_Index], "s30 Center Bold cffffffff x" graph_regions[k][1] + graph_regions[k][3] * (A_Index - 1)//6 " y" graph_regions[k][2] + graph_regions[k][4] + 14, "Segoe UI")
		}
	}

	; draw graphs
	for k, v in graph_regions {
		pBMGraph := Gdip_CreateBitmap(v[3] + 8, v[4] + 8)
		G_Graph := Gdip_GraphicsFromImage(pBMGraph)
		Gdip_SetSmoothingMode(G_Graph, 4)
		Gdip_SetInterpolationMode(G_Graph, 7)

		switch k {
			case "Credits":
			Loop 5 {
				Gdip_TextToGraphics(G, FormatNumber(max_value-(range_value * (A_Index - 1))//4), "s28 Right Bold cffffffff x" v[1] - 310 " y" v[2] + v[4] * (A_Index-1)//4 - 20, "Segoe UI", 240)
			}

			enum := status_changes.__Enum()
			enum.Call(&m)
			for i, j in status_changes {
				if enum.Call(&m) = 0 {
					m := 3599
				}
				points := []
				points.Push([4 + i * v[3] / 3600, 4 + v[4]])
				points.Push([4 + i * v[3] / 3600, 4 + v[4] - (credit_values[i//60] + (i / 60 - i//60) * (credit_values[i//60 + 1]-credit_values[i//60]) - min_value) / range_value * v[4]])
				for x, y in credit_values {
					((y != "") && (x >= i/60 && x <= m/60)) && points.Push([4 + x * v[3] / 60, 4 + v[4] - ((y > 0) ? (((y - min_value) / range_value) * v[4]) : 0)])
				}
				points.Push([4 + m * v[3] / 3600, 4 + v[4] - (credit_values[m//60] + (m / 60 - m//60) * (credit_values[m//60 + 1] - credit_values[m//60]) - min_value) / range_value * v[4]])
				points.Push([4 + m * v[3] / 3600, 4 + v[4]])

				colour := (j = 1) ? 0xff8f34eb
				 : (j = 2) ? 0xffd6d013
				 : 0xff859aad

				pBrush := Gdip_BrushCreateSolid(colour - 0x80000000)
				Gdip_FillPolygon(G_Graph, pBrush, points)
				Gdip_DeleteBrush(pBrush)

				points.RemoveAt(1), points.Pop()
				pPen := Gdip_CreatePen(colour, 6)
				Gdip_DrawLines(G_Graph, pPen, points)
				Gdip_DeletePen(pPen)
			}


			case "Credits12h":
			Loop 5 {
				Gdip_TextToGraphics(G, FormatNumber(max_12h - Floor((range_12h * (A_Index-1)) / 4)), "s28 Right Bold cffffffff x" v[1] - 310 " y" v[2] + v[4] * (A_Index - 1)//4 - 20, "Segoe UI", 240)
			}
			
			points := []
			credits_12h.__Enum().Call(&x), points.Push([4 + v[3] * x / 180, 4 + v[4]])
			for x, y in credits_12h {
				(y != "") && points.Push([4 + v[3] * (max_x := x)/180, 4 + v[4] - ((y - min_12h) / range_12h) * v[4]])
			}
			points.Push([4 + v[3] * max_x / 180, 4 + v[4]])
			colour := 0xff0e8bf0

			pBrush := Gdip_BrushCreateSolid(colour - 0x80000000)
			Gdip_FillPolygon(G_Graph, pBrush, points)
			Gdip_DeleteBrush(pBrush)

			points.RemoveAt(1), points.Pop()
			pPen := Gdip_CreatePen(colour, 6)
			Gdip_DrawLines(G_Graph, pPen, points)
			Gdip_DeletePen(pPen)
		}
	}

	; calculate times
	time := DateAdd(DateAdd(A_Now, -A_Min, "Minutes"), -A_Sec, "Seconds")
	session_time := DateDiff(time, start_time, "Seconds")

	local hour_Game_time, hour_Lobby_time, hour_Other_time
		, hour_Game_percent, hour_Lobby_percent, hour_Other_percent
		, Game_percent, Lobby_percent, Other_percent

	status_list := ["Game", "Lobby", "Other"]
	for i, j in status_list {
		hour_%j%_time := 0
	}
	enum := status_changes.__Enum()
	enum.Call(&m)
	for i, j in status_changes {
		if (enum.Call(&m) = 0) {
			m := 3600
		}
		status := (j = 1) ? "Game"
		 : (j = 2) ? "Lobby"
		 : "Other"
		hour_%status%_time += m - i
	}
	for i, j in status_list {
		%j%_time += hour_%j%_time
	}

	unix_now := DateDiff(SubStr(A_NowUTC, 1, 10), "19700101000000", "Seconds")

	; calculate percentages
	cumul_hour := 0, cumul_hour_rounded := 0
	cumul_total := 0, cumul_total_rounded := 0
	for i, j in status_list {
		cumul_hour += hour_%j%_time * 100 / 3600
		hour_%j%_percent := Round(cumul_hour) - cumul_hour_rounded . "%"
		cumul_hour_rounded := Round(cumul_hour)

		cumul_total += %j%_time * 100 / session_time
		%j%_percent := Round(cumul_total) - cumul_total_rounded . "%"
		cumul_total_rounded := Round(cumul_total)
	}

	; session stats
	current_credits := credit_values[60]
	session_total := current_credits - start_credits

	; last hour stats
	hour_increase := (credit_values[60] - credit_values[0] < credits_earned) ? "0" : "1"
	credits_earned := credit_values[60] - credit_values[0]
	average_difference := credits_average ? ((session_total * 3600 / session_time) - credits_average) : 0
	credits_change := (average_difference = 0) ? "(+0%)" : (average_difference > 0) ? "(+" . Ceil(average_difference * 100 / Abs(credits_average)) . "%)" : "(" . Floor(average_difference * 100 / Abs(credits_average)) . "%)"
	credits_average := session_total * 3600 / session_time


	; WRITE STATS
	; section 1: last hour
	Gdip_TextToGraphics(G, "LAST HOUR", "s64 Center Bold cffffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 " y" stat_regions["LastHour"][2] + 4, "Segoe UI")

	Gdip_TextToGraphics(G, "Credits Earned", "s60 Right Bold ccfffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 - 40 " y" stat_regions["LastHour"][2] + 96, "Segoe UI")
	pos := Gdip_TextToGraphics(G, FormatNumber(credits_earned), "s60 Left Bold cffffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 + 40 " y" stat_regions["LastHour"][2] + 96, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)
	pBrush := Gdip_BrushCreateSolid(hour_increase ? 0xff00ff00 : 0xffff0000), (x) && Gdip_FillPolygon(G, pBrush, hour_increase ? [[x + 45, stat_regions["LastHour"][2] + 119], [x + 20, stat_regions["LastHour"][2] + 161], [x + 70, stat_regions["LastHour"][2]+161]] : [[x + 20, stat_regions["LastHour"][2] + 119], [x + 70, stat_regions["LastHour"][2] + 119], [x + 45, stat_regions["LastHour"][2] + 161]]), Gdip_DeleteBrush(pBrush)

	Gdip_TextToGraphics(G, "Hourly Average", "s60 Right Bold ccfffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 - 40 " y" stat_regions["LastHour"][2] + 180, "Segoe UI")
	pos := Gdip_TextToGraphics(G, FormatNumber(credits_average), "s60 Left Bold cffffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 + 40 " y" stat_regions["LastHour"][2] + 180, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)
	Gdip_TextToGraphics(G, credits_change, "s60 Left Bold c" . (InStr(credits_change, "-") ? "ffff0000" : InStr(credits_change, "+0") ? "ff888888" : "ff00ff00") . " x" x " y" stat_regions["LastHour"][2] + 180, "Segoe UI")

	angle := -90
	for i, j in status_list {
		colour := (j = "Game") ? 0xff8f34eb
		 : (j = "Lobby") ? 0xffd6d013
		 : 0xff859aad
		pBrush := Gdip_BrushCreateSolid(colour)
		Gdip_FillPie(G, pBrush, stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 - 464, stat_regions["LastHour"][2] + 318, 280, 280, angle, hour_%j%_time / 10)
		angle += hour_%j%_time / 10

		Gdip_FillRoundedRectangle(G, pBrush, stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 + 74, stat_regions["LastHour"][2] + 348 + (A_Index-1)*88, 44, 44, 4)
		Gdip_DeleteBrush(pBrush)

		Gdip_TextToGraphics(G, j, "s48 Right Bold ccfffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 + 56 " y" stat_regions["LastHour"][2] + 335 + (A_Index - 1) * 88, "Segoe UI")
		Gdip_TextToGraphics(G, DurationFromSeconds(hour_%j%_time), "s48 Left Bold cefffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 + 135 " y" stat_regions["LastHour"][2] + 335 + (A_Index - 1) * 88, "Segoe UI")
		Gdip_TextToGraphics(G, hour_%j%_percent, "s48 Right Bold cefffffff x" stat_regions["LastHour"][1] + stat_regions["LastHour"][3]//2 + 476 " y" stat_regions["LastHour"][2] + 335 + (A_Index - 1) * 88, "Segoe UI")
	}

	; section 2: session
	Gdip_TextToGraphics(G, "SESSION", "s64 Center Bold cffffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 " y" stat_regions["Session"][2] + 4, "Segoe UI")

	Gdip_TextToGraphics(G, "Current Credits", "s60 Right Bold ccfffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 - 40 " y" stat_regions["Session"][2] + 96, "Segoe UI")
	Gdip_TextToGraphics(G, FormatNumber(current_credits), "s60 Left Bold cffffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 + 40 " y" stat_regions["Session"][2] + 96, "Segoe UI")

	Gdip_TextToGraphics(G, "Session Credits", "s60 Right Bold ccfffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 - 40 " y" stat_regions["Session"][2] + 180, "Segoe UI")
	Gdip_TextToGraphics(G, FormatNumber(session_total), "s60 Left Bold cffffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 + 40 " y" stat_regions["Session"][2] + 180, "Segoe UI")

	Gdip_TextToGraphics(G, "Session Time", "s60 Right Bold ccfffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 - 40 " y" stat_regions["Session"][2] + 264, "Segoe UI")
	Session_time_F := DurationFromSeconds(session_time)
	Gdip_TextToGraphics(G, session_time_F, "s60 Left Bold cffffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 + 40 " y" stat_regions["Session"][2] + 264, "Segoe UI")

	angle := -90
	for i, j in status_list {
		colour := (j = "Game") ? 0xff8f34eb
		 : (j = "Lobby") ? 0xffd6d013
		 : 0xff859aad
		pBrush := Gdip_BrushCreateSolid(colour)
		Gdip_FillPie(G, pBrush, stat_regions["Session"][1] + stat_regions["Session"][3]//2 - 464, stat_regions["Session"][2] + 402, 280, 280, angle, %j%_time/session_time * 360)
		angle += %j%_time/session_time * 360

		Gdip_FillRoundedRectangle(G, pBrush, stat_regions["Session"][1] + stat_regions["Session"][3]//2 + 74, stat_regions["Session"][2] + 432 + (A_Index - 1) * 88, 44, 44, 4)
		Gdip_DeleteBrush(pBrush)

		Gdip_TextToGraphics(G, j, "s48 Right Bold ccfffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 + 56 " y" stat_regions["Session"][2] + 419 + (A_Index - 1) * 88, "Segoe UI")
		Gdip_TextToGraphics(G, DurationFromSeconds(%j%_time), "s48 Left Bold cefffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 + 135 " y" stat_regions["Session"][2] + 419 + (A_Index - 1) * 88, "Segoe UI")
		Gdip_TextToGraphics(G, %j%_percent, "s48 Right Bold cefffffff x" stat_regions["Session"][1] + stat_regions["Session"][3]//2 + 476 " y" stat_regions["Session"][2] + 419 + (A_Index - 1) * 88, "Segoe UI")
	}


	; section 5: stats
	pos := Gdip_TextToGraphics(G, "STATS", "s64 Center Bold cffffffff x" stat_regions["Stats"][1] + stat_regions["Stats"][3]//2 " y" stat_regions["Stats"][2] + 4, "Segoe UI")
	y := SubStr(pos, InStr(pos, "|", , , 1) + 1, InStr(pos, "|", , , 2) - InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 3) + 1, InStr(pos, "|", , , 4) - InStr(pos, "|", , , 3) - 1) + 4 + 40 ; y level between first stat and title

	for i, j in stats {
		Gdip_TextToGraphics(G, j[1], "s60 Right Bold ccfffffff x" stat_regions["Stats"][1] + stat_regions["Stats"][3]//4 + 180 " y" y, "Segoe UI") ;  stat text
		pos := Gdip_TextToGraphics(G, j[2], "s60 Left Bold cffffffff x" stat_regions["Stats"][1] + stat_regions["Stats"][3]//2 + 50 " y" y, "Segoe UI") ; current amount
		if j[2] > stats_old[i][2] {
			x := stat_regions["Stats"][1] + stat_regions["Stats"][3]//2 + 270 ; arrow
			pBrush := Gdip_BrushCreateSolid((j[1] = "Disconnects") ? 0xffff0000 : 0xff00ff00), Gdip_FillPolygon(G, pBrush, [[x + 45, y + 23], [x + 20, y + 65], [x + 70, y + 65]]), Gdip_DeleteBrush(pBrush)
			x := stat_regions["Stats"][1] + stat_regions["Stats"][3]//2 + 352 ; amount increased
			Gdip_TextToGraphics(G, j[2] - stats_old[i][2], "s40 Left Bold cafffffff x" x " y" y + 16, "Segoe UI")
		} else {
			pBrush := Gdip_BrushCreateSolid(0xff666666)
			Gdip_FillRoundedRectangle(G, pBrush, stat_regions["Stats"][1] + stat_regions["Stats"][3]//2 + 260, y + 36, 50, 12, 6)
			Gdip_DeleteBrush(pBrush)
		}
		y := SubStr(pos, InStr(pos, "|", , , 1) + 1, InStr(pos, "|", , , 2) - InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 3) + 1, InStr(pos, "|", , , 4) - InStr(pos, "|", , , 3) - 1) - 4 + 30 ; y level between stats
	}

	; section 6: info
	; row 1: grind mode
	y := stat_regions["Info"][2] + 60
	pos := Gdip_TextToGraphics(G, "Grind Mode: " (GrindMode ? (GrindMode) : ("Unknown")), "s56 Center Bold c00ffffff x" stat_regions["Info"][1] + stat_regions["Info"][3]//2 " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1)

	pos := Gdip_TextToGraphics(G, "Grind Mode: ", "s56 Left Bold cafffffff x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)

	Gdip_TextToGraphics(G, GrindMode ? (GrindMode) : ("Unknown"), "s56 Left Bold c" (GrindMode ? "ff4fdf26" : "ffcc0000") " x" x " y" y, "Segoe UI")

	; row 2: statmonitor version
	y := stat_regions["Info"][2] + 140
	pos := Gdip_TextToGraphics(G, "StatMonitor v" VersionID, "s56 Center Bold c00ffffff x" stat_regions["Info"][1] + stat_regions["Info"][3]//2 " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1)

	pos := Gdip_TextToGraphics(G, "StatMonitor v" VersionID, "s56 Left Bold cafffffff x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)

	; row 3: report timestamp
	y := stat_regions["Info"][2] + 220
	FormatStr := Buffer(256), DllCall("GetLocaleInfoEx", "Ptr", 0, "UInt", 0x20, "Ptr", FormatStr.Ptr, "Int", 256)
	DateStr := Buffer(512), DllCall("GetDateFormatEx", "Ptr", 0, "UInt", 0, "Ptr", 0, "Str", StrReplace(StrReplace(StrReplace(StrReplace(StrGet(FormatStr), ", dddd"), "dddd, "), " dddd"), "dddd "), "Ptr", DateStr.Ptr, "Int", 512, "Ptr", 0)
	pos := Gdip_TextToGraphics(G, times[1] " - " times[7] " • " StrGet(DateStr), "s56 Center Bold c00ffffff x" stat_regions["Info"][1] + stat_regions["Info"][3]//2 " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1)

	pos := Gdip_TextToGraphics(G, times[1] " - " times[7] " ", "s56 Left Bold cffffda3d x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)

	pos := Gdip_TextToGraphics(G, "•", "s56 Left Bold cafffffff x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)

	Gdip_TextToGraphics(G, StrGet(DateStr), "s56 Left Bold cffffda3d x" x " y" y, "Segoe UI")

	; row 4: OCR status
	y := stat_regions["Info"][2] + 300
	pos := Gdip_TextToGraphics(G, "OCR: " (OCR_enabled ? ("Enabled (" OCR_language ")") : ("Disabled (" ((A_OSVersion < "WIN") ? "Debloated" : "Not Installed") ")")), "s56 Center Bold c00ffffff x" stat_regions["Info"][1] + stat_regions["Info"][3]//2 " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1)

	pos := Gdip_TextToGraphics(G, "OCR: ", "s56 Left Bold cafffffff x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1) + SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)

	Gdip_TextToGraphics(G, OCR_enabled ? ("Enabled (" OCR_language ")") : ("Disabled (" ((A_OSVersion < "WIN") ? "Debloated" : "Not Installed") ")"), "s56 Left Bold c" (OCR_enabled ? "ff4fdf26" : "ffcc0000") " x" x " y" y, "Segoe UI")

	; row 5: windows version
	y := stat_regions["Info"][2] + 380
	Gdip_TextToGraphics(G, os_version, "s56 Center Bold cff04b4e4 x" stat_regions["Info"][1] + stat_regions["Info"][3]//2 " y" y, "Segoe UI")

	; row 6: SDM information
	if (IsSet(MacroVersionID)) {
		y := stat_regions["Info"][2] + 460
		x := stat_regions["Info"][1] + stat_regions["Info"][3]//2 - 50

		pos := Gdip_TextToGraphics(G, MacroName " v" MacroVersionID, "s56 Left Bold c00ffffff x" x - 675 " y" y + 100, "Segoe UI")
		x -= SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1) / 2
		pos := Gdip_TextToGraphics(G, "discord.gg/Nfn6czrzbv", "s56 Left Bold c00ffffff x" x + 445 " y" y, "Segoe UI")
		x -= SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1) / 2

		pos := Gdip_TextToGraphics(G, "discord.gg/Nfn6czrzbv", "s56 Left Bold Underline cff3366cc x" x + 445 " y" y, "Segoe UI")
		x := SubStr(pos, 1, InStr(pos, "|", , , 1) - 1)+SubStr(pos, InStr(pos, "|", , , 2) + 1, InStr(pos, "|", , , 3) - InStr(pos, "|", , , 2) - 1)
		if Month = ("September" || "October" || "November") {
			Gdip_DrawImage(G, bitmaps["pBMCursedIcon"], x - 775, y + 100, 80, 80)
		} else if (Month = ("December" || "January" || "February")) {
			Gdip_DrawImage(G, bitmaps["pBMJollyIcon"], x - 775, y + 100, 80, 80)
		} else if (Month = ("March" || "April" || "May")) {
			Gdip_DrawImage(G, bitmaps["pBMEasterIcon"], x - 775, y + 100, 80, 80)
		} else {
			Gdip_DrawImage(G, bitmaps["pBMSDMIcon"], x - 775, y + 100, 80, 80)
		}
		Gdip_TextToGraphics(G, MacroName " v" MacroVersionID, "s56 Left Bold cffb47bd1 x" x - 675 " y" y + 100, "Segoe UI")
	}

	Gdip_DeleteGraphics(G)

	WebhookURL := IniRead(A_SettingsWorkingDir "main_config.ini", "Discord", "WebhookURL")
	BotToken := IniRead(A_SettingsWorkingDir "main_config.ini", "Discord", "BotToken")
	DiscordMode := IniRead(A_SettingsWorkingDir "main_config.ini", "Discord", "DiscordMode")
	ReportChannelID := IniRead(A_SettingsWorkingDir "main_config.ini", "Discord", "ReportChannelID")
	if StrLen(ReportChannelID) < 17 {
		ReportChannelID := IniRead(A_SettingsWorkingDir "main_config.ini", "Discord", "MainChannelID")
	}

	try {
		chars := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		chars := Sort(chars, "D| Random")
		boundary := SubStr(StrReplace(chars, "|"), 1, 12)
		hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream := 0, "UInt")

		str :=
		(
		'
		------------------------------' boundary '
		Content-Disposition: form-data; name="payload_json"
		Content-Type: application/json

		{
			"embeds": [{
				"title": "**[' A_Hour ':00:00] Hourly Report**",
				"color": "14052794",
				"image": {"url": "attachment://file.png"}
			}]
		}
		------------------------------' boundary '
		Content-Disposition: form-data; name="files[0]"; filename="file.png"
		Content-Type: image/png

		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")

		pFileStream := Gdip_SaveBitmapToStream(pBMReport)
		DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size := 0, "UInt")
		DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
		DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
		ObjRelease(pFileStream)

		str :=
		(
		'

		------------------------------' boundary '--
		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")
		ObjRelease(pStream)

		pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
		size := DllCall("GlobalSize", "Ptr", pData, "UPtr")

		retData := ComObjArray(0x11, size)
		pvData := NumGet(ComObjValue(retData), 8 + A_PtrSize, "Ptr")
		DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)

		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("GlobalFree", "Ptr", hData, "Ptr")
		contentType := "multipart/form-data; boundary=----------------------------" boundary

		wr := ComObject("WinHttp.WinHttpRequest.5.1")
		wr.Option[9] := 2720
		wr.Open("POST", (DiscordMode = 1) ? WebhookURL : ("https://discord.com/api/v9/channels/" ReportChannelID "/messages"), 0)
		if (DiscordMode = 2) {
			wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
			wr.SetRequestHeader("Authorization", "Bot " BotToken)
		}
		wr.SetRequestHeader("Content-Type", contentType)
		wr.SetTimeouts(0, 60000, 120000, 30000)
		wr.Send(retData)
	} catch as e {
		message := "**[" A_Hour ":" A_Min ":" A_Sec "]**`n"
		. "**Failed to send Hourly Report!**`n"
		. "Gdip SaveBitmap Error: " result "`n`n"
		. "Exception Properties:`n"
		. ">>> What: " e.what "`n"
		. "File: " e.file "`n"
		. "Line: " e.line "`n"
		. "Message: " e.message "`n"
		. "Extra: " e.extra
		message := StrReplace(StrReplace(message, "\", "\\"), "`n", "\n")

		postdata :=
		(
		'
		{
			"embeds": [{
				"description": "' message '",
				"color": "15085139"
			}]
		}
		'
		)

		Send_WM_COPYDATA(postdata, "Discord.ahk ahk_class AutoHotkey")
	}

	Gdip_DisposeImage(pBMReport)

	; save old stats for comparison
	for k, v in stats_old {
		v[2] := stats[k][2]
	}
	; reset credit values map
	credit_values.Clear()
	credit_values[0] := current_credits
	; reset status changes array
	for k, v in status_changes {
		if A_Index = status_changes.Count {
			current_status := v
		}
	}
	status_changes.Clear()
	status_changes[0] := current_status
}

/**
 * @description Rounds a number (integer/float) to 4 s.f. and abbreviates it with common large number prefixes
 * @param n The number to round
 * @returns String (result)
*/
FormatNumber(n) {
	static numnames := ["M", "B", "T", "Qa"]
	digits := floor(log(abs(n))) + 1
	if digits > 6 {
		numname := (digits - 4)//3
		numstring := SubStr((Round(n, 4 - digits)) / 10**(3 * numname + 3), 1, 5)
		numformat := (SubStr(numstring, 0) = ".") ? 1.000 : numstring, numname += (SubStr(numstring, 0) = ".") ? 1 : 0
		num := SubStr((Round(n, 4-digits)) / 10**(3 * numname + 3), 1, 5) " " numnames[numname]
	} else {
		num := Buffer(32), DllCall("GetNumberFormatEx", "str", "!x-sys-default-locale", "uint", 0, "str", n, "ptr", 0, "Ptr", num.Ptr, "int", 32)
		num := SubStr(StrGet(num), 1, -3)
	}
	return num
}

/**
 * @description Responsible for receiving messages from the main macro script to set current status
 * @param wParam The status number
 * @param lParam The second of the hour when status started
*/
SetStatus(wParam, lParam, *){
	for k, v in status_changes {
		if lParam < k {
			return 0
		}
	}
	status_changes[lParam] := wParam
	return 0
}

/**
 * @description Responsible for receiving messages from the main macro script to increment stats
 * @param wParam The stat to be incrememted
 * @param lParam The amount
*/
IncrementStat(wParam, lParam, *){
	stats[wParam][2] += lParam
	return 0
}

/**
 * @description These functions return the minimum and maximum values in maps and arrays
 * @author Modified versions of functions by FanaticGuru
 * @url https://www.autohotkey.com/boards/viewtopic.php?t=40898
*/
minX(List) {
	List.__Enum().Call(, &X)
	for key, element in List {
		if (IsNumber(element) && (element < X)) {
			X := element
		}
	}
	return X
}
maxX(List) {
	List.__Enum().Call(, &X)
	for key, element in List {
		if (IsNumber(element) && (element > X)) {
			X := element
		}
	}
	return X
}

/**
 * @description OCR with UWP API
 * @author Malcev, Teadrinker
 * @url https://www.autohotkey.com/boards/viewtopic.php?t=72674
*/
HBitmapToRandomAccessStream(hBitmap) {
	static IID_IRandomAccessStream := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"
	 , IID_IPicture            := "{7BF80980-BF32-101A-8BBB-00AA00300CAB}"
	 , PICTYPE_BITMAP := 1
	 , BSOS_DEFAULT   := 0
	 , sz := 8 + A_PtrSize * 2

	DllCall("Ole32\CreateStreamOnHGlobal", "Ptr", 0, "UInt", true, "PtrP", &pIStream := 0, "UInt")

	PICTDESC := Buffer(sz, 0)
	NumPut("uint", sz
	 , "uint", PICTYPE_BITMAP
	 , "ptr", hBitmap, PICTDESC)

	riid := CLSIDFromString(IID_IPicture)
	DllCall("OleAut32\OleCreatePictureIndirect", "Ptr", PICTDESC, "Ptr", riid, "UInt", false, "PtrP", &pIPicture := 0, "UInt")
	; IPicture::SaveAsFile
	ComCall(15, pIPicture, "Ptr", pIStream, "UInt", true, "UIntP", &size := 0, "UInt")
	riid := CLSIDFromString(IID_IRandomAccessStream)
	DllCall("ShCore\CreateRandomAccessStreamOverStream", "Ptr", pIStream, "UInt", BSOS_DEFAULT, "Ptr", riid, "PtrP", &pIRandomAccessStream := 0, "UInt")
	ObjRelease(pIPicture)
	ObjRelease(pIStream)
	Return pIRandomAccessStream
}

CLSIDFromString(IID, &CLSID?) {
	CLSID := Buffer(16)
	if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", CLSID, "UInt")
	throw Error("CLSIDFromString failed. Error: " . Format("{:#x}", res))
	Return CLSID
}

OCR(file, lang := "FirstFromAvailableLanguages") {
	static OCREngineStatics, OCREngine, MaxDimension, LanguageFactory, Language, CurrentLanguage := "", BitmapDecoderStatics, GlobalizationPreferencesStatics
	if (!IsSet(OCREngineStatics)) {
		CreateClass("Windows.Globalization.Language", ILanguageFactory := "{9B0252AC-0C27-44F8-B792-9793FB66C63E}", &LanguageFactory)
		CreateClass("Windows.Graphics.Imaging.BitmapDecoder", IBitmapDecoderStatics := "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", &BitmapDecoderStatics)
		CreateClass("Windows.Media.Ocr.OcrEngine", IOCREngineStatics := "{5BFFA85A-3384-3540-9940-699120D428A8}", &OCREngineStatics)
		ComCall(6, OCREngineStatics, "uint*", &MaxDimension:=0)
	}
	text := ""
	if file = "ShowAvailableLanguages" {
		if (!IsSet(GlobalizationPreferencesStatics)) {
			CreateClass("Windows.System.UserProfile.GlobalizationPreferences", IGlobalizationPreferencesStatics := "{01BF4326-ED37-4E96-B0E9-C1340D1EA158}", &GlobalizationPreferencesStatics)
		}
		ComCall(9, GlobalizationPreferencesStatics, "ptr*", &LanguageList := 0)   ; get_Languages
		ComCall(7, LanguageList, "int*", &count := 0)   ; count
		Loop count {
			ComCall(6, LanguageList, "int", A_Index - 1, "ptr*", &hString := 0)   ; get_Item
			ComCall(6, LanguageFactory, "ptr", hString, "ptr*", &LanguageTest := 0)   ; CreateLanguage
			ComCall(8, OCREngineStatics, "ptr", LanguageTest, "int*", &bool := 0)   ; IsLanguageSupported
			if bool = 1 {
				ComCall(6, LanguageTest, "ptr*", &hText := 0)
				b := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length := 0, "ptr")
				text .= StrGet(b, "UTF-16") "`n"
			}
			ObjRelease(LanguageTest)
		}
		ObjRelease(LanguageList)
		return text
	}
	if (lang != CurrentLanguage) || (lang = "FirstFromAvailableLanguages") {
		if (IsSet(OCREngine)) {
			ObjRelease(OCREngine)
			if CurrentLanguage != "FirstFromAvailableLanguages" {
				ObjRelease(Language)
			}
		}
		if lang = "FirstFromAvailableLanguages" {
			ComCall(10, OCREngineStatics, "ptr*", OCREngine)   ; TryCreateFromUserProfileLanguages
		} else {
			CreateHString(lang, &hString)
			ComCall(6, LanguageFactory, "ptr", hString, "ptr*", &Language := 0)   ; CreateLanguage
			DeleteHString(hString)
			ComCall(9, OCREngineStatics, "ptr", Language, "ptr*", &OCREngine := 0)   ; TryCreateFromLanguage
		}
		if OCREngine = 0 {
			MsgBox('Unable to use language "' lang '" for OCR.`nPlease install a language pack.')
			ExitApp()
		}
		CurrentLanguage := lang
	}
	IRandomAccessStream := file
	ComCall(14, BitmapDecoderStatics, "ptr", IRandomAccessStream, "ptr*", &BitmapDecoder := 0)   ; CreateAsync
	WaitForAsync(&BitmapDecoder)
	BitmapFrame := ComObjQuery(BitmapDecoder, IBitmapFrame := "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")
	ComCall(12, BitmapFrame, "uint*", &width := 0)   ; get_PixelWidth
	ComCall(13, BitmapFrame, "uint*", &height := 0)   ; get_PixelHeight
	if (width > MaxDimension) || (height > MaxDimension) {
		MsgBox('Image is too big - ' width 'x' height '.`nIt should be a maximum of - ' MaxDimension ' pixels')
		ExitApp()
	}
	BitmapFrameWithSoftwareBitmap := ComObjQuery(BitmapDecoder, IBitmapFrameWithSoftwareBitmap := "{FE287C9A-420C-4963-87AD-691436E08383}")
	ComCall(6, BitmapFrameWithSoftwareBitmap, "ptr*", &SoftwareBitmap := 0)   ; GetSoftwareBitmapAsync
	WaitForAsync(&SoftwareBitmap)
	ComCall(6, OCREngine, "ptr", SoftwareBitmap, "ptr*", &OCRResult := 0)   ; RecognizeAsync
	WaitForAsync(&OCRResult)
	ComCall(6, OCRResult, "ptr*", &LinesList := 0)   ; get_Lines
	ComCall(7, LinesList, "int*", &count := 0)   ; count
	Loop count {
		ComCall(6, LinesList, "int", A_Index - 1, "ptr*", &OCRLine := 0)
		ComCall(7, OCRLine, "ptr*", &hText := 0)
		buf := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length := 0, "ptr")
		text .= StrGet(buf, "UTF-16") "`n"
		ObjRelease(OCRLine)
	}
	Close := ComObjQuery(IRandomAccessStream, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
	ComCall(6, Close)   ; Close
	Close := ComObjQuery(SoftwareBitmap, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
	ComCall(6, Close)   ; Close
	ObjRelease(IRandomAccessStream)
	ObjRelease(BitmapDecoder)
	ObjRelease(SoftwareBitmap)
	ObjRelease(OCRResult)
	ObjRelease(LinesList)
	return text
}

CreateClass(str, interface, &Class) {
	CreateHString(str, &hString)
	GUID := CLSIDFromString(interface)
	result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", GUID, "ptr*", &Class := 0)
	if result != 0 {
		if result = 0x80004002 {
			MsgBox("No such interface supported")
		} else if (result = 0x80040154) {
			MsgBox("Class not registered")
		} else {
			msgbox("Error: " result)
		}
	}
	DeleteHString(hString)
}

CreateHString(str, &hString) {
	DllCall("Combase.dll\WindowsCreateString", "wstr", str, "uint", StrLen(str), "ptr*", &hString := 0)
}

DeleteHString(hString) {
	DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}

WaitForAsync(&Object) {
	AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
	Loop {
		ComCall(7, AsyncInfo, "uint*", &status := 0)   ; IAsyncInfo.Status
		if status != 0 {
			if status != 1 {
				ComCall(8, AsyncInfo, "uint*", &ErrorCode := 0)   ; IAsyncInfo.ErrorCode
				MsgBox("AsyncInfo Status Error: " ErrorCode)
				ExitApp()
			}
			break
		}
		Sleep 10
	}
	ComCall(8, Object, "ptr*", &ObjectResult := 0)   ; GetResults
	ObjRelease(Object)
	Object := ObjectResult
}

Send_WM_COPYDATA(StringToSend, TargetScriptTitle, wParam := 0) {
	CopyDataStruct := Buffer(3 * A_PtrSize)
	SizeInBytes := (StrLen(StringToSend) + 1) * 2
	NumPut("Ptr", SizeInBytes
	 , "Ptr", StrPtr(StringToSend)
	 , CopyDataStruct, A_PtrSize)
	DetectHiddenWindows(1)
	try {
		ret := SendMessage(0x004A, wParam, CopyDataStruct, , TargetScriptTitle)
	}
	DetectHiddenWindows(0)
	return (IsSet(ret) ? ret : 0)
}

/**
 * @description Set the current status of whether the macro is in the lobby or not, in order to activate checks for credit's count
 * @param wParam The value to set it to (1 or 0)
 * @returns {Integer} On success
*/
SetLobbyState(wParam, *) {
	Critical
	global InLobby := wParam
	return 0
}
