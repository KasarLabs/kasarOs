#!/bin/bash

set -eu -o pipefail
sudo -n true
test $? -eq 0 || exit 1 "You should have sudo privilege to run this script."

source ./utils.sh

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
	if [ -d "../client" ]
	then
		rm -rf $HOME/.client_data
		rm -rf ../client
	fi
	git clone git@github.com:starkware-libs/papyrus.git ../client &> /dev/null
	mkdir -p $HOME/.client_data/.papyrus
	sudo docker run -d --rm --name papyrus\
  	-p 8080-8081:8080-8081 \
  	-v $HOME/.client_data/.papyrus:/app/data \
  	ghcr.io/starkware-libs/papyrus:dev
	echo -e "\n\033[1;32mDone !\033[m\n"
}

installJuno() {
	if [ -d "../client" ]
	then
		rm -rf $HOME/.client_data
		rm -rf ../client
	fi
	git clone https://github.com/NethermindEth/juno ../client &> /dev/null
	mkdir -p $HOME/.client_data/juno
	sudo docker run -d -it \
	-p 6060:6060 \
	-v $HOME/.client_data/juno:/var/lib/juno \
	nethermindeth/juno \
	--rpc-port 6060 \
 	--db-path /var/lib/juno
	echo -e "\n\033[1;32mDone !\033[m\n"
}

installPathfinder() {
	if [ -d "../client" ]
	then
		rm -rf $HOME/.client_data
		rm -rf ../client
	fi
	git clone https://github.com/NethermindEth/juno ../client &> /dev/nul
	mkdir -p $HOME/.client_data/.pathfinder
	sudo docker run \
	--name pathfinder \
	--restart unless-stopped \
	--detach \
	-p 9545:9545 \
	--user "$(id -u):$(id -g)" \
	-e RUST_LOG=info \
	-e PATHFINDER_ETHEREUM_API_URL="https://goerli.infura.io/v3/<project-id>" \
	-v $HOME/.client_data/pathfinder:/usr/share/pathfinder/data \
	eqlabs/pathfinder
	echo -e "\n\033[1;32mDone !\033[m\n"
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
	
	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
	rm get-docker.sh
}
main
