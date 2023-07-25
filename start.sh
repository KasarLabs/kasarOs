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
total_space=$(df -h --total | awk '/total/{print $2}' | sed 's/[A-Za-z]//g')
ip="127.0.0.1"

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
    if [ -d "/root/papyrus" ]; then
        rm -rf /root/papyrus
    fi
    if [ -d "/root/juno" ]; then
        rm -rf /root/juno
    fi
    postState "Clone client"
    git clone https://github.com/eqlabs/pathfinder $CLIENT_DIR
    postState "Client cloned"
    updateNetwork 9545
    if [ ! -e "/root/pathfinder/tar.lock" ]; then
        if (( $(bc <<< "$total_space < 300") )); then
            if [ -e "/root/mainnet-v0.5.6-64152.tar.xz" ]; then
                rm -rf /root/mainnet-v0.5.6-64152.tar.xz
            fi
            postState "Download Mainnet"
            wget -P /root/ https://pathfinder-backup.zklend.com/mainnet/mainnet-56215.tar.xz
            sudo mkdir -p $BASE/pathfinder
            sudo chmod 777 $BASE/pathfinder
            postState "Unzip Mainnet"
            tar -xvf /root/mainnet-56215.tar.xz -C /root/pathfinder
            rm -rf /root/mainnet-56215.tar.xz
            sudo touch $BASE/pathfinder/tar.lock
        else
            if [ -e "/root/mainnet-v0.5.6-64152.tar.xz" ]; then
                rm -rf /root/mainnet-v0.5.6-64152.tar.xz
            fi
            postState "Download Mainnet"
            wget -P /root/ https://pathfinder-backup.zklend.com/mainnet/mainnet-v0.5.6-64152.tar.xz > /dev/null 2>&1
            sudo mkdir -p $BASE/pathfinder
            sudo chmod 777 $BASE/pathfinder
            postState "Unzip Mainnet"
            tar -xvf /root/mainnet-v0.5.6-64152.tar.xz -C /root/pathfinder
            rm -rf /root/mainnet-v0.5.6-64152.tar.xz
            sudo touch $BASE/pathfinder/tar.lock
        fi
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
    if [ -d "$CLIENT_DIR" ]; then
        rm -rf $CLIENT_DIR
    fi
    if [ -d "/root/pathfinder" ]; then
        rm -rf /root/pathfinder
    fi
    if [ -d "/root/papyrus" ]; then
        rm -rf /root/papyrus
    fi
    sleep 1
    git clone https://github.com/NethermindEth/juno $CLIENT_DIR
    if [ -d "/root/juno" ]; then
        folder_size=$(du -s /root/juno | awk '{print $1}')
        folder_size_gb=$(echo "scale=2; $folder_size / 1024" | bc)
        if (( $(echo "$folder_size_gb > 29" | bc -l) )); then
            sudo touch $BASE/juno/tar.lock
        fi
    fi
    if [ ! -e "/root/juno/tar.lock" ]; then

        if [ -e "/root/juno_mainnet_v0.4.0_100713.tar" ]; then
            rm -rf /root/juno_mainnet_v0.4.0_100713.tar
        fi
        postState "Download Mainnet"
        wget -P /root/ https://juno-snapshot.s3.us-east-2.amazonaws.com/mainnet/juno_mainnet_v0.4.0_100713.tar > /dev/null 2>&1
        postState "Unzip Mainnet"
        tar -xvf /root/juno_mainnet_v0.4.0_100713.tar -C /root/
        sudo mv /root/juno_mainnet /root/juno
        sudo touch $BASE/juno/tar.lock
        sudo chmod 777 $BASE/juno
        rm -rf /root/juno_mainnet_v0.4.0_100713.tar
    fi
    sudo docker run -d -it --name juno \
        -p 6060:6060 \
        -v $BASE/$client:/var/lib/juno \
        nethermind/juno:v0.4.1-arm64 \
        --http-port 6060 \
        --db-path /var/lib/juno
    echo -e "\n\033[34mWaiting for Juno client to start... \033[m"
    updateNetwork 6060
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
    if [ -d "$CLIENT_DIR" ]; then
        rm -rf $CLIENT_DIR
    fi
    if [ -d "/root/pathfinder" ]; then
        rm -rf /root/pathfinder
    fi
    if [ -d "/root/juno" ]; then
        rm -rf /root/juno
    fi
    git clone https://github.com/starkware-libs/papyrus $CLIENT_DIR
    sudo docker pull ghcr.io/starkware-libs/papyrus:dev
    sudo docker run -d --rm --name papyrus \
        -p 8080-8081:8080-8081 \
        -v $BASE/$client:/app/data \
        ghcr.io/starkware-libs/papyrus:dev
    echo -e "Waiting for Papyrus client to start..."
    updateNetwork 8080
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
    sudo dpkg --configure -a
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
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
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

updateNetwork() {
    URL="http://179.61.246.59:8080/node/updateNetwork?provider_id=$provider_id"
    DATA="{
        \"NodeID\": $node_id,
        \"LocalIp\": \"$ip\",
        \"Port\": $1,
        \"Storage\": $total_space
    }"
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
elif sudo docker ps -a --format '{{.Names}}' | grep -q "^juno$"; then
    postState "Starting"
    sudo docker start ${node_docker} > /dev/null
    postState "Run"
    sudo docker logs -f $client &>> $LOGS_PATH & nohup $KASAROS_PATH/myOsiris > $KASAROS_PATH/nohup.out 2>&1 &
    exit
else
    install
fi



