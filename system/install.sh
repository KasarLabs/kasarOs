#!/bin/bash

set -eu -o pipefail
sudo -n true
test $? -eq 0 || exit 1 "You should have sudo privilege to run this script."

source ./utils.sh

# Main menu
main() {
    osirisClear
    options=("Payrus - Starkware" "Juno - Nethermind" "Pathfinder - Equilibrium" "Quit")
    yesOrNo=("Yes" "No" "Quit")
  	if [ -f "/usr/local/bin/osiris" ]
	then
		print_menu "Hi again 👋 myOsiris already installed!" "Do you want to install another client?" "${yesOrNo[@]}"
	else
		print_menu "Welcome to myOsiris! 👋" "Please chose the client you'd like to install" "${options[@]}"
	fi
}

juno() {
	# installTools
	git clone https://github.com/NethermindEth/juno ../client/
	cd ../client/
	# bash go.sh
	make juno
	go build
	go ./build/juno
}

juno

