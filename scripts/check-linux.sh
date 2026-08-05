#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is unavailable; run scripts/check.sh for deterministic Linux template checks." >&2
  exit 2
fi

docker run --rm -v "$repo:/dotfiles:ro" alpine:3.22 sh -eu -c '
  apk add --no-cache chezmoi gitleaks zsh >/dev/null
  cd /dotfiles
  chezmoi execute-template < dot_zshrc.tmpl > /tmp/zshrc
  chezmoi execute-template < dot_config/ghostty/config.tmpl > /tmp/ghostty
  zsh -n /tmp/zshrc
  grep -q '\''^export PNPM_HOME="$HOME/.local/share/pnpm"$'\'' /tmp/zshrc
  ! grep -q '\''^macos-titlebar-style'\'' /tmp/ghostty
  ./executable_install.sh >/tmp/install-output
'

printf '%s\n' "native Linux checks passed"
