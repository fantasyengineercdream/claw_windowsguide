# OpenClaw Windows Easy Deploy (Feishu Only)

中文：这是给 Windows 小白用户的一键部署方案。默认只用飞书，不需要 WSL，不需要 Docker。  
English: A beginner-friendly OpenClaw setup for native Windows. Feishu-only by default. No WSL, no Docker.

![OpenClaw Easy Setup GUI](assets/gui/openclaw-easy-gui.png)

中文：上图为安装器实际截图。  
English: The image above is a real screenshot generated from the installer GUI.

## GUI Quick Start / 图形界面快速开始

1. 双击 `install.cmd`（Double-click `install.cmd`）。
2. 在界面里填写 `Workspace Path`、`Feishu App ID`、`Feishu App Secret`，点击 `Run One-Click Setup`。
3. 点击 `Start Gateway`。
4. 把飞书里拿到的配对码填入 `Feishu Pairing Code`，点击 `Approve Pairing`。

中文：默认流程可全程在 GUI 完成，不需要手打命令。  
English: The default flow can be completed fully in GUI without typing commands.

## Optional CLI Mode / 可选命令行模式

```powershell
.\install.cmd cli `
  -FeishuAppId "cli_xxx" `
  -FeishuAppSecret "xxx" `
  -WorkspacePath "D:\OpenClawWorkspace"
```

Direct script / 直接脚本入口：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap-openclaw-feishu.ps1 `
  -FeishuAppId "cli_xxx" `
  -FeishuAppSecret "xxx" `
  -WorkspacePath "D:\OpenClawWorkspace"
```

## What It Configures / 它会做什么

- Install Node.js LTS if missing (`winget`)
- Install `openclaw` if missing (`npm -g`)
- Write Feishu channel config to `~/.openclaw/openclaw.json`
- Disable Telegram by default
- Optionally apply hardlock (`openclaw_bot` + ACL)

中文补充：
- 缺少 Node.js 时自动安装
- 缺少 openclaw 时自动安装
- 自动写入飞书通道配置
- 默认禁用 Telegram
- 可选应用 ACL 硬锁

## Health Check / 健康检查

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\doctor-openclaw-feishu.ps1
```

Live check (slower) / 实时检查（更慢）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\doctor-openclaw-feishu.ps1 -Live
```

## Security Notes / 安全说明

- This is host hardening on Windows, not container/kernel isolation.
- Boundary comes from low-privilege user + NTFS ACL.
- If OpenClaw runs as your normal account, isolation is weaker.

中文：
- 这是 Windows 主机侧加固，不是容器级隔离。
- 边界依赖低权限账号与 NTFS ACL。
- 若用日常账号运行，隔离效果会变弱。

## Scripts / 脚本列表

- `install.cmd`: GUI entry (`install.cmd cli ...` for CLI)
- `scripts/openclaw-easy-gui.ps1`: GUI installer (includes Start Gateway + Approve Pairing)
- `scripts/bootstrap-openclaw-feishu.ps1`: install + config + optional hardlock
- `scripts/doctor-openclaw-feishu.ps1`: diagnostics
- `scripts/start-openclaw-gateway.ps1`: start gateway in background
- `scripts/stop-openclaw-gateway.ps1`: stop gateway process
- `scripts/apply-openclaw-hardlock-elevated.ps1`: elevated hardlock launcher
- `scripts/setup-openclaw-hardlock.ps1`: hardlock implementation
- `scripts/test-openclaw-hardlock.ps1`: hardlock validation
- `scripts/rollback-openclaw-hardlock.ps1`: rollback changes

## Strategy Docs / 策略文档

- `docs/POSITIONING_AND_STRATEGY.md`: positioning and differentiation
- `docs/LAUNCH_30D.md`: 30-day launch execution checklist
- `docs/MARKETING_COPY_CN.md`: ready-to-post Chinese marketing copy
- `docs/FEISHU_SECURITY_CHECKLIST.md`: secret hygiene, minimum scopes, callback verification

## GUI Screenshot Command / GUI 截图命令

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\openclaw-easy-gui.ps1 -ScreenshotPath .\assets\gui\openclaw-easy-gui.png
```

## Packaging / 打包

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\make-release-zip.ps1
```

## License

MIT
