#!/bin/bash

set -eu -o pipefail

source ./utils.sh

OSIRIS_PATH=$(dirname $(pwd))
CLIENT_DIR="$OSIRIS_PATH/client"
LOGS_PATH="$OSIRIS_PATH/network/logs.txt"

# Main menu
main() {
	osirisClear
	options=("Papyrus - Starkware" "Quit")
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
	git clone git@github.com:starkware-libs/papyrus.git $CLIENT_DIR &> /dev/null
	sudo docker run -d --rm --name papyrus \
	-p 8080-8081:8080-8081 \
	-v $CLIENT_DIR:/app/data \
	ghcr.io/starkware-libs/papyrus:dev
	sudo docker logs -f papyrus &>> $LOGS_PATH & return
}

installJuno() {
	echo -e "\n\033[34mRunning docker... \033[m"
	sleep 1
	refreshClient
	git clone https://github.com/NethermindEth/juno $CLIENT_DIR &> /dev/null
	sudo docker run -d -it --name juno \
	-p 6060:6060 \
	-v $CLIENT_DIR:/var/lib/juno \
	nethermindeth/juno \
	--rpc-port 6060 \
	--db-path /var/lib/juno
	sudo docker logs -f juno &>> $LOGS_PATH & return
}

installPathfinder() {
	echo -e "\n\033[34mRunning docker... \033[m"
	sleep 1
	refreshClient
	git clone git@github.com:eqlabs/pathfinder.git $CLIENT_DIR &> /dev/null
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
	sudo docker logs -f pathfinder &>> $LOGS_PATH & return
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
	if sudo docker ps -a | grep juno > /dev/null 
	then
		sudo docker rm -f juno > /dev/null
		sudo docker image rm -f nethermindeth/juno > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
	if sudo docker ps -a | grep papyrus > /dev/null
	then
		sudo docker rm -f papyrus > /dev/null
		sudo docker image rm -f ghcr.io/starkware-libs/papyrus:dev > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
	if sudo docker ps -a | grep pathfinder > /dev/null
	then
		sudo docker rm -f pathfinder > /dev/null
		sudo docker image rm -f eqlabs/pathfinder > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
	if [ -d $CLIENT_DIR ]
	then
		rm -rf $CLIENT_DIR
	fi
}
main
echo -e "\n\033[1;32mDone !\033[m\n"
