#! /bin/sh

# Author: Gary Decosmo
# Description: service for power_switch


### BEGIN INIT INFO
# Provides:          powerSwitch.py
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

# If you want a command to always run, put it here

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Starting powerswitch.py"
    /usr/local/bin/power-switch.py &
    ;;
  stop)
    echo "Stopping power-switch.py"
    pkill -f /usr/local/bin/power-switch.py
    ;;
  *)
    echo "Usage: /etc/init.d/power-switch.sh {start|stop}"
    exit 1
    ;;
esac

exit 0