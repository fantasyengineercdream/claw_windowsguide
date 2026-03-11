# OpenClaw Windows 一键部署（飞书版）

给 Windows 用户准备的 OpenClaw 安装包。

这套方案的特点：

- 只做 Windows
- 默认只接飞书
- 不依赖 WSL
- 不依赖 Docker
- 通过 OpenClaw 的 Feishu channel 把飞书接进来

重要：

- 飞书应用本身，仍然要先按飞书官方文档完成创建和基础配置
- 本项目负责的是：把你已经准备好的飞书应用接到 OpenClaw

![OpenClaw 安装器截图](assets/gui/openclaw-easy-gui.png)

## 先看这一段

如果你只是想装好它，不想研究代码，按这个顺序做：

1. 先按飞书官方文档，在飞书开放平台创建应用并完成基础配置
2. 拿到：
   - `App ID`
   - `App Secret`
3. 再把 OpenClaw 的模型跑通
   参考：[docs/OPENCLAW_MODEL_SETUP_CN.md](docs/OPENCLAW_MODEL_SETUP_CN.md)
4. 下载本项目 ZIP，解压后双击 `install.cmd`
5. 在安装器里填：
   - `工作目录`
   - `飞书 App ID`
   - `飞书 App Secret`
6. 点击 `一键安装并启动`
7. 去飞书里拿配对码
8. 回到安装器里点击 `批准配对`

做完这 8 步，才算完成。

飞书官方文档：

- <https://www.feishu.cn/content/article/7613711414611463386>

## 你需要提前准备什么

开始前，请先确认你已经有下面 2 样东西：

1. 一个已经按飞书官方文档准备好的飞书应用
2. 一个已经能用的 OpenClaw 模型配置

如果这两样没有准备好，不要先点安装器。

## 这套方案到底是什么

这是：

- OpenClaw Windows 本机安装方案
- 飞书应用 + OpenClaw 接入方案
- 通过 `appId/appSecret + pairing` 完成接入

这不是：

- 飞书官方文档的替代品
- 飞书应用市场上架教程
- “填完就自动拥有模型能力”的全自动方案

## 最短安装步骤

### 第 1 步：先准备飞书应用

先按飞书官方文档，在飞书开放平台把应用创建好，并完成基础配置。

官方文档：

- <https://www.feishu.cn/content/article/7613711414611463386>

然后拿到：

- `App ID`
- `App Secret`

如果飞书应用这一步没准备好，不要先开安装器。

### 第 2 步：再把模型跑通

先确认 OpenClaw 已经能正常使用模型。

如果这一步没做，后面的飞书接入没有意义。

参考：

- [docs/OPENCLAW_MODEL_SETUP_CN.md](docs/OPENCLAW_MODEL_SETUP_CN.md)

### 第 3 步：下载并解压

下载 ZIP：

- `Code -> Download ZIP`

也可以直接打开：

- `https://github.com/fantasyengineercdream/claw_windowsguide/archive/refs/heads/main.zip`

下载后解压。

### 第 4 步：双击安装器

双击：

- `install.cmd`

默认会打开中文 GUI。

### 第 5 步：填写 3 个信息

安装器里主要填写：

1. `工作目录`
2. `飞书 App ID`
3. `飞书 App Secret`

然后点击：

- `一键安装并启动`

### 第 6 步：在飞书里完成配对

安装器启动后，你还需要：

1. 去飞书里拿到配对码
2. 回到安装器里填入配对码
3. 点击 `批准配对`

只有这一步完成后，飞书里才能真正开始聊天。

## 适合谁

这套方案适合：

- 想在 Windows 本机跑 OpenClaw 的用户
- 不想折腾 WSL / Docker 的用户
- 想默认用飞书，不想先配 Telegram 的用户
- 想用中文安装器的用户

## 不适合谁

如果你要的是下面这些场景，这个项目不适合：

- 你想做飞书官方插件开发
- 你想走飞书官方插件文章里的完整回调/发布路线
- 你想要 Mac 版
- 你想要 Docker / WSL 隔离方案

## 安装器会帮你做什么

安装器会自动处理这些事情：

- 检查 Node.js
- 缺少时尝试安装 Node.js
- 检查 `openclaw`
- 缺少时尝试全局安装 `openclaw`
- 把飞书配置写入 `~/.openclaw/openclaw.json`
- 默认关闭 Telegram
- 提供启动网关和批准配对按钮

## 安装器不会帮你做什么

安装器不会替你做下面这些事情：

- 不会替代飞书官方文档里的应用创建和基础配置步骤
- 不会替你决定用哪个模型
- 不会替你完成模型接入
- 不会替你跳过配对

## 一句话说明给小白

可以直接把这句话发给别人：

`这是给 Windows 用的 OpenClaw 飞书一键安装包。先按飞书官方文档把应用准备好，再把 OpenClaw 模型配好，然后双击 install.cmd，最后按界面做配对。`

## 常见误解

### 误解 1：双击安装器就能直接聊天

不是。

你还必须先完成：

- 模型配置
- 飞书应用创建
- 飞书配对

### 误解 2：用了这个项目，就不用看飞书官方文档

不是。

飞书应用的创建和基础配置，仍然要按飞书官方文档来做。

本项目解决的是：

- 在 Windows 上把 OpenClaw 接到你已经准备好的飞书应用

### 误解 3：这是完全零配置

不是。

它只是把 Windows 安装、OpenClaw 配置写入、网关启动、配对操作尽量简化了。

## GUI 快速开始

1. 先准备好飞书 `App ID / App Secret`
2. 双击 `install.cmd`
3. 填 `工作目录`
4. 填 `飞书 App ID`
5. 填 `飞书 App Secret`
6. 点 `一键安装并启动`
7. 拿飞书配对码
8. 点 `批准配对`

## 健康检查

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\doctor-openclaw-feishu.ps1
```

实时检查：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\doctor-openclaw-feishu.ps1 -Live
```

## 可选命令行模式

```powershell
.\install.cmd cli `
  -FeishuAppId "cli_xxx" `
  -FeishuAppSecret "xxx" `
  -WorkspacePath "D:\OpenClawWorkspace"
```

## 安全说明

- 这是 Windows 主机侧加固，不是容器级隔离
- 主要边界来自低权限账号和 NTFS ACL
- 如果你直接用日常高权限账号运行，隔离效果会明显变弱

## 相关文档

- [docs/OPENCLAW_MODEL_SETUP_CN.md](docs/OPENCLAW_MODEL_SETUP_CN.md)
- [docs/FEISHU_SECURITY_CHECKLIST.md](docs/FEISHU_SECURITY_CHECKLIST.md)
- [docs/BEGINNER_DELIVERY.md](docs/BEGINNER_DELIVERY.md)
- [docs/PUBLISH_CHECKLIST_CN.md](docs/PUBLISH_CHECKLIST_CN.md)

## 脚本列表

- `install.cmd`：默认 GUI 入口
- `scripts/openclaw-easy-gui.ps1`：图形安装器
- `scripts/bootstrap-openclaw-feishu.ps1`：安装和配置脚本
- `scripts/doctor-openclaw-feishu.ps1`：诊断脚本
- `scripts/start-openclaw-gateway.ps1`：启动网关
- `scripts/stop-openclaw-gateway.ps1`：停止网关

## 许可证

MIT
