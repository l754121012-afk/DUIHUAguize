# Global Agent Bootstrap

<!-- agent-collaboration-protocol:start -->
## Agent Collaboration Protocol

- 默认加载 `agent-collaboration-protocol`。
- 中等及以上任务在实现前输出 Task Preflight，必须包含预计 token 与成本区间。
- 完成任务时必须验证并报告实际 token/成本、数据来源、对预检的偏差与原因。
- 上一轮提出的同类问题线索必须进入下一轮 Preflight 和执行验证。
- 先读项目交接、索引和最小必要代码，不默认全仓扫描。
- 先定位根因，再修改，再验证；同一失败原因最多做一次有依据修正。
- 面向用户使用简洁中文汇报，进度更新短而具体。
- 用户可见文本不得包含工具调用标记、参数块或原始命令包装；工具调用只走工具通道。
- 涉及视觉、模型路由、Godot、PowerShell、Codex App 或文档产物时，按 `adapters/registry.md` 加载对应 adapter。
- 密钥、私有记忆、机器路径和项目历史不得写入本协议仓库。
<!-- agent-collaboration-protocol:end -->
