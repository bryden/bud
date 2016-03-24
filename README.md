About bud.sh
==============
bud.sh (back/up/date) is an automated incremental backup script for MySQL databases. It creates a full backup as often as defined in the configuration settings. Users can restore their database using the most recent full back-up and the row logging files created. 

The bud.sh script is free, like beer. See License below.

Authors
--------------
Bryden Arndt at webHolistics: http://www.webholistics.ca/

Dependencies
--------------
1. Postfix and mail-utils (ubuntu)
2. MySQL

Installation
==============

1. To download bud.sh run the following commands:

        git clone https://github.com/bryden/bud.git
        
2. Enable row-based logging in MySQL.
In /etc/my.cnf add these lines **under the MYSQLD section**:

        log-bin = mysql-bin
        binlog_format = ROW

3. Configure bud.sh to meet specific needs. Open bud.sh and set the variables at the top of the file:

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

4. This file has database passwords so we should restrict access:

        sudo chmod 700 bud.sh

5. Setup an ssh key for the script so that it can send a copy remotely without requiring a user to enter their password.

        ssh-keygen -t rsa
        Generating public/private rsa key pair.
        Enter a file in which to save the key (/Users/you/.ssh/id_rsa): [Press enter]
        Enter passphrase (empty for no passphrase): [Type a passphrase]
        Enter same passphrase again: [Type passphrase again]

    Copy your ssh key to the remote host 

        ssh-copy-id user@hostname.example.com

    Add your ssh key
    
        eval `ssh-agent -s`
        ssh-add

    Test the ssh connection and then exit

        ssh user@hostname.example.com
        exit

6. Setup cron job.

        sudo vi /etc/crontab

    Add this line, replace USERNAME with the user on the server who should run the script (don't use root) and /PATH/TO/SCRIPT/ to the location of bud.sh
    
        0 3 * * * USERNAME /PATH/TO/SCRIPT/bud.sh

License
=================
Copyright (c) 2016 Bryden Arndt


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
