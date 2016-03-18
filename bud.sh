#!/bin/bash

####################################
# USER SETTINGS - PLEASE CONFIGURE #
####################################
USER="root" # a mysql admin user account
PASS="root" # the mysql admin password
BACKDIR="/home/brydena/mysql-bak" # the directory where you setup your mysql-bak folder
FULLBACKUPLIFE=4320 # how often a full backup (rather than incremental) should be completed (4320 == 3 days)
DATABASE="" # the database that should be targeted for back-up
EMAIL="" # your email address for success/failure notifications
#NOTIFY_SUCCESS="YES" # notify on success? YES/NO

####################################
# ONLY REQUIRED FOR REMOTE BACKUPS #
####################################
REMOTEUSER="" # the username that you have setup for ssh
REMOTEHOST="" # the hostname of the server to ssh into
REMOTEDIR="/home/arndtb/bud/" # the remote directory to copy backups to

#################################
# SYSTEM SETTINGS - DO NOT EDIT #
#################################
BASEBACKDIR="$BACKDIR/$DATABASE" # leave as-is
#INCRBACKDIR="$BACKDIR/incr" # leave as-is
START=`date +%s` # leave as-is
TMPFILE="$DATABASE-$START.sql" # leave as-is

########
# CODE #
########

echo "BUD: Backup script starting..."

# TEST FOR CORRECT SETUP
if test ! -d $BASEBACKDIR -o ! -w $BASEBACKDIR
then
    error
    echo "BUD: $BASEBACKDIR does not exist or is not writable"; echo
    exit 1
fi

if [ -z "`mysqladmin -u $USER --password=$PASS status | grep 'Uptime'`" ]
then
    echo "BUD: HALTED! MySQL does not appear to be running or mysql user/pass is incorrect."; echo
    exit 1
fi

echo "BUD: Checking for mysql datadir"
DATADIR=`mysql -u $USER --password=$PASS -e 'SHOW VARIABLES WHERE Variable_Name = "datadir"' | grep mysql | awk '{print $2}'`

echo "BUD: Datadir listed in MySQL as: $DATADIR"
echo "BUD: Setup check completed fantastically. Pat yourself on the back and tell yourself \"Good work!\""
echo "BUD: Back to more serious things. Checking for latest backup file..."

# CHECK FOR LATEST BACKUP
LATEST=`find $BASEBACKDIR -mindepth 1 -maxdepth 1 -printf "%P\n" | sort -nr | head -1`

AGE=`stat -c %Y $BASEBACKDIR/$LATEST`
#echo "AGE : $AGE\n LATEST : $LATEST"

#if [ "$LATEST" -a `expr $AGE + $FULLBACKUPLIFE + 5` -ge $START ]
#then

#else
    echo "BUD: New full backup"
    # Create a new full backup
    echo "BUD: Saving to $BASEBACKDIR/$TMPFILE"
    mysqldump -u $USER --password=$PASS $DATABASE > $BASEBACKDIR/$TMPFILE
    tar -zcvf $BASEBACKDIR/$TMPFILE.tar.gz $BASEBACKDIR/$TMPFILE
    rm $BASEBACKDIR/$TMPFILE
    TMPFILE="$TMPFILE.tar.gz"

    # Email notification to admin
    MESSAGE="Full backup of MySQL completed successfully for $DATABASE.\n"
    MESSAGE="$MESSAGE $BASEBACKDIR/$TMPFILE\n"
    echo $MESSAGE | mail -s "BUD: Full backup successful" "$EMAIL"

    # Copy the database to a remote folder
    echo "BUD: Transferring $TMPFILE to $REMOTEHOST:/$REMOTEDIR"
    scp $BASEBACKDIR/$TMPFILE $REMOTEUSER@$REMOTEHOST:/$REMOTEDIR/
    echo "BUD: Removing last backup: $LATEST"
    rm $BASEBACKDIR/$LATEST
    echo 'BUD: Exiting. Goodbye.'
#fi

