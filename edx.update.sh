#!/bin/sh
# Native Open edX Ubuntu 16.04 64 bit Update
# McDaniel
# January 2018
#
# To update the Open edX software on a single-server instance of Open edX Ginkgo.1
# this is a modification of the generic instructions from:
#   Native Open edX Ubuntu 16.04 64 bit Installation
#   https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/146440579/Native+Open+edX+Ubuntu+16.04+64+bit+Installation
#
# This script takes around 1 hour to complete. It is intended to be run unattended, on a background thread using
# nohup.
#
# NOTE: if you have a server-vars.yml file then copy it to /home/ubuntu/server-vars.yml
#       before executing the script. this script will place a copy of your server-vars.yml
#       in the correct location at the appropriate time.
#====================================================================================================================

# ensure we're in the home directory
cd ~


# 1. Set the OPENEDX_RELEASE variable:
export OPENEDX_RELEASE=open-release/ginkgo.2


# 2. look for a server-vars.yml file in the home directory
if [[ -f server-vars.yml ]]; then
  echo "found server-vars.yml";
  echo "copying to /edx/app/edx_ansible/server-vars.yml";
  sudo cp server-vars.yml /edx/app/edx_ansible/server-vars.yml
fi

# 3. Stop the LMS and CMS
echo "Stopping LMS and CMS";
/edx/bin/supervisorctl stop edxapp:
/edx/bin/supervisorctl stop edxapp_worker:

# 4. remove the current software repo
echo "Removing existing edx-platform repo";
sudo rm -rf /edx/app/edxapp/edx-platform

# 5. Update Open edX:
echo "Beginning the software update";
wget https://raw.githubusercontent.com/edx/configuration/$OPENEDX_RELEASE/util/install/sandbox.sh -O - | bash > edx.install.out
