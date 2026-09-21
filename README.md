# Dotfiles

My dotfiles.

## Clone

```sh
git clone https://github.com/kishor-rajbanshi/dotfiles.git ~/dotfiles
```

## Terminal

### Import profile

```sh
open ~/dotfiles/terminal/"Pitch Black.terminal"
```

### Set as default

```sh
defaults write com.apple.Terminal "Default Window Settings" -string "Pitch Black"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pitch Black"
```

## VS Code

### Symlink

```sh
U=~/"Library/Application Support/Code/User"

ln -sf ~/dotfiles/vscode/settings.json    "$U/settings.json"
ln -sf ~/dotfiles/vscode/keybindings.json "$U/keybindings.json"
ln -sf ~/dotfiles/vscode/mcp.json        "$U/mcp.json"
ln -sfn ~/dotfiles/vscode/snippets        "$U/snippets"
```

### Install extensions

```sh
xargs -n1 code --install-extension < ~/dotfiles/vscode/extensions.txt
```

### Export extensions

```sh
code --list-extensions > ~/dotfiles/vscode/extensions.txt
```
