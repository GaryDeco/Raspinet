#!/usr/bin/env bash

#########################################################################################################

# Author: Gary Decosmo
# Date Created: 1/28/2022
# Description: Network Analyzer Configuration Tool
#########################################################################################################
#------------------------------------    MENU CONFIG    ----------------------------------------#

AUTHOR="Gary Decosmo"
VERSION="v0.0.3"
BKTITLE="RasPiNet [$VERSION] [IP: $(hostname -I)]"
# some terminal colors
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"
RAZBAN="${RED}[raspinet]${RESET}"
# raspinet directory
RASDIR=/home/pi/raspinet/
# reports directory
REPDIR=$RASDIR/reports
# live hosts directory
UPHOSTSDIR=$REPDIR/live_hosts
# Current network host range (CIDR)
HOST_RANGE=$(ip -4 -o addr show eth0 | awk '{print $4}') 
IFPATH="/sys/class/net"
ETH0=$IFPATH/eth0/operstate
WIFI0=$IFPATH/wlan0/operstate
WIFI1=$IFPATH/wlan1/operstate
ISUP="${GREEN}Up${RESET}"
ISDOWN="${RED}Down${RESET}"
ETH0IP=$(ip addr show | grep eth0 | grep inet | awk '{print$2}' | cut -d'/' -f1)

DT=$(date "+%F-%H-%M")
# gpio
SCANLED_DIR=/sys/class/gpio/gpio22
sudo usermod -aG gpio dev # permissions for gpio access (dev user)

if [ -f $RASDIR/profiles/default.txt ];then
    PROF=$(cat $RASDIR/profiles/default.txt)
else
    set_prof_to_default
fi

function scanled_on(){

    gpio export 22 out
    echo 1 > $SCANLED_DIR/value

}

function scanled_off(){

    echo 0 > $SCANLED_DIR/value
    gpio export 22 in
    
}

## Util Methods:
function dispMsg() {
    whiptail --title "$1" --msgbox "$2" 8 78
}

function dlogMsg(){
    dialog --title "$1" --msgbox "$2" 8 7
}

function build_profdirs(){
    # build_profdirs [profile name]
    # make directories for the profile
    sudo touch /home/pi/raspinet/profiles/default.txt
    sudo chmod 777 /home/pi/raspinet/profiles/default.txt
    sudo touch /home/pi/raspinet/profiles/temp.txt
    sudo chmod 777 /home/pi/raspinet/profiles/temp.txt
    sudo touch /home/pi/raspinet/profiles/proflog.txt
    sudo chmod 777 /home/pi/raspinet/profiles/proflog.txt
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/up_hosts
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/up_hosts/xml
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/up_hosts/html
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/up_hosts/dt
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/down_hosts
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/open_ports
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/open_ports/xml
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/open_ports/html
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/closed_ports
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/closed_ports/xml
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/closed_ports/html 
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/filtered_ports
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/filtered_ports/xml
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/filtered_ports/html
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/os_versions
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/os_versions/xml
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/os_versions/html
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/services
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/services/xml
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/services/html
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/flagged
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/flagged/xml
    sudo mkdir -p -m777 /home/pi/raspinet/reports/$1/flagged/html
}

function add_to_proflog(){
    # add to temp profiles
    sudo echo -e $1 >> /home/pi/raspinet/profiles/temp.txt #make a temp to handle duplicates
    awk '!seen[$0]++' /home/pi/raspinet/profiles/temp.txt > /home/pi/raspinet/profiles/proflog.txt #remove duplicates for netprof log
}

function set_defpro(){
    # sets and adds a profile as the active profile 
    if [ -f /home/pi/raspinet/profiles/default.txt ]; then
        sudo echo -e $1 > /home/pi/raspinet/profiles/default.txt
        sudo echo -e $1 >> /home/pi/raspinet/profiles/temp.txt
        if grep -q $1 "/home/pi/raspinet/profiles/default.txt"; then
            PROF=$(cat /home/pi/raspinet/profiles/default.txt)
            if ! grep -q "$PROF" "/home/pi/raspinet/profiles/temp.txt"; then
                add_to_proflog $1
                dispMsg "($PROF) is now the current active profile" 
            else
                sudo awk '!seen[$0]++' /home/pi/raspinet/profiles/temp.txt > /home/pi/raspinet/profiles/proflog.txt #remove duplicates for netprof log 
                dispMsg "($PROF) is the current active profile"
            fi
        fi
    fi 
}

function check_active_prof(){
    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
    if [ "$1" != "$PROF" ];then 
        if ! grep -q "$1" "/home/pi/raspinet/profiles/proflog.txt"; then
            dispMsg "($1) is not a profile"
            if whiptail --yesno "Do you want to add $1 as a new profile?" 8 78; then
                build_profdirs $1
                add_to_proflog $1
                if whiptail --yesno "Do you want to set $1 as the active profile?" 8 78; then
                    set_defpro $1
                    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
                    dispMsg "Current Active Network Profile" "                                $PROF"
                else

                    dispMsg "$1 Added to profiles"
                fi
            else
                dispMsg "Profile not added"
            fi
        else
            dispMsg "$1 already exists"
            if whiptail --yesno "Do you want to set $1 as the active profile?" 8 78; then
                set_defpro $1
                PROF=$(cat /home/pi/raspinet/profiles/default.txt)
                dispMsg "Profile set to" "                                $PROF"
            else
                dispMsg "Current Active Network Profile" "                                $PROF"
            fi
        fi
    else
        dispMsg "Profile:[$1] is already active!"
    fi 
}

function set_prof_to_default(){
    sudo echo -e "default" > /home/pi/raspinet/profiles/default.txt
    sudo echo -e "default" >> /home/pi/raspinet/profiles/temp.txt
    sudo awk '!seen[$0]++' /home/pi/raspinet/profiles/temp.txt > /home/pi/raspinet/profiles/proflog.txt #remove duplicates for netprof log 
    if ! grep -q "default" "/home/pi/raspinet/profiles/default.txt"; then
        PROF="default"
    fi
}

function get_ethstate(){
    if [ `grep "" $ETH0` == "up" ];then
        E0IF="eth0 (ethernet)"
        E0STATE="$ISUP"
        E0IP="${GREEN}$ETH0IP${RESET}"
    else
        E0IF="eth0 (ethernet)"
        E0STATE="$ISDOWN"
        E0IP="${GREEN}$ISDOWN${RESET}"
    fi
}

function get_w0state(){
    if [ `grep "" $WIFI0` == "up" ];then
        W0IF="wlan0 (built-in Wi-Fi)"
        W0STATE="$ISUP"
        W0IP="${GREEN}$WLAN0IP${RESET}"
    else
        W0IF="wlan0 (built-in Wi-Fi)"
        W0STATE="$ISDOWN"
        W0IP="${GREEN}$ISDOWN${RESET}"
    fi
}

function get_w1state(){
    if [ `grep "" $WIFI1` == "up" ];then
        W1IF="wlan0 (Wi-Fi dongle)"
        W1STATE="$ISUP"
        W1IP="${GREEN}$WLAN1IP${RESET}"

    else
        W1IF="wlan0 (Wi-Fi dongle)"
        W1STATE="   $ISDOWN"
        W1IP="${GREEN}$ISDOWN${RESET}"
    fi
}

function show_banner_info(){
    echo $(clear)
    echo
    figlet -c -f ~/.local/share/fonts/figlet-fonts/Big.flf "Welcome To" | lolcat
    figlet -c -f ~/.local/share/fonts/figlet-fonts/3d.flf RasPiNet | lolcat
    echo 
    echo
    echo "Author: Gary Decosmo"
    echo "Campbell University"
    echo
    echo "$(date)"
    echo -e "Current Network Profile: ${GREEN}$PROF${RESET}"
    echo
    echo "   INTERFACE               STATUS               IP ADDRESS"
    echo "---------------" "       ---------------" "       ---------------"
    get_ethstate
    if [ `grep "" $ETH0` == "up" ];then
        echo -e "$E0IF             "$E0STATE"                  "$E0IP
        echo
    else
        echo -e "$E0IF              "$E0STATE"                   $E0IP"
        echo
        echo -e "$RAZBAN No ethernet link detected. Please connect and retry..."
        echo -e "$RAZBAN exiting..."
        echo
        sleep 1
        exit
    fi
    sleep $1
}

function main() {
    # update the profile variable.
    PROF=$(cat /home/pi/raspinet/profiles/default.txt)
    sudo bash /home/pi/raspinet/filemanager.sh
    while true; do
        mainmenu=$(whiptail --title "RasPiNet Main Menu" --backtitle "$BKTITLE" --ok-button "Select" --cancel-button "Quit to Terminal" --menu "Select an option" 20 78 10 \
            "1 System Config" " Access the Raspi-config tool" \
            "2 Arp Scan" " Choose a range of hosts to ping and view the output" \
            "3 Net-Info" " View a network information report" \
            "4 Default Scans " " Default Options for scans" \
            "5 Smart Scans" " Under Construction" \
            "6 Network Profiles" " Change network profiles for scan reporting" \
            3>&1 1>&2 2>&3)

            exitstatus=$?

            if [ ${exitstatus} = 0 ]; then
                case ${mainmenu} in
                    1\ *) 
                            main_option1
                            ;;
                    2\ *) 
                            main_option2
                            ;;            
                    3\ *) 
                            main_option3
                            ;;
                    4\ *) 
                            main_option4
                            ;;
                    5\ *) 
                            main_option5
                            ;;
                    6\ *) 
                            main_option6
                            ;;
                esac
            else
                show_banner_info 0.1
                exit
            fi
    done
}

#------------------------------------ OPTION 1 ----------------------------------------#

function main_option1() {
    whiptail --title "Notification" --msgbox "Proceeding to the Raspberry Pi Configuration Menu." 8 78
    sudo raspi-config
}

#------------------------------------ OPTION 2 ----------------------------------------#

function main_option2() {

    if (whiptail --title "Do you want to Proceed?" --yesno "Choose [Y/N]" 8 78) then
        dispMsg "Switching to terminal"
        sudo bash /home/pi/DSI/scripts/update_arp_cache.sh
        echo "Press <enter> to proceed"
        read line
        dispMsg "Going back to the main menu"
    else
        dispMsg "Going back to the main menu"
    fi
}

#------------------------------------ OPTION 3 ----------------------------------------#

function main_option3() {

    dispMsg "Generating Report"
	sudo bash /home/pi/DSI/scripts/whiptail/get_netinfo.sh
    #read line 
	dispMsg "Going back to the main menu"
}

#------------------------------------ OPTION 4 ----------------------------------------#

function main_option4() {
while true; do
    OPTIONS=$(whiptail --title "Default Scan Menu" --backtitle "$BKTITLE" --ok-button "Select" --cancel-button "Back To Main" --menu "Select an option" 20 78 10 \
            "1 Host Inventory" " Get a list of live hosts" \
            "2 Port Scan" " Get a list of live hosts and open ports" \
            "3 OS Detection" " Get a list of hosts and running services" \
            "4 Combined" " Get Hosts/Ports/and OS-services" \
            3>&1 1>&2 2>&3)

        exitstatus=$?

    if [ ${exitstatus} = 0 ]; then
        case ${OPTIONS} in
            1\ *)  
                    scanOption1
                    ;;
            2\ *)  
                    scanOption2
                    ;;
            3\ *)  
                    scanOption3
                    ;;
            4\ *)  
                    scanOption4
                    ;;
        esac
    else
       main
    fi
done
}

#------------------------------------ OPTION 5 ----------------------------------------#

function main_option5() {
while true; do
    OPTIONS=$(whiptail --title "Smart Scan Menu" --backtitle "$BKTITLE" --ok-button "Select" --cancel-button "Back To Main" --menu "Select an option" 20 78 10 \
            "1 Smart Scan 1 (TBD)" " Smart Scan 1 Descrption (TBD)" \
            "2 Smart Scan 2 (TBD)" " Smart Scan 2 Descrption (TBD)" \
            "3 Smart Scan 3 (TBD)" " Smart Scan 3 Descrption (TBD)" \
            "4 Smart Scan 4 (TBD)" " Smart Scan 4 Descrption (TBD)" \
            3>&1 1>&2 2>&3)

        exitstatus=$?

    if [ ${exitstatus} = 0 ]; then
        case ${OPTIONS} in
            1\ *)  
                    smscanOption1
            ;;
            2\ *)  
                    smscanOption2
            ;;
            3\ *)  
                    smscanOption3
            ;;
            4\ *)  
                    smscanOption4
            ;;
        esac
    else
        exit
    fi
done
}

#------------------------------------ OPTION 6 ----------------------------------------#

function main_option6() {

    while true; do
        OPTIONS=$(whiptail --title "Network Profile Manager" --backtitle "$BKTITLE" --ok-button "Select" --cancel-button "Back To Main" --menu "Select an option" 20 78 10 \
                "1 Network Profiles" " View all current profiles" \
                "2 Select/Create" " Select new or create a profile" \
                "3 About" " Network profiles explained" \
                3>&1 1>&2 2>&3)

            exitstatus=$?

        if [ ${exitstatus} = 0 ]; then
            case ${OPTIONS} in
                1\ *)  
                        profOption1
                ;;
                2\ *)  
                        profOption2
                ;;
                3\ *)  
                        profOption3
                ;;
            esac
        else
            main
        fi
    done
}

function profOption1(){

    whiptail --title "Network Profiles" --textbox /home/pi/raspinet/profiles/proflog.txt 20 60 --scrolltext

} 

function profOption2(){

    name=$(whiptail --inputbox "Enter a profile name (single string, no spaces)" 10 30 3>&1 1>&2 2>&3)
    if [ "$name" == "" ]; then
        dispMsg "Nothing Entered, Going back to the main menu"
    else   
        check_active_prof $name
    fi

}  

function p3(){
cat << EOF
About Network Profiles:
(scroll using down arrow on keyboard)

Network profiles are neccessary in order 
to distinguish one network from another.
when a profile is created, a new report 
directory is created under that profile 
name. All scans and reports conducted 
under that profile are saved to that 
directory. It is up to the user to ensure 
the correct profile is used for the 
network being analyzed. If it is 
incorrect, the reporting will be 
corrupted/inaccurate. Please use caution. 

Creating a new profile:

Select option 2, and type in a single string.
If the name exists, you can switch to it,
if it does not exist, you can add it as a 
new profile or exit to return to the menu.
Your new profile wil be switched to auto-
matically upon creation. 

Author: Gary Decosmo
EOF
}

function profOption3(){

    p3 > /home/pi/raspinet/profiles/about.txt
    whiptail --title "About Network Profiles" --textbox /home/pi/raspinet/profiles/about.txt 20 60 --scrolltext
    
} 

############################### END OF OPTIONS FOR MAIN MENU ###################################

####################################### SCAN OPTIONS ###########################################

#------------------------------------ Default Scan Menu ----------------------------------------#

function scanOption1(){
    PROFDIR=$REPDIR/$PROF
    HOSTUP=$PROFDIR/up_hosts
    # host inv
    COUNT=0
    source /home/pi/raspinet/piscan.sh
    (( COUNT+=10 ))
    echo $COUNT | dialog --gauge "Please wait: Setting up scan..." 10 70 0
    sleep 1
    scanled_on
    (( COUNT+=10 ))
    echo "$COUNT" | dialog --gauge "Please wait: Looking for Hosts (this may take a while)..." 10 70 0
    sleep 1
    sudo nmap -n -sn $HOST_RANGE -oG - | awk '/Up$/{print $2}' > $HOSTUP/hostinv.txt
    (( COUNT+=60 ))
    echo "$COUNT" | dialog --gauge "Please wait: Hosts found..." 10 70 0
    sleep 1
    sudo cp $HOSTUP/hostinv.txt $HOSTUP/hostinv_$DT.txt
    sudo cp $HOSTUP/hostinv.txt $PROFDIR/tgts_all.txt 
    (( COUNT+=10 ))
    echo "$COUNT" | dialog --gauge "Please wait: Finishing up..." 10 70 0
    sleep 1
    # Update the current host count
    cat $HOSTUP/hostinv.txt | echo "$DT, $(wc -l)" >> $HOSTUP/hostinv_runcount.txt
    cat $HOSTUP/hostinv.txt | wc -l > $HOSTUP/hostinv_count.txt
    scanled_off
    (( COUNT+=10 ))
    echo "$COUNT" | dialog --gauge "All Done!:" 10 70 0
    sleep 1
    whiptail --title "Active Host IP Addresses (scroll-box)" --textbox $HOSTUP/hostinv.txt 20 60 --scrolltext 
    clear #the dialog tool leaves a messy screen so it needs to be cleared
    dispMsg "Heading back to the main menu"
    #main # go back to main
}

function scanOption2(){
    PROFDIR=$REPDIR/$PROF
    PODIR=$PROFDIR/open_ports
    POXML=$PODIR/xml
    POHTML=$PODIR/html
    COUNT=0
    sleep 1
    echo $COUNT | dialog --gauge "Getting ready..." 10 70 0
    scanled_on
    (( COUNT+=10 ))
    echo $COUNT | dialog --gauge "Preparing to scan..." 10 70 0
    sleep 1
    sudo chmod 777 $PROFDIR/tgts_all.txt
    (( COUNT+=10 ))
    echo $COUNT | dialog --gauge "Scanning top 100 ports (This may take a while)..." 10 70 0
    sudo nmap --top-ports 100 -F --open -oG $PODIR/tmp_open_ports.txt -oX $POXML/open_ports.xml -iL $PROFDIR/tgts_all.txt
    sleep 1
    echo $COUNT | dialog --gauge "Scan complete..." 10 70 0
    cd $POXML
    xsltproc open_ports.xml -o "open_ports.html"
    sudo mv open_ports.html $POHTML/open_ports.html
    sudo cp open_ports.xml open_ports_$DT.xml
    sudo rm -rf $open_ports.xml
    sleep 1
    (( COUNT+=40 ))
    sudo echo "************ OPEN PORTS ***********" > $PODIR/open_ports.txt # overwrite and add a header
    sudo echo "HOST IP:PORT1,PORT2,..." >> $PODIR/open_ports.txt # append a header
    cat $PODIR/tmp_open_ports.txt | grep open | grep -v Nmap | awk '{printf "%s:",$2;
    for (i=4;i<=NF;i++) { split($i,a,"/"); 
    if (a[2]=="open") printf ",%s",a[1];} print "" }' | sed -e 's/,//' >> $PODIR/open_ports.txt
    (( COUNT+=10 ))
    echo $COUNT | dialog --gauge "Parsing data..." 10 70 0
    sleep 1
    (( COUNT+=10 ))
    echo $COUNT | dialog --gauge "Cleaning up..." 10 70 0
    sleep 1
    (( COUNT+=10 ))
    scanled_off
    echo $COUNT | dialog --gauge "Done..." 10 70 0
    sleep 1 
    whiptail --title "Hosts with Open Ports (scroll-box)" --textbox $PODIR/open_ports.txt 20 60 --scrolltext 
    clear #the dialog tool leaves a messy screen so it needs to be cleared
    dispMsg "Heading back to the main menu"
    #main # go back to main
}

function scanOption3(){

    dispMsg "Add OS/services scan here"

}

function scanOption4(){

    dispMsg "Add Hosts,Ports, and services scan here"

}
#################################### Smart Scan Menu #########################################
function smscanOption1(){

    dispMsg "Add Smart Scan 1 Here"

}
function smscanOption2(){

    dispMsg "Add Smart Scan 2 Here"

}

function smscanOption3(){

    dispMsg "Add Smart Scan 3 Here"

}

function smscanOption4(){

    dispMsg "Add Smart Scan 4 Here"

}

#################################### END OF CONFIG ###########################################
# execute main
# make sure the profile variable is updated
PROF=$(cat /home/pi/raspinet/profiles/default.txt)
sudo bash /home/pi/raspinet/filemanager.sh
show_banner_info 3
main





