#!/bin/sh
step=1
prog_name="rc.local"

KASAROS_PATH="/root/kasarOs"
CLIENT_DIR="$KASAROS_PATH/client"
LOGS_PATH="$KASAROS_PATH/network/logs.txt"
CONFIG_PATH="/boot/efi/src/config.json"
client=$(jq -r '.client' $CONFIG_PATH)

check_script() {
    if ! pgrep -f prog_name >/dev/null; then
        if [ "$step" -eq 1 ]; then
            sudo reboot
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
        sleep 20
        check_script
    fi
    sleep 20
done