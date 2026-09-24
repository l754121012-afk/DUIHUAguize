# Security and Privacy

## Never commit

- API keys, tokens, cookies, passwords, private SSH keys.
- CC Switch databases containing credentials.
- Machine-specific absolute paths that reveal private data.
- Project memories, rollout summaries, customer data or private logs.
- Screenshots or media that contain private information.

## Adapter rules

- Adapters may write only inside their documented scope.
- Remote-call adapters must state whether they send text, images or files to a provider.
- Install and uninstall scripts must resolve and validate target paths before deletion.
- No destructive repository command is allowed without explicit user approval.

