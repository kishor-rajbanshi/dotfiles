# Dotfiles

My dotfiles.

## Clone

```sh
git clone https://github.com/kishor-rajbanshi/dotfiles.git ~/dotfiles
```

## Homebrew

### Install packages

```sh
brew bundle --file ~/dotfiles/homebrew/Brewfile
```

### Export packages

```sh
brew bundle dump --force --file ~/dotfiles/homebrew/Brewfile
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
mkdir -p "$U"

ln -sfn ~/dotfiles/vscode/settings.json    "$U/settings.json"
ln -sfn ~/dotfiles/vscode/keybindings.json "$U/keybindings.json"
ln -sfn ~/dotfiles/vscode/mcp.json        "$U/mcp.json"
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

## Stats

### Import settings

```sh
osascript -e 'quit app "Stats"'
defaults import eu.exelban.Stats ~/dotfiles/stats/eu.exelban.Stats.plist
sleep 1 && open -a Stats
```

### Export settings

```sh
defaults export eu.exelban.Stats ~/dotfiles/stats/eu.exelban.Stats.plist
plutil -convert xml1 ~/dotfiles/stats/eu.exelban.Stats.plist
```

## Ghostty

### Symlink

```sh
mkdir -p ~/.config/ghostty
ln -sfn ~/dotfiles/ghostty/config ~/.config/ghostty/config
```

## SSH

### Symlink

```sh
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ln -sfn ~/dotfiles/ssh/config ~/.ssh/config
```

## rm (wrapper)

### Symlink

```sh
sudo mkdir -p /usr/local/bin/
sudo ln -sfn ~/dotfiles/bin/rm /usr/local/bin/rm
```

## Oh My Posh

### Initialize

zsh

```sh
echo 'eval "$(oh-my-posh init zsh --config ~/dotfiles/oh-my-posh/config.json)"' >> ~/.zshrc
```

bash

```sh
echo 'eval "$(oh-my-posh init bash --config ~/dotfiles/oh-my-posh/config.json)"' >> ~/.bashrc
```

## Aliases

### Source

zsh

```sh
echo 'source ~/dotfiles/aliases/aliases' >> ~/.zshrc
echo 'source ~/dotfiles/aliases/zsh_completions' >> ~/.zshrc
```

bash

```sh
echo 'source ~/dotfiles/aliases/aliases' >> ~/.bashrc
echo 'source ~/dotfiles/aliases/bash_completions' >> ~/.bashrc
```

## zsh-completions

### Initialize

zsh

```sh
chmod go-w "$(brew --prefix)/share"
chmod -R go-w "$(brew --prefix)/share/zsh"
echo 'FPATH=$(brew --prefix)/share/zsh-completions:$FPATH' >> ~/.zshrc
echo 'autoload -Uz compinit' >> ~/.zshrc
echo 'compinit' >> ~/.zshrc
rm -f ~/.zcompdump* && exec zsh
```

## fzf

### Initialize

zsh

```sh
echo 'source <(fzf --zsh)' >> ~/.zshrc
```

bash

```sh
echo 'eval "$(fzf --bash)"' >> ~/.bashrc
```

## fzf-tab

### Source

zsh

```sh
echo 'source $(brew --prefix)/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh' >> ~/.zshrc
```

## zoxide

### Initialize

zsh

```sh
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
```

bash

```sh
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
```

## zsh-autosuggestions

### Source

zsh

```sh
echo 'source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
```

## zsh-syntax-highlighting

### Source

zsh

```sh
echo 'source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
```

## Notes

### rc order (zsh)

Lines appended to `~/.zshrc` must follow this order:

1. zsh-completions (`compinit`)
2. fzf, fzf-tab, zoxide
3. zsh-autosuggestions
4. zsh-syntax-highlighting (always last)
