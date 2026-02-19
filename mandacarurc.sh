#!/bin/bash

apps=(tmux chrome brave wezterm nvim intellij idea)

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

function cpu_app() {
  app=$1
  ps -eo pcpu,command | grep -i $app | awk '{p=$1 ; sum +=p} END {print sum "%"}'
}

function mem_app() {
  app=$1
  ps -eo rss,command | grep -i $app | awk '{m=$1 ; sum +=m} END {print sum/1024 " MB"}'
}

function resource_app() {
  app=$1
  cpu=$(cpu_app $app)
  mem=$(mem_app $app)
  echo "$app|$cpu|$mem"
}

function generate_report() {
  echo "App|CPU|Mem"
  for app in "${apps[@]}"; do
    resource_app "$app"
  done
}

function consume_apps() {
  generate_report | column -s '|' -t
}

function wca() {
  time=$1
  while true; do
    clear
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
