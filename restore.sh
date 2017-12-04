#!/bin/sh
# Native Open edX Ubuntu 16.04 64 bit Management
# McDaniel
# December 2017
#
# To restore user and course data
# this is a modification of the generic instructions from:
#   Native Open edX Ubuntu 16.04 64 bit Installation
#   https://github.com/alikhil/open-edx-configuring/blob/master/README.md#first-steps-to-do-after-installation-open-edx
#
# and also from
#   https://github.com/BluePlanetLife/openedx-server-prep
#
# Note: easiest way to transfer backup file to this server:
# scp backup.tar.gz root@second-server-ip:~/backup.tar.gz

# unpacking
tar -zxvf backup.tar.gz
cd backup

# restoring mysql
mysql -u root edxapp < backup.sql

# cleaning up mongo db and restoring
mongo edxapp --eval "db.dropDatabase()"
mongorestore dump/

/edx/bin/supervisorctl restart edxapp:
/edx/bin/supervisorctl restart edxapp_worker:
