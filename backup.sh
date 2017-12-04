#!/bin/sh
# Native Open edX Ubuntu 16.04 64 bit Management
# McDaniel
# December 2017
#
# To backup all user and course data
# this is a modification of the generic instructions from:
#   Native Open edX Ubuntu 16.04 64 bit Installation
#   https://github.com/alikhil/open-edx-configuring/blob/master/README.md#first-steps-to-do-after-installation-open-edx
#
# and also from
#   https://github.com/BluePlanetLife/openedx-server-prep
mkdir backup

# backing up mysql db
mysqldump edxapp -u root --single-transaction > backup/backup.sql
cd backup

# backing up mongo db
mongodump --db edxapp
mongodump --db cs_comments_service_development
cd ..

# Packing it to single file for easy copying to second sever
tar -zcvf backup.tar.gz backup/
sudo rm -r backup
