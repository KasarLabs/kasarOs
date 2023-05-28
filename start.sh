#!/bin/bash

set -eu -o pipefail

KASAROS_PATH="/home/starknode/kasarOs"
BASE="/home/starknode/"
CLIENT_DIR="$KASAROS_PATH/client"
LOGS_PATH="$KASAROS_PATH/network/logs.txt"
TRACK_MODE=true

client=$(jq -r '.client' $KASAROS_PATH/config.json)
rpc_key=$(jq -r '.rpc_key' $KASAROS_PATH/config.json)

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

installPathfinder() {
    echo -e "\n\033[34mCloning and running docker... \033[m"
    sleep 1
    git clone https://github.com/eqlabs/pathfinder $CLIENT_DIR
    sudo mkdir -p $BASE/pathfinder
    sudo chmod 777 $BASE/pathfinder
    sudo docker run \
        --name pathfinder \
        --restart unless-stopped \
        --detach \
        -p 9545:9545 \
        --user "$(id -u):$(id -g)" \
        -e RUST_LOG=info \
        -e PATHFINDER_ETHEREUM_API_URL="$rpc_key" \
        -v $CLIENT_DIR:/usr/share/pathfinder/data \
        eqlabs/pathfinder > /dev/null
    echo -e "\n\033[34mWaiting for Pathfinder client to start... \033[m"
   	while ! sudo docker logs pathfinder > /dev/null; do sleep 1; done    
    go build -buildvcs=false > /home/starknode/kasarOs/lilopop 2>&1 
    echo -e "\n\033[32mPathfinder full node is running correctly using Pathfinder client!\033[m"
    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f $client &>> $LOGS_PATH & nohup $KASAROS_PATH/myOsiris > $KASAROS_PATH/nohup.out 2>&1 &
        sleep 2
        echo -e -n "\nTracking view mode will exit in 10secs\n"
        timeout 10s tail -f nohup.out
    else
        exit
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
        ufw
EOF
)
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
        echo "" | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt-get update
        sudo apt-get install -y docker.io
    fi
    if ! command go version >/dev/null; then
        echo "Installing go language package version 1.20.2"
        sudo tar -C /usr/local -xzf /home/starknode/go1.20.4.linux-arm64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/starknode/.bashrc
        echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/environment > /dev/null
        export GOPATH="/home/starknode/go"
        export GOCACHE="/home/starknode/go/pkg/mod/cache"
        sudo chmod 0644 /etc/environment
        source /etc/environment
    fi
    while read -r p ; do sudo apt install -y $p ; done < <(cat << "EOF"
        sysstat
        bc
EOF
)

    if [ ! -d "$KASAROS_PATH/tmp/" ]
    then
        mkdir $KASAROS_PATH/tmp/
    fi

    # git -C $(pwd)/tmp/ clone https://github.com/raboof/nethogs > $(pwd)/tmp/sample.log 2>&1
    # sudo make install -C $(pwd)/tmp/nethogs/ >> $(pwd)/tmp/sample.log 2>&1
    # rm -rf $(pwd)/tmp/
}

install() {
    installTools
    
    if [ "$client" = "pathfinder" ]; then
        installPathfinder
    elif [ "$client" = "juno" ] || [ "$client" = "papyrus" ]; then
        echo "$client is not supported at the moment."
    else
        echo "Client $client does not exist."
    fi
}

node_docker=$client

if sudo docker ps -a --format '{{.Names}}' | grep -q "^pathfinder$"; then
    sudo docker start ${node_docker} > /dev/null
    echo -e "\nNode started.\n"
    sudo docker logs -f $client &>> $LOGS_PATH & nohup $KASAROS_PATH/myOsiris > $KASAROS_PATH/nohup.out 2>&1 &
    exit
else
    install
fi



