[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BeforePath,

    [Parameter(Mandatory = $true)]
    [string]$AfterPath,

    [string]$ProjectRoot = (Get-Location).Path,

    [ValidateRange(1, 255)]
    [int]$Threshold = 8,

    [string]$OutputImagePath,

    [string]$OutputJsonPath
)

$ErrorActionPreference = "Stop"

function Convert-ToArgbBitmap {
    param([string]$Path)

    Add-Type -AssemblyName System.Drawing
    $source = [System.Drawing.Image]::FromFile($Path)
    try {
        $bitmap = New-Object System.Drawing.Bitmap(
            $source.Width,
            $source.Height,
            [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
        )
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.DrawImage($source, 0, 0, $source.Width, $source.Height)
        }
        finally {
            $graphics.Dispose()
        }
        return $bitmap
    }
    finally {
        $source.Dispose()
    }
}

function Get-BitmapBytes {
    param([System.Drawing.Bitmap]$Bitmap)

    $rectangle = New-Object System.Drawing.Rectangle(0, 0, $Bitmap.Width, $Bitmap.Height)
    $data = $Bitmap.LockBits(
        $rectangle,
        [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )

    try {
        $length = [Math]::Abs($data.Stride) * $Bitmap.Height
        $bytes = New-Object byte[] $length
        [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $length)
        return [pscustomobject]@{
            Bytes = $bytes
            Stride = $data.Stride
            Width = $Bitmap.Width
            Height = $Bitmap.Height
        }
    }
    finally {
        $Bitmap.UnlockBits($data)
    }
}

$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$before = (Resolve-Path -LiteralPath $BeforePath).Path
$after = (Resolve-Path -LiteralPath $AfterPath).Path

$beforeBitmap = Convert-ToArgbBitmap -Path $before
$afterBitmap = Convert-ToArgbBitmap -Path $after

try {
    if ($beforeBitmap.Width -ne $afterBitmap.Width -or $beforeBitmap.Height -ne $afterBitmap.Height) {
        throw "Images must have identical dimensions."
    }

    $beforeData = Get-BitmapBytes -Bitmap $beforeBitmap
    $afterData = Get-BitmapBytes -Bitmap $afterBitmap
    $width = $beforeBitmap.Width
    $height = $beforeBitmap.Height
    $stride = $beforeData.Stride

    $outputData = New-Object byte[] $afterData.Bytes.Length
    [Array]::Copy($afterData.Bytes, $outputData, $afterData.Bytes.Length)

    $diffPixels = 0
    $minX = $width
    $minY = $height
    $maxX = -1
    $maxY = -1

    for ($y = 0; $y -lt $height; $y++) {
        $rowOffset = $y * $stride
        for ($x = 0; $x -lt $width; $x++) {
            $offset = $rowOffset + ($x * 4)
            $bDiff = [Math]::Abs([int]$beforeData.Bytes[$offset] - [int]$afterData.Bytes[$offset])
            $gDiff = [Math]::Abs([int]$beforeData.Bytes[$offset + 1] - [int]$afterData.Bytes[$offset + 1])
            $rDiff = [Math]::Abs([int]$beforeData.Bytes[$offset + 2] - [int]$afterData.Bytes[$offset + 2])
            $aDiff = [Math]::Abs([int]$beforeData.Bytes[$offset + 3] - [int]$afterData.Bytes[$offset + 3])

            $isDifferent = ($bDiff -gt $Threshold -or $gDiff -gt $Threshold -or $rDiff -gt $Threshold -or $aDiff -gt $Threshold)
            if ($isDifferent) {
                $diffPixels++
                $minX = [Math]::Min($minX, $x)
                $minY = [Math]::Min($minY, $y)
                $maxX = [Math]::Max($maxX, $x)
                $maxY = [Math]::Max($maxY, $y)

                $outputData[$offset] = 0
                $outputData[$offset + 1] = 0
                $outputData[$offset + 2] = 255
                $outputData[$offset + 3] = 255
            }
        }
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $resultDirectory = Join-Path $root "work\vision-results"
    $inboxDirectory = Join-Path $root "work\vision-inbox"
    New-Item -ItemType Directory -Force -Path $resultDirectory | Out-Null
    New-Item -ItemType Directory -Force -Path $inboxDirectory | Out-Null

    if (-not $OutputJsonPath) {
        $OutputJsonPath = Join-Path $resultDirectory "pixel-diff-$timestamp.json"
    }
    if (-not $OutputImagePath) {
        $OutputImagePath = Join-Path $inboxDirectory "pixel-diff-$timestamp.png"
    }

    $OutputJsonPath = [System.IO.Path]::GetFullPath($OutputJsonPath)
    $OutputImagePath = [System.IO.Path]::GetFullPath($OutputImagePath)
    New-Item -ItemType Directory -Force -Path ([System.IO.Path]::GetDirectoryName($OutputJsonPath)) | Out-Null
    New-Item -ItemType Directory -Force -Path ([System.IO.Path]::GetDirectoryName($OutputImagePath)) | Out-Null

    $diffBitmap = New-Object System.Drawing.Bitmap(
        $width,
        $height,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    try {
        $rectangle = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
        $diffData = $diffBitmap.LockBits(
            $rectangle,
            [System.Drawing.Imaging.ImageLockMode]::WriteOnly,
            [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
        )
        try {
            [System.Runtime.InteropServices.Marshal]::Copy($outputData, 0, $diffData.Scan0, $outputData.Length)
        }
        finally {
            $diffBitmap.UnlockBits($diffData)
        }
        $diffBitmap.Save($OutputImagePath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $diffBitmap.Dispose()
    }

    $boundingBox = $null
    if ($diffPixels -gt 0) {
        $boundingBox = @($minX, $minY, ($maxX - $minX + 1), ($maxY - $minY + 1))
    }

    $result = [ordered]@{
        status = "done"
        before_path = $before
        after_path = $after
        threshold = $Threshold
        width = $width
        height = $height
        diff_pixels = $diffPixels
        total_pixels = $width * $height
        diff_ratio = [Math]::Round($diffPixels / ($width * $height), 6)
        bbox = $boundingBox
        diff_image_path = $OutputImagePath
        generated_at = (Get-Date).ToString("o")
    }

    $result |
        ConvertTo-Json -Depth 10 |
        Set-Content -LiteralPath $OutputJsonPath -Encoding UTF8

    Write-Output "PIXEL_DIFF_JSON=$OutputJsonPath"
    Write-Output "PIXEL_DIFF_IMAGE=$OutputImagePath"
    Write-Output "DIFF_PIXELS=$diffPixels"
    Write-Output "DIFF_RATIO=$($result.diff_ratio)"
}
finally {
    $beforeBitmap.Dispose()
    $afterBitmap.Dispose()
}
