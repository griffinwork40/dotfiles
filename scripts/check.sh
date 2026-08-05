#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

zsh -n "$repo/private_dot_zshenv"
zsh -n "$repo/dot_zprofile"
zsh -n "$repo/dot_zshrc"
gitleaks dir "$repo" --no-banner --redact --exit-code 1

oversized=$(find "$repo" -type f -not -path '*/.git/*' -exec awk 'FNR == 1 { file=FILENAME } FNR > 350 { print file; nextfile }' {} +)
if [ -n "$oversized" ]; then
  printf '%s\n' "$oversized" >&2
  echo "A source file exceeds the 350-line limit." >&2
  exit 1
fi

chezmoi verify
printf '%s\n' "dotfiles checks passed"
