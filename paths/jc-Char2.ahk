Loop {
    if sd_ImgSearch("Chapters\storymode.png", 30)[1] = 0 { ; switch tabs to story mode
        MouseMove(sd_ImgSearch("Chapters\storymode.png", 10)[2] - 21, sd_ImgSearch("Chapters\storymode.png", 10)[3] + 29), MouseMove(sd_ImgSearch("Chapters\storymode.png", 10)[2] - 20, sd_ImgSearch("Chapters\storymode.png", 10)[3] + 30)
        Sleep(250), Send("{Click}")
        Sleep 2500
        break
    }
}
Loop {
    returnVal := JoinChar()
    if returnVal = 1 {
        break
    } else if (returnVal = -1 || returnVal = -2) {
        CloseRoblox()
        DetectHiddenWindows(1)
        PostMessage(0x5557, 0, , , "skibi_defense_macro.ahk ahk_class AutoHotkey")
        DetectHiddenWindows(0)
        Exit()
    }
}

JoinChar() {
    hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd)
    if sd_ImgSearch("Chapters\ch2.png", 10)[1] = 0 { ; if this succeeds, move the mouse here and join
        MouseMove(sd_ImgSearch("Chapters\ch2.png", 10)[2] + 699, sd_ImgSearch("Chapters\ch2.png", 10)[3] + 89), MouseMove(sd_ImgSearch("Chapters\ch2.png", 10)[2] + 700, sd_ImgSearch("Chapters\ch2.png", 10)[3] + 90)
        Send "{Click}"
        Sleep 5000
        ; use an image search to verify its in the correct chapter and start the game. If it fails, find the disband button to exit and scroll to the top to try again
        if sd_ImgSearch("Chapters\ch2game.png", 10)[1] = 0 {
            if sd_ImgSearch("Chapters\startgame.png", 10)[1] = 0 {
                MouseMove(sd_ImgSearch("Chapters\startgame.png", 10)[2] - 1, sd_ImgSearch("Chapters\startgame.png", 10)[3] + 29), MouseMove(sd_ImgSearch("Chapters\startgame.png", 10)[2], sd_ImgSearch("Chapters\startgame.png", 10)[3] + 30)
                Sleep(250), Send("{Click}")
                Loop {
                    if (sd_ImgSearch("Chapters\startgame.png", 10)[1] = 0) {
                        MouseMove(sd_ImgSearch("Chapters\startgame.png", 10)[2] - 1, sd_ImgSearch("Chapters\startgame.png", 10)[3] + 29), MouseMove(sd_ImgSearch("Chapters\startgame.png", 10)[2], sd_ImgSearch("Chapters\startgame.png", 10)[3] + 30)
                        Sleep(250), Send("{Click}")
                    } else {
                        break
                    }
                    if A_Index > 850 {
                        return -1
                    }
                }
                Loop {
                    if sd_ImgSearch("Chapters\readygame.png", 10)[1] = 0 {
                        global InLobby := 1
                        DetectHiddenWindows(1)
                        if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
                            PostMessage(0x5556, InLobby)
                        }
                        if WinExist("background.ahk ahk_class AutoHotkey") {
                            PostMessage(0x5557, InLobby)
                        }
                        DetectHiddenWindows(0)
                        break
                    }
                    Sleep 1000
                    if A_Index > 1000 {
                        return -2
                    }
                }
                Loop { ;  check if now in game
                    if sd_ImgSearch("Chapters\readygame.png", 70)[1] = 1 {
                        Sleep 2500
                        Send "{" SC_Z "}"
                        return 1
                    }
                    Sleep 1000
                    if A_Index > 500 {
                        return -2
                    }
                }
            }
        } else {
            if sd_ImgSearch("Chapters\disbandparty.png", 15)[1] = 0 {
                MouseMove(sd_ImgSearch("Chapters\disbandparty.png", 15)[2] + 9, sd_ImgSearch("Chapters\disbandparty.png", 15)[3] + 24), MouseMove(sd_ImgSearch("Chapters\disbandparty.png", 15)[2] + 10, sd_ImgSearch("Chapters\disbandparty.png", 15)[3] + 25)
                Sleep(250), Send("{Click}")
            } else {
                return -1
            }
            MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
            Loop {
                if sd_ImgSearch("Chapters\storytop.png", 10)[1] = 0 {
                    break
                }
                Send "{WheelUp}"
            }
            return 0
        }
    } else if (sd_ImgSearch("Chapters\storybottom.png", 10)[1] = 1) { ; scroll down and try again
        MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
        Send "{WheelDown}"
        return 0
    } else { ; if chapter 6 is found, scroll all the way back up and try again
        MouseMove((windowX + (windowWidth//2)), (IsSet(offsetY) ? ((windowY + offsetY) + ((windowHeight - offsetY)//2)) : (windowY + (windowHeight//2))))
        Loop {
            if sd_ImgSearch("Chapters\storytop.png", 10)[1] = 0 {
                break
            }
            Send "{WheelUp}"
        }
        return 0
    }
}
