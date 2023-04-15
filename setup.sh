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
    elif sudo docker ps -a | grep taiko > /dev/null
	then
		node_docker="taiko"
    elif sudo docker ps -a | grep celo > /dev/null
	then
		node_docker="celo"
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
    options=("Ethereum" "Starknet" "Taiko" "Celo" "Quit")
    yesOrNo=("Yes" "No" "Quit")
    selected=0 # Initialize the selected variable
    print_menu "Welcome to myOsiris!" "Please chose a blockchain you'd like to setup" "${options[@]}"

    if [ "${options[$selected]}" = "Starknet" ]; then
        menu_starknet
    elif [ "${options[$selected]}" = "Taiko" ]; then
        installTools
        installTaiko
    elif [ "${options[$selected]}" = "Ethereum" ]; then
        menu_ethereum
    elif [ "${options[$selected]}" = "Celo" ]; then
        installTools
        installCelo
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

menu_ethereum() {
    osirisClear
    options=("Geth - Ethereum" "Nethermind - Nethermind" "Besu - Hyperledger" "Erigon - Ledgerstack" "Quit")
    yesOrNo=("Yes" "No" "Quit")
    selected=0 # Initialize the selected variable
    print_menu "You selected Ethereum" "Please chose the execution client you'd like to install (currently using Lodestar concensus client)" "${options[@]}"
    # Prompt for node name, rpc_key, and osiris_key
    echo -e -n "${yellow}> Enter a name for your node:${reset} "
    read node_name
    echo -e -n "${yellow}> Enter your Osiris key:${reset} "
    read osiris_key

    # Create a JSON object and store it in config.json
    if [ "${options[$selected]}" = "Geth - Ethereum" ]; then
        client="geth"
        installTools
        installGeth
    elif [ "${options[$selected]}" = "Nethermind - Nethermind" ]; then
        client="nethermind"
        installTools
        installGeth
    elif [ "${options[$selected]}" = "Besu - Hyperl" ]; then
        client="besu"
        installTools
        installGeth
    elif [ "${options[$selected]}" = "Erigon - Ledgerwatch" ]; then
        client="erigon"
        installTools
        installGeth
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
    git clone https://github.com/ChainSafe/lodestar-quickstart $CLIENT_DIR
    cd $CLIENT_DIR
    sed -i 's|LODESTAR_EXTRA_ARGS="--network mainnet $LODESTAR_FIXED_VARS"|LODESTAR_EXTRA_ARGS="--checkpointSyncUrl https://beaconstate-mainnet.chainsafe.io --network mainnet $LODESTAR_FIXED_VARS"|g' ./mainnet.vars
    ./setup.sh --dataDir goerli-data --elClient geth --network mainnet --detached --dockerWithSudo
    # Wait for the Geth client to start
    osirisClear
    echo -e "\n\033[34mWaiting for Geth container to be in a running state... \033[m"
    while [[ "$(sudo docker inspect -f '{{.State.Status}}' mainnet-geth)" != "running" ]]; do sleep 1; done
    osirisClear
    echo -e "\n\033[34mWaiting for Geth client to start... \033[m"
    sudo docker logs mainnet-geth
    while ! sudo docker exec mainnet-geth grep Ethereum > /dev/null; do sleep 1; done
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

installCelo() {
    osirisClear
    echo -e "\n\033[34mSetting up Celo full node... \033[m"
    sleep 1
    refreshClient

    # Set up the environment variable
    export CELO_IMAGE=us.gcr.io/celo-org/geth:mainnet

    # Pull the Celo Docker image
    sudo docker pull $CELO_IMAGE

    # Set up the data directory
    CELO_DATA_DIR=$HOME/celo-data-dir
    mkdir -p $CELO_DATA_DIR
    chmod 777 $CELO_DATA_DIR

    # Create an account and get its address
    CELO_ACCOUNT_ADDRESS=$(sudo docker run -v $CELO_DATA_DIR:/root/.celo --rm -it $CELO_IMAGE account new | grep "Public address of the key:" | awk '{print $NF}')
    echo "Celo account address: $CELO_ACCOUNT_ADDRESS"

    # Start the Celo full node
    sudo docker run --name celo -d --restart unless-stopped --stop-timeout 300 \
        -p 127.0.0.1:8545:8545 -p 127.0.0.1:8546:8546 -p 30303:30303 -p 30303:30303/udp \
        -v $CELO_DATA_DIR:/root/.celo $CELO_IMAGE --verbosity 3 --syncmode full --http \
        --http.addr 0.0.0.0 --http.api eth,net,web3,debug,admin,personal --light.serve 90 \
        --light.maxpeers 1000 --maxpeers 1100 --etherbase $CELO_ACCOUNT_ADDRESS --datadir /root/.celo

    osirisClear
    echo -e "\n\033[34mWaiting for Celo full node to start... \033[m"
    while ! sudo docker logs celo-fullnode | grep "Imported new chain segment"; do sleep 1; done
    echo -e "\n\033[32mCelo full node is running correctly!\033[m"

    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f celo-fullnode &>> $LOGS_PATH & nohup ./myOsiris &
        sleep 2
        echo -e -n "\n${red}Tracking view mode will exit in 10secs${reset}\n"
        timeout 10s tail -f nohup.out
    else
        exit
    fi
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
    if sudo docker ps -a | grep mainnet-geth > /dev/null
	then
		sudo docker rm -f mainnet-geth > /dev/null
		sudo docker rm -f mainnet-lodestar > /dev/null
		sudo docker image rm -f chainsafe/lodestar > /dev/null
		sudo docker image rm -f ethereum/client-go > /dev/null
        rm -rf ./nohup.out > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
    if sudo docker ps -a | grep taiko > /dev/null
	then
		sudo docker rm -f taiko-client > /dev/null
		sudo docker image rm -f ethereum/client-go > /dev/null
        rm -rf ./nohup.out > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
    if sudo docker ps -a | grep celo-fullnode > /dev/null
	then
		sudo docker rm -f us.gcr.io/celo-org/geth:mainnet > /dev/null
		sudo docker image rm -f ethereum/client-go > /dev/null
        rm -rf ./nohup.out > /dev/null
		rm -f $LOGS_PATH > /dev/null
	fi
	if [ -d $CLIENT_DIR ]
	then
		sudo rm -rf $CLIENT_DIR
	fi
}
main "$@"