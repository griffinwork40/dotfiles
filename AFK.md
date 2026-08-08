# Dotfiles (chezmoi source)

## What This Is

Griffin's macOS + Linux developer configuration, managed with [chezmoi](https://www.chezmoi.io/). This directory is the chezmoi **source state** (`chezmoi source-path`), not the live config — nothing here takes effect until `chezmoi apply` writes it to `$HOME`. Remote: `griffinwork40/dotfiles`. No package manager, build system, or CI; the whole verification surface is `scripts/check.sh`.

Covered: zsh (Oh My Zsh + Powerlevel10k), Ghostty, tmux, git ignore, and a Homebrew `Brewfile`. Both `dot_zshrc.tmpl` and `dot_config/ghostty/config.tmpl` are Go templates that render differently on Darwin vs Linux.

## Source ≠ Deployed

Editing a file here changes nothing until it is applied. Editing `~/.zshrc` directly is **wrong** — it creates drift that `chezmoi verify` fails on, and the next `chezmoi apply` overwrites it.

| Intent | Correct action |
|---|---|
| Change shell/editor config | Edit the file **here**, then `chezmoi diff` → `chezmoi apply` |
| See what a change would do to `$HOME` | `chezmoi diff` |
| Check `$HOME` matches this repo | `chezmoi verify` (exit 0 = no drift) |
| Pull a hand-edited `~` file back into the repo | `chezmoi re-add <path>` |

## Commands

```sh
./scripts/check.sh          # full gate — run before EVERY commit
./scripts/check-linux.sh    # optional Alpine/Docker check; exits 2 if no Docker daemon
chezmoi diff                # preview source → $HOME
chezmoi apply               # write to $HOME
chezmoi verify              # assert $HOME matches source
./executable_install.sh     # install tools from Brewfile (macOS) / verify deps (Linux)

# Render a template for one OS without applying it
chezmoi execute-template < dot_zshrc.tmpl
chezmoi execute-template --override-data '{"chezmoi":{"os":"linux"}}' < dot_zshrc.tmpl
```

`scripts/check.sh` runs, in order: `zsh -n` / `sh -n` syntax checks → Darwin + Linux template renders (asserting the `PNPM_HOME` path and the macOS-only Ghostty titlebar branch) → **gitleaks** → a **350-line-per-file** gate → `chezmoi verify`.

## Architecture

| Path | Renders to | Purpose |
|---|---|---|
| `private_dot_zshenv` | `~/.zshenv` (0600) | Every zsh invocation. Minimal, secret-free; sources cargo env only. |
| `dot_zprofile` | `~/.zprofile` | Login shells. Probes 3 Homebrew prefixes (Apple Silicon, Intel, Linuxbrew), uses first hit. |
| `dot_zshrc.tmpl` | `~/.zshrc` | Interactive shells. p10k instant prompt, PATH dedupe helpers, nvm, AFK launchers. |
| `dot_config/ghostty/config.tmpl` | `~/.config/ghostty/config` | Terminal; `macos-titlebar-style` is Darwin-gated. |
| `dot_config/ghostty/themes/agent-afk` | same path | Custom dark palette. |
| `dot_config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | vi mode-keys, mouse, `\|`/`-` splits, `hjkl` panes. |
| `dot_config/private_git/ignore` | `~/.config/git/ignore` (0600) | Global gitignore. |
| `Brewfile` | *(not applied)* | 7 taps, 42 brews, 18 casks, 16 VS Code exts. Installed only by `executable_install.sh`. |
| `scripts/`, `README.md`, `SECURITY.md`, `BENCHMARKS.md` | *(not applied)* | Repo meta — excluded via `.chezmoiignore`. |

### Filename prefixes are semantics, not decoration

`dot_` → leading `.` · `private_` → 0600 · `executable_` → +x · `.tmpl` → Go-templated. Renaming a file changes its target path **and its permissions**. Any new repo-meta file (docs, scripts, CI) must be added to `.chezmoiignore` or chezmoi will deploy it into `$HOME`.

### `dot_zshrc.tmpl` notable regions

- **Lines 1–4**: p10k instant prompt must stay at the top; anything requiring input goes above it.
- **`_afk_cd_from_marker`**: AFK writes a destination to `$AFK_HOME/state/last-cwd` and the shell cds after the binary exits (a child cannot change its parent's cwd). **Ordering is load-bearing: `cd` before `rm`** — a failed `cd` must keep the marker and warn.
- **`afk-dev-public` / `afk-dev-private`**: run `node dist/cli.mjs` out of separate checkouts with separate `AFK_HOME`s (`~/.afk-dev-public`, `~/.afk-dev-private`). Public core is canonical; `afk-dev` aliases public.
- **`afk shell-init` block**: installed by hand and deliberately **not** byte-identical to the generator's output (it shares `_afk_cd_from_marker`). If the marker protocol changes, diff against `afk shell-init` rather than assuming.
- **zsh-syntax-highlighting must load last**, after all widgets and integrations.

## Conventions

- **Portability first.** Never hardcode a Homebrew prefix or an OS-specific path — probe a candidate list and take the first match, or branch with `{{ if eq .chezmoi.os "darwin" }}`. Both renders must pass `zsh -n`; add a `grep` assertion to `scripts/check.sh` for any new OS-divergent line.
- **Optional things must degrade silently.** Guard every external source with `[[ -r ... ]]` — a moved checkout (termauto, nvm, p10k) must not break new shells.
- **No secrets, ever** — not in shell startup files, not in this repo. Use Keychain or the provider's credential store and inject per-process. Gitleaks gates every `check.sh` run. See `SECURITY.md`.
- **350-line hard cap per file**, enforced mechanically by `check.sh`. At the ceiling, extract a whole concern into a new file; never raise the limit.
- **Packages are never installed implicitly.** `chezmoi apply` only writes config; `executable_install.sh` is the explicit opt-in, and on Linux it refuses to call any package manager.
- **`~/.p10k.zsh` is generated and intentionally untracked** — run `p10k configure` per machine. Do not add it here.
- **POSIX `sh` for scripts** (`#!/bin/sh` + `set -eu`), zsh only for shell config. Comments explain *why* a construct is load-bearing, not what it does.
- Commit messages are Conventional Commits (`feat:`, `refactor:`, `chore:`).

## Risks

- No CI and no test suite — `scripts/check.sh` is the only gate, and it is opt-in. Run it before every commit.
- `check.sh` ends in `chezmoi verify`, so it **fails when `$HOME` has drifted**, even if the repo change itself is fine. Read the failure before assuming your edit broke something.
- Template edits are the easiest way to break every new shell on one OS while looking fine on the other. Render both before committing.
- `scripts/check-linux.sh` exits **2** (not 1) when Docker is unavailable — that is "skipped", not "failed".
