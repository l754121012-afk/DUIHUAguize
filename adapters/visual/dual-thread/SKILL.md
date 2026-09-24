---
name: dual-thread-vision-workflow
description: Keep image understanding out of the main task. Use for screenshot-heavy projects, visual review, OCR/layout extraction, pixel-diff checks, and compact image-to-text handoffs.
---

# Dual Thread Vision Workflow

The main task stays text-only. A separate vision task handles one image and one question.

## Rules

1. The main task must not open screenshots or original images.
2. One request covers one image and one question.
3. The vision task writes only its result JSON.
4. The main task reads only the compact result.
5. If a context compaction occurs, stop the milestone, update handoff, and start a fresh task.

## Workflow

```powershell
& "<repo>/adapters/visual/dual-thread/scripts/invoke_vision_preprocess.ps1" `
  -ProjectRoot "<project-root>" `
  -ImagePath "<image-path>" `
  -Mode layout `
  -Question "<one precise question>"
```

Read only the returned JSON path. If the cache is reused, do not call the model again.

Use the text protocol plus local scripts on systems where PowerShell is unavailable.

## Provider routing

Image pass-through and model routing are provider-specific. Load:

`../../model-routing/deepseek-cc-switch/`

Core remains provider-neutral.

## References

- `references/protocol.md`
- `references/prompt-templates.md`
- `references/template-router.md`
- `../../../core/references/task-preflight.md`
