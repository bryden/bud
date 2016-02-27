#!/bin/bash


###################
# CONFIG/SETTINGS #
###################

USER="root"
PASS="root"
BACKDIR="mysql-bak"
BASEBACKDIR="$BACKDIR/base"
INCRBACKDIR="$BACKDIR/incr"
FULLBACKUPLIFE=3600
START=`date +%s`
TMPFILE="$START.sql"
DATABASE="webholistics"


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
    mysqlbackup -u $USER -p $PASS --incremental
else
    echo "New full backup"
    # Create a new full backup
    echo "Saving to $BASEBACKDIR/$TMPFILE"
    mysqldump -u $USER --password=$PASS $DATABASE > $BASEBACKDIR/$TMPFILE
fi

