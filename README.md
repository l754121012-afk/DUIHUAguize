# agent-collaboration-protocol

可跨项目、跨设备、跨新旧对话复用的 Agent 协作协议。

仓库采用四层结构：

- `core/`：永远加载的通用交流与执行规则。
- `profiles/`：用户个人偏好，例如报告语言、预算意识和自主执行方式。
- `adapters/`：按任务、工具或环境触发的补充包。
- `templates/`：项目级规则和交接模板。

## 最快使用

1. 运行 `install/install.ps1` 或 `install/install.sh`。
2. 在新项目中引用 `templates/project-AGENTS.md`。
3. 新任务使用：

```text
使用 $agent-collaboration-protocol。
开始前先根据任务规模输出 Task Preflight。
```

需要视觉、DeepSeek/CC Switch、Godot、PowerShell 或 Codex App 能力时，由 Core 按触发条件加载对应 adapter。

## 隐私

本仓库只保存通用协议和适配器，不保存项目记忆、rollout 摘要、API 密钥、私有路径或具体项目历史。

详见 `SECURITY.md`。

