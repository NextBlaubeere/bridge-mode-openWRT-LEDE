#!/bin/sh

# -----------------------------------------------
# This is a reconnect script for bridge-mode by
# Blaubeere using mbim as connection protocol
# Sorry for interfaces beeing hardcoded
# -----------------------------------------------

lastIPAddress="0.0.0.0"


sleep 20 # give the boot process some time before starting with the script

while [ true ]
do
	CONFIG=$(umbim -d /dev/cdc-wdm0 -n -t 7 config)
	
	# if connection is established	
	if [[ ! -z "$CONFIG" ]]; then
		currentIP=$(logger -e "$CONFIG"|grep "ipv4address"|grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
		#logger "Connection is Up. Address: $currentIP"
		
		
		if [[ "$currentIP" != "$lastIPAddress" ]]; then
			logger "WAN address has changed. Restarting dhcp service ..."
			lastIPAddress="$currentIP"
			/etc/init.d/dnsmasq stop
			ifdown lan
			sleep 1
			ifup lan
			/etc/init.d/dnsmasq start
		fi
		sleep 5
		
		
		
	# if connection is not established
	else
	
		logger "WAN connection is down. Restarting connection ..."
		ifdown wan
		usbreset 1199:9071
		sleep 1
		ifup wan
		sleep 15
		
	fi

done
logger "Connection-Watchdog failed ... terminating!"