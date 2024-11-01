:: Begin batch script; start macro
@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %~dp0

:: Echo colours
set "grey=[90m"
set "red=[91m"
set "green=[92m"
set "yellow=[93m"
set "blue=[94m"
set "magenta=[95m"
set "cyan=[96m"
set "white=[97m"

set "repo_link=https://github.com/NegativeZero01/skibi-defense-macro"

:: If the script exists and the AutoHotkey 32-bit executable file exists, run the macro:
if exist "submacros\skibi_defense_macro.ahk" (
	if exist "submacros\AutoHotkey32.exe (
		echo %cyan%Starting Skibi Defense Macro . . .%reset%
		<nul set /p "=%green%Press any key to start . . .%reset%"
			pause >nul
		start "" "%~dp0submacros\AutoHotkey32.exe" "%~dp0submacros\skibi_defense_macro.ahk" %*
		exit
	) else (set "EXE_missing=1")
) else (set "Macro_missing=1")

:: Missing files:
if "%Macro_missing%" == "1" (
	echo %red%Failed to find the 'skibi_defense_macro.ahk' file in the suhmacros folder^^!
	echo This is most likely due to a third-party antivirus deleting the file, or a corrupted installation. Try following these steps to fix the issue:
	echo 1. Re-install the macro from the official GitHub; [%repo_link%, and check that 'skibi_defense_macro.ahk' exists in the submacros folder
	echo 2. Disable any third-party antivirus software ^(or add the Skibi Defense Macro folder as an exception^)
	echo 3. Run Start.bat
	echo:
	echo Note: Both Skibi Defense Macro and AutoHotkey are safe and work fine with Microsoft Defender%reset%
	:: echo Join the Discord server for support: discord.gg/%reset%^>
	echo:
	<nul set /p "=%grey%Press any key to exit . . . %reset%"
		pause >nul
	exit
)

if "%EXE_missing%" == "1" (
	echo %red%Failed to find the 'AutoHotkey32.exe' file in the submacros folder^^!
	echo This is most likely due to a third-party antivirus deleting the file, or a corrupted installation. Try following these steps to fix the issue:
	echo 1. Re-install the macro from the official GitHub; [%repo_link%], and check that 'AutoHotkey32.exe' exists in the submacros folder
	echo 2. Disable any third-party antivirus software ^(or add the Skibi Defense Macro folder as an exception^)
	echo 3. Run Start.bat
	echo:
	echo Note: Both Skibi Defense Macro and AutoHotkey are safe and work fine with Microsoft Defender.%reset%^>
	:: echo Join the Discord server for support: discord.gg/%reset%
	echo:
	<nul set /p "=%grey%Press any key to exit . . . %reset%"
		pause >nul
	exit
)

:: Or try to find the .zip file in common install directories, extract it, then run the macro:
for %%a in (".\..") do set "grandparent=%%~nxa"
if not [!grandparent!] == [] (
	for /f "tokens=1,* delims=_" %%a in ("%grandparent%") do set "zip=%%b"
	if not [!zip!] == [] (
		call set str=%%zip:*.zip=%%
		call set zip=%%zip:!str!=%%
		if not [!zip!] == [] (
			echo %yellow%Looking for !zip! . . .%reset%
			cd %USERPROFILE%
			for %%a in ("Downloads","Downloads\Skibi Defense Macro","Desktop","Documents","OneDrive\Downloads","OneDrive\Downloads\Skibi Defense Macro","OneDrive\Desktop","OneDrive\Documents") do (
				if exist "%%~a\!zip!" (
					echo %green%.zip File found in %%~a^^!%reset%
					echo:
					
					echo %magenta%Extracting %USERPROFILE%\%%~a\!zip! . . .%reset%
					for /f delims^=^ EOL^= %%g in ('cscript //nologo "%~f0?.wsf" "%USERPROFILE%\%%~a" "%USERPROFILE%\%%~a\!zip!"') do set "folder=%%g"
					echo %cyan%Extract complete^^!%reset%
					echo:
					
					echo %magenta%Deleting unextracted !zip! . . .%reset%
					del /f /q "%USERPROFILE%\%%~a\!zip!" >nul
					echo %yellow%Deleted successfully^^!%reset%
					echo:
					
					echo %cyan%Extract complete^^! Starting Skibi Defense Macro in 10 seconds.%reset%
					<nul set /p =%green%Press any key to skip . . . %reset%
					timeout /t 10 >nul
					start "" "%USERPROFILE%\%%~a\!folder!\submacros\AutoHotkey32.exe" "%USERPROFILE%\%%~a\!folder!\submacros\skibi-defense-macro.ahk"
					exit
				)
			)
		) else (echo %redNo .zip detected; essential files are missing^^!%reset%)
	) else (echo %red%Could not determine name of the unextracted .zip.%reset%)
) else (echo %red%Could not find Temp folder of unextracted .zip^^! ^(.bat has no grandparent^)%reset%)

echo %red%Unable to automatically extract Skibi Defense Macro^^!
echo - If you have already extracted, you are missing important files. Please re-extract
echo - If you have not extracted, you may have to manually extract the zipped folder#reset%
:: echo Join the Discord for support: discord.gg/%reset%
echo:
<nul set /p "=%grey%Press any key to exit . . . %reset%"
pause >nul
exit

----- Begin wsf script --->
<job><script language="VBScript">
set fso = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("Shell.Application")
set FilesInZip = objShell.NameSpace(WScript.Arguments(1)).items
for each folder in FilesInZip
	WScript.Echo folder
next
objShell.NameSpace(WScript.Arguments(0)).CopyHere FilesInZip, 20
set fso = Nothing
set objShell = Nothing
</script></job>