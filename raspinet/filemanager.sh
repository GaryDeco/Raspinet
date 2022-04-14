#!/bin/bash

# archive and remove files older than 30 days
ARCHDIR=$HOME/raspinet/reports/archive
REPDIR=$HOME/raspinet/reports

# archive all files that have not been modified for 30 days in /raspinet/reports dir.
find $REPDIR -mtime +30 -type f | xargs tar -czvPf $ARCHDIR/arch_$(date +%F).tar.gz
# remove the primary files after they are archived
find $REPDIR -mtime +30 -type f -delete



