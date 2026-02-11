#/bin/bash

function macos_requirements() {
  brew install zsh-syntax-hightling tmux wezterm nvim
}

echo "Installing dependencies"
macos_requirements

echo "Adding zsh-syntax-highlighting to .zshrc"
echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>$HOME/.zshrc

echo "Setup Wezterm conf"
mv $HOME/.wezterm.lua{,.mandacaru_bkp}
ln -s $(pwd)/wezterm.lua $HOME/.wezterm.lua

echo "Setup Tmux conf"
mv $HOME/.temux.conf{,.mandacaru_bkp}
ln -s $(pwd)/temux.conf $HOME/.tmux.conf

echo "Setup git config global"
git config --global core.editor "nvim"

echo "Initializin submodules"
git submodule init
git submodule update

echo "Setup nvim with lazyvim"
mv $HOME/.config/nvim{,.mandacaru_bkp}
ln -s $(pwd)/lazyvim $HOME/.config/nvim
