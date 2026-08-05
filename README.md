# Griffin's dotfiles

Curated macOS developer configuration managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap

1. Install Homebrew.
2. Clone or initialize this repository as the chezmoi source directory.
3. Preview with `chezmoi diff`.
4. Apply with `chezmoi apply`.
5. Install tools with `brew bundle --file "$(chezmoi source-path)/Brewfile"`.
6. Run `p10k configure` to generate the machine-local `~/.p10k.zsh`.

## Safety

- Secrets never belong in shell startup files or this repository.
- `~/.p10k.zsh` is generated and intentionally untracked.
- Run `scripts/check.sh` before every commit.
- Public and private AFK launchers use separate state homes.
