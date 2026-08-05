#!/bin/sh
set -eu

if ! command -v brew >/dev/null 2>&1; then
  echo "Install Homebrew first: https://brew.sh" >&2
  exit 1
fi

brew install chezmoi gitleaks
brew bundle --file="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/Brewfile"
chezmoi diff
printf '%s\n' "Review the diff, then run: chezmoi apply"
