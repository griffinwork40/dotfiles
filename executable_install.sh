#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# The zsh UX plugins are sourced by absolute path (see dot_zshrc.tmpl), not
# resolved from PATH, so command -v can never detect them. Probe the same
# candidate prefixes the shell config probes, in the same order.
zsh_plugin_present() {
  for candidate in \
    "/opt/homebrew/share/$1/$1.zsh" \
    "/usr/local/share/$1/$1.zsh" \
    "/home/linuxbrew/.linuxbrew/share/$1/$1.zsh" \
    "/usr/share/$1/$1.zsh"
  do
    if [ -r "$candidate" ]; then
      return 0
    fi
  done
  return 1
}

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
    # Optional interactive-shell plugins. dot_zshrc.tmpl skips them silently
    # when absent, which makes a missing package look like a missing feature.
    # Report them here so the gap is visible without failing the bootstrap.
    optional=""
    zsh_plugin_present zsh-autosuggestions ||
      optional="$optional zsh-autosuggestions"
    zsh_plugin_present zsh-syntax-highlighting ||
      optional="$optional zsh-syntax-highlighting"
    if [ -n "$optional" ]; then
      echo "Optional zsh plugins not installed:$optional" >&2
      echo "Without them the shell works but has no inline autosuggestions or syntax highlighting." >&2
    fi
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

chezmoi diff
printf '%s\n' "Review the diff, then run: chezmoi apply"
