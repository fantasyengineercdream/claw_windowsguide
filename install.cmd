@echo off
setlocal
set ROOT=%~dp0

if /I "%~1"=="cli" (
  shift
  powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\bootstrap-openclaw-feishu.ps1" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\openclaw-easy-gui.ps1"
)

endlocal
