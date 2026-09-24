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

    [string]$BaseUrl = $(if ($env:DEEPSEEK_BASE_URL) { $env:DEEPSEEK_BASE_URL } else { "http://127.0.0.1:15721/v1" }),

    [string]$Model = $(
        if ($env:DEEPSEEK_VISION_MODEL) {
            $env:DEEPSEEK_VISION_MODEL
        }
        elseif ($env:DEEPSEEK_BASE_URL) {
            "deepseek-flash"
        }
        else {
            # CC Switch 3.18 detects vision support from this legacy name.
            "deepseek-v4-flash-vision-exp"
        }
    ),

    [ValidateSet("low", "high", "original", "auto")]
    [string]$Detail = "low",

    [ValidateRange(128, 4096)]
    [int]$MaxOutputTokens = 800,

    [switch]$NoCache,

    [switch]$KeepRaw
)

$ErrorActionPreference = "Stop"

$prepareScript = Join-Path $PSScriptRoot "prepare_vision_request.ps1"
$prepareArgs = @{
    ImagePath = $ImagePath
    Question = $Question
    Mode = $Mode
    ProjectRoot = $ProjectRoot
    MaxDimension = $MaxDimension
}

if ($NoCache) {
    $prepareArgs.NoCache = $true
}

$prepareOutput = & $prepareScript @prepareArgs
$paths = @{}

foreach ($line in $prepareOutput) {
    if ($line -match "^([A-Z0-9_]+)=(.*)$") {
        $paths[$matches[1]] = $matches[2]
    }
}

if ($paths["REUSED_CACHE"] -eq "1") {
    Write-Output "REUSED_CACHE=1"
    Write-Output "RESULT_PATH=$($paths["RESULT_PATH"])"
    Write-Output "IMAGE_SHA256=$($paths["IMAGE_SHA256"])"
    exit 0
}

$previewPath = $paths["PREVIEW_PATH"]
$requestPath = $paths["REQUEST_PATH"]
$resultPath = $paths["RESULT_PATH"]
$hash = $paths["IMAGE_SHA256"]

if (-not $previewPath -or -not $resultPath) {
    throw "prepare_vision_request.ps1 did not return the required paths."
}

function Get-ImageMimeType {
    param([string]$Path)

    switch ([System.IO.Path]::GetExtension($Path).ToLowerInvariant()) {
        ".jpg" { return "image/jpeg" }
        ".jpeg" { return "image/jpeg" }
        ".png" { return "image/png" }
        ".gif" { return "image/gif" }
        ".webp" { return "image/webp" }
        default { return "application/octet-stream" }
    }
}

function ConvertFrom-ModelJson {
    param([string]$Content)

    $trimmed = $Content.Trim()
    $trimmed = $trimmed -replace "^```(?:json)?\s*", ""
    $trimmed = $trimmed -replace "\s*```$", ""

    $firstBrace = $trimmed.IndexOf("{")
    $lastBrace = $trimmed.LastIndexOf("}")

    if ($firstBrace -lt 0 -or $lastBrace -le $firstBrace) {
        throw "The model response did not contain a JSON object."
    }

    $jsonObject = $trimmed.Substring($firstBrace, $lastBrace - $firstBrace + 1)
    return ($jsonObject | ConvertFrom-Json)
}

$imageBytes = [System.IO.File]::ReadAllBytes($previewPath)
$base64 = [Convert]::ToBase64String($imageBytes)
$mimeType = Get-ImageMimeType -Path $previewPath
$dataUrl = "data:$mimeType;base64,$base64"

$prompt = @"
You are a constrained vision extraction worker.
Answer only the question in the visual request.
Do not speculate about content that is not visible.
Return exactly one JSON object and no markdown fence or extra text.

Schema:
{
  "status": "done",
  "summary": "one-sentence answer",
  "facts": [
    {"key": "stable.fact.key", "value": "value", "confidence": "high"}
  ],
  "observations": [
    {"label": "object", "bbox": [0, 0, 0, 0], "text": "optional"}
  ],
  "uncertain": []
}

Question:
$Question
"@

$contentBlocks = [System.Collections.ArrayList]@()
$null = $contentBlocks.Add([ordered]@{
    type = "text"
    text = $prompt
})
$null = $contentBlocks.Add([ordered]@{
    type = "image_url"
    image_url = [ordered]@{
        url = $dataUrl
        detail = $Detail
    }
})

$messages = [System.Collections.ArrayList]@()
$null = $messages.Add([ordered]@{
    role = "user"
    content = $contentBlocks.ToArray()
})

$requestBody = [ordered]@{
    model = $Model
    messages = $messages.ToArray()
    thinking = [ordered]@{
        type = "disabled"
    }
    max_tokens = $MaxOutputTokens
    stream = $false
}

$jsonBody = $requestBody | ConvertTo-Json -Depth 30 -Compress
$headers = @{}

if ($env:DEEPSEEK_API_KEY -and -not $BaseUrl.StartsWith("http://127.0.0.1:15721")) {
    $headers.Authorization = "Bearer $env:DEEPSEEK_API_KEY"
}

try {
    $response = Invoke-RestMethod `
        -Uri "$($BaseUrl.TrimEnd('/'))/chat/completions" `
        -Method Post `
        -Headers $headers `
        -ContentType "application/json; charset=utf-8" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($jsonBody)) `
        -TimeoutSec 180

    $content = [string]$response.choices[0].message.content
    $parsed = $null
    $parseError = $null

    try {
        $parsed = ConvertFrom-ModelJson -Content $content
    }
    catch {
        $parseError = $_.Exception.Message
    }

    $rawPath = $null
    if ($KeepRaw -or $parseError) {
        $rawPath = [System.IO.Path]::ChangeExtension($resultPath, ".raw.txt")
        Set-Content -LiteralPath $rawPath -Value $content -Encoding UTF8
    }

    $facts = @()
    $observations = @()
    $uncertain = @()

    if ($parsed -and $null -ne $parsed.facts) {
        $facts = @($parsed.facts)
    }
    if ($parsed -and $null -ne $parsed.observations) {
        $observations = @($parsed.observations)
    }
    if ($parsed -and $null -ne $parsed.uncertain) {
        $uncertain = @($parsed.uncertain)
    }
    elseif ($parseError) {
        $uncertain = @($parseError)
    }

    $result = [ordered]@{
        request_id = [System.IO.Path]::GetFileNameWithoutExtension($resultPath)
        status = if ($parsed.status) { $parsed.status } elseif ($parseError) { "partial" } else { "done" }
        image_sha256 = $hash
        mode = $Mode
        question = $Question.Trim()
        image_path = (Resolve-Path -LiteralPath $ImagePath).Path
        preview_path = $previewPath
        request_path = $requestPath
        summary = if ($parsed) { $parsed.summary } else { $content }
        facts = [object[]]$facts
        observations = [object[]]$observations
        uncertain = [object[]]$uncertain
        passes = 1
        model = $Model
        detail = $Detail
        usage = $response.usage
        raw_response_path = $rawPath
    }

    $result |
        ConvertTo-Json -Depth 30 |
        Set-Content -LiteralPath $resultPath -Encoding UTF8

    Write-Output "REUSED_CACHE=0"
    Write-Output "RESULT_PATH=$resultPath"
    Write-Output "IMAGE_SHA256=$hash"

    if ($response.usage) {
        Write-Output "USAGE=$($response.usage | ConvertTo-Json -Compress)"
    }
}
catch {
    $errorResult = [ordered]@{
        request_id = [System.IO.Path]::GetFileNameWithoutExtension($resultPath)
        status = "error"
        image_sha256 = $hash
        mode = $Mode
        question = $Question.Trim()
        image_path = (Resolve-Path -LiteralPath $ImagePath).Path
        preview_path = $previewPath
        request_path = $requestPath
        error = $_.Exception.Message
        passes = 1
        model = $Model
        detail = $Detail
    }

    $errorResult |
        ConvertTo-Json -Depth 20 |
        Set-Content -LiteralPath $resultPath -Encoding UTF8

    Write-Output "RESULT_PATH=$resultPath"
    Write-Output "ERROR=$($_.Exception.Message)"
    exit 1
}
