# VISION-FACTS

本文件只保存稳定、可复用、可以被主会话当作事实使用的视觉结论。

## Stable Facts

| Key | Value | Source request | Confidence | Notes |
|---|---|---|---|---|
| example.button.center | [182, 640] | 20260924-213000-a1b2c3d4 | high | 原图像素坐标 |

## Uncertain

| Key | Problem | Next check | Owner |
|---|---|---|---|
| example.text.alignment | 预览图无法确认 1px 偏移 | 裁切原图局部做像素差 | vision |

## Requests

| Request ID | Mode | Summary | Result file |
|---|---|---|---|
| 20260924-213000-a1b2c3d4 | layout | 左按钮中心坐标 | work/vision-results/20260924-213000-a1b2c3d4.json |

## Rules

- 主会话只读取 `work/vision-results/` 中的 JSON 和本文件。
- 原图、截图和预览图不得进入主会话。
- 坐标统一使用原图 `[x, y, width, height]`。
- 相同 `image_sha256 + mode + question` 不重复请求。
