[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$outputsDir = Join-Path $root "outputs"
$requestDir = Join-Path $root "work\vision-requests"
$inboxDir = Join-Path $root "work\vision-inbox"
$resultDir = Join-Path $root "work\vision-results"

foreach ($directory in @($outputsDir, $requestDir, $inboxDir, $resultDir)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
}

$factsPath = Join-Path $outputsDir "VISION-FACTS.md"
$templatePath = Join-Path $PSScriptRoot "..\assets\VISION-FACTS.template.md"
$templatePath = (Resolve-Path -LiteralPath $templatePath).Path

if ($Force -or -not (Test-Path -LiteralPath $factsPath)) {
    Copy-Item -LiteralPath $templatePath -Destination $factsPath -Force
}

$agentsPath = Join-Path $root "AGENTS.md"
$startMarker = "<!-- dual-thread-vision-workflow:start -->"
$endMarker = "<!-- dual-thread-vision-workflow:end -->"
$agentsBlock = @"
$startMarker
## Dual-Thread Vision Workflow

- The main task must not call view_image, read screenshots, or load original/large images.
- Put image requests in `work/vision-requests/`; visual results are read only from `work/vision-results/`.
- Keep durable visual facts in `outputs/VISION-FACTS.md`; do not paste image reasoning into the main task.
- One request covers one image and one question. Split layout, OCR, quality, and pixel-diff requests.
- The vision task may write only its result file under `work/vision-results/` and must not edit product code or assets.
- Read `AGENTS.md` -> `outputs/SESSION-HANDOFF.md` -> `outputs/VISION-FACTS.md` in that order.
- On the first compaction, stop coding, update the handoff, and start a fresh task.
$endMarker
"@

if (Test-Path -LiteralPath $agentsPath) {
    $agentsContent = Get-Content -LiteralPath $agentsPath -Raw
    $pattern = "(?s)$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))"
    if ([regex]::IsMatch($agentsContent, $pattern)) {
        $agentsContent = [regex]::Replace($agentsContent, $pattern, $agentsBlock.Trim())
    }
    else {
        $agentsContent = $agentsContent.TrimEnd() + "`r`n`r`n" + $agentsBlock.Trim() + "`r`n"
    }
}
else {
    $agentsContent = "# Project Rules`r`n`r`n" + $agentsBlock.Trim() + "`r`n"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($agentsPath, $agentsContent, $utf8NoBom)

$readmePath = Join-Path $outputsDir "README.md"
if (Test-Path -LiteralPath $readmePath) {
    $readme = Get-Content -LiteralPath $readmePath -Raw
    if ($readme -notmatch "VISION-FACTS\.md") {
        $readme = $readme.TrimEnd() + "`r`n- [视觉事实 VISION-FACTS](./VISION-FACTS.md)`r`n"
        [System.IO.File]::WriteAllText($readmePath, $readme, $utf8NoBom)
    }
}

Write-Output "PROJECT_ROOT=$root"
Write-Output "AGENTS_PATH=$agentsPath"
Write-Output "VISION_FACTS_PATH=$factsPath"
Write-Output "VISION_REQUEST_DIR=$requestDir"
Write-Output "VISION_RESULT_DIR=$resultDir"
