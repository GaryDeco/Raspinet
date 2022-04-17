#!/usr/bin/bash
# run this script every 60 seconds
NICPATH="/sys/class/net"
ETHUP="eth0/operstate"
ETH0_STATE=$NICPATH/$ETHUP

sudo usermod -aG gpio dev # needed to add permissions for gpio access 

function ethled_on(){
    sudo echo "26" >/sys/class/gpio/export
	sudo echo "out" >/sys/class/gpio/gpio26/direction
    sudo echo "1" > /sys/class/gpio/gpio26/value
}
function ethled_off(){
    sudo echo "0" > /sys/class/gpio/gpio26/value
    sudo echo "26" >/sys/class/gpio/unexport   
}
isEthUp(){
if [ `grep "" $ETH0_STATE` == "up" ] 
then
	echo "Turning on LED"
	ethled_on 
else
	echo "Turning off LED"
	ethled_off 
fi
}
isEthUp >/dev/null 2>&1
