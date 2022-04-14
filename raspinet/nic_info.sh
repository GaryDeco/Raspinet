#!/bin/bash
##############################################################################################
#Author:       Gary Decosmo
#Date Created: October 31, 2021
#Description:  Discover the Pi IP address and NIC status 
###############################################################################################
clear
# Bold terminal colors
Red=$'\e[0;31m'
Grn=$'\e[0;32m'
Blu=$'\e[0;34m'
Yel=$'\e[0,33m'
Wht=$'\e[0m'
# Normal terminal colors
RedB=$'\e[1;31m'
GrnB=$'\e[1;32m'
BluB=$'\e[1;34m'
YelB=$'\e[1,33m'
# start message
sleep 0.1s
echo ""
echo "$Red"
figlet -t DSI Net Analyzer
echo "$Wht"
sleep 0.1s
echo ""
echo "Getting system info..."
echo ""
sleep 0.1s
# display connected devices
echo "______________ Connected Devices _________________"
echo ""
sleep 0.1s
# show USB connected devices
lsusb
sleep 0.1s
###############################################################################################
# Testing some IP address retrieval tecniques for later use
IPV4=$(ip route get 8.8.8.8 | tr -s ' ' | cut -d' ' -f7)
# CIDR (wlan0)
GET_WLANIP_CDR=$(ip -4 -o addr show wlan0 | awk '{print $4}')
# CIDR (eth0)
GET_ETH0IP_CDR=$(ip -4 -o addr show eth0 | awk '{print $4}')
# get the mac address for the Pi
GETMAC=$(ifconfig eth0 | grep ether | awk '{print $2}')
# ethtool implementation for cable connection status
ELINK=$(ethtool eth0 | grep "Link det" | awk '{print $3}')

# Some path variables
NICPATH="/sys/class/net"
ETHSTAT="eth0/carrier"
WLANSTAT="wlan0/carrier"
ETHUP="eth0/operstate"
WLANUP="wlan0/operstate"
ES=$NICPATH/$ETHSTAT
EU=$NICPATH/$ETHUP
WS=$NICPATH/$WLANSTAT
WU=$NICPATH/$WLANUP

# It was found that ethool is ideal for getting info on wired connection
# it can confirm a linked cable connection which is ideal 

# Funcs
isWiFiUp(){
if [ `grep "" $WU` == "up" ] 
then
	echo "IPv4 (wlan0) Target range: $GET_WLANIP_CDR"
	sleep 0.1s
	echo "Wlan0 is `grep "" $WU`"  
	sleep 0.1s
	echo "Assigned IP (Wlan0): $IPV4"
	sleep 0.1s
echo "Wlan0 Network Status: `grep "" $WS`"
else
	echo "IPv4 (wlan0) Target range: No assigned IP address"
fi
}

#isEthLinked(){
#	if []
#}

isEthUp(){
if [ `grep "" $EU` == "up" ] 
then
	echo "IPv4 (eth0) Target range: $GET_ETH0IP_CDR"
else
	echo "IPv4 (eth0) Target range: No assigned IP address"
fi
}

echo ""
echo "_____________     NIC Status    ___________________"
echo ""
sleep 0.1s
echo "`isWiFiUp`"
sleep 0.1s
echo "Eth0 is `grep "" $EU`"
sleep 0.1s
echo "Eth0 Network Status: `grep "" $ES`"
sleep 0.1s
echo "`isEthUp`"
sleep 0.1s
echo "MAC Address (eth0): $GETMAC"
sleep 0.1s
echo ""
echo "____________   Report Complete  ___________________"
echo ""

read -n 1



