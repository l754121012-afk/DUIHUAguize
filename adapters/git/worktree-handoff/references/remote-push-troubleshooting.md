# Remote Push Troubleshooting

Use this flow before changing credentials or remote URLs.

## 1. Inspect configuration

```powershell
git config --global --get http.proxy
git config --global --get https.proxy
git remote -v
```

## 2. Test the configured proxy

```powershell
Test-NetConnection 127.0.0.1 -Port 7890
```

If the configured port is closed, do not assume the network itself is unavailable.

## 3. Test direct connection once

```powershell
git -c http.proxy= -c https.proxy= ls-remote --symref <remote-url> HEAD
```

If direct connection resets or times out, continue with local proxy discovery.

## 4. Discover local helper proxies

```powershell
$ports = @(1080, 1081, 7890, 7891, 7897, 7898, 7899, 8888)
foreach ($port in $ports) {
    Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
}

Get-Process |
    Where-Object { $_.ProcessName -match "clash|mihomo|vortex|v2ray|sing|xray|proxy" } |
    Select-Object Id, ProcessName, Path
```

## 5. Verify the candidate proxy

```powershell
$env:HTTPS_PROXY = "http://127.0.0.1:7897"
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com" -TimeoutSec 20 |
    Select-Object StatusCode
```

## 6. Push with a command-level override

```powershell
git -c http.proxy=http://127.0.0.1:7897 `
    -c https.proxy=http://127.0.0.1:7897 `
    push -u origin main
```

Prefer a command-level override until the proxy port is confirmed as stable.

## 7. Verify remote state

```powershell
git -c http.proxy=http://127.0.0.1:7897 `
    -c https.proxy=http://127.0.0.1:7897 `
    ls-remote origin refs/heads/main

git status --short --branch
git log --oneline -1
```

Do not report push success from command output alone. Confirm the remote hash and tracking branch.

## Known environment example

In the current Windows environment:

- stale configured proxy: `127.0.0.1:7890`;
- working helper process: `com.vortex.helper`;
- working proxy port observed: `127.0.0.1:7897`.

This is an environment hint, not a universal default.

