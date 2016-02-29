#!/bin/bash

####################################
# USER SETTINGS - PLEASE CONFIGURE #
####################################
USER="root" # a mysql admin user account
PASS="root" # the mysql admin password
BACKDIR="mysql-bak" # the directory where you setup your mysql-bak folder
FULLBACKUPLIFE=3600 # how often a full backup (rather than incremental) should be completed
DATABASE="webholistics" # the database that should be targeted for back-up
EMAIL="bryden@arndt.ca" # your email address for success/failure notifications
NOTIFY_SUCCESS="YES" # notify on success? YES/NO

#################################
# SYSTEM SETTINGS - DO NOT EDIT #
#################################
BASEBACKDIR="$BACKDIR/base" # leave as-is
INCRBACKDIR="$BACKDIR/incr" # leave as-is
START=`date +%s` # leave as-is
TMPFILE="$START.sql" # leave as-is


########
# CODE #
########

# TEST FOR CORRECT SETUP

echo "Backup script commencing..."

if test ! -d $BASEBACKDIR -o ! -w $BASEBACKDIR
then
    error
    echo "$BASEBACKDIR does not exist or is not writable"; echo
    exit 1
fi

if test ! -d $INCRBACKDIR -o ! -w $INCRBACKDIR
then
    error
    echo "$INCRBACKDIR does not exist or is not writable"; echo
    exit 1
fi

if [ -z "`mysqladmin -u $USER --password=$PASS status | grep 'Uptime'`" ]
then
    echo "HALTED: MySQL does not appear to be running."; echo
    exit 1
fi

echo "Checking for mysql datadir"
DATADIR=`mysql -u $USER --password=$PASS -e 'SHOW VARIABLES WHERE Variable_Name = "datadir"' | grep mysql | awk '{print $2}'`

echo "Datadir: $DATADIR"

echo "Setup check completed fantastically. Good work."
echo "Checking for latest backup file..."


# CHECK FOR LATEST BACKUP

LATEST=`find $BASEBACKDIR -mindepth 1 -maxdepth 1 -printf "%P\n" | sort -nr | head -1`

AGE=`stat -c %Y $BASEBACKDIR/$LATEST`
echo "AGE : $AGE\n LATEST : $LATEST"

if [ "$LATEST" -a `expr $AGE + $FULLBACKUPLIFE + 5` -ge $START ]
then
    echo 'New incremental backup'
    # Create an inremental backup

    # Check incr sub dir exists
    # try to create if not
    if test ! -d $INCRBACKDIR/$LATEST
    then
        mkdir $INCRBACKDIR/$LATEST
    fi

    # Check incr sub dir exists and is writable
    if test ! -d $INCRBACKDIR/$LATEST -o ! -w $INCRBACKDIR/$LATEST
    then
        echo $INCRBASEDIR 'does not exist or is not writable'
        exit 1
    fi

    LATESTINCR=`find $INCRBACKDIR/$LATEST -mindepth 1 -maxdepth 1 -type d | sort -nr | head -1`
    if [ ! $LATESTINCR ]
    then
        # This is the first incremental backup
        INCRBASEDIR=$BASEBACKDIR/$LATEST
    else
        # This is a 2+ incremental backup
        INCRBASEDIR=$LATESTINCR
    fi

    # Create incremental backup
    echo "Incremental export happening"
    mysqlbackup -u $USER -p $PASS --incremental
else
    echo "New full backup"
    # Create a new full backup
    echo "Saving to $BASEBACKDIR/$TMPFILE"
    mysqldump -u $USER --password=$PASS $DATABASE > $BASEBACKDIR/$TMPFILE
    MESSAGE="Full backup of MySQL completed successfully for $DATABASE.\n"
    MESSAGE="$MESSAGE $BASEBACKDIR/$TMPFILE\n"
    echo $MESSAGE | mail -s "BUD: Full backup successful" "$EMAIL"
fi

