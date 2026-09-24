param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" })
)

$ErrorActionPreference = "Stop"
$SkillsDir = Join-Path $CodexHome "skills"
$required = @(
    "agent-collaboration-protocol",
    "deepseek-cc-switch",
    "dual-thread-vision-workflow",
    "godot-verification",
    "windows-powershell",
    "codex-app-runtime",
    "artifact-router",
    "git-worktree-handoff"
)
$failed = $false

foreach ($name in $required) {
    $skillFile = Join-Path (Join-Path $SkillsDir $name) "SKILL.md"
    if (Test-Path -LiteralPath $skillFile) {
        Write-Host "OK   $name"
    } else {
        Write-Host "MISS $name"
        $failed = $true
    }
}

$agentsPath = Join-Path $CodexHome "AGENTS.md"
if ((Test-Path -LiteralPath $agentsPath) -and ((Get-Content -Raw -LiteralPath $agentsPath).Contains("agent-collaboration-protocol:start"))) {
    Write-Host "OK   global AGENTS bootstrap"
} else {
    Write-Host "MISS global AGENTS bootstrap"
    $failed = $true
}

if ($failed) {
    exit 1
}
Write-Host "Doctor: PASS"

