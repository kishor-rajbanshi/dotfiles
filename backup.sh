#!/bin/sh
# Usage: ./backup.sh [target ...]
# No arguments = back up everything.
# Targets: brew vscode stats
set -eu

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
TARGETS="brew vscode stats"

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ -d "$DOTFILES" ] || die "$DOTFILES not found"

b_brew() {
  command -v brew >/dev/null 2>&1 || die "brew not found"
  log "Brewfile"
  brew bundle dump --force --file "$DOTFILES/homebrew/Brewfile"
}

b_vscode() {
  if ! command -v code >/dev/null 2>&1; then
    PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  fi
  command -v code >/dev/null 2>&1 || die "'code' CLI not found"
  log "VS Code extensions"
  code --list-extensions > "$DOTFILES/vscode/extensions.txt"
}

b_stats() {
  log "Stats settings"
  defaults export eu.exelban.Stats "$DOTFILES/stats/eu.exelban.Stats.plist"
  plutil -convert xml1 "$DOTFILES/stats/eu.exelban.Stats.plist"
}

[ "$#" -gt 0 ] || set -- $TARGETS

for t in "$@"; do
  case " $TARGETS " in
    *" $t "*) ;;
    *) die "unknown target '$t' (available: $TARGETS)" ;;
  esac
done

for t in "$@"; do
  "b_$t"
done

log "done"
