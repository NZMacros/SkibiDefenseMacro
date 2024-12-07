/*
  _____   _                _             
 |  __ \ | |              (_)            
 | |__) || | _   _   __ _  _  _ __   ___ 
 |  ___/ | || | | | / _` || || '_ \ / __|
 | |     | || |_| || (_| || || | | |\__ \
 |_|     |_| \__,_| \__, ||_||_| |_||___/
                     __/ |               
                    |___/                
*/

; You can use this file to make use of any functions in the main files, as well as being able to use the all libraries, specifically based on what you need
; By default, functions.ahk is included, but you can include any files you need from the main macro using this formal:
; #Include "%A_WorkingDir%\" <-- This automatically redirects all following #Include's to be in the main macro folder, meaning you can include files/libraries like this:
; #Include "lib\ROBLOX.ahk" or #Include "lib\mainFiles\GUI.ahk"
; After including what you need in THIS file (do it below), you can then include THIS file into your plugin
; Make sure to remove the #Include for this file in your plugin once it's completed to avoid duplicate function definitions

#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir "\..\..")
#Include "%A_WorkingDir%\"
#Include "lib\mainFiles\functions.ahk"

; To create a plugin, you need to follow these basic steps:
; 1. Name the file the name of the tab you want to implement into the macro
; 2. Define the basic parameters you need
; 3. Include this file
; 4. Start with "TabCtrl.UseTab("")" and in-between the quotations, put the file name (to reference the tab)
; You now need to design the file and the tab and include any functions it uses
; Finally, find the #Include in lib\mainFiles\GUI.ahk that includes the lib\Plugins directory, and include your file underneath it
; If your plugin requires you to modify other things within the macro to make a functioning tab but would also like to share the plugin, you can create a fork (with permission) of the repository with your changes for others to use
; To finalise your Plugin, ensure it abides by the Plugin_LICENSE.txt's terms!
