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

installTools() {
	echo -e "\n\033[34mInstalling tools pre-requisites... \033[m\n"
		sleep 1
		while read -r p ; do sudo apt install -y $p ; done < <(cat << "EOF"
		build-essential
		libncurses5-dev 
		libpcap-dev
		git
		jq
EOF
)

	echo -e "\n\033[34mInstalling tools... \033[m\n"
		sleep 1
		while read -r p ; do sudo apt install -y $p ; done < <(cat << "EOF"
		sysstat
		bc
EOF
)

	if [ ! -d "$(pwd)/tmp/" ]
	then
		mkdir $(pwd)/tmp/
	fi


	git -C $(pwd)/tmp/ clone https://github.com/raboof/nethogs >& $(pwd)/tmp/sample.log
	sudo make install -C $(pwd)/tmp/nethogs/ >& $(pwd)/tmp/sample.log
	rm -rf $(pwd)/tmp/
	sudo cp $(pwd)/osiris /usr/local/bin

	echo -e "\n\033[1;32mDone !\033[m\n"
}

# INTEGRATE JUNO INSTALLER FN
# INTEGRATE PATHFINDER INSTALLER FN
# INTEGRATE PAPYRUS INSTALLER FN

main

