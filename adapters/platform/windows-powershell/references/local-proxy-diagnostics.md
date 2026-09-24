# Local Proxy Diagnostics

## Symptom

A command works through a proxy on one day and then fails after the configured port becomes stale.

Typical error:

```text
Failed to connect to github.com port 443 via 127.0.0.1
```

## Checks

1. Read global Git proxy settings.
2. Check whether the configured port is listening.
3. Check common local proxy ports.
4. Identify the owning process.
5. Test `https://github.com` through the candidate proxy.
6. Use a command-level Git override.

## Rules

- Do not assume direct internet access is available.
- Do not assume the configured proxy is still running.
- Do not overwrite global Git proxy settings without user confirmation.
- Prefer the smallest validated override.
- Record the working proxy in the environment profile only when the user wants it persisted.

