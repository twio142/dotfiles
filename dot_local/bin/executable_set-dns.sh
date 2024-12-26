#!/bin/bash

# Admin privileges needed

flush_dns=false

# Check and set DNS for Wi-Fi if available
current_wifi_dns=$(networksetup -getdnsservers Wi-Fi 2>/dev/null)
if [[ $? -eq 0 && "$current_wifi_dns" != "127.0.0.1" ]]; then
    networksetup -setdnsservers Wi-Fi 127.0.0.1 && {
        echo "Wi-Fi DNS set to 127.0.0.1";
        flush_dns=true;
    }
fi

# Check and set DNS for Ethernet if available
networksetup -listnetworkserviceorder | grep -E '^\(\d+\) .*LAN.*' | while read -r line; do
    line=$(echo "$line" | sed -E 's/^\([0-9]+\) //')
    current_ethernet_dns=$(networksetup -getdnsservers "$line" 2>/dev/null)
    if [[ $? -eq 0 && "$current_ethernet_dns" != "127.0.0.1" ]]; then
        networksetup -setdnsservers "$line" 127.0.0.1 && {
            echo "Ethernet DNS set to 127.0.0.1";
            flush_dns=true;
        }
    fi
done

# Flush DNS cache only if DNS was changed
if [ "$flush_dns" == true ]; then
    dscacheutil -flushcache
    killall -HUP mDNSResponder
fi
