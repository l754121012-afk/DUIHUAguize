# Changelog

## 1.0.3 - 2026-09-27

- 禁止用户可见文本出现工具调用标记、参数块、原始调用包装或内部通道标记。
- 工具调用只走工具通道；可见回复只保留结果、证据和下一步。

## 1.0.2 - 2026-09-27

- Task Preflight 明确要求预计输入、输出、缓存命中与高峰期/非高峰期成本区间。
- 完成报告、交接和模板增加实际 token/成本验证、数据来源、偏差与原因。
- 所有主开发模板加入成本闭环要求，避免只估不算。

## 1.0.1 - 2026-09-25

- 增加 Git 远端推送失败的代理诊断流程。
- 增加 Windows 本地代理端口和进程检查规则。
- 记录当前环境的 Vortex helper 代理优先候选 `127.0.0.1:7897`。
- 推送成功后增加 `ls-remote` 核验要求。

## 1.0.0 - 2026-09-25

- 建立 Core、Profiles、Adapters、Templates 四层结构。
- 加入 Task Preflight、同类问题排查、上下文治理、循环熔断和交接规范。
- 加入 DeepSeek/CC Switch、视觉双线程、Godot、Windows/PowerShell、Codex App、Artifacts 和 Git adapter。
- 加入跨平台安装、doctor 和卸载脚本。
