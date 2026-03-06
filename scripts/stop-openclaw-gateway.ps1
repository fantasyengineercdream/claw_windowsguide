[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$targets = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match "^node(\.exe)?$" -and
    $_.CommandLine -like "*openclaw*" -and
    $_.CommandLine -like "*gateway*"
}

if (-not $targets) {
    Write-Host "No running OpenClaw gateway process found."
    exit 0
}

foreach ($p in $targets) {
    try {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop
        Write-Host "Stopped gateway process PID $($p.ProcessId)."
    } catch {
        Write-Warning "Failed to stop PID $($p.ProcessId): $($_.Exception.Message)"
    }
}
