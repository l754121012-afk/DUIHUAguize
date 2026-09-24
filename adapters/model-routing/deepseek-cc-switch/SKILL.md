---
name: deepseek-cc-switch
description: DeepSeek model routing, cache-aware pricing, and CC Switch maintenance. Use when tasks mention DeepSeek, CC Switch, model selection, token cost estimates, cache pricing, or vision pass-through configuration.
---

# DeepSeek and CC Switch Adapter

This adapter supplies provider-specific defaults to Core.

## Daily model policy

- Text and code: `deepseek-v4-flash`, `medium` reasoning.
- Use a higher reasoning tier only for architecture, repeated parity failure or high-risk review.
- Keep provider/model routing stable inside one cache-warm deliverable.

## Vision routing

- CC Switch 3.18 replaces image blocks for models it classifies as text-only.
- Vision pass-through requires the legacy `deepseek-v4-flash-vision-exp` route.
- Keep the vision route context metadata at `1000000`.

## Maintenance

```powershell
& "<repo>/adapters/model-routing/deepseek-cc-switch/scripts/sync_cc_switch_models.ps1" -Force
```

The script must back up the CC Switch database before writing.

## Cost

Read `references/pricing.md` for the dated price snapshot and use:

```powershell
& "<repo>/adapters/model-routing/deepseek-cc-switch/scripts/estimate_deepseek_cost.ps1" `
  -InputTokens <input> `
  -OutputTokens <output> `
  -CacheHitPercent <0-100> `
  -Period <Auto|Peak|OffPeak>
```

Do not place provider prices in Core.

