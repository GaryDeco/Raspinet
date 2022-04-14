#!/usr/bin/env bash

##############################################################################################
#Author:       Gary Decosmo
#Date Created: October 31, 2021
#Description:  Discover the Pi IP address and other network info
###############################################################################################

clear
#terminal colors
# Red=$'\e[0;31m'
# RedB=$'\e[1;31m'
# GrnB=$'\e[1;32m'
# BluB=$'\e[1;34m'
# Wht=$'\e[0m'

# # start message
# sleep 0.1s
# echo ""
# echo "$Red"
# figlet -t Network"  "Info
# echo "$Wht"
# sleep 0.1s
# echo ""
# echo "Getting info..."

# network paths
IFPATH="/sys/class/net"
ethState=$IFPATH/eth0/operstate
wifiState=$IFPATH/wlan0/operstate

# # setup gpio (the long way for now #TODO fix later)
# if [ ! -e /sys/class/gpio/gpio23 ]; then
# echo "23" > /sys/class/gpio/export
# fi
# echo "out" > /sys/class/gpio/gpio23/direction

# network info
ethIP=$(ifconfig eth0 | grep -w inet | awk '{print $2}')
ethMASK=$(ifconfig eth0 | grep -w inet | awk '{print $4}')
ethBC=$(ifconfig eth0 | grep -w inet | awk '{print $6}')
ethMAC=$(ifconfig eth0 | grep -w ether | awk '{print $2}') 
ethNETID=$(ip -4 addr show eth0 | grep inet | awk -F" " {' print $2 '} | awk -F"." {'print $1"."$2"."$3".0"'})
ethGW=$(ip route | grep -w default | grep -w eth0 | awk '{print $3}')
ethCDR=$(ip -4 -o addr show eth0 | awk '{print $4}')

wifiIP=$(ifconfig wlan0 | grep -w inet | awk '{print $2}')
wifiMASK=$(ifconfig wlan0 | grep -w inet | awk '{print $4}')
wifiBC=$(ifconfig wlan0 | grep -w inet | awk '{print $6}')
wifiMAC=$(ifconfig wlan0 | grep -w ether | awk '{print $2}') 
wifiNETID=$(ip -4 addr show wlan0 | grep inet | awk -F" " {' print $2 '} | awk -F"." {'print $1"."$2"."$3".0"'})
wifiGW=$(ip route | grep -w default | grep -w wlan0 | awk '{print $3}')
wifiCDR=$(ip -4 -o addr show wlan0 | awk '{print $4}')

# echo -e "\n<><><><><><><><> Network Info Report <><><><><><><><><>"
# echo "$RedB"
# echo -e "_________________ Ethernet Info _________________"
# echo "$Wht"
# if [ "`cat $ethState`" == "up" ];then
#     echo  "Ethernet connection is: $GrnB`cat $ethState`$Wht"
#     echo "1" > /sys/class/gpio/gpio23/value
#     echo "IP Address:$GrnB             $ethIP $Wht"
#     echo "Net Mask:$GrnB               $ethMASK $Wht"
#     echo "Broadcast:$GrnB              $ethBC $Wht"
#     echo "Net ID:$GrnB                 $ethNETID $Wht"
#     echo "Gateway:$GrnB                $ethGW $Wht"
#     echo "Host Range (CIDR):     $GrnB $ethCDR $Wht"
# else 
#     echo  "Ethernet connection is: $RedB`cat $ethState`$Wht"
#     echo  "Information unavailable..."
#     echo "0" > /sys/class/gpio/gpio23/value
# fi
# echo "$RedB"
# echo -e "___________________ Wifi Info ___________________"
# echo "$Wht"

# if [ "`cat $wifiState`" == "up" ];then
#     echo  "Wifi connection is: $GrnB    `cat $wifiState`$Wht"
#     echo "IP Address:$GrnB             $wifiIP $Wht"
#     echo "Net Mask:$GrnB               $wifiMASK $Wht"
#     echo "Broadcast:$GrnB              $wifiBC $Wht"
#     echo "Net ID:$GrnB                 $wifiNETID $Wht"
#     echo "Gateway:$GrnB                $wifiGW $Wht"
#     echo "Host Range (CIDR):     $GrnB $wifiCDR $Wht"
# else 
#     echo  "Wifi connection is: $RedB`cat $wifiState`$Wht"
#     echo  "Information unavailable..."
# fi

# echo -e "\n<<><><><><><><><><> End of Report <><><><><><><><><><>>\n"

#output

function netReport() {
    echo "<Ethernet Report>"
    echo "Interface Name: eth0" # #TODO need to fix 
    echo "Datetime: `date +%F_%H-%M-%S`"
    echo "Connection Status: `cat $ethState`"
    echo "IP Address: $ethIP"
    echo "Net Mask: $ethMASK "
    echo "Broadcast: $ethBC"
    echo "Net ID: $ethNETID"
    echo "Gateway: $ethGW "
    echo "Host Range (CIDR): $ethCDR"
    echo " "
    echo "<Wifi Report>"
    echo "Interface Name: wlan0" # #TODO need to fix 
    echo "Datetime: `date +%F_%H-%M-%S`"
    echo "Connection Status: `cat $wifiState`"
    echo "IP Address: $wifiIP"
    echo "Net Mask: $wifiMASK "
    echo "Broadcast: $wifiBC"
    echo "Net ID: $wifiNETID"
    echo "Gateway: $wifiGW "
    echo "Host Range (CIDR): $wifiCDR"
    echo " "
}


netReport >> /home/pi/DSI/scripts/whiptail/network_reports/net_reports_$(date +%F_%H-%M).txt
whiptail --title "Network Info (scroll-box)" --textbox /home/pi/DSI/scripts/whiptail/network_reports/net_reports_$(date +%F_%H-%M).txt 20 60 --scrolltext

