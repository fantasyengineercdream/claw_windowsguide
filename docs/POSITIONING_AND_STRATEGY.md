# Claw Windows Positioning And Strategy

## One Sentence

Claw Windows is a Feishu-first, no-WSL, no-Docker OpenClaw launcher for non-technical Windows users who need fast setup and safer local file boundaries.

## Why This Exists

- Many Windows users fail on WSL or Docker installation.
- Many beginners want local file automation without learning terminal workflows.
- Teams in Chinese-speaking contexts often prefer Feishu over Telegram.

## Core Difference vs "Generic OpenClaw Wrapper"

- Feishu-first UX, not Telegram-first onboarding.
- Native Windows local-file workflow (no virtual Linux filesystem required).
- Optional hardlock boundary (low-privilege user + NTFS ACL) as a practical safety layer.
- GUI-first operation: setup, gateway start, pairing approval in one window.

## Target Users

- Student / creator / office users on Windows.
- Non-technical users who need "double-click then use."
- Small teams that collaborate through Feishu.

## Product Pillars

1. KISS onboarding
- One installer entry (`install.cmd`).
- Required input only: workspace + Feishu credentials.

2. Trust and safety
- Explain what hardlock protects and what it does not.
- Provide visible doctor checks (`doctor-openclaw-feishu.ps1`).

3. Local productivity
- Work with native Windows files directly.
- Avoid WSL path confusion for beginner users.

## Product Direction (Next 30-60 Days)

1. Setup quality
- Add preflight checks and clearer error messages for missing Node/npm/openclaw.
- Add optional proxy input in GUI for enterprise networks.

2. Beginner UX
- Add "Quick Diagnostics" panel in GUI.
- Add "Copy support bundle" button (logs + config summary, no secrets).

3. Feishu operations
- Add guided pairing tips in GUI.
- Add one-click "test message" helper after pairing.

4. Adoption
- Publish short tutorial videos.
- Publish troubleshooting KB for top 10 errors.

## What Not To Claim

- Do not claim kernel/container-level isolation.
- Do not claim full-disk sandboxing.
- Do not claim network egress isolation.

## Value Proposition Template

Chinese:
- 不想折腾 WSL 和 Docker？直接在 Windows 本机一键部署 OpenClaw，飞书开箱即用，并提供可选 ACL 安全边界。

English:
- Skip WSL and Docker complexity. Deploy OpenClaw directly on native Windows with Feishu-first onboarding and an optional ACL hardlock boundary.
