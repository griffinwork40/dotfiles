# Griffin's dotfiles

Curated macOS and Linux developer configuration managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap

### macOS

1. Install Homebrew.
2. Install chezmoi: `brew install chezmoi`.
3. Initialize this repository: `chezmoi init git@github.com:griffinwork40/dotfiles.git`.
4. Preview with `chezmoi diff`, then apply with `chezmoi apply`.
5. Run `"$(chezmoi source-path)/executable_install.sh"` to install the captured Brewfile intentionally.
6. Run `p10k configure` to generate machine-local `~/.p10k.zsh`.

### Linux

1. Install zsh, chezmoi, and Gitleaks with the distribution package manager or Linuxbrew.
2. Initialize: `chezmoi init git@github.com:griffinwork40/dotfiles.git`.
3. Preview with `chezmoi diff`, then apply with `chezmoi apply`.
4. Run `"$(chezmoi source-path)/executable_install.sh"` to verify required tools; it never invokes apt, dnf, pacman, or another package manager.
5. Install Oh My Zsh, Powerlevel10k, NVM, and project checkouts as needed.

Package installation is explicit on both systems; `chezmoi apply` never installs packages.

## Portability

- `PNPM_HOME` renders as `~/Library/pnpm` on macOS and `~/.local/share/pnpm` on Linux.
- Homebrew shell integration probes Apple Silicon, Intel macOS, and Linuxbrew paths at runtime.
- Ghostty's macOS titlebar setting is omitted on Linux.
- zsh plugins probe Homebrew and common Linux distribution paths and source only the first match.
- AFK launchers remain optional and expect project checkouts under `~/Projects`.

## Verification

- `scripts/check.sh` runs zsh/sh syntax checks, Darwin and deterministic Linux template renders, Gitleaks, the 350-line gate, and chezmoi drift verification.
- `scripts/check-linux.sh` is an optional high-fidelity Docker check; it requires a running Docker daemon.

## Safety

- Secrets never belong in shell startup files or this repository.
- `~/.p10k.zsh` is generated and intentionally untracked.
- Run `scripts/check.sh` before every commit.
- Public and private AFK launchers use separate state homes.
