@echo off
setlocal enabledelayedexpansion

:: Get Steam installation path from the registry
for /f "tokens=2* delims= " %%A in ('reg query "HKCU\SOFTWARE\Valve\Steam" /v "SteamPath" 2^>nul') do set SteamPath=%%B

:: Normalize path
set SteamPath=%SteamPath:\=/%

:: Define game install path
set GamePath=%SteamPath%/steamapps/common/Source SDK Base 2013 Singleplayer
set BinPath=%GamePath%/bin

:: Check if the game is installed
if not exist "%GamePath%" (
    echo Source SDK Base 2013 Singleplayer is not installed.
    echo Press any key to install it via Steam...
    pause
    start steam://install/243730
    echo Waiting for installation to complete...
    :check_install
    timeout /t 10 >nul
    if not exist "%GamePath%" goto check_install
)

:: Ensure the game is fully installed
echo Source SDK Base 2013 Singleplayer found.

:: Define local bin folder
set LocalBin=%~dp0bin

:: Ensure local bin exists
if not exist "%LocalBin%" (
    echo Error: No "bin" folder found adjacent to this script.
    pause
    exit /b
)

:: Copy bin contents
echo Copying files to game directory...
xcopy /E /Y "%LocalBin%\*" "%BinPath%\" >nul

:: Create shortcuts
set ScriptDir=%~dp0
echo Creating shortcuts...

:: Function to create shortcuts using PowerShell
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%ScriptDir%Hammer++.lnk');$s.TargetPath='%BinPath%\hammerplusplus.exe';$s.Save()"
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%ScriptDir%HLMV++.lnk');$s.TargetPath='%BinPath%\hlmvplusplus.exe';$s.Save()"
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%ScriptDir%VMT Editor.lnk');$s.TargetPath='%BinPath%\VMT_Editor.exe';$s.Save()"

echo Setup complete! Shortcuts created.
pause
