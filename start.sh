#!/bin/bash

set -eu -o pipefail

KASAROS_PATH="/root/kasarOs"
BASE="/root"
CLIENT_DIR="$KASAROS_PATH/client"
LOGS_PATH="$KASAROS_PATH/network/logs.txt"
CONFIG_PATH="/boot/efi/src/config.json"
TRACK_MODE=true
provider_id=$(jq -r '.provider_id' $CONFIG_PATH)
node_id=$(jq -r '.node_id' $CONFIG_PATH)

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
    if [ -d "$CLIENT_DIR" ]; then
        rm -rf $CLIENT_DIR
    fi
    git clone https://github.com/eqlabs/pathfinder $CLIENT_DIR
    if [ ! -d "/root/pathfinder/tar.lock" ]; then
        if [ -d "/root/mainnet-v0.5.6-64152.tar.xz" ]; then
            rm -rf /root/mainnet-v0.5.6-64152.tar.xz
        fi
        postState "Download Mainnet"
        wget -P /root/ https://pathfinder-backup.zklend.com/mainnet/mainnet-v0.5.6-64152.tar.xz
        sudo mkdir -p $BASE/pathfinder
        sudo chmod 777 $BASE/pathfinder
        postState "Unzip Mainnet"
        tar -xvf /root/mainnet-v0.5.6-64152.tar.xz -C /root/pathfinder
        rm -rf /root/mainnet-v0.5.6-64152.tar.xz
        sudo touch $BASE/pathfinder/tar.lock
    fi
    postState "Starting"
    sudo docker run \
        --name pathfinder \
        --restart unless-stopped \
        --detach \
        -p 9545:9545 \
        --user "$(id -u):$(id -g)" \
        -e RUST_LOG=info \
        -e PATHFINDER_ETHEREUM_API_URL="$rpc_key" \
        -v $BASE/$client:/usr/share/pathfinder/data \
        eqlabs/pathfinder > /dev/null
    echo -e "\n\033[34mWaiting for Pathfinder client to start... \033[m"
   	while ! sudo docker logs pathfinder > /dev/null; do sleep 1; done
    go build -buildvcs=false
    echo -e "\n\033[32mPathfinder full node is running correctly using Pathfinder client!\033[m"
    postState "Run"
    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f $client &>> $LOGS_PATH & nohup $KASAROS_PATH/myOsiris > $KASAROS_PATH/nohup.out 2>&1 &
        sleep 2
        echo -e -n "\nTracking view mode will exit in 10secs\n"
        timeout 10s tail -f nohup.out
    else
        exit
    fi
}

installJuno() {
    echo -e "\n\033[34mCloning and running docker... \033[m"
    sleep 1
    git clone https://github.com/NethermindEth/juno $CLIENT_DIR
    sudo docker run -d -it --name juno \
        -p 6060:6060 \
        -v $BASE/$client:/var/lib/juno \
        nethermindeth/juno \
        --rpc-port 6060 \
        --db-path /var/lib/juno
    echo -e "\n\033[34mWaiting for Juno client to start... \033[m"
    postState "Starting"
   	while ! sudo docker logs juno > /dev/null; do sleep 1; done
    go build -buildvcs=false
    echo -e "\n\033[32mJuno full node is running correctly using Pathfinder client!\033[m"
    postState "Run"
    if [ $TRACK_MODE == true ]; then
        sudo docker logs -f $client &>> $LOGS_PATH & nohup $KASAROS_PATH/myOsiris > $KASAROS_PATH/nohup.out 2>&1 &
        sleep 2
        echo -e -n "\nTracking view mode will exit in 10secs\n"
        timeout 10s tail -f nohup.out
    else
        exit
    fi
}

installPapyrus() {
    echo -e "Cloning and running docker...[m"

    git clone https://github.com/starkware-libs/papyrus $CLIENT_DIR
    sudo docker run -d --rm --name papyrus \
        -p 8080-8081:8080-8081 \
        -v $BASE/$client:/app/data \
        ghcr.io/starkware-libs/papyrus:dev
    echo -e "Waiting for Papyrus client to start..."
    postState "Starting"
    while ! sudo docker exec papyrus pgrep papyrus > /dev/null; do sleep 1; done   
    go build -buildvcs=false
    echo -e "Papyrus full node is running correctly using Pathfinder client!"
    postState "Run"
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
    sudo apt-get update --fix-missing 
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
        curl https://dl.google.com/go/go1.20.4.linux-arm64.tar.gz --output ../go1.20.4.linux-arm64.tar.gz
        sudo tar -C /usr/local -xzf $BASE/go1.20.4.linux-arm64.tar.gz
        rm -rf /root/go1.20.4.linux-arm64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/starknode/.bashrc
        echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/environment > /dev/null
        export GOPATH="$BASE/go"
        export GOCACHE="$BASE/go/pkg/mod/cache"
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
    if [ "$client" = "pathfinder" ]; then
        installPathfinder
    elif [ "$client" = "juno" ]; then
        installJuno
    elif [ "$client" = "papyrus" ]; then
        installPapyrus
    else
        echo "Client $client does not exist."
    fi
}

postState() {

    URL="http://179.61.246.59:8080/node/setState?provider_id=$provider_id&node_id=$node_id"
    DATA="\"$1\""
    echo $DATA
    curl -X POST -H "Content-Type: application/json" -d "$DATA" "$URL"
}

postState "Install Tools"

installTools

client=$(jq -r '.client' $CONFIG_PATH)
rpc_key=$(jq -r '.rpc_key' $CONFIG_PATH)

node_docker=$client

if sudo docker ps -a --format '{{.Names}}' | grep -q "^pathfinder$"; then
    postState "Starting"
    sudo docker start ${node_docker} > /dev/null
    postState "Run"
    sudo docker logs -f $client &>> $LOGS_PATH & nohup $KASAROS_PATH/myOsiris > $KASAROS_PATH/nohup.out 2>&1 &
    exit
else
    install
fi



