#NoTrayIcon
#SingleInstance Force
#MaxThreads 255
Persistent(1)
#Warn VarUnset, Off

#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "JSON.ahk"
#Include "externalFuncs\DurationFromSeconds.ahk"
#Include "mainFiles\Roblox.ahk"
#Include "externalFuncs\enum.ahk"
#Include "externalFuncs\nowUnix.ahk"

OnError (e, mode) => (mode = "Return") ? -1 : 0
SetWorkingDir(A_ScriptDir "\..")
CoordMode("Mouse", "Client")

MacroName := A_Args[21]
if A_Args.Length < 21 || A_Args.Length > 21 {
	MsgBox("This script needs to be run by " MacroName "! You are not supposed to run it manually.")
	ExitApp()
}



; initialisation
MacroState := logsize := GameUpdate := 0
status_buffer := [], command_buffer := []

; main
CommandPrefix := A_Args[1]
DiscordCheck := A_Args[2]
DiscordMode := A_Args[3]
WebhookURL := A_Args[4]
BotToken := A_Args[5]

; channels
MainChannelCheck := A_Args[6]
ReportChannelCheck := A_Args[7]
MainChannelID := A_Args[8]
ReportChannelID := A_Args[9]
DiscordUserID := "<@" A_Args[10] ">"

; modes
DebugLogEnabled := A_Args[11]
Criticals := A_Args[12]
Screenshots := A_Args[13]
DebuggingScreenshots := A_Args[14]

; pings
CriticalErrorPings := A_Args[15]
DisconnectPings := A_Args[16]

; screenshots
CriticalScreenshots := A_Args[17]

; bitmaps
offsetY := A_Args[18]
windowDimensions := A_Args[19]

; other
ColourfulEmbeds := A_Args[20]

A_SettingsWorkingDir := A_WorkingDir "\settings\"
mainSettingsPath := A_SettingsWorkingDir "sd_config.ini"



pToken := Gdip_Startup()
OnExit(ExitFunc)
OnMessage(0x004A, sd_SendPostData, 255)
OnMessage(0xC2, sd_SetStatus, 255)
OnMessage(0x5552, sd_SetGlobalInt, 255)
OnMessage(0x5553, sd_SetGlobalStr, 255)
OnMessage(0x5556, sd_SendHeartbeat)
OnMessage(0x5560, ExitFunc)


settings := Map(), settings.CaseSense := 0
; Integers
; status
settings["ReversedStatusLog"] := {enum: 1, type: "int", section: "Status", regex: "i)^(0|1)$"}

; settings["DiscordCheck"] := {enum: 2, type: "int", section: "Discord", regex: "i)^(0|1)$"} ; Discord, dangerous
; settings["DiscordMode"] := {enum: 3, type: "int", section: "Discord", regex: "i)^(1|2)$"}, dangerous
; settings["MainChannelCheck"] := {enum: 4, type: "int", section: "Discord", regex: "i)^(0|1)$"}, dangerous
settings["ReportChannelCheck"] := {enum: 5, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["DebugLogEnabled"] := {enum: 6, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["Criticals"] := {enum: 7, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["Screenshots"] := {enum: 8, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["DebuggingScreenshots"] := {enum: 9, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["CriticalErrorPings"] := {enum: 10, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["DisconnectPings"] := {enum: 11, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["CriticalScreenshots"] := {enum: 12, type: "int", section: "Discord", regex: "i)^(0|1)$"}
settings["ColourfulEmbeds"] := {enum: 13, type: "int", section: "Discord", regex: "i)^(0|1)$"}

; settings
; settings["GUI_X"] := {enum: 14, type: "int", section: "Settings", regex: "i)^(0|1)$"}, unknown
; settings["GUI_Y"] := {enum: 156, type: "int", section: "Settings", regex: "i)^(0|1)$"}, unknown
settings["AlwaysOnTop"] := {enum: 16, type: "int", section: "Settings", regex: "i)^(0|1)$"}
; settings["GUITransparency"] := {enum: 17, type: "int", section: "Settings", regex: "i)^(0|1)$"}, unknown
settings["KeyDelay"] := {enum: 18, type: "int", section: "Settings", regex: "i)^(0|1)$"}
settings["PublicFallback"] := {enum: 19, type: "int", section: "Settings", regex: "i)^(0|1)$"}
settings["ShowOnPause"] := {enum: 20, type: "int", section: "Settings", regex: "i)^(0|1)$"}
; settings["ClickCount"] := {enum: 21, type: "int", section: "Settings", regex: "i)^(0|1)$"}, unknown
; settings["ClickDelay"] := {enum: 22, type: "int", section: "Settings", regex: "i)^(0|1)$"}, unknown
settings["ClickMode"] := {enum: 23, type: "int", section: "Settings", regex: "i)^(0|1)$"}
; settings["MacroState"] := {enum: 24, type: "int", regex: "i)^(0|1|2)$"}, dangerous


; Strings
; Discord
settings["CommandPrefix"] := {enum: 1, type: "int", section: "Discord", regex: "i)^\S{1,3}$"}
settings["WebhookURL"] := {enum: 2, type: "str", section: "Discord", regex: "i)^(https:\/\/(canary\.|ptb\.)?(Discord|Discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)|<blank>)$"}
; settings["BotToken"] := {enum: 3, type: "str", section: "Discord", regex: "i)^[\w-.]{50,83}$"}, dangerous
; settings["MainChannelID"] := {enum: 4, type: "str", section: "Discord", regex: "i)^\d{17,20}$"}, dangerous
settings["ReportChannelID"] := {enum: 5, type: "str", section: "Discord", regex: "i)^\d{17,20}$"}
settings["DiscordUserID"] := {enum: 6, type: "str", section: "Discord", regex: "i)^&?\d{17,20}$"}

; settings
settings["GUITheme"] := {enum: 7, type: "str", section: "Settings", regex: "^(Allure|Ayofe|BluePaper|Concaved|Core|Cosmo|Fanta|Graygray|Hana|Invoice|Lakrits|Luminous|MacLion3|Minimal|Museo|None|Panther|PaperAGV|PINK|Relapse|Simplex3|SNAS|Stomp|VS7|WhiteGray|Woodwork)$"}
settings["Language"] := {enum: 8, type: "str", section: "Settings", regex: "^(english|spanish|turkish|portuguese)$"}
settings["PrivServer"] := {enum: 9, type: "str", section: "Settings", regex: "i)^(((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*|<blank>)$"}
settings["FallbackServer1"] := {enum: 10, type: "str", section: "Settings", regex: "i)^(((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*|<blank>)$"}
settings["FallbackServer2"] := {enum: 11, type: "str", section: "Settings", regex: "i)^(((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*|<blank>)$"}
settings["FallbackServer3"] := {enum: 12, type: "str", section: "Settings", regex: "i)^(((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*|<blank>)$"}
settings["ReconnectMethod"] := {enum: 13, type: "str", section: "Settings", regex: "^(Deeplink|Browser)$"}
; settings["ReconnectMessage"] := {enum: 14, type: "str", section: "Settings", regex: ""}, unknown
settings["ClickButton"] := {enum: 15, type: "str", section: "Settings", regex: "^(LMB|RMB)$"}



commands := Map(), commands.CaseSense := 0
commands['help/h/" " (s/set)'] := {section: "Commands"}
commands["a/ad/adv/advance/advanced"] := {section: "Commands"}
commands["ss/screenshot (mode)"] := {section: "Commands"}
commands["start"] := {section: "Commands"}
commands["pause/unpause"] := {section: "Commands"}
commands["stop/end/reload"] := {section: "Commands"}
commands["close"] := {section: "Commands"}
commands["forceclose"] := {section: "Commands"}
commands["activate"] := {section: "Commands"}
commands["minimise/minimize"] := {section: "Commands"}
commands["rejoin/reconnect"] := {section: "Commands"}
commands["statuslog/log"] := {section: "Commands"}
commands["prefix"] := {section: "Commands"}
commands["s/set"] := {section: "Commands"}
commands["get"] := {section: "Commands"}
commands["send"] := {section: "Commands"}
commands["upload"] := {section: "Commands"}
commands["click (mode)"] := {section: "Commands"}
commands["shutdown"] := {section: "Commands"}
commands["info/i/information/whatis/whis/nameit/nit/cmds/commands/cmd [command]"] := {section: "Commands"}

bitmaps := Map()
#Include "%A_ScriptDir%\..\sd_img_assets\offset\bitmaps.ahk"


Discord.SendEmbed("Connected to Discord!", 5066239)
Loop {
	(status_buffer.Length > 0) && sd_Status(status_buffer[1])
	(Mod(A_Index, 5) = 0) && Discord.GetCommands(MainChannelID)
	(command_buffer.Length > 0) && sd_Command(command_buffer[1])
	(Mod(A_Index, 10) = 0) && sd_GameUpdate()
	((DebugLogEnabled = 1) && (logsize > 8000000)) && sd_TrimLog(4194304) ; trim to 4MiB
	Sleep 100
}

sd_Status(status) {
	stateString := SubStr(status, InStr(status, "] ") + 2)
	state := SubStr(stateString, 1, InStr(stateString, ": ") - 1), objective := SubStr(stateString, InStr(stateString, ": ") + 2)

	; write to debug log
	global logsize
	if (DebugLogEnabled = 1) {
		try {
			log := FileOpen(A_SettingsWorkingDir "debug_log.txt", "a-d"), log.WriteLine(StrReplace(status, "`n", " - ")), logsize := log.Length, log.Close()
		}
	}

	; send to Discord
	if (DiscordCheck = 1) {
		; set colour based on state string
		static colourIndex := 0, colours := [16711680, 16744192, 16776960, 65280, 255, 4915330, 9699539]
		if (ColourfulEmbeds = 1) {
			colour := colours[colourIndex := Mod(colourIndex, 7) + 1]
		} else {
			colour := ((state == "Disconnected") || (state == "Failed") || (state == "Error") || (state == "Aborting") || (state == "Missing") || (state == "Canceling")) ? 15085139 ; red - error
			: ((state == "Interupted") || (state == "Warning")) ? 14408468 ; yellow - alert
			: ((state == "Completed") || (state == "Success")) ? 48128 ; green - success
			: ((state == "Starting") || (InStr(state, "Join")) || (InStr(state, "Return")) || (state == "Grinding") || (InStr(state, "Replay")) || (state == "Collecting")) ? 16366336 ; orange - game
			: ((state == "GUI") || (state == "Resetting") || (state == "Testing") || (state == "Attempting") || (state == "Paused") || (state == "GitHub") || (state == "Detected") || (state == "Closing") || (state == "Begin") || (state == "End")) ? 15658739 ; white - GUI / utility
			: ((state == "Discord") || (state == "Dank Memer")) ? 5066239 ; blue - discord
			: 3223350
		}

		; ping
		content := ((Criticals = 1) && (DiscordUserID)
			&& (((CriticalErrorPings = 1) && (state == "Error"))
			|| ((DisconnectPings = 1) && InStr(stateString, "Disconnected"))
			|| ((InStr(stateString, "Resetting: Character") && (Mod(SubStr(objective, InStr(objective, " ") + 1), 10) = 5)))))
			? (DiscordUserID) : ""

		; status update (embed)
		message := StrReplace(StrReplace(StrReplace(StrReplace(SubStr(status, InStr(status, "]") + 1), "\", "\\"), "`n", "\n"), Chr(9), "  "), "`r")

		; screenshot
		if ((Screenshots = 1) 
			&& ((((CriticalScreenshots = 1) && (content != ""))
			|| ((state == "Grinding") && (pBM := CreateGameBitmap()))
			|| (((state == "Returned") && (objective == "Lobby")) && (pBM := CreateGameBitmap()))
			|| ((DebuggingScreenshots = 1) && ((state == "Collecting") || (InStr(state, "Join")) || (InStr(state, "Replay")) || (state == "Failed"))))))
							  {
			if (!IsSet(pBM)) {
				hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd), pBM := Gdip_BitmapFromScreen((windowWidth > 0) ? (IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight)) : 0)
			}
		}

		status_buffer.RemoveAt(1)
		Discord.SendEmbed(message, colour, content, pBM?, channel?), IsSet(pBM) && pBM > 0 && Gdip_DisposeImage(pBM)

	} else {
		status_buffer.RemoveAt(1)
	}

	; extra: game update
	if (Screenshots = 1) {
		global GameUpdate
		if ((state = "Grinding") && (!InStr(objective, "Ended"))) {
			GameUpdate := (ColourfulEmbeds = 1) ? colours[colourIndex := Mod(colourIndex, 7) + 1] : colour
		}
		else if (state != "Detected") {
			GameUpdate := 0
		}
	}
}

sd_GameUpdate() {
	static id := ""

	if (GameUpdate) {
		payload_json := '{"embeds": [{"description": "[' A_Hour ':' A_Min ':' A_Sec '] Game Progress", "color": "' GameUpdate '", "image": {"url": "attachment://game.png"}}], "attachments": []}'
		Discord.CreateFormData(&postdata, &contentType
		 , [Map("name", "payload_json", "content-type", "application/json", "content", payload_json)
		 , Map("name", "files[0]", "filename", "game.png", "content-type", "image/png", "pBitmap", pBM := CreateGameBitmap())])
		if pBM <= 0 {
			return
		}
		Gdip_DisposeImage(pBM)
		try {
			id ? Discord.EditMessageAPI(id, postdata, contentType) : ((message := JSON.parse(Discord.SendMessageAPI(postdata, contentType))).Has("id") && (id := message["id"]))
		}
	} else if (id) {
		id := ""
	}
}

CreateGameBitmap() {
	hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd)
	if (windowWidth <= 500) {
		return -2
	}
	pBM := Gdip_CreateBitmap(windowWidth, windowHeight), G := Gdip_GraphicsFromImage(pBM)
	pBMmainScreen := Gdip_BitmapFromScreen((IsSet(windowDimensions) ? windowDimensions : windowX "|" (IsSet(offsetY) ? (windowY + offsetY) : windowY) "|" windowWidth "|" (IsSet(offsetY) ? (windowHeight - offsetY) : windowHeight))), Gdip_DrawImage(G, pBMmainScreen), Gdip_DisposeImage(pBMmainScreen)
	Gdip_DeleteGraphics(G)
	return pBM
}

sd_Command(command) {
	global CommandPrefix, MacroState, settings, commands
	static ScreenshotMode := "All"

	id := command.id, params := []
	Loop Parse SubStr(command.content, StrLen(CommandPrefix) + 1), A_Space {
		if (A_LoopField != "") {
			params.Push(A_LoopField)
		}
	}
	params.Length := 10, params.Default := ""

	switch (name := params[1]), 0 {
		case "help", "h", "":
		switch params[2], 0 {
			case "s", "set":
			sections := Map("Status", "**__Status__**"
			 , "Discord", "**__Discord__**"
			 , "Settings", "**__Settings__**"
			 , "Game", "**__Game__**"), sections.Default := ""
		
			; populate each variable list
			for k, v in settings {
				if (HasProp(v, "regex")) {
					sections[v.section] .= "`n" k
				}
			}
		
			; trim all lists to 4096 characters (max embed description)
			for , list in sections {
				list := SubStr(list, 1, 4096)
			}
		
			; split lists into max 4096 character embeds
			enum := sections.__Enum(), enum.Call(,&section)
			embeds := [], embed := Map("title", "List of Variables for ``" CommandPrefix "set``")
			Loop 10 {
				embed["color"] := 5066239, embed["description"] := section
				Loop sections.Count {
					if (enum.Call(,&section) = 0) {
						embeds.Push(embed)
						break 2
					}
					if (StrLen(embed["description"]) + StrLen(section) > 4092) { ; 4 characters for "\n\n"
						break
					} else {
						embed["description"] .= "`n`n" section
					}
				}
				embeds.Push(embed.Clone()), embed.Clear()
			}
		
			; send embeds as separate messages (because of the max 6000 character limit)
			enum := embeds.__Enum(), enum.Call(&embed)
			postdata :=
			(
			'
			{
				"embeds": [' JSON.stringify(embed) '],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
				"message_id": "' id '",
				"fail_if_not_exists": false
				}
			}
			'
			)
			while enum.Call(&embed) {
				Discord.SendMessageAPI(postdata), postdata := '{"embeds": [' JSON.stringify(embed) ']}'
			}

			case "a", "ad", "adv", "advance", "advanced":
			postdata :=
			(
			'
			{
				"embeds": [{
					"title": "Advanced Commands",
					"color": "7569663",
					"fields": [{
						"name": "' CommandPrefix 'set [setting] [value]",
						"value": "Sets a setting to ``value`` (use ``' CommandPrefix 'help set`` for a list)",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'get [setting]",
						"value": "Gets the current value of a setting in the macro",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'send [keys]",
						"value": "Uses AHK`'s ``Send`` command (see in-macro documentation table (coming soon))",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'upload [filepath]",
						"value": "Uploads a specific file from ``filepath``",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'download [directory]",
						"value": "Downloads the attached file to ``directory``",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'click [options]",
						"value": "Uses AHK`'s ``Click`` command (see AutoHotkey documentation)",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'activate [window]",
						"value": "Uses ``WinActivate`` to activate a window",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'minimize [window]",
						"value": "Uses ``WinMinimize`` to minimize a window",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'shutdown",
						"value": "Shuts your computer down, using the parameters from the AutoHotkeyv2 documentation on Shutdown() at https://www.autohotkey.com/docs/v2/lib/Shutdown.htm",
						"inline": true
					}]
				}],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
				"message_id": "' id '",
				"fail_if_not_exists": false
				}
			}
			'
			)
			

			default:
			postdata :=
			(
			'
			{
				"embeds": [{
					"title": "Useful Commands",
					"color": "5066239",
					"fields": [{
						"name": "' CommandPrefix 'help",
						"value": "Display a list of useful commands",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'screenshot",
						"value": "Uploads a screenshot of all monitors",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'stop",
						"value": "Stop and reload ' MacroName ' (``F3``)",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'forceclose [window]",
						"value": "Closes a specific window, e.g. ``' CommandPrefix 'close Roblox``",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'rejoin (delay)",
						"value": "Closes Roblox and rejoins after an optional delay",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'log",
						"value": "Uploads your status debug log as a .txt file",
						"inline": true
					},
					{
						"name": "' CommandPrefix 'prefix [prefix]",
						"value": "Sets the command prefix, e.g. ``' CommandPrefix 'prefix ' RandomPrefix() '``",
						"inline": true
					},
					{
						"name": "Remember",
						"value": "Reload the macro after making changes to validate them!",
						"inline": true
					}]
				}],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
					"message_id": "' id '",
					"fail_if_not_exists": false
				}
			}
			'
			)
		}
		Discord.SendMessageAPI(postdata)


		case "ss", "screenshot":
		switch params[2], 0 {
			case "mode":
			if ((params[3] = "all") || (params[3] = "window") || (params[3] = "screen")) {
				ScreenshotMode := RegExReplace(params[3], "(?:^|\.|\R)[- 0-9\*\(]*\K(.)([^\.\r\n]*)", "$U1$L2")
				Discord.SendEmbed("Set screenshot mode to " ScreenshotMode "!", 5066239, , , , id)
			} else {
				Discord.SendEmbed("Invalid ``Mode``!\nMust be either ``All``, ``Window``, or ``Screen``", 16711731, , , , id)
			}

			default:
			switch ScreenshotMode, 0 {
				case "all":
				pBM := Gdip_BitmapFromScreen()

				case "window":
				WinGetClientPos(&x, &y, &w, &h, "A")
				pBM := Gdip_BitmapFromScreen((w > 0) ? (x "|" y "|" w "|" h) : 0)

				case "screen":
				pBM := Gdip_BitmapFromScreen(1)

				default:
				Discord.SendEmbed("Error: Invalid screenshot mode!", 16711731, , , , id)
				pBM := Gdip_BitmapFromScreen()
			}
			Discord.SendImage(pBM, "ss.png", id)
			Gdip_DisposeImage(pBM)
		}


		case "start":
		if MacroState = 0 {
			DetectHiddenWindows(1)
			if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
				PostMessage(0x5550, 1)
				Discord.SendEmbed("Starting Macro...", 5066239, , , , id)
			} else {
				Discord.SendEmbed("Error: Macro not found!", 16711731, , , , id)
			}
		} else {
			Discord.SendEmbed("Macro has already been started!", 16711731, , , , id)
		}


		case "pause", "unpause":
			if MacroState = 0 {
				Discord.SendEmbed("Macro is not running!", 16711731, , , , id)
			} else {
				DetectHiddenWindows(1)
				if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
					PostMessage(0x5550, 2)
					Discord.SendEmbed(((MacroState = 2) ? "Pausing" : "Unpausing") " Macro...", 5066239, , , , id)
				} else {
					Discord.SendEmbed("Error: Macro not found!", 16711731, , , , id)
				}
			}


		case "stop", "end", "reload":
		DetectHiddenWindows(1)
		if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
			PostMessage(0x5550, 3)
			Discord.SendEmbed("Stopping Macro...", 5066239, , , , id)
		} else {
			Discord.SendEmbed("Error: Macro not found!", 16711731, , , , id)
		}
		DetectHiddenWindows(0)


		case "close":
		DetectHiddenWindows(1)
		if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
			PostMessage(0x5550, 5, , , "skibi_defense_macro ahk_class AutoHotkey")
			Discord.SendEmbed("Closing Macro...", 5066239, , , , id)
		} else {
			Discord.SendEmbed("Error: Macro not found!", 16711731, , , , id)
		}
		DetectHiddenWindows(0)


		case "forceclose":
		DetectHiddenWindows(0)
		if (hwnd := WinExist(window := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name))))) {
			windowPID := WinGetPID()
			title := WinGetTitle("ahk_id " hwnd)
			Loop 3 {
				if WinExist("ahk_id" hwnd) {
					WinKill()
				}
			}
			Discord.SendEmbed('Closed Window: ``' StrReplace(StrReplace(title, "\", "\\"), '"', '\"') '``', 5066239, , , , id)
		} else {
			Discord.SendEmbed('Window ``' StrReplace(StrReplace(window, "\", "\\"), '"', '\"') '`` not found!', 16711731, , , , id)
		}


		case "activate":
		DetectHiddenWindows(0)
		if (hwnd := WinExist(window := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name))))) {
			title := WinGetTitle("ahk_id " hwnd)
			try {
				WinActivate("ahk_id " hwnd)
				Discord.SendEmbed('Activated Window: ``' StrReplace(StrReplace(title, "\", "\\"), '"', '\"') '``', 5066239, , , , id)
			} catch as e {
				Discord.SendEmbed("Error:\n" e.Message " " e.What, 16711731, , , , id)
			}
		} else {
			Discord.SendEmbed('Window ``' StrReplace(StrReplace(window, "\", "\\"), '"', '\"') '`` not found!', 16711731, , , , id)
		}


		case "minimise", "minimize":
		DetectHiddenWindows(0)
		if (hwnd := WinExist(window := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name))))) {
			title := WinGetTitle("ahk_id " hwnd)
			try {
				WinMinimize("ahk_id " hwnd)
				Discord.SendEmbed('Minimized Window: ``' StrReplace(StrReplace(title, "\", "\\"), '"', '\"') '``', 5066239, , , , id)
			} catch as e {
				Discord.SendEmbed("Error:\n" e.Message " " e.What, 16711731, , , , id)
			}
		} else {
			Discord.SendEmbed('Window ``' StrReplace(StrReplace(window, "\", "\\"), '"', '\"') '`` not found!', 16711731, , , , id)
		}


		case "rejoin", "reconnect":
		if (!params[2] || ((params[2] ~= "i)^[0-9]+$") && (params[2] <= 600))) { ; note: use this regex for guix and y settings changing through bot
			delay := params[2] ? params[2] : 0    
			DetectHiddenWindows(1)
			if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
				PostMessage(0x5557, delay)
				Discord.SendEmbed((delay > 0) ? ("Rejoining after " delay " seconds!") : "Rejoining...", 5066239, , , , id)
			} else {
				Discord.SendEmbed("Error: Macro not found!", 16711731, , , , id)
			}
		} else {
			Discord.SendEmbed("Reconnect delay must be an integer less than or equal to 600!\nYou entered ``" params[2] "``.", 16711731, , , , id)
		}


		case "statuslog", "log":
		Discord.SendFile(A_SettingsWorkingDir "debug_log.txt", id)


		case "prefix":
		if ((newPrefix := SubStr(params[2], 1, 3)) && (StrLen(newPrefix) > 0)) {
			CommandPrefix := newPrefix
			IniWrite(CommandPrefix, mainSettingsPath, "Discord", "CommandPrefix")
			Discord.SendEmbed("Set ``" newPrefix "`` as your command prefix!" ((StrLen(params[2]) > 3) ? "\nThe maximum prefix length is 3." : ""), 5066239, , , , id)
		} else {
			Discord.SendEmbed("``" ((StrLen(params[2]) > 0) ? params[2] : "<blank>") "`` is not a valid prefix!" ((StrLen(params[2]) = 0) ? "\nYou cannot have an empty prefix!" : ""), 16711731, , , , id)
		}


		case "s", "set":
		switch params[2], 0 {
			default:
			Loop 1 {
				for k, v in settings {
					if ((k = params[2]) && HasProp(v, "regex")) {
						value := Trim(SubStr(command.content, InStr(command.content, params[2]) + StrLen(params[2])))
						if (value ~= v.regex) {
							(v.type = "str") ? UpdateStr(k, (value = "<blank>") ? "" : value, v.section) : UpdateInt(k, value, v.section)
							Discord.SendEmbed("Set ``" k "`` to ``" value "``!", 5066239, , , , id)
						} else {
							Discord.SendEmbed("``" ((StrLen(value) > 0) ? value : "<blank>") "`` is not an acceptable value for ``" k "``!", 16711731, , , , id)
						}
						break 2
					}
				}
				Discord.SendEmbed("``" ((StrLen(params[2]) > 0) ? params[2] : "<blank>") "`` is not a valid setting!\nUse ``?help set`` for a list of settings.", 16711731, , , , id)
			}
		}


		case "get":
		k := StrReplace(Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name))), " ")
		str := ""
		try ini := FileOpen(A_WorkingDir "\settings\main_config.ini", "r"), str := ini.Read(), ini.Close()
		Loop Parse str, "`n", "`r" A_Space A_Tab {
			switch (c := SubStr(A_LoopField, 1, 1)) {
				case "[",";":
				continue


				default:
				if ((p := InStr(A_LoopField, "=")) && (k = SubStr(A_LoopField, 1, p-1))) {
					k := SubStr(A_LoopField, 1, p-1), v := SubStr(A_LoopField, p+1), s := 1
					break
				}
			}
		}
		if IsSet(s) {
			postdata :=
			(
			'
			{
				"embeds": [{
					"color": "5066239",
					"fields": [{
							"name": "' k '",
							"value": "' ((StrLen(v) > 0) ? v : "<blank>") '"
						}
					]
				}],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
					"message_id": "' id '",
					"fail_if_not_exists": false
				}
			}
			'
			)
			Discord.SendMessageAPI(postdata)
		}
		else {
			Discord.SendEmbed("``" (k ? k : "<blank>") "`` is not a valid variable!", 16711731, , , , id)
		}


		case "send":
		Send (options := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name))))
		Discord.SendEmbed('Used ``````ahk\nSend \"' StrReplace(options, '"', '\"') '\"``````', 5066239, , , , id)


		case "upload":
		Discord.SendFile(Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name))), id)


		case "download":
		if (url := command.url) {
			path := StrReplace(RTrim(StrReplace(Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name))), "/", "\"), "\"), "\\", "\"), message := ""
			if (StrLen(path) > 0) {
				if !FileExist(path) {
					try {
						DirCreate(path), message .= 'Created folder ``' StrReplace(StrReplace(path, "\", "\\"), '"', '\"') '``\n'
					} catch as e {
						message .= "'Create Directory' Error:\n" e.Message " " e.What "\n\n"
					}
				}
				if InStr(FileExist(path), "D") {
					SplitPath(url, &fileName)
					(pos := InStr(fileName, "?")) && (fileName := SubStr(fileName, 1, pos-1))
					try {
						Download(url, (path .= "\" filename))
						Discord.SendEmbed(message .= 'Downloaded ``' StrReplace(StrReplace(path, "\", "\\"), '"', '\"') '``', 5066239, , , , id)
					} catch as e {
						Discord.SendEmbed(message .= "Download Error:\n" e.Message " " e.What, 16711731, , , , id)
					}
				}
			} else {
				Discord.SendEmbed("You must specify a valid directory!", 16711731, , , , id)
			}
		} else {
			Discord.SendEmbed("No attachment found to download!", 16711731, , , , id)
		}


		case "click":
		switch params[2], 0 {
			case "mode":
			if ((params[3] = "screen") || (params[3] = "relative") || (params[3] = "window") || (params[3] = "client")) {
				CoordMode("Mouse", params[3])
				Discord.SendEmbed("Used ``````ahk\nCoordMode, Mouse, " RegExReplace(params[3], "(?:^|\.|\R)[- 0-9\*\(]*\K(.)([^\.\r\n]*)", "$U1$L2") "``````", 5066239, , , , id)
			} else {
				Discord.SendEmbed("Invalid ``CoordMode``!\nMust be either ``Screen``, ``Relative``, ``Window``, or ``Client``", 16711731, , , , id)
			}

			default:
			options := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name)))
			if (InStr(options, "WheelUp") || InStr(options, "WheelDown") || InStr(options, "WU") || InStr(options, "WD")) {
				for k, v in ["WheelUp","WheelDown","WU","WD"] {
					if (p := InStr(options, v)) {
						Loop Parse SubStr(options, p + StrLen(v) + 1), A_Space {
							if (A_LoopField != "") {
								count := A_LoopField
								break
							}
						}

						if IsSet(count) {
							if (count ~= "i)^[0-9]+$") {
								options := SubStr(options, 1, p + StrLen(v))
								Loop count {
									Click(options)
									Sleep 50
								}
								Discord.SendEmbed('Used ``````ahk\nLoop ' count '\n{\n  Click \"' options '\"\n  Sleep 50\n}``````', 5066239, , , , id)
							} else {
								Discord.SendEmbed("Click options are not valid!\nWheel scroll count must be an integer!", 16711731, , , , id)
							}
						} else {
							Click(options)
							Discord.SendEmbed('Used ``````ahk\nClick \"' options '\"``````', 5066239, , , , id)
						}
					}
				}
			} else {
				Click(options)
				Discord.SendEmbed('Used ``````ahk\nClick' ((StrLen(options) > 0) ? (' \"' options '\"') : "") '``````', 5066239, , , , id)
			}
		}


		case "shutdown":
		RegExMatch(params[2], "i)^(0|1|2|3|8|9|10|11)$", &ShutdownCode)
		if ShutdownCode = 0 || ShutdownCode = 1 || ShutdownCode = 2 || ShutdownCode = 3 || ShutdownCode = 8 || ShutdownCode = 9 || ShutdownCode = 10 || ShutdownCode = 11 {
			ShutdownCode := ShutdownCode + 4
			Discord.SendEmbed("Shutting system down with code " params[2] " + 4 (Force)...", 5066239, , , , id)
			try {
				Shutdown(ShutdownCode)
			}
		} else {
			Discord.SendEmbed("Invalid code!!!", 16711731, DiscordUserID, , , id)
		}

			postdata .= "]}"
			Discord.SendMessageAPI(postdata)


		case "info", "i", "information", "inform", "whatis", "whis", "nameit", "nit", "cmds", "commands", "cmd":
		switch params[2], 0 {
			case "shutdown":
			postdata :=
			(
			'
			{
				"embeds": [{
					"title": "``' CommandPrefix 'shutdown``" ,
					"color": "5066239",
					"fields": [{
						"name": "Shuts your computer system using the given parameters, which you can find out about at https://www.autohotkey.com/docs/v2/lib/Shutdown.htm\nNote: Force is automatically applied to your code\nNote: You also will not be logged in",
						"value": "Usage: ``' CommandPrefix 'shutdown [code]``",
						"inline": true
					}]
				}],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
					"message_id": "' id '",
					"fail_if_not_exists": false
				}
			}
			'
			)


			case "set", "s":
			switch params[3], 0 {
				case "ReversedStatusLog":
				postdata :=
				(
				'
				{
					"embeds": [{
						"title": "``' CommandPrefix 'set ReversedStatusLog``" ,
						"color": "5066239",
						"fields": [{
							"name": "Reverse/un-reverse the order of events in the status log.",
							"value": "Usage: ``' CommandPrefix 'set ReversedStatusLog [0|1]``",
							"inline": true
						}]
					}],
					"allowed_mentions": {
						"parse": []
					},
					"message_reference": {
						"message_id": "' id '",
						"fail_if_not_exists": false
					}
				}
				'
				)


				case "":
				postdata :=
				(
				'
				{
					"embeds": [{
						"title": "``' CommandPrefix 'set``" ,
						"color": "5066239",
						"fields": [{
							"name": "Set a variable to a value from its RegEx (use ``' CommandPrefix 'info set [Variable]`` to see its options)",
							"value": "Usage: ``' CommandPrefix 'set [Variable] [Value]``",
							"inline": true
						}]
					}],
					"allowed_mentions": {
						"parse": []
					},
					"message_reference": {
						"message_id": "' id '",
						"fail_if_not_exists": false
					}
				}
				'
				)


				default:
				Discord.SendEmbed("``<blank>`` is not a valid variable or hasn't been added yet!"    , 16711731, , , , id)
			}


			case "a", "ad", "adv", "advance", "advanced":
			postdata :=
			(
			'
			{
				"embeds": [{
					"title": "``' CommandPrefix 'advanced``" ,
					"color": "5066239",
					"fields": [{
						"name": "Display useful commands (like ``' CommandPrefix 'help) that are for more advanced usage",
						"value": "Usage: ``' CommandPrefix 'advanced``",
						"inline": true
					}]
				}],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
					"message_id": "' id '",
					"fail_if_not_exists": false
				}
			}
			'
			)


			case "activate":
			postdata :=
			(
			'
			{
				"embeds": [{
					"title": "``' CommandPrefix 'activate``" ,
					"color": "5066239",
					"fields": [{
						"name": "Activates a minimised window",
						"value": "Usage: ``' CommandPrefix 'activate [WindowTitle]``",
						"inline": true
					}]
				}],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
					"message_id": "' id '",
					"fail_if_not_exists": false
				}
			}
			'
			)


			case "click":
			postdata :=
			(
			'
			{
				"embeds": [{
					"title": "``' CommandPrefix 'click``" ,
					"color": "5066239",
					"fields": [{
						"name": "Clicks a key",
						"value": "Usage: ``' CommandPrefix 'click [key]``",
						"inline": true
					}]
				}],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
					"message_id": "' id '",
					"fail_if_not_exists": false
				}
			}
			'
			)


			case "":
			sections := Map("Commands", "**__Commands__**"), sections.Default := "Commands"
					
			; populate each variable list
			for k, v in commands {
				if (HasProp(v, "section")) {
					sections[v.section] .= "`n" k
				}
			}
					
			; trim all lists to 4096 characters (max embed description)
			for , list in sections {
				list := SubStr(list, 1, 4096)
			}
					
			; split lists into max 4096 character embeds
			enum := sections.__Enum(), enum.Call(,&section)
			embeds := [], embed := Map("title", "List of Commands using ``" CommandPrefix "``")
			Loop 10 {
				embed["color"] := 7569663, embed["description"] := section
				Loop sections.Count {
					if (enum.Call(,&section) = 0) {
						embeds.Push(embed)
						break 2
					}
					if (StrLen(embed["description"]) + StrLen(section) > 4092) { ; 4 characters for "\n\n"
						break
					} else {
						embed["description"] .= "`n`n" section
					}
				}
				embeds.Push(embed.Clone()), embed.Clear()
			}
					
			; send embeds as separate messages (because of the max 6000 character limit)
			enum := embeds.__Enum(), enum.Call(&embed)
			postdata :=
			(
			'
			{
				"embeds": [' JSON.stringify(embed) '],
				"allowed_mentions": {
					"parse": []
				},
				"message_reference": {
				"message_id": "' id '",
				"fail_if_not_exists": false
				}
			}
			'
			)
			while enum.Call(&embed) {
				Discord.SendMessageAPI(postdata), postdata := '{"embeds": [' JSON.stringify(embed) ']}'
			}


        default:
        Discord.SendEmbed("``" CommandPrefix name "`` does not exist or hasn't been added yet!", 16711731, , , , id)
	}
    Discord.SendMessageAPI(postdata)

		#Include "*i %A_ScriptDir%\..\settings\personal_commands\"
		; #Include ".ahk"

		default:
		Discord.SendEmbed("``" CommandPrefix name "`` is not a valid command!\nUse ``" CommandPrefix "help`` for a list of commonly used commands.", 16711731, , , , id)
	}
	command_buffer.RemoveAt(1)
}



class Discord {
	static baseURL := "https://Discord.com/api/v9/"

	static SendEmbed(message, colour := 3223350, content := "", pBitmap := 0, channel := "", replyID := 0) {
		payload_json :=
		(
		'
		{
			"content": "' content '",
			"embeds": [{
				"description": "' message '",
				"color": "' colour '"
				' (pBitmap ? (',"image": {"url": "attachment://ss.png"}') : '') '
			}]
			' (replyID ? (',"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}') : '') '
		}
		'
		)

		if pBitmap {
			this.CreateFormData(&postdata, &contentType, [Map("name", "payload_json", "content-type", "application/json", "content", payload_json), Map("name", "files[0]", "filename", "ss.png", "content-type", "image/png", "pBitmap", pBitmap)])
        } else {
			postdata := payload_json, contentType := "application/json"
        }

		return this.SendMessageAPI(postdata, contentType, channel)
	}

	static SendFile(filepath, replyID:=0) {
		static MimeTypes := Map("PNG", "image/png"
		 , "JPEG", "image/jpeg"
		 , "JPG", "image/jpeg"
	 	 , "BMP", "image/bmp"
 		 , "GIF", "image/gif"
		 , "WEBP", "image/webp"
	 	 , "TXT", "text/plain"
 		 , "INI", "text/plain")

		if (attr := FileExist(filepath)) {
			SplitPath(filepath := RTrim(filepath, "\/"), &file := "")
			if (file && InStr(attr, "D")) {
				; attempt to zip folder to temp
				try {
					RunWait('powershell.exe -WindowStyle Hidden -Command Compress-Archive -Path "' filepath '\*" -DestinationPath "$env:TEMP\' file '.zip" -CompressionLevel Fastest -Force', , "Hide")
					if !FileExist(filepath := A_Temp "\" file ".zip")
						throw
				} catch {
					this.SendEmbed('The folder ``' StrReplace(StrReplace(filepath, "\", "\\"), '"', '\"') '`` could not be zipped!`nThis function is only supported on Windows 10 or higher.', 16711731, , , , replyID)
					return -3
				}
			}
			size := FileGetSize(filepath)
			if (size > 26214076) {
				this.SendEmbed('``' StrReplace(StrReplace(filepath, "\", "\\"), '"', '\"') '`` is above the Discord file size limit of 25MiB!', 16711731, , , , replyID)
				return -1
			}
		} else {
			this.SendEmbed('``' StrReplace(StrReplace(filepath, "\", "\\"), '"', '\"') '`` does not exist or could not be read!', 16711731, , , , replyID)
			return -2
		}

		SplitPath(filepath, &file, , &ext)
		ext := StrUpper(ext)
		params := []
		(replyID > 0) && params.Push(Map("name", "payload_json", "content-type", "application/json", "content", '{"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}}'))
		params.Push(Map("name", "files[0]", "filename", file, "content-type", MimeTypes.Has(ext) ? MimeTypes[ext] : "application/octet-stream", "file", filepath))
		this.CreateFormData(&postdata, &contentType, params)
		this.SendMessageAPI(postdata, contentType)

		; delete any temp file created
		if (SubStr(filepath, 1, StrLen(A_Temp)) = A_Temp) {
			try {
				FileDelete(filepath)
			}
        }
	}

	static SendImage(pBitmap, imageName := "image.png", replyID := 0) {
		params := []
		(replyID > 0) && params.Push(Map("name", "payload_json", "content-type", "application/json", "content", '{"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}}'))
		params.Push(Map("name", "files[0]", "filename", imageName, "content-type", "image/png", "pBitmap", pBitmap))
		this.CreateFormData(&postdata, &contentType, params)
		this.SendMessageAPI(postdata, contentType)
	}

	static SendMessageAPI(postdata, contentType := "application/json", channel := "", url := "") {
		global WebhookURL, BotToken, DiscordMode, MainChannelCheck, MainChannelID

		if (!channel && (DiscordMode = 2)) {
			if MainChannelCheck = 1 {
				channel := MainChannelID
            } else {
				return -2
            }
		}

		if (!url) {
			url := (DiscordMode = 1) ? (WebhookURL "?wait=true") : (this.BaseURL "/channels/" channel "/messages")
        }

		try {
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("POST", url, 1)
			if (DiscordMode = 2) {
				wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
				wr.SetRequestHeader("Authorization", "Bot " BotToken)
			}
			wr.SetRequestHeader("Content-Type", contentType)
			wr.SetTimeouts(0, 60000, 120000, 30000)
			wr.Send(postdata)
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static GetCommands(channel) {
		global DiscordMode, CommandPrefix

		if DiscordMode = 1 {
			return -1
		}

		Loop (n := (messages := this.GetRecentMessages(channel)).Length) {
			i := n - A_Index + 1
			Sleep 1000
			(SubStr(content := Trim(messages[i]["content"]), 1, StrLen(CommandPrefix)) = CommandPrefix) && command_buffer.Push({content:content, id:messages[i]["id"], url:messages[i]["attachments"].Has(1) ? messages[i]["attachments"][1]["url"] : ""})
		}
	}

	static GetRecentMessages(channel) {
		global DiscordMode
		static lastmsg := Map()

		if DiscordMode = 1 {
			return -1
		}

		try {
			(messages := JSON.parse(text := this.GetMessageAPI(lastmsg.Has(channel) ? ("?after=" lastmsg[channel]) : "?limit=1", channel))).Length
		} catch {
			return []
		}

		if (messages.Has(1)) {
			lastmsg[channel] := messages[1]["id"]
		}

		return messages
	}

	static GetMessageAPI(params := "", channel := "") {
		global BotToken, DiscordMode, MainChannelCheck, MainChannelID

		if DiscordMode = 1 {
			return -1
		}

		if (!channel) {
			if MainChannelCheck = 1 {
				channel := MainChannelID
			} else {
				return -2
			}
		}

		try {
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("GET", this.BaseURL "/channels/" channel "/messages" params, 1)
			wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
			wr.SetRequestHeader("Authorization", "Bot " BotToken)
			wr.SetRequestHeader("Content-Type", "application/json")
			wr.Send()
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static EditMessageAPI(id, postdata, contentType := "application/json", channel := "") {
		if (!channel && DiscordMode = 2) {
			if (MainChannelCheck = 1) {
				channel := MainChannelID
            } else {
				return -2
            }
		}

		url := (DiscordMode = 1) ? (WebhookURL "/messages/" id) : (this.BaseURL "/channels/" channel "/messages/" id)

		try {
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("PATCH", url, 1)
			if DiscordMode = 2 {
				wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
				wr.SetRequestHeader("Authorization", "Bot " BotToken)
			}
			wr.SetRequestHeader("Content-Type", contentType)
			wr.SetTimeouts(0, 60000, 120000, 30000)
			wr.Send(postdata)
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static CreateFormData(&retData, &contentType, fields) {
		static chars := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"

		chars := Sort(chars, "D| Random")
		boundary := SubStr(StrReplace(chars, "|"), 1, 12)
		hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream:=0, "UInt")

		for field in fields {
			str :=
			(
			'

			------------------------------' boundary '
			Content-Disposition: form-data; name="' field["name"] '"' (field.Has("filename") ? ('; filename="' field["filename"] '"') : "") '
			Content-Type: ' field["content-type"] '

			' (field.Has("content") ? (field["content"] "`r`n") : "")
			)

			utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
			DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")

			if field.Has("pBitmap") {
				try {
					pFileStream := Gdip_SaveBitmapToStream(field["pBitmap"])
					DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
					DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
					DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
					ObjRelease(pFileStream)
				}
			}

			if field.Has("file") {
				DllCall("shlwapi\SHCreateStreamOnFileEx", "WStr", field["file"], "Int", 0, "UInt", 0x80, "Int", 0, "Ptr", 0, "PtrP", &pFileStream:=0)
				DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
				DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
				ObjRelease(pFileStream)
			}
		}

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
	}
}



sd_TrimLog(size) {
	global logsize
	try {
		log := FileOpen("\settings\debug_log.txt", "r-d"), log.Seek(-((log.Length < size) ? (f := log.Length) : size), 2), txt := log.Read(), log.Close()
		log := FileOpen("\settings\debug_log.txt", "w-d"), log.Write(SubStr(txt, f ? 1 : InStr(txt, "`n") + 1)), logsize := log.Length, log.Close()
	}
}

sd_SetStatus(wParam, lParam, *) {
	return status_buffer.Push(StrGet(lParam))
}

; currently only ReportChannelID
sd_SendPostData(wParam, lParam, *) {
	Critical
	global ReportChannelID, MainChannelID
	Discord.SendMessageAPI(StrGet(NumGet(lParam + 2 * A_PtrSize, "UPtr")), "application/json", (StrLen(ReportChannelID) > 16) ? ReportChannelID : MainChannelID)
	return 0
}

UpdateStr(var, value, section) {
	global
	static sections := Map("Settings", 1, "Discord", 2, "Status", 3)
	try %var% := value
	IniWrite(value, mainSettingsPath, section, var)
	DetectHiddenWindows(1)
	if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
		PostMessage(0x5553, settings[var].enum, sections[section])
	}
	if WinExist("background.ahk ahk_class AutoHotkey") {
		PostMessage(0x5553, settings[var].enum, sections[section])
	}
}

UpdateInt(var, value, section) {
	global
	try %var% := value
	IniWrite(value, mainSettingsPath, section, var)
	DetectHiddenWindows(1)
	if WinExist("skibi_defense_macro ahk_class AutoHotkey") {
		PostMessage(0x5552, settings[var].enum, value)
	}
	if WinExist("background.ahk ahk_class AutoHotkey") {
		PostMessage(0x5552, settings[var].enum, value)
	}
}

sd_SetGlobalInt(wParam, lParam, *) {
	global
	Critical
	local var
	; enumeration
	EnumInt()

	var := arr[wParam], %var% := lParam
	return 0
}

sd_SetGlobalStr(wParam, lParam, *) {
	global
	Critical
	local var
	; enumeration
	EnumStr()
	static sections := ["Discord", "Game", "Settings", "Status"]

	var := arr[wParam], section := sections[lParam]
	%var% := IniRead(mainSettingsPath, section, var)
	return 0
}

sd_SendHeartbeat(*) {
	Critical
	DetectHiddenWindows 1
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
		PostMessage(0x5556, 3)
	}
	return 0
}

RandomPrefix(*) {
	RandomPrefix := GenerateRandomString(1)
	return RandomPrefix
}

GenerateRandomString(count, *) {
	global
	if (!IsSet(PrevRandomString)) {
		PrevRandomString := ""
	}
	RandomStringArr := []
	Loop count {
		GeneratedString := Random(1, 93)
		if GeneratedString = 1 {
			RandomStringArr.Push("!")
		} else if (GeneratedString = 2) {
			RandomStringArr.Push('"')
		} else if (GeneratedString = 3) {
			RandomStringArr.Push("#")
		} else if (GeneratedString = 4) {
			RandomStringArr.Push("$")
		} else if (GeneratedString = 5) {
			RandomStringArr.Push("%")
		} else if (GeneratedString = 6) {
			RandomStringArr.Push("&")
		} else if (GeneratedString = 7) {
			RandomStringArr.Push("'")
		} else if (GeneratedString = 8) {
			RandomStringArr.Push("(")
		} else if (GeneratedString = 9) {
			RandomStringArr.Push(")")
		} else if (GeneratedString = 10) {
			RandomStringArr.Push("*")
		} else if (GeneratedString = 11) {
			RandomStringArr.Push("+")
		} else if (GeneratedString = 12) {
			RandomStringArr.Push(",")
		} else if (GeneratedString = 13) {
			RandomStringArr.Push("-")
		} else if (GeneratedString = 14) {
			RandomStringArr.Push(".")
		} else if (GeneratedString = 15) {
			RandomStringArr.Push("/")
		} else if (GeneratedString = 16) {
			RandomStringArr.Push("0")
		} else if (GeneratedString = 17) {
			RandomStringArr.Push("1")
		} else if (GeneratedString = 18) {
			RandomStringArr.Push("2")
		} else if (GeneratedString = 19) {
			RandomStringArr.Push("3")
		} else if (GeneratedString = 20) {
			RandomStringArr.Push("4")
		} else if (GeneratedString = 21) {
			RandomStringArr.Push("5")
		} else if (GeneratedString = 22) {
			RandomStringArr.Push("6")
		} else if (GeneratedString = 23) {
			RandomStringArr.Push("7")
		} else if (GeneratedString = 24) {
			RandomStringArr.Push("8")
		} else if (GeneratedString = 25) {
			RandomStringArr.Push("9")
		} else if (GeneratedString = 26) {
			RandomStringArr.Push(":")
		} else if (GeneratedString = 27) {
			RandomStringArr.Push(";")
		} else if (GeneratedString = 28) {
			RandomStringArr.Push("<")
		} else if (GeneratedString = 29) {
			RandomStringArr.Push("=")
		} else if (GeneratedString = 30) {
			RandomStringArr.Push(">")
		} else if (GeneratedString = 31) {
			RandomStringArr.Push("?")
		} else if (GeneratedString = 32) {
			RandomStringArr.Push("@")
		} else if (GeneratedString = 33) {
			RandomStringArr.Push("A")
		} else if (GeneratedString = 34) {
			RandomStringArr.Push("B")
		} else if (GeneratedString = 35) {
			RandomStringArr.Push("C")
		} else if (GeneratedString = 36) {
			RandomStringArr.Push("D")
		} else if (GeneratedString = 37) {
			RandomStringArr.Push("E")
		} else if (GeneratedString = 38) {
			RandomStringArr.Push("F")
		} else if (GeneratedString = 39) {
			RandomStringArr.Push("G")
		} else if (GeneratedString = 40) {
			RandomStringArr.Push("H")
		} else if (GeneratedString = 41) {
			RandomStringArr.Push("I")
		} else if (GeneratedString = 42) {
			RandomStringArr.Push("J")
		} else if (GeneratedString = 43) {
			RandomStringArr.Push("K")
		} else if (GeneratedString = 44) {
			RandomStringArr.Push("L")
		} else if (GeneratedString = 45) {
			RandomStringArr.Push("M")
		} else if (GeneratedString = 46) {
			RandomStringArr.Push("N")
		} else if (GeneratedString = 47) {
			RandomStringArr.Push("O")
		} else if (GeneratedString = 48) {
			RandomStringArr.Push("P")
		} else if (GeneratedString = 49) {
			RandomStringArr.Push("Q")
		} else if (GeneratedString = 50) {
			RandomStringArr.Push("R")
		} else if (GeneratedString = 51) {
			RandomStringArr.Push("S")
		} else if (GeneratedString = 52) {
			RandomStringArr.Push("T")
		} else if (GeneratedString = 53) {
			RandomStringArr.Push("U")
		} else if (GeneratedString = 54) {
			RandomStringArr.Push("V")
		} else if (GeneratedString = 55) {
			RandomStringArr.Push("W")
		} else if (GeneratedString = 56) {
			RandomStringArr.Push("X")
		} else if (GeneratedString = 57) {
			RandomStringArr.Push("Y")
		} else if (GeneratedString = 58) {
			RandomStringArr.Push("Z")
		} else if (GeneratedString = 59) {
			RandomStringArr.Push("[")
		} else if (GeneratedString = 60) {
			RandomStringArr.Push("\")
		} else if (GeneratedString = 61) {
			RandomStringArr.Push("]")
		} else if (GeneratedString = 62) {
			RandomStringArr.Push("^")
		} else if (GeneratedString = 63) {
			RandomStringArr.Push("_")
		} else if (GeneratedString = 64) {
			RandomStringArr.Push("a")
		} else if (GeneratedString = 65) {
			RandomStringArr.Push("b")
		} else if (GeneratedString = 66) {
			RandomStringArr.Push("c")
		} else if (GeneratedString = 67) {
			RandomStringArr.Push("d")
		} else if (GeneratedString = 68) {
			RandomStringArr.Push("e")
		} else if (GeneratedString = 69) {
			RandomStringArr.Push("f")
		} else if (GeneratedString = 70) {
			RandomStringArr.Push("g")
		} else if (GeneratedString = 71) {
			RandomStringArr.Push("h")
		} else if (GeneratedString = 72) {
			RandomStringArr.Push("i")
		} else if (GeneratedString = 73) {
			RandomStringArr.Push("j")
		} else if (GeneratedString = 74) {
			RandomStringArr.Push("k")
		} else if (GeneratedString = 75) {
			RandomStringArr.Push("l")
		} else if (GeneratedString = 76) {
			RandomStringArr.Push("m")
		} else if (GeneratedString = 77) {
			RandomStringArr.Push("n")
		} else if (GeneratedString = 78) {
			RandomStringArr.Push("o")
		} else if (GeneratedString = 79) {
			RandomStringArr.Push("p")
		} else if (GeneratedString = 80) {
			RandomStringArr.Push("q")
		} else if (GeneratedString = 81) {
			RandomStringArr.Push("r")
		} else if (GeneratedString = 82) {
			RandomStringArr.Push("s")
		} else if (GeneratedString = 83) {
			RandomStringArr.Push("t")
		} else if (GeneratedString = 84) {
			RandomStringArr.Push("u")
		} else if (GeneratedString = 85) {
			RandomStringArr.Push("v")
		} else if (GeneratedString = 86) {
			RandomStringArr.Push("w")
		} else if (GeneratedString = 87) {
			RandomStringArr.Push("x")
		} else if (GeneratedString = 88) {
			RandomStringArr.Push("y")
		} else if (GeneratedString = 89) {
			RandomStringArr.Push("z")
		} else if (GeneratedString = 90) {
			RandomStringArr.Push("{")
		} else if (GeneratedString = 91) {
			RandomStringArr.Push("|")
		} else if (GeneratedString = 92) {
			RandomStringArr.Push("}")
		} else if (GeneratedString = 93) {
			RandomStringArr.Push("~")
		}
	}
	RandomString := ""
	for k, v in RandomStringArr {
    	RandomString .= v
		if PrevRandomString == RandomString {
			sd_Status("ERROR: Random string generator generated an identical string to the previous one.")
			ExitFunc()
		}
		PrevRandomString := RandomString
	}
	return RandomString
}

ExitFunc(*) {
	Critical
	global status_buffer
	arr := []
	for k, v in status_buffer {
		arr.Push(v)
	}
	for k,v in arr {
		sd_Status(v)
	}
	Sleep 10000
}
