# 提交上游 PR 后，怎么收到通知

## 你会在哪些情况下收到通知

只要这个 PR 是你创建的，通常出现下面这些情况时，GitHub 都会通知你：

1. 有人评论你的 PR
2. 有人发起代码审查
3. 有人请求你修改
4. PR 被关闭
5. PR 被合并
6. CI 失败或通过

## 最稳的设置方法

建议你把下面 4 个地方都打开：

### 1. GitHub 站内通知

右上角 `Notifications` 会收到：

- 评论
- review
- CI 状态变化
- merge / close

### 2. 邮件通知

GitHub Settings -> Notifications

建议至少打开：

- `Participating and @mentions`
- `Watching`
- `Pull requests`
- `Email`

这样即使你不盯着网页，也能收到邮件。

### 3. 仓库 Watch

在 `openclaw/openclaw` 仓库右上角点击 `Watch`，推荐选：

- `Custom`
- 勾选 `Pull requests`

这样即使不是你发起的讨论，你也更容易看到这个仓库的 PR 动静。

### 4. 手机推送

如果你装了 GitHub App，可以在 App 里把通知打开。

这样官方一旦有 review、comment、close、merge，你会更快看到。

## 提交后你还应该做什么

1. 打开你自己的 PR 页面
2. 点击右侧或顶部的 `Subscribe`
3. 确保自己没有误点成 `Unsubscribe`

如果你是 PR 作者，通常默认会订阅，但最好自己确认一遍。

## 关于“官方是不是 AI 审核”

从 OpenClaw 当前公开的贡献文档看，不能把它理解成“纯 AI 自动审核”。

更合理的判断是：

1. 可能有 CI、模板检查、机器人参与
2. 但是否接受、是否合并，主要还是维护者决定

所以最有效的做法不是赌“AI 会不会自动过”，而是：

1. PR 范围小
2. 价值明确
3. 风险低
4. 回滚简单
5. 局限性写清楚

## 这次我已经替你做了什么

我已经把 PR 文案加强成更容易被接受的版本，重点强调了：

1. 这是 docs-first、小范围、低风险改动
2. 它填补了 Windows 原生用户的真实文档空白
3. 它不会动默认行为
4. 它不会错误宣称“等价于 Docker sandbox”

你直接用这些文件就可以：

- `upstream-pr/PR_TITLE.txt`
- `upstream-pr/PR_BODY.md`
- `upstream-pr/FILE_PLAN.md`
- `upstream-pr/docs/gateway/windows-no-docker-hardening.md`
