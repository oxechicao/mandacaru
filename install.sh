#/bin/bash

function macos_requirements() {
  brew install zsh-syntax-hightling tmux wezterm nvim
}

function install_deps() {
  echo "Installing dependencies"
  macos_requirements
  echo "Adding zsh-syntax-highlighting to .zshrc"
  echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>$HOME/.zshrc
}

function setup_wez() {
  echo "Setup Wezterm conf"
  mv $HOME/.wezterm.lua{,.mandacaru_bkp}
  ln -s $(pwd)/wezterm.lua $HOME/.wezterm.lua
}

function setup_tmux() {
  echo "Setup Tmux conf"
  mv $HOME/.temux.conf{,.mandacaru_bkp}
  ln -s $(pwd)/temux.conf $HOME/.tmux.conf
}

function setup_git() {
  echo "Setup git config global"
  git config --global core.editor "nvim"
}

function setup_lazyvim() {
  echo "Initializin submodules"
  git submodule init
  git submodule update
  echo "Setup nvim with lazyvim" mv $HOME/.config/nvim{,.mandacaru_bkp}
  ln -s $(pwd)/lazyvim $HOME/.config/nvim
}

function setup_mandacarurc() {
  echo "source $(pwd)/mandacarurc.sh" >>$HOME/.zshrc
}

function install_everything() {
  install_deps
  setup_wez
  setup_tmux
  setup_git
  setup_lazyvim
  setup_mandacarurc
}

option=$1

case $option in
"0")
  setup_everything
  ;;
"1")
  install_deps
  ;;
"2")
  setup_wez
  ;;
"3")
  setup_tmux
  ;;
"4")
  setup_git
  ;;
"5")
  setup_lazyvim
  ;;
"6")
  setup_mandacarurc
  ;;
*)
  echo "0 - Install everything"
  echo "1 - Install dependencies"
  echo "2 - Setup Wezterm"
  echo "3 - Setup Tmux"
  echo "4 - Setup Git"
  echo "5 - Setup LazyVim"
  echo "6 - Setup Mandacarurc"
  ;;
esac
