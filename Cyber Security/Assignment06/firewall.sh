#!/bin/bash
# You are NOT allowed to change the files' names!
config="config.txt"
rulesV4="rulesV4"
rulesV6="rulesV6"

function firewall() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-config"  ]; then
        while IFS= read -r line; do
            ipv4_address=$(dig +short $line A) &
            ipv6_address=$(dig +short $line AAAA) &
            wait

            for ip in $ipv4_address; do 
                if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    iptables -A INPUT -s $ip -j REJECT
                else
                    echo "Skipped invalid IPv4 address: $ip"
                fi
            done

            for ip in $ipv6_address; do 
                if [[ "$ip" =~ ^[0-9a-fA-F:]+$ ]]; then
                    ip6tables -A INPUT -s $ip -j REJECT
                else
                    echo "Skipped invalid IPv6 address: $ip"
                fi
            done
        done < config.txt

        true
        
    elif [ "$1" = "-save"  ]; then
        iptables-save > rulesV4
        ip6tables-save > rulesV6
        true
        
    elif [ "$1" = "-load"  ]; then
        iptables-restore < rulesV4
        ip6tables-restore < rulesV6
        true

        
    elif [ "$1" = "-reset"  ]; then
        iptables -F
        ip6tables -F
        
        iptables -P INPUT ACCEPT
        ip6tables -P INPUT ACCEPT
        true

        
    elif [ "$1" = "-list"  ]; then
        echo "IPv4 Rules:"
        iptables -L
        echo "IPv6 Rules:"
        ip6tables -L
        true
        
    elif [ "$1" = "-help"  ]; then
        printf "This script is responsible for creating a simple firewall mechanism. It rejects connections from specific domain names or IP addresses using iptables/ip6tables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -config\t  Configure adblock rules based on the domain names and IPs of '$config' file.\n"
        printf "  -save\t\t  Save rules to '$rulesV4' and '$rulesV6'  files.\n"
        printf "  -load\t\t  Load rules from '$rulesV4' and '$rulesV6' files.\n"
        printf "  -list\t\t  List current rules for IPv4 and IPv6.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

firewall $1
exit 0