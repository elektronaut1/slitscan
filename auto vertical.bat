@ECHO OFF
SETLOCAL
cls
@TITLE Slitscan processing

IF EXIST "%~dp0\%1" Set InputFile="%~dp0\%1"
IF EXIST "%1" Set InputFile="%1"
ECHO - Processing %InputFile% with default parameters

"%SYSTEMROOT%\system32\windowspowershell\v1.0\powershell.exe" -Command Start-Process "$PSHOME\powershell.exe" -ArgumentList "'-NoExit -ExecutionPolicy Bypass %~dp0\defaultslitscan.ps1 %InputFile% vertical'"

::pause
ENDLOCAL