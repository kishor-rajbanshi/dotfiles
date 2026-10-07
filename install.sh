#!/bin/sh
# Usage: ./install.sh [target ...]
# No arguments = install everything.
# Targets: brew terminal vscode stats ghostty ssh rm oh-my-posh aliases qrcode
#          zsh-completions fzf fzf-tab zoxide zsh-autosuggestions zsh-syntax-highlighting
set -eu

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"
RM=/bin/rm # absolute path: the dotfiles `rm` wrapper may shadow `rm` once installed
TARGETS="brew terminal vscode stats ghostty ssh rm oh-my-posh aliases qrcode zsh-completions fzf fzf-tab zoxide zsh-autosuggestions zsh-syntax-highlighting"

# Lines in this order are kept at the end of ~/.zshrc, whatever order targets are installed in.
ZSH_ORDER='FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
autoload -Uz compinit
compinit
source <(fzf --zsh)
source $(brew --prefix)/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh
eval "$(zoxide init zsh)"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "run as your normal user, not root; sudo is requested automatically when needed"
[ -d "$DOTFILES" ] || die "$DOTFILES not found"

# ---------- helpers ----------

SUDO_READY=""
KEEPALIVE_PID=""
need_sudo() {
  if [ -z "$SUDO_READY" ]; then
    log "sudo required"
    sudo -v || die "sudo authentication failed"
    ( while :; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit 0; done ) &
    KEEPALIVE_PID=$!
    SUDO_READY=1
  fi
}
trap '[ -z "$KEEPALIVE_PID" ] || kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT INT TERM

need_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [ -x "$b" ] && eval "$("$b" shellenv)" && break
    done
  fi
  if ! command -v brew >/dev/null 2>&1; then
    log "installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [ -x "$b" ] && eval "$("$b" shellenv)" && break
    done
  fi
  command -v brew >/dev/null 2>&1 || die "brew not available"
}

need_code() {
  if ! command -v code >/dev/null 2>&1; then
    PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  fi
  command -v code >/dev/null 2>&1 || die "'code' CLI not found (install VS Code first: ./install.sh brew)"
}

add_line() { # add_line FILE LINE (idempotent)
  touch "$1"
  grep -qxF -- "$2" "$1" || printf '%s\n' "$2" >> "$1"
}

zsh_add() { # add to ~/.zshrc, then restore the required order
  add_line "$ZSHRC" "$1"
  printf '%s\n' "$ZSH_ORDER" | while IFS= read -r l; do
    grep -qxF -- "$l" "$ZSHRC" || continue
    grep -vxF -- "$l" "$ZSHRC" > "$ZSHRC.tmp" || true
    cat "$ZSHRC.tmp" > "$ZSHRC"
    "$RM" -f "$ZSHRC.tmp"
    printf '%s\n' "$l" >> "$ZSHRC"
  done
}

# ---------- targets ----------

t_brew() {
  need_brew
  log "brew bundle"
  brew bundle --file "$DOTFILES/homebrew/Brewfile"
}

t_terminal() {
  log "Terminal profile"
  open "$DOTFILES/terminal/Pitch Black.terminal"
  sleep 1
  defaults write com.apple.Terminal "Default Window Settings" -string "Pitch Black"
  defaults write com.apple.Terminal "Startup Window Settings" -string "Pitch Black"
}

t_vscode() {
  need_code
  log "VS Code"
  U="$HOME/Library/Application Support/Code/User"
  mkdir -p "$U"
  ln -sfn "$DOTFILES/vscode/settings.json"    "$U/settings.json"
  ln -sfn "$DOTFILES/vscode/keybindings.json" "$U/keybindings.json"
  ln -sfn "$DOTFILES/vscode/mcp.json"         "$U/mcp.json"
  ln -sfn "$DOTFILES/vscode/snippets"         "$U/snippets"
  xargs -n1 code --install-extension < "$DOTFILES/vscode/extensions.txt"
}

t_stats() {
  log "Stats"
  osascript -e 'quit app "Stats"' 2>/dev/null || true
  defaults import eu.exelban.Stats "$DOTFILES/stats/eu.exelban.Stats.plist"
  sleep 1
  open -a Stats
}

t_ghostty() {
  log "Ghostty"
  mkdir -p "$HOME/.config/ghostty"
  ln -sfn "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
}

t_ssh() {
  log "SSH"
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ln -sfn "$DOTFILES/ssh/config" "$HOME/.ssh/config"
}

t_rm() {
  log "rm wrapper"
  need_sudo
  sudo mkdir -p /usr/local/bin
  sudo ln -sfn "$DOTFILES/bin/rm" /usr/local/bin/rm
}

t_oh_my_posh() {
  log "Oh My Posh"
  add_line "$ZSHRC"  'eval "$(oh-my-posh init zsh --config ~/dotfiles/oh-my-posh/config.json)"'
  add_line "$BASHRC" 'eval "$(oh-my-posh init bash --config ~/dotfiles/oh-my-posh/config.json)"'
}

t_aliases() {
  log "aliases"
  add_line "$ZSHRC"  'source ~/dotfiles/aliases/aliases'
  add_line "$ZSHRC"  'source ~/dotfiles/aliases/zsh_completions'
  add_line "$BASHRC" 'source ~/dotfiles/aliases/aliases'
  add_line "$BASHRC" 'source ~/dotfiles/aliases/bash_completions'
}

t_qrcode() {
  log "qrcode"
  add_line "$ZSHRC"  'source ~/dotfiles/functions/qrcode'
  add_line "$BASHRC" 'source ~/dotfiles/functions/qrcode'
}

t_zsh_completions() {
  need_brew
  log "zsh-completions"
  P="$(brew --prefix)"
  if ! { chmod go-w "$P/share" && chmod -R go-w "$P/share/zsh"; } 2>/dev/null; then
    need_sudo
    sudo chmod go-w "$P/share"
    sudo chmod -R go-w "$P/share/zsh"
  fi
  zsh_add 'FPATH=$(brew --prefix)/share/zsh-completions:$FPATH'
  zsh_add 'autoload -Uz compinit'
  zsh_add 'compinit'
  "$RM" -f "$HOME"/.zcompdump*
}

t_fzf() {
  log "fzf"
  zsh_add 'source <(fzf --zsh)'
  add_line "$BASHRC" 'eval "$(fzf --bash)"'
}

t_fzf_tab() {
  log "fzf-tab"
  zsh_add 'source $(brew --prefix)/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh'
}

t_zoxide() {
  log "zoxide"
  zsh_add 'eval "$(zoxide init zsh)"'
  add_line "$BASHRC" 'eval "$(zoxide init bash)"'
}

t_zsh_autosuggestions() {
  log "zsh-autosuggestions"
  zsh_add 'source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
}

t_zsh_syntax_highlighting() {
  log "zsh-syntax-highlighting"
  zsh_add 'source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
}

# ---------- main ----------

[ "$#" -gt 0 ] || set -- $TARGETS

for t in "$@"; do
  case " $TARGETS " in
    *" $t "*) ;;
    *) die "unknown target '$t' (available: $TARGETS)" ;;
  esac
done

# Ask for the sudo password up front so the run isn't interrupted midway.
for t in "$@"; do
  [ "$t" = rm ] && need_sudo
done

for t in "$@"; do
  "t_$(printf '%s' "$t" | tr - _)"
done

log "done"
