# 固定对话模板

## 使用原则

- 每个新任务先用“主开发会话标准开场”。
- 所有主开发任务默认先执行 Task Preflight；S/M 直接做，L 切分，XL 停下确认。
- 精确成本和模型价格由 provider adapter 提供；视觉协议本身不内嵌价格表。
- 每个任务都必须有成本闭环：开始时给预计 token/成本，完成时给实际消耗、数据来源、偏差与原因；没有精确 usage 时明确标注估算口径。
- 模板只用于开场和跨边界交接。任务开始后继续就事论事，只在压缩、独立审图、最终验收或新版本时推荐下一模板。
- 没有图片的任务不要创建视觉会话。
- 图片进入主会话之前先保存到磁盘，只传路径。
- 固定前缀、交接文件和阅读顺序在同一任务内不要改动。
- 视觉会话不执行完整工作量预检，但必须写清图片数量、detail、最大查看轮数和 token 风险。

## 1. 主开发会话标准开场

```text
使用 $dual-thread-vision-workflow。

这是《<项目名>》的主开发会话，只处理文本、代码、命令和仓库修改。
项目根：<项目根目录>

模板只用于本次开场和后续任务边界。当前交付开始后，我会直接给出需求、反馈和修正，不重复套模板。
只有出现独立视觉判断、上下文压缩、最终验收或新版本时，才用一行推荐下一段对话模板。

开始实现前先输出一个简短的 Task Preflight，不要先改代码：
- 目标
- 工作量：S/M/L/XL
- 预计输入、输出和缓存命中
- 预计成本：非高峰 $<范围>，高峰 $<范围>
- 执行步骤
- 最可能导致返工或循环的风险
- 停损线
- 决策：直接执行 / 先切分 / 需要我确认

S/M 在预检后直接执行；L 先切分，只做第一片；XL 停止实现，先给我拆分方案。
预检控制在 8 行以内，不能变成长篇方案。

先读：
1. AGENTS.md
2. outputs/SESSION-HANDOFF.md 的当前交接和 ## 下一步
3. outputs/VISION-FACTS.md

本次只交付：<一个可验收结果>
完成条件：<必须通过的 smoke、测试或可观察结果>

硬规则：
- 不调用 view_image，不读取截图、原图或大 PNG。
- 遇到普通识图问题时，优先执行 invoke_vision_preprocess.ps1，只读取返回 JSON。
- 遇到主观视觉判断时，只创建视觉任务单，等我另开视觉会话。
- 坐标和像素差先用 crop_image.ps1 或 pixel_diff.ps1 在本地处理。
- 不中途切换模型或供应商，不在同一会话连续做多个交付。

收尾：
- 回填 outputs/SESSION-HANDOFF.md。
- 把稳定视觉事实合并到 outputs/VISION-FACTS.md。
- 报告改动文件、参数前后值、验证命令、实际结果，以及实际 token/成本验证与预检偏差。
```

## 2. 主开发会话简版开场

```text
使用 $dual-thread-vision-workflow。继续《<项目名>》，项目根：<项目根目录>。
开始前先给 8 行内 Task Preflight：工作量、token 区间、成本区间、缓存预期、步骤、循环风险、停损线。
如果为 L 先切分；XL 先停下等我确认。
先读 AGENTS.md、outputs/SESSION-HANDOFF.md 当前交接和 ## 下一步、outputs/VISION-FACTS.md。
本次只做：<一个目标>。
主会话零图片；普通识图调用 invoke_vision_preprocess.ps1；主观审图另开会话。
完成后回填 SESSION-HANDOFF 和 VISION-FACTS，并列出验证结果。
完成后同时报告实际 token/成本、数据来源与预检偏差。
```

## 3. 普通识图，主会话自动调用

```text
按双会话视觉工作流处理这个视觉问题，主会话不要读取图片。

先给一行视觉预检：图片数量、detail、预计单图 token、预计成本、最大模型调用次数。

项目根：<项目根目录>
图片：<图片绝对路径>
模式：<general|layout|ocr|quality|pixel-diff>
问题：<一个明确问题>

先执行：
& "$env:USERPROFILE\.codex\skills\dual-thread-vision-workflow\scripts\invoke_vision_preprocess.ps1" `
  -ProjectRoot "<项目根目录>" `
  -ImagePath "<图片绝对路径>" `
  -Mode <模式> `
  -Question "<问题>"

只读取返回的 RESULT_PATH JSON。
如果 REUSED_CACHE=1，不再调用模型。
坐标或像素精度不足时，先用 crop_image.ps1 或 pixel_diff.ps1，不靠猜测。
```

## 4. 独立视觉会话开场

```text
使用 $dual-thread-vision-workflow。

这是视觉审图会话，不修改工程，不写产品代码，不做仓库搜索。
只读取这个视觉任务单：
<work/vision-requests/xxx.md 的绝对路径>

先给一行视觉预检：图片数量、detail、最大查看轮数、预计 token 与成本风险。

只允许查看任务单中的 preview_path。最多两轮：
1. 按任务单回答并覆盖 result_path 对应 JSON。
2. 只有结果明确缺少一个局部裁切时才再看一次。

坐标必须换算回原图像素，格式为 [x, y, width, height]。
无法确认的字段写 null，并记录到 uncertain。
完成后只回复：视觉结果已到 <result_path>
```

## 5. 回到主会话接收视觉结果

```text
视觉结果已到：
<work/vision-results/xxx.json 的绝对路径>

只读取该 JSON，不要打开图片。
把稳定事实合并到 outputs/VISION-FACTS.md，然后继续当前里程碑。
不要复述整段视觉推理，只保留可复用事实和仍不确定项。
```

## 6. 项目首次初始化

```text
使用 $dual-thread-vision-workflow 初始化项目。

先给一行预检：工作量 S、预计创建或更新 4-5 个路径、无模型识图、预计成本 < $0.001。

项目根：<项目根目录>
执行：
& "$env:USERPROFILE\.codex\skills\dual-thread-vision-workflow\scripts\init_project_workflow.ps1" -ProjectRoot "<项目根目录>"

只创建或更新：
- work/vision-requests/
- work/vision-inbox/
- work/vision-results/
- outputs/VISION-FACTS.md
- AGENTS.md 中双会话视觉工作流标记块

不要改动其它项目文件。完成后列出所有变更路径。
```

## 7. 上下文过长或发生压缩

```text
停止继续编码。当前会话上下文已经过长或发生过压缩。

按 AGENTS.md 和 outputs/SESSION-HANDOFF.md 执行收尾：
1. 记录当前目标、完成项、未完成项。
2. 记录改动文件、参数前后值、未提交文件。
3. 记录已运行验证及结果，未运行的写清原因。
4. 更新 ## 下一步，并给出一个可直接粘贴的新会话口令。

不要继续读大文档、大图或原图，不要再开始新的实现。
```

## 8. Bug 修复任务

```text
使用 $dual-thread-vision-workflow。

先输出 8 行内 Task Preflight：工作量、token 区间、成本区间、缓存预期、执行步骤、循环风险、停损线。
如果为 L 先切分；XL 先停下等我确认。

主会话只读文本、代码和日志，不读取截图。
项目根：<项目根目录>

现象：<实际现象>
复现：<复现步骤>
预期：<正确结果>
影响范围：<单文件|模块|全工程>
必须验证：<命令、smoke 或步骤>

先定位根因，再最小范围修改。不要顺手重构无关模块。
需要看图时先调用 invoke_vision_preprocess.ps1；主观判断才另开视觉会话。
完成后回填 SESSION-HANDOFF 和 VISION-FACTS，并给出验证证据。
完成后同时报告实际 token/成本、数据来源与预检偏差。
```

## 9. UI 或视觉验收任务

```text
使用 $dual-thread-vision-workflow。

先输出 8 行内 Task Preflight：工作量、token 区间、成本区间、缓存预期、执行步骤、循环风险、停损线。
如果为 L 先切分；XL 先停下等我确认。

这是视觉验收任务，主会话不读取图片。
项目根：<项目根目录>
检查对象：<截图或场景>
检查项：<对齐、尺寸、颜色、文字、遮挡、层级、间距>

先运行本地尺寸、颜色采样、裁剪和像素差检查。
需要语义判断时执行 invoke_vision_preprocess.ps1，一次只问一个问题。
输出分为：
1. 已确认事实，附 result_id。
2. 明确不通过项，附坐标或尺寸证据。
3. 不确定项，说明下一次最小检查。

不要凭感觉直接改布局。先给证据，再改参数。
```

## 10. 最终验收任务

```text
使用 $dual-thread-vision-workflow，只做验收，不新增功能。

先输出 8 行内 Task Preflight：工作量、token 区间、成本区间、缓存预期、执行步骤、循环风险、停损线。
如果为 L 先切分；XL 先停下等我确认。

项目根：<项目根目录>
验收目标：<本次版本或里程碑>
必须运行：<命令、smoke、试玩步骤>
视觉检查：<需要的截图或视觉事实>

输出固定为：
1. PASS 或 FAIL。
2. 每项验收的证据。
3. 失败项的最小复现。
4. 是否更新 SESSION-HANDOFF。
5. 建议下一步，但不直接实施。
6. 报告实际 token/成本、数据来源与预检偏差。

主会话零图片。视觉判断只读取 VISION-FACTS 或调用视觉预处理脚本。
```

## 11. 新版本继续开发

```text
使用 $dual-thread-vision-workflow。继续《<项目名>》，项目根：<项目根目录>。

先输出 8 行内 Task Preflight：工作量、token 区间、成本区间、缓存预期、执行步骤、循环风险、停损线。
如果为 L 先切分；XL 先停下等我确认。

先只读：
1. AGENTS.md
2. outputs/SESSION-HANDOFF.md 当前交接
3. ## 下一步
4. outputs/VISION-FACTS.md

本次目标严格限定为：
<一个新版本目标>

不要重新讨论已确认方案，不要重做已完成项。
先核对 git status 和未提交文件，再开始实现。
完成后回填交接文件并提交验证证据。
同时报告实际 token/成本、数据来源与预检偏差。
```

## 12. Provider 路由维护

DeepSeek、CC Switch、价格和模型目录维护已拆到：

`adapters/model-routing/deepseek-cc-switch/`

视觉会话只负责图片与视觉结果，不直接改模型配置。

## 13. 图片很多时的批处理

```text
使用 $dual-thread-vision-workflow 批量处理图片，但主会话零图片。

先输出批处理预检：图片数量、预计模型调用数、缓存可复用数、预计 input/output token、预计成本、停止条件。

项目根：<项目根目录>
图片目录：<目录>
每个图片只回答：<同一个明确问题>

对每张图：
1. 生成 SHA256 并检查已有结果。
2. 命中缓存时跳过模型调用。
3. 未命中时调用 invoke_vision_preprocess.ps1。
4. 只把 JSON 路径和稳定事实带回主会话。

先列出批次计划，再执行；不要一次性把多张图载入上下文。
```
