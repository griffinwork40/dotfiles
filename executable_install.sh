#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "Install Homebrew first: https://brew.sh" >&2
      exit 1
    fi
    brew install chezmoi gitleaks
    brew bundle --file="$repo/Brewfile"
    ;;
  Linux)
    missing=""
    command -v chezmoi >/dev/null 2>&1 || missing="$missing chezmoi"
    command -v gitleaks >/dev/null 2>&1 || missing="$missing gitleaks"
    if [ -n "$missing" ]; then
      echo "Install the following with your distribution package manager or Homebrew:$missing" >&2
      exit 1
    fi
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

chezmoi diff
printf '%s\n' "Review the diff, then run: chezmoi apply"
