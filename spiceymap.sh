#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

set -euo pipefail

#Function to check for required tools\c
check_tools() {
	for tool in nmap tcpdump nc; do 
	 if ! command -v $tool &> /dev/null; then
	  echo -e "${RED}This script requires $tool. Please install it.${RESET}"
	    exit 1
	 fi
        done
}

#Function to validate network input\c
validate_network() {
	if ! [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/([0-9]|[1-2][0-9]|3[0-2]))?$ ]]; then
		echo -e ${RED}"Invalid Network Format. Use CIDR notation (e.g., 192.168.1.0/24)${RESET}"
		exit 1
	fi
}

#Function to validate port\c
validate_port() {
	if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
		echo -e ${RED}"Invalid Port Number. Please enter a number between 1 and 65535.${RESET}"
		exit 1
	fi
}

get_scan_ports() {
	read -p "Do you want to specify port to scan? (yes/no, default: no):" specify_ports
	specify_ports=${specify_ports,,}

	if [[ "$specify_ports" == "yes" ]]; then
		read -p "Enter ports to scan (e.g., 22, 80, 443, or 1-1000 for the range): " input_ports
		SCAN_PORTS=${input_ports:-"1-65535"}
	else
		SCAN_PORTS="1-65535"
	fi
}

#Function to scan networks and identify active IPs\c
scan_network() {

	: "${SCANNING_MODE:=stealth}"

	echo -e "${RED}Scanning The Network... :)${RESET}"

	OUTPUT_FILE="active_ips.txt"

	case "$SCANNING_MODE" in
		"stealth")
			sudo nmap -sS -p "$SCAN_PORTS" "$NETWORK" -oG "$OUTPUT_FILE"
			;;
		"decoy")
			sudo nmap -D RND:"$DECOY_COUNT" -p "$SCAN_PORTS" -sn "$NETWORK" -oG "$OUTPUT_FILE"
			;;
		"idle")
		       sudo nmap -sI "$ZOMBIE_IP" -Pn -p "$SCAN_PORTS" "$NETWORK" -oG "$OUTPUT_FILE"
		       ;;
	       *)
		      sudo  nmap -sn "$NETWORK" -oG "$OUTPUT_FILE"
		       ;;
       esac

       # Debugger for checking IP text file\c
       echo -e "${RED}Checking active_ips.txt${RESET}"
       ls -l active_ips.txt
       cat "$OUTPUT_FILE"
       # End of debugger list\c

       if [[ ! -s active_ips.txt ]]; then
	       echo -e "${RED}No active IPs found.${RESET}"
	       exit 1
       fi
       echo -e "${RED} Active IPs.${RESET}"
       cat "$OUTPUT_FILE"
}

#Function to get a list of network interface
get_network_interface() {
	INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
	if [[ -z "$INTERFACE" ]]; then
		echo -e "${RED}No Network Interface.${RESET}"
		exit 1
	fi
	echo "$INTERFACE"
}

#Function to capture TCP traffic for a specified duration\c
capture_traffic() {
	echo -e "${RED}Starting TCP traffic capture for $DUMP_DURATION seconds...${RESET}"

	#Clear any previous capture file\c
	> "$DUMP_FILE"

	sudo timeout "$DUMP_DURATION" stdbuf -o0 tcpdump -i "$INTERFACE" -c 50 -w $DUMP_FILE -s 0 tcp > /dev/null 2>&1 & TCPDUMP_PID=$!

	wait "$TCPDUMP_PID" || true

	sleep "$DUMP_DURATION"
	kill "$TCPDUMP_PID" || true

	if [ ! -s "$DUMP_FILE" ]; then
		echo -e "${RED}Capture file is empty. No Packets were captured${RESET}"
		exit 1
	fi

	echo -e "${RED}TCP traffic capture stopped. Data saved to $DUMP_FILE.${RESET}"
}

#Function to convert the captured PCAP data to plain text\c
convert_to_text() {
	echo -e "${RED}Converting captured data to plain text format...${RESET}"

	if [ ! -s "$DUMP_FILE" ]; then
		echo -e "${RED}Capture file is empty. No packets were captured.${RESET}"
		exit 1
	fi

	if ! sudo tcpdump -r "$DUMP_FILE" > "$DUMP_TEXT_FILE"; then
		echo -e "${RED}Error converting PCAP to text.${RESET}"
		exit 1
	fi

	echo -e "${RED}Captured data in plain text saved to $DUMP_TEXT_FILE.${RESET}"
}

#Function to send a test message to active IPs on a specific port\c
send_test_messages() {
	echo -e "${RED}Sending a test message to active IPs on a specific port $NC_PORT...${RESET}"
	while IFS= read -r IP; do
		echo -e "${RED}Hello from $(hostname)" | nc -w 1 "$IP" "$NC_PORT" & done < active_ips.txt
		wait # Wait for all netcat processes to finish
}

#Function to receive messages on a specific port\c
receive_messages() {
	echo -e "${RED}Listening to messages on port $NC_PORT...${RESET}"
	sudo nc -l -p "$NC_PORT"
}

#Function to display menu for user input\c
display_menu() {
	echo -e "${RED}Please configure the following settings.${RESET}"
	read -p "Enter the network (default: 192.168.1.0/24):"	input_network
	NETWORK=${input_network:-192.168.1.0/24}

	#Get Ports For nmap Scan
	get_scan_ports

	# Use default if no input\c

	read -p "Enter the duration to capture packets (default: 60 seconds):" input_duration
	DUMP_DURATION=${input_duration:-60}
	# Use defualt if no input\c

	echo -e "${RED}Choose A Scanning Mode:${RESET}"
	echo -e "${RED}1. Normal Scan (Ping Scan)${RESET}"
	echo -e "${RED}2. Stealth Scan (SYN Scan)${RESET}"
	echo -e "${RED}3. Decoy Scan (With Randomized Decoys)${RESET}"
	echo -e "${RED}4. Idle Scan (Zombie Scan)${RESET}"
	read -p "Enter Your Choice (1,2,3,4):" scan_choice

	case "$scan_choice" in
		"1")
			SCANNING_MODE="normal"
			;;
		"2")
			SCANNING_MODE="stealth"
			;;
		"3")
			SCANNING_MODE="decoy"

			read -p "Enter The Number Of Random Decoys to use (default 10):"
			DECOY_COUNT=${input_decoy_count:-10}
			;;
		"4")
			SCANNING_MODE="idle"
			#Set a default zombie IP for idle scan if needed\c
			read -p "Enter the IP Of A Zombie Host For The Idle Scan (default: 192.168.1.1):" ZOMBIE_IP
			ZOMBIE_IP=${ZOMBIE_IP:-192.168.1.1}
			;;
		*)
			echo -e "${RED}!Invalid Choice! Defaulting To Normal Scan.${RESET}"
			SCANNING_MODE="normal"
			;;
	esac

	echo -e "${RED}Available Network Interface:${RESET}"
	get_network_interface
	read -p "Enter The Network Interface to Capture traffic on (default: any): " input_interface
	INTERFACE=${input_interface:-any}

	while true; do
	echo -e "${RED}Would You Like To Use Netcat for messaging?${RESET}"
	echo -e "${RED}1. Yes${RESET}"
	echo -e "${RED}2. No${RESET}"
	read -p "Enter Your Choice (1 or 2): " use_netcat

	if [[ "$use_netcat" =~ ^[12]$ ]]; then
		break
	else
		echo -e "${RED}INVALID CHOICE. PLEASE ENTER 1 OR 2${RESET}"
	fi
done 

if [[ "$use_netcat" == "1" ]]; then
        read -p "Enter the port for netcat (default: 12345): " input_port
        NC_PORT=${input_port:-12345}
        validate_port "$NC_PORT"
        #Validate Port Input

        echo -e "${RED}Choose An Option${RESET}"
	echo -e "${RED}1. Send Message${RESET}"
        echo -e "${RED}2. Receive Message${RESET}"
        echo -e "${RED}3. Skip Messaging${RESET}"
        read -p "Enter Your Choice (1, 2, Or 3): " choice
	choice=${choice:-3}

        if [[ "$choice" == "1" ]]; then
                send_test_messages
        elif [[ "$choice" == "2" ]]; then
                receive_messages
        elif [[ "$choice" == "3" ]]; then
                echo -e "${RED}Skipping Messaging${RESET}"
        else
                echo -e "${RED}!!INVALID CHOICE. PLEASE RE-RUN THIS SCRIPT!!${RESET}"
                exit 1
        fi
else
        echo -e "${RED}Skipping netcat Messaging${RESET}"
fi


}

#Main script Execution\c
DUMP_FILE="tcpdump.pcap"
#File to save the captured packet in plain text
DUMP_TEXT_FILE="tcp_dump.txt"
DUMP_DURATION=60

#Display the input Menu\c
display_menu

#Execute function in sequence\c
check_tools
scan_network
capture_traffic
convert_to_text

echo -e "${GREEN}PROTOCOL COMPLETE!${RESET}"

#Scrip Created By CyberTracell\c
