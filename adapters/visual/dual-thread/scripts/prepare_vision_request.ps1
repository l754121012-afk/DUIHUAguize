[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ImagePath,

    [Parameter(Mandatory = $true)]
    [string]$Question,

    [ValidateSet("general", "layout", "ocr", "quality", "pixel-diff")]
    [string]$Mode = "general",

    [string]$ProjectRoot = (Get-Location).Path,

    [ValidateRange(0, 8192)]
    [int]$MaxDimension = 1024,

    [switch]$NoCache
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$sourceImage = (Resolve-Path -LiteralPath $ImagePath).Path
$normalizedQuestion = $Question.Trim()

if (-not $normalizedQuestion) {
    throw "Question cannot be empty."
}

$requestDir = Join-Path $root "work\vision-requests"
$inboxDir = Join-Path $root "work\vision-inbox"
$resultDir = Join-Path $root "work\vision-results"

New-Item -ItemType Directory -Force -Path $requestDir | Out-Null
New-Item -ItemType Directory -Force -Path $inboxDir | Out-Null
New-Item -ItemType Directory -Force -Path $resultDir | Out-Null

$hash = (Get-FileHash -LiteralPath $sourceImage -Algorithm SHA256).Hash.ToLowerInvariant()

if (-not $NoCache) {
    $cacheHit = $null
    $resultFiles = Get-ChildItem -LiteralPath $resultDir -Filter "*.json" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending

    foreach ($resultFile in $resultFiles) {
        try {
            $candidate = Get-Content -LiteralPath $resultFile.FullName -Raw | ConvertFrom-Json
        }
        catch {
            continue
        }

        if (
            $candidate.status -eq "done" -and
            $candidate.image_sha256 -eq $hash -and
            $candidate.mode -eq $Mode -and
            $candidate.question -eq $normalizedQuestion
        ) {
            $cacheHit = $candidate
            break
        }
    }

    if ($cacheHit) {
        $cachedRequestPath = if ($cacheHit.request_path) { $cacheHit.request_path } else { $null }
        Write-Output "REUSED_CACHE=1"
        if ($cachedRequestPath) {
            Write-Output "REQUEST_PATH=$cachedRequestPath"
        }
        Write-Output "PREVIEW_PATH=$($cacheHit.preview_path)"
        Write-Output "RESULT_PATH=$($resultFile.FullName)"
        Write-Output "IMAGE_SHA256=$hash"
        exit 0
    }
}

$requestId = "{0}-{1}" -f (Get-Date -Format "yyyyMMdd-HHmmss"), $hash.Substring(0, 8)
$extension = [System.IO.Path]::GetExtension($sourceImage)

$inboxImage = Join-Path $inboxDir ($requestId + $extension)
Copy-Item -LiteralPath $sourceImage -Destination $inboxImage -Force

$previewPath = $null
$width = $null
$height = $null

try {
    Add-Type -AssemblyName System.Drawing
    $source = [System.Drawing.Image]::FromFile($sourceImage)
    try {
        $width = $source.Width
        $height = $source.Height

        if ($MaxDimension -gt 0) {
            $scale = [Math]::Min(1.0, [double]$MaxDimension / [Math]::Max($source.Width, $source.Height))
            $previewWidth = [Math]::Max(1, [int][Math]::Round($source.Width * $scale))
            $previewHeight = [Math]::Max(1, [int][Math]::Round($source.Height * $scale))

            $bitmap = New-Object System.Drawing.Bitmap($previewWidth, $previewHeight)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.DrawImage($source, 0, 0, $previewWidth, $previewHeight)
                $previewPath = Join-Path $inboxDir ($requestId + "-preview.png")
                $bitmap.Save($previewPath, [System.Drawing.Imaging.ImageFormat]::Png)
            }
            finally {
                $graphics.Dispose()
                $bitmap.Dispose()
            }
        }
    }
    finally {
        $source.Dispose()
    }
}
catch {
    Write-Warning "Preview generation failed. The copied image will be used instead: $($_.Exception.Message)"
    $previewPath = $inboxImage
}

if (-not $previewPath) {
    $previewPath = $inboxImage
}

$requestPath = Join-Path $requestDir ($requestId + ".md")
$resultPath = Join-Path $resultDir ($requestId + ".json")

$request = @"
# Visual Request

- request_id: $requestId
- project_root: $root
- mode: $Mode
- image_path: $sourceImage
- preview_path: $previewPath
- image_sha256: $hash
- image_dimensions: $width x $height
- result_path: $resultPath

## Question

$normalizedQuestion

## Required output

- Write one JSON object to result_path.
- Use original-image pixel coordinates, not preview-image coordinates.
- Use null for unknown values and list them in uncertain.
- Do not modify product files, scenes, assets, or configuration.
"@

Set-Content -LiteralPath $requestPath -Value $request -Encoding UTF8

$resultTemplate = [ordered]@{
    request_id = $requestId
    status = "pending"
    image_sha256 = $hash
    mode = $Mode
    question = $normalizedQuestion
    image_path = $sourceImage
    preview_path = $previewPath
    request_path = $requestPath
    summary = $null
    facts = @()
    observations = @()
    uncertain = @()
    passes = 0
}

$resultTemplate |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath $resultPath -Encoding UTF8

Write-Output "REUSED_CACHE=0"
Write-Output "REQUEST_PATH=$requestPath"
Write-Output "PREVIEW_PATH=$previewPath"
Write-Output "RESULT_PATH=$resultPath"
Write-Output "IMAGE_SHA256=$hash"
