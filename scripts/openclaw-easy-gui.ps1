[CmdletBinding()]
param(
    [string]$ScreenshotPath = "",
    [ValidateSet("default", "initial", "configured", "paired")]
    [string]$ScreenshotVariant = "default"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$isScreenshotMode = -not [string]::IsNullOrWhiteSpace($ScreenshotPath)
$bootstrapScript = Join-Path $PSScriptRoot "bootstrap-openclaw-feishu.ps1"
$startGatewayScript = Join-Path $PSScriptRoot "start-openclaw-gateway.ps1"
$modelGuidePath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\docs\OPENCLAW_MODEL_SETUP_CN.md"))

if (-not (Test-Path -LiteralPath $bootstrapScript)) {
    [System.Windows.Forms.MessageBox]::Show(
        "缺少脚本: $bootstrapScript",
        "OpenClaw 一键安装",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

function New-Label {
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width = 160
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Location = New-Object System.Drawing.Point($X, $Y)
    $label.Size = New-Object System.Drawing.Size($Width, 24)
    $label.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
    return $label
}

function New-Input {
    param(
        [int]$X,
        [int]$Y,
        [int]$Width = 500
    )
    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Location = New-Object System.Drawing.Point($X, $Y)
    $tb.Size = New-Object System.Drawing.Size($Width, 28)
    $tb.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
    return $tb
}

function New-Button {
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width = 140,
        [int]$Height = 34,
        [System.Drawing.Color]$BackColor = [System.Drawing.Color]::FromArgb(30, 136, 229),
        [System.Drawing.Color]$ForeColor = [System.Drawing.Color]::White
    )

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $Text
    $btn.Location = New-Object System.Drawing.Point($X, $Y)
    $btn.Size = New-Object System.Drawing.Size($Width, $Height)
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = $BackColor
    $btn.ForeColor = $ForeColor
    $btn.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $btn
}

function Append-Log {
    param(
        [Parameter(Mandatory = $true)][System.Windows.Forms.TextBox]$LogBox,
        [Parameter(Mandatory = $true)][string]$Message
    )
    if ([string]::IsNullOrWhiteSpace($LogBox.Text)) {
        $LogBox.Text = $Message
    } else {
        $LogBox.Text += "`r`n`r`n$Message"
    }
}

function Save-FormScreenshot {
    param(
        [Parameter(Mandatory = $true)][System.Windows.Forms.Form]$TargetForm,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $dir = Split-Path -Parent $fullPath
    if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $TargetForm.StartPosition = "Manual"
    $TargetForm.Location = New-Object System.Drawing.Point(40, 40)
    $TargetForm.ShowInTaskbar = $false
    $TargetForm.TopMost = $true
    [void]$TargetForm.Show()
    $TargetForm.Refresh()
    Start-Sleep -Milliseconds 300

    $bitmap = New-Object System.Drawing.Bitmap($TargetForm.Width, $TargetForm.Height)
    try {
        $rect = New-Object System.Drawing.Rectangle(0, 0, $TargetForm.Width, $TargetForm.Height)
        $TargetForm.DrawToBitmap($bitmap, $rect)
        $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $bitmap.Dispose()
        $TargetForm.Close()
    }
}

function Set-ScreenshotState {
    param(
        [Parameter(Mandatory = $true)][string]$Variant
    )

    $txtWorkspace.Text = "D:\OpenClawWorkspace"
    $txtState.Text = "D:\OpenClawWorkspace\.openclaw-state"
    $txtAppId.Text = ""
    $txtAppSecret.Text = ""
    $chkModelReady.Checked = $false
    $txtBotUser.Text = "openclaw_bot"
    $txtPairCode.Text = ""

    switch ($Variant) {
        "initial" {
            $txtLog.Text = "就绪. 请先准备飞书应用和 OpenClaw 模型, 再点击 一键安装并启动."
        }
        "configured" {
            $txtAppId.Text = "cli_your_app_id"
            $txtAppSecret.Text = "****************"
            $chkModelReady.Checked = $true
            $txtLog.Text = @"
[提示] 已先按飞书官方文档准备好 App ID/App Secret
[提示] 已先在 OpenClaw 中完成模型接入与默认模型设置
[下一步] 点击 一键安装并启动
"@
        }
        "paired" {
            $txtAppId.Text = "cli_your_app_id"
            $txtAppSecret.Text = "****************"
            $chkModelReady.Checked = $true
            $txtPairCode.Text = "PAIRCODE123"
            $txtLog.Text = @"
[提示] 已先按飞书官方文档准备好 App ID/App Secret
[提示] 已先在 OpenClaw 中完成模型接入与默认模型设置
[步骤] 准备工作目录
[步骤] 检查 Node.js 运行环境
[步骤] 写入飞书通道配置
[步骤] 应用 ACL 硬锁
[步骤] 启动网关
[下一步] 去飞书里拿配对码, 回到这里点击 批准配对
"@
        }
        default {
            $txtAppId.Text = "cli_your_app_id"
            $txtAppSecret.Text = "****************"
            $chkModelReady.Checked = $true
            $txtPairCode.Text = "PAIRCODE123"
            $txtLog.Text = @"
[提示] 已先按飞书官方文档准备好 App ID/App Secret
[提示] 已先在 OpenClaw 中完成模型接入与默认模型设置
[步骤] 准备工作目录
[步骤] 检查 Node.js 运行环境
[步骤] 写入飞书通道配置
[步骤] 应用 ACL 硬锁
[步骤] 启动网关
[步骤] 等待飞书配对码
完成.
"@
        }
    }

    Update-StateTextBox
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenClaw 一键安装 (飞书版)"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(1000, 900)
$form.MinimumSize = New-Object System.Drawing.Size(1000, 900)
$form.BackColor = [System.Drawing.Color]::FromArgb(243, 246, 251)
$form.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)

$panelHeader = New-Object System.Windows.Forms.Panel
$panelHeader.Location = New-Object System.Drawing.Point(0, 0)
$panelHeader.Size = New-Object System.Drawing.Size(1000, 92)
$panelHeader.BackColor = [System.Drawing.Color]::FromArgb(16, 42, 92)
$form.Controls.Add($panelHeader)

$title = New-Object System.Windows.Forms.Label
$title.Text = "OpenClaw Windows 一键安装"
$title.Location = New-Object System.Drawing.Point(24, 16)
$title.Size = New-Object System.Drawing.Size(560, 34)
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold)
$panelHeader.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "中文小白友好 | 无需 WSL/Docker | 飞书优先 | 可选 ACL 硬锁"
$subtitle.Location = New-Object System.Drawing.Point(24, 52)
$subtitle.Size = New-Object System.Drawing.Size(760, 24)
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(210, 226, 255)
$subtitle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$panelHeader.Controls.Add($subtitle)

$panelPrereq = New-Object System.Windows.Forms.Panel
$panelPrereq.Location = New-Object System.Drawing.Point(20, 108)
$panelPrereq.Size = New-Object System.Drawing.Size(944, 64)
$panelPrereq.BackColor = [System.Drawing.Color]::FromArgb(255, 248, 230)
$panelPrereq.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($panelPrereq)

$prereqTitle = New-Object System.Windows.Forms.Label
$prereqTitle.Text = "先准备飞书应用, 再准备 OpenClaw 模型"
$prereqTitle.Location = New-Object System.Drawing.Point(16, 10)
$prereqTitle.Size = New-Object System.Drawing.Size(280, 24)
$prereqTitle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$prereqTitle.ForeColor = [System.Drawing.Color]::FromArgb(120, 80, 8)
$panelPrereq.Controls.Add($prereqTitle)

$prereqText = New-Object System.Windows.Forms.Label
$prereqText.Text = "开始前, 请先按飞书官方文档准备好 App ID/App Secret, 再在 OpenClaw 里完成模型接入并选好默认模型."
$prereqText.Location = New-Object System.Drawing.Point(16, 34)
$prereqText.Size = New-Object System.Drawing.Size(720, 20)
$prereqText.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$prereqText.ForeColor = [System.Drawing.Color]::FromArgb(102, 76, 11)
$panelPrereq.Controls.Add($prereqText)

$btnOpenModelGuide = New-Button -Text "打开模型教程" -X 770 -Y 14 -Width 154 -Height 34 -BackColor ([System.Drawing.Color]::FromArgb(255, 183, 77)) -ForeColor ([System.Drawing.Color]::FromArgb(74, 43, 0))
$panelPrereq.Controls.Add($btnOpenModelGuide)

$panelConfig = New-Object System.Windows.Forms.Panel
$panelConfig.Location = New-Object System.Drawing.Point(20, 186)
$panelConfig.Size = New-Object System.Drawing.Size(944, 396)
$panelConfig.BackColor = [System.Drawing.Color]::White
$panelConfig.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($panelConfig)

$configTitle = New-Object System.Windows.Forms.Label
$configTitle.Text = "安装配置"
$configTitle.Location = New-Object System.Drawing.Point(16, 12)
$configTitle.Size = New-Object System.Drawing.Size(180, 24)
$configTitle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$configTitle.ForeColor = [System.Drawing.Color]::FromArgb(30, 45, 74)
$panelConfig.Controls.Add($configTitle)

$y = 46

$panelConfig.Controls.Add((New-Label -Text "工作目录" -X 16 -Y $y -Width 170))
$txtWorkspace = New-Input -X 190 -Y ($y - 2) -Width 580
$txtWorkspace.Text = Join-Path $env:USERPROFILE "openclaw-workspace"
$panelConfig.Controls.Add($txtWorkspace)
$btnWorkspace = New-Button -Text "浏览..." -X 784 -Y ($y - 3) -Width 140 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(236, 241, 249)) -ForeColor ([System.Drawing.Color]::FromArgb(28, 58, 108))
$panelConfig.Controls.Add($btnWorkspace)

$y += 44
$panelConfig.Controls.Add((New-Label -Text "状态目录" -X 16 -Y $y -Width 170))
$txtState = New-Input -X 190 -Y ($y - 2) -Width 580
$txtState.Text = Join-Path $txtWorkspace.Text ".openclaw-state"
$panelConfig.Controls.Add($txtState)
$btnState = New-Button -Text "浏览..." -X 784 -Y ($y - 3) -Width 140 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(236, 241, 249)) -ForeColor ([System.Drawing.Color]::FromArgb(28, 58, 108))
$panelConfig.Controls.Add($btnState)

$chkDefaultState = New-Object System.Windows.Forms.CheckBox
$chkDefaultState.Text = "使用 工作目录\\.openclaw-state"
$chkDefaultState.Location = New-Object System.Drawing.Point(190, ($y + 28))
$chkDefaultState.Size = New-Object System.Drawing.Size(300, 24)
$chkDefaultState.Checked = $true
$panelConfig.Controls.Add($chkDefaultState)

$y += 58
$panelConfig.Controls.Add((New-Label -Text "飞书 App ID" -X 16 -Y $y -Width 170))
$txtAppId = New-Input -X 190 -Y ($y - 2) -Width 734
$panelConfig.Controls.Add($txtAppId)

$y += 44
$panelConfig.Controls.Add((New-Label -Text "飞书 App Secret" -X 16 -Y $y -Width 170))
$txtAppSecret = New-Input -X 190 -Y ($y - 2) -Width 734
$txtAppSecret.UseSystemPasswordChar = $true
$panelConfig.Controls.Add($txtAppSecret)

$y += 44
$chkModelReady = New-Object System.Windows.Forms.CheckBox
$chkModelReady.Text = "我已经准备好飞书 App ID/Secret, 并在 OpenClaw 里完成模型接入和默认模型设置"
$chkModelReady.Location = New-Object System.Drawing.Point(190, $y)
$chkModelReady.Size = New-Object System.Drawing.Size(470, 24)
$panelConfig.Controls.Add($chkModelReady)

$hintModelReady = New-Object System.Windows.Forms.Label
$hintModelReady.Text = "模型不会自动配置; 不会飞书应用配置时请先看官方文档"
$hintModelReady.Location = New-Object System.Drawing.Point(680, ($y + 2))
$hintModelReady.Size = New-Object System.Drawing.Size(244, 20)
$hintModelReady.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 8)
$hintModelReady.ForeColor = [System.Drawing.Color]::FromArgb(110, 120, 140)
$panelConfig.Controls.Add($hintModelReady)

$y += 44
$panelConfig.Controls.Add((New-Label -Text "硬锁账号" -X 16 -Y $y -Width 170))
$txtBotUser = New-Input -X 190 -Y ($y - 2) -Width 320
$txtBotUser.Text = "openclaw_bot"
$panelConfig.Controls.Add($txtBotUser)

$panelConfig.Controls.Add((New-Label -Text "硬锁密码(可选)" -X 530 -Y $y -Width 170))
$txtBotPassword = New-Input -X 680 -Y ($y - 2) -Width 244
$txtBotPassword.UseSystemPasswordChar = $true
$panelConfig.Controls.Add($txtBotPassword)

$y += 44
$chkHardlock = New-Object System.Windows.Forms.CheckBox
$chkHardlock.Text = "启用 Windows ACL 硬锁 (推荐)"
$chkHardlock.Location = New-Object System.Drawing.Point(190, $y)
$chkHardlock.Size = New-Object System.Drawing.Size(280, 24)
$chkHardlock.Checked = $true
$panelConfig.Controls.Add($chkHardlock)

$chkSkipSiblingDeny = New-Object System.Windows.Forms.CheckBox
$chkSkipSiblingDeny.Text = "跳过同级目录限制 (隔离更弱)"
$chkSkipSiblingDeny.Location = New-Object System.Drawing.Point(500, $y)
$chkSkipSiblingDeny.Size = New-Object System.Drawing.Size(260, 24)
$panelConfig.Controls.Add($chkSkipSiblingDeny)

$panelOps = New-Object System.Windows.Forms.Panel
$panelOps.Location = New-Object System.Drawing.Point(20, 596)
$panelOps.Size = New-Object System.Drawing.Size(944, 122)
$panelOps.BackColor = [System.Drawing.Color]::White
$panelOps.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($panelOps)

$opsTitle = New-Object System.Windows.Forms.Label
$opsTitle.Text = "快捷操作"
$opsTitle.Location = New-Object System.Drawing.Point(16, 10)
$opsTitle.Size = New-Object System.Drawing.Size(180, 24)
$opsTitle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$opsTitle.ForeColor = [System.Drawing.Color]::FromArgb(30, 45, 74)
$panelOps.Controls.Add($opsTitle)

$btnRun = New-Button -Text "一键安装并启动" -X 16 -Y 44 -Width 200 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(33, 150, 83))
$panelOps.Controls.Add($btnRun)

$btnStartGateway = New-Button -Text "启动网关" -X 228 -Y 44 -Width 150 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(30, 136, 229))
$panelOps.Controls.Add($btnStartGateway)

$panelOps.Controls.Add((New-Label -Text "飞书配对码" -X 390 -Y 52 -Width 90))
$txtPairCode = New-Input -X 476 -Y 48 -Width 190
$panelOps.Controls.Add($txtPairCode)

$btnApprovePairing = New-Button -Text "批准配对" -X 676 -Y 44 -Width 130 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(123, 31, 162))
$panelOps.Controls.Add($btnApprovePairing)

$btnClose = New-Button -Text "关闭" -X 816 -Y 44 -Width 110 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(90, 103, 121))
$panelOps.Controls.Add($btnClose)

$panelLog = New-Object System.Windows.Forms.Panel
$panelLog.Location = New-Object System.Drawing.Point(20, 732)
$panelLog.Size = New-Object System.Drawing.Size(944, 174)
$panelLog.BackColor = [System.Drawing.Color]::White
$panelLog.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($panelLog)

$logTitle = New-Object System.Windows.Forms.Label
$logTitle.Text = "执行日志"
$logTitle.Location = New-Object System.Drawing.Point(16, 10)
$logTitle.Size = New-Object System.Drawing.Size(180, 24)
$logTitle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$logTitle.ForeColor = [System.Drawing.Color]::FromArgb(30, 45, 74)
$panelLog.Controls.Add($logTitle)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.WordWrap = $false
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtLog.Location = New-Object System.Drawing.Point(16, 40)
$txtLog.Size = New-Object System.Drawing.Size(910, 118)
$txtLog.Text = "就绪. 请先确认飞书应用和 OpenClaw 模型都已准备好, 再点击 一键安装并启动."
$panelLog.Controls.Add($txtLog)

function Update-StateTextBox {
    if ($chkDefaultState.Checked) {
        $txtState.Text = Join-Path $txtWorkspace.Text ".openclaw-state"
        $txtState.Enabled = $false
        $btnState.Enabled = $false
    } else {
        $txtState.Enabled = $true
        $btnState.Enabled = $true
    }
}

Update-StateTextBox

$chkDefaultState.Add_CheckedChanged({
    Update-StateTextBox
})

$txtWorkspace.Add_TextChanged({
    if ($chkDefaultState.Checked) {
        $txtState.Text = Join-Path $txtWorkspace.Text ".openclaw-state"
    }
})

$btnWorkspace.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "选择工作目录"
    $dialog.SelectedPath = $txtWorkspace.Text
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtWorkspace.Text = $dialog.SelectedPath
    }
})

$btnState.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "选择状态目录"
    $dialog.SelectedPath = $txtState.Text
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtState.Text = $dialog.SelectedPath
    }
})

$btnClose.Add_Click({
    $form.Close()
})

$btnOpenModelGuide.Add_Click({
    if (-not (Test-Path -LiteralPath $modelGuidePath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "未找到教程文件: $modelGuidePath",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    try {
        Start-Process $modelGuidePath | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "打开教程失败: $($_.Exception.Message)",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$btnStartGateway.Add_Click({
    if (-not (Test-Path -LiteralPath $startGatewayScript)) {
        [System.Windows.Forms.MessageBox]::Show(
            "缺少脚本: $startGatewayScript",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return
    }

    try {
        $out = (& $startGatewayScript 2>&1 | Out-String)
        if ([string]::IsNullOrWhiteSpace($out)) {
            $out = "网关启动命令执行完成."
        }
        Append-Log -LogBox $txtLog -Message "== 启动网关 ==`r`n$out"
        [System.Windows.Forms.MessageBox]::Show(
            "已请求启动网关.",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "启动网关失败: $($_.Exception.Message)",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$btnApprovePairing.Add_Click({
    $code = $txtPairCode.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($code)) {
        [System.Windows.Forms.MessageBox]::Show(
            "请先输入飞书配对码.",
            "参数校验",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }
    if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) {
        [System.Windows.Forms.MessageBox]::Show(
            "未找到 openclaw 命令, 请先执行安装.",
            "参数校验",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    try {
        $out = (& openclaw pairing approve feishu $code 2>&1 | Out-String)
        if ([string]::IsNullOrWhiteSpace($out)) {
            $out = "配对批准命令执行完成."
        }
        Append-Log -LogBox $txtLog -Message "== 批准配对 ==`r`n$out"
        [System.Windows.Forms.MessageBox]::Show(
            "已发送配对批准命令.",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "配对批准失败: $($_.Exception.Message)",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$btnRun.Add_Click({
    $txtLog.Text = ""

    if ([string]::IsNullOrWhiteSpace($txtAppId.Text)) {
        [System.Windows.Forms.MessageBox]::Show(
            "请填写飞书 App ID.",
            "参数校验",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }
    if ([string]::IsNullOrWhiteSpace($txtAppSecret.Text)) {
        [System.Windows.Forms.MessageBox]::Show(
            "请填写飞书 App Secret.",
            "参数校验",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }
    if (-not $chkModelReady.Checked) {
        [System.Windows.Forms.MessageBox]::Show(
            "请先准备好飞书 App ID/App Secret, 并在 OpenClaw 里完成模型接入和默认模型设置, 再回来执行安装.`r`n`r`n你可以点击顶部的""打开模型教程"".",
            "先完成前置准备",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }
    if ([string]::IsNullOrWhiteSpace($txtWorkspace.Text)) {
        [System.Windows.Forms.MessageBox]::Show(
            "请填写工作目录.",
            "参数校验",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }
    if ([string]::IsNullOrWhiteSpace($txtState.Text)) {
        [System.Windows.Forms.MessageBox]::Show(
            "请填写状态目录.",
            "参数校验",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $btnRun.Enabled = $false
    $btnClose.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor

    $arguments = @{
        FeishuAppId = $txtAppId.Text.Trim()
        FeishuAppSecret = $txtAppSecret.Text.Trim()
        WorkspacePath = $txtWorkspace.Text.Trim()
        StatePath = $txtState.Text.Trim()
        BotUser = $txtBotUser.Text.Trim()
        ApplyHardlock = $chkHardlock.Checked
        DisableTelegram = $true
    }
    if (-not [string]::IsNullOrWhiteSpace($txtBotPassword.Text)) {
        $arguments.BotPassword = $txtBotPassword.Text
    }
    if ($chkSkipSiblingDeny.Checked) {
        $arguments.SkipSiblingDeny = $true
    }

    try {
        $allOutput = (& $bootstrapScript @arguments 2>&1 3>&1 4>&1 5>&1 6>&1 | Out-String)
        if (Test-Path -LiteralPath $startGatewayScript) {
            $startOut = (& $startGatewayScript 2>&1 | Out-String)
            if (-not [string]::IsNullOrWhiteSpace($startOut)) {
                $allOutput += "`r`n`r`n== 启动网关 ==`r`n$startOut"
            }
        }
        if ([string]::IsNullOrWhiteSpace($allOutput)) {
            $allOutput = "安装完成, 未返回额外日志."
        }
        $txtLog.Text = $allOutput
        [System.Windows.Forms.MessageBox]::Show(
            "安装完成, 已尝试启动网关. 下一步: 去飞书里拿配对码, 回到这里填入 飞书配对码, 然后点击 批准配对.",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    } catch {
        $txtLog.Text = "安装失败: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "安装失败, 请查看日志.",
            "OpenClaw 一键安装",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    } finally {
        $btnRun.Enabled = $true
        $btnClose.Enabled = $true
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
    }
})

if ($isScreenshotMode) {
    Set-ScreenshotState -Variant $ScreenshotVariant
    Save-FormScreenshot -TargetForm $form -Path $ScreenshotPath
    Write-Host "Screenshot saved: $([System.IO.Path]::GetFullPath($ScreenshotPath))"
    exit 0
}

[void]$form.ShowDialog()


