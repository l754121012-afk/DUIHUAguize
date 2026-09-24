[CmdletBinding()]
param(
    [string]$DbPath = (Join-Path $env:USERPROFILE ".cc-switch\cc-switch.db"),

    [string]$CatalogPath = (Join-Path $env:USERPROFILE ".codex\cc-switch-model-catalog.json"),

    [string]$PythonPath = (Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"),

    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $DbPath)) {
    throw "CC Switch database not found: $DbPath"
}

if (-not (Test-Path -LiteralPath $PythonPath)) {
    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCommand) {
        throw "Python not found."
    }
    $PythonPath = $pythonCommand.Source
}

$running = Get-Process -Name "cc-switch" -ErrorAction SilentlyContinue
if ($running -and -not $Force) {
    throw "CC Switch is running. Close it first or pass -Force."
}

$backupDir = Join-Path (Split-Path -Parent $DbPath) "backups"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$pythonCode = @'
import json
import re
import shutil
import sqlite3
import sys
from datetime import datetime
from pathlib import Path

db_path = Path(sys.argv[1])
catalog_path = Path(sys.argv[2])
backup_dir = Path(sys.argv[3])
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
backup_path = backup_dir / f"db_backup_{timestamp}_dual_thread_vision.db"
shutil.copy2(db_path, backup_path)

con = sqlite3.connect(str(db_path), timeout=30)
con.row_factory = sqlite3.Row
provider = con.execute(
    "SELECT id, settings_config FROM providers WHERE app_type='codex' AND is_current=1 LIMIT 1"
).fetchone()

if provider is None:
    raise RuntimeError("No current Codex provider found.")

settings = json.loads(provider["settings_config"])
config = settings.get("config", "")
config = re.sub(r'(?m)^model\s*=\s*"[^"]*"$', 'model = "deepseek-v4-flash"', config)
config = re.sub(
    r'(?m)^model_reasoning_effort\s*=\s*"[^"]*"$',
    'model_reasoning_effort = "medium"',
    config,
)
settings["config"] = config

model_catalog = settings.get("modelCatalog") or {}
models = model_catalog.get("models") or []
new_models = []
seen = set()

for item in models:
    model_name = str(item.get("model", ""))
    if model_name in {"deepseek-v4-flash", "deepseek-v4-flash-vision-exp", "deepseek-flash"}:
        item["contextWindow"] = 1000000
    if model_name == "deepseek-v4-flash-vision-exp":
        item["displayName"] = "DeepSeek Flash (Vision)"

    if model_name and model_name not in seen:
        new_models.append(item)
        seen.add(model_name)

if "deepseek-v4-flash" not in seen:
    new_models.insert(0, {
        "model": "deepseek-v4-flash",
        "displayName": "DeepSeek V4 Flash",
        "contextWindow": 1000000,
    })
    seen.add("deepseek-v4-flash")

if "deepseek-v4-flash-vision-exp" not in seen:
    new_models.append({
        "model": "deepseek-v4-flash-vision-exp",
        "displayName": "DeepSeek Flash (Vision)",
        "contextWindow": 1000000,
    })

settings["modelCatalog"] = {"models": new_models}
con.execute(
    "UPDATE providers SET settings_config=? WHERE id=? AND app_type='codex'",
    (json.dumps(settings, ensure_ascii=False), provider["id"]),
)

setting = con.execute("SELECT value FROM settings WHERE key='common_config_codex'").fetchone()
if setting is not None and setting["value"]:
    common = re.sub(
        r'(?m)^model_reasoning_effort\s*=\s*"[^"]*"$',
        'model_reasoning_effort = "medium"',
        setting["value"],
    )
    con.execute(
        "UPDATE settings SET value=? WHERE key='common_config_codex'",
        (common,),
    )

con.commit()
con.close()

catalog_updated = False
if catalog_path.exists():
    data = json.loads(catalog_path.read_text(encoding="utf-8"))
    models = data.get("models") or []
    vision_entry = None

    for model in models:
        slug = model.get("slug")
        if slug in {"deepseek-v4-flash", "deepseek-v4-flash-vision-exp", "deepseek-flash"}:
            model["context_window"] = 1000000
        if slug == "deepseek-v4-flash-vision-exp":
            vision_entry = model

    if vision_entry is not None:
        vision_entry["display_name"] = "DeepSeek Flash (Vision)"
        vision_entry["context_window"] = 1000000
        catalog_updated = True
    elif not any(model.get("slug") == "deepseek-v4-flash-vision-exp" for model in models):
        source = next((m for m in models if m.get("slug") == "deepseek-v4-flash"), None)
        if source is not None:
            clone = json.loads(json.dumps(source, ensure_ascii=False))
            clone["slug"] = "deepseek-v4-flash-vision-exp"
            clone["display_name"] = "DeepSeek Flash (Vision)"
            if "description" in clone:
                clone["description"] = "DeepSeek Flash (Vision)"
            clone["context_window"] = 1000000
            models.append(clone)
            catalog_updated = True

    if catalog_updated:
        catalog_path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

print(json.dumps({
    "status": "ok",
    "provider_id": provider["id"],
    "db_backup": str(backup_path),
    "catalog_updated": catalog_updated,
}, ensure_ascii=False))
'@

$result = $pythonCode | & $PythonPath - $DbPath $CatalogPath $backupDir
Write-Output $result
Write-Output "CC_SWITCH_RUNNING=$([bool]$running)"
