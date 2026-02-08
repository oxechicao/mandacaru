#!/bin/bash

############################
# Resource measure script
############################

apps=(chrome brave wezterm nvim)
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
