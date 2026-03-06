[CmdletBinding()]
param(
    [string]$BotUser = "openclaw_bot",
    [switch]$Live
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$failures = @()

function Write-Ok([string]$Message) {
    Write-Host "[OK]  $Message" -ForegroundColor Green
}

function Write-WarnMsg([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Fail([string]$Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:failures += $Message
}

function Test-HasCommand([string]$Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

Write-Host "OpenClaw Feishu Doctor"
Write-Host "----------------------"

if (Test-HasCommand "node") {
    Write-Ok "Node.js found: $(& node --version)"
} else {
    Write-Fail "Node.js not found in PATH."
}

if (Test-HasCommand "openclaw") {
    Write-Ok "OpenClaw found: $(& openclaw --version)"
} else {
    Write-Fail "openclaw not found in PATH."
}

$configPath = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"
if (-not (Test-Path -LiteralPath $configPath)) {
    Write-Fail "Missing config file: $configPath"
} else {
    Write-Ok "Config file exists: $configPath"
    try {
        $config = (Get-Content -LiteralPath $configPath -Raw) | ConvertFrom-Json

        $workspace = $config.agents.defaults.workspace
        if ([string]::IsNullOrWhiteSpace($workspace)) {
            Write-WarnMsg "agents.defaults.workspace is empty."
        } else {
            Write-Ok "Workspace: $workspace"
        }

        $feishuEnabled = $false
        try { $feishuEnabled = [bool]$config.channels.feishu.enabled } catch {}
        if ($feishuEnabled) {
            Write-Ok "channels.feishu.enabled = true"
        } else {
            Write-Fail "channels.feishu.enabled is not true."
        }

        $appId = ""
        try { $appId = "$($config.channels.feishu.accounts.default.appId)" } catch {}
        $appSecret = ""
        try { $appSecret = "$($config.channels.feishu.accounts.default.appSecret)" } catch {}
        if ([string]::IsNullOrWhiteSpace($appId) -or [string]::IsNullOrWhiteSpace($appSecret)) {
            Write-Fail "Feishu credentials are missing in channels.feishu.accounts.default."
        } else {
            Write-Ok "Feishu credentials are configured."
        }

        $telegramEnabled = $null
        try { $telegramEnabled = [bool]$config.channels.telegram.enabled } catch {}
        if ($null -ne $telegramEnabled -and $telegramEnabled) {
            Write-WarnMsg "Telegram channel is still enabled."
        } else {
            Write-Ok "Telegram channel is disabled (or not configured)."
        }
    } catch {
        Write-Fail "Failed to parse config: $($_.Exception.Message)"
    }
}

try {
    $bot = Get-LocalUser -Name $BotUser -ErrorAction SilentlyContinue
    if ($null -eq $bot) {
        Write-WarnMsg "Hardlock user not found: $BotUser"
    } else {
        Write-Ok "Hardlock user exists: $BotUser"
    }
} catch {
    Write-WarnMsg "Could not query local users (needs permissions)."
}

if ($Live -and (Test-HasCommand "openclaw")) {
    Write-Host ""
    Write-Host "Live check: openclaw channels list --json"
    try {
        $raw = (& openclaw channels list --json 2>&1 | Out-String)
        $start = $raw.IndexOf("{")
        $end = $raw.LastIndexOf("}")
        if ($start -ge 0 -and $end -gt $start) {
            $jsonText = $raw.Substring($start, $end - $start + 1)
            $liveObj = $jsonText | ConvertFrom-Json
            if ($liveObj.chat.feishu) {
                Write-Ok "Live channels include feishu account(s): $($liveObj.chat.feishu -join ", ")"
            } else {
                Write-WarnMsg "Live channels output has no feishu chat entries."
            }
        } else {
            Write-WarnMsg "Live output did not contain parseable JSON."
        }
    } catch {
        Write-WarnMsg "Live channel check failed: $($_.Exception.Message)"
    }
}

Write-Host ""
if ($failures.Count -gt 0) {
    Write-Host "Doctor result: FAILED" -ForegroundColor Red
    exit 1
}

Write-Host "Doctor result: OK" -ForegroundColor Green
exit 0
