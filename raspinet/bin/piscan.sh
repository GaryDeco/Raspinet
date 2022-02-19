#!/bin/bash

#The >> appends.
#The > operator overwrites the file by first truncating it to be empty and then writing. 

IPADDR=$(ifconfig eth0 | grep -w inet | awk '{print $2}')
TGTRANGE=$(ip addr | grep -w eth0 | grep -w inet | awk '{print $2}')
OUTDIR="$HOME/DSI/scripts/scans/host"

# command function
function piscan(){
case "$1" in	
    '--hlist')
        echo "Performing nmap -iL scan with xml output" 	
        nmap -sL $TGTRANGE -oA $OUTDIR/_hlist
        ;;	
    '--li_grep')
        echo "Performing nmap -iL scan with grep output" 	
        nmap -sL $TGTRANGE -oG $OUTDIR/_hostlist
        ;;
    '--li_total')
        echo "Getting a count of the host scanning range" 	
        nmap -sL $TGTRANGE | grep -w "done" | awk '{print $3}' > $OUTDIR/_hostcount
        echo "The range of IP addresses is ..."
        cat $OUTDIR/_hostcount
        ;;
    '--tcpsyn')
        echo "Performing TCP_SYN ping scan with xml output" 	
        nmap -sn $TGTRANGE -oX $OUTDIR/tcpsyn_$(date +"%Y%m%d_%I%M%p").xml
        ;;
    '--tcpsyn_grep')
        echo "Performing TCP_SYN ping scan with greppable output" 	
        nmap -sn $TGTRANGE -oG | $OUTDIR/_tcpsynlist
        ;;	
    '--tcpsyn_total') #TODO Needs to be updated
        echo "Get the numvber of hosts found by TCP_SYN" 	
        echo "TCP_SYN found the following number of hosts ..."
        cat $OUTDIR/_tcpsynlist | grep -v Nmap | wc -l > $OUTDIR/_tcpcount
        cat $OUTDIR/_tcpcount
        ;;	
    '--h')	
        scan_help
        ;;
    *   )	
        echo "Use piscan [-h] for reference guide"
        ;;
esac    
}

function scan_help(){
echo "
************************************************************************************ 
                        [[[[[[ piscan help reference ]]]]]]
------------------------------------------------------------------------------------
usage:                      nmhosts [option1] 
------------------------------------------------------------------------------------
Note:                       These scans cover the whole range of available 
                            IP's on the network. The target passed to nmap is 
                            (for example) 192.168.68.25/24                 
------------------------------------------------------------------------------------    
[-li]                       Target enumeration: Lists all hosts in network range 
                            with xml output. Does not scan them.
------------------------------------------------------------------------------------
[-li_grep]                  Target enumeration: Lists all hosts in network range 
                            with greppable output. Does not scan them.
------------------------------------------------------------------------------------
[-li_total]                 Get total host count (hc) range in tgt range.
                            Does not scan them.
------------------------------------------------------------------------------------
[-tcpsyn]                   Ping hosts: Using TCP-SYN with xml output
------------------------------------------------------------------------------------
[-tcpsyn_grep]              Ping hosts: Using TCP-SYN with greppable output.
------------------------------------------------------------------------------------
[-tcpsyn_total]             Running total count (hc) of how many hosts tcp scan 
                            found. Does not scan.
------------------------------------------------------------------------------------                                                   
[-h]                        Returns help message
------------------------------------------------------------------------------------
[  ]                        Null argument returns help message
*************************************************************************************    
    "
}
