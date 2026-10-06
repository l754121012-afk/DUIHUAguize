# Task Preflight

Task Preflight is a short decision tool, not a long design document.

## Required fields

```text
- 目标
- 工作量：S | M | L | XL
- 适配器：Core + <视觉 | DeepSeek | Godot | Windows | Codex App | Artifacts | Git>
- 预计消耗与成本：输入 / 输出 / 缓存命中（如可估）；非高峰与高峰价格区间
- 执行步骤
- 同类排查：范围 | 代表样本 | 本轮必须验证的同类项
- 主要风险
- 停损线
- 决策：直接执行 | 先切分 | 需要用户确认
```

Keep the normal form within 8 lines. XL tasks may use up to 12 lines.

Every task must also carry a completion counterpart:

```text
- 消耗验证：实际输入 / 输出 / 缓存命中 / 成本 | 数据来源 | 对预检的偏差 | 偏差原因与下次修正
```

If exact usage is unavailable, state the estimation basis explicitly; never silently omit the
expected or actual cost check.

## Carry-forward rule

If the previous response identified a possible same-class issue, that issue is a required item in the next Preflight unless the user explicitly deferred it.

## Workload

| Level | Typical scope | Strategy |
|---|---|---|
| S | one file or one command | direct |
| M | 3-5 files, one module, one acceptance target | one deliverable |
| L | cross-module, several tests, visual iteration | split into 2-3 deliverables |
| XL | several subsystems or unresolved architecture | stop and split before coding |

## Budget

Use provider adapters for model-specific prices. The Core gives relative ranges or an unknown status when no provider adapter is loaded.

## Decision gate

- S/M: execute after the Preflight.
- L: show the split, then execute only the first slice.
- XL: do not implement until scope is confirmed.
