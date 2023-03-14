#!/bin/bash

# Define colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
reset='\033[0m'

# Clear + Banner

osirisClear() {
    clear
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
}

# Define options and default selected option
selected=0

# Function to print the menu
print_menu() {
    osirisClear
    local message=$1
    local question=$2
    shift 2
    local options=("${@}")
    echo -e "\n\n${message}"
    echo -e "${question}\n"
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "${red}➡️  ${options[$i]}${reset}"
        else
            echo -e "${yellow}   ${options[$i]}${reset}"
        fi
    done

    # Loop for user input
    while true; do
        read -sn1 input
        case $input in
            A) # Up arrow
                selected=$((selected-1))
                if [ $selected -lt 0 ]; then
                    selected=$((${#options[@]}-1))
                fi
                print_menu "${message}" "${question}" "${options[@]}"
                ;;
            B) # Down arrow
                selected=$((selected+1))
                if [ $selected -ge ${#options[@]} ]; then
                    selected=0
                fi
                print_menu "${message}" "${question}" "${options[@]}"
                ;;
            "") # Enter key
                osirisClear
                if [ "${options[$selected]}" = "Quit" ]; then
                    echo "See you soon!"
                else
                    echo "You selected ${options[$selected]}"
                fi
                break
                ;;
        esac
    done
    return ${selected}
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
