#!/bin/sh
step=1
prog_name="rc.local"

KASAROS_PATH="/root/kasarOs"
CLIENT_DIR="$KASAROS_PATH/client"
LOGS_PATH="$KASAROS_PATH/network/logs.txt"
CONFIG_PATH="/boot/efi/src/config.json"
client=$(jq -r '.client' $CONFIG_PATH)
provider_id=$(jq -r '.provider_id' $CONFIG_PATH)
node_id=$(jq -r '.node_id' $CONFIG_PATH)
action=""

postState() {
    URL="http://179.61.246.59:8080/node/setState?provider_id=$provider_id&node_id=$node_id"
    DATA="\"$1\""
    echo $DATA
    curl -X POST -H "Content-Type: application/json" -d "$DATA" "$URL"
}

getAction() {
    URL="http://179.61.246.59:8080/node/getAction?provider_id=$provider_id"
    DATA="{
        \"NodeID\": $node_id,
        \"Action\": \"\",
        \"Command\": \"\",
        \"Response\": \"\"
    }"
    action=$(curl -X POST -H "Content-Type: application/json" -d "$DATA" "$URL")
}

check_script() {
    if ! pgrep -f prog_name >/dev/null; then
        if [ "$step" -eq 1 ]; then
            sleep 5
        elif [ "$step" -eq 2 ]; then
            ./start.sh > /root/logs 2>&1 &
        else
            sudo docker logs -f $client &>> $LOGS_PATH & nohup $KASAROS_PATH/myOsiris > $KASAROS_PATH/nohup.out 2>&1 &
        fi
    fi

}

while true; do
    if pgrep -f "rc.local" >/dev/null; then
        step=1
        prog_name="start.sh"
    elif pgrep -f "start.sh" >/dev/null; then
        step=2
         prog_name="myOsiris"
    elif pgrep -f "myOsiris" >/dev/null; then
        step=3
    else
        sleep 5
        check_script
    fi
    getAction
    if [ "$action" = "\"shutdown\"" ]; then
        postState "Shut down"
        sudo poweroff
    elif [ "$action" = "\"reboot\"" ]; then
        postState "Rebooting"
        sudo reboot
    elif [ "$action" = "\"hardReset\"" || "$action" = "\"reset\"" ]; then
        if command -v docker >/dev/null 2>&1; then
            sudo docker stop $(docker ps -aq) > /dev/null 2>&1 || true
            sudo docker rm $(docker ps -aq) > /dev/null 2>&1 || true
        fi
        sudo rm -rf /root/kasarOs
        if [ -d "/root/juno" ]; then
            rm -rf /root/juno
        fi
        if [ -d "/root/pathfinder" ]; then
            rm -rf /root/pathfinder
        fi
        cd /root/
        git clone https://github.com/KasarLabs/kasarOs && cd kasarOs && git checkout roc-dev
        if ! cmp -s "/root/kasarOs/rc.local" "/etc/rc.local"; then
            cp "/root/kasarOs/rc.local" "/etc/rc.local"
        fi
        postState "Rebooting"
        sudo reboot
    fi
    sleep 20
done