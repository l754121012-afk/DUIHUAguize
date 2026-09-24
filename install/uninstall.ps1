param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" })
)

$ErrorActionPreference = "Stop"
$SkillsDir = (Resolve-Path (Join-Path $CodexHome "skills")).Path
$names = @(
    "agent-collaboration-protocol",
    "deepseek-cc-switch",
    "dual-thread-vision-workflow",
    "godot-verification",
    "windows-powershell",
    "codex-app-runtime",
    "artifact-router",
    "git-worktree-handoff"
)

function Assert-ChildPath([string]$Child, [string]$Parent) {
    $childFull = [System.IO.Path]::GetFullPath($Child)
    $parentFull = [System.IO.Path]::GetFullPath($Parent).TrimEnd('\') + '\'
    if (-not $childFull.StartsWith($parentFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove path outside skills directory: $childFull"
    }
}

foreach ($name in $names) {
    $target = Join-Path $SkillsDir $name
    if (Test-Path -LiteralPath $target) {
        Assert-ChildPath $target $SkillsDir
        Remove-Item -LiteralPath $target -Recurse -Force
        Write-Host "Removed: $name"
    }
}

$agentsPath = Join-Path $CodexHome "AGENTS.md"
if (Test-Path -LiteralPath $agentsPath) {
    $text = Get-Content -Raw -LiteralPath $agentsPath
    $text = [regex]::Replace($text, "(?s)<!-- agent-collaboration-protocol:start -->.*?<!-- agent-collaboration-protocol:end -->", "").Trim()
    [System.IO.File]::WriteAllText($agentsPath, $text + "`n", [System.Text.UTF8Encoding]::new($false))
}

Write-Host "Uninstall complete. Backups were left in the skills directory."
