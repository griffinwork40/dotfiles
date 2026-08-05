# Security

Never commit API keys, passwords, tokens, private keys, auth databases, shell history, or application credential directories.

Store secrets in the provider's native credential store, macOS Keychain, or an approved password manager, and inject them only into the process that needs them.

If a secret enters a tracked file, revoke it first, remove it from the working tree and Git history, then run Gitleaks before sharing the repository.

## Remediation record

On 2026-08-05, plaintext shell credentials were removed from `~/.zshenv`, gogcli was migrated to macOS Keychain, and the exposed Cursor API key was revoked by the account owner; no replacement Cursor key is stored in these dotfiles.
