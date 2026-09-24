param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SkillsDir = Join-Path $CodexHome "skills"
$MainTarget = Join-Path $SkillsDir "agent-collaboration-protocol"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-Existing([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        if (-not $Force) {
            throw "Target exists: $Path. Re-run with -Force to back it up and replace it."
        }
        $backup = "$Path.backup-$Stamp"
        Move-Item -LiteralPath $Path -Destination $backup
        Write-Host "Backed up: $Path -> $backup"
    }
}

function Copy-RepoItem([string]$RelativePath, [string]$DestinationRoot) {
    $source = Join-Path $RepoRoot $RelativePath
    $destination = Join-Path $DestinationRoot $RelativePath
    New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
Backup-Existing $MainTarget
New-Item -ItemType Directory -Force -Path $MainTarget | Out-Null

foreach ($item in @("SKILL.md", "README.md", "VERSION", "SECURITY.md", "core", "profiles", "adapters", "templates")) {
    Copy-RepoItem $item $MainTarget
}

$adapterMap = @{
    "deepseek-cc-switch"       = "adapters\model-routing\deepseek-cc-switch"
    "dual-thread-vision-workflow" = "adapters\visual\dual-thread"
    "godot-verification"       = "adapters\engine\godot"
    "windows-powershell"       = "adapters\platform\windows-powershell"
    "codex-app-runtime"        = "adapters\runtime\codex-app"
    "artifact-router"          = "adapters\files\artifacts"
    "git-worktree-handoff"     = "adapters\git\worktree-handoff"
}

foreach ($entry in $adapterMap.GetEnumerator()) {
    $target = Join-Path $SkillsDir $entry.Key
    Backup-Existing $target
    Copy-Item -LiteralPath (Join-Path $MainTarget $entry.Value) -Destination $target -Recurse -Force
    Write-Host "Installed adapter: $($entry.Key)"
}

$agentsPath = Join-Path $CodexHome "AGENTS.md"
$bootstrap = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot "AGENTS.md")
$existing = if (Test-Path -LiteralPath $agentsPath) { Get-Content -Raw -LiteralPath $agentsPath } else { "" }
$pattern = "(?s)<!-- agent-collaboration-protocol:start -->.*?<!-- agent-collaboration-protocol:end -->"
$existing = [regex]::Replace($existing, $pattern, "").Trim()
$combined = if ($existing.Length -gt 0) { "$existing`n`n$bootstrap" } else { $bootstrap }
[System.IO.File]::WriteAllText($agentsPath, $combined.Trim() + "`n", [System.Text.UTF8Encoding]::new($false))

Write-Host "Installed agent-collaboration-protocol into $CodexHome"
Write-Host "Run doctor/doctor.ps1 to verify."

