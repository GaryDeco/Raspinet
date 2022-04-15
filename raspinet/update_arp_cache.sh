#!/bin/bash

#/home/pi/DSI/scripts/update_arp_cache.sh

#####################################################
# Author: Gary Decosmo
# Date Created: 1/31/2022
# Description: 
# 	
#	Ping hosts on subnet in 
# 	a user defined range and update arp cache

######################################################
# cleanup the terminal
clear 
# some console color definitions
Red=$'\e[0;31m'
Wht=$'\e[0m'

# display Host ID string in console with figlet (just for looks)
echo "$Red"
figlet -t Host ID 
echo "$Wht"

# get network id
netid=$(ip -4 addr show eth0 | grep inet | awk -F" " {' print $2 '} | awk -F"." {'print $1"."$2"."$3'})

# user input and responses
echo "Enter start and stop values for desired IP range (0-255)"
echo -n "Starting IP: $netid."
read ipstart
echo -n "Ending IP: $netid."
read ipstop
echo "Searching for hosts on $netid.$ipstart-$ipstop..."

range=`expr $ipstop - $ipstart`

# for loop to iterate through each IP and ping each one
for (( i=ipstart; i<=ipstop; i++ )); do
       ping -c 1 -w 1 "$netid.$i"
done

echo "Search Complete"
echo "${range} Hosts were scanned"
echo "Saving temp file to: `$pwd`/tmp"
#TODO Fix dirs
arp -e | grep -v incomplete > /home/pi/DSI/scripts/tmp/arp_cache_$(date +%F)
echo "Copying timestamped temp file to: `$pwd`/arptables"
#TODO update these directories for integration into the new format
cp /home/pi/DSI/scripts/tmp/arp_cache_$(date +%F) /home/pi/DSI/scripts/arptables/arp_cache_$(date +%F_%H-%M-%S)
echo "Arp cache has been updated:"
arp -e
echo ""
echo -n "Would you like to remove incomplete entries from arp cache (y/n): "
read choice

if [ "$choice" = y ]; then
       clear
       echo "Incomplete entries have been removed:"
       #TODO Fix the dirs below
       sudo grep -v address /home/pi/DSI/scripts/tmp/arp_cache_$(date +%F) | awk -F" " {' print $1" "$3'} > /home/pi/DSI/scripts/tmp/update
       sudo ip -s neigh flush all
       #TODO Fix dirs
       sudo arp -f /home/pi/DSI/scripts/tmp/update
       sudo rm /home/pi/DSI/scripts/tmp/update
       echo "Report cleaned up..."
       echo "Saving..."
       arp -e
else
       echo "OK, Saving all..." 
fi
#TODO Fix dirs
sudo cp /home/pi/DSI/scripts/update_arp_cache.sh /usr/local/bin
echo "Report complete"


