#!/bin/bash

OUTDIR=$HOME/raspinet

sudo curl https://raw.githubusercontent.com/GaryDeco/Raspinet/main/raspinet/wakeled.py > $OUTDIR/wakeled.py
sudo chmod 777 $OUTDIR/wakeled.py
sudo chmod 777 /etc/rc.local

update_rclocal(){
cat << EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi

nohookup sudo python3 /home/dev/raspinet/wakeled.py >/dev/null 2>&1 &
exit 0
EOF
}
update_rclocal > /etc/rc.local




