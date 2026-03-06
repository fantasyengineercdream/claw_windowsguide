[CmdletBinding()]
param(
    [switch]$Foreground
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) {
    throw "openclaw command not found in PATH."
}

$existing = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match "^node(\.exe)?$" -and
    $_.CommandLine -like "*openclaw*" -and
    $_.CommandLine -like "*gateway*"
}

if ($existing) {
    Write-Host "OpenClaw gateway is already running."
    $existing | Select-Object ProcessId, Name, CommandLine | Format-Table -AutoSize
    exit 0
}

if ($Foreground) {
    Write-Host "Starting OpenClaw gateway in foreground..."
    & openclaw gateway
    exit $LASTEXITCODE
}

$argList = @(
    "-NoProfile"
    "-ExecutionPolicy"
    "Bypass"
    "-Command"
    "openclaw gateway"
)

Start-Process -FilePath "powershell.exe" -WindowStyle Hidden -ArgumentList $argList | Out-Null
Write-Host "OpenClaw gateway started in background."
