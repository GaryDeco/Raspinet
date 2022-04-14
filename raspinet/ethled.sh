#!/bin/bash
# run this script every 60 seconds

NICPATH="/sys/class/net"
ETHUP="eth0/operstate"

ETH0_STATE=$NICPATH/$ETHUP

sudo usermod -aG gpio pi # needed to add permissions for gpio access 

function ethled_on(){

    gpio export 26 out
    echo 1 > /sys/class/gpio/gpio26/value

}

function ethled_off(){

    echo 0 > /sys/class/gpio/gpio26/value
    gpio export 26 in
    
}

isEthUp(){
if [ `grep "" $ETH0_STATE` == "up" ] 
then
	ethled_on
else
	ethled_off
fi
}

isEthUp