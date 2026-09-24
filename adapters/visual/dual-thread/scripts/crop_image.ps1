[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [string]$OutputPath,

    [Parameter(Mandatory = $true)]
    [int]$X,

    [Parameter(Mandatory = $true)]
    [int]$Y,

    [Parameter(Mandatory = $true)]
    [int]$Width,

    [Parameter(Mandatory = $true)]
    [int]$Height,

    [ValidateRange(0.01, 8.0)]
    [double]$Scale = 1.0
)

$ErrorActionPreference = "Stop"

$sourcePath = (Resolve-Path -LiteralPath $InputPath).Path

if (-not $OutputPath) {
    $directory = [System.IO.Path]::GetDirectoryName($sourcePath)
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath)
    $OutputPath = Join-Path $directory "$baseName-crop-$X-$Y-$Width-$Height.png"
}

$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = [System.IO.Path]::GetDirectoryName($outputFullPath)
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

Add-Type -AssemblyName System.Drawing
$source = [System.Drawing.Image]::FromFile($sourcePath)

try {
    if ($X -lt 0 -or $Y -lt 0 -or $Width -le 0 -or $Height -le 0) {
        throw "Crop coordinates and dimensions must be positive."
    }

    if (($X + $Width) -gt $source.Width -or ($Y + $Height) -gt $source.Height) {
        throw "Crop rectangle exceeds image bounds."
    }

    $rectangle = New-Object System.Drawing.Rectangle($X, $Y, $Width, $Height)
    $crop = $source.Clone($rectangle, $source.PixelFormat)

    try {
        $final = $crop
        if ($Scale -ne 1.0) {
            $targetWidth = [Math]::Max(1, [int][Math]::Round($crop.Width * $Scale))
            $targetHeight = [Math]::Max(1, [int][Math]::Round($crop.Height * $Scale))
            $scaled = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
            $graphics = [System.Drawing.Graphics]::FromImage($scaled)
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.DrawImage($crop, 0, 0, $targetWidth, $targetHeight)
                $final = $scaled
            }
            finally {
                $graphics.Dispose()
            }
        }

        try {
            $final.Save($outputFullPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            if ($final -ne $crop) {
                $final.Dispose()
            }
        }
    }
    finally {
        $crop.Dispose()
    }
}
finally {
    $source.Dispose()
}

$result = [ordered]@{
    status = "done"
    input_path = $sourcePath
    output_path = $outputFullPath
    x = $X
    y = $Y
    width = $Width
    height = $Height
    scale = $Scale
}

Write-Output "CROP_PATH=$outputFullPath"
Write-Output "CROP_JSON=$($result | ConvertTo-Json -Compress)"
