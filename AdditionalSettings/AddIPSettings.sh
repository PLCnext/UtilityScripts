#!/bin/bash

NEWIP="192.168.188.5"
SUBNET="24"
ADAPTER="eth0"
DEFAULTGW="192.168.188.1"
NAMESERVER="nameserver 8.8.8.8"


echo "###########Old Settings"
ip addr
# Where are my requests sent?
netstat -rn
# can i reach the WWW through a DNS?
ping -c 3 www.google.de
# can i reach a public DNS?
ping -c 3 8.8.8.8 
cat /etc/resolv.conf

#As ROOT!
if [ "$(whoami)" = "root" ]; then

	echo "Add IP:${NEWIP}"
	echo "Add Subnet:${SUBNET}"
	echo "Addapter to modify:${ADAPTER}"
	echo "New Default GW:${DEFAULTGW}"
	echo "New Nameserver: ${NAMESERVER}"	
	echo "procede to activate changes [y/N]?"
	read -r -p "Are you sure? [y/N] " response

	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then 
		# Delete old gateway
		ip route delete default

		# Add new IP address in the subnet of your Gateway
		ip addr add ${NEWIP}/${SUBNET} dev ${ADAPTER}

		# Add new default gw
		ip route add default via ${DEFAULTGW}

		# add new nameserver
		echo "${NAMESERVER}" > /etc/resolv.conf

		echo "NETWORK SETTINGS have been changed"
		echo "Caution these changes are not persistent and will be reset after reboot."

		echo "########ChangedSettings:"
		ip addr 
		netstat -rn
		cat /etc/resolv.conf
	else
		echo "cancled."
	fi
else
        echo "To use this script and change settings: run as root"
fi
