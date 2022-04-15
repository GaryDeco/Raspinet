#!/bin/bash

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# ip address
IP_ADDR=$(ifconfig eth0 | grep -w inet | awk '{print $2}') # Current Ip address
# ip host range 
HOST_RANGE=$(ip -4 -o addr show eth0 | awk '{print $4}') # Current network host range (CIDR)
#HOST_RANGE=$(ip addr | grep -w eth0 | grep -w inet | awk '{print $2}') # Alt method
# date time stamp
DT=$(date "+%F-%H-%M")
# network dir
IFPATH="/sys/class/net"
# iface states
ethState=$IFPATH/eth0/operstate
wifiState=$IFPATH/wlan0/operstate
PROF=$(cat /home/pi/raspinet/profiles/default.txt)
#TODO fix all of these dirs for the new format
RASDIR=/home/pi/raspinet/
REPDIR=$RASDIR/reports
PORTDIR=$REPDIR/ports
TMPDIR=$REPDIR/tmp
UPHOSTSDIR=$REPDIR/live_hosts
#*************** GPIO ******************#
SCANLED_DIR=/sys/class/gpio/gpio22
sudo usermod -aG gpio pi # needed to add permissions for gpio access 
#TODO add to build script
#TODO add sudo apt-get install -y lolcat --> build script

function scanled_on(){
    # init gpio pin 22 as ouput
    # creates dir gpio22
    gpio export 22 out
    # write 1 to the gpio22 dir
    # turns led on
    echo 1 > $SCANLED_DIR/value

}

function scanled_off(){
    # write 0 to gpio22 dir
    echo 0 > $SCANLED_DIR/value
    # set as input to keep state low
    gpio export 22 in
    
}
#*****************************************#
################################### ETRA CUSTOM CLI FOR FUN ################################
# Author: Gary Decomo
# Rander some cool text effects and banners 
function render_banner(){
    case "$1" in	
    '-3d') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/3d.flf $2 | lolcat
        echo
        ;;
    '-3d_diag')
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/3d_diagonal.flf $2 | lolcat
        echo
        ;;	
    '-3_D') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/3-D.flf $2 | lolcat
        echo
        ;;
    '-3x5') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/3x5.flf $2 | lolcat
        echo
        ;;
    '-4max') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/4Max.flf $2 | lolcat
        echo
        ;;
    '-5line_obl') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/5lineoblique.flf $2 | lolcat
        echo
        ;;
    '-bin') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/Binary.flf $2 | lolcat
        echo
        ;;
    '-big') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/Big.flf $2 | lolcat
        echo
        ;;
    '-doom') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/Doom.flf $2 | lolcat
        echo
        ;;
    '-iso') 
        echo
        figlet -c -f ~/.local/share/fonts/figlet-fonts/Isometric1.flf $2 | lolcat
        echo
        ;;			
    '-help') 	
        rb_help
        ;;
    *   )	# default message of no argument is passed
        echo "Use render_banner [-help] for help menu"
        ;;
    esac    

}

function rb_help(){

echo -e "

************************************************************************************ 
                         |><| render_banner help reference |><|
------------------------------------------------------------------------------------
Author:                     Gary Decosmo 
Notes:                      Permission is granted to modify as desired 
License:                    GNU-public 
Attributions:               Content used from Figlet, and lolcat. 
------------------------------------------------------------------------------------
usage:                      render_banner [option1] --> [string]
------------------------------------------------------------------------------------
about:                      Displays a string in the chosen font using figlet and 
                            lolcat for custom 3-d cli text
                            More will be added later, these are a few cool ones
------------------------------------------------------------------------------------
                        |><| render_banner help reference |><|
************************************************************************************ 
[]                          Null argument returns help message 
------------------------------------------------------------------------------------   
[-help]                     Returns help menu     
------------------------------------------------------------------------------------    
[-3d]                       Render a colorful 3d text output
------------------------------------------------------------------------------------      
[-3d_diag]                  Render a colorful 3d diagonal text output
------------------------------------------------------------------------------------ 
[-3_D]                      Render a 3d variation text output
------------------------------------------------------------------------------------ 
[-3x5]                      Render a 3d variation slight change
------------------------------------------------------------------------------------  
[-4max]                     Render a broader 3-D variation
------------------------------------------------------------------------------------ 
[-5line_obl]                Render a 5-line oblique font
------------------------------------------------------------------------------------ 
[-bin]                      Render a binary font
------------------------------------------------------------------------------------  
[-big]                      Render a big-ol standard font
------------------------------------------------------------------------------------ 
[-doom]                     Render a doom font
------------------------------------------------------------------------------------ 
[-iso]                      Render a isometric font
------------------------------------------------------------------------------------ 

    "
}


function raspinet-menu(){
    sudo echo -e $(clear)
    #TODO Fix dirs
    bash /home/pi/DSI/scripts/whiptail/config_tool.sh
    
}


function defscan(){
    #TODO expand all
    # Update target files initially
    echo -e "${RED}[raspinet]${RESET} ${GREEN}|><| Default Scans |><|${RESET}"
    sleep 1
    case "$1" in	
        '-inv' | '-inventory')
                    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
                    host_inv #get an inventory of live host IPs and output to a text file
            ;;
        '-po' | '-ports_open') 
                    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
                    get_open_ports #check live ports from host list
            ;;
        '-pa' | '-ports_all') 
                    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
                    get_all_open_ports #check all ports from host list, skip host discovery
            ;;				
        '-h' | '-help') # run the help menu function	
                    df_help
            ;;
        *   )	# default message of no argument is passed
            echo "Use defscan [-help] for help menu"
            ;;
    esac    
}

function df_help(){
echo "
************************************************************************************
------------------------------------------------------------------------------------ 
                         |><| defscan help reference |><|
------------------------------------------------------------------------------------
usage:                      defscan [option1] 
------------------------------------------------------------------------------------
about:                      Default scans ultilizing Nmap for network discovery 
                            An example IP target passed to nmap is: 192.168.68.25/24
                            ********************************************************
                            Scans the available host range of the local network
------------------------------------------------------------------------------------
[]                          Null argument returns help message 
------------------------------------------------------------------------------------   
[-h | -help]                Returns help menu     
------------------------------------------------------------------------------------    
[-inv | -inventory]         Scan Type: [nmap -n -sn <tgt>] No port scan. 
                            Return a text file with the list of live host IP's
                            Ovewrites the file and makes a date/time stamped copy
------------------------------------------------------------------------------------
[-po | -ports_open]         Scan Type: [nmap --top-ports 100 -F --open <tgt>]
                            A quick scan of the top 100 ports. Returns a text file 
                            with the list of host IP's and their open ports.  
------------------------------------------------------------------------------------
[-pa | -ports_all]          Scan Type:                               
------------------------------------------------------------------------------------
************************************************************************************    
    "
}
function host_inv(){
    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
    PROFDIR=$REPDIR/$PROF
    HOSTUP=$PROFDIR/up_hosts
    echo -e "${RED}[raspinet]${RESET} Current profile: ${GREEN}$PROF${RESET}"
    echo -e "${RED}[raspinet]${RESET} Getting list of live hosts"
    scanled_on
    sudo nmap -n -sn $HOST_RANGE -oG - | awk '/Up$/{print $2}' > $HOSTUP/hostinv.txt
    sudo cp $HOSTUP/hostinv.txt $HOSTUP/dt/hostinv_$DT.txt # copy file to uphosts directory (timestamped)
    echo -e "${RED}[raspinet]${RESET} Outputting current count of live hosts"
    cat $HOSTUP/hostinv.txt | echo "$DT, $(wc -l)" >> $HOSTUP/hostinv_runcount.txt #keep a running log
    cat $HOSTUP/hostinv.txt | wc -l > $HOSTUP/hostinv_count.txt # updated count
    sudo cp $HOSTUP/hostinv.txt $PROFDIR/tgts_all.txt
    echo -e "${RED}[raspinet]${RESET} Report complete"
    scanled_off
}

function get_open_ports(){
    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
    PROFDIR=$REPDIR/$PROF
    PODIR=$PROFDIR/open_ports
    POXML=$PODIR/xml
    POHTML=$PODIR/html
    echo -e "${RED}[raspinet]${RESET} Current profile: ${GREEN}$PROF${RESET}"
    echo -e "${RED}[raspinet]${RESET} Scanning ports from tgts-all list"
    scanled_on
    sudo nmap --top-ports 100 -F --open -oG $PODIR/tmp_open_ports.txt -oX $PODIR/open_ports.xml -iL $PROFDIR/tgts_all.txt
    echo -e "${RED}[raspinet]${RESET} Scan Complete"
    cd $PODIR
    xsltproc open_ports.xml -o "open_ports.html"
    sudo cp open_ports.xml $POXML/open_ports_$DT.xml
    #TODO Fix this dir
    sudo -rm -rf /home/pi/raspinet/reports/$PROF/open_ports/open_ports.xml 
    #TODO Fix this dir
    sudo mv /home/pi/raspinet/reports/$PROF/open_ports/open_ports.html /home/pi/raspinet/reports/$PROF/open_ports/html/open_ports.html
    echo -e "${RED}[raspinet]${RESET} Generating HTML"
    sleep 1
    echo -e "${RED}[raspinet]${RESET} Parsing nmap output..."
    sudo echo "************ OPEN PORTS ***********" > $PODIR/open_ports.txt # overwrite and add a header
    sudo echo "HOST IP:PORT1,PORT2,..." >> $PODIR/open_ports.txt # append a header 
    cat $PODIR/tmp_open_ports.txt | grep open | grep -v Nmap | awk '{printf "%s:",$2;
    for (i=4;i<=NF;i++) { split($i,a,"/"); 
    if (a[2]=="open") printf ",%s",a[1];} print "" }' | sed -e 's/,//' >> $PODIR/open_ports.txt
    echo -e "${RED}[raspinet]${RESET} All Done!"
    scanled_off

}

function get_all_open_ports(){
    echo "Getting all ports"
    # echo -e "${RED}[raspinet]${RESET} Scanning ports from host list"
    # scanled_on
    # sudo chmod 777 $REPDIR/hostinv.txt
    # sudo nmap -Pn -T4 -oG $TMPDIR/tmp_all_ports.txt -oX $REPDIR/ports/all_ports.xml -iL $REPDIR/hostinv.txt
    # echo -e "${RED}[raspinet]${RESET} Scan Complete"
    # sleep 1
    # cd $PORTDIR
    # xsltproc all_ports.xml -o "all_ports.html"
    # sudo cp all_ports.xml all_ports_$DT.xml
    # sudo -rm -rf all_ports.xml 
    # sudo mv all_ports.html $PORTDIR/html/
    # echo -e "${RED}[raspinet]${RESET} Generating HTML"
    # echo -e "${RED}[raspinet]${RESET} All Done!"
    # scanled_off
}
function get_portHosts(){
    echo "Getting Port Hosts"
    # cat $TMPDIR/tmp_open_ports.txt | grep open | grep -v Nmap | awk '{printf "%s:",$2;
    # for (i=4;i<=NF;i++) { split($i,a,"/"); 
    # if (a[2]=="open") printf ",%s",a[1];} print "" }' | sed -e 's/,//' > $PORTDIR/open_ports.txt
}

