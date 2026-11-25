@echo off
setlocal
pushd "%~dp0..\.."
set "APPDATA=%CD%\.godot-home"
set "LOCALAPPDATA=%CD%\.godot-home"
start "" "%CD%\tools\godot\Godot_v4.7.2-stable_win64.exe" --path "%~dp0motion"
popd
