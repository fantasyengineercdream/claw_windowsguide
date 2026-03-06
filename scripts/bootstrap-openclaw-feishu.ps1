[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FeishuAppId,
    [Parameter(Mandatory = $true)]
    [string]$FeishuAppSecret,
    [string]$WorkspacePath = (Join-Path $env:USERPROFILE "openclaw-workspace"),
    [string]$StatePath = "",
    [string]$BotUser = "openclaw_bot",
    [string]$BotPassword = "",
    [bool]$ApplyHardlock = $true,
    [bool]$DisableTelegram = $true,
    [switch]$SkipSiblingDeny,
    [switch]$SkipNodeAutoInstall,
    [switch]$SkipOpenClawInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Resolve-FullPath([string]$PathValue) {
    return [System.IO.Path]::GetFullPath($PathValue)
}

function Ensure-Directory([string]$PathValue) {
    if (-not (Test-Path -LiteralPath $PathValue)) {
        New-Item -ItemType Directory -Path $PathValue -Force | Out-Null
    }
}

function Test-HasCommand([string]$Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-OrCreateObject {
    param(
        [Parameter(Mandatory = $true)][object]$Parent,
        [Parameter(Mandatory = $true)][string]$PropertyName
    )

    $prop = $Parent.PSObject.Properties[$PropertyName]
    if ($null -eq $prop) {
        $newObject = [pscustomobject]@{}
        $Parent | Add-Member -NotePropertyName $PropertyName -NotePropertyValue $newObject
        return $newObject
    }

    if ($null -eq $prop.Value -or $prop.Value -is [string] -or $prop.Value.GetType().IsPrimitive) {
        $newObject = [pscustomobject]@{}
        $Parent.$PropertyName = $newObject
        return $newObject
    }

    return $prop.Value
}

if ([string]::IsNullOrWhiteSpace($StatePath)) {
    $StatePath = Join-Path $WorkspacePath ".openclaw-state"
}

$workspace = Resolve-FullPath $WorkspacePath
$state = Resolve-FullPath $StatePath

Write-Step "Preparing workspace and state directories"
Ensure-Directory $workspace
Ensure-Directory $state

Write-Step "Checking Node.js runtime"
if (-not (Test-HasCommand "node")) {
    if ($SkipNodeAutoInstall) {
        throw "Node.js is not installed. Install Node.js LTS, then run this script again."
    }

    if (-not (Test-HasCommand "winget")) {
        throw "Node.js is not installed and winget is unavailable. Install Node.js LTS manually."
    }

    Write-Host "Installing Node.js LTS with winget..."
    & winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        throw "winget failed to install Node.js (exit code: $LASTEXITCODE)."
    }

    foreach ($candidate in @("C:\Program Files\nodejs", "$env:LOCALAPPDATA\Programs\nodejs")) {
        if ((Test-Path -LiteralPath $candidate) -and -not (($env:Path -split ";") -contains $candidate)) {
            $env:Path += ";$candidate"
        }
    }
}
Write-Host "Node.js: $(& node --version)"

Write-Step "Checking OpenClaw CLI"
if (-not (Test-HasCommand "openclaw")) {
    if ($SkipOpenClawInstall) {
        throw "openclaw command is not installed. Install it, then run this script again."
    }

    if (-not (Test-HasCommand "npm")) {
        throw "npm is unavailable. Node.js installation appears incomplete."
    }

    Write-Host "Installing OpenClaw globally (npm install -g openclaw)..."
    & npm install -g openclaw
    if ($LASTEXITCODE -ne 0) {
        throw "npm failed to install openclaw (exit code: $LASTEXITCODE)."
    }

    try {
        $npmGlobalBin = (& npm bin -g 2>$null).Trim()
        if (-not [string]::IsNullOrWhiteSpace($npmGlobalBin) -and (Test-Path -LiteralPath $npmGlobalBin)) {
            if (-not (($env:Path -split ";") -contains $npmGlobalBin)) {
                $env:Path += ";$npmGlobalBin"
            }
        }
    } catch {
        Write-Host "npm global bin lookup skipped: $($_.Exception.Message)"
    }
}

if (-not (Test-HasCommand "openclaw")) {
    throw "openclaw is still unavailable in PATH after installation."
}
$openclawVersion = (& openclaw --version | Out-String).Trim()
Write-Host "OpenClaw: $openclawVersion"

Write-Step "Writing Feishu-only OpenClaw config"
$configRoot = Join-Path $env:USERPROFILE ".openclaw"
Ensure-Directory $configRoot
$configPath = Join-Path $configRoot "openclaw.json"

$config = [pscustomobject]@{}
if (Test-Path -LiteralPath $configPath) {
    try {
        $raw = Get-Content -LiteralPath $configPath -Raw
        if (-not [string]::IsNullOrWhiteSpace($raw)) {
            $config = $raw | ConvertFrom-Json
        }
    } catch {
        throw "Failed to parse existing config: $configPath"
    }
}

$meta = Get-OrCreateObject -Parent $config -PropertyName "meta"
$meta.lastTouchedAt = (Get-Date).ToUniversalTime().ToString("o")
$meta.lastTouchedVersion = $openclawVersion

$agents = Get-OrCreateObject -Parent $config -PropertyName "agents"
$defaults = Get-OrCreateObject -Parent $agents -PropertyName "defaults"
$defaults.workspace = $workspace

$channels = Get-OrCreateObject -Parent $config -PropertyName "channels"
$feishu = Get-OrCreateObject -Parent $channels -PropertyName "feishu"
$feishu.enabled = $true
$feishu.dmPolicy = "pairing"
$feishu.domain = "feishu"
$accounts = Get-OrCreateObject -Parent $feishu -PropertyName "accounts"
$defaultAccount = Get-OrCreateObject -Parent $accounts -PropertyName "default"
$defaultAccount.appId = $FeishuAppId
$defaultAccount.appSecret = $FeishuAppSecret

if ($DisableTelegram) {
    $telegram = Get-OrCreateObject -Parent $channels -PropertyName "telegram"
    $telegram.enabled = $false
    if ($telegram.PSObject.Properties["botToken"]) {
        $telegram.botToken = ""
    }
}

$plugins = Get-OrCreateObject -Parent $config -PropertyName "plugins"
$allowValues = @()
if ($plugins.PSObject.Properties["allow"] -and $plugins.allow) {
    $allowValues = @($plugins.allow | ForEach-Object { "$_" })
}
if ($DisableTelegram) {
    $allowValues = @($allowValues | Where-Object { $_ -ne "telegram" })
}
if (-not ($allowValues -contains "feishu")) {
    $allowValues += "feishu"
}
$plugins.allow = @($allowValues | Select-Object -Unique)

$entries = Get-OrCreateObject -Parent $plugins -PropertyName "entries"
$feishuEntry = Get-OrCreateObject -Parent $entries -PropertyName "feishu"
$feishuEntry.enabled = $true
if ($DisableTelegram) {
    $telegramEntry = Get-OrCreateObject -Parent $entries -PropertyName "telegram"
    $telegramEntry.enabled = $false
}

$json = $config | ConvertTo-Json -Depth 100
Set-Content -LiteralPath $configPath -Encoding utf8 -Value $json

Write-Host "Config saved: $configPath"
Write-Host "Workspace  : $workspace"
Write-Host "State path : $state"
Write-Host "Feishu app : $FeishuAppId"
if ($DisableTelegram) {
    Write-Host "Telegram   : disabled"
}

if ($ApplyHardlock) {
    Write-Step "Applying Windows hardlock (UAC prompt may appear)"
    $hardlockScript = Join-Path $PSScriptRoot "apply-openclaw-hardlock-elevated.ps1"
    if (-not (Test-Path -LiteralPath $hardlockScript)) {
        throw "Missing script: $hardlockScript"
    }

    $invokeArgs = @{
        WorkspacePath = $workspace
        StatePath = $state
        BotUser = $BotUser
    }
    if (-not [string]::IsNullOrWhiteSpace($BotPassword)) {
        $invokeArgs.BotPassword = $BotPassword
    }
    if ($SkipSiblingDeny) {
        $invokeArgs.SkipSiblingDeny = $true
    }

    & $hardlockScript @invokeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Hardlock setup failed (exit code: $LASTEXITCODE)."
    }
}

Write-Step "Done"
Write-Host "Next command:"
Write-Host "  openclaw gateway"
Write-Host ""
Write-Host "Optional (run under constrained user):"
$botPrincipal = "$env:COMPUTERNAME\$BotUser"
Write-Host "  runas /user:$botPrincipal `"powershell -NoProfile -NoExit -Command `"`$env:OPENCLAW_STATE_DIR='$state'; `$env:OPENCLAW_CONFIG_PATH='$configPath'; Set-Location -LiteralPath '$workspace'; openclaw gateway`"`""
