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
In /etc/my.cnf add these lines *under the MYSQLD section*:

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
4. Setup cron job. Move the bud.sh script to /etc/cron.daily folder

        sudo mv bud.sh /etc/cron.daily

License
=================
Copyright (c) 2016 Bryden Arndt


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
