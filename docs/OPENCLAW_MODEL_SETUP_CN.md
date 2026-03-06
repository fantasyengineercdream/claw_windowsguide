# OpenClaw 模型准备教程

这个安装器只负责两件事:

1. 在 Windows 上安装和配置 OpenClaw
2. 把飞书通道接进来

它不负责替你完成模型接入, 也不负责替你选默认模型。

所以正确顺序是:

1. 先把 OpenClaw 里的模型跑通
2. 再运行这个飞书安装器

## 你需要先完成什么

开始这个安装器前, 请先确认:

1. 你已经在 OpenClaw 里完成模型接入
2. 你已经在 OpenClaw 里选好了默认模型

## 最简单的做法

在 PowerShell 里运行:

```powershell
openclaw configure --section model
```

这个步骤的目标不是“填某个固定 API Key”, 而是先让 OpenClaw 知道:

1. 你要用哪个模型提供商
2. 你要用哪个账号或授权方式
3. 默认跑哪个模型

## 完成后怎么自检

先看默认模型:

```powershell
openclaw config get agents.defaults.model.primary
```

如果这里返回了一个模型 ID, 说明默认模型已经写入。

再看当前模型状态:

```powershell
openclaw models status --plain
```

如果这里能看到当前默认模型, 就说明模型链路基本已经打通。

## 常见情况

### 情况 1: 你用 Codex / OAuth

这种情况通常不是在这个安装器里填 API Key。

更常见的流程是:

1. 先在 OpenClaw 的模型配置里完成登录或授权
2. 再把默认模型设好
3. 最后回来运行飞书安装器

### 情况 2: 你用 API 模式

这种情况通常是:

1. 先在 OpenClaw 的模型配置里填好对应 provider 的 API 凭证
2. 再设默认模型
3. 最后回来运行飞书安装器

## 只想快速确认, 不想研究概念

你可以直接按下面顺序做:

```powershell
openclaw configure --section model
openclaw config get agents.defaults.model.primary
openclaw models status --plain
```

如果第二条和第三条都能返回正常结果, 就可以回来运行 `install.cmd` 了。
