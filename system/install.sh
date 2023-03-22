#!/bin/bash

set -eu -o pipefail
sudo -n true
test $? -eq 0 || exit 1 "You should have sudo privilege to run this script."

source ./utils.sh

OSIRIS_PATH=$(dirname $(pwd))
CLIENT_NAME="client"
CLIENT_DIR="$OSIRIS_PATH/$CLIENT_NAME"

# Main menu
main() {
	osirisClear
	options=("Papyrus - Starkware" "Juno - Nethermind" "Pathfinder - Equilibrium" "Quit")
	yesOrNo=("Yes" "No" "Quit")
	if [ -f "/usr/local/bin/osiris" ]
	then
		print_menu "Hi again, myOsiris already installed!" "Do you want to install another client?" "${yesOrNo[@]}"
	else
		print_menu "Welcome to myOsiris!" "Please chose the client you'd like to install" "${options[@]}"
	fi

	if [ "${options[$selected]}" = "Papyrus - Starkware" ]; then
		installTools
		installPapyrus
	elif [ "${options[$selected]}" = "Juno - Nethermind" ]; then
		installTools
		installJuno
	elif [ "${options[$selected]}" = "Pathfinder - Equilibrium" ]; then
		installTools
		installPathfinder
	fi
}

installPapyrus() {
	echo -e "\n\033[34mRunning docker... \033[m"
	sleep 1
	refreshClient
	git clone git@github.com:starkware-libs/papyrus.git ../client &> /dev/null
	sudo docker run -d --rm --name papyrus\
  	-p 8080-8081:8080-8081 \
  	-v $CLIENT_DIR:/app/data \
  	ghcr.io/starkware-libs/papyrus:dev > /dev/null
}

installJuno() {
	echo -e "\n\033[34mRunning docker... \033[m"
	sleep 1
	refreshClient
	git clone https://github.com/NethermindEth/juno ../client &> /dev/null
	sudo docker run -d -it \
	-p 6060:6060 \
	-v $CLIENT_DIR:/var/lib/juno \
	nethermindeth/juno \
	--rpc-port 6060 \
 	--db-path /var/lib/juno > /dev/null
}

installPathfinder() {
	echo -e "\n\033[34mRunning docker... \033[m"
	sleep 1
	refreshClient
	git clone https://github.com/NethermindEth/juno ../client &> /dev/nul
	sudo docker run \
	--name pathfinder \
	--restart unless-stopped \
	--detach \
	-p 9545:9545 \
	--user "$(id -u):$(id -g)" \
	-e RUST_LOG=info \
	-e PATHFINDER_ETHEREUM_API_URL="https://goerli.infura.io/v3/<project-id>" \
	-v $CLIENT_DIR:/usr/share/pathfinder/data \
	eqlabs/pathfinder > /dev/null
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
}

refreshClient()
{
	if sudo docker ps | grep juno > /dev/null 
	then
		sudo docker stop juno > /dev/null
	fi
	if sudo docker ps | grep papyrus > /dev/null
	then
		sudo docker stop papyrus > /dev/null
	fi
	if sudo docker ps | grep pathfinder > /dev/null
	then
		sudo docker stop pathfinder > /dev/null
	fi	
	if [ -d $CLIENT_DIR ]
	then
		rm -rf $CLIENT_DIR
	fi
}
main
echo -e "\n\033[1;32mDone !\033[m\n"
