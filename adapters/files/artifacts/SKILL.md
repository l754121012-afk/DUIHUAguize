---
name: artifact-router
description: Route document, spreadsheet, slide, and PDF requests to the correct artifact workflow. Use when the user requests docx, pptx, xlsx, csv, PDF, slides, sheets, or a document deliverable.
---

# Artifact Router Adapter

Route by output type:

| Output | Workflow |
|---|---|
| `.docx`, Word, Google Docs-targeted | documents workflow |
| `.pptx`, slides, deck | presentations workflow |
| `.xlsx`, sheets, tabular model | spreadsheets workflow |
| `.pdf`, fillable form | pdf workflow |
| raster image generation/edit | image generation workflow |
| SVG/icon/code-native visual | edit the code/vector source directly |

Always follow the output format’s render/verify gate before claiming completion.

