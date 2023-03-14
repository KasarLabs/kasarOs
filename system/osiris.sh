#!/bin/bash

set -u -e -o pipefail
sudo -n true
test $? -eq 0 || exit 1 "You should have sudo privilege to run this script."

if pgrep -x pathfinder > /dev/null
then
	PNAME="pathfinder"
elif pgrep -x juno > /dev/null
then
	PNAME="juno"
elif pgrep -x papyrus_node > /dev/null
then
	PNAME="papyrus_node"
else
	echo "No node is currently running."
	exit 1
fi

asciiFunction()
{
	echo -e "\n"
	echo -e "\e[1;33m⠐⢤⣀⣀⡀⠀⠀⠀⢀⣀⣀⣀⣀⣠⣤⣤⣤⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⠀⠀\e[0m"
	echo -e "\e[1;33m⡄⠀⠈⠛⠿⢿⡿⠟⠛⠛⠛⠛⠛⠛⠛⠉⠉⠉⠉⠉⠁⠀⠀⠈⠉⠉⠛⠻⡇⠀\e[0m"
	echo -e "\e[1;33m⢹⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣶⣶⣶⣶⣦⣄⠀⠀⠀⠁⠀\e[0m"
	echo -e "\e[1;33m⠀⢻⣿⣿⣶⣶⣦⣤⣤⣤⣤⣤⣶⣾⣿⣿⠿⠛⢋⣿⣿⣿⣿⡛⢿⣷⣄⠀⠀⠀\e[0m"
	echo -e "\e[1;33m⠀⠀⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣭⣁⡀⠀⠀⠸⣿⣿⣿⣿⠇⠀⣘⣿⣿⣦⡄ \t\t\033[1;33mOsiris v1.0"
	echo -e "\e[1;33m⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠿⢿⣿⣿⣶⣶⣿⣿⣿⣿⣶⣿⣿⡿⠿⠿⣇    \t\033[1;35mBy Kasar Labs"
	echo -e "\e[1;33m⠀⠀⠀⠀⠀⠀⠐⣶⣤⡀⠀⠀⠀⠀⠀⠀⠉⠙⠛⣻⣿⣿⣿⡟⠉⠀⠀⠀⠀⠀\e[0m"
	echo -e "\e[1;33m⠀⠀⠀⠀⢀⣶⡿⠿⢿⣿⡆⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⢿⣿⡅⢸⠀⠀⠀⠀⠀\e[0m"
	echo -e "\e[1;33m⠀⠀⠀⠀⣿⡏⠀⠀⠀⢹⠇⠀⠀⠀⢀⣠⣾⣿⡿⠋⠁⢸⣿⣿⡟⠀⠀⠀⠀⠀\e[0m"
	echo -e "\e[1;33m⠀⠀⠀⠀⢿⣷⡀⠀⠔⠋⢀⣀⣤⣶⣿⡿⠛⠁⠀⠀⠀⢸⣿⡟⠀⠀⠀⠀⠀⠀\e[0m"
	echo -e "\e[1;33m⠀⠀⠀⠀⠀⠙⠿⠿⣿⣿⡿⠿⠟⠋⠁⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀\e[0m"
	echo -e "\e[1;33m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠀⠀⠀⠀⠀⠀⠀\e[0m"
	echo -e "\n"
}

if [ ! -f "/var/log/tracker_log.log" ];
then
	echo -e "TIMESTAMP,CPU,MEM,PROCESS" | sudo tee /var/log/tracker_log.log > /dev/null
fi

if [ ! -f "/var/log/osiris.log" ];
then
	sudo touch /var/log/osiris.log
	echo -e "\t\t%CPU\t%MEM\tkb_RD/s\t\tkb_WR/s\t\tSNT/s\t\tRCD/s\t\tPID\tPROCESS" | sudo tee /var/log/osiris.log > /dev/null

fi

if date | grep "PM" > /dev/null
then
	CPU_USAGE=$(pidstat -u -C ${PNAME} | awk 'NR == 4 {print $9}')
	RAM_USAGE=$(pidstat -r -C ${PNAME} | awk 'NR == 4 {print $9}')
	RD_USAGE=$(pidstat -d -C ${PNAME} | awk 'NR == 4 {print $5}')
	WR_USAGE=$(pidstat -d -C ${PNAME} | awk 'NR == 4 {print $6}')
else
	CPU_USAGE=$(pidstat -u -C ${PNAME} | awk 'NR == 4 {print $8}')
	RAM_USAGE=$(pidstat -r -C ${PNAME} | awk 'NR == 4 {print $8}')
	RD_USAGE=$(pidstat -d -C ${PNAME} | awk 'NR == 4 {print $4}')
	WR_USAGE=$(pidstat -d -C ${PNAME} | awk 'NR == 4 {print $5}')
fi

if [ ! -f "/tmp/nethogs_data" ]
then
	sudo nethogs -t -c 2  > /tmp/nethogs_data
fi

if sudo cat /tmp/nethogs_data | grep ${PNAME} > /dev/null
then
	DATA_SENT=$(sudo cat /tmp/nethogs_data | grep ${PNAME} | awk '{print $2}')
	DATA_RECEIVED=$(sudo cat /tmp/nethogs_data | grep ${PNAME} | awk '{print $3}')
	sudo rm /tmp/nethogs_data
else
	DATA_SENT=$(echo -n "0")
	DATA_RECEIVED=$(echo -n "0")
	sudo rm /tmp/nethogs_data
fi

echo -e "$(date +%s),${CPU_USAGE},${RAM_USAGE},${PNAME}" | sudo tee -a /var/log/tracker_log.log > /dev/null

TOTAL_CPU=$(cat /var/log/tracker_log.log | tail -n +2 | awk -F ',' '{print $2}' | paste -sd+ | bc)
AVERAGE_CPU=$(echo "${TOTAL_CPU} / $(cat /var/log/tracker_log.log | tail -n +2 | wc -l)" | bc)
MINIMUM_CPU=$(cat /var/log/tracker_log.log | tail -n +2 | cut -d"," -f2 | sort -n | head -1)
MAXIMUM_CPU=$(cat /var/log/tracker_log.log | tail -n +2 | cut -d"," -f2 | sort -n | tail -1)
TOTAL_RAM=$(cat /var/log/tracker_log.log | tail -n +2 | awk -F ',' '{print $3}' | paste -sd+ | bc)
AVERAGE_RAM=$(echo "${TOTAL_RAM} / $(cat /var/log/tracker_log.log | tail -n +2 | wc -l)" | bc)
MINIMUM_RAM=$(cat /var/log/tracker_log.log | tail -n +2 | cut -d"," -f3 | sort -n | head -1)
MAXIMUM_RAM=$(cat /var/log/tracker_log.log | tail -n +2 | cut -d"," -f3 | sort -n | tail -1)

helpFunction()
{
	echo -e "Usage:\n  myOsiris [options]\n"
	echo "Track performances of available clients on Starknet."
	echo "Options are:"
	echo -e "  -j, --json\t\t\tPrint and generate .json file."
	echo -e "  -h, --help\t\t\tDisplay this help and exit."
	exit 1
}

jsonFunction()
{
	JSON_STRING="{
	\"cpu_usage\":\"${CPU_USAGE}\",
	\"cpu_max_usage\":\"${MAXIMUM_CPU}\",
	\"cpu_min_usage\":\"${MINIMUM_CPU}\",
	\"ram_average_usage\":\"${AVERAGE_CPU}\",
	\"ram_usage\":\"${RAM_USAGE}\",
	\"ram_max_usage\":\"${MAXIMUM_RAM}\",
	\"ram_min_usage\":\"${MINIMUM_RAM}\",
	\"ram_average_usage\":\"${AVERAGE_RAM}\",
	\"data_received\":\"${DATA_RECEIVED}\",
	\"data_sent\":\"${DATA_SENT}\",
	\"disk_written\":\"${WR_USAGE}\",
	\"disk_read\":\"${RD_USAGE}\"
	}"

	echo -e "${JSON_STRING}" > performance.json
	cat $(pwd)/performance.json | jq
}

round()
{
    echo "scale=${2};(${1}+0.5)/1" | bc
}

basicFunction()
{
	asciiFunction
	ROUND_DATA_SENT=$(round ${DATA_SENT} 2)
	ROUND_DATA_RECEIVED=$(round ${DATA_RECEIVED} 2)

	echo -e "$(date +%X)\t\e[0;32m${CPU_USAGE}\t${RAM_USAGE}\t${RD_USAGE}\t\t${WR_USAGE}\t${ROUND_DATA_SENT}\t\t${ROUND_DATA_RECEIVED}\t\t$(pidof ${PNAME})\e[0m\t\e[1;34m${PNAME}\e[0m\e" | sudo tee -a /var/log/osiris.log > /dev/null
	cat /var/log/osiris.log
}

if [ $# -eq 0 ]
then
	basicFunction
elif [ $# -eq 1 ] && [ "$1" == "--json" ] || [ "$1" == "-j" ]
then
	jsonFunction
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
	helpFunction
else
	helpFunction
fi
