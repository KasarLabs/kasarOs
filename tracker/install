#!/bin/bash

set -eu -o pipefail
sudo -n true
test $? -eq 0 || exit 1 "You should have sudo privilege to run this script."

echo -e "\n"
echo -e "\e[1;33m⠐⢤⣀⣀⡀⠀⠀⠀⢀⣀⣀⣀⣀⣠⣤⣤⣤⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⠀⠀\e[0m"
echo -e "\e[1;33m⡄⠀⠈⠛⠿⢿⡿⠟⠛⠛⠛⠛⠛⠛⠛⠉⠉⠉⠉⠉⠁⠀⠀⠈⠉⠉⠛⠻⡇⠀\e[0m"
echo -e "\e[1;33m⢹⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣶⣶⣶⣶⣦⣄⠀⠀⠀⠁⠀\e[0m"
echo -e "\e[1;33m⠀⢻⣿⣿⣶⣶⣦⣤⣤⣤⣤⣤⣶⣾⣿⣿⠿⠛⢋⣿⣿⣿⣿⡛⢿⣷⣄⠀⠀⠀\e[0m"
echo -e "\e[1;33m⠀⠀⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣭⣁⡀⠀⠀⠸⣿⣿⣿⣿⠇⠀⣘⣿⣿⣦⡄ \t\t\033[1;33mOsiris v1.0"
echo -e "\e[1;33m⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠿⢿⣿⣿⣶⣶⣿⣿⣿⣿⣶⣿⣿⡿⠿⠿⣇    \t\033[1;35mBy Kasar Labs"
echo -e "\e[1;33m⠀⠀⠀⠀⠀⠀⠐⣶⣤⡀⠀⠀⠀⠀⠀⠀⠉⠙⠛⣻⣿⣿⣿⡟⠉⠀⠀⠀⠀⠀\e[0m"
echo -e "\e[1;33m⠀⠀⠀⠀⢀⣶⡿⠿⢿⣿⡆⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⢿⣿⡅⢸⠀⠀⠀⠀⠀\e[0m"
echo -e "\e[1;33m⠀⠀⠀⠀⣿⡏⠀⠀⠀⢹⠇⠀⠀⠀⢀⣠⣾⣿⡿⠋⠁⢸⣿⣿⡟⠀⠀⠀⠀⠀\e[0m"
echo -e "\e[1;33m⠀⠀⠀⠀⢿⣷⡀⠀⠔⠋⢀⣀⣤⣶⣿⡿⠛⠁⠀⠀⠀⢸⣿⡟⠀⠀⠀⠀⠀⠀\e[0m"
echo -e "\e[1;33m⠀⠀⠀⠀⠀⠙⠿⠿⣿⣿⡿⠿⠟⠋⠁⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀\e[0m"
echo -e "\e[1;33m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠀⠀⠀⠀⠀⠀⠀\e[0m"
echo -e "\e[1;33m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⠿⠆⠀⠀⠀⠀⠀⠀\e[0m"

if [ -f "/usr/local/bin/osiris" ]
then
	echo -e "\n\t\033[1;32mOsiris already installed !\033[m\n\n"
	exit 1
fi

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
