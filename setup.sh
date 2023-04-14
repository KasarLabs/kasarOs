#!/bin/bash

set -eu -o pipefail

OSIRIS_PATH=$(pwd)
CLIENT_DIR="$OSIRIS_PATH/client"
LOGS_PATH="$OSIRIS_PATH/network/logs.txt"
TRACK_MODE=false

check_track() {
    echo "$@"
    for arg in "$@"
    do
        case $arg in
            --track)
                TRACK_MODE=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Utils
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
    echo -e "\e[1;33m⠀⠀⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣭⣁⡀⠀⠀⠸⣿⣿⣿⣿⠇⠀⣘⣿⣿⣦⡄ \t\t\033[1;33mOsiris v0.1.0-beta.1"
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
    local message=$1
    local question=$2
    shift 2
    local options=("${@}")

    while true; do
        osirisClear
        echo -e "\n\n${message}"
        echo -e "${question}\n"
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "${red}>  ${options[$i]}${reset}"
            else
                echo -e "${yellow}   ${options[$i]}${reset}"
            fi
        done

        # Loop for user input
        read -sn1 input
        case $input in
            A) # Up arrow
                selected=$((selected-1))
                if [ $selected -lt 0 ]; then
                    selected=$((${#options[@]}-1))
                fi
                ;;
            B) # Down arrow
                selected=$((selected+1))
                if [ $selected -ge ${#options[@]} ]; then
                    selected=0
                fi
                ;;
            "") # Enter key
                osirisClear
                if [ "${options[$selected]}" = "Quit" ]; then
                    echo -e "\nSee you soon!"
                    exit
                else
                    echo -e "\nYou selected ${options[$selected]}\n"
                fi
                break
                ;;
        esac
    done
}

getClient() {
	if sudo docker ps -a | grep juno > /dev/null
	then
		node_docker="juno"
	elif sudo docker ps -a | grep papyrus > /dev/null
	then
		node_docker="papyrus"
	elif sudo docker ps -a | grep pathfinder > /dev/null
	then
		node_docker="pathfinder"
    elif sudo docker ps -a | grep geth > /dev/null
	then
		node_docker="geth"
	else
		node_docker="null"
	fi
}

menu_installer() {
    reset
    osirisClear
    options=("Track" "Stop" "Restart" "Delete" "Quit")
    yesOrNo=("Yes" "No" "Quit")
    selected=0 # Initialize the selected variable
    print_menu "Welcome back to myOsiris!" "A client has been detected on this machine. Please chose your option!" "${options[@]}"

    if [ "${options[$selected]}" = "Track" ]; then
        osirisClear
        echo -e -n "\n${red}Tracking view mode will exit in 10secs${reset}\n"
        client=$(jq -r '.client' config.json)
        if sudo docker exec $client pgrep $client > /dev/null; then
            sudo docker logs -f $client &>> $LOGS_PATH & nohup ./myOsiris&
            sleep 2
        fi
        timeout 10s tail -f nohup.out
    fi
    if [ "${options[$selected]}" = "Stop" ]; then
        osirisClear
        sudo docker stop ${node_docker} > /dev/null
        echo -e "\nNode stoped.\n"
        exit
    fi
    if [ "${options[$selected]}" = "Restart" ]; then
        osirisClear
        sudo docker start ${node_docker} > /dev/null
        echo -e "\nNode started.\n"
        exit
    fi
    if [ "${options[$selected]}" = "Delete" ]; then
        osirisClear
        echo -e "\nNode deleted.\n"
        refreshClient
        exit
    fi
}

menu_running() {
    osirisClear
    options=("Ethereum" "Starknet" "Taiko" "Quit")
    yesOrNo=("Yes" "No" "Quit")
    selected=0 # Initialize the selected variable
    print_menu "Welcome to myOsiris!" "Please chose a blockchain you'd like to setup" "${options[@]}"

    if [ "${options[$selected]}" = "Starknet" ]; then
        menu_starknet
    elif [ "${options[$selected]}" = "Taiko" ]; then
        installTools
        installTaiko
    elif [ "${options[$selected]}" = "Ethereum" ]; then
        installTools
        installGeth
    fi
}

menu_starknet() {
    osirisClear
    options=("Papyrus - Starkware" "Pathfinder - Equilibrium" "Juno - Nethermind" "Quit")
    yesOrNo=("Yes" "No" "Quit")
    selected=0 # Initialize the selected variable
    print_menu "You selected Starknet" "Please chose the client you'd like to install" "${options[@]}"
    # Prompt for node name, rpc_key, and osiris_key
    echo -e -n "${yellow}> Enter a name for your node:${reset} "
    read node_name
    echo -e -n "${yellow}> Enter your Ethereum RPC url:${reset} "
    read rpc_key
    echo -e -n "${yellow}> Enter your Osiris key:${reset} "
    read osiris_key

    # Create a JSON object and store it in config.json
    if [ "${options[$selected]}" = "Papyrus - Starkware" ]; then
        client="papyrus"
        installTools
        installPapyrus
    elif [ "${options[$selected]}" = "Juno - Nethermind" ]; then
        client="juno"
        installTools
        installJuno
    elif [ "${options[$selected]}" = "Pathfinder - Equilibrium" ]; then
        client="pathfinder"
        installTools
        installPathfinder
    fi
    echo "{\"name\": \"${node_name}\", \"client\": \"${client}\", \"rpc_key\": \"${rpc_key}\", \"osiris_key\": \"${osiris_key}\"}" > config.json    
}

main(){
    check_track "$@"
    getClient
    if [ "${node_docker}" = "null" ]; then
        menu_running
    else
        menu_installer
    fi
}

installPapyrus() {
    osirisClear
    echo -e "\n\033[34mCloning and running docker... \033[m"
    sleep 1
    refreshClient
    git clone git@github.com:starkware-libs/papyrus.git $CLIENT_DIR
    sudo docker run -d --rm --name papyrus \
        -p 8080-8081:8080-8081 \
        -v $CLIENT_DIR:/app/data \
        ghcr.io/starkware-libs/papyrus:dev
    # Wait for the Papyrus client to start
    osirisClear
    echo -e "\n\033[34mWaiting for Papyrus client to start... \033[m"
    while ! sudo docker exec papyrus pgrep papyrus > /dev/null; do sleep 1; done
    echo "{\"name\": \"${node_name}\", \"client\": \"${client}\", \"rpc_key\": \"${rpc_key}\", \"osiris_key\": \"${osiris_key}\"}" > config.json    
    go build
    echo -e "\n\033[32m$(cat ./config.json | jq -r '.name') full node is running correctly using Papyrus client!\033[m"
    echo -e "\033[32mTo stop or remove it please run setup.sh again\033[m"
    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f papyrus &>> $LOGS_PATH & nohup ./myOsiris&
        sleep 2
        echo -e -n "\n${red}Tracking view mode will exit in 10secs${reset}\n"
        timeout 10s tail -f nohup.out
    else
        exit
    fi
}

installJuno() {
    osirisClear
    echo -e "\n\033[34mCloning and running docker... \033[m"
    sleep 1
    refreshClient
    git clone https://github.com/NethermindEth/juno $CLIENT_DIR
    sudo docker run -d -it --name juno \
        -p 6060:6060 \
        -v $CLIENT_DIR:/var/lib/juno \
        nethermindeth/juno \
        --rpc-port 6060 \
        --db-path /var/lib/juno
    # Wait for the Juno client to start
    osirisClear
    echo -e "\n\033[34mWaiting for Juno client to start... \033[m"
   	while ! sudo docker exec juno pgrep juno > /dev/null; do sleep 1; done
    echo "{\"name\": \"${node_name}\", \"client\": \"${client}\", \"rpc_key\": \"${rpc_key}\", \"osiris_key\": \"${osiris_key}\"}" > config.json    
    go build
    echo -e "\n\033[32m$(cat ./config.json | jq -r '.name') full node is running correctly using Juno client!\033[m"
    echo -e "\033[32mTo stop or remove it please run setup.sh again\033[m"
    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f juno &>> $LOGS_PATH & nohup ./myOsiris&
        sleep 2
        echo -e -n "\n${red}Tracking view mode will exit in 10secs${reset}\n"
        timeout 10s tail -f nohup.out
    else
        exit
    fi
}

installPathfinder() {
    osirisClear
    echo -e "\n\033[34mCloning and running docker... \033[m"
    sleep 1
    refreshClient
    git clone git@github.com:eqlabs/pathfinder.git $CLIENT_DIR
    sudo mkdir -p $HOME/pathfinder
    sudo chmod 777 $HOME/pathfinder
    sudo docker run \
        --name pathfinder \
        --restart unless-stopped \
        --detach \
        -p 9545:9545 \
        --user "$(id -u):$(id -g)" \
        -e RUST_LOG=info \
        -e PATHFINDER_ETHEREUM_API_URL="$(cat ./config.json | jq -r '.rpc_key')" \
        -v $CLIENT_DIR:/usr/share/pathfinder/data \
        eqlabs/pathfinder > /dev/null
    # Wait for the Pathfinder client to start
    osirisClear
    echo -e "\n\033[34mWaiting for Pathfinder client to start... \033[m"
   	while ! sudo docker exec pathfinder grep pathfinder > /dev/null; do sleep 1; done
    echo "{\"name\": \"${node_name}\", \"client\": \"${client}\", \"rpc_key\": \"${rpc_key}\", \"osiris_key\": \"${osiris_key}\"}" > config.json    
    go build
    echo -e "\n\033[32m$name full node is running correctly using Pathfinder client!\033[m"
    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f pathfinder &>> $LOGS_PATH & nohup ./myOsiris&
        sleep 2
        echo -e -n "\n${red}Tracking view mode will exit in 10secs${reset}\n"
        timeout 10s tail -f nohup.out
    else
        exit
    fi
}

installGeth() {
    osirisClear
    echo -e "\n\033[34mCloning and running docker... \033[m"
    sleep 1
    refreshClient
    git clone https://github.com/ethereum/go-ethereum.git $CLIENT_DIR

    # Set the data directories for Geth and Nimbus
    GETH_DATA=$(pwd)/geth_data
    NIMBUS_DATA=$(pwd)/nimbus_data

    sudo chown -R $(id -u):$(id -g) "$NIMBUS_DATA"

    # Pull the Geth and Nimbus Docker images
    docker pull ethereum/client-go:latest
    docker pull statusim/nimbus-eth2:latest

    # Create a custom network for the containers
    docker network create eth2_network

    # Start the Geth Docker container
    docker run -d \
    --name geth \
    --network eth2_network \
    -p 30303:30303 \
    -p 30303:30303/udp \
    -p 8551:8551 \
    -u "$(id -u):$(id -g)" \
    -e RUST_LOG=info \
    -v "$GETH_DATA:/home/geth/.ethereum" \
    ethereum/client-go \
    --datadir /home/geth/.ethereum \
    --http \
    --http.addr 0.0.0.0 \
    --http.port 8551 \
    --http.vhosts=*

    # Start the Nimbus Docker container and connect it to the Geth container
    docker run -it \
    --name nimbus \
    --network eth2_network \
    -p 9000:9000 \
    -v "$NIMBUS_DATA:/home/nimbus/.nimbus" \
    --user "$(id -u):$(id -g)" \
    statusim/nimbus-eth2:amd64-latest \
    --log-level=info \
    --data-dir=/home/nimbus/.nimbus \
    --web3-url=http://geth:8551

    # Wait for the Geth client to start
    osirisClear
    echo -e "\n\033[34mWaiting for Geth container to be in a running state... \033[m"
    while [[ "$(sudo docker inspect -f '{{.State.Status}}' geth)" != "running" ]]; do sleep 1; done
    osirisClear
    echo -e "\n\033[34mWaiting for Geth client to start... \033[m"
    while ! sudo docker exec geth grep Ethereum > /dev/null; do sleep 1; done
    echo "{\"name\": \"${node_name}\", \"client\": \"${client}\", \"rpc_key\": \"${rpc_key}\", \"osiris_key\": \"${osiris_key}\"}" > config.json
    go build
    echo -e "\n\033[32m$name full node is running correctly using Geth client!\033[m"
    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f geth &>> $LOGS_PATH & nohup ./myOsiris&
        sleep 2
        echo -e -n "\n${red}Tracking view mode will exit in 10secs${reset}\n"
        timeout 10s tail -f nohup.out
    else
        exit
    fi
}

installTaiko() {
    osirisClear
    echo -e "\n\033[34mCloning Taiko node... \033[m"
    sleep 1
    refreshClient
    git clone https://github.com/taikoxyz/simple-taiko-node.git $CLIENT_DIR
    cd $CLIENT_DIR
    osirisClear
    echo -e "\n\033[34mConfiguring Taiko node... \033[m"
    sleep 1
    cp .env.sample .env
    # Prompt the user to set L1_ENDPOINT_HTTP and L1_ENDPOINT_WS in the .env file manually
    osirisClear
    echo -e "\n\033[34mStarting Taiko node... \033[m"
    sleep 1
    sudo docker compose up -d
}


installTools() {
    osirisClear
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
    osirisClear
    echo -e "\n\033[34mInstalling tools... \033[m\n"
    if ! command -v docker &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    fi
    if command version go >/dev/null; then
        echo "Installing go language package version 1.20.2"
        curl https://storage.googleapis.com/golang/go1.20.2.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf -
        echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/environment > /dev/null
        sudo chmod 0644 /etc/environment
        source /etc/environment
    fi
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
        rm -rf ./nohup.out > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
	if sudo docker ps -a | grep papyrus > /dev/null
	then
		sudo docker rm -f papyrus > /dev/null
		sudo docker image rm -f ghcr.io/starkware-libs/papyrus:dev > /dev/null
        rm -rf ./nohup.out > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
	if sudo docker ps -a | grep pathfinder > /dev/null
	then
		sudo docker rm -f pathfinder > /dev/null
		sudo docker image rm -f eqlabs/pathfinder > /dev/null
        rm -rf ./nohup.out > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
    if sudo docker ps -a | grep geth > /dev/null
	then
		sudo docker rm -f geth > /dev/null
		sudo docker image rm -f ethereum/client-go > /dev/null
        rm -rf ./nohup.out > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
	if [ -d $CLIENT_DIR ]
	then
		rm -rf $CLIENT_DIR
	fi
}
main "$@"