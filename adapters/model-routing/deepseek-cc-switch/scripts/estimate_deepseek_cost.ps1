[CmdletBinding()]
param(
    [ValidateRange(0, [double]::MaxValue)]
    [double]$InputTokens = 0,

    [ValidateRange(0, [double]::MaxValue)]
    [double]$OutputTokens = 0,

    [ValidateRange(0, 100)]
    [double]$CacheHitPercent = 0,

    [ValidateSet("Auto", "Peak", "OffPeak")]
    [string]$Period = "Auto",

    [datetime]$AtTime = (Get-Date),

    [ValidateRange(0, 100)]
    [double]$UsdCnyRate = 0
)

$ErrorActionPreference = "Stop"

function Resolve-DeepSeekPeriod {
    param([datetime]$Time)

    $utc = $Time.ToUniversalTime()
    if ($utc.DayOfWeek -eq [System.DayOfWeek]::Saturday -or $utc.DayOfWeek -eq [System.DayOfWeek]::Sunday) {
        return "OffPeak"
    }

    $minutes = ($utc.Hour * 60) + $utc.Minute
    $isMorningPeak = $minutes -ge (1 * 60) -and $minutes -lt (4 * 60)
    $isAfternoonPeak = $minutes -ge (6 * 60) -and $minutes -lt (10 * 60)

    if ($isMorningPeak -or $isAfternoonPeak) {
        return "Peak"
    }

    return "OffPeak"
}

$resolvedPeriod = if ($Period -eq "Auto") { Resolve-DeepSeekPeriod -Time $AtTime } else { $Period }

$pricing = @{
    Peak = @{
        CacheHitPerMillion = 0.006
        CacheMissPerMillion = 0.3
        OutputPerMillion = 1.2
    }
    OffPeak = @{
        CacheHitPerMillion = 0.003
        CacheMissPerMillion = 0.15
        OutputPerMillion = 0.6
    }
}

$rate = $pricing[$resolvedPeriod]
$cacheHitTokens = $InputTokens * ($CacheHitPercent / 100.0)
$cacheMissTokens = $InputTokens - $cacheHitTokens

$cacheHitCost = $cacheHitTokens * $rate.CacheHitPerMillion / 1000000.0
$cacheMissCost = $cacheMissTokens * $rate.CacheMissPerMillion / 1000000.0
$outputCost = $OutputTokens * $rate.OutputPerMillion / 1000000.0
$totalUsd = $cacheHitCost + $cacheMissCost + $outputCost

$result = [ordered]@{
    model = "deepseek-flash"
    pricing_source = "DeepSeek official pricing checked 2026-09-24"
    period = $resolvedPeriod
    at_time_local = $AtTime.ToString("o")
    at_time_utc = $AtTime.ToUniversalTime().ToString("o")
    input_tokens = [Math]::Round($InputTokens, 2)
    cache_hit_percent = [Math]::Round($CacheHitPercent, 2)
    cache_hit_tokens = [Math]::Round($cacheHitTokens, 2)
    cache_miss_tokens = [Math]::Round($cacheMissTokens, 2)
    output_tokens = [Math]::Round($OutputTokens, 2)
    cache_hit_cost_usd = [Math]::Round($cacheHitCost, 8)
    cache_miss_cost_usd = [Math]::Round($cacheMissCost, 8)
    output_cost_usd = [Math]::Round($outputCost, 8)
    total_usd = [Math]::Round($totalUsd, 8)
}

if ($UsdCnyRate -gt 0) {
    $result.usd_cny_rate = [Math]::Round($UsdCnyRate, 4)
    $result.total_cny = [Math]::Round($totalUsd * $UsdCnyRate, 6)
}

Write-Output ($result | ConvertTo-Json -Depth 5 -Compress)
