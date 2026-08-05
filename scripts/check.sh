#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-check.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

zsh -n "$repo/private_dot_zshenv"
zsh -n "$repo/dot_zprofile"
sh -n "$repo/executable_install.sh"

chezmoi execute-template < "$repo/dot_zshrc.tmpl" > "$tmp/zshrc-darwin"
chezmoi execute-template < "$repo/dot_config/ghostty/config.tmpl" > "$tmp/ghostty-darwin"
zsh -n "$tmp/zshrc-darwin"
grep -q '^export PNPM_HOME="$HOME/Library/pnpm"$' "$tmp/zshrc-darwin"
grep -q '^macos-titlebar-style = tabs$' "$tmp/ghostty-darwin"

linux_data='{"chezmoi":{"os":"linux"}}'
chezmoi execute-template --override-data "$linux_data" < "$repo/dot_zshrc.tmpl" > "$tmp/zshrc-linux"
chezmoi execute-template --override-data "$linux_data" < "$repo/dot_config/ghostty/config.tmpl" > "$tmp/ghostty-linux"
zsh -n "$tmp/zshrc-linux"
grep -q '^export PNPM_HOME="$HOME/.local/share/pnpm"$' "$tmp/zshrc-linux"
if grep -q '^macos-titlebar-style' "$tmp/ghostty-linux"; then
  echo "Linux Ghostty render contains a macOS-only setting." >&2
  exit 1
fi

gitleaks dir "$repo" --no-banner --redact --exit-code 1

oversized=$(find "$repo" -type f -not -path '*/.git/*' -exec awk 'FNR == 1 { file=FILENAME } FNR > 350 { print file; nextfile }' {} +)
if [ -n "$oversized" ]; then
  printf '%s\n' "$oversized" >&2
  echo "A source file exceeds the 350-line limit." >&2
  exit 1
fi

chezmoi verify
printf '%s\n' "dotfiles checks passed"
