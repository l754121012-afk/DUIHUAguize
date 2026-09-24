# 双会话视觉协同协议

## 目录约定

```text
work/
  vision-requests/
  vision-inbox/
  vision-results/
outputs/
  VISION-FACTS.md
  SESSION-HANDOFF.md
```

原图不得进入主会话。

## 流程

1. 主会话发现视觉不确定项。
2. 普通识图直接运行预处理脚本。
3. 主观审图创建请求文件，由独立视觉会话处理。
4. 视觉会话只写 `work/vision-results/*.json`。
5. 主会话只读取结果 JSON，并把稳定事实合并到 `VISION-FACTS.md`。

## 请求文件

```markdown
# Visual Request
- request_id:
- project_root:
- mode: layout
- image_path:
- preview_path:
- image_sha256:
- image_dimensions:
- result_path:

## Question
<one question>
```

## 结果 JSON

```json
{
  "request_id": "",
  "status": "done",
  "summary": "",
  "facts": [],
  "observations": [],
  "uncertain": [],
  "passes": 1
}
```

坐标统一为原图像素 `[x, y, width, height]`。

## 缓存

- 固定读取顺序和文件格式。
- 相同 `image_sha256 + mode + question` 复用结果。
- 跨天后不要假设缓存一定命中。

