#/bin/bash

function macos_requirements() {
  brew install zsh-syntax-hightling
}

echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>$HOME/.zshrc

ln -s $(pwd)/wezterm.lua $HOME/.wezterm.lua
