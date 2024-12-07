/*
   _____             _                       _____                                                _      
  / ____|           | |                     / ____|                                              | |     
 | |     _   _  ___ | |_  ___   _ __ ___   | |      ___   _ __ ___   _ __ ___    __ _  _ __    __| | ___ 
 | |    | | | |/ __|| __|/ _ \ | '_ ` _ \  | |     / _ \ | '_ ` _ \ | '_ ` _ \  / _` || '_ \  / _` |/ __|
 | |____| |_| |\__ \| |_| (_) || | | | | | | |____| (_) || | | | | || | | | | || (_| || | | || (_| |\__ \
  \_____|\__,_||___/ \__|\___/ |_| |_| |_|  \_____|\___/ |_| |_| |_||_| |_| |_| \__,_||_| |_| \__,_||___/                                                                                                                                                                                                              
*/

; Welcome to the custom commands lobby! In this folder, you can create files that contain information for bot-commands
; When you create a file here, make sure to open Discord.ahk, and find the commented "#Include .ahk"
; Remove the comment and replace it with the name of the file you create to include the command
; After this, you need to create the raw command (even if you get errors for placing some code in places it shouldn't be), which you can use the examples below

; First, start with a "case", which tells the macro's Discord integration to search for the parameters you give
; For example, the code below would make the macro send an embed if the command contains the words "hello" and "hi":

case "hello", "hi":
Discord.SendEmbed("Hello!")

; If you want to create a sub-command inside this, for example, how you can use "?help" along with "?help set", include an extra switch parameter inside the first case
; For example, the code below will search for a second parameter, and if it doesn't exist, send the normal embed:

case "hello", "hi":
switch params[2], 0 ; <-- Case sensitivity
;             ^
;             |
;             |
;       The parameter number
{
    case "goodbye", "bye":
    Discord.SendEmbed("Hi! Bye!")


    default:
    Discord.SendEmbed("Hello!")
}

; From here, what you do is based completely on your own knowledge. You can look through the Discord.ahk pre-installed command's code and if you want your command to do things to the main script, read AutoHotkey v2's documentation for Post/SendMessage and OnMessage
; Have fun! Please remember you are required to include the provided Plugins license in the lib\Plugins folder and abide by the terms to create your plugin
