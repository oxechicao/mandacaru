#!/bin/bash

############################
# Settings
############################

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(starship init zsh)"

apps=(chrome brave alacritty tmux wezterm nvim intellij idea)

############################
# Reload settings
############################

function tf5() {
  if [ -n "$TMUX" ]; then
    echo "You are in a tmux session."
  else
    echo "You are NOT in a tmux session."
    exit 1
  fi

  echo "Refesh tmux config"
  tmux source $HOME/.tmux.conf
}

function f5() {
  source $HOME/.zshrc
}

############################
# Resource measure script
############################

ps_sum_by_app() {
  local app="$1"
  ps aux | awk -v app="$app" '
      BEGIN { IGNORECASE=1 }
      NR > 1 && index(tolower($0), tolower(app)) > 0 {
        cpu += $3
        mem += $4
        rss += $6
        n++
      }
      END {
        printf "%s|%d|%.2f|%.2f|%d|%.1f\n", app, n, cpu, mem, rss, rss/1024
      }
    '
}

# Call ps_sum_by_app for one or more apps and print a table
ps_sum_table() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: ps_sum_table <app1> [app2 ...]"
    return 1
  fi

  {
    echo "APP|PROCS|CPU_%|MEM_%|RSS_KB|RSS_MB"
    local app
    for app in "$@"; do
      ps_sum_by_app "$app"
    done
  } | column -s '|' -t
}

function consume_apps() {
  ps_sum_table "${apps[@]}"
}

function wca() {
  time=$1
  while true; do
    consume_apps
    sleep $1
  done
}

############################
# Setup local environments
############################

function config_git() {
  git config user.name "Chicão Thiago"
  git config user.email "fthiagogv+github@gmail.com"
}

function mandacaru_sm_up() {
  echo "Updating lazyvim submodule..."
  dir=$(pwd)
  msg=$1
  git add .
  git commit -m "$msg"
  git push origin main
  cd ..
  git add .
  git commit -m "submodule update: $msg"
  git push origin main
  cd $dir
}

##########################
# Alias function
##########################

function nv() {
  args="${@:1}"
  if [ -z "$args" ]; then
    nvim $(pwd)
  else
    nvim $args
  fi
}

function lpy() {
  eval "$(pyenv init - zsh)"
}
